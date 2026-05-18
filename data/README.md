# Data

Ce dossier regroupe tous les fichiers `.mat` et artefacts de simulation.

## Sous-dossiers

- `generated/` : artefacts produits par les scripts (`ABmatrice.mat`, `calcul_Q.mat`, etc.).
- `formes/` : jeux de donnees utilises par Simulink pour les trajectoires/scenarios.
- `runtime/` : donnees runtime produites pendant les campagnes de simulation (`info_simulation.mat`).

## Regles

- Ne pas modifier manuellement les fichiers de `generated/` sauf cas exceptionnel.
- Documenter ici toute nouvelle dependance `.mat` du modele.
- Conserver des noms explicites pour les jeux de donnees dans `formes/`.
