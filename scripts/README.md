# Scripts

Ce dossier contient le code MATLAB source du pipeline, organise par intention.

## Sous-dossiers

- `modeling/` : generation des matrices et calcul des artefacts de controle.
- `analysis/` : visualisation, post-traitement et diagnostics de stabilite.
- `validation/` : scripts de verification et essais de reglage.

## Execution recommandee

- Mode one-shot : `runWorkflow.m` a la racine.
- Mode pas-a-pas :
  1. scripts de `modeling/`
  2. simulation Simulink
  3. scripts de `analysis/`
  4. scripts de `validation/` selon besoin

## Convention

- Utiliser des chemins relatifs via `projectRoot` + `fullfile(...)`.
- Les fichiers `.mat` produits vont dans `data/generated/`.
- Les scripts ne doivent pas dependre de chemins absolus machine.
