---
layout: default
title: "Documentation — Mini-sous-marin MATLAB/Simulink"
---

# Modélisation du contrôle du mini-sous-marin

Ce site rassemble la documentation complète du pipeline MATLAB/Simulink utilisé pour modéliser, contrôler et valider le mini-sous-marin AUV développé à l'ASUQTR.

> **Code source** : [ASUQTR/Matlab\_Simulink](https://github.com/ASUQTR/Matlab_Simulink)

---

## Pages de documentation

| Page | Contenu |
|------|---------|
| [Vue d'ensemble](overview) | Présentation générale et points clés du dépôt |
| [Théorie — Modèle d'état & LQR](theorie) | Cadre mathématique complet : espace d'état, stabilité, contrôlabilité, Riccati, réglage |
| [Pipeline MATLAB & scripts](pipeline-scripts) | Rôle de chaque script, flux de données et détail du calcul de A et B |
| [Annexes](annexes) | Stockage des figures, références et ressources complémentaires |

---

## Démarrage rapide

1. Cloner le dépôt et ouvrir MATLAB.
2. Exécuter `Parameters.m` pour charger les paramètres du sous-marin.
3. Exécuter `Generate_PyMatrix.m` pour générer les matrices symboliques `A` et `B` → `ABmatrice.mat`.
4. Exécuter `calcul_matrice_A_lineaire.m` pour obtenir les matrices numériques et le gain LQR `K`.
5. Lancer la simulation Simulink (`.slx`) qui utilise `K`.
6. Utiliser `Graphique.m` et `instabiliter_graphique.m` pour visualiser les résultats.

Pour les détails mathématiques, consulter la page [Théorie](theorie).  
Pour comprendre chaque script, consulter la page [Pipeline MATLAB](pipeline-scripts).
