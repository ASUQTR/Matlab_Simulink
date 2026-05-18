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
| [Glossaire](glossaire) | Vocabulaire essentiel MATLAB/Simulink pour nouveaux arrivants |
| [Annexes](annexes) | Stockage des figures, références et ressources complémentaires |

---

## Démarrage rapide

1. Cloner le dépôt et ouvrir MATLAB.
2. Ouvrir le projet MATLAB (`ASUQTR_Control.prj`) si disponible.
3. Exécuter `projectStartup.m` (ou utiliser le startup du projet).
4. Lancer `runWorkflow.m` pour exécuter simulation + post-traitement.
5. Pour un mode pas-a-pas, utiliser les scripts dans `scripts/modeling/`, puis simuler le modèle, puis lancer `scripts/analysis/`.

Pour les détails mathématiques, consulter la page [Théorie](theorie).  
Pour comprendre chaque script, consulter la page [Pipeline MATLAB](pipeline-scripts).
