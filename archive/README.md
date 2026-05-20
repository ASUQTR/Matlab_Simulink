# Archive

Ce dossier contient l'historique technique organise par type.

## Structure

- `models/` : anciennes versions de modeles Simulink (`.slx`, variantes `.r2019b`, `.r2020b`, etc.).
- `scripts/` : anciens scripts MATLAB non utilises dans le pipeline principal.

## Regle

Aucun element de ce dossier ne doit etre une dependance obligatoire du pipeline courant
(regle : si `runWorkflow` en a besoin, ce n'est pas une archive).

## Ajouter a l'archive

Deplacer le fichier avec `git mv` pour conserver l'historique :

```bash
git mv ancien_script.m archive/scripts/ancien_script.m
```
