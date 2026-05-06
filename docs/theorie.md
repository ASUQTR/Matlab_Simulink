---
layout: default
title: "Théorie — Modèle d'état et LQR"
---

# Théorie — Modèle d'état et LQR (niveau approfondi)

Cette page explicite formellement le cadre mathématique utilisé dans le dépôt et fournit les outils conceptuels pour comprendre pourquoi et comment le LQR agit sur le système.

---

## 1) Modèle d'état (définition)

Un modèle d'état linéaire invariant dans le temps (LTI) s'écrit :

$$
\dot{x}(t) = A\,x(t) + B\,u(t), \\
y(t) = C\,x(t) + D\,u(t),
$$

où
- \\(x(t)\in\mathbb{R}^n\\) est le vecteur d'état,
- \\(u(t)\in\mathbb{R}^m\\) est le vecteur de commande,
- \\(y(t)\in\mathbb{R}^p\\) est le vecteur de sorties mesurées,
- \\(A\in\mathbb{R}^{n\times n},\;B\in\mathbb{R}^{n\times m},\;C\in\mathbb{R}^{p\times n},\;D\in\mathbb{R}^{p\times m}\\).

Interprétation :
- \\(A\\) décrit la dynamique interne (auto-dérive, couplages entre états).
- \\(B\\) indique comment chaque entrée agit sur chaque état.
- \\(C\\) décrit quelles combinaisons d'états sont mesurées.

Pour un modèle non-linéaire \\(\dot{x}=f(x,u)\\), la linéarisation autour d'un point d'équilibre \\((x_0,u_0)\\) fournit

$$
\delta\dot{x} = A\,\delta x + B\,\delta u,
$$

avec \\(A=\left.\dfrac{\partial f}{\partial x}\right\|_{(x_0,u_0)}\\) et \\(B=\left.\dfrac{\partial f}{\partial u}\right\|_{(x_0,u_0)}\\).

---

## 2) Stabilité et valeurs propres

Les valeurs propres de \\(A\\) (ou de \\(A-BK\\) en boucle fermée) gouvernent la stabilité locale :
- \\(\mathrm{Re}(\lambda) < 0\\) → modes exponentiellement décroissants (stabilité asymptotique).
- \\(\mathrm{Re}(\lambda) > 0\\) → instabilité.

La position des pôles donne aussi la fréquence naturelle et l'amortissement de chaque mode.

---

## 3) Contrôlabilité & Observabilité

**Critère de Kalman (contrôlabilité)** : la matrice de contrôlabilité

$$
\mathcal{C} = \begin{bmatrix}B & AB & A^2B & \dots & A^{n-1}B\end{bmatrix}
$$

doit avoir rang \\(n\\) pour que le système soit entièrement contrôlable.

**Observabilité** (critère similaire) :

$$
\mathcal{O} = \begin{bmatrix}C \\ CA \\ CA^2 \\ \vdots \\ CA^{n-1}\end{bmatrix}
$$

doit avoir rang \\(n\\) pour que l'état soit déterminable à partir des sorties.

