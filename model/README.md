# Model

Ce dossier contient le modele Simulink principal du projet.

## Contenu

- `Modele_LQR_6DOF.slx` : modele principal 6 DOF.
- `callbacks/` : scripts executes automatiquement pour initialiser la simulation.

## Flux attendu

1. Le projet charge les chemins (`projectStartup.m`).
2. Les callbacks du modele chargent les parametres (`callbacks/Parameters.m`).
3. Le modele consomme les artefacts de `data/generated/` et les donnees de `data/formes/`.

## Bonnes pratiques

- Ne pas versionner les autosaves (`*.autosave`) ou caches Simulink.
- Garder ce dossier reserve au modele et a ses callbacks.
- Toute logique de calcul doit rester dans `scripts/`.
