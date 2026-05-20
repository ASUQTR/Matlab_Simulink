# Modélisation du contrôle du sous-marin

Ce dépôt rassemble le modèle mathématique, la génération des matrices d'état, le calcul du retour LQR et les scripts de validation/visualisation utilisés autour des modèles Simulink du sous-marin AUV développé à l'ASUQTR.

## Demarrage pour nouveaux arrivants

Si vous arrivez sur le projet pour la premiere fois, commencez ici:

- Guide pas-a-pas: [ONBOARDING.md](ONBOARDING.md)
- Setup projet MATLAB: [docs/PROJECT_SETUP.md](docs/PROJECT_SETUP.md)
- Cartographie du projet (actif vs archive): [PROJECT_MAP.md](PROJECT_MAP.md)
- Utilitaires ponctuels: [tools/README.md](tools/README.md)
- Pipeline one-shot: `runWorkflow.m`

### Documentation par dossier

- Modele Simulink: [model/README.md](model/README.md)
- Callbacks modele: [model/callbacks/README.md](model/callbacks/README.md)
- Scripts (global): [scripts/README.md](scripts/README.md)
- Scripts de modelisation: [scripts/modeling/README.md](scripts/modeling/README.md)
- Scripts d'analyse: [scripts/analysis/README.md](scripts/analysis/README.md)
- Scripts de validation: [scripts/validation/README.md](scripts/validation/README.md)
- Presets de simulation: [scripts/config/README.md](scripts/config/README.md)
- Tests formels: [tests/README.md](tests/README.md)
- Donnees: [data/README.md](data/README.md)
- Documentation site/docs: [docs/README.md](docs/README.md)
- Archives historiques: [archive/README.md](archive/README.md)
- Ressources projet MATLAB: [resources/README.md](resources/README.md)

📘 **Documentation complète (équations rendues avec MathJax) :**
👉 [https://asuqtr.github.io/Matlab_Simulink/](https://asuqtr.github.io/Matlab_Simulink/)

> Si la page n'est pas accessible, activer GitHub Pages dans **Settings → Pages** (branche `Lewis_Cleaning`, dossier `/docs`).

---

## Points à retenir

- `Parameters.m` et `Generate_PyMatrix.m` portent le cœur de la modélisation.
- `calcul_matrice_A_lineaire.m` transforme le modèle symbolique en matrices numériques exploitables pour le contrôle.
- `trouver_matrice_Q.m` et `test_calculQ.m` servent à concevoir et valider la matrice de coût du LQR.
- Les scripts `Graphique.m`, `mouvement.m` et `instabiliter_graphique.m` sont des outils d'analyse et de présentation des résultats.
- Les fichiers `.slx` complètent la chaîne de simulation, mais la logique se trouve dans les scripts MATLAB.

## Pipeline MATLAB (vue d'ensemble)

```mermaid
flowchart TD
    P["Parameters.m"] --> GPM["Generate_PyMatrix.m"]
    GPM --> AB["ABmatrice.mat\n(symbolic A,B)"]
    AB --> CAL["calcul_matrice_A_lineaire.m"]
    CAL --> ANUM["Matrice_A_lineaire.mat\n(A_num, B_num)"]
    P --> CAL
    QF["trouver_matrice_Q.m"] --> QMAT["calcul_Q.mat\n(Q_final)"]
    QMAT --> CAL
    CAL --> K["K_LQR.mat\n(K)"]
    K --> SIM["Simulink (.slx) / Simulation"]
    SIM --> POST["Graphique.m / instabiliter_graphique.m"]
    POST --> FIGS["docs/figures (images)"]
```

---

## Documentation détaillée

| Sujet | Lien |
|-------|------|
| Vue d'ensemble et fichiers clés | [docs/overview.md](docs/overview.md) |
| Théorie : espace d'état, stabilité, LQR, Riccati | [docs/theorie.md](docs/theorie.md) |
| Pipeline MATLAB et détail des scripts | [docs/pipeline-scripts.md](docs/pipeline-scripts.md) |
| Annexes (figures, références) | [docs/annexes.md](docs/annexes.md) |
