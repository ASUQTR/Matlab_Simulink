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
- ajoute `scripts/`, `data/formes/`, `data/generated/`, `tools/` au path
- verifie que les fichiers requis sont presents

> **Premiere fois sur cette machine ?** Verifier dans Project Settings → Task Automation que `tools/projectStartup.m` est bien dans "Startup files". Sinon l'ajouter manuellement (voir `docs/PROJECT_SETUP.md`).

---

## 2) Lancer une simulation

```matlab
simOut = runWorkflow();
```

**Deux types de configuration independants :**

| Type | Fichier | Controle |
|------|---------|---------|
| Calibration physique | `scripts/config/params_*.m` | Masse, inertie, actionneurs — modifie dans `Parameters.m` |
| Scenario de simulation | `scripts/config/scenario_*.m` | Duree, figures, exports — passe a `runWorkflow` |

Exemple — changer la duree et sauvegarder les figures :

```matlab
cfg = scenario_default();   % scripts/config/scenario_default.m
cfg.stopTime    = 30;
cfg.saveFigures = true;
simOut = runWorkflow(cfg);
```

Pour changer la calibration physique : modifier `model/callbacks/Parameters.m`,
remplacer `params_nominal()` par la variante voulue.

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
- **Artefacts manquants** : les fichiers `data/generated/*.mat` (ABmatrice, calcul_Q, etc.) sont recalculables — relancer les scripts dans `scripts/modeling/` dans l'ordre.

---

## 5) Structure en un coup d'oeil

```
ASUQTR_Control.prj   ← ouvrir ceci
runWorkflow.m        ← lancer ceci
model/               ← modele Simulink + parametres
scripts/
  modeling/          ← generation matrices A, B, Q, K
  analysis/          ← graphiques, animation, stabilite
  validation/        ← verification du reglage
  config/            ← presets de simulation (scenario_default, etc.)
data/
  formes/            ← trajectoires/scenarios (requis)
  generated/         ← artefacts recalculables (gitignore)
  experiments/       ← variantes de tuning versionnees
  runtime/           ← sorties de simulation (gitignore)
tests/               ← tests formels (unit/, integration/)
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

Glossaire complet : `docs/glossaire.md`
