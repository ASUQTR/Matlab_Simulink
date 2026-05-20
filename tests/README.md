# Tests

Scripts de verification formels du projet, distincts des scripts `validation/` qui servent au reglage.

## Sous-dossiers

- `unit/` : tests unitaires de fonctions individuelles (matrices, gains, calculs).
- `integration/` : tests de bout en bout (pipeline complet, coherence entrees/sorties).

## Convention

- Chaque script de test doit etre executable de facon autonome apres `projectStartup`.
- Nommer les scripts `test_<nom_fonction_ou_module>.m`.
- Un test qui passe ne doit produire aucune erreur MATLAB; un echec genere une `error(...)`.

## Execution rapide

```matlab
projectStartup
run('tests/unit/test_<nom>.m')
```

Pour lancer tous les tests d'un sous-dossier :

```matlab
results = runtests('tests/unit');
table(results)
```
