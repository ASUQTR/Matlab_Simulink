% create_matlab_project.m
% Run this script from MATLAB in the repository root to create a MATLAB
% project and set `projectStartup.m` as the startup file.
% Usage (in MATLAB):
%   cd('<path-to-repo>');
%   create_matlab_project

function create_matlab_project()
try
    if exist('matlab.project.createProject','file')
        p = matlab.project.createProject(pwd);
        % Try to set the startup script if present
        startupFile = fullfile(p.RootFolder, 'tools', 'projectStartup.m');
        if exist(startupFile,'file')
            try
                p.Startup = startupFile;
                fprintf('Project created at %s\nStartup set to %s\n', p.RootFolder, startupFile);
            catch err
                warning('Project created but could not set Startup: %s', err.message);
            end
        else
            fprintf('Project created at %s\nNote: tools/projectStartup.m not found. Add it manually via Project Settings > Task Automation.\n', p.RootFolder);
        end
    else
        error('MATLAB project API not available in this release. Create the project from the MATLAB GUI: Home → New → Project → From Folder...');
    end
catch e
    fprintf('Error creating project: %s\n', e.message);
    rethrow(e);
end
end
