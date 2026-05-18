# Model Callbacks

Ce dossier contient les scripts executes par le modele Simulink lors de l'ouverture ou du lancement.

## Contenu

- `Parameters.m` : initialise les parametres physiques, ajoute les chemins utiles et charge les matrices requises.

## Role

Le callback garantit qu'un utilisateur qui ouvre le modele sans preparation manuelle obtient un environnement coherent.

## Dependances

- Lit des fichiers dans `data/generated/`.
- Verifie les donnees de simulation dans `data/formes/`.

## Regle

Si vous ajoutez un nouveau fichier requis au demarrage du modele, documentez-le ici et dans `data/README.md`.
