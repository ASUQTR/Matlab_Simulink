# TODO — Travaux en suspens

> Mis à jour : 2026-05-21
> Branche active : `feature/sldd`

---

## PRIORITÉ HAUTE

### 1. Passer le solver Simulink en fixed-step ode4 (0.01s)
Le solver actuel (variable-step auto) donne un `dt` variable, ce qui rend
l'intégration Riccati moins précise et la simulation plus lente.

**Ce qu'il faut faire dans Simulink :**
```
Configuration Parameters → Solver
  Type      : Fixed-step
  Solver    : ode4 (Runge-Kutta)
  Step size : 0.01
```

Puis dans le bloc `compute_K` (Simulink) :
- Remplacer le bloc `Clock` par un bloc `Constant` avec valeur `0.01`
- Renommer le port `t` → `dt` dans le bloc
- Supprimer `persistent t_prev` dans `block_compute_K.m`
- Simplifier `gain_scheduling(A, Q_files, dt)` : plus besoin de calculer `dt = t - t_prev`

**Fichier à modifier :** `model/block_compute_K.m`

---

### 2. Nettoyer les connexions obsolètes dans Simulink
Warnings lors de la simulation : ports Demux 7-12 non connectés, port Add non connecté.
Ces fils venaient de l'ancien bloc `ABmatrix` (qui sortait R, Q, A, B séparément).

**Ce qu'il faut faire dans Simulink :**
- Supprimer les blocs `out.R_s`, `out.Q_s`, `out.A_s`, `out.B_s` (si encore présents)
- Déconnecter / supprimer les fils pendants dans le subsystem `Controller`
- Vérifier le subsystem `ROV model` (port Add non connecté)

---

### 3. Valider la simulation end-to-end
La simulation a tourné une fois mais a été interrompue (Ctrl-C).
Lancer une simulation complète (30s, trajectoire carrée, rayon 1m) et vérifier :
- Pas d'erreur ni d'exception
- La trajectoire converge (pas de divergence)
- Les graphiques s'affichent correctement
- `save_last_simulation()` fonctionne après le run

---

## PRIORITÉ MOYENNE

### 4. Tester le mode fixed_point
Une fois le solver fixe (point 1), valider que le switch `CONTROL_METHOD_NUM = 1`
fonctionne correctement :
- Sélectionner `nominal_fixedpoint` dans `controller_selector`
- Lancer `compute_controller('nominal_fixedpoint')`
- Lancer la simulation et vérifier la stabilité

---

### 5. Commit de la branche `feature/sldd`
Une fois les points 1, 2, 3 testés et stables, créer un commit propre.

**Fichiers modifiés à inclure :**
- `model/Modele_LQR_6DOF.slx` (nouveaux blocs linearize_A, compute_K, Clock/Constant, SIZE_TRAJ)
- `model/block_linearize_A.m` (nouveau)
- `model/block_compute_K.m` (nouveau)
- `model/README.md` (mis à jour)
- `model/callbacks/Parameters.m` (exporte K et CONTROL_METHOD_NUM)
- `model/callbacks/README.md` (mis à jour)
- `tools/config_selector.m` (bouton Editer config LQR, auto-compute)
- `tools/controller_selector.m` (affichage Q diagonal)
- `scripts/config/lqr/lqr_nominal.m` (cfg.Q explicite, op hover)
- `scripts/config/lqr/lqr_nominal_fixedpoint.m` (cfg.Q explicite, op hover)
- `scripts/config/README.md` (mis à jour)
- `scripts/modeling/README.md` (legacy documenté)
- `tools/init_project.m` (déplacé depuis racine)
- `tools/README.md` (mis à jour)
- `ONBOARDING.md` (workflow GUI)
- `README.md` (pipeline GUI)
- `PROJECT_MAP.md` (mis à jour)

---

## PRIORITÉ BASSE

### 6. LQR redesign pour le mode yaw_tracking
Le mode `YAW_MODE = 1` cause de la divergence — le LQR est linéarisé autour
de yaw = 0. Nécessite une re-linéarisation autour d'un point en rotation.

**Prérequis :** point 3 (validation) doit être stable.

**Approche :**
- Créer `scripts/config/lqr/lqr_yaw_tracking.m` avec cfg.op.yaw ≠ 0
- Valider la stabilité en boucle fermée
- Tester dans la simulation

---

### 7. Paramètres de bruit capteurs
Future couche de config pour tester différents niveaux de bruit (IMU, profondimètre).
Architecture identique aux configs `lqr_*.m` — prévoir `scripts/config/sensors/sensor_*.m`.

---

### 8. Dropdown contrôleur dans `config_selector`
Optionnellement fusionner le sélecteur de contrôleur directement dans `config_selector.m`
pour éviter d'ouvrir une deuxième fenêtre.

---

## FAIT (session 2026-05-21)

- [x] Refonte controleur : remplacé ABmatrix + mRiccati ODE + blocs matriciels par 2 blocs MATLAB Function propres (`linearize_A` + `compute_K`)
- [x] `compute_K` — Riccati en pur code matriciel (persistent P, Euler avant, sans coder.extrinsic)
- [x] `compute_K` — switch gain_scheduling / fixed_point via `CONTROL_METHOD_NUM`
- [x] `lqr_nominal.m` — Q diagonal explicite (Bryson), point op hover, compatible lqr()
- [x] `lqr_nominal_fixedpoint.m` — Q diagonal explicite, point op hover
- [x] `Parameters.m` — exporte K et CONTROL_METHOD_NUM au workspace
- [x] `config_selector.m` — bouton "Editer config LQR", auto-compute si .mat absent
- [x] `controller_selector.m` — affichage Q diagonal (gere cfg.Q et legacy cfg.q_state_vals)
- [x] SIZE_TRAJ connecté au 5e port du bloc trajectoire dans Simulink
- [x] `init_project.m` déplacé → `tools/init_project.m`
- [x] READMEs mis à jour (README.md, ONBOARDING.md, PROJECT_MAP.md, tools/, scripts/config/, scripts/modeling/, model/, model/callbacks/)

## FAIT (session 2026-05-20)

- [x] `config_selector.m` — refonte en 2 colonnes, 660px, bouton contrôleur intégré
- [x] `controller_selector.m` — nouveau GUI avec détection auto des variantes lqr_*.m
- [x] `lqr_nominal.m` — config versionnée avec champ `method`
- [x] `lqr_nominal_fixedpoint.m` — variante K constant (config prête)
- [x] `compute_controller.m` — supporte gain_scheduling et fixed_point
- [x] `Parameters.m` — exporte CONTROL_METHOD et CONTROLLER_VARIANT
- [x] `calcul_matrice_A_lineaire.m` — documenté (legacy)
- [x] `trouver_matrice_Q.m` — documenté (legacy)
- [x] `projectStartup.m` — initialise CONTROLLER_VARIANT
- [x] `save_last_simulation.m` + `replay_simulation.m` — outils de sauvegarde manuelle
