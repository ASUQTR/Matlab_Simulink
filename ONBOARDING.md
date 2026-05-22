# Onboarding rapide (nouvel arrivant)

Ce guide permet de lancer le pipeline en moins de 10 minutes.

Reference structure: `PROJECT_MAP.md` — Documentation complete: `docs/`

---

## En 3 etapes

```
1. Ouvrir ASUQTR_Control.prj   →  MATLAB configure tout automatiquement
2. config_selector()            →  choisir trajectoire + controleur + lancer
3. save_last_simulation()       →  sauvegarder les resultats (manuel)
```

---

## 1) Ouvrir le projet

Dans MATLAB : **Home → Open → `ASUQTR_Control.prj`**

MATLAB execute automatiquement `tools/projectStartup.m` a l'ouverture, ce qui :
- ajoute `scripts/`, `data/formes/`, `data/generated/`, `tools/`, `model/` au path
- initialise les variables workspace (`TRAJECTOIRE`, `YAW_MODE`, `CONTROLLER_VARIANT`, etc.)

> **Premiere fois sur cette machine ?** Verifier dans Project Settings → Task Automation que
> `tools/projectStartup.m` est bien dans "Startup files". Sinon l'ajouter manuellement
> (voir `docs/PROJECT_SETUP.md`). Aussi executer `create_sldd()` une seule fois.

---

## 2) Lancer une simulation via le GUI

```matlab
config_selector()
```

La fenetre `config_selector` permet de configurer :

| Parametre | Options |
|-----------|---------|
| Trajectoire | Carre / Cercle / Lissajous |
| Taille trajectoire | Rayon ou cote (m) |
| Duree | Secondes |
| Yaw mode | Cap fixe (recommande) / Pointer vers cible* |
| Calibration physique | nominal / emile / originaux |
| Controleur LQR | Bouton "Controleur LQR" → `controller_selector` |

> *YAW_MODE=1 (pointer vers cible) peut causer de la divergence — le LQR est linearise
> autour de yaw=0. Un avertissement s'affiche dans le GUI.

### Choisir le controleur LQR

Le bouton **"Controleur LQR"** ouvre `controller_selector`, qui detecte automatiquement
toutes les variantes `scripts/config/lqr/lqr_*.m` :

| Variante | Methode | Description |
|----------|---------|-------------|
| `nominal` | gain_scheduling | K recalcule a chaque pas (actif par defaut) |
| `nominal_fixedpoint` | fixed_point | K constant au point d'operation |

### Appliquer et lancer

Le bouton **"Appliquer et lancer"** dans `config_selector` appelle `runWorkflow(opts)`
avec les options selectionnees.

---

## 3) Sauvegarder et rejouer

Les sorties ne sont **pas sauvegardees automatiquement**. Apres chaque simulation :

```matlab
save_last_simulation()   % sauvegarde dans data/runtime/history/
```

Pour rejouer une simulation precedente :

```matlab
replay_simulation()      % ouvre un selecteur de fichier
```

---

## 4) Analyser les resultats

| Ce que tu veux voir | Script |
|---------------------|--------|
| Graphiques position/commande | `scripts/analysis/Graphique.m` |
| Animation 3D trajectoire | relancer avec option Mouvement 3D dans le GUI |
| Evolution des poles (stabilite) | `scripts/analysis/instabiliter_graphique.m` |
| Resume instabilites | `scripts/analysis/report_instabilities.m` |

---

## 5) Si une erreur apparait

- **"File not found"** : verifier que `data/formes/sous marin en pentagone.mat` existe.
- **"Undefined function"** : le projet n'est peut-etre pas ouvert. Rouvrir `ASUQTR_Control.prj`.
- **Artefacts manquants** : les fichiers `data/generated/*.mat` sont recalculables — relancer `scripts/modeling/Generate_PyMatrix.m` puis `compute_controller('nominal')`.
- **SLDD introuvable** : executer `create_sldd()` dans la Command Window (une seule fois par machine).

---

## 6) Structure en un coup d'oeil

```
ASUQTR_Control.prj      ← ouvrir ceci
model/
  Modele_LQR_6DOF.slx   ← modele Simulink
  AUV_Params.sldd        ← parametres physiques actifs
  callbacks/Parameters.m ← charge le controleur et exporte les variables
scripts/
  modeling/              ← generation matrices symboliques A, B (Generate_PyMatrix.m)
  analysis/              ← graphiques, animation, stabilite
  config/
    params_*.m           ← calibrations physiques
    lqr/lqr_*.m          ← variantes de controleur LQR
tools/
  config_selector.m      ← GUI principal (lancer ici)
  controller_selector.m  ← GUI selection variante LQR
  compute_controller.m   ← calcule Q et K
  save_last_simulation.m ← sauvegarde manuelle
  replay_simulation.m    ← rejouer une simulation
  set_config.m           ← changer de calibration
data/
  formes/                ← trajectoires (requis)
  generated/             ← artefacts recalculables (gitignore)
  runtime/history/       ← historique simulations (gitignore)
```

Pour savoir "quel fichier fait quoi" : `PROJECT_MAP.md`.

---

## Mini glossaire

| Terme | Definition |
|-------|------------|
| `A`, `B` | Matrices d'etat linearisees (dynamique et entree commande) |
| `Q`, `R` | Poids du regulateur LQR (compromis precision / effort) |
| `K` | Gain de retour d'etat calcule par LQR |
| `CONTROLLER_VARIANT` | Nom de la variante LQR active (ex: `'nominal'`) |
| `CONTROL_METHOD_NUM` | 0=gain_scheduling, 1=fixed_point (lu par le bloc Simulink) |
| poles | Valeurs propres boucle fermee — partie reelle > 0 = instabilite |
| SLDD | Simulink Data Dictionary — fichier de parametres branche directement sur le modele |

Glossaire complet : `docs/glossaire.md`
