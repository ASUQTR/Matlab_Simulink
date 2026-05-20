---
layout: default
title: "Annexes"
---

# Annexes

---

## Stockage des figures

Les figures générées par `Graphique.m`, `mouvement.m` et `instabiliter_graphique.m` doivent être placées dans le dossier `docs/figures/`.

**Convention recommandée :**
- Ne pas intégrer de code source ou de données binaires dans les pages de documentation.
- Nommer les fichiers de façon explicite (ex. : `poles_lqr_Q1.png`, `trajectoire_3d.png`).
- Pour intégrer une figure dans une page de documentation :

```markdown
![Description de la figure](figures/nom_du_fichier.png)
```

---

## Ressources et références

### Contrôle optimal et LQR
- Anderson, B. D. O. & Moore, J. B. — *Optimal Control: Linear Quadratic Methods* (Prentice Hall, 1990)
- Brogan, W. L. — *Modern Control Theory* (3e éd., Prentice Hall, 1991)

### Modélisation des véhicules sous-marins
- Fossen, T. I. — *Handbook of Marine Craft Hydrodynamics and Motion Control* (Wiley, 2011)
- Fossen, T. I. — *Marine Control Systems* (Marine Cybernetics, 2002)

### MATLAB / Simulink
- Documentation officielle `lqr` : [MathWorks — lqr](https://www.mathworks.com/help/control/ref/lqr.html)
- Documentation `jacobian` symbolique : [MathWorks — jacobian](https://www.mathworks.com/help/symbolic/sym.jacobian.html)

---

## Activation de GitHub Pages

Pour publier ce site :
1. Aller sur `ASUQTR/Matlab_Simulink` → **Settings → Pages**.
2. Source : « Deploy from a branch ».
3. Branch : `Lewis_Cleaning` / Dossier : `/docs`.
4. Cliquer **Save**.

Le site sera accessible à l'adresse :
`https://asuqtr.github.io/Matlab_Simulink/`

---

<div class="page-nav">
  <a href="{{ '/pipeline-scripts' | relative_url }}">← Pipeline MATLAB</a>
  <a href="{{ '/' | relative_url }}">Accueil →</a>
</div>