Si le système est **stabilisable** (toutes les parties non contrôlables sont stables) et **détectable** (similaire pour l'observabilité), alors le LQR et le filtre de Kalman possèdent des garanties théoriques.

---

## 4) Lien avec la fonction de transfert

La fonction de transfert s'obtient par

$$
G(s) = C(sI - A)^{-1}B + D.
$$

Ceci relie l'analyse fréquentielle (Bode, Nyquist) à l'analyse d'état (pôles et zéros).

---

## 5) LQR — formulation et équation de Riccati

**Problème standard (continu)** : minimiser

$$
J = \int_0^{\infty} \bigl(x^T Q\, x + u^T R\, u\bigr)\,dt
$$

sous la dynamique linéaire ci-dessus, avec \\(Q = Q^T \succeq 0\\) et \\(R = R^T \succ 0\\).

La condition optimale se traduit par l'**équation algébrique de Riccati** (CARE) :

$$
A^T P + P A - P B R^{-1} B^T P + Q = 0,
$$

où \\(P = P^T \succeq 0\\). Le gain en retour d'état optimal est

$$
K = R^{-1} B^T P.
$$

**Propriétés importantes :**
- Si \\((A,B)\\) est stabilisable et \\((A,Q^{1/2})\\) est détectable, alors il existe une unique solution \\(P \succeq 0\\) menant à \\(A - BK\\) stable.
- \\(P\\) mesure la « valeur » quadratique associée au coût futur : grandes composantes de \\(P\\) ↦ états coûteux.

---

## 6) Choix pratique de \\(Q\\) et \\(R\\) (règles, unités)

- Toujours tenir compte des **unités** : si \\(x_i\\) est en mètres, alors \\(Q_{ii}\\) a l'unité \\(\mathrm{m}^{-2}\\) pour que \\(x^T Q x\\) soit sans dimension.
- **Normalisation recommandée** : pour chaque état \\(x_i\\), choisir

$$
Q_{ii} = \frac{1}{(\Delta x_i)^2},
$$

où \\(\Delta x_i\\) est l'amplitude admissible (tolérance) sur cet état.

- Pour \\(R\\), normaliser par la commande maximale :

$$
R_{jj} = \frac{1}{(u_{j,\max})^2},
$$

de sorte qu'une commande saturée coûte environ 1.

- Pour **privilégier certains états**, multiplier les \\(Q_{ii}\\) correspondants par un facteur d'importance.

**Exemple illustratif** : pour un état position avec tolérance \\(\Delta p = 0.5\,\mathrm{m}\\),

$$
Q_{\text{pos}} = \frac{1}{(0.5)^2} = 4.
$$

---

## 7) Procédure pratique de réglage

1. Linéariser au point d'opération choisi et extraire \\(A, B\\).
2. Normaliser états et commandes ; construire \\(Q\\) et \\(R\\) diagonales initiales.
3. Résoudre la CARE, obtenir \\(K\\) et analyser les pôles de \\(A - BK\\).
4. Simuler réponse indicielle, trajectoire 3D et efforts moteurs.
5. Ajuster \\(Q\\) et \\(R\\) (balayage paramétrique) et tracer le lieu des pôles pour étudier la sensibilité.

---

## 8) Exemples illustratifs (petite dimension)

**Double intégrateur 1D** (position \\(p\\), vitesse \\(v\\)) avec amortissement approximatif :

$$
x = \begin{bmatrix}p \\ v\end{bmatrix},
\quad
A = \begin{bmatrix}0 & 1 \\ 0 & -\zeta\end{bmatrix},
\quad
B = \begin{bmatrix}0 \\ 1/m\end{bmatrix}.
$$

Choix typique : \\(Q = \operatorname{diag}(1/\Delta p^2,\; 1/\Delta v^2)\\), \\(R = 1/u_{\max}^2\\).

En dimension réelle (12 états du sous-marin) la logique est identique : penser par blocs (pose vs vitesse angulaire vs vitesses linéaires) et normaliser chaque composante.

---

## 9) Robustesse et limites

- Le LQR est optimal pour le **modèle linéaire** et un critère quadratique ; si la non-linéarité est importante, vérifier la validité locale et comparer plusieurs points de linéarisation.
- La **saturation des actionneurs** n'est pas gérée explicitement par le LQR : surveiller les efforts moteurs et ajouter des anti-windup ou contraintes si besoin.
- Tester la **sensibilité** aux erreurs de masse/inertie et aux incertitudes hydrodynamiques.

---

<div class="page-nav">
  <a href="{{ '/overview' | relative_url }}">← Vue d'ensemble</a>
  <a href="{{ '/pipeline-scripts' | relative_url }}">Pipeline MATLAB →</a>
</div>
