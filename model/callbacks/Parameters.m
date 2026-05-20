% Parameters.m — callback d'initialisation du modele Simulink.
% Charge la calibration active et exporte les variables au base workspace.
%
% Pour changer de calibration : modifier la ligne params_nominal() ci-dessous
% par params_inertie_emile(), params_originaux(), ou toute autre variante
% definie dans scripts/config/.

projectRoot      = fileparts(fileparts(fileparts(mfilename('fullpath'))));
generatedDataDir = fullfile(projectRoot, 'data', 'generated');
simDataDir       = fullfile(projectRoot, 'data', 'formes');

if ~contains(path, generatedDataDir), addpath(generatedDataDir); end
if ~contains(path, simDataDir),       addpath(simDataDir);       end

if ~exist(fullfile(simDataDir, 'sous marin en pentagone.mat'), 'file')
    error('Fichier de trajectoire manquant : %s', fullfile(simDataDir, 'sous marin en pentagone.mat'));
end

%% --- Calibration active --- (changer ici pour switcher de config)
p = params_nominal();

%% Matrices LQR (generees par scripts/modeling/)
load(fullfile(generatedDataDir, 'calcul_Q.mat'),          'Q_final');
load(fullfile(generatedDataDir, 'Matrice_A_lineaire.mat'), 'A_num');
p.Q_final   = Q_final;
p.A_num     = A_num;
p.Q_envoyer = Q_final(:,:,1);

%% Exporter toutes les variables au base workspace pour Simulink
close all
fields = fieldnames(p);
for i = 1:numel(fields)
    assignin('base', fields{i}, p.(fields{i}));
end
