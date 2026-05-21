function compute_controller(variant)
%COMPUTE_CONTROLLER  Calcule le contrôleur LQR pour une variante et sauvegarde le résultat.
%
%   compute_controller()                     — variante 'nominal' par défaut
%   compute_controller('nominal')            — gain scheduling (Q_final + vérif. nominale)
%   compute_controller('nominal_fixedpoint') — K constant au point d'opération
%
%   DEUX MÉTHODES SUPPORTÉES selon cfg.method dans le fichier lqr_<variant>.m :
%
%   'gain_scheduling' (défaut)
%     Riccati est résolu à CHAQUE PAS DE TEMPS à l'intérieur du modèle Simulink,
%     en re-linéarisant A autour de l'état courant x(t).  K(t) varie pendant
%     la simulation.  Cette fonction calcule uniquement :
%       - Q_final  → chargé par Parameters.m, utilisé par Simulink à chaque pas
%       - K_nominal, A_num → vérification de stabilité au point nominal AVANT sim
%
%   'fixed_point'
%     K est calculé UNE SEULE FOIS au point cfg.op et utilisé comme gain constant.
%     Requiert un switch dans le modèle Simulink lisant CONTROL_METHOD (à venir).
%     Cette fonction calcule :
%       - A_num   → A linéarisé au point d'opération
%       - Q_final → matrice de coût
%       - K       → gain constant à appliquer
%
%   Lit  : scripts/config/lqr/lqr_<variant>.m
%          data/generated/ABmatrice.mat  (matrices A/B symboliques)
%   Écrit: data/generated/controller_<variant>.mat
%          data/generated/Matrice_A_lineaire.mat  (legacy — compatibilité)
%          data/generated/calcul_Q.mat            (legacy — compatibilité)

if nargin < 1
    variant = 'nominal';
end

projectRoot  = fileparts(fileparts(mfilename('fullpath')));
generatedDir = fullfile(projectRoot, 'data', 'generated');
lqrConfigDir = fullfile(projectRoot, 'scripts', 'config', 'lqr');

if ~contains(path, lqrConfigDir), addpath(lqrConfigDir); end
if ~contains(path, fileparts(mfilename('fullpath'))), addpath(fileparts(mfilename('fullpath'))); end

%% Charger la config de la variante
cfgFn = str2func(['lqr_' variant]);
try
    cfg = cfgFn();
catch
    error('compute_controller:unknownVariant', ...
        'Aucun fichier lqr_%s.m trouvé dans %s', variant, lqrConfigDir);
end

method = cfg.method;
fprintf('\n=== compute_controller(''%s'') — methode : %s ===\n', variant, method);

%% Charger les matrices symboliques A et B
abPath = fullfile(generatedDir, 'ABmatrice.mat');
if ~exist(abPath, 'file')
    error('compute_controller:missingAB', ...
        'ABmatrice.mat introuvable dans %s\nGenerez-le avec Generate_PyMatrix.m', generatedDir);
end
S = load(abPath);
A_sym = S.A;
B_sym = S.B;

%% Variables symboliques (ordre identique à ABmatrice.mat)
syms x y z roll_ pitch_ yaw_ u v w p q r radius

vars = [x y z roll_ pitch_ yaw_ u v w p q r radius];

%% Calcul de Q_final (commun aux deux méthodes)
Q_final = compute_Q_from_cfg(A_sym, B_sym, cfg, vars);

