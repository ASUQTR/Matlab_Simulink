function simOut = runWorkflow(options)
%RUNWORKFLOW Run the Simulink model and post-process plots in one step.
%   simOut = runWorkflow()
%   simOut = runWorkflow(options)
%
%   Options fields:
%     modelName      - Simulink model path or name (default: 'model/Modele_LQR_6DOF.slx')
%     stopTime       - Simulation stop time as number or string (default: 10)
%     runParameters  - true/false, execute model parameters script first (default: true)
%     runGraphique   - true/false, run scripts/analysis/Graphique.m (default: true)
%     runMouvement   - true/false, run scripts/analysis/mouvement.m (default: false)
%     runStability   - true/false, run scripts/analysis/instabiliter_graphique.m (default: true)
%     reportInstability - true/false, print instability times and summary (default: true)
%     openModel      - true/false, open model before simulating (default: false)
%     showFigures    - true/false, display figures while running analysis (default: true)
%     saveFigures    - true/false, save all open figures in figureOutputDir (default: false)
%     figureOutputDir - folder where figures are saved (default: 'docs/figures')
%     saveFigureFormats - cell array of formats to save (default: {'fig','png'})
%     figureFormat   - backward-compatible single format alias (default: 'png')
%     closeFiguresAfterSave - close figures after saving (default: false)
%     saveSimulationData - true/false, save simOut to data/runtime/info_simulation.mat (default: true)
%     saveSimulationHistory - true/false, save timestamped copies in data/runtime/history (default: true)
%     simulationLabel - optional text tag appended to history filenames (default: '')

if nargin < 1
    options = struct();
end

run(fullfile(fileparts(mfilename('fullpath')), 'tools', 'projectStartup.m'));

if ~isfield(options,'modelName') || isempty(options.modelName)
    options.modelName = fullfile('model','Modele_LQR_6DOF.slx');
end
if ~isfield(options,'stopTime') || isempty(options.stopTime)
    options.stopTime = 10;
end
if ~isfield(options,'runParameters')
    options.runParameters = true;
end
if ~isfield(options,'runGraphique')
    options.runGraphique = true;
end
if ~isfield(options,'runMouvement')
    options.runMouvement = false;
end
if ~isfield(options,'runStability')
    options.runStability = true;
end
if ~isfield(options,'reportInstability')
    options.reportInstability = true;
end
if ~isfield(options,'openModel')
    options.openModel = false;
end
if ~isfield(options,'showFigures')
    options.showFigures = true;
end
if ~isfield(options,'saveFigures')
    options.saveFigures = false;
end
if ~isfield(options,'figureOutputDir') || isempty(options.figureOutputDir)
    options.figureOutputDir = fullfile('docs','figures');
end
if isfield(options,'saveFigureFormats') && ~isempty(options.saveFigureFormats)
    options.saveFigureFormats = normalize_formats(options.saveFigureFormats);
elseif isfield(options,'figureFormat') && ~isempty(options.figureFormat)
    options.saveFigureFormats = normalize_formats(options.figureFormat);
else
    options.saveFigureFormats = {'fig', 'png'};
end
if ~isfield(options,'closeFiguresAfterSave')
    options.closeFiguresAfterSave = false;
end
if ~isfield(options,'saveSimulationData')
    options.saveSimulationData = true;
end
if ~isfield(options,'saveSimulationHistory')
    options.saveSimulationHistory = true;
end
if ~isfield(options,'simulationLabel') || isempty(options.simulationLabel)
    options.simulationLabel = '';
end

projectRoot = fileparts(mfilename('fullpath'));
modelPath = fullfile(projectRoot, options.modelName);
figureOutputDir = fullfile(projectRoot, options.figureOutputDir);
runtimeOutputDir = fullfile(projectRoot, 'data', 'runtime');
historyOutputDir = fullfile(runtimeOutputDir, 'history');

prevFigureVisibility = get(groot, 'DefaultFigureVisible');
restoreVisibility = onCleanup(@() set(groot, 'DefaultFigureVisible', prevFigureVisibility)); %#ok<NASGU>
if ~options.showFigures
    set(groot, 'DefaultFigureVisible', 'off');
end

if options.runParameters
    run(fullfile(projectRoot, 'model', 'callbacks', 'Parameters.m'));
end

