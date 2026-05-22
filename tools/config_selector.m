function config_selector()
% Fenetre de configuration de la simulation AUV ASUQTR.
%
% Usage:
%   config_selector()

thisFile    = mfilename('fullpath');
projectRoot = fileparts(fileparts(thisFile));

% Valeurs par defaut selon la trajectoire [carre, cercle, lissajous]
stopDefaults = [120,  65, 130];
sizeDefaults = [2.0, 1.5, 2.0];

% Lire l'etat actuel du workspace
try
    trajInit = int32(evalin('base', 'TRAJECTOIRE'));
    if ~ismember(double(trajInit), [1 2 3]), trajInit = int32(1); end
catch
    trajInit = int32(1);
end
tIdx = double(trajInit);

try
    cv = char(evalin('base', 'CONTROLLER_VARIANT'));
catch
    cv = 'nominal';
end

% ── Fenetre ────────────────────────────────────────────────────────────
fig = uifigure('Name', 'Configuration AUV ASUQTR', ...
    'Position', [200 100 660 570], 'Resize', 'off');

% ── Titre ──────────────────────────────────────────────────────────────
uilabel(fig, 'Text', 'Configuration de la simulation', ...
    'Position', [20 538 620 22], 'FontWeight', 'bold', 'FontSize', 13);

% ══════════════════════════ COLONNE GAUCHE ════════════════════════════

% --- Section : Configuration physique ---
uilabel(fig, 'Text', 'CONFIGURATION PHYSIQUE', ...
    'Position', [20 514 300 18], 'FontWeight', 'bold', 'FontSize', 9, ...
    'FontColor', [0.25 0.25 0.65]);

uilabel(fig, 'Text', 'Calibration physique (AUV_Params.sldd)', ...
    'Position', [20 496 300 14], 'FontColor', [0.45 0.45 0.45], 'FontSize', 9);

ddCalib = uidropdown(fig, ...
    'Items',     {'Nominal — valeurs mesurees 2026 (defaut)', ...
                  'Emile  — variante inertie Emile', ...
                  'Originaux — modele theorique initial'}, ...
    'ItemsData', {'nominal', 'emile', 'originaux'}, ...
    'Position',  [20 460 300 32], 'FontSize', 10);

uibutton(fig, ...
    'Text', sprintf('Controleur LQR : %s     [modifier...]', cv), ...
    'Position', [20 418 190 36], 'FontSize', 10, ...
    'BackgroundColor', [0.91 0.94 0.99], ...
    'ButtonPushedFcn', @(~,~) controller_selector());

uibutton(fig, ...
    'Text', 'Editer config LQR', ...
    'Position', [215 418 105 36], 'FontSize', 10, ...
    'BackgroundColor', [0.95 0.95 0.95], ...
    'ButtonPushedFcn', @(~,~) editer_config_lqr());

% Separateur
uilabel(fig, 'Text', repmat(char(9472), 1, 38), ...
    'Position', [20 404 300 10], 'FontColor', [0.82 0.82 0.82], 'FontSize', 9);

% --- Section : Trajectoire ---
uilabel(fig, 'Text', 'TRAJECTOIRE', ...
    'Position', [20 382 300 18], 'FontWeight', 'bold', 'FontSize', 9, ...
    'FontColor', [0.25 0.25 0.65]);

uilabel(fig, 'Text', 'Trajectoire de reference', ...
    'Position', [20 364 300 14], 'FontColor', [0.45 0.45 0.45], 'FontSize', 9);

ddTraj = uidropdown(fig, ...
    'Items',     {'1 — Carre (defaut)', '2 — Cercle', '3 — Lissajous'}, ...
    'ItemsData', {int32(1), int32(2), int32(3)}, ...
    'Position',  [20 328 300 32], 'FontSize', 10);
ddTraj.Value = trajInit;

uilabel(fig, 'Text', 'Duree = 1 trajectoire (s)', ...
    'Position', [20 308 140 14], 'FontColor', [0.45 0.45 0.45], 'FontSize', 9);
uilabel(fig, 'Text', 'Rayon / Cote (m)', ...
    'Position', [165 308 140 14], 'FontColor', [0.45 0.45 0.45], 'FontSize', 9);

efStop = uieditfield(fig, 'numeric', ...
    'Value', stopDefaults(tIdx), 'Limits', [1 Inf], ...
    'Position', [20 276 130 28], 'FontSize', 10);
efSize = uieditfield(fig, 'numeric', ...
    'Value', sizeDefaults(tIdx), 'Limits', [0.01 Inf], ...
    'Position', [165 276 130 28], 'FontSize', 10);

ddTraj.ValueChangedFcn = @(src, ~) updateDefaults(src.Value, efStop, efSize);

try
    tsVal   = evalin('base', 'Ts');
    tsHint  = sprintf('0 = Ts du solver (%.4g s = %g Hz)', tsVal, 1/tsVal);
catch
    tsHint  = '0 = Ts du solver';
end
uilabel(fig, 'Text', sprintf('Frequence de boucle (Hz)   [%s]', tsHint), ...
    'Position', [20 254 300 14], 'FontColor', [0.45 0.45 0.45], 'FontSize', 9);

efStep = uieditfield(fig, 'numeric', ...
    'Value', 0, 'Limits', [0 10000], ...
    'Position', [20 222 130 28], 'FontSize', 10);

ckYaw = uicheckbox(fig, ...
    'Text',     'Pointer vers la cible (yaw — necessite LQR adapte)', ...
    'Value',    false, ...
    'Position', [20 190 300 24], 'FontSize', 9);

