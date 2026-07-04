syms x y z roll_ pitch_ yaw_ u v w p q r radius

close all
load("ABmatrice.mat","A","B")

radius1 = 0.16;

% R = diag([0.15, 0.15, 0.1, 0.1, 0.1, 0.1, 0.15, 0.15]);
R = 0.1 * eye(8);

% Définition des 12 pôles cibles
P_targets = [ ...
    -3.0 + 1i, -3.0 - 1i, ...
    -2 + 1i, -2 - 1i, ...
    -2.7, -1.0, ...
    -3.2, -6.0, ...
    -2.5, -2.2, -1.5, -2.5];

% Point d'opération
x1 = 100;
y1 = 100;
z1 = 100;

roll_1  = 1.57;
pitch_1 = 0.7;
yaw_1   = 0.7;

u1 = 1.2;
v1 = 1.2;
w1 = 1.2;

p1 = 1.2;
q1 = 1.0;
r1 = 1.0;

% Conversion de B en numérique
B_num = double(B);

% ==========================
% Calcul de A et du gain K
% ==========================

A_num = subs(A,...
    [x y z roll_ pitch_ yaw_ u v w p q r],...
    [x1 y1 z1 roll_1 pitch_1 yaw_1 u1 v1 w1 p1 q1 r1]);

A_num = double(A_num);

K_place = place(A_num, B_num, P_targets);

% ==========================
% Système boucle fermée
% ==========================

Ac = A_num - B_num * K_place;

% ==========================
% Matrices de coût
% ==========================

Q_inverse = -(Ac' * (K_place' * R * K_place) + ...
              (K_place' * R * K_place) * Ac);

Q_final = K_place' * R * K_place;

% ==========================
% TEST 1 : Q_inverse > 0
% ==========================

if all(eig(Q_inverse) > 0)
    disp('test1 : Le système est STABLE.');
else
    disp('test1 : Le système est INSTABLE !');
end

% ==========================
% TEST 2 : Valeurs propres
% ==========================

poles_fermes = eig(Ac);

if all(real(poles_fermes) < 0)
    disp('test2 : Le système est STABLE.');
else
    disp('test2 : Le système est INSTABLE !');
end

% ==========================
% TEST 3 : Lyapunov complet
% ==========================

Q_lyap = eye(size(Ac));

P = lyap(Ac', Q_lyap);

sym_error = norm(P - P', 'fro');
eigP = eig(P);

fprintf('\n===== TEST LYAPUNOV =====\n');
fprintf('Erreur de symétrie de P : %.3e\n', sym_error);
fprintf('Valeur propre min(P)    : %.6e\n', min(eigP));
fprintf('Valeur propre max(P)    : %.6e\n', max(eigP));

residu = Ac' * P + P * Ac + Q_lyap;

fprintf('Norme du résidu         : %.3e\n', norm(residu,'fro'));

if sym_error < 1e-10 && all(eigP > 1e-10)
    disp('test3 : Lyapunov -> SYSTEME STABLE');
else
    disp('test3 : Lyapunov -> SYSTEME INSTABLE');
end

% ==========================
% Affichage des pôles
% ==========================

figure;
pzmap(ss(Ac, B_num, eye(size(Ac)), 0));
grid on;
title('Placement des pôles en boucle fermée');

% ==========================
% Sauvegarde
% ==========================

save("calcul_Q","Q_final")

% ==========================
% Affichage matrices
% ==========================

disp( "Q_inverse " + "[ " + Q_inverse(1,1) + " ] " + "[ " + Q_inverse(2,2) + " ] "+ "[ " + Q_inverse(3,3) + " ] "+ "[ " + Q_inverse(4,4) + " ] "+ "[ " + Q_inverse(5,5) + " ] "+ "[ " + Q_inverse(6,6) + " ] "+ "[ " + Q_inverse(7,7) + " ] "+ "[ " + Q_inverse(8,8) + " ] "+ "[ " + Q_inverse(9,9) + " ] "+ "[ " + Q_inverse(10,10) + " ] "+ "[ " + Q_inverse(11,11) + " ] "+ "[ " + Q_inverse(12,12) + " ] ") 
disp( "Q_Final " + "[ " + Q_final(1,1) + " ] " + "[ " + Q_final(2,2) + " ] "+ "[ " + Q_final(3,3) + " ] "+ "[ " + Q_final(4,4) + " ] "+ "[ " + Q_final(5,5) + " ] "+ "[ " + Q_final(6,6) + " ] "+ "[ " + Q_final(7,7) + " ] "+ "[ " + Q_final(8,8) + " ] "+ "[ " + Q_final(9,9) + " ] "+ "[ " + Q_final(10,10) + " ] "+ "[ " + Q_final(11,11) + " ] "+ "[ " + Q_final(12,12) + " ] ")
