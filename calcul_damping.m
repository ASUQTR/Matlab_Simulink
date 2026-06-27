%% compute_damping.m
% Calcul des coefficients d'amortissement linéaire et quadratique
% selon Fossen (2011) - Handbook of Marine Craft Hydrodynamics and Motion Control
%
% Méthodes utilisées :
%   - Amortissement linéaire  : Section 6.4.1, équations 6.76 à 6.81
%   - Amortissement quadratique : Section 6.4.2 et 6.4.3 (traînée visqueuse)

clear all; close all; clc;

fprintf('=======================================================\n');
fprintf('  CALCUL DU DAMPING - Fossen 2011 (Sections 6.4.1-6.4.3)\n');
fprintf('=======================================================\n\n');

%% ============================================================
%  PARAMÈTRES DU SOUS-MARIN (tirés de ton code)
%% ============================================================

% --- Masse et inertie ---
mass = 23.9;        % [kg]
Ix   = 0.578;       % [kg·m²]
Iy   = 0.645;       % [kg·m²]
Iz   = 0.937;       % [kg·m²]

% --- Dimensions (demi-axes de l'ellipsoïde) ---
a = 0.30;   % demi-longueur X [m]
b = 0.25;   % demi-largeur  Y [m]
c = 0.17;   % demi-hauteur  Z [m]

% --- Fluide ---
rho = 1000.0;   % densité eau [kg/m³]
nu  = 1e-6;     % viscosité cinématique à 20°C [m²/s]

%% ============================================================
%  ÉTAPE 1 : MASSE AJOUTÉE (même calcul que dans ton code)
%  Coefficients de Lamb - ellipsoïde (Section 6.2)
%% ============================================================

e      = sqrt(1 - (b/a)^2);
alpha0 = (2*(1-e^2)/e^3) * (0.5*log((1+e)/(1-e)) - e);
beta0  = (1/e^2) - (1-e^2)/(2*e^3) * log((1+e)/(1-e));
k1     = alpha0 / (2 - alpha0);
k2     = beta0  / (2 - beta0);

Xu_dot = -k1 * mass;                   % masse ajoutée surge
Yv_dot = -k2 * mass;                   % masse ajoutée sway
Zw_dot = -k2 * mass;                   % masse ajoutée heave
Kp_dot = 0;                            % masse ajoutée roll (négligeable)
Mq_dot = -(0.2 * mass * (a^2 - b^2)^2 * (k2-k1) / max((a^2-b^2), 1e-9));
Nr_dot = -Mq_dot;                      % symétrie

% Masses effectives (masse + masse ajoutée)
m11 = mass + abs(Xu_dot);   % surge
m22 = mass + abs(Yv_dot);   % sway
m33 = mass + abs(Zw_dot);   % heave
m44 = Ix   + abs(Kp_dot);   % roll
m55 = Iy   + abs(Mq_dot);   % pitch
m66 = Iz   + abs(Nr_dot);   % yaw

fprintf('--- Masses ajoutées (Lamb, ellipsoïde) ---\n');
fprintf('  Xu_dot = %.4f kg\n', Xu_dot);
fprintf('  Yv_dot = %.4f kg\n', Yv_dot);
fprintf('  Zw_dot = %.4f kg\n', Zw_dot);
fprintf('  Mq_dot = %.4f kg·m²\n', Mq_dot);
fprintf('  Nr_dot = %.4f kg·m²\n\n', Nr_dot);

%% ============================================================
%  ÉTAPE 2 : AMORTISSEMENT LINÉAIRE
%  Section 6.4.1, Équations 6.76-6.81
%
%  Pour surge, sway, yaw (translation/rotation horizontale) :
%      B_iiv = (m_eff) / T_i  =  8*pi*zeta_i * m_eff / Tn_i
%
%  Pour heave, pitch, roll (oscillateurs) :
%      B_iiv = 2 * zeta_i * omega_n_i * m_eff
%% ============================================================

fprintf('--- AMORTISSEMENT LINÉAIRE (Section 6.4.1) ---\n');
fprintf('Méthode : constantes de temps (T) ou ratio d''amortissement (zeta)\n\n');

% ---- Choix des paramètres d'amortissement ----
% Pour un ROV/AUV : T est en secondes (bien plus court qu'un navire)
% Règle pratique de Fossen : T_surge,sway,yaw ~ 100-250 s pour navires
% Pour un petit sous-marin agile, on choisit des valeurs plus petites

% Option A : via constante de temps T [s]
T_surge = 1.0;   % [s] - ajuster selon comportement réel
T_sway  = 0.5;   % [s]
T_yaw   = 0.7;   % [s]

% Option B : via ratio d'amortissement zeta et fréquence naturelle [rad/s]
% (pour heave, roll, pitch — oscillateurs)
% Fréquences naturelles estimées (immersion totale => pas de flottabilité oscillante)
% On estime via omega_n = sqrt(restoring / m_eff) si applicable
% Pour un sous-marin immergé : heave/pitch/roll ont peu de raideur => on choisit zeta

zeta_heave = 0.7;    % [-] ratio d'amortissement heave
zeta_pitch = 0.7;    % [-] ratio d'amortissement pitch
zeta_roll  = 0.1;    % [-] ratio d'amortissement roll (Fossen: 0.05-0.10 typique)

% Fréquences naturelles estimées (approximation sans raideur hydrodynamique)
% Pour un sous-marin immergé, la raideur vient uniquement de la flottabilité
displaced_volume = 0.024;   % [m³] (valeur de ton code)
W  = mass * 9.81;
Fb = displaced_volume * rho * 9.81;
bz = 0.05;  % centre de flottabilité [m] (de ton code)

% Moment de rappel en roulis/tangage (raideur GZ)
% K_roll  ≈ (Fb - W)*bz  [N·m/rad] — approximation linéaire
% Pour un sous-marin légèrement positif ou neutre, on estime
K_roll  = abs(Fb * bz);           % [N·m] raideur roulis
K_pitch = abs(Fb * bz);           % [N·m] raideur tangage
K_heave = abs(Fb - W);            % [N]   raideur heave (différence poids/flottabilité)

omega_heave = sqrt(max(K_heave, 0.01) / m33);
omega_roll  = sqrt(max(K_roll,  0.01) / m44);
omega_pitch = sqrt(max(K_pitch, 0.01) / m55);

% ---- Calcul des coefficients linéaires (éqs. 6.76-6.81) ----

% Surge  (éq. 6.76) : B11v = m11 / T_surge
B11v = m11 / T_surge;
Xu   = -B11v;

% Sway   (éq. 6.77) : B22v = m22 / T_sway
B22v = m22 / T_sway;
Yv   = -B22v;

% Heave  (éq. 6.78) : B33v = 2*zeta_heave * omega_heave * m33
B33v = 2 * zeta_heave * omega_heave * m33;
Zw   = -B33v;

% Roll   (éq. 6.79) : B44v = 2*zeta_roll  * omega_roll  * m44
B44v = 2 * zeta_roll  * omega_roll  * m44;
Kp   = -B44v;

% Pitch  (éq. 6.80) : B55v = 2*zeta_pitch * omega_pitch * m55
B55v = 2 * zeta_pitch * omega_pitch * m55;
Mq   = -B55v;

% Yaw    (éq. 6.81) : B66v = m66 / T_yaw
B66v = m66 / T_yaw;
Nr   = -B66v;

fprintf('  T_surge = %.2f s  |  T_sway = %.2f s  |  T_yaw = %.2f s\n', T_surge, T_sway, T_yaw);
fprintf('  zeta_heave = %.2f | zeta_pitch = %.2f | zeta_roll = %.2f\n\n', zeta_heave, zeta_pitch, zeta_roll);
fprintf('  omega_heave = %.4f rad/s\n', omega_heave);
fprintf('  omega_roll  = %.4f rad/s\n', omega_roll);
fprintf('  omega_pitch = %.4f rad/s\n\n', omega_pitch);

fprintf('  Résultats amortissement LINÉAIRE :\n');
fprintf('  Xu  = %10.4f  (B11v = %.4f)\n', Xu,  B11v);
fprintf('  Yv  = %10.4f  (B22v = %.4f)\n', Yv,  B22v);
fprintf('  Zw  = %10.4f  (B33v = %.4f)\n', Zw,  B33v);
fprintf('  Kp  = %10.4f  (B44v = %.4f)\n', Kp,  B44v);
fprintf('  Mq  = %10.4f  (B55v = %.4f)\n', Mq,  B55v);
fprintf('  Nr  = %10.4f  (B66v = %.4f)\n\n', Nr, B66v);

%% ============================================================
%  ÉTAPE 3 : AMORTISSEMENT QUADRATIQUE
%  Section 6.4.2 (surge) et 6.4.3 (sway/heave/etc.)
%  Formule générale (éq. 6.55) :
%      f(u) = -1/2 * rho * CD * A * |u| * u
%  Donc :
%      X|u|u = -1/2 * rho * CD_x * A_x
%      Y|v|v = -1/2 * rho * CD_y * A_y
%      etc.
%% ============================================================

fprintf('--- AMORTISSEMENT QUADRATIQUE (Sections 6.4.2 & 6.4.3) ---\n');
fprintf('Méthode : traînée visqueuse  f = -1/2 * rho * CD * A * |v|*v\n\n');

% ---- Aires projetées de l'ellipsoïde ----
% Vue de face (X) : ellipse b x c
A_front = pi * b * c;   % [m²] aire frontale (surge)
% Vue de côté (Y) : ellipse a x c
A_side  = pi * a * c;   % [m²] aire latérale (sway)
% Vue du dessus (Z) : ellipse a x b
A_top   = pi * a * b;   % [m²] aire supérieure (heave)

% ---- Coefficients de traînée CD ----
% Valeurs empiriques pour ellipsoïde / cylindre immergé (Hoerner 1965)
% CD_x : traînée frontale (surge) — ellipsoïde profilé => CD faible
% CD_y, CD_z : traînée latérale et verticale => CD plus élevé (forme plate)
% CD_rot : traînée rotationnelle (roll/pitch/yaw)

CD_x = 0.16;    % surge  — Fossen éq. 6.88 : CX ≈ 0.16 (courant)
CD_y = 0.80;    % sway   — corps émergé latéralement (0.6-1.0 typique)
CD_z = 0.80;    % heave  — similaire à sway
CD_k = 0.50;    % roll   — résistance rotationnelle (estimation)
CD_m = 0.50;    % pitch  — résistance rotationnelle
CD_n = 0.50;    % yaw    — résistance rotationnelle

% ---- Bras de levier pour les moments rotationnels ----
% Moment = Intégrale de (force * bras) => proportionnel à L^2 ou L^3
% Approximation : bras moyen = demi-longueur correspondante

% Roll  (rotation autour X) : intégration sur les faces Y et Z
%   Moment ~ 1/2 * rho * CD_k * (2*b) * c^3  (strip theory approx.)
r_roll  = c;      % bras effectif roll  [m]
r_pitch = a;      % bras effectif pitch [m]
r_yaw   = b;      % bras effectif yaw   [m]

% Volumes de résistance rotationnelle (approximation strip theory éqs. 6.91-6.92)
Vol_roll  = (4/3) * pi * b * c^3;    % ~ intégrale de x²*T(x)dx en roll
Vol_pitch = (4/3) * pi * a^3 * c;   % en pitch
Vol_yaw   = (4/3) * pi * a^3 * b;   % en yaw

% ---- Calcul des coefficients quadratiques (éq. 6.55) ----

% Surge (éq. 6.87-6.88)
Xuu = -0.5 * rho * CD_x * A_front;

% Sway  (éq. 6.55 appliquée en Y)
Yvv = -0.5 * rho * CD_y * A_side;

% Heave (éq. 6.55 appliquée en Z)
Zww = -0.5 * rho * CD_z * A_top;

% Roll  (strip theory — éqs. 6.91-6.92 adaptées en rotation)
Kpp = -0.5 * rho * CD_k * Vol_roll;

% Pitch
Mqq = -0.5 * rho * CD_m * Vol_pitch;

% Yaw
Nrr = -0.5 * rho * CD_n * Vol_yaw;

fprintf('  Aires projetées :\n');
fprintf('    A_front (surge) = %.5f m²\n', A_front);
fprintf('    A_side  (sway)  = %.5f m²\n', A_side);
fprintf('    A_top   (heave) = %.5f m²\n\n', A_top);

fprintf('  Coefficients de traînée CD choisis :\n');
fprintf('    CD_x (surge) = %.2f\n', CD_x);
fprintf('    CD_y (sway)  = %.2f\n', CD_y);
fprintf('    CD_z (heave) = %.2f\n', CD_z);
fprintf('    CD_k (roll)  = %.2f\n', CD_k);
fprintf('    CD_m (pitch) = %.2f\n', CD_m);
fprintf('    CD_n (yaw)   = %.2f\n\n', CD_n);

fprintf('  Résultats amortissement QUADRATIQUE :\n');
fprintf('  Xuu = %10.4f\n', Xuu);
fprintf('  Yvv = %10.4f\n', Yvv);
fprintf('  Zww = %10.4f\n', Zww);
fprintf('  Kpp = %10.4f\n', Kpp);
fprintf('  Mqq = %10.4f\n', Mqq);
fprintf('  Nrr = %10.4f\n\n', Nrr);

%% ============================================================
%  ÉTAPE 4 : COMPARAISON AVEC TES VALEURS ACTUELLES
%% ============================================================

fprintf('=======================================================\n');
fprintf('  COMPARAISON : calculé vs. identifié (ton code)\n');
fprintf('=======================================================\n\n');

% Valeurs identifiées de ton code
Xu_id  = -23.9201;  Xuu_id = -26.7035;
Yv_id  = -43.6523;  Yvv_id = -80.1106;
Zw_id  = -52.9362;  Zww_id = -117.8097;
Kp_id  = -1.0752;   Kpp_id = -3.1250;
Mq_id  = -1.4659;   Mqq_id = -5.0470;
Nr_id  = -1.3090;   Nrr_id = -2.9207;

fprintf('  %-6s | %12s | %12s | %8s\n', 'DOF', 'Calculé', 'Identifié', 'Ratio');
fprintf('  %s\n', repmat('-',1,48));
fprintf('  %-6s | %12.4f | %12.4f | %8.3f\n', 'Xu',  Xu,  Xu_id,  Xu/Xu_id);
fprintf('  %-6s | %12.4f | %12.4f | %8.3f\n', 'Yv',  Yv,  Yv_id,  Yv/Yv_id);
fprintf('  %-6s | %12.4f | %12.4f | %8.3f\n', 'Zw',  Zw,  Zw_id,  Zw/Zw_id);
fprintf('  %-6s | %12.4f | %12.4f | %8.3f\n', 'Kp',  Kp,  Kp_id,  Kp/Kp_id);
fprintf('  %-6s | %12.4f | %12.4f | %8.3f\n', 'Mq',  Mq,  Mq_id,  Mq/Mq_id);
fprintf('  %-6s | %12.4f | %12.4f | %8.3f\n', 'Nr',  Nr,  Nr_id,  Nr/Nr_id);
fprintf('\n');
fprintf('  %-6s | %12s | %12s | %8s\n', 'DOF', 'Calculé', 'Identifié', 'Ratio');
fprintf('  %s\n', repmat('-',1,48));
fprintf('  %-6s | %12.4f | %12.4f | %8.3f\n', 'Xuu', Xuu, Xuu_id, Xuu/Xuu_id);
fprintf('  %-6s | %12.4f | %12.4f | %8.3f\n', 'Yvv', Yvv, Yvv_id, Yvv/Yvv_id);
fprintf('  %-6s | %12.4f | %12.4f | %8.3f\n', 'Zww', Zww, Zww_id, Zww/Zww_id);
fprintf('  %-6s | %12.4f | %12.4f | %8.3f\n', 'Kpp', Kpp, Kpp_id, Kpp/Kpp_id);
fprintf('  %-6s | %12.4f | %12.4f | %8.3f\n', 'Mqq', Mqq, Mqq_id, Mqq/Mqq_id);
fprintf('  %-6s | %12.4f | %12.4f | %8.3f\n', 'Nrr', Nrr, Nrr_id, Nrr/Nrr_id);

%% ============================================================
%  ÉTAPE 5 : RÉTRO-CALCUL des CD et T à partir des valeurs identifiées
%  (Utile pour vérifier la cohérence physique)
%% ============================================================

fprintf('\n=======================================================\n');
fprintf('  RÉTRO-CALCUL : CD et T implicites dans les valeurs identifiées\n');
fprintf('=======================================================\n\n');

% Constantes de temps implicites (linéaire)
T_surge_id = -m11 / Xu_id;
T_sway_id  = -m22 / Yv_id;
T_yaw_id   = -m66 / Nr_id;

fprintf('  Constantes de temps implicites :\n');
fprintf('    T_surge = %.4f s\n', T_surge_id);
fprintf('    T_sway  = %.4f s\n', T_sway_id);
fprintf('    T_yaw   = %.4f s\n\n', T_yaw_id);

% Coefficients CD implicites (quadratique)
CD_x_id = -2 * Xuu_id / (rho * A_front);
CD_y_id = -2 * Yvv_id / (rho * A_side);
CD_z_id = -2 * Zww_id / (rho * A_top);

fprintf('  Coefficients CD implicites :\n');
fprintf('    CD_x (surge) = %.4f\n', CD_x_id);
fprintf('    CD_y (sway)  = %.4f\n', CD_y_id);
fprintf('    CD_z (heave) = %.4f\n', CD_z_id);

%% ============================================================
%  ÉTAPE 6 : GRAPHIQUE — Force de traînée vs vitesse
%% ============================================================

fprintf('\n--- Génération des graphiques ---\n');

v_range = linspace(0, 1.5, 200);   % vitesse 0 à 1.5 m/s

% Force totale = linéaire + quadratique
F_surge_calc = abs(Xu)  .* v_range + abs(Xuu) .* v_range.^2;
F_sway_calc  = abs(Yv)  .* v_range + abs(Yvv) .* v_range.^2;
F_heave_calc = abs(Zw)  .* v_range + abs(Zww) .* v_range.^2;

F_surge_id   = abs(Xu_id)  .* v_range + abs(Xuu_id) .* v_range.^2;
F_sway_id    = abs(Yv_id)  .* v_range + abs(Yvv_id) .* v_range.^2;
F_heave_id   = abs(Zw_id)  .* v_range + abs(Zww_id) .* v_range.^2;

figure('Name','Comparaison forces de trainee','Position',[100 100 1200 400]);

subplot(1,3,1);
plot(v_range, F_surge_calc, 'b-', 'LineWidth', 2); hold on;
plot(v_range, F_surge_id,   'r--','LineWidth', 2);
xlabel('Vitesse [m/s]'); ylabel('Force [N]');
title('Surge — Force de traînée'); grid on;
legend('Calculé (Fossen)','Identifié (ton code)', 'Location','NW');

subplot(1,3,2);
plot(v_range, F_sway_calc,  'b-', 'LineWidth', 2); hold on;
plot(v_range, F_sway_id,    'r--','LineWidth', 2);
xlabel('Vitesse [m/s]'); ylabel('Force [N]');
title('Sway — Force de traînée'); grid on;
legend('Calculé (Fossen)','Identifié (ton code)', 'Location','NW');

subplot(1,3,3);
plot(v_range, F_heave_calc, 'b-', 'LineWidth', 2); hold on;
plot(v_range, F_heave_id,   'r--','LineWidth', 2);
xlabel('Vitesse [m/s]'); ylabel('Force [N]');
title('Heave — Force de traînée'); grid on;
legend('Calculé (Fossen)','Identifié (ton code)', 'Location','NW');

sgtitle('Amortissement : Valeurs calculées (Fossen 2011) vs. Identifiées');

%% ============================================================
%  SORTIE FINALE — Format prêt à coller dans ton code principal
%% ============================================================

fprintf('\n=======================================================\n');
fprintf('  COPIER-COLLER dans ton code principal\n');
fprintf('=======================================================\n\n');
fprintf('  %% Amortissement linéaire (Section 6.4.1 Fossen 2011)\n');
fprintf('  Xu  = %.4f;\n', Xu);
fprintf('  Yv  = %.4f;\n', Yv);
fprintf('  Zw  = %.4f;\n', Zw);
fprintf('  Kp  = %.4f;\n', Kp);
fprintf('  Mq  = %.4f;\n', Mq);
fprintf('  Nr  = %.4f;\n\n', Nr);
fprintf('  %% Amortissement quadratique (Section 6.4.2-6.4.3 Fossen 2011)\n');
fprintf('  Xuu = %.4f;\n', Xuu);
fprintf('  Yvv = %.4f;\n', Yvv);
fprintf('  Zww = %.4f;\n', Zww);
fprintf('  Kpp = %.4f;\n', Kpp);
fprintf('  Mqq = %.4f;\n', Mqq);
fprintf('  Nrr = %.4f;\n', Nrr);