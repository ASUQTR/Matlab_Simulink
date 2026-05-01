
syms x y z roll_ pitch_ yaw_ u v w p q r radius
close all
load("ABmatrice.mat","A","B")
load("calcul_Q.mat","Q_final")
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


save("Matrice_A_lineaire","A_num")

