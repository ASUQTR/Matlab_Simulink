function p = params_originaux()
% Variante : parametres originaux du modele de reference.
% Valeurs utilisees avant les mesures sur le sous-marin reel.

p = params_nominal();

%% Inertie originale [kg*m^2]
p.I_x = 0.16;
p.I_y = 0.16;
p.I_z = 0.16;

%% Masse originale
p.m = 11.5;
p.W = p.m * p.g;
p.B = -p.W;

%% Positions actionneurs originales [m]
p.lx1 =  0.2987;  p.ly1 =  0.2130;  p.lz1 = 0;
p.lx2 =  0.2987;  p.ly2 = -0.2130;  p.lz2 = 0.16;
p.lx3 = -0.1073;  p.ly3 =  0.2725;  p.lz3 = 0;
p.lx4 = -0.1073;  p.ly4 = -0.2725;  p.lz4 = 0.300193;
p.lx5 =  0.1073;  p.ly5 =  0.2725;  p.lz5 = 0.16;
p.lx6 =  0.1073;  p.ly6 = -0.2725;  p.lz6 = 0;
p.lx7 = -0.2987;  p.ly7 =  0.2130;  p.lz7 = 0;
p.lx8 = -0.2987;  p.ly8 = -0.2130;  p.lz8 = 0;

%% Force originale
p.force = 65.7;

p.Fx1 = -0.7071*p.force;  p.Fy1 =  0.7071*p.force;  p.Fz1 = 0;
p.Fx2 = -0.7071*p.force;  p.Fy2 = -0.7071*p.force;  p.Fz2 = 0;
p.Fx3 =  0;               p.Fy3 =  0;               p.Fz3 = -p.force;
p.Fx4 =  0;               p.Fy4 =  0;               p.Fz4 = -p.force;
p.Fx5 =  0;               p.Fy5 =  0;               p.Fz5 = -p.force;
p.Fx6 =  0;               p.Fy6 =  0;               p.Fz6 = -p.force;
p.Fx7 =  0.7071*p.force;  p.Fy7 =  0.7071*p.force;  p.Fz7 = 0;
p.Fx8 =  0.7071*p.force;  p.Fy8 = -0.7071*p.force;  p.Fz8 = 0;

end
