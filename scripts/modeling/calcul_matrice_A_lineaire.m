% calcul_matrice_A_lineaire.m
%
% MÉTHODE : fixed_point — linéarisation à UN point d'opération fixe.
%   Ce script calcule K une seule fois au point hardcodé ci-dessous,
%   puis trace les pôles de A - B*K pour vérifier la stabilité.
%
% DIFFÉRENCE AVEC LE MODÈLE EN SIMULATION :
%   Le modèle Simulink utilise la méthode 'gain_scheduling' : il re-linéarise
%   A autour de l'état courant x(t) à chaque pas et re-résout Riccati.
%   Ce script sert à explorer l'approche fixed_point et valider Q/R.
%
% REMPLACÉ PAR (pour usage courant) :
%   compute_controller('nominal_fixedpoint')
%   → charge lqr_nominal_fixedpoint.m (point d'opération versionné)
%   → sauvegarde controller_nominal_fixedpoint.mat
%
% ENTRÉES :
%   data/generated/ABmatrice.mat  — matrices A/B symboliques
%   data/generated/calcul_Q.mat   — Q_final (généré par trouver_matrice_Q.m)
%
% SORTIES :
%   data/generated/Matrice_A_lineaire.mat — A_num au point d'opération
%   figure(10) — carte des pôles de la boucle fermée

projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
generatedDataDir = fullfile(projectRoot, 'data', 'generated');

syms x y z roll_ pitch_ yaw_ u v w p q r radius
close all
load(fullfile(generatedDataDir, "ABmatrice.mat"), "A", "B")
load(fullfile(generatedDataDir, "calcul_Q.mat"), "Q_final")
radius1 = 0.26; R = 0.1*eye(8);
Q = diag([Q_final(1,1) Q_final(2,2) Q_final(3,3) Q_final(4,4) Q_final(5,5) Q_final(6,6) Q_final(7,7) Q_final(8,8) Q_final(9,9) Q_final(10,10) Q_final(11,11) Q_final(12,12)]);
% Q = Q_final;
x1 = [10]; % serve a rien
y1 = [10]; % serve a rien
z1 = [10]; % serve a rien
roll_1 = [0];
pitch_1 = [0];
yaw_1 = [0];
u1 = [1];
v1 = [1];
w1 = [1];
p1 = [0.25];
q1 = [0.25];
r1 = [0.25];
n =1;
A_num = subs(A, [x y z roll_ pitch_ yaw_ u v w p q r radius], [x1(n) y1(n) z1(n) roll_1(n) pitch_1(n) yaw_1(n) u1(n) v1(n) w1(n) p1(n) q1(n) r1(n) radius1]);
A_num = double(A_num);

B_num = B;
B_num = double(B_num);

K = lqr(A_num, B_num, Q_final, R);
poles = eig(A_num - B_num*K);

figure(10)
plot(real(poles), imag(poles), 'x')
grid on
xlabel('Partie réelle')
ylabel('Partie imaginaire')
title('Pôles du système')


save(fullfile(generatedDataDir, "Matrice_A_lineaire.mat"), "A_num")

