# Onboarding rapide (nouvel arrivant)

Ce guide permet de lancer le pipeline en moins de 10 minutes.

Reference structure: `PROJECT_MAP.md` — Documentation complete: `docs/`

---

## En 2 etapes

```
1. Ouvrir ASUQTR_Control.prj  →  MATLAB configure tout automatiquement
2. runWorkflow()               →  simulation + figures
```

C'est tout. Le projet s'occupe des chemins MATLAB au demarrage via Task Automation.

---

## 1) Ouvrir le projet

Dans MATLAB : **Home → Open → `ASUQTR_Control.prj`**

MATLAB execute automatiquement `tools/projectStartup.m` a l'ouverture, ce qui :
- ajoute `scripts/`, `data/formes/`, `data/generated/`, `tools/`, `model/` au path
- verifie que les fichiers requis sont presents

> **Premiere fois sur cette machine ?** Verifier dans Project Settings → Task Automation que `tools/projectStartup.m` est bien dans "Startup files". Sinon l'ajouter manuellement (voir `docs/PROJECT_SETUP.md`).

---

## 2) Lancer une simulation

```matlab
simOut = runWorkflow();
```

**Deux types de configuration independants :**

| Type | Comment changer | Controle |
|------|----------------|---------|
| Calibration physique | `set_config('nominal')` dans la Command Window | Masse, inertie, actionneurs |
| Scenario de simulation | `cfg = scenario_default(); cfg.stopTime = 30;` passe a `runWorkflow` | Duree, figures, exports |

### Changer de calibration physique

```matlab
set_config('nominal')    % valeurs mesurees 2026 (defaut)
set_config('emile')      % variante avec inertie calculee par Emile
set_config('originaux')  % modele theorique initial (avant mesures)
```

Puis relancer `runWorkflow()`. Le modele Simulink lit les parametres
directement depuis `model/AUV_Params.sldd` — pas besoin de modifier de fichier.

> **C'est quoi le SLDD ?** Un fichier de parametres directement branche sur le modele
> Simulink. `set_config` met a jour ce fichier, le modele le relit automatiquement.
> Les sources de chaque calibration restent dans `scripts/config/params_*.m`.

### Changer les options de simulation

```matlab
cfg = scenario_default();   % scripts/config/scenario_default.m
cfg.stopTime    = 30;
cfg.saveFigures = true;
simOut = runWorkflow(cfg);
```

Voir `scripts/config/README.md` pour la liste complete et des exemples.

---

## 3) Lire les resultats

| Ce que tu veux voir | Script |
|---------------------|--------|
| Graphiques position/commande | `scripts/analysis/Graphique.m` |
| Animation 3D trajectoire | relancer avec `cfg.runMouvement = true` |
| Evolution des poles (stabilite) | `scripts/analysis/instabiliter_graphique.m` |
| Resume instabilites | `scripts/analysis/report_instabilities.m` |

Les sorties sont sauvegardees automatiquement :
- `data/runtime/info_simulation.mat` — derniere simulation
- `data/runtime/history/info_simulation_YYYYMMDD_HHMMSS.mat` — historique

---

## 4) Si une erreur apparait

- **"File not found"** : verifier que `data/formes/sous marin en pentagone.mat` existe.
- **"Undefined function"** : le projet n'est peut-etre pas ouvert. Rouvrir `ASUQTR_Control.prj`.
- **Artefacts manquants** : les fichiers `data/generated/*.mat` sont recalculables — relancer les scripts dans `scripts/modeling/` dans l'ordre.
- **SLDD introuvable** : executer `create_sldd()` dans la Command Window (a faire une seule fois par machine).

---

## 5) Structure en un coup d'oeil

```
ASUQTR_Control.prj   ← ouvrir ceci
runWorkflow.m        ← lancer ceci
model/
  Modele_LQR_6DOF.slx   ← modele Simulink
  AUV_Params.sldd        ← parametres physiques actifs (config active)
scripts/
  modeling/          ← generation matrices A, B, Q, K
  analysis/          ← graphiques, animation, stabilite
  validation/        ← verification du reglage
  config/            ← calibrations (params_*.m) et scenarios (scenario_*.m)
tools/
  set_config.m       ← changer de calibration
  create_sldd.m      ← setup initial du SLDD (1 fois par machine)
data/
  formes/            ← trajectoires/scenarios (requis)
  generated/         ← artefacts recalculables (gitignore)
  experiments/       ← variantes de tuning versionnees
  runtime/           ← sorties de simulation (gitignore)
archive/
  models/            ← anciens .slx
  scripts/           ← anciens .m
```

Pour savoir "quel fichier fait quoi" : `PROJECT_MAP.md`.

---

## Mini glossaire

| Terme | Definition |
|-------|------------|
| `A`, `B` | Matrices d'etat lineairees (dynamique et entree commande) |
| `Q`, `R` | Poids du regulateur LQR (compromis precision / effort) |
| `K` | Gain de retour d'etat calcule par LQR |
| `out` | Objet `Simulink.SimulationOutput` contenant les signaux |
| poles | Valeurs propres boucle fermee — partie reelle > 0 = instabilite |
| SLDD | Simulink Data Dictionary — fichier de parametres branche directement sur le modele |

Glossaire complet : `docs/glossaire.md`
