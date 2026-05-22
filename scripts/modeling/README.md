# Scripts Modeling

Scripts de construction du modele symbolique. Ces scripts sont des **outils de re-generation**
— ils produisent les artefacts dans `data/generated/` qui sont ensuite utilises par
`compute_controller()`. En usage normal, il n'est pas necessaire de les re-executer.

## Fichiers

| Fichier | Statut | Role |
|---------|--------|------|
| `Generate_PyMatrix.m` | **Actif** | Construit les matrices symboliques A/B, exporte `data/generated/ABmatrice.mat` |
| `calcul_matrice_A_lineaire.m` | **LEGACY** | Derivation manuelle de A numerique au point fixe — remplace par `compute_controller()` |
| `trouver_matrice_Q.m` | **LEGACY** | Derivation manuelle de Q — remplace par le champ `cfg.Q` dans `lqr_*.m` |

> Les scripts LEGACY sont conserves pour reference et compatibilite. Ne pas les utiliser
> pour de nouveaux calculs — utiliser `compute_controller('variante')` a la place.

## Sorties principales

- `data/generated/ABmatrice.mat` — source de tout (A/B symboliques)
- `data/generated/Matrice_A_lineaire.mat` — legacy, encore charge pour compatibilite
- `data/generated/calcul_Q.mat` — legacy, encore charge pour compatibilite
