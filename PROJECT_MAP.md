# Project Map (quoi va ou)

Ce document fige la structure officielle du projet pour eviter toute ambiguite.

## 1) Fichiers attendus a la racine

Racine minimale recommandee:

- `README.md` : entree principale
- `ONBOARDING.md` : guide 1ere prise en main
- `PROJECT_MAP.md` : ce document (structure et roles)
- `TODO.md` : travaux en suspens
- `runWorkflow.m` : execution simulation + analyses
- `startup.m` : fallback MATLAB startup
- `ASUQTR_Control.prj` : projet MATLAB partage
- `.gitignore`, `.gitattributes`
- Dossiers: `model/`, `scripts/`, `data/`, `docs/`, `archive/`, `resources/`, `tests/`, `tools/`

`PROJECT_SETUP.md` a ete deplace dans `docs/PROJECT_SETUP.md`.
`projectStartup.m` est dans `tools/projectStartup.m` (appele via Task Automation).

Tout le reste a la racine est considere comme bruit (cache/artefact) et doit etre deplace ou ignore.

## 1.1) Quel fichier sert a quoi

| Fichier | Quand l'utiliser | Role |
|---|---|---|
| `ASUQTR_Control.prj` | A chaque session — **ouvrir ceci en premier** | Configure les chemins et lance `tools/projectStartup.m` via Task Automation |
| `tools/config_selector.m` | **Point d'entree principal** apres ouverture du projet | GUI : choisir trajectoire, calibration, controleur LQR et lancer la simulation |
| `tools/controller_selector.m` | Ouvert depuis `config_selector` | GUI : selectionner la variante LQR (`lqr_*.m`) |
| `tools/compute_controller.m` | Appele par `controller_selector` | Calcule Q_final et K selon la methode, exporte `controller_<variant>.mat` |
| `tools/save_last_simulation.m` | Apres chaque simulation a conserver | Sauvegarde manuelle dans `data/runtime/history/` |
| `tools/replay_simulation.m` | Pour rejouer une simulation precedente | Recharge un `.mat` d'historique et relance les analyses |
| `runWorkflow.m` | Appele par `config_selector` ou directement | Lance la simulation puis les figures, exports et rapports |
| `tools/projectStartup.m` | Appele automatiquement par le projet a l'ouverture | Initialise les chemins et les variables workspace — ne pas appeler manuellement |
| `tools/set_config.m` | Pour changer de calibration physique | Met a jour `model/AUV_Params.sldd` |
| `tools/create_matlab_project.m` | Une seule fois, pour creation/initialisation du projet | Aide a creer le `.prj` quand l'API MATLAB est disponible |
| `scripts/config/params_nominal.m` | Source de verite calibration — lire, pas modifier directement | Parametres physiques du sous-marin (masse, inertie, actionneurs) |
| `scripts/config/lqr/lqr_nominal.m` | Source de verite controleur — lire, pas modifier directement | Config gain scheduling (methode active) |
| `scripts/config/scenario_default.m` | Passe a `runWorkflow(cfg)` pour personaliser un run | Options de simulation : duree, figures, exports — sans lien avec la physique |

## 2) Actif vs Archive

### Actif (utilise par le pipeline courant)

- GUI principal: `tools/config_selector.m`, `tools/controller_selector.m`
- Calcul controleur: `tools/compute_controller.m`
- Modele principal: `model/Modele_LQR_6DOF.slx`
- Initialisation modele: `model/callbacks/Parameters.m`
- Generation matrices symboliques: `scripts/modeling/Generate_PyMatrix.m`
- Variantes LQR: `scripts/config/lqr/lqr_*.m`
- Calibrations physiques: `scripts/config/params_*.m`
- Validation reglage: `scripts/validation/*.m`
- Post-traitement: `scripts/analysis/*.m`
- Presets de simulation: `scripts/config/scenario_default.m` (et variantes)
- Tests formels: `tests/unit/`, `tests/integration/`
- Donnees de simulation:
  - `data/formes/` (trajectoires — requis)
  - `data/runtime/history/` (historique simulations — gitignore)
  - `data/generated/` (artefacts recalculables — gitignore)
  - `data/experiments/` (variantes de tuning versionnees)

### Legacy (conserves pour reference, non utilises dans le flux normal)

- `scripts/modeling/calcul_matrice_A_lineaire.m` — derivation manuelle A numerique
- `scripts/modeling/trouver_matrice_Q.m` — derivation manuelle Q

### Archive (historique)

- `archive/models/` : variantes anciennes modeles `.slx` (3DOF, r2019b, r2020b)
- `archive/scripts/` : anciens scripts de test non utilises par le flux principal

Regle: si un fichier est requis pour executer `runWorkflow`, il n'est pas en archive.

## 3) Ordre officiel de simulation

## Mode recommande (GUI)

```
1. Ouvrir ASUQTR_Control.prj
2. config_selector()        ← choisir trajectoire + calibration + controleur
3. "Appliquer et lancer"    ← lance runWorkflow(opts)
4. save_last_simulation()   ← sauvegarder apres simulation
```

## Mode pas-a-pas (debug)

1. `tools/projectStartup` (automatique a l'ouverture du projet)
2. `compute_controller('nominal')` — recalcule K si necessaire
3. `run('model/callbacks/Parameters.m')` — charge K dans workspace
4. Simuler `model/Modele_LQR_6DOF.slx`
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