%% Branchement selon la méthode
switch method

    case 'gain_scheduling'
        % --------------------------------------------------------
        % Le modèle Simulink re-résout Riccati à chaque pas.
        % Ici on calcule uniquement A_num et K au point nominal
        % pour vérifier la stabilité AVANT de lancer la simulation.
        % --------------------------------------------------------
        fprintf('Q_final calcule pour usage par Simulink a chaque pas.\n');
        fprintf('Evaluation de A au point nominal pour verification...\n');

        op      = cfg.op;
        op_vals = [op.x op.y op.z op.roll op.pitch op.yaw ...
                   op.u op.v op.w op.p op.q op.r op.radius];
        A_num   = double(subs(A_sym, vars, op_vals));
        B_num   = double(B_sym);

        fprintf('Calcul du gain nominal K (verification pre-sim uniquement)...\n');
        K_nominal = lqr(A_num, B_num, Q_final, cfg.R);
        K         = K_nominal;

        check_stability(A_num, B_num, K, variant, '(point nominal)');

        fprintf('\nATTENTION : en gain_scheduling, K nominal est pour VERIFICATION seulement.\n');
        fprintf('Le modele Simulink calcule K(t) a chaque pas via Riccati interne.\n');

    case 'fixed_point'
        % --------------------------------------------------------
        % K est calculé une seule fois au point d'opération.
        % A utiliser quand le modèle Simulink est configuré pour
        % lire CONTROL_METHOD = ''fixed_point'' (switch a implémenter).
        % --------------------------------------------------------
        fprintf('Linearisation de A au point d''operation...\n');

        op      = cfg.op;
        op_vals = [op.x op.y op.z op.roll op.pitch op.yaw ...
                   op.u op.v op.w op.p op.q op.r op.radius];
        A_num   = double(subs(A_sym, vars, op_vals));
        B_num   = double(B_sym);

        fprintf('Calcul du gain K constant = lqr(A, B, Q, R)...\n');
        K = lqr(A_num, B_num, Q_final, cfg.R);

        check_stability(A_num, B_num, K, variant, '(point fixe)');

        fprintf('\nNOTE : K constant calcule. Le switch CONTROL_METHOD dans le modele\n');
        fprintf('Simulink n''est pas encore implemente — voir model/README.md.\n');

    otherwise
        error('compute_controller:unknownMethod', ...
            'Methode inconnue : "%s"\nValeurs valides : ''gain_scheduling'', ''fixed_point''', method);
end

%% Sauvegarde
if ~exist(generatedDir, 'dir'), mkdir(generatedDir); end

outPath = fullfile(generatedDir, sprintf('controller_%s.mat', variant));
save(outPath, 'A_num', 'B_num', 'Q_final', 'K', 'cfg', 'method');
fprintf('\nControleur "%s" sauvegarde : %s\n', variant, outPath);

%% Fichiers legacy (compatibilité avec l'ancien Parameters.m)
save(fullfile(generatedDir, 'Matrice_A_lineaire.mat'), 'A_num');
save(fullfile(generatedDir, 'calcul_Q.mat'), 'Q_final');
fprintf('Fichiers legacy mis a jour (Matrice_A_lineaire.mat, calcul_Q.mat).\n\n');

end

% -----------------------------------------------------------------------

function Q_final = compute_Q_from_cfg(A_sym, B_sym, cfg, vars)
%COMPUTE_Q_FROM_CFG  Dérive Q depuis la config ou le calcul symbolique.
    if isfield(cfg, 'Q') && ~isempty(cfg.Q)
        Q_final = cfg.Q;
        fprintf('Q fourni explicitement dans la config.\n');
    else
        fprintf('Calcul de Q par substitution symbolique (Q = A''*B*B''*A)...\n');
        Q_sym   = transpose(A_sym) * (B_sym * B_sym') * A_sym;
        q_vals  = [cfg.q_state_vals, cfg.op.radius];
        Q_final = double(subs(Q_sym, vars, q_vals));
    end
end

function check_stability(A_num, B_num, K, variant, label)
%CHECK_STABILITY  Affiche les pôles et un bilan de stabilité.
    poles      = eig(A_num - B_num * K);
    n_unstable = sum(real(poles) >= 0);
    if n_unstable > 0
        warning('compute_controller:unstable', ...
            '%d pole(s) instable(s) — variante "%s" %s', n_unstable, variant, label);
    else
        fprintf('Systeme stable %s — tous les poles a partie reelle negative.\n', label);
    end
end
