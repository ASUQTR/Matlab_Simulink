# Model Callbacks

Scripts executes automatiquement par Simulink avant chaque simulation.

## Parameters.m

Charge le controleur LQR actif et exporte les variables requises au workspace base.

**Variables exportees :**

| Variable | Valeur | Usage |
|---|---|---|
| `Q_final` | Matrice 12x12 | Matrice de cout complete |
| `Q_envoyer` | `Q_final(:,:,1)` | Entree du bloc `compute_K` |
| `K` | Gain 8x12 | Entree `K_fixed` du bloc `compute_K` |
| `A_num` | Matrice 12x12 | A au point nominal (reference) |
| `CONTROL_METHOD` | `'gain_scheduling'` ou `'fixed_point'` | Methode texte |
| `CONTROL_METHOD_NUM` | 0 ou 1 | Lu par le bloc Constant Simulink |

**Logique de chargement :**
1. Lit `CONTROLLER_VARIANT` depuis le workspace (defaut : `'nominal'`)
2. Charge `data/generated/controller_<variant>.mat`
3. Si absent : fallback legacy (`calcul_Q.mat` + `Matrice_A_lineaire.mat`)

## Changer de calibration physique

```matlab
set_config('nominal')    % valeurs mesurees 2026 (defaut)
set_config('emile')      % variante inertie Emile
set_config('originaux')  % modele theorique initial
```

## Setup initial (1ere fois sur une machine)

```matlab
create_sldd()                  % cree model/AUV_Params.sldd
compute_controller('nominal')  % genere controller_nominal.mat
```
