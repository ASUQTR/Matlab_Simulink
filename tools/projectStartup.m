function projectStartup()
%PROJECTSTARTUP Add project folders to path and perform basic checks.
%   Called automatically by MATLAB Project Task Automation on project open.
%   Can also be called manually: run(fullfile('tools','projectStartup.m'))

% This file lives in tools/ — go up one level to reach the project root
thisFile = mfilename('fullpath');
if isempty(thisFile)
    projectRoot = fileparts(pwd);
else
    projectRoot = fileparts(fileparts(thisFile));
end

% Folders to add to path
scriptsDir = fullfile(projectRoot, 'scripts');
simDir     = fullfile(projectRoot, 'data', 'formes');
genDir     = fullfile(projectRoot, 'data', 'generated');
toolsDir   = fullfile(projectRoot, 'tools');
modelDir   = fullfile(projectRoot, 'model');

if isfolder(scriptsDir)
    addpath(genpath(scriptsDir));
end
if isfolder(simDir) && ~contains(path, simDir)
    addpath(simDir);
end
if isfolder(genDir) && ~contains(path, genDir)
    addpath(genDir);
end
if isfolder(toolsDir) && ~contains(path, toolsDir)
    addpath(toolsDir);
end
if isfolder(modelDir) && ~contains(path, modelDir)
    addpath(modelDir);
end

% Redirect Simulink cache and codegen away from the project root
Simulink.fileGenControl('set', ...
    'CacheFolder',   fullfile(projectRoot, 'sim_cache'), ...
    'CodeGenFolder', fullfile(projectRoot, 'codegen'));

fprintf('projectStartup: paths configured from %s\n', projectRoot);

% Basic checks (non-fatal)
sigPath = fullfile(simDir, 'sous marin en pentagone.mat');
if ~exist(sigPath, 'file')
    warning('projectStartup:MissingSignal', 'Simulation signal missing: %s', sigPath);
end

end
