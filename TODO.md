# TODO — Travaux en suspens

> Mis à jour : 2026-05-20
> Branche active : `feature/sldd`

---

## PRIORITÉ HAUTE

### 1. Switch CONTROL_METHOD dans le modèle Simulink
Implémenter le basculement gain scheduling / point fixe dans `model/Modele_LQR_6DOF.slx`.

**Ce qu'il faut faire :**
- Ouvrir le modèle et localiser où K est appliqué (signal u = -K·x)
- Ajouter un `Variant Subsystem` avec deux variantes :
  - `GainScheduling` (condition : `CONTROL_METHOD_NUM == 0`) — comportement actuel
  - `FixedPoint`      (condition : `CONTROL_METHOD_NUM == 1`) — K constant depuis workspace
- La variable `CONTROL_METHOD_NUM` est déjà exportée par `Parameters.m`
- La config côté MATLAB est prête (`lqr_nominal_fixedpoint.m`, `compute_controller`)

**Référence :** `scripts/config/lqr/lqr_nominal_fixedpoint.m` + `tools/compute_controller.m`

---

### 2. Connecter SIZE_TRAJ dans le bloc Simulink `trajectoire`
La fonction trajectoire a 5 entrées (t, TRAJECTOIRE, YAW_MODE, T_TRAJ, SIZE_TRAJ).
Le 5e port (SIZE_TRAJ) doit être branché à un bloc `Constant` lisant la variable workspace.

**Ce qu'il faut faire :**
- Ouvrir `model/Modele_LQR_6DOF.slx`
- Ajouter un bloc `Constant` avec valeur `SIZE_TRAJ` (variable workspace)
- Brancher sur le 5e port d'entrée du bloc MATLAB Function `trajectoire`

---

## PRIORITÉ MOYENNE

### 3. Mettre à jour les READMEs
Les fichiers suivants sont périmés — le workflow a changé (GUI-first, variables workspace, compute_controller).

| Fichier | Ce qui est périmé |
|---|---|
| `README.md` | Diagramme pipeline, section "Points à retenir" |
| `ONBOARDING.md` | Workflow entier (maintenant config_selector + controller_selector) |
| `tools/README.md` | Manque : config_selector, controller_selector, compute_controller, save/replay |
| `scripts/config/README.md` | Manque le sous-dossier `lqr/` et la notion de CONTROLLER_VARIANT |
| `scripts/modeling/README.md` | Marquer les scripts legacy comme tels |
| `PROJECT_MAP.md` | Workflow et liste des fichiers actifs à mettre à jour |

---

### 4. Déplacer `init_project.m` vers `tools/`
Fichier actuellement non tracké à la racine — appartient à `tools/`.

```
init_project.m  →  tools/init_project.m
```

---

### 5. LQR redesign pour le mode yaw_tracking
Le mode `YAW_MODE = 1` (pointer vers la cible) cause de la divergence car le LQR est
linéarisé autour de yaw = 0. Il faut re-linéariser autour d'un point d'opération en rotation.

**Approche :**
- Créer `scripts/config/lqr/lqr_yaw_tracking.m` avec un point d'opération en yaw ≠ 0
- Recalculer K avec `compute_controller('yaw_tracking')`
- Tester la stabilité en boucle fermée

**Prérequis :** Switch Simulink (point 1) doit être implémenté pour utiliser ce K.

---

## PRIORITÉ BASSE

### 6. Commit de la branche `feature/sldd`
Une fois les points 1 et 2 testés et stables, créer un commit propre.

### 7. Paramètres de bruit capteurs
Future couche de config pour tester des niveaux de bruit différents (IMU, profondimètre, etc.).
Architecture identique aux configs `lqr_*.m` — prévoir `scripts/config/sensors/sensor_*.m`.

### 8. Dropdown contrôleur dans `config_selector`
Optionnellement fusionner le sélecteur de contrôleur directement dans `config_selector.m`
pour éviter d'ouvrir une deuxième fenêtre.

---

## FAIT (cette session — 2026-05-20)

- [x] `config_selector.m` — refonte en 2 colonnes, 660px, bouton contrôleur intégré
- [x] `controller_selector.m` — nouveau GUI avec détection auto des variantes lqr_*.m
- [x] `lqr_nominal.m` — config versionnée avec champ `method`
- [x] `lqr_nominal_fixedpoint.m` — variante K constant (config prête, switch Simulink en attente)
- [x] `compute_controller.m` — supporte gain_scheduling et fixed_point
- [x] `Parameters.m` — exporte CONTROL_METHOD et CONTROLLER_VARIANT
- [x] `calcul_matrice_A_lineaire.m` — documenté (méthode fixed_point, legacy)
- [x] `trouver_matrice_Q.m` — documenté (dérivation de Q, legacy)
- [x] `projectStartup.m` — initialise CONTROLLER_VARIANT
- [x] `save_last_simulation.m` + `replay_simulation.m` — outils de sauvegarde manuelle
