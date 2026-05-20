% Parameters.m — callback d'initialisation du modele Simulink.
% Les parametres physiques sont dans model/AUV_Params.sldd, lie au modele.
% Ce callback charge uniquement les matrices LQR calculees.
%
% Pour changer de calibration : set_config('nominal'|'emile'|'originaux')
% Pour creer le SLDD (1ere fois) : create_sldd()

projectRoot      = fileparts(fileparts(fileparts(mfilename('fullpath'))));
generatedDataDir = fullfile(projectRoot, 'data', 'generated');

if ~contains(path, generatedDataDir), addpath(generatedDataDir); end

load(fullfile(generatedDataDir, 'calcul_Q.mat'),          'Q_final');
load(fullfile(generatedDataDir, 'Matrice_A_lineaire.mat'), 'A_num');

assignin('base', 'Q_final',   Q_final);
assignin('base', 'A_num',     A_num);
assignin('base', 'Q_envoyer', Q_final(:,:,1));