try
    if int32(evalin('base', 'YAW_MODE')) == int32(1)
        ckYaw.Value = true;
    end
catch
end

% ══════════════════════════ COLONNE DROITE ════════════════════════════

% --- Section : Affichages ---
uilabel(fig, 'Text', 'AFFICHAGES APRES SIMULATION', ...
    'Position', [360 514 280 18], 'FontWeight', 'bold', 'FontSize', 9, ...
    'FontColor', [0.25 0.25 0.65]);

ckAnim = uicheckbox(fig, ...
    'Text',  'Animation 3D (mouvement.m)', ...
    'Value', false, ...
    'Position', [360 488 280 22], 'FontSize', 10);

ckStab = uicheckbox(fig, ...
    'Text',  'Analyse de stabilite (poles LQR)', ...
    'Value', false, ...
    'Position', [360 462 280 22], 'FontSize', 10);

% ══════════════════════════ BOUTONS PRINCIPAUX ════════════════════════

uibutton(fig, ...
    'Text', 'Appliquer la configuration', ...
    'Position', [20 150 620 36], 'FontSize', 11, ...
    'ButtonPushedFcn', @(~,~) appliquer( ...
        ddCalib.Value, ddTraj.Value, efStop.Value, efSize.Value, ...
        efStep.Value, ckYaw.Value, ckAnim.Value, ckStab.Value, false));

uibutton(fig, ...
    'Text', 'Appliquer et lancer la simulation', ...
    'Position', [20 98 620 46], 'FontSize', 11, ...
    'BackgroundColor', [0.2 0.5 0.9], 'FontColor', 'white', ...
    'ButtonPushedFcn', @(~,~) appliquer( ...
        ddCalib.Value, ddTraj.Value, efStop.Value, efSize.Value, ...
        efStep.Value, ckYaw.Value, ckAnim.Value, ckStab.Value, true));

% ══════════════════════════ SECTION REJOUER ═══════════════════════════

uilabel(fig, 'Text', repmat(char(9472), 1, 90), ...
    'Position', [20 84 620 10], 'FontColor', [0.75 0.75 0.75], 'FontSize', 9, ...
    'HorizontalAlignment', 'center');

uibutton(fig, ...
    'Text', 'Rejouer une simulation sauvegardee...', ...
    'Position', [20 38 620 40], 'FontSize', 11, ...
    'BackgroundColor', [0.93 0.93 0.93], ...
    'ButtonPushedFcn', @(~,~) replay_simulation());

uilabel(fig, 'Text', 'Tip : save_last_simulation() pour sauvegarder apres run', ...
    'Position', [20 10 620 16], 'FontColor', [0.65 0.65 0.65], 'FontSize', 8, ...
    'HorizontalAlignment', 'center');

% ─────────────────────────── Callbacks ───────────────────────────────

    function editer_config_lqr()
        try
            variant = char(evalin('base', 'CONTROLLER_VARIANT'));
        catch
            variant = 'nominal';
        end
        lqrFile = fullfile(projectRoot, 'scripts', 'config', 'lqr', ['lqr_' variant '.m']);
        if ~isfile(lqrFile)
            uialert(fig, sprintf('Fichier introuvable :\n%s', lqrFile), 'Erreur', 'Icon', 'error');
            return;
        end
        edit(lqrFile);
    end

    function updateDefaults(trajVal, fStop, fSize)
        idx = max(1, min(3, double(int32(trajVal))));
        fStop.Value = stopDefaults(idx);
        fSize.Value = sizeDefaults(idx);
    end

    function appliquer(variant, trajVal, stopTime, sizeTraj, freqHz, useYaw, runAnim, runStab, simuler)
        try
            set_config(variant);
            assignin('base', 'TRAJECTOIRE', int32(trajVal));
            assignin('base', 'YAW_MODE',    int32(useYaw));
            assignin('base', 'T_TRAJ',      stopTime);
            assignin('base', 'SIZE_TRAJ',   sizeTraj);
        catch err
            uialert(fig, err.message, 'Erreur', 'Icon', 'error');
            return;
        end

        if simuler
            % Auto-calculer le controleur si le .mat n'existe pas encore
            try
                cv = char(evalin('base', 'CONTROLLER_VARIANT'));
            catch
                cv = 'nominal';
            end
            ctrlPath = fullfile(projectRoot, 'data', 'generated', ...
                sprintf('controller_%s.mat', cv));
            if ~isfile(ctrlPath)
                try
                    fprintf('controller_%s.mat absent — calcul automatique...\n', cv);
                    compute_controller(cv);
                catch err
                    uialert(fig, sprintf('Erreur calcul controleur "%s" :\n%s', cv, err.message), ...
                        'Erreur', 'Icon', 'error');
                    return;
                end
            end

            close(fig);
            opts = struct( ...
                'stopTime',          stopTime, ...
                'runMouvement',      runAnim, ...
                'runStability',      runStab, ...
                'reportInstability', runStab);
            if freqHz > 0
                opts.fixedStep = 1 / freqHz;
            end
            runWorkflow(opts);
        else
            if freqHz > 0
                freqStr = sprintf('%g Hz  (dt = %g s)', freqHz, 1/freqHz);
            else
                freqStr = 'auto';
            end
            uialert(fig, ...
                sprintf('Calibration : params_%s\nTrajectoire : %d\nDuree : %g s   Taille : %g m\nFrequence : %s\nYaw : %s   Animation : %s   Stabilite : %s', ...
                    variant, trajVal, stopTime, sizeTraj, freqStr, ...
                    mat2str(useYaw), mat2str(runAnim), mat2str(runStab)), ...
                'OK', 'Icon', 'success');
        end
    end

end
