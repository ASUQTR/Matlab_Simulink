# Data/Experiments — Variantes de tuning

Ce dossier contient les essais de reglage intentionnels qui meritent d'etre versionnes.

Contrairement a `generated/` (artefacts recalculables, gitignore), les fichiers ici sont commites car ils representent des choix de conception explicites.

## Contenu

| Fichier | Description |
|---------|-------------|
| `Q_test1.mat` | Premier essai de matrice Q |
| `calcul_Q_possible1.mat` | Variante Q — option 1 |
| `calcul_Q_possible2.mat` | Variante Q — option 2 |
| `calcul_Q_possible3.mat` | Variante Q — option 3 |

## Convention

- Nommer les fichiers de facon descriptive (ex: `Q_agressif_pitch.mat`, pas `Q_test7.mat`).
- Documenter dans ce tableau la difference par rapport a `data/generated/calcul_Q.mat`.
- Si un essai devient le reglage de reference, le copier via `scripts/modeling/trouver_matrice_Q.m` et le regenerer dans `generated/`.
