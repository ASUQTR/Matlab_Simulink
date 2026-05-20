# Tools

Utilitaires ponctuels et scripts d'infrastructure. Pas le pipeline de simulation.

## Contenu

| Fichier | Role |
|---------|------|
| `projectStartup.m` | Configure les chemins MATLAB au demarrage du projet. Appele automatiquement par Task Automation — ne pas appeler manuellement. |
| `check_project_structure.m` | Verifie que l'arborescence attendue est presente (non-destructif). |
| `create_matlab_project.m` | Aide a creer/reinitialiser le `.prj` MATLAB. |

## Verification rapide

```matlab
check_project_structure()
```

## Task Automation — configuration requise

Pour que `projectStartup.m` s'execute automatiquement a l'ouverture du projet :

**Project Settings → Task Automation → Startup files → Add → `tools/projectStartup.m`**

Sans ca, les chemins MATLAB ne sont pas configures et `runWorkflow` echouera.
