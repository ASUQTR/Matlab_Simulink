# Model

Contient le modele Simulink principal et les fonctions MATLAB associees au controleur.

## Contenu

| Fichier | Role |
|---------|------|
| `Modele_LQR_6DOF.slx` | Modele Simulink principal 6 DOF |
| `callbacks/Parameters.m` | Callback init : charge le controleur LQR et exporte les variables workspace |
| `block_linearize_A.m` | Code a coller dans le bloc MATLAB Function `linearize_A` |
| `block_compute_K.m` | Code a coller dans le bloc MATLAB Function `compute_K` |

---

## Architecture du controleur (subsystem Controller)

```
state (y) ──→ [linearize_A] ──→ A ──→ [compute_K] ──→ K ──→ [State_error] ──→ u
                                        ↑
              Q_envoyer ────────────────┤
              CONTROL_METHOD_NUM ───────┤  (blocs Constant depuis workspace)
              K ────────────────────────┤
              Constant(Ts) ─────────────┘  (dt = pas fixe du solver)
```

### Bloc `linearize_A`
**Fichier :** `block_linearize_A.m`

Calcule la matrice A linearisee autour de l'etat courant x(t) — le Jacobien du
modele non-lineaire evalue a chaque pas. Entree : `state` (12x1). Sortie : `A` (12x12).

### Bloc `compute_K`
**Fichier :** `block_compute_K.m`

Calcule le gain K selon la methode active (`CONTROL_METHOD_NUM`) :

| `CONTROL_METHOD_NUM` | Methode | Description |
|---|---|---|
| `0` | `gain_scheduling` | Resout l'equation de Riccati en temps reel (Euler avant, pur code matriciel) |
| `1` | `fixed_point` | Retourne directement `K_fixed` depuis le workspace (pre-calcule) |

**Equation de Riccati (gain scheduling) :**
```
dP/dt = A'P + PA - PB R⁻¹ B'P + Q
P(t+dt) = P(t) + dt * dP/dt
K = R⁻¹ B' P
```

Implementation via `persistent P` — equivalent a l'ancien `mRiccati + integrateur`
mais en pur code matriciel (pas de `coder.extrinsic`, compile nativement).

### Bloc `State_error`
```matlab
u = -K * (state - target_state)
```

---

## Variables workspace requises

| Variable | Source | Role |
|---|---|---|
| `Q_envoyer` | `Parameters.m` | Matrice Q (12x12) pour le gain scheduling |
| `K` | `Parameters.m` | Gain pre-calcule pour le mode fixed_point |
| `CONTROL_METHOD_NUM` | `Parameters.m` | 0 = gain_scheduling, 1 = fixed_point |
| `CONTROLLER_VARIANT` | `projectStartup.m` | Nom de la variante active (ex: `'nominal'`) |
| `Ts` | `projectStartup.m` | Pas de simulation (s) — lu par le solver et le bloc Constant(dt) |
| `T_TRAJ` | `projectStartup.m` / GUI | Duree simulation = stop time Simulink |

Toutes ces variables sont assignees automatiquement au demarrage via
`projectStartup.m` + `Parameters.m`. Ne pas les assigner manuellement.

---

## Configuration du solver Simulink

**Reglage actuel :** Fixed-step, ode4, step = `Ts` (variable workspace)

```
Configuration Parameters → Solver
  Type        : Fixed-step
  Solver      : ode4 (Runge-Kutta)
  Step size   : Ts          ← variable workspace (defaut : 0.01 s = 100 Hz)
  Stop time   : T_TRAJ      ← variable workspace (duree trajectoire)
```

Pour changer la frequence de simulation : modifier `Ts` dans `projectStartup.m`
ou utiliser le champ "Frequence de boucle" dans `config_selector`.

Avantages du fixed-step :
- `dt` constant → integration Riccati stable (Euler avant)
- Simulation deterministe et reproductible
- Tous les blocs a sample time variable (`ZOH`, `White Noise`) heritent de `Ts` automatiquement

---

## Callbacks

### `Parameters.m`

Execute automatiquement par Simulink avant chaque simulation.

1. Determine la variante active (`CONTROLLER_VARIANT` depuis workspace)
2. Charge `data/generated/controller_<variant>.mat` :
   - `K` → gain LQR (pre-calcule)
   - `Q_final` → matrice de cout
   - `A_num` → A au point nominal (verification seulement)
   - `method` → `'gain_scheduling'` ou `'fixed_point'`
3. Calcule `CONTROL_METHOD_NUM` = 0 ou 1
4. Exporte tout au workspace base

Si `controller_<variant>.mat` est absent, tente un fallback sur les fichiers legacy
(`calcul_Q.mat`, `Matrice_A_lineaire.mat`). Ce fallback disparaitra quand tous les
controleurs auront ete generes via `compute_controller`.

---

## Setup initial (1ere fois sur une machine)

```matlab
create_sldd()                    % cree model/AUV_Params.sldd
compute_controller('nominal')    % genere controller_nominal.mat
```

`compute_controller` est aussi lance automatiquement par `config_selector`
si le `.mat` est absent au moment de lancer la simulation.
