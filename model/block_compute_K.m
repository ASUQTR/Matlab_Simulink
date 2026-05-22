% =========================================================
% BLOC SIMULINK : compute_K
% Entrees : A                  (12x12) — depuis linearize_A
%           Q_files            (12x12) — workspace : Q_envoyer
%           CONTROL_METHOD_NUM (1x1)   — workspace : CONTROL_METHOD_NUM
%           K_fixed            (8x12)  — workspace : K
%           t                  (1x1)   — depuis bloc Clock
% Sortie  : K                  (8x12)
%
% Coller ce code directement dans le MATLAB Function block.
% =========================================================

function K = compute_K(A, Q_files, CONTROL_METHOD_NUM, K_fixed, t)

K = zeros(8, 12);

if CONTROL_METHOD_NUM == 1
    K = K_fixed;
else
    K = gain_scheduling(A, Q_files, t);
end

end

% ---------------------------------------------------------

function K = gain_scheduling(A, Q_files, t)
% Resout l'equation de Riccati en temps reel (Euler avant).
% Equivalent a l'ancien mRiccati + integrateur, sans appel extrinsic.

persistent P t_prev;

B = get_B();
Q = diag(diag(Q_files));
R = 10 * eye(8);

if isempty(P)
    % Condition initiale : P = Q (symetrique definie positive, convergence rapide)
    P      = Q;
    t_prev = t;
end

dt = t - t_prev;
t_prev = t;

if dt > 0
    % dP/dt = A'P + PA - PB R^{-1} B'P + Q  (equation de Riccati continue)
    P_dot = A'*P + P*A - P*B*(R\(B'*P)) + Q;
    P = P + dt * P_dot;
    P = (P + P') / 2;  % forcer la symetrie (evite la derive numerique)
end

% K = R^{-1} B' P
K = R \ (B' * P);

end

% ---------------------------------------------------------

function B = get_B()
% Matrice d'entree B — constante (independante de l'etat).

B = [...
[                                          0,                                            0,              0,              0,             0,             0,                                            0,                                           0]; ...
[                                          0,                                            0,              0,              0,             0,             0,                                            0,                                           0]; ...
[                                          0,                                            0,              0,              0,             0,             0,                                            0,                                           0]; ...
[                                          0,                                            0,              0,              0,             0,             0,                                            0,                                           0]; ...
[                                          0,                                            0,              0,              0,             0,             0,                                            0,                                           0]; ...
[                                          0,                                            0,              0,              0,             0,             0,                                            0,                                           0]; ...
[                                  -707/6950,                                    -707/6950,              0,              0,             0,             0,                                     707/6950,                                    707/6950]; ...
[                                   707/6950,                                    -707/6950,              0,              0,             0,             0,                                     707/6950,                                   -707/6950]; ...
[                                          0,                                            0,        -20/139,        -20/139,       -20/139,       -20/139,                                            0,                                           0]; ...
[                                          0,                                            0,  -130255/80342,   130255/80342, -130255/80342,  130255/80342,                                            0,                                           0]; ...
[                                          0,                                            0, -256447/448275, -256447/448275, 256447/448275, 256447/448275,                                            0,                                           0]; ...
[194698457386957391875/146640581566903877632, -194698457386957391875/146640581566903877632,              0,              0,             0,             0, -194698457386957391875/146640581566903877632, 194698457386957391875/146640581566903877632]];

end
