# Tools

Ce dossier contient des utilitaires ponctuels, pas le pipeline de simulation.

## Contenu

- `create_matlab_project.m` : aide a creer et initialiser le projet MATLAB.
- `check_project_structure.m` : verifie que l'arborescence MATLAB/Simulink attendue est presente.

## Verification rapide

Depuis la racine du depot:

```matlab
projectStartup
report = check_project_structure();
```

## Regle

- Les scripts de simulation doivent rester dans `runWorkflow.m`, `projectStartup.m` et les dossiers `model/` / `scripts/`.
- Les utilitaires one-shot vont ici pour eviter de surcharger la racine du depot.
