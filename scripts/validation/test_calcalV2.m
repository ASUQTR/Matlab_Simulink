projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
generatedDataDir = fullfile(projectRoot, 'data', 'generated');

syms x y z roll_ pitch_ yaw_ u v w p q r radius
close all
load(fullfile(generatedDataDir, "ABmatrice.mat"), "A", "B")
radius1 = 0.26;
% R = diag([0.1, 0.1, 0.05, 0.05, 0.05, 0.05, 0.1, 0.1]); 
R = 0.1*eye(8);
% Définition des 12 pôles cibles
P_targets = [ ...
    -3.0 + 2i, -3.0 - 2i, ... % x, y
    -5 + 1i, -5 - 1i,               ... % z et sa vitesse
    -8, -9.0, ... % roll, pitch
    -7, -6,               ... % yaw
    -2.5, -3.0, -3.5, -4.5    ... % Amortissement des vitesses restantes
];

x1 = [10]; % serve a rien
y1 = [10]; % serve a rien
z1 = [10]; % serve a rien
roll_1 = [1.57];
pitch_1 = [0.7];
yaw_1 = [0.7];
u1 = [1.6];
v1 = [1.6];
w1 = [1.6];
p1 = [1.2];
q1 = [1];
r1 = [1];

B_num = B;
B_num = double(B_num);

for n = 1:1
    
    A_num = subs(A, [x y z roll_ pitch_ yaw_ u v w p q r radius], [x1(n) y1(n) z1(n) roll_1(n) pitch_1(n) yaw_1(n) u1(n) v1(n) w1(n) p1(n) q1(n) r1(n) radius1]);
    A_num = double(A_num);
    K_place = place(A_num, B_num, P_targets);
    
    
    Ac = A_num - B_num * K_place;
    Q_inverse = -(Ac' * (K_place' * R * K_place) + (K_place' * R * K_place) * Ac); 
    
    Q_final(:,:,n) = K_place' * R * K_place;

end

if all(eig(Q_inverse) > 0)
    disp('test1 : Le système est STABLE.');
else
    disp("test1 : Le système est INSTABLE !");
end


% Calcul de la matrice boucle fermée
Ac = A_num - B_num * K_place;

% Calcul des valeurs propres
poles_fermes = eig(Ac);

% Affichage de la partie réelle
% disp('Partie réelle des pôles :');
% disp(real(poles_fermes));

% Test logique
if all(real(poles_fermes) < 0)
    disp('test2 : Le système est STABLE.');
else
    disp('test2 : Le système est INSTABLE !');
end

figure;
pzmap(ss(Ac, B_num, eye(size(Ac)), 0)); % Trace les pôles et zéros
grid on;
title('Placement des pôles en boucle fermée');

save(fullfile(generatedDataDir, "calcul_Q.mat"), "Q_final")


disp( "Q_inverse " + "[ " + Q_inverse(1,1) + " ] " + "[ " + Q_inverse(2,2) + " ] "+ "[ " + Q_inverse(3,3) + " ] "+ "[ " + Q_inverse(4,4) + " ] "+ "[ " + Q_inverse(5,5) + " ] "+ "[ " + Q_inverse(6,6) + " ] "+ "[ " + Q_inverse(7,7) + " ] "+ "[ " + Q_inverse(8,8) + " ] "+ "[ " + Q_inverse(9,9) + " ] "+ "[ " + Q_inverse(10,10) + " ] "+ "[ " + Q_inverse(11,11) + " ] "+ "[ " + Q_inverse(12,12) + " ] ")
disp( "Q_Final " +  "[ " + Q_final(1,1) + " ] " + "[ " + Q_final(2,2) + " ] "+ "[ " + Q_final(3,3) + " ] "+ "[ " + Q_final(4,4) + " ] "+ "[ " + Q_final(5,5) + " ] "+ "[ " + Q_final(6,6) + " ] "+ "[ " + Q_final(7,7) + " ] "+ "[ " + Q_final(8,8) + " ] "+ "[ " + Q_final(9,9) + " ] "+ "[ " + Q_final(10,10) + " ] "+ "[ " + Q_final(11,11) + " ] "+ "[ " + Q_final(12,12) + " ] ")