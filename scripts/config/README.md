# Scripts/Config

Ce dossier contient deux types de configuration independants.

---

## Vue d'ensemble

```
"Quel sous-marin ?"  →  params_*.m    →  Parameters.m (callback modele)  →  blocs Simulink
"Comment simuler ?"  →  scenario_*.m  →  runWorkflow(cfg)                 →  duree, figures
```

Ces deux dimensions sont orthogonales : on peut simuler le sous-marin nominal avec
un scenario court, ou le sous-marin original avec un scenario complet, en combinant
librement les deux types.

---

## 1. Calibrations physiques — `params_*.m`

Definissent les parametres physiques du sous-marin (masse, inertie, actionneurs).
Utilises par `model/callbacks/Parameters.m` au demarrage de la simulation.

| Fichier | Description |
|---------|-------------|
| `params_nominal.m` | **Reference active** — valeurs mesurees sur le sous-marin reel (2026) |
| `params_inertie_emile.m` | Variante avec inertie calculee par Emile |
| `params_originaux.m` | Parametres du modele theorique initial (avant mesures sur le vrai robot) |

**Changer de calibration** — modifier une seule ligne dans
[model/callbacks/Parameters.m](../../model/callbacks/Parameters.m) :

```matlab
p = params_nominal();        % ← remplacer par la variante voulue
```

**Creer une variante** — surcharger uniquement ce qui change :

```matlab
function p = params_piscine()
    p = params_nominal();
    p.water_density = 998.2;  % eau douce a 20 deg C
end
```

---

## 2. Scenarios de simulation — `scenario_*.m`

Definissent les options passees a `runWorkflow` : duree, figures, exports.
Ne touchent pas aux parametres physiques du modele.

| Fichier | Description |
|---------|-------------|
| `scenario_default.m` | Simulation standard — 10s, graphiques actifs, pas d'animation ni de sauvegarde |

**Lancer avec un scenario** :

```matlab
cfg = scenario_default();
simOut = runWorkflow(cfg);
```

**Creer un scenario** — copier et modifier :

```matlab
function cfg = scenario_demo()
    cfg = scenario_default();
    cfg.stopTime     = 30;
    cfg.runMouvement = true;   % animation 3D
    cfg.saveFigures  = true;   % sauvegarde dans docs/figures/
end
```

---

## Combiner les deux

La calibration active est toujours celle definie dans `Parameters.m`.
Le scenario est celui passe a `runWorkflow`.
On peut les changer independamment :

```matlab
% Dans Parameters.m : p = params_inertie_emile();  ← calibration
% Dans la Command Window :
cfg = scenario_default();
cfg.stopTime = 30;
simOut = runWorkflow(cfg);                           % ← scenario
```

---

> **Migration future** : les `params_*.m` seront remplacees par un Simulink Data Dictionary
> (`model/AUV_Params.sldd`), ce qui eliminera le `Parameters.m` callback et le besoin
> d'assigner les variables manuellement au workspace.
