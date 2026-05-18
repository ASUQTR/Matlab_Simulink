# Scripts Analysis

Scripts d'analyse des resultats Simulink.

## Fichiers

- `Graphique.m` : graphiques de position/consignes et signaux de commande.
- `mouvement.m` : visualisation 3D de la trajectoire.
- `instabiliter_graphique.m` : evolution des poles en boucle fermee.
- `report_instabilities.m` : resume des instants instables (indices/temps).
- `setax.m` : helper appele par le bloc MATLAB Function du modele.

## Entree attendue

- Variable `out` de type `Simulink.SimulationOutput` en workspace.

## Astuce

`runWorkflow.m` injecte automatiquement `out` et peut aussi sauvegarder les figures dans `docs/figures/`.
