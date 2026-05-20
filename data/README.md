# Data

Ce dossier regroupe tous les fichiers `.mat` et artefacts de simulation.

## Sous-dossiers

- `generated/` : artefacts recalculables produits par les scripts (`ABmatrice.mat`, `calcul_Q.mat`, etc.). Gitignore — ne pas committer.
- `formes/` : jeux de donnees de trajectoires/scenarios utilises par Simulink.
- `runtime/` : sorties de simulation automatiquement sauvegardees par `runWorkflow` (`info_simulation.mat` + historique). Gitignore.
- `experiments/` : variantes de tuning et essais de reglage versionnees (ex: alternatives Q, essais K). A committer quand un reglage merite d'etre conserve.

## Regles

- Ne pas modifier manuellement `generated/` sauf cas exceptionnel (recalculable via pipeline).
- Les essais de reglage intentionnels vont dans `experiments/`, pas dans `generated/`.
- Documenter toute nouvelle dependance `.mat` du modele dans ce README.
- Conserver des noms explicites pour les jeux de donnees dans `formes/`.
