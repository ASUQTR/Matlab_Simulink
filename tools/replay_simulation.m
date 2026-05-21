function replay_simulation(matFilePath)
%REPLAY_SIMULATION  Recharge une simulation sauvegardee et rejoue les analyses.
%
%   replay_simulation()           — ouvre un selecteur de fichier
%   replay_simulation('path.mat') — charge directement le fichier

thisFile    = mfilename('fullpath');
projectRoot = fileparts(fileparts(thisFile));   % tools/ -> root

% --- Selectionner le fichier ---
if nargin < 1 || isempty(matFilePath)
    historyDir = fullfile(projectRoot, 'data', 'runtime', 'history');
    startDir   = historyDir;
    if ~exist(historyDir, 'dir')
        startDir = fullfile(projectRoot, 'data', 'runtime');
    end

    [fname, fpath] = uigetfile('*.mat', 'Choisir une simulation a rejouer', startDir);
    if isequal(fname, 0)
        fprintf('replay_simulation: annule.\n');
        return;
    end
    matFilePath = fullfile(fpath, fname);
end

if ~exist(matFilePath, 'file')
    error('replay_simulation:notFound', 'Fichier introuvable : %s', matFilePath);
end

% --- Charger ---
fprintf('\nChargement : %s\n', matFilePath);
data = load(matFilePath);

if ~isfield(data, 'out') && ~isfield(data, 'simOut')
    error('replay_simulation:invalidFile', ...
        'Le fichier ne contient pas de donnees de simulation valides (out / simOut manquant).');
end

% Injecter dans le base workspace
if isfield(data, 'simOut')
    assignin('base', 'simOut', data.simOut);
    assignin('base', 'out',    data.simOut);
end
if isfield(data, 'out')
    assignin('base', 'out', data.out);
end

% --- Afficher le resume des options ---
if isfield(data, 'options')
    o = data.options;
    fprintf('--- Parametres de la simulation ---\n');
    if isfield(o, 'stopTime'),        fprintf('  Duree      : %g s\n',  o.stopTime);        end
    if isfield(o, 'simulationLabel') && ~isempty(o.simulationLabel)
                                      fprintf('  Label      : %s\n',    o.simulationLabel);  end
    fprintf('-----------------------------------\n');
end

% --- Rejouer les analyses ---
run(fullfile(projectRoot, 'scripts', 'analysis', 'Graphique.m'));
run(fullfile(projectRoot, 'scripts', 'analysis', 'instabiliter_graphique.m'));

if isfield(data, 'out')
    out = data.out; %#ok<NASGU>
    try
        report_instabilities(out);
    catch
    end
end

fprintf('replay_simulation: termine.\n');
end
