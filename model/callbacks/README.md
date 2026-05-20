# Model Callbacks

Scripts executes automatiquement par Simulink a l'ouverture du modele.

## Contenu

- `Parameters.m` : charge la calibration physique active et exporte les variables au workspace Simulink.

## Ce que fait Parameters.m

1. Appelle la calibration active (ex: `params_nominal()` dans `scripts/config/`)
2. Charge les matrices LQR depuis `data/generated/` (calcul_Q.mat, Matrice_A_lineaire.mat)
3. Exporte toutes les variables au base workspace pour que les blocs Simulink y aient acces

**Changer de calibration** : modifier la ligne `p = params_nominal()` dans `Parameters.m`.
Les options disponibles sont dans `scripts/config/params_*.m`.

## Dependances

- `scripts/config/params_*.m` — calibration physique active
- `data/generated/calcul_Q.mat` — matrice Q du LQR
- `data/generated/Matrice_A_lineaire.mat` — matrice A numerique
- `data/formes/sous marin en pentagone.mat` — trajectoire de reference

## Regle

Si vous ajoutez une nouvelle dependance au demarrage du modele, documentez-la ici et dans `data/README.md`.
