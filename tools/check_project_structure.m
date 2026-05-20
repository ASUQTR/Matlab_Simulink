function report = check_project_structure(projectRoot)
%CHECK_PROJECT_STRUCTURE Validate the expected MATLAB/Simulink layout.
%   report = check_project_structure()
%   report = check_project_structure(projectRoot)
%
%   This utility is intentionally non-destructive: it only reports missing
%   folders/files and workflow hygiene warnings.

if nargin < 1 || isempty(projectRoot)
    projectRoot = fileparts(fileparts(mfilename('fullpath')));
end

requiredDirs = {
    'model'
    fullfile('model', 'callbacks')
    'scripts'
    fullfile('scripts', 'modeling')
    fullfile('scripts', 'analysis')
    fullfile('scripts', 'validation')
    fullfile('scripts', 'config')
    'data'
    fullfile('data', 'formes')
    fullfile('data', 'generated')
    fullfile('data', 'runtime')
    fullfile('data', 'experiments')
    'docs'
    'archive'
    fullfile('archive', 'models')
    fullfile('archive', 'scripts')
    'resources'
    'tools'
    'tests'
    };

requiredFiles = {
    'README.md'
    'ONBOARDING.md'
    'PROJECT_MAP.md'
    'runWorkflow.m'
    'ASUQTR_Control.prj'
    fullfile('docs', 'PROJECT_SETUP.md')
    fullfile('tools', 'projectStartup.m')
    fullfile('model', 'Modele_LQR_6DOF.slx')
    fullfile('model', 'callbacks', 'Parameters.m')
    fullfile('data', 'formes', 'sous marin en pentagone.mat')
    };

generatedArtifacts = {
    fullfile('data', 'generated', 'ABmatrice.mat')
    fullfile('data', 'generated', 'calcul_Q.mat')
    fullfile('data', 'generated', 'Matrice_A_lineaire.mat')
    };

allowedRootEntries = {
    'README.md'
    'ONBOARDING.md'
    'PROJECT_MAP.md'
    'runWorkflow.m'
    'ASUQTR_Control.prj'
    '.git'
    '.gitignore'
    '.gitattributes'
    'archive'
    'codegen'
    'data'
    'docs'
    'model'
    'resources'
    'scripts'
    'sim_cache'
    'slprj'
    'tests'
    'tools'
    };

report = struct();
report.projectRoot = projectRoot;
report.missingDirs = find_missing(projectRoot, requiredDirs, true);
report.missingFiles = find_missing(projectRoot, requiredFiles, false);
report.missingGeneratedArtifacts = find_missing(projectRoot, generatedArtifacts, false);
report.rootNoise = find_root_noise(projectRoot, allowedRootEntries);
report.warnings = {};

prjPath = fullfile(projectRoot, 'ASUQTR_Control.prj');
if exist(prjPath, 'file')
    prjInfo = dir(prjPath);
else
    prjInfo = [];
end
if ~isempty(prjInfo) && prjInfo.bytes < 500
    report.warnings{end + 1} = 'ASUQTR_Control.prj exists but looks minimal; configure Project startup/path settings in MATLAB before sharing.';
end

print_report(report);

end

function missing = find_missing(projectRoot, relativePaths, expectDir)
missing = {};
for i = 1:numel(relativePaths)
    candidate = fullfile(projectRoot, relativePaths{i});
    if expectDir
        exists = isfolder(candidate);
    else
        exists = exist(candidate, 'file') == 2;
    end
    if ~exists
        missing{end + 1} = relativePaths{i}; %#ok<AGROW>
    end
end
end

function noise = find_root_noise(projectRoot, allowedEntries)
noise = {};
entries = dir(projectRoot);
for i = 1:numel(entries)
    name = entries(i).name;
    if strcmp(name, '.') || strcmp(name, '..')
        continue;
    end
    if ~any(strcmp(name, allowedEntries))
        noise{end + 1} = name; %#ok<AGROW>
    end
end
end

function print_report(report)
fprintf('Project structure check: %s\n', report.projectRoot);
print_list('Missing required folders', report.missingDirs);
print_list('Missing required files', report.missingFiles);
print_list('Missing generated artifacts', report.missingGeneratedArtifacts);
print_list('Unexpected root entries', report.rootNoise);
print_list('Warnings', report.warnings);

if isempty(report.missingDirs) && isempty(report.missingFiles)
    fprintf('Core layout: OK\n');
else
    fprintf('Core layout: needs attention\n');
end
end

function print_list(label, values)
if isempty(values)
    fprintf('%s: none\n', label);
    return;
end

fprintf('%s:\n', label);
for i = 1:numel(values)
    fprintf(' - %s\n', values{i});
end
end
