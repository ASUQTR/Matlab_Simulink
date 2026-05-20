# Model Callbacks

Scripts executes automatiquement par Simulink a l'ouverture du modele.

## Contenu

- `Parameters.m` : charge les matrices LQR calculees et les exporte au workspace.

## Ce que fait Parameters.m

Depuis la migration SLDD, ce callback ne charge plus les parametres physiques —
ceux-ci viennent directement de `model/AUV_Params.sldd`, lie au modele.

Il charge uniquement :
1. `calcul_Q.mat` → `Q_final`, `Q_envoyer`
2. `Matrice_A_lineaire.mat` → `A_num`

## Changer de calibration

```matlab
set_config('nominal')    % valeurs mesurees 2026 (defaut)
set_config('emile')      % variante inertie Emile
set_config('originaux')  % modele theorique initial
```

Les sources de chaque calibration sont dans `scripts/config/params_*.m`.

## Dependances

- `model/AUV_Params.sldd` — parametres physiques (lie au modele .slx)
- `data/generated/calcul_Q.mat` — matrice Q du LQR
- `data/generated/Matrice_A_lineaire.mat` — matrice A numerique

## Setup initial (1ere fois sur une machine)

```matlab
create_sldd()   % cree model/AUV_Params.sldd depuis params_nominal
```

Puis lier le modele au SLDD (une seule fois) :
```matlab
load_system('model/Modele_LQR_6DOF');
set_param('Modele_LQR_6DOF', 'DataDictionary', 'AUV_Params.sldd');
save_system('model/Modele_LQR_6DOF');
```
