# Scripts Validation

Scripts de verification pour confirmer la coherence de Q/R/K et du modele lineaire.

## Fichiers

- `test_calculQ.m` : test de calcul LQR et inspection des poles.
- `test_calcalV2.m` : scenario de reference pour l'ajustement de Q.

## Entrees

- `data/generated/ABmatrice.mat`
- `data/generated/calcul_Q.mat`

## Usage

Utiliser ces scripts apres la generation des matrices et avant de figer les gains dans un scenario de simulation.
