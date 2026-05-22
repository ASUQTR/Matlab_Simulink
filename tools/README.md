# Tools

Utilitaires ponctuels et scripts d'infrastructure. Pas le pipeline de simulation.

## Contenu

| Fichier | Role |
|---------|------|
| `projectStartup.m` | Configure les chemins MATLAB au demarrage du projet. Appele automatiquement par Task Automation — ne pas appeler manuellement. |
| `config_selector.m` | **GUI principal** — choisir trajectoire, calibration, controleur LQR et lancer la simulation. |
| `controller_selector.m` | GUI secondaire — selectionner la variante LQR (`lqr_*.m`). Ouvert depuis `config_selector`. |
| `compute_controller.m` | Calcule `Q_final` et `K` selon la methode choisie (gain_scheduling ou fixed_point). Appele par `controller_selector`. |
| `save_last_simulation.m` | Sauvegarde manuelle la derniere simulation dans `data/runtime/history/`. |
| `replay_simulation.m` | Recharge un `.mat` d'historique et rejoue les analyses. |
| `set_config.m` | Change la calibration active dans le SLDD : `set_config('emile')`. |
| `create_sldd.m` | Cree `model/AUV_Params.sldd` depuis `params_nominal`. A executer une seule fois au setup. |
| `init_project.m` | Initialisation et verification one-shot du projet (creation dossiers, archivage, verification integrite). |
| `apply_compute_K.m` | Met a jour le code du bloc MATLAB Function `compute_K` dans le `.slx` depuis `model/block_compute_K.m`. A relancer apres chaque modification du fichier source. |
| `check_project_structure.m` | Verifie que l'arborescence attendue est presente (non-destructif). |
| `create_matlab_project.m` | Aide a creer/reinitialiser le `.prj` MATLAB. |

## Workflow normal

```matlab
% 1. Le projet ouvre config_selector automatiquement (ou appeler manuellement)
config_selector()

% 2. Apres simulation — sauvegarder manuellement
save_last_simulation()

% 3. Rejouer une simulation anterieure
replay_simulation()
```

## Task Automation — configuration requise

Pour que `projectStartup.m` s'execute automatiquement a l'ouverture du projet :

**Project Settings → Task Automation → Startup files → Add → `tools/projectStartup.m`**

Sans ca, les chemins MATLAB ne sont pas configures et `config_selector` echouera.
