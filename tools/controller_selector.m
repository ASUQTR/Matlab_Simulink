function controller_selector()
%CONTROLLER_SELECTOR  GUI de sélection et calcul du contrôleur LQR.
%
%   controller_selector()
%
%   Détecte automatiquement les fichiers lqr_*.m dans scripts/config/lqr/,
%   affiche le statut du .mat calculé et les paramètres clés de chaque variante.

thisFile    = mfilename('fullpath');
projectRoot = fileparts(fileparts(thisFile));
lqrDir      = fullfile(projectRoot, 'scripts', 'config', 'lqr');
genDir      = fullfile(projectRoot, 'data', 'generated');

if ~contains(path, lqrDir), addpath(lqrDir); end
if ~contains(path, fileparts(thisFile)), addpath(fileparts(thisFile)); end

% --- Détecter les variantes disponibles ---
files = dir(fullfile(lqrDir, 'lqr_*.m'));
if isempty(files)
    errordlg('Aucun fichier lqr_*.m trouvé dans scripts/config/lqr/', 'Erreur');
    return;
end
variants = cellfun(@(f) regexprep(f, '^lqr_|\.m$', ''), {files.name}, 'UniformOutput', false);

% Variante active dans le workspace
try
    activeVariant = evalin('base', 'CONTROLLER_VARIANT');
catch
    activeVariant = 'nominal';
end

% --- Fenêtre ---
fig = uifigure('Name', 'Contrôleur LQR — AUV ASUQTR', ...
    'Position', [540 200 320 420], 'Resize', 'off');

uilabel(fig, 'Text', 'Sélection du contrôleur LQR', ...
    'Position', [20 390 280 22], 'FontWeight', 'bold', 'FontSize', 12);

uilabel(fig, 'Text', 'Variante de contrôleur', ...
    'Position', [20 362 280 18], 'FontColor', [0.4 0.4 0.4], 'FontSize', 10);

ddVariant = uidropdown(fig, ...
    'Items',     variants, ...
    'ItemsData', variants, ...
    'Position',  [20 324 280 32], 'FontSize', 11);

if ismember(activeVariant, variants)
    ddVariant.Value = activeVariant;
end

% Statut du fichier .mat
lblStatus = uilabel(fig, ...
    'Text', '', ...
    'Position', [20 298 280 20], 'FontSize', 9);

% Zone d'information
uilabel(fig, 'Text', 'Paramètres de la variante', ...
    'Position', [20 278 280 16], 'FontColor', [0.35 0.35 0.35], ...
    'FontSize', 9, 'FontWeight', 'bold');

taInfo = uitextarea(fig, ...
    'Position',        [20 148 280 126], ...
    'FontSize',        9, ...
    'Editable',        'off', ...
    'BackgroundColor', [0.96 0.96 0.96]);

% --- Boutons ---
uibutton(fig, 'Text', 'Appliquer la variante', ...
    'Position', [20 100 280 36], 'FontSize', 11, ...
    'ButtonPushedFcn', @(~,~) appliquer(ddVariant.Value, false));

uibutton(fig, 'Text', 'Calculer et appliquer', ...
    'Position', [20 48 280 46], 'FontSize', 11, ...
    'BackgroundColor', [0.2 0.5 0.9], 'FontColor', 'white', ...
    'ButtonPushedFcn', @(~,~) appliquer(ddVariant.Value, true));

uilabel(fig, ...
    'Text', 'Editer lqr_<variante>.m pour modifier le point d''operation', ...
    'Position', [20 8 280 14], 'FontColor', [0.65 0.65 0.65], 'FontSize', 8, ...
    'HorizontalAlignment', 'center');

% --- Init ---
updateInfo(ddVariant.Value);
ddVariant.ValueChangedFcn = @(src, ~) updateInfo(src.Value);

% -----------------------------------------------------------------------
    function updateInfo(variant)
        ctrlPath = fullfile(genDir, sprintf('controller_%s.mat', variant));
        if exist(ctrlPath, 'file')
            d = dir(ctrlPath);
            lblStatus.Text      = sprintf('[OK]  controller_%s.mat  (%s)', ...
                variant, datestr(d.datenum, 'dd mmm yyyy HH:MM'));
            lblStatus.FontColor = [0.1 0.55 0.1];
        else
            lblStatus.Text      = sprintf('[!]  controller_%s.mat non calcule', variant);
            lblStatus.FontColor = [0.75 0.35 0.0];
        end

        try
            cfgFn = str2func(['lqr_' variant]);
            cfg   = cfgFn();
            op    = cfg.op;

            % Description de la méthode
            switch cfg.method
                case 'gain_scheduling'
                    methodDesc = 'Gain scheduling — Riccati resolu a chaque pas';
                    methodNote = '  K(t) varie. Point op. = verification pre-sim.';
                case 'fixed_point'
                    methodDesc = 'Point fixe — K constant calcule a cfg.op';
                    methodNote = '  Requiert switch CONTROL_METHOD dans le modele.';
                otherwise
                    methodDesc = cfg.method;
                    methodNote = '';
            end

            lines = {
                sprintf('Methode : %s', methodDesc);
                methodNote;
                '';
                'Point d''operation :';
                sprintf('  u=%.2g  v=%.2g  w=%.2g', op.u, op.v, op.w);
                sprintf('  p=%.3g  q=%.3g  r=%.3g', op.p, op.q, op.r);
                sprintf('  roll=%.3g  pitch=%.3g  yaw=%.3g', op.roll, op.pitch, op.yaw);
                '';
                sprintf('R = %.2g x I_8', cfg.R(1,1));
                '';
                'Q diagonal :';
                q_line(cfg);
            };
            taInfo.Value = lines;
        catch err
            taInfo.Value = {sprintf('Erreur lecture : %s', err.message)};
        end
    end

    function s = q_line(cfg)
        if isfield(cfg, 'Q')
            s = sprintf('  [%s]', num2str(diag(cfg.Q)', '%.4g '));
        elseif isfield(cfg, 'q_state_vals')
            s = sprintf('  q_state_vals: [%s]', num2str(cfg.q_state_vals, '%.2g '));
        else
            s = '  (non defini)';
        end
    end

    function appliquer(variant, recalculer)
        if recalculer
            try
                compute_controller(variant);
            catch err
                uialert(fig, err.message, 'Erreur calcul', 'Icon', 'error');
                return;
            end
        end
        assignin('base', 'CONTROLLER_VARIANT', variant);
        updateInfo(variant);
        if ~recalculer
            uialert(fig, ...
                sprintf('Variante "%s" appliquee.\nLe modele utilisera ce controleur au prochain lancement.', variant), ...
                'OK', 'Icon', 'success');
        end
    end

end
