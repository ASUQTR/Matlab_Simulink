# Modelisation du controle du mini-sous-marin

Ce dépôt rassemble le modèle mathématique, la génération des matrices d'état, le calcul du retour LQR et les scripts de validation/visualisation utilisés autour des modèles Simulink.

Je ne détaille pas le contenu interne des fichiers `.slx`, mais ce README explique le pipeline MATLAB qui alimente la simulation et l'analyse.

## Vue d'ensemble


## Points a retenir

- `Parameters.m` et `Generate_PyMatrix.m` portent le coeur de la modélisation.
- `calcul_matrice_A_lineaire.m` transforme le modèle symbolique en base numérique exploitable pour le contrôle.
- `trouver_matrice_Q.m` et `test_calculQ.m` servent à concevoir et valider la matrice de coût du LQR.
- Les scripts `Graphique.m`, `mouvement.m` et `instabiliter_graphique.m` sont des outils d'analyse et de présentation des résultats.
- Les fichiers `.slx` complètent la chaîne de simulation, mais la logique se trouve dans les scripts MATLAB.

## Annexes — Formules et graphiques


### Où stocker les figures

Créez un dossier `docs/figures` et rangez-y les images finales (pas de code dans le README).

## Théorie — Modèle d'état et LQR (niveau approfondi)

Cette section explicite formellement le cadre mathématique utilisé dans le dépôt et donne les outils conceptuels pour comprendre pourquoi et comment le LQR agit sur le système.

### 1) Modèle d'état (définition)

Un modèle d'état linéaire invariant dans le temps (LTI) s'écrit :

$$
\dot{x}(t) = A\,x(t) + B\,u(t),\\
y(t) = C\,x(t) + D\,u(t),
$$

où
- $x(t)\in\mathbb{R}^n$ est le vecteur d'état,
- $u(t)\in\mathbb{R}^m$ est le vecteur de commande,
- $y(t)\in\mathbb{R}^p$ est le vecteur de sorties mesurées,
- $A\in\mathbb{R}^{n\times n},\;B\in\mathbb{R}^{n\times m},\;C\in\mathbb{R}^{p\times n},\;D\in\mathbb{R}^{p\times m}$.

Interpretation :
- $A$ décrit la dynamique interne (auto-dérive, couplages entre états).
- $B$ indique comment chaque entrée agit sur chaque état.
- $C$ décrit quelles combinaisons d'états sont mesurées.

Pour un modèle non-linéaire $\dot{x}=f(x,u)$, la linéarisation autour d'un point d'équilibre $(x_0,u_0)$ fournit

$$
\delta\dot{x} = A\,\delta x + B\,\delta u,
$$
avec $A=\left.\dfrac{\partial f}{\partial x}\right|_{(x_0,u_0)}$ et $B=\left.\dfrac{\partial f}{\partial u}\right|_{(x_0,u_0)}$.

### 2) Stabilité et valeurs propres

Les valeurs propres de $A$ (ou de $A-BK$ en boucle fermée) gouvernent la stabilité locale :
- Re(λ)<0 → modes exponentiellement décroissants (stabilité asympt.)
- Re(λ)>0 → instabilité.

La position des pôles donne aussi la fréquence naturelle et l'amortissement de chaque mode.

### 3) Contrôlabilité & Observabilité

Critère de Kalman (contrôlabilité) : la matrice de contrôlabilité

$$
\mathcal{C} = [B\;AB\;A^2B\;\dots\;A^{n-1}B]
$$
doit avoir rang $n$ pour que le système soit entièrement contrôlable.

Observabilité (similaire) :

$$
\mathcal{O} = \begin{bmatrix}C\\CA\\CA^2\\\vdots\\CA^{n-1}\end{bmatrix}
$$
doit avoir rang $n$ pour que l'état soit déterminable à partir des sorties.

