function save_last_simulation(label)
%SAVE_LAST_SIMULATION  Sauvegarde la derniere simulation depuis le workspace.
%
%   save_last_simulation()          — sauvegarde avec horodatage
%   save_last_simulation('label')   — ajoute un suffixe au nom de fichier
%
%   Necessite que 'out' ou 'simOut' soit present dans le base workspace
%   (toujours le cas apres runWorkflow).

if nargin < 1
    label = '';
end

thisFile    = mfilename('fullpath');
projectRoot = fileparts(fileparts(thisFile));

runtimeDir = fullfile(projectRoot, 'data', 'runtime');
historyDir = fullfile(runtimeDir, 'history');

if ~exist(runtimeDir, 'dir'), mkdir(runtimeDir); end
if ~exist(historyDir, 'dir'), mkdir(historyDir); end

% Recuperer les donnees depuis le base workspace
hasOut    = evalin('base', 'exist(''out'',    ''var'')');
hasSimOut = evalin('base', 'exist(''simOut'', ''var'')');

if ~hasOut && ~hasSimOut
    error('save_last_simulation:noData', ...
        'Aucune simulation trouvee dans le workspace (out / simOut manquant).');
end

out    = []; %#ok<NASGU>
simOut = [];

if hasSimOut
    simOut = evalin('base', 'simOut'); %#ok<NASGU>
end
if hasOut
    out = evalin('base', 'out'); %#ok<NASGU>
    if isempty(simOut)
        simOut = out; %#ok<NASGU>
    end
end

% Recuperer les options si presentes
options = struct(); %#ok<NASGU>
if evalin('base', 'exist(''options'', ''var'')')
    try
        options = evalin('base', 'options'); %#ok<NASGU>
    catch
    end
end

% Construire le nom de fichier
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
lbl       = lower(strtrim(label));
lbl       = regexprep(lbl, '[^a-z0-9_\-]+', '_');
lbl       = regexprep(lbl, '^_|_$', '');

if isempty(lbl)
    fname = sprintf('info_simulation_%s.mat', timestamp);
else
    fname = sprintf('info_simulation_%s_%s.mat', timestamp, lbl);
end

latestPath  = fullfile(runtimeDir, 'info_simulation.mat');
historyPath = fullfile(historyDir, fname);

save(latestPath,  'simOut', 'out', 'options');
save(historyPath, 'simOut', 'out', 'options');

fprintf('Simulation sauvegardee :\n');
fprintf('  Derniere : %s\n', latestPath);
fprintf('  Historique : %s\n', historyPath);
end
