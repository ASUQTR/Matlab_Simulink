function set_config(variant)
% Change la calibration active dans AUV_Params.sldd.
%
% Usage:
%   set_config('nominal')    — valeurs mesurees 2026 (defaut git)
%   set_config('emile')      — variante inertie calculee par Emile
%   set_config('originaux')  — modele theorique initial (avant mesures)
%   set_config()             — affiche les variantes disponibles
%
% Note: le SLDD doit exister (lancer create_sldd() au besoin).
% Convention git: la version committee du SLDD = nominal.

if nargin < 1
    fprintf('Calibrations disponibles :\n');
    fprintf('  set_config(''nominal'')    — valeurs mesurees 2026\n');
    fprintf('  set_config(''emile'')      — variante inertie Emile\n');
    fprintf('  set_config(''originaux'')  — modele theorique initial\n');
    return
end

thisFile    = mfilename('fullpath');
projectRoot = fileparts(fileparts(thisFile));   % tools/ -> root
slddPath    = fullfile(projectRoot, 'model', 'AUV_Params.sldd');

if ~exist(slddPath, 'file')
    error('set_config:noSldd', ...
        'AUV_Params.sldd introuvable.\nExecuter create_sldd() dabord.');
end

% Charger la variante demandee
fn = str2func(['params_' variant]);
p  = fn();

% Mettre a jour les entrees du SLDD
d     = Simulink.data.dictionary.open(slddPath);
dSect = getSection(d, 'Design Data');

fields = fieldnames(p);
for i = 1:numel(fields)
    val = p.(fields{i});
    if existEntry(dSect, fields{i})
        entry = getEntry(dSect, fields{i});
        setValue(entry, Simulink.Parameter(val));
    else
        addEntry(dSect, fields{i}, Simulink.Parameter(val));
    end
end

saveChanges(d);
fprintf('Calibration active : params_%s\n', variant);
end
