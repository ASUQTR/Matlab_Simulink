# Testing and smoke checks

Quick test steps to verify the project after cloning or restructuring.

1) Start MATLAB and open the project folder:

```matlab
cd('C:\Programmation\ASUQTR\Matlab_Simulink')
addpath(genpath(pwd))
projectStartup()   % adds project paths and checks expected files
```

2) Initialize parameters (runs checks added in `Parameters.m`)

```matlab
run('model/callbacks/Parameters.m')
```

3) Run generation scripts (optional)

```matlab
run('scripts/modeling/Generate_PyMatrix.m')
run('scripts/modeling/calcul_matrice_A_lineaire.m')
```

4) Run validation scripts (optional)

```matlab
run('scripts/validation/test_calcalV2.m')
run('scripts/validation/test_calculQ.m')
```

5) Open and simulate the main model (smoke test)

```matlab
open_system('model/Modele_LQR_6DOF.slx')
sim('model/Modele_LQR_6DOF.slx','StopTime','10')
```

6) Recommended one-click workflow for simulation + plots

```matlab
simOut = runWorkflow(struct(...
	'runParameters', true, ...
	'runGraphique', true, ...
	'runMouvement', false, ...
	'runStability', true, ...
	'openModel', false, ...
	'stopTime', 10));
```

What to check:
- No "file not found" errors in the MATLAB console.
- `Parameters.m` ran and did not throw an error.
- The signal files under `data/formes` are found and loaded by the model.
- Figures from `scripts/analysis/Graphique.m` appear (if run).
- `scripts/analysis/instabiliter_graphique.m` produces the pole-evolution plot when the required logs are available.

If you encounter errors, copy the full MATLAB error text and the failing script name and report it.
