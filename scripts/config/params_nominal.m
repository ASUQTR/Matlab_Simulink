function p = params_nominal()
% Calibration nominale du sous-marin AUV ASUQTR.
% Valeurs actives au 2026-05. Copier et renommer pour creer une variante.
%
% Usage:
%   p = params_nominal();
%
% Pour surcharger un parametre dans une variante:
%   p = params_nominal();
%   p.I_x = 0.5380;   % valeur specifique a cette variante

%% Geometrie — position du centre de gravite / flottabilite [m]
p.x_rg = 0;   p.y_rg = 0;   p.z_rg = 0;
p.x_rb = 0;   p.y_rb = 0;   p.z_rb = 0;

%% Inertie [kg*m^2]
p.I_x = 0.578;
p.I_y = 0.645;
p.I_z = 0.9366;

%% Masse et flottabilite
p.water_density = 1000.0;   % [kg/m^3]
p.radius        = 0.26;     % [m]
p.m             = 23.9;     % [kg]
p.g             = 9.81;     % [m/s^2]
p.W             = p.m * p.g;
p.B             = -p.W;

%% Positions des actionneurs [m]
p.lx1 =  0.0194;  p.ly1 =  0.0381;  p.lz1 = 0.0575;
p.lx2 =  0.0194;  p.ly2 = -0.0381;  p.lz2 = 0.0575;
p.lx3 = -0.0317;  p.ly3 =  0.0049;  p.lz3 = 0.0366;
p.lx4 = -0.0317;  p.ly4 = -0.0049;  p.lz4 = 0.0366;
p.lx5 =  0.0317;  p.ly5 =  0.0049;  p.lz5 = 0.0366;
p.lx6 =  0.0317;  p.ly6 = -0.0049;  p.lz6 = 0.0366;
p.lx7 = -0.0194;  p.ly7 =  0.0381;  p.lz7 = 0.0575;
p.lx8 = -0.0194;  p.ly8 = -0.0381;  p.lz8 = 0.0575;

%% Force nominale des actionneurs [N]
p.force = 20;

%% Composantes de force par actionneur [N]
p.Fx1 = -0.7071*p.force;  p.Fy1 =  0.7071*p.force;  p.Fz1 = 0;
p.Fx2 = -0.7071*p.force;  p.Fy2 = -0.7071*p.force;  p.Fz2 = 0;
p.Fx3 =  0;               p.Fy3 =  0;               p.Fz3 = -p.force;
p.Fx4 =  0;               p.Fy4 =  0;               p.Fz4 = -p.force;
p.Fx5 =  0;               p.Fy5 =  0;               p.Fz5 = -p.force;
p.Fx6 =  0;               p.Fy6 =  0;               p.Fz6 = -p.force;
p.Fx7 =  0.7071*p.force;  p.Fy7 =  0.7071*p.force;  p.Fz7 = 0;
p.Fx8 =  0.7071*p.force;  p.Fy8 = -0.7071*p.force;  p.Fz8 = 0;

end
