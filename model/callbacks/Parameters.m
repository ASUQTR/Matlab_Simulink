% Parameters.m — callback d'initialisation du modele Simulink.
% Les parametres physiques sont dans model/AUV_Params.sldd, lie au modele.
% Ce callback charge les matrices LQR de la variante de controleur active.
%
% Pour changer de calibration    : set_config('nominal'|'emile'|'originaux')
% Pour changer de controleur     : assignin('base','CONTROLLER_VARIANT','nominal')
% Pour (re)calculer un controleur: compute_controller('nominal')
% Pour creer le SLDD (1ere fois) : create_sldd()

projectRoot      = fileparts(fileparts(fileparts(mfilename('fullpath'))));
generatedDataDir = fullfile(projectRoot, 'data', 'generated');

if ~contains(path, generatedDataDir), addpath(generatedDataDir); end

% Determiner la variante active (defaut : 'nominal')
if evalin('base', 'exist(''CONTROLLER_VARIANT'', ''var'')')
    variant = evalin('base', 'CONTROLLER_VARIANT');
else
    variant = 'nominal';
end

ctrlPath = fullfile(generatedDataDir, sprintf('controller_%s.mat', variant));

if exist(ctrlPath, 'file')
    data    = load(ctrlPath, 'A_num', 'Q_final', 'method');
    A_num   = data.A_num;
    Q_final = data.Q_final;
    ctrl_method = data.method;
    fprintf('Parameters: controleur "%s" charge (methode : %s).\n', variant, ctrl_method);
else
    % Fallback : anciens fichiers legacy
    warning('Parameters:notFound', ...
        'controller_%s.mat introuvable — lancez compute_controller(''%s'').\nChargement des fichiers legacy.', ...
        variant, variant);
    load(fullfile(generatedDataDir, 'calcul_Q.mat'),          'Q_final');
    load(fullfile(generatedDataDir, 'Matrice_A_lineaire.mat'), 'A_num');
    ctrl_method = 'gain_scheduling';  % hypothese par defaut
end

assignin('base', 'Q_final',        Q_final);
assignin('base', 'A_num',          A_num);
assignin('base', 'Q_envoyer',      Q_final(:,:,1));
assignin('base', 'CONTROL_METHOD', ctrl_method);
