---
layout: default
title: "Vue d'ensemble"
---

# Vue d'ensemble

Ce dépôt rassemble le modèle mathématique, la génération des matrices d'état, le calcul du retour LQR et les scripts de validation/visualisation utilisés autour des modèles Simulink du mini-sous-marin AUV.

Le contenu des fichiers `.slx` (modèles Simulink) n'est pas détaillé ici ; cette documentation se concentre sur le pipeline MATLAB qui alimente la simulation et l'analyse.

---

## Points à retenir

- **`Parameters.m`** et **`Generate_PyMatrix.m`** portent le cœur de la modélisation : paramètres physiques et construction symbolique des matrices d'état.
- **`calcul_matrice_A_lineaire.m`** transforme le modèle symbolique en matrices numériques exploitables pour le contrôle (linéarisation au point d'équilibre).
- **`trouver_matrice_Q.m`** et **`test_calculQ.m`** servent à concevoir et valider la matrice de coût du LQR.
- Les scripts **`Graphique.m`**, **`mouvement.m`** et **`instabiliter_graphique.m`** sont des outils d'analyse et de présentation des résultats.
- Les fichiers **`.slx`** complètent la chaîne de simulation, mais la logique se trouve dans les scripts MATLAB.

---

## Structure des fichiers clés

| Fichier | Rôle |
|---------|------|
| `Parameters.m` | Paramètres numériques (masse, inertie, hydrodynamique, propulseurs) |
| `Generate_PyMatrix.m` | Modélisation symbolique non-linéaire et calcul des jacobiennes A, B |
| `calcul_matrice_A_lineaire.m` | Linéarisation numérique, calcul du gain LQR K |
| `trouver_matrice_Q.m` | Construction de la matrice de coût Q guidée par simulation |
| `test_calculQ.m` | Banc de test pour valider Q, R et K |
| `Graphique.m` | Post-traitement et tracés des résultats de simulation |
| `mouvement.m` | Visualisation 3D / animation de trajectoire |
| `instabiliter_graphique.m` | Évolution des valeurs propres et détection d'instabilités |

---

## Flux de données résumé

```
Parameters.m ──► Generate_PyMatrix.m ──► ABmatrice.mat (symbolique)
                                              │
                                              ▼
                              calcul_matrice_A_lineaire.m ──► Matrice_A_lineaire.mat
                                                         └──► K_LQR.mat
                                                                   │
                              trouver_matrice_Q.m ──► calcul_Q.mat ┘
                                                                   ▼
                                                         Simulink (.slx)
                                                                   │
                                                                   ▼
                                              Graphique.m / instabiliter_graphique.m
```

Pour le diagramme interactif complet, voir la page [Pipeline MATLAB](pipeline-scripts).

---

<div class="page-nav">
  <a href="{{ '/' | relative_url }}">← Accueil</a>
  <a href="{{ '/theorie' | relative_url }}">Théorie →</a>
</div>
