projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
generatedDataDir = fullfile(projectRoot, 'data', 'generated');
runtimeDataDir = fullfile(projectRoot, 'data', 'runtime');

clc
% etats max et min
load(fullfile(generatedDataDir, "ABmatrice.mat"))
load(fullfile(runtimeDataDir, "info_simulation.mat"), "out")
syms x y z roll_ pitch_ yaw_ u v w p q r radius;
thrust = 1;
importance = 0;
R = diag([thrust, thrust, thrust-importance, thrust-importance, thrust-importance, thrust-importance, thrust, thrust]); 

x1 = out.etats.signals.values(:,1);
y1 = out.etats.signals.values(:,2);
z1 = out.etats.signals.values(:,3);
roll1 = out.etats.signals.values(:,4);
pitch1 = out.etats.signals.values(:,5);
yaw1 = out.etats.signals.values(:,6);
u1 = out.etats.signals.values(:,7);
v1 = out.etats.signals.values(:,8);
w1 = out.etats.signals.values(:,9);
p1 = out.etats.signals.values(:,10);
q1 = out.etats.signals.values(:,11);
r1 = out.etats.signals.values(:,12);

max_x = max(x1);
max_y = max(y1);
max_z = max(z1);
max_roll = max(roll1);
max_pitch = max(pitch1);
max_yaw = max(yaw1);
max_u = max(u1);
max_v = max(v1);
max_w = max(w1);
max_p =  max(p1);
max_q =  max(q1);
max_r = max(r1);

min_x = min(x1);
min_y = min(y1);
min_z = min(z1);
min_roll = min(roll1);
min_pitch = min(pitch1);
min_yaw = min(yaw1);
min_u = min(u1);
min_v = min(v1);
min_w = min(w1);
min_p =  min(p1);
min_q =  min(q1);
min_r = min(r1);

disp("x :     " + "| max : " + max_x + " | min : " + min_x + " |")
disp("y :     " + "| max : " + max_y + " | min : " + min_y + " |")
disp("z :     " + "| max : " + max_z + " | min : " + min_z + " |")
disp("roll  : " + "| max : " + max_roll + " | min : " + min_roll + " |")
disp("pitch : " + "| max : " + max_pitch + " | min : " + min_pitch + " |")
disp("yaw :   " + "| max : " + max_yaw + " | min : " + min_yaw + " |")
disp("u :     " + "| max : " + max_u + " | min : " + min_u + " |")
disp("v :     " + "| max : " + max_v + " | min : " + min_v + " |")
disp("w :     " + "| max : " + max_w + " | min : " + min_w + " |")
disp("p :     " + "| max : " + max_p + " | min : " + min_p + " |")
disp("q :     " + "| max : " + max_q + " | min : " + min_q + " |")
disp("r :     " + "| max : " + max_r + " | min : " + min_r + " |")



Q = transpose(A)*(B*inv(R)*transpose(B))*A;

% Définissez vos variables symboliques dans un vecteur
vars = [x, y, z, roll_, pitch_, yaw_, u, v, w, p, q, r, radius];

% Définissez les valeurs de remplacement dans un vecteur de même taille
vals = [0.1, 0.1, 0.1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.26];

% Appliquez le remplacement
Q_num = subs(Q, vars, vals);

% Convertir en nombres à virgule
Q_final = double(Q_num)

save(fullfile(generatedDataDir, "calcul_Q.mat"), "Q_final")