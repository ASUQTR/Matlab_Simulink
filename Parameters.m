% REF
%     Q_elements = [1 1 4 4 1 1 3 3 3 4 4 4];
%     Q = diag(Q_elements);
%     R_elements = [0.001 0.001 0.001 0.001 0.001 0.001 0.001 0.001];
%     R = diag(R_elements);
    %Q_elements = [0.000001 0.000001 1.5 1 1 1 1 1 1 0.0001 0.0001 0.0001];
    %Q = diag(Q_elements);
    %R_elements = [0.01 0.01 0.01 0.01 0.01 0.01 0.01 0.01];
    %R = diag(R_elements);
    %Amatrix = zeros(12,12);
    %Bmatrix = zeros(12,8);
    %X0 = 0;

close all
%% ------------------------------ Parameters ------------------------------
%rg_b = [0 0 0.02 ]; [m]  % location of the CG (center of gravity) with respect to CO (') (0, 0,0)
x_rg = 0;
y_rg = 0;
z_rg = 0;

%rb_b = [0 0 0]; [m] % location of CB (center of buoyancy) with respect to CO
x_rb = 0;
y_rb = 0;
z_rb = 0;

%I_b = [0.16 0.16 0.16].'; [kg*m^2] % inertia tensor where the body axes coincide with the principal axes of inertia or the longitudinal

% inertie trouvé ancien
I_x = 0.578;
I_y = 0.645;
I_z = 0.9366;


% calculé Émile
% I_x = 0.5380;
% I_y = 0.5057;
% I_z = 0.5432;


% original
% I_x =  0.16; % original (0.16)
% I_y =  0.16; % original (0.16)
% I_z =  0.16; % original (0.16)

%m = 11.5; % mass [kg]
%g = 9.81; %acceleration of gravity
%W = 112.8; % weight W = m*g [N]
%B = 114.8; % buoyancy [N]
water_density = 1000.0;
radius = 0.26;
m = 23.9; % original (2.8)
g = 9.81;
W = m*g;
B = -W;

%% ---------------------------------Actuators------------------------------
%syms angle_motors = pi/4
% longeur[m]


lx1 =  0.2987;  % original (0.2987)
ly1 =  0.2130; % original (0.2130)
lz1 =  0; % original (0)

lx2 =  0.2987; % original (0.2987)
ly2 =  -0.2130; % original (-0.2130)
lz2 =  0; % original (0.16)

lx3 = -0.1073; % original (-0.1073)
ly3 =  0.2725; % original (0.2725)
lz3 =  0; % original (0)

lx4 = -0.1073; % original (-0.1073)
ly4 = -0.2725; % original (-0.2725)
lz4 =  0; % original (0)

lx5 =  0.1073; % original (0.1073)
ly5 =  0.2725; % original (0.2725)
lz5 =  0; % original (0.16)

lx6 = 0.1073; % original (0.1073)
ly6 = -0.2725; % original (-0.2725)
lz6 = 0; % original (0)

lx7 =  -0.2987; % original (-0.2987)
ly7 =  0.2130; % original (0.2130)
lz7 =  0; % original (0)

lx8 =  -0.2987; % original (-0.2987)
ly8 = -0.2130; % original (-0.2130)
lz8 =  0; % original (0)

% calculé
% lx1 = 0.0194; ly1 = 0.0381; lz1 = 0.0575;
% lx2 = 0.0194; ly2 = -0.0381; lz2 = 0.0575;
% lx3 = -0.0317; ly3 = 0.0049; lz3 = 0.0366;
% lx4 = -0.0317; ly4 = -0.0049; lz4 = 0.0366;
% lx5 = 0.0317; ly5 = 0.0049; lz5 = 0.0366;
% lx6 = 0.0317; ly6 = -0.0049; lz6 = 0.0366;
% lx7 = -0.0194; ly7 = 0.0381; lz7 = 0.0575;
% lx8 = -0.0194; ly8 = -0.0381; lz8 = 0.0575;

% calculé V2
% I1x = -0.019373; I1y = -0.038098; I1z = -0.057470;
% I2x = -0.019373; I2y = 0.038098; I2z = -0.057470;
% I3x = 0.031707; I3y = -0.004916; I3z = -0.036624;
% I4x = 0.031707; I4y = 0.004916; I4z = -0.036624;
% I5x = -0.031707; I5y = -0.004916; I5z = -0.036624;
% I6x = -0.031707; I6y = 0.004916; I6z = -0.036624;
% I7x = 0.019373; I7y = -0.038098; I7z = -0.057470;
% I8x = 0.019373; I8y = 0.038098; I8z = -0.057470;

% force = 65.7
force = 1;
% force = 1;
%F1cos(pi/4);
%-F1sin(pi/4);



Fx1 = -0.7071*force; Fy1 =  0.7071*force; Fz1 = 0;
Fx2 = -0.7071*force; Fy2 = -0.7071*force; Fz2 = 0;

Fx3 = 0; Fy3 = 0; Fz3 = -1*force;
Fx4 = 0; Fy4 = 0; Fz4 = -1*force;
Fx5 = 0; Fy5 = 0; Fz5 = -1*force;
Fx6 = 0; Fy6 = 0; Fz6 = -1*force;

Fx7 =  0.7071*force; Fy7 =  0.7071*force; Fz7 = 0;
Fx8 =  0.7071*force; Fy8 = -0.7071*force; Fz8 = 0;


load("calcul_Q.mat","Q_final");
load("Matrice_A_lineaire","A_num")
% load("ABmatrice","A","B")
% load("calcul_Q_possible3.mat","Q_final");
Q_envoyer = Q_final(:,:,1);