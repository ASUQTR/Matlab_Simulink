function create_sldd()
% Cree model/AUV_Params.sldd depuis params_nominal().
% A executer une seule fois lors du setup initial du projet.
%
% Usage:
%   create_sldd()
%
% Pour changer de calibration apres la creation: utiliser set_config().
% Pour recreer le SLDD depuis zero: supprimer model/AUV_Params.sldd puis relancer.

thisFile    = mfilename('fullpath');
projectRoot = fileparts(fileparts(thisFile));   % tools/ -> root
slddPath    = fullfile(projectRoot, 'model', 'AUV_Params.sldd');

if exist(slddPath, 'file')
    fprintf('SLDD deja present: %s\n', slddPath);
    fprintf('Pour changer de calibration : set_config(''nominal''|''emile''|''originaux'')\n');
    fprintf('Pour recreer depuis zero    : supprimer le fichier puis relancer create_sldd()\n');
    return
end

% Fermer tout dictionnaire ouvert pour eviter les conflits
Simulink.data.dictionary.closeAll('-discard');

% Creer le dictionnaire
d     = Simulink.data.dictionary.create(slddPath);
dSect = getSection(d, 'Design Data');

% Charger les parametres nominaux et les ecrire dans le SLDD
p      = params_nominal();
fields = fieldnames(p);
for i = 1:numel(fields)
    val = p.(fields{i});
    addEntry(dSect, fields{i}, Simulink.Parameter(val));
end

saveChanges(d);

fprintf('SLDD cree : %s\n', slddPath);
fprintf('\nEtape suivante — lier le modele au SLDD dans MATLAB :\n');
fprintf('  load_system(''model/Modele_LQR_6DOF'');\n');
fprintf('  set_param(''Modele_LQR_6DOF'', ''DataDictionary'', ''AUV_Params.sldd'');\n');
fprintf('  save_system(''model/Modele_LQR_6DOF'');\n');
end
