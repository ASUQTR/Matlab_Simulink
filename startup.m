% startup.m
% Fallback script: when this folder is on the MATLAB path at startup,
% MATLAB will run this file and it will call `projectStartup.m` if present.
% To enable on your machine:
%  - In MATLAB: addpath('c:\Programmation\ASUQTR\Matlab_Simulink'); savepath;
%  - Restart MATLAB and this script will run automatically.

try
    projFile = fullfile(fileparts(mfilename('fullpath')),'projectStartup.m');
    if exist(projFile,'file')
        run(projFile);
        fprintf('projectStartup executed from %s\n', projFile);
    else
        % No projectStartup found; nothing to do
    end
catch ME
    warning('startup:projectStartup','Error running projectStartup: %s', ME.message);
end
