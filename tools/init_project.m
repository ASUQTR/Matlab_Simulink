function init_project(varargin)
%INIT_PROJECT Initialize and verify the ASUQTR project (one-shot setup)
%   init_project              - Run all initialization steps
%   init_project('setup')     - Only create directories
%   init_project('cleanup')   - Only archive old files
%   init_project('verify')    - Only verify project integrity
%
%   This consolidates setup, cleanup, and verification into one function.

if nargin == 0
    mode = 'all';
else
    mode = varargin{1};
end

projectRoot = pwd;

%% PART 1: Setup Results Directories
if strcmp(mode, 'all') || strcmp(mode, 'setup')
    setup_results_directories(projectRoot);
end

%% PART 2: Cleanup & Archive
if strcmp(mode, 'all') || strcmp(mode, 'cleanup')
    cleanup_and_archive(projectRoot);
end

%% PART 3: Verify Project
if strcmp(mode, 'all') || strcmp(mode, 'verify')
    verify_project_integrity(projectRoot);
end

fprintf('\n✓ Project initialization complete!\n\n');

end

%% ========== PART 1: Setup ==========
function setup_results_directories(projectRoot)
fprintf('\n%s\n', repmat('=', 1, 60));
fprintf('ÉTAPE 1: Créer structure results/\n');
fprintf('%s\n', repmat('=', 1, 60));

resultsDirs = {
    'results'
    'results/figures'
    'results/figures/latest'
    'results/figures/archive'
    'results/reports'
};

for i = 1:numel(resultsDirs)
    dirPath = fullfile(projectRoot, resultsDirs{i});
    if ~isfolder(dirPath)
        mkdir(dirPath);
        fprintf('  ✓ Créé: %s\n', resultsDirs{i});
    else
        fprintf('  ✓ Existe: %s\n', resultsDirs{i});
    end
end
fprintf('\n');
end

%% ========== PART 2: Cleanup ==========
function cleanup_and_archive(projectRoot)
fprintf('%s\n', repmat('=', 1, 60));
fprintf('ÉTAPE 2: Archiver fichiers historiques\n');
fprintf('%s\n', repmat('=', 1, 60));

% Create archive structure
archiveDirs = {
    'archive/legacy_data'
    'archive/legacy_models'
    'archive/legacy_tests'
};

for i = 1:numel(archiveDirs)
    dirPath = fullfile(projectRoot, archiveDirs{i});
    if ~isfolder(dirPath)
        mkdir(dirPath);
        fprintf('  ✓ Créé: %s\n', archiveDirs{i});
    end
end

% Move old .mat files
oldMatFiles = {
    'data/generated/calcul_Q_possible1.mat'
    'data/generated/calcul_Q_possible2.mat'
    'data/generated/calcul_Q_possible3.mat'
    'data/generated/Q_test1.mat'
    'data/generated/signal1_test.mat'
};

fprintf('\nDéplacement données historiques:\n');
for i = 1:numel(oldMatFiles)
    srcPath = fullfile(projectRoot, oldMatFiles{i});
    [~, filename, ext] = fileparts(srcPath);
    dstPath = fullfile(projectRoot, 'archive/legacy_data', [filename ext]);
    
    if isfile(srcPath)
        movefile(srcPath, dstPath);
        fprintf('  ✓ %s\n', [filename ext]);
    end
end

% Move old Simulink models
oldModels = {
    'archive/Modele_LQR_3DOF.slx'
    'archive/LQR block.slx'
    'archive/Modele_LQR_6DOF.slx.r2020b'
    'archive/Modele_LQR_6DOF.slx.r2019b'
};

fprintf('\nDéplacement anciens modèles:\n');
for i = 1:numel(oldModels)
    srcPath = fullfile(projectRoot, oldModels{i});
    [~, filename, ext] = fileparts(srcPath);
    dstPath = fullfile(projectRoot, 'archive/legacy_models', [filename ext]);
    
    if isfile(srcPath)
        movefile(srcPath, dstPath);
        fprintf('  ✓ %s\n', [filename ext]);
    end
end

% Move old test scripts
testScripts = {
    'archive/testFinale.m'
    'archive/signal_de_controle.m'
    'archive/Calcul_Inertie.m'
};

fprintf('\nDéplacement anciens tests:\n');
for i = 1:numel(testScripts)
    srcPath = fullfile(projectRoot, testScripts{i});
    [~, filename, ext] = fileparts(srcPath);
    dstPath = fullfile(projectRoot, 'archive/legacy_tests', [filename ext]);
    
    if isfile(srcPath)
        if ~strcmp(srcPath, dstPath)
            movefile(srcPath, dstPath);
            fprintf('  ✓ %s\n', [filename ext]);
        end
    end
end

fprintf('\n');
end

%% ========== PART 3: Verify ==========
function verify_project_integrity(projectRoot)
fprintf('%s\n', repmat('=', 1, 60));
fprintf('ÉTAPE 3: Vérifier intégrité du projet\n');
fprintf('%s\n', repmat('=', 1, 60));

% Check directories
requiredDirs = {
    'model', 'scripts', 'scripts/modeling', 'scripts/analysis', 'scripts/validation'
    'scripts/config', 'data', 'data/generated', 'data/formes', 'tests', 'docs'
    'results', 'results/figures', 'results/figures/latest', 'archive'
};

fprintf('\nRépertoires:\n');
allDirsOk = true;
for i = 1:numel(requiredDirs)
    dirPath = fullfile(projectRoot, requiredDirs{i});
    if isfolder(dirPath)
        fprintf('  ✓ %s\n', requiredDirs{i});
    else
        fprintf('  ✗ %s (MANQUANT)\n', requiredDirs{i});
        allDirsOk = false;
    end
end

% Check critical files
criticalFiles = {
    'projectStartup.m', 'startup.m', 'runWorkflow.m'
    'model/Modele_LQR_6DOF.slx', 'model/callbacks/Parameters.m'
    'scripts/config/load_model_parameters.m'
};

fprintf('\nFichiers critiques:\n');
allFilesOk = true;
for i = 1:numel(criticalFiles)
    filePath = fullfile(projectRoot, criticalFiles{i});
    if isfile(filePath)
        fprintf('  ✓ %s\n', criticalFiles{i});
    else
        fprintf('  ✗ %s (MANQUANT)\n', criticalFiles{i});
        allFilesOk = false;
    end
end

% Summary
fprintf('\n%s\n', repmat('=', 1, 60));
if allDirsOk && allFilesOk
    fprintf('✓ Projet prêt!\n');
else
    fprintf('⚠ Vérifier les fichiers manquants ci-dessus\n');
end
fprintf('%s\n\n', repmat('=', 1, 60));
end
