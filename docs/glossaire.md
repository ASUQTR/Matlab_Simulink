---
layout: default
title: "Glossaire"
---

# Glossaire MATLAB/Simulink (sous-marin)

Ce glossaire est destine aux personnes qui decouvrent le projet.

## Concepts controle

- **Etat**: vecteur des variables dynamiques du systeme (position, orientation, vitesses).
- **A (matrice d'etat)**: linearisation de la dynamique par rapport a l'etat.
- **B (matrice d'entree)**: linearisation de la dynamique par rapport aux commandes.
- **Q**: matrice de poids des erreurs d'etat (plus grand = etat plus penalise).
- **R**: matrice de poids de l'effort de commande (plus grand = commandes plus douces).
- **LQR**: methode de synthese d'un retour d'etat optimal (au sens quadratique).
- **K**: gain de retour d'etat tel que `u = -Kx` (selon la convention du modele).
- **Poles (valeurs propres)**: indicateurs de stabilite locale de la dynamique bouclee.

## Concepts simulation

- **`out`**: objet `Simulink.SimulationOutput` produit par `sim(...)`.
- **`tout`**: vecteur temps de simulation.
- **Instabilite locale**: instant ou au moins un pole a une partie reelle strictement positive.
- **Smoke test**: execution courte pour verifier que le pipeline tourne sans erreur bloquante.

## Dossiers du projet

- **`model/`**: modeles Simulink et callbacks.
- **`scripts/modeling/`**: generation de matrices et calculs de controle.
- **`scripts/analysis/`**: post-traitement, figures et diagnostic de stabilite.
- **`scripts/validation/`**: scripts de verification et essais de reglage.
- **`data/generated/`**: artefacts `.mat` generes par les scripts.
- **`data/formes/`**: fichiers de scenario/trajectoire utilises par Simulink.
- **`data/runtime/`**: sorties runtime utiles pour analyses ulterieures.

## Fichiers centraux

- **`projectStartup.m`**: initialise les chemins MATLAB du projet.
- **`runWorkflow.m`**: lance le pipeline complet (simulation + analyses).
- **`model/callbacks/Parameters.m`**: initialise parametres et chargements pour le modele.
