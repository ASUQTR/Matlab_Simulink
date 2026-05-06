---
layout: default
title: "Pipeline MATLAB & scripts"
---

# Pipeline MATLAB — rôle et détail de calcul

Cette page décrit précisément ce que fait chaque script principal du dépôt et comment les matrices `A` et `B` sont construites et utilisées.

---

## Diagramme de flux

```
Parameters.m ──────────────────────────────────────────────────────────────┐
     │                                                                     │
     ▼                                                                     │
Generate_PyMatrix.m ──► ABmatrice.mat (A, B symboliques)                  │
                                │                                          │
                                ▼                                          │
                   calcul_matrice_A_lineaire.m ◄────────────────────────── ┘
                        │              │
                        │         calcul_Q.mat ◄── trouver_matrice_Q.m
                        │
                        ├──► Matrice_A_lineaire.mat (A_num, B_num)
                        └──► K_LQR.mat (K)
                                   │
                                   ▼
                         Simulink (.slx) / Simulation
                                   │
                                   ▼
                   Graphique.m / instabiliter_graphique.m
                                   │
                                   ▼
                           docs/figures (images)
```

> **Note** : Le diagramme ci-dessus est une représentation textuelle. Sur GitHub, le Mermaid du README est rendu nativement.

---

## `Generate_PyMatrix.m`

**Objectif** : formaliser le modèle non-linéaire symbolique et calculer les jacobiennes.

Ce que fait le script :
- Définit symboliquement l'état $x = [x, y, z, \phi, \theta, \psi, u, v, w, p, q, r]^T$ et les commandes (throttles des propulseurs).
- Construit la matrice d'inertie rigide `Mrb` et la masse ajoutée `Ma`, les matrices d'amortissement (linéaire/quadratique), la matrice de Coriolis `C` et le terme gravité `G`.
- Assemble la dynamique non-linéaire sous la forme $\dot{x} = f(x) + g(x)\,u$.
- Calcule symboliquement les jacobiennes :
  - $A(x_0, u_0) = \partial f / \partial x \big\|_{(x_0,u_0)}$,
  - $B(x_0, u_0) = \partial g / \partial u \big\|_{(x_0,u_0)}$.
- Sauvegarde `ABmatrice.mat` (objets symboliques) et exporte `Matrix_centrer.txt`.

> `A` et `B` sont obtenues par différentiation symbolique ; l'assemblage numérique intervient ensuite dans `calcul_matrice_A_lineaire.m`.

---

## Construction détaillée de `A` et `B` (pas-à-pas)

### 1. Assemblage des termes d'inertie et d'hydrodynamique

- Matrice d'inertie rigide : $M_{rb}$ (6×6) construite à partir de `mass`, `Ix, Iy, Iz, Ixy, ...`
- Matrice de masse ajoutée : $M_a$ (6×6) issue des coefficients `Xu_dot, Yv_dot, ...`
- Masse totale utilisée dans le calcul inertiel :

$$M = M_{rb} + M_a.$$

### 2. Coriolis et amortissement

- Matrice de Coriolis $C$ calculée par `coriolisMatrix(M, state)` (dépend de $M$ et des vitesses).
- Terme d'amortissement $D$ = `linear_damping + quadratic_damping`.

### 3. Terme gravité/flottabilité

- Vecteur $G$ calculé par `gravityMatrix(state, mass, ...)` (poids vs poussée d'Archimède, dépend des angles d'Euler).

### 4. Partie cinématique

- La transformation de vitesses corps→NED est fournie par `J(state)` ; la partie supérieure de la dynamique utilise cette jacobienne de coordonnées.

### 5. Écriture de la dynamique non-linéaire

On construit symboliquement

$$f_1 = \begin{bmatrix}0_{6\times6} & J(\text{state}) \\ 0_{6\times6} & -M^{-1}(C - D)\end{bmatrix},$$

> **Note** : ici $D$ est la matrice d'amortissement (termes résistifs positifs) et $C$ la matrice de Coriolis. Le signe moins devant $M^{-1}$ avec $(C - D)$ reflète le signe conventionnel utilisé dans le code MATLAB — vérifier le signe de $D$ selon la convention choisie (résistance ou dissipation).

$$f_2 = \begin{bmatrix}0_{6\times1} \\ -M^{-1} G\end{bmatrix},$$

puis la dynamique interne (sans commandes) est

$$f(x) = f_1(x)\,x + f_2(x).$$

### 6. Allocation des propulseurs → terme de commande

- `thrust_direction` et `thrust_position` définissent l'allocation.
- `thrust_allocation` (6×8) mappe les 8 propulseurs en forces et couples.
- Les entrées symboliques `du_i` sont transformées en forces : `u_control(i) = du_i * abs(du_i)`, puis

$$\tau = T\,u_{\text{control}},$$

où $T$ est la matrice d'allocation (6×8).