load_system(modelPath);
if options.openModel
    open_system(modelPath);
end

simOut = sim(modelPath, 'StopTime', num2str(options.stopTime));
out = simOut; %#ok<NASGU>

if options.saveSimulationData || options.saveSimulationHistory
    save_simulation_data(simOut, options, runtimeOutputDir, historyOutputDir);
end

if options.runGraphique
    run(fullfile(projectRoot, 'scripts', 'analysis', 'Graphique.m'));
    if options.saveFigures
        save_open_figures(figureOutputDir, options.saveFigureFormats, options.closeFiguresAfterSave);
    end
end

if options.runMouvement
    run(fullfile(projectRoot, 'scripts', 'analysis', 'mouvement.m'));
end

if options.runStability
    run(fullfile(projectRoot, 'scripts', 'analysis', 'instabiliter_graphique.m'));
end

if options.reportInstability
    if isfield(out, 'A_s') && isfield(out, 'B_s') && isfield(out, 'K_s')
        report_instabilities(out);
    else
        fprintf('Stability report skipped: out.A_s / out.B_s / out.K_s not available.\n');
    end
end

end

function save_open_figures(outputDir, formats, closeAfterSave)
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

figs = findobj('Type', 'figure');
if isempty(figs)
    fprintf('No figures to save.\n');
    return;
end

figs = flipud(figs);
for i = 1:numel(figs)
    fig = figs(i);
    for fmtIdx = 1:numel(formats)
        formatExt = formats{fmtIdx};
        try
            if isprop(fig, 'Number')
                figBaseName = sprintf('figure_%02d', fig.Number);
            else
                figBaseName = sprintf('figure_%02d', i);
            end
            figPath = fullfile(outputDir, sprintf('%s.%s', figBaseName, formatExt));
            if strcmpi(formatExt, 'fig')
                savefig(fig, figPath);
            else
                saveas(fig, figPath);
            end
        catch err
            warning('runWorkflow:saveFigure', 'Could not save figure %d as %s: %s', i, formatExt, err.message);
        end
    end
end

fprintf('Saved %d figure(s) to %s as [%s]\n', numel(figs), outputDir, strjoin(formats, ', '));

if closeAfterSave
    close(figs);
end

end

function formats = normalize_formats(value)
if isstring(value)
    value = cellstr(value);
end
if ischar(value)
    formats = {lower(strtrim(value))};
elseif iscell(value)
    formats = cellfun(@(item) lower(strtrim(char(item))), value, 'UniformOutput', false);
else
    error('runWorkflow:invalidFigureFormat', 'saveFigureFormats must be a char, string, or cell array of formats.');
end
formats = formats(~cellfun('isempty', formats));
if isempty(formats)
    formats = {'fig', 'png'};
end
end

function save_simulation_data(simOut, options, runtimeOutputDir, historyOutputDir)
if ~exist(runtimeOutputDir, 'dir')
    mkdir(runtimeOutputDir);
end

out = simOut; %#ok<NASGU>
latestPath = fullfile(runtimeOutputDir, 'info_simulation.mat');

try
    save(latestPath, 'simOut', 'out', 'options');
    fprintf('Saved latest simulation data to %s\n', latestPath);
catch err
    warning('runWorkflow:saveSimulationData', 'Could not save latest simulation data: %s', err.message);
end

if ~options.saveSimulationHistory
    return;
end

if ~exist(historyOutputDir, 'dir')
    mkdir(historyOutputDir);
end

timestamp = datestr(now, 'yyyymmdd_HHMMSS');
label = sanitize_label(options.simulationLabel);
if isempty(label)
    historyFileName = sprintf('info_simulation_%s.mat', timestamp);
else
    historyFileName = sprintf('info_simulation_%s_%s.mat', timestamp, label);
end
historyPath = fullfile(historyOutputDir, historyFileName);

try
    save(historyPath, 'simOut', 'out', 'options');
    fprintf('Saved simulation history to %s\n', historyPath);
catch err
    warning('runWorkflow:saveSimulationHistory', 'Could not save simulation history: %s', err.message);
end

end

function label = sanitize_label(value)
label = lower(strtrim(char(value)));
label = regexprep(label, '[^a-z0-9_\-]+', '_');
label = regexprep(label, '_+', '_');
label = regexprep(label, '^_|_$', '');
end
