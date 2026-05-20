# Project Map (quoi va ou)

Ce document fige la structure officielle du projet pour eviter toute ambiguite.

## 1) Fichiers attendus a la racine

Racine minimale recommandee:

- `README.md` : entree principale
- `ONBOARDING.md` : guide 1ere prise en main
- `PROJECT_MAP.md` : ce document (structure et roles)
- `projectStartup.m` : initialisation path/projet
- `runWorkflow.m` : execution one-shot simulation + analyses
- `startup.m` : fallback MATLAB startup
- `ASUQTR_Control.prj` : projet MATLAB partage
- `.gitignore`, `.gitattributes`
- Dossiers: `model/`, `scripts/`, `data/`, `docs/`, `archive/`, `resources/`, `tests/`

`PROJECT_SETUP.md` a ete deplace dans `docs/PROJECT_SETUP.md`.

Tout le reste a la racine est considere comme bruit (cache/artefact) et doit etre deplace ou ignore.

## 1.1) Quel fichier sert a quoi

| Fichier | Quand l'utiliser | Role |
|---|---|---|
| `ASUQTR_Control.prj` | A chaque session — **ouvrir ceci en premier** | Configure les chemins et lance `tools/projectStartup.m` via Task Automation |
| `runWorkflow.m` | A chaque nouvelle simulation | Lance la simulation puis les figures, exports et rapports |
| `tools/projectStartup.m` | Appele automatiquement par le projet a l'ouverture | Initialise les chemins et verifie les fichiers requis — ne pas appeler manuellement |
| `tools/create_matlab_project.m` | Une seule fois, pour creation/initialisation du projet | Aide a creer le `.prj` quand l'API MATLAB est disponible |
| `scripts/config/params_nominal.m` | Calibration active — changer dans `Parameters.m` | Parametres physiques du sous-marin (masse, inertie, actionneurs) |
| `scripts/config/scenario_default.m` | Passe a `runWorkflow(cfg)` pour personaliser un run | Options de simulation : duree, figures, exports — sans lien avec la physique |

## 2) Actif vs Archive

### Actif (utilise par le pipeline courant)

- Modele principal: `model/Modele_LQR_6DOF.slx`
- Initialisation modele: `model/callbacks/Parameters.m`
- Generation modeles/artefacts: `scripts/modeling/*.m`
- Validation reglage: `scripts/validation/*.m`
- Post-traitement: `scripts/analysis/*.m`
- Presets de simulation: `scripts/config/scenario_default.m` (et variantes)
- Tests formels: `tests/unit/`, `tests/integration/`
- Donnees de simulation:
  - `data/formes/` (scenarios/trajectoires)
  - `data/runtime/` (sorties runtime — gitignore)
  - `data/generated/` (artefacts recalculables — gitignore)
  - `data/experiments/` (variantes de tuning versionnees)

### Archive (historique)

- `archive/models/` : variantes anciennes modeles `.slx` (3DOF, r2019b, r2020b)
- `archive/scripts/` : anciens scripts de test non utilises par le flux principal

Regle: si un fichier est requis pour executer `runWorkflow`, il n'est pas en archive.

## 3) Ordre officiel de simulation

## Mode recommande (one-shot)

```matlab
projectStartup
simOut = runWorkflow(struct( ...
    'runParameters', true, ...
    'runGraphique', true, ...
    'runMouvement', false, ...
    'runStability', true, ...
    'reportInstability', true, ...
    'saveFigures', true));
```

Regle pratique: pour une nouvelle simulation courante, on utilise `runWorkflow`. `projectStartup` sert a preparer l'environnement; `startup.m` ne sert que comme secours hors projet.

## Mode pas-a-pas (debug)

1. `projectStartup`
2. `run('model/callbacks/Parameters.m')`
3. Simuler `model/Modele_LQR_6DOF.slx`
4. `out = simOut;`
5. `run('scripts/analysis/Graphique.m')`
6. `run('scripts/analysis/mouvement.m')`
7. `run('scripts/analysis/instabiliter_graphique.m')`
8. `report_instabilities(out)`

## 4) Setup 1ere fois (nouvel arrivant)

1. Ouvrir MATLAB dans la racine du repo.
2. Ouvrir `ASUQTR_Control.prj` (si compatible version).
3. Verifier dans Project Settings:
   - Search Path: `scripts/`, `data/formes/`, `data/generated/`
   - Task Automation Startup: `projectStartup.m`
   - Simulink cache: `sim_cache/`
   - Code generation folder: `codegen/`
4. Lancer le smoke test avec `runWorkflow`.

## 5) Interpreting git status pendant la reorganisation

Pendant un refactor avec deplacements, `git status` peut afficher beaucoup de:

- `D ancien_fichier` (supprime a l'ancien emplacement)
- `?? nouveau_dossier/fichier` (nouvel emplacement non stage)

C'est normal tant que les moves n'ont pas encore ete stages/commit.