- Le vecteur de commande dans l'équation d'état est

$$g(x,u) = M^{-1}\,\tau,$$

affectant uniquement les lignes 7 à 12 de l'état.

### 7. Construction de l'état dérivé

`state_dot = f(x) + g(x,u)` (stocké symboliquement).

### 8. Calcul des jacobiennes

$$
A(x_0,u_0) = \left.\frac{\partial\,\mathrm{state\_dot}}{\partial x}\right|_{(x_0,u_0)}
$$

calculée par `df_dstate = jacobian(state_dot, state)`.

$$
B(x_0,u_0) = \left.\frac{\partial\,\mathrm{state\_dot}}{\partial u}\right|_{(x_0,u_0)}
$$

calculée par `jacobian(state_dot, transpose(du))`.

### 9. Substitution numérique

`Parameters.m` fournit les valeurs numériques pour `mass`, inerties, coefficients de damping, etc. L'évaluation numérique se fait via `subs`/`vpa` avant de sauver dans `ABmatrice.mat`.

### 10. Export et vérification

`Matrix_centrer.txt` contient la forme textuelle des éléments de `A` et `B` pour inspection.

**Remarques pratiques :**
- La dépendance non-linéaire via `du*abs(du)` rend $B$ dépendant du point d'équilibre — choisir un point cohérent.
- Les termes de Coriolis dans les blocs 7:12 de $A$ créent les couplages gyroscopiques.
- En roulis/pitch non nul, les termes de gravité dans $A$ deviennent non triviaux.

---

## `Parameters.m`

**Objectif** : centraliser les paramètres numériques et la convention d'axes.

Contenu : géométrie, positions du CG/CB, masses, inerties, coefficients d'amortissement, positions/directions des propulseurs, tolérances et chargement optionnel de `calcul_Q.mat`.

**Rôle pratique** : fournit les valeurs numériques pour substituer les expressions symboliques de `ABmatrice.mat` et obtenir `A_num`, `B_num`.

---

## `calcul_matrice_A_lineaire.m`

**Objectif** : spécialiser les matrices symboliques au point d'équilibre et produire les matrices numériques.

Étapes typiques :
1. Charger `ABmatrice.mat` (symbolique).
2. Exécuter `Parameters.m` pour définir les valeurs numériques et le point d'équilibre $(x_0, u_0)$.
3. Évaluer les jacobiennes : générer `A_num` et `B_num`.
4. Sauvegarder `Matrice_A_lineaire.mat` et éventuellement `K_LQR.mat`.

---

## `trouver_matrice_Q.m`

**Objectif** : construire une matrice de coût $Q$ guidée par la simulation.

Logique : analyser `info_simulation.mat` (amplitudes des états), fixer des tolérances admissibles et construire $Q$ diagonale selon

$$Q_{ii} = \frac{1}{(\Delta x_i)^2}$$

ou une variante pondérée ; sauvegarder `calcul_Q.mat`.

---

## `test_calculQ.m`

**Objectif** : banc de test pour valider $Q$ et $R$.

Actions : charger `ABmatrice.mat` et `calcul_Q.mat`, appeler `lqr(A_num, B_num, Q, R)` pour obtenir $K$, tracer la carte des pôles, et sauvegarder les diagnostics.

---

## `Graphique.m` et `mouvement.m`

- **`Graphique.m`** : post-traitement des résultats de simulation (`out`), tracés des positions, erreurs, entrées moteurs. Produit les images finales dans `docs/figures/`.
- **`mouvement.m`** : visualisation 3D/animation de la trajectoire (pédagogie et validation visuelle).

---

## `instabiliter_graphique.m`

Calcule les pôles instantanés (évolution des valeurs propres) à partir de linéarisations temporelles et trace leur évolution pour détecter les instabilités transitoires.

---

## Fichiers clés — producteurs et consommateurs

| Fichier | Produit par | Consommé par |
|---------|-------------|--------------|
| `ABmatrice.mat` | `Generate_PyMatrix.m` | `calcul_matrice_A_lineaire.m` |
| `Matrice_A_lineaire.mat` | `calcul_matrice_A_lineaire.m` | `test_calculQ.m`, Simulink |
| `calcul_Q.mat` | `trouver_matrice_Q.m` | `test_calculQ.m`, `calcul_matrice_A_lineaire.m` |
| `K_LQR.mat` | `calcul_matrice_A_lineaire.m` / `test_calculQ.m` | Simulink |
| `info_simulation.mat` | Simulink / simulation | `trouver_matrice_Q.m`, `Graphique.m` |
| `resultats_stabilite.mat` | `instabiliter_graphique.m` | `Graphique.m` |

---

<div class="page-nav">
  <a href="{{ '/theorie' | relative_url }}">← Théorie</a>
  <a href="{{ '/annexes' | relative_url }}">Annexes →</a>
</div>
