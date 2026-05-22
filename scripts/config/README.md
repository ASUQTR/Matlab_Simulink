# Scripts/Config

Ce dossier contient trois types de configuration independants.

---

## Vue d'ensemble

```
"Quel sous-marin ?"     →  params_*.m  →  set_config()  →  AUV_Params.sldd  →  blocs Simulink
"Quel controleur LQR ?" →  lqr/lqr_*.m  →  compute_controller()  →  controller_<variant>.mat
"Comment simuler ?"     →  scenario_*.m  →  runWorkflow(cfg)  →  duree, figures
```

---

## 1. Calibrations physiques — `params_*.m`

Definissent les parametres physiques du sous-marin (masse, inertie, actionneurs).
Ces fichiers sont la **source de verite lisible** — les valeurs sont chargees dans
`model/AUV_Params.sldd` via `set_config()`, et le modele Simulink les lit depuis le SLDD.

| Fichier | Description |
|---------|-------------|
| `params_nominal.m` | **Reference active** — valeurs mesurees sur le sous-marin reel (2026) |
| `params_emile.m` | Variante avec inertie calculee par Emile |
| `params_originaux.m` | Parametres du modele theorique initial (avant mesures sur le vrai robot) |

**Changer de calibration** — via le GUI ou la Command Window :

```matlab
set_config('nominal')    % valeurs mesurees 2026 (defaut git)
set_config('emile')      % variante inertie Emile
set_config('originaux')  % modele theorique initial
```

---

## 2. Controleurs LQR — `lqr/lqr_*.m`

Chaque fichier definit un point d'operation et une methode de calcul de K.
`compute_controller('nom_variante')` lit le fichier correspondant et exporte
`controller_<variant>.mat` dans `data/generated/`.

| Fichier | Methode | Description |
|---------|---------|-------------|
| `lqr/lqr_nominal.m` | `gain_scheduling` | **Actif** — K recalcule a chaque pas (Riccati temps reel) |
| `lqr/lqr_nominal_fixedpoint.m` | `fixed_point` | K constant calcule au point d'operation nominal |

**Ajouter une variante** — creer `lqr/lqr_<nom>.m` avec les champs `cfg.op`, `cfg.Q`,
`cfg.R`, `cfg.method`. Elle apparait automatiquement dans `controller_selector`.

La variable workspace `CONTROLLER_VARIANT` indique la variante active (ex: `'nominal'`).
`CONTROL_METHOD_NUM` (0=gain_scheduling, 1=fixed_point) est lu par le bloc Simulink.

---

## 3. Scenarios de simulation — `scenario_*.m`

Definissent les options passees a `runWorkflow` : duree, figures, exports.
Ne touchent pas aux parametres physiques ni au controleur.

| Fichier | Description |
|---------|-------------|
| `scenario_default.m` | Simulation standard — 10s, graphiques actifs, pas d'animation ni de sauvegarde |

```matlab
cfg = scenario_default();
cfg.stopTime = 30;
simOut = runWorkflow(cfg);
```
