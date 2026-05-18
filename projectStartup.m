function projectStartup()
%PROJECTSTARTUP Add project folders to path and perform basic checks
%   Run this at MATLAB startup or manually to setup paths for the project.

% Resolve project root (this file is at projectRoot/projectStartup.m)
thisFile = mfilename('fullpath');
if isempty(thisFile)
    % when running as script, try current folder
    projectRoot = pwd;
else
    projectRoot = fileparts(thisFile);
end

% expected layout
scriptsDir = fullfile(projectRoot,'scripts');
simDir     = fullfile(projectRoot,'data','formes');
genDir     = fullfile(projectRoot,'data','generated');

% Add to path
if isfolder(scriptsDir)
    addpath(genpath(scriptsDir));
end
if isfolder(simDir) && ~contains(path, simDir)
    addpath(simDir);
end
if isfolder(genDir) && ~contains(path, genDir)
    addpath(genDir);
end

fprintf('projectStartup: added paths (if present):\n - %s\n - %s\n - %s\n', scriptsDir, simDir, genDir);

% Basic checks (non-fatal warnings)
expectedSignals = {'sous marin en pentagone.mat'};
for i=1:numel(expectedSignals)
    if ~exist(fullfile(simDir, expectedSignals{i}),'file')
        warning('projectStartup:MissingSignal','Expected simulation signal missing: %s', fullfile(simDir, expectedSignals{i}));
    end
end

end
