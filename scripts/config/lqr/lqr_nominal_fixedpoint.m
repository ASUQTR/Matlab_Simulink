function cfg = lqr_nominal_fixedpoint()
%LQR_NOMINAL_FIXEDPOINT  Contrôleur nominal — gain fixe au point d'équilibre.
%
%   cfg = lqr_nominal_fixedpoint()
%
%   MÉTHODE : 'fixed_point'
%     K est calculé UNE SEULE FOIS au point d'opération défini dans cfg.op,
%     puis utilisé comme gain constant pendant toute la simulation.
%     Plus simple à analyser, mais peut diverger loin du point de linéarisation.
%
%   Différence vs lqr_nominal :
%     lqr_nominal          → gain scheduling (K varie, Riccati à chaque pas)
%     lqr_nominal_fixedpoint → K constant    (Riccati résolu une seule fois)
%
%   Pour générer le gain K : compute_controller('nominal_fixedpoint')
%   Cela produira data/generated/controller_nominal_fixedpoint.mat
%
%   NOTE : Pour que le modèle Simulink utilise ce K constant, un switch dans
%   le modèle doit lire la variable workspace CONTROL_METHOD = 'fixed_point'.
%   Ce switch n'est pas encore implémenté — voir TODO dans model/README.md.

%% Méthode de contrôle
cfg.method = 'fixed_point';

%% Point d'opération — utilisé pour linéariser A et calculer K
cfg.op.x     = 0;     cfg.op.y     = 0;     cfg.op.z     = 0;
cfg.op.roll  = 0;     cfg.op.pitch = 0;     cfg.op.yaw   = 0;
cfg.op.u     = 1;     cfg.op.v     = 1;     cfg.op.w     = 1;
cfg.op.p     = 0.25;  cfg.op.q     = 0.25;  cfg.op.r     = 0.25;
cfg.op.radius = 0.26;

%% Pondération actionneurs
cfg.R = 0.1 * eye(8);

%% Valeurs d'états pour la dérivation automatique de Q
%  Ordre : [x   y   z   roll  pitch  yaw  u  v  w  p  q  r]
cfg.q_state_vals = [0.1, 0.1, 0.1, 1, 1, 1, 1, 1, 1, 1, 1, 1];

end
