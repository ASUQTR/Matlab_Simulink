function apply_compute_K()
% Met a jour le code du bloc MATLAB Function "compute_K" dans le .slx.
% A executer apres chaque modification de model/block_compute_K.m.
%
% Usage : apply_compute_K()

modelName = 'Modele_LQR_6DOF';
blockPath = [modelName '/Controller/compute_K'];
codeFile  = fullfile(fileparts(mfilename('fullpath')), '..', 'model', 'block_compute_K.m');

if ~isfile(codeFile)
    error('Fichier source introuvable : %s', codeFile);
end

wasLoaded = bdIsLoaded(modelName);
if ~wasLoaded
    load_system(modelName);
end

rt     = sfroot();
charts = rt.find('-isa', 'Stateflow.EMChart');
chart  = [];
for i = 1:numel(charts)
    if contains(charts(i).Script, 'function K = compute_K')
        chart = charts(i);
        break;
    end
end
if isempty(chart)
    error('Bloc compute_K introuvable dans le modele charge.');
end
fprintf('Bloc trouve : %s\n', chart.Path);

chart.Script = fileread(codeFile);
fprintf('compute_K : code mis a jour.\n');

save_system(modelName);
fprintf('Modele sauvegarde.\n');

if ~wasLoaded
    close_system(modelName, 0);
end

fprintf('\nIMPORTANT : un nouveau port "dt" est apparu sur le bloc compute_K.\n');
fprintf('Ajouter un bloc Constant (valeur = Ts) et le connecter au port dt.\n');

end
