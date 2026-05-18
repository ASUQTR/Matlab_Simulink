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
%     runMouvement   - true/false, run scripts/analysis/mouvement.m (default: true)
%     runStability   - true/false, run scripts/analysis/instabiliter_graphique.m (default: true)
%     reportInstability - true/false, print instability times and summary (default: true)
%     openModel      - true/false, open model before simulating (default: false)
%     showFigures    - true/false, display figures while running analysis (default: true)
%     saveFigures    - true/false, save all open figures in figureOutputDir (default: false)
%     figureOutputDir - folder where figures are saved (default: 'docs/figures')
%     figureFormat   - figure extension for saveas (default: 'png')
%     closeFiguresAfterSave - close figures after saving (default: false)

if nargin < 1
    options = struct();
end

projectStartup();

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
    options.runMouvement = true;
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
if ~isfield(options,'figureFormat') || isempty(options.figureFormat)
    options.figureFormat = 'png';
end
if ~isfield(options,'closeFiguresAfterSave')
    options.closeFiguresAfterSave = false;
end

projectRoot = fileparts(mfilename('fullpath'));
modelPath = fullfile(projectRoot, options.modelName);
figureOutputDir = fullfile(projectRoot, options.figureOutputDir);

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

if options.runGraphique
    run(fullfile(projectRoot, 'scripts', 'analysis', 'Graphique.m'));
end

if options.runMouvement
    run(fullfile(projectRoot, 'scripts', 'analysis', 'mouvement.m'));
end

if options.runStability
    run(fullfile(projectRoot, 'scripts', 'analysis', 'instabiliter_graphique.m'));
end

if options.reportInstability
    report_instabilities(out);
end

if options.saveFigures
    save_open_figures(figureOutputDir, options.figureFormat, options.closeFiguresAfterSave);
end

end

function save_open_figures(outputDir, formatExt, closeAfterSave)
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
    try
        if isprop(fig, 'Number')
            figName = sprintf('figure_%02d.%s', fig.Number, formatExt);
        else
            figName = sprintf('figure_%02d.%s', i, formatExt);
        end
        saveas(fig, fullfile(outputDir, figName));
    catch err
        warning('runWorkflow:saveFigure', 'Could not save figure %d: %s', i, err.message);
    end
end

fprintf('Saved %d figure(s) to %s\n', numel(figs), outputDir);

if closeAfterSave
    close(figs);
end
end
