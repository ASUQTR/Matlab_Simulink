function cfg = lqr_nominal()
%LQR_NOMINAL  Contrôleur nominal — gain scheduling, translation lente (2026).
%
%   cfg = lqr_nominal()
%
%   MÉTHODE : 'gain_scheduling'
%     Le modèle Simulink re-linéarise A autour de l'état courant x(t) à
%     chaque pas de temps et re-résout Riccati en continu.  K(t) varie
%     pendant la simulation.  Seuls Q et R influencent le comportement réel ;
%     le point d'opération sert uniquement à la vérification nominale pré-sim.
%
%   Pour une version à point fixe (K constant) : voir lqr_nominal_fixedpoint.m
%   Pour générer / vérifier le contrôleur    : compute_controller('nominal')
%
%   Champs retournés :
%     cfg.method        — 'gain_scheduling' | 'fixed_point'
%     cfg.op            — point d'opération (vérification externe uniquement)
%     cfg.R             — pondération actionneurs 8×8
%     cfg.q_state_vals  — vecteur [1×12] pour le calcul automatique de Q
%                         (méthode symbolique : Q = A'*B*B'*A évalué en q_state_vals)

%% Méthode de contrôle
cfg.method = 'gain_scheduling';

%% Point d'opération — utilisé uniquement pour la vérification nominale pré-sim
%  (pas utilisé par le modèle Simulink en mode gain_scheduling)
cfg.op.x     = 0;     cfg.op.y     = 0;     cfg.op.z     = 0;
cfg.op.roll  = 0;     cfg.op.pitch = 0;     cfg.op.yaw   = 0;
cfg.op.u     = 1;     cfg.op.v     = 1;     cfg.op.w     = 1;
cfg.op.p     = 0.25;  cfg.op.q     = 0.25;  cfg.op.r     = 0.25;
cfg.op.radius = 0.26;

%% Pondération actionneurs — influence directe sur le comportement en simulation
cfg.R = 0.1 * eye(8);

%% Valeurs d'états pour la dérivation automatique de Q
%  Méthode : Q_sym = A' * B * B' * A  (symbolique, R_design = I)
%  puis subs(Q_sym, vars, [q_state_vals, radius]) → Q_final
%  Ordre : [x   y   z   roll  pitch  yaw  u  v  w  p  q  r]
cfg.q_state_vals = [0.1, 0.1, 0.1, 1, 1, 1, 1, 1, 1, 1, 1, 1];

end