Si le système est stabilisable (toutes les parties non contrôlables sont stables) et détectable (similaire pour l'observabilité), alors le LQR et le filtre de Kalman possèdent des garanties.

### 4) Lien avec la fonction de transfert

La fonction de transfert s'obtient par

$$
G(s)=C(sI-A)^{-1}B + D.
$$

Ceci relie l'analyse fréquentielle (Bode, Nyquist) à l'analyse d'état (pôles et zéros).

### 5) LQR — formulation et équation de Riccati

Problème standard (continu) : minimiser

$$
J = \int_0^{\infty} (x^T Q x + u^T R u)\,dt
$$
sous la dynamique linéaire ci-dessus, avec $Q=Q^T\succeq0$ et $R=R^T\succ0$.

La condition optimale se traduit par l'équation algébrique de Riccati (CARE) :

$$
A^T P + P A - P B R^{-1} B^T P + Q = 0,
$$
où $P=P^T\succeq0$. Le gain en retour d'état optimal est

$$
K = R^{-1} B^T P.
$$

Propriétés importantes :
- Si $(A,B)$ est stabilisable et $(A,Q^{1/2})$ est détectable, alors il existe une unique solution $P\succeq0$ menant à $A-BK$ stable.
- $P$ mesure la « valeur » quadratique associée au coût futur: grandes composantes de $P$ ↦ états coûteux.

### 6) Choix pratique de $Q$ et $R$ (règles, unités)

- Toujours tenir compte des unités : si $x_i$ est en mètres, alors $Q_{ii}$ a unité m^{-2} pour que $x^T Q x$ soit sans unité relative.
- Normalisation recommandée : pour chaque état $x_i$, choisir

	$$Q_{ii} = \frac{1}{(\Delta x_i)^2},$$

	où $\Delta x_i$ est l'amplitude admissible (tolérance) sur cet état.
- Pour $R$, normaliser par la commande maximale :

	$$R_{jj} = \frac{1}{(u_{j,\max})^2}$$

	de sorte qu'une commande saturée coûte environ 1.
- Si vous voulez privilégier certains états, multipliez les $Q_{ii}$ correspondants par un facteur d'importance.

Exemple simple (illustratif) : pour un état position avec tolérance 0.5 m → $Q_{pos}=1/(0.5)^2=4$.

### 7) Procédure pratique de réglage

1. Linéariser au point d'opération choisi et extraire $A,B$.
2. Normaliser états et commandes et construire $Q$ et $R$ diagonales initiales.
3. Résoudre la CARE, obtenir $K$ et analyser les pôles de $A-BK$.
4. Simuler réponse indicielle / trajec. 3D / efforts moteurs.
5. Ajuster $Q$ et $R$ (balayage paramétrique) et tracer le lieu des pôles pour étudier la sensibilité.

### 8) Exemples illustratifs (petite dimension pour intuition)

Double intégrateur 1D (position p, vitesse v) avec amortissement approximatif :

$$
x = \begin{bmatrix}p\\v\end{bmatrix},
\quad A=\begin{bmatrix}0 & 1\\0 & -\zeta\end{bmatrix},
\quad B=\begin{bmatrix}0\\1/m\end{bmatrix}.
$$

Choix typique : $Q=\operatorname{diag}(1/\Delta p^2, 1/\Delta v^2)$, $R=1/u_{\max}^2$.

En dimension réelle (12 états du sous-marin) la logique est identique : penser par blocs (pose vs vitesse angulaire vs vitesses linéaires) et normaliser chaque composante.

### 9) Robustesse et limites

- LQR est optimal pour le modèle linéaire et pour un critère quadratique ; si la non-linéarité est importante, vérifier la validité locale et comparer plusieurs points de linéarisation.
- La saturation des actionneurs n'est pas gérée explicitement par le LQR : surveiller les efforts moteurs et ajouter des anti-windup ou contraintes si besoin.
- Tester la sensibilité aux erreurs de masse/inertie et aux incertitudes hydrodynamiques.

## Comprendre les scripts MATLAB — rôle et détail de calcul

Ci-dessous une description précise de ce que fait chaque script principal et comment les matrices `A` et `B` sont effectivement construites et utilisées.

```mermaid
flowchart TD
	P[Parameters.m] --> GPM[Generate_PyMatrix.m]
	GPM --> AB[ABmatrice.mat\n(symbolic A,B)]
	AB --> CAL[calcul_matrice_A_lineaire.m]
	CAL --> ANUM[Matrice_A_lineaire.mat\n(A_num, B_num)]
	P --> CAL
	QF[trouver_matrice_Q.m] --> QMAT[calcul_Q.mat\n(Q_final)]
	QMAT --> CAL
	CAL --> K[K_LQR.mat\n(K)]
	K --> SIM[Simulink (.slx) / Simulation]
	SIM --> POST[Graphique.m / instabiliter_graphique.m]
	POST --> docs[docs/figures (images)]
```

### `Generate_PyMatrix.m`
- Objectif : formaliser le modèle non-linéaire symbolique et calculer les jacobiennes.
- Ce que fait le script :
	- définit symboliquement l'état \(x=[x,y,z,\phi,\theta,\psi,u,v,w,p,q,r]^T\) et les commandes (throttles des propulseurs);
	- construit la matrice d'inertie rigide `Mrb` et la masse ajoutée `Ma`, les matrices d'amortissement (linéaire/quad.), la matrice de Coriolis `C` et le terme gravité `G`;
	- assemble la dynamique non-linéaire sous la forme \(\dot x = f(x) + g(x)\,u\) (ou équivalent) ;
	- calcule symboliquement les Jacobiennes :
		- \(A(x_0,u_0)=\partial f/\partial x\big|_{(x_0,u_0)}\),
		- \(B(x_0,u_0)=\partial g/\partial u\big|_{(x_0,u_0)}\).
	- sauvegarde `ABmatrice.mat` (objets symboliques) et exporte `Matrix_centrer.txt` (version texte des matrices et vecteurs utiles).

> Remarque : `A` et `B` sont obtenues par différentiation symbolique des expressions de dynamique ; l'assemblage numérique intervient ensuite.

### Construction détaillée de `A` et `B` (pas-à-pas)

Voici le procédé exact suivi dans `Generate_PyMatrix.m`, avec les formules correspondant aux blocs de code :

1. Assemblage des termes d'inertie et d'hydrodynamique :
	- matrice d'inertie rigide : $M_{rb}$ (6×6) construite à partir de `mass`, `Ix,Iy,Iz,Ixy,...` ;
	- matrice de masse ajoutée : $M_a$ (6×6) issue des coefficients `Xu_dot,Yv_dot,...` ;
	- masse totale utilisée dans le calcul inertiel :

	  $$M = M_{rb} + M_a.$$

2. Coriolis et amortissement :
	- matrice de Coriolis $C$ calculée par la fonction `coriolisMatrix(M,state)` (dépend de $M$ et des composantes de vitesse).
	- terme d'amortissement $D$ = `linear_damping + quadratic_damping` (dépend des coefficients linéaires/quadratiques).

3. Terme gravité/flottabilité :
	- vecteur $G$ calculé par `gravityMatrix(state, mass, ...)` (poids vs poussée d'Archimède, dépend des angles d'Euler).

4. Partie cinématique :
	- la transformation de vitesses corps→NED est fournie par `J(state)` ; la partie supérieure de la dynamique non-linéaire utilise cette jacobienne de coordonnées.

5. Écriture de la dynamique non-linéaire :
	- on construit symboliquement

	  $$f_1 = \begin{bmatrix}0_{6\times6} & J(state) \\ 0_{6\times6} & -M^{-1}(C-D) \end{bmatrix},$$

	  $$f_2 = \begin{bmatrix}0_{6\times1} \\ -M^{-1} G \end{bmatrix},$$

	  puis la dynamique interne (sans commandes) est

	  $$f(x) = f_1(x)\,x + f_2(x).$$

6. Allocation des propulseurs et actionneurs → terme de commande :
	- `thrust_direction` et `thrust_position` définissent l'allocation ; `thrust_allocation` (6×8 transposé puis mis en forme) mappe les 8 propulseurs en forces et couples.
	- les entrées symboliques `du_i` sont transformées en forces `u_control(i)=du_i*abs(du_i)` (non-linéarité de la loi de commande) puis

	  $$\tau = T\,u_{control}$$

	  où $T$ est la matrice d'allocation (6×8) transposée dans le code.
	- le vecteur de commande dans l'équation d'état est ensuite

	  $$g(x,u) = M^{-1}\,\tau$$

	  affectant uniquement les équations de vitesse (les lignes 7..12 de l'état).

7. Construction symbolique de l'état dérivé :
	- `state_dot = f(x) + g(x,u)` (stocké symboliquement en `F_dot` puis `state_dot`).

8. Calcul des Jacobiennes (mise en forme exacte) :
	- la matrice d'état linéaire est

	  $$A(x_0,u_0) = \left.\frac{\partial\,state\_dot}{\partial x}\right|_{(x_0,u_0)},$$

	  calculée dans le code par `df_dstate = jacobian(state_dot,state); A = df_dstate;` puis sauvegardée.
	- la matrice de commande est

	  $$B(x_0,u_0) = \left.\frac{\partial\,state\_dot}{\partial u}\right|_{(x_0,u_0)},$$

	  calculée par `jacobian(state_dot,transpose(du))` (avec la manipulation des entrées `du*abs(du)` correctement différentiée par la différentiation symbolique).

9. Substitution numérique :
	- après construction symbolique, `Parameters.m` (et les assignations dans le fichier) fournit les valeurs numériques pour `mass`, inerties, coefficients de damping, positions/directions, etc.
	- l'évaluation numérique se fait via `subs`/`vpa` dans le code avant de sauver `A` et `B` dans `ABmatrice.mat`.

10. Export et vérification :
	- `Matrix_centrer.txt` est écrit avec la forme textuelle des éléments de `A` et `B` pour inspection.

Remarques pratiques et pièges à connaître :
- la dépendance non-linéaire des entrées via `du*abs(du)` rend $B$ dépendant du point d'équilibre (si `du_0=0` la dérivée peut être nulle ou indéterminée selon le formalisme) — choisir un point d'opération cohérent.
- les termes de Coriolis apparaissent dans les blocs 7:12 de $A$ via $-M^{-1}C$ et impliquent des produits d'états — ce sont eux qui créent les couplages gyroscopiques.
- si vous linéarisez autour d'un état en roulis/pitch non nul, attendez-vous à des termes de gravité et géométrie (matrice `G`) non triviaux dans $A$.


### `Parameters.m`
- Objectif : centraliser les paramètres numériques et la convention d'axes.
- Ce que contient : géométrie, positions du CG/CB, masses, inerties, coefficients d'amortissement, positions/directions des propulseurs, tolérances et parfois chargement de `calcul_Q.mat`.
- Rôle pratique : fournit les valeurs numériques utilisées pour substituer dans les expressions symboliques de `ABmatrice.mat` afin d'obtenir `A_num` et `B_num`.

### `calcul_matrice_A_lineaire.m`
- Objectif : spécialiser les matrices symboliques au point d'équilibre choisi et produire les matrices numériques exploitables.
- Étapes typiques du script :
	1. charger `ABmatrice.mat` (symbolique) ;
	2. exécuter / inclure `Parameters.m` pour définir les valeurs numériques et le point d'équilibre \((x_0,u_0)\) ;
	3. évaluer les jacobiennes en ce point : générer `A_num` et `B_num` (substitution des symboles par valeurs numériques) ;
	4. sauvegarder `Matrice_A_lineaire.mat` et éventuellement `K_LQR.mat` si le calcul LQR est lancé ici.

### `trouver_matrice_Q.m`
- Objectif : construire une matrice de coût `Q` guidée par la simulation.
- Logique : analyser `info_simulation.mat` (amplitudes des états), fixer des tolérances admissibles pour chaque état, et construire `Q` diagonale selon la règle
	\(Q_{ii}=1/(\Delta x_i)^2\) ou une variante pondérée ; sauvegarder `calcul_Q.mat`.

### `test_calculQ.m`
- Objectif : banc de test pour valider `Q` et `R`.
- Actions : charger `ABmatrice.mat` et `calcul_Q.mat`, spécialiser en numérique (ou charger `Matrice_A_lineaire.mat`), appeler `lqr(A_num,B_num,Q,R)` pour obtenir `K`, tracer la carte des pôles, et sauvegarder diagnostics.

### `Graphique.m` et `mouvement.m`
- `Graphique.m` : post-traitement des résultats de simulation (`out`), tracés des positions, erreurs, entrées moteurs, etc. Utilisé pour produire les images finales.
- `mouvement.m` : visualisation 3D/animation de la trajectoire (utile pour pédagogie et validation visuelle).

### `instabiliter_graphique.m`
- Calcule les pôles instantanés (ou l'évolution des valeurs propres) à partir de linéarisations temporelles et trace leur évolution pour détecter instabilités transitoires.

### Fichiers clés et qui les produit / consomme
- `ABmatrice.mat` : produit par `Generate_PyMatrix.m` (symbolique) ; consommé par `calcul_matrice_A_lineaire.m`.
- `Matrice_A_lineaire.mat` : produit par `calcul_matrice_A_lineaire.m` (A_num, B_num) ; consommé par `test_calculQ.m`, Simulink et routines d'analyse.
- `calcul_Q.mat` : produit par `trouver_matrice_Q.m` ; consommé par `test_calculQ.m`.
- `K_LQR.mat` : produit par le script qui calcule `K` (souvent `calcul_matrice_A_lineaire.m` ou `test_calculQ.m`).
- `info_simulation.mat`, `resultats_stabilite.mat` : sorties de simulations et analyses, consommées par `Graphique.m` et `instabiliter_graphique.m`.
