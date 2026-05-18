# Scripts Modeling

Scripts de construction du modele et des matrices de controle.

## Fichiers

- `Generate_PyMatrix.m` : construit les matrices symboliques A/B et exporte `ABmatrice.mat`.
- `trouver_matrice_Q.m` : construit/ajuste la matrice Q a partir des donnees de simulation.
- `calcul_matrice_A_lineaire.m` : specialise le modele, calcule la version lineaire exploitable et met a jour les artefacts associes.

## Entrees principales

- `data/runtime/info_simulation.mat` (si utilise par le script Q)
- Parametres de `model/callbacks/Parameters.m`

## Sorties principales

- `data/generated/ABmatrice.mat`
- `data/generated/calcul_Q.mat`
- `data/generated/Matrice_A_lineaire.mat`
