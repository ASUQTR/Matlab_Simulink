%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Émile Lahaie
%   11 novembre 2025
%   calcul d'inertie sous marin
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
masse_moteur = 0.427; % masse moteur T200
masse_total = 24 % kg
masse_sous_marin = masse_total-masse_moteur;
L = 0.33;
r = 0.11;
n = 1:8;
Inertie_sans_angle = 0;
thrust_position = [    0.2987,  0.2130, 0;  %thruster 1
                           0.2987, -0.2130, 0;  %thruster 2
                          -0.1073,  0.2725, 0;  %thruster 3
                          -0.1073, -0.2725, 0;  %thruster 4
                           0.1073,  0.2725, 0;  %thruster 5
                           0.1073, -0.2725, 0;  %thruster 6
                          -0.2987,  0.2130, 0;  %thruster 7
                          -0.2987, -0.2130, 0]; %thruster 8
     
thrust_direction = [     -0.707,   0.707,    0;   %thruster 1
                         -0.707,  -0.707,    0;   %thruster 2
                         0.0,      0.0,      -1;   %thruster 3
                         0.0,      0.0,      -1;   %thruster 4
                         0.0,      0.0,      -1;   %thruster 5
                         0.0,      0.0,      -1;   %thruster 6
                         0.707,    0.707,    0;   %thruster 7
                         0.707,   -0.707,    0];  %thruster 8

for n = 1:8
I_tenseur{n} = [   masse_moteur*(thrust_position(n,2)^2+thrust_position(n,3)^2),
                 -masse_moteur*thrust_position(n,1)*thrust_position(n,2) ,
                 -masse_moteur*thrust_position(n,1)*thrust_position(n,3);
                -masse_moteur*thrust_position(n,1)*thrust_position(n,2),
                masse_moteur*(thrust_position(n,1)^2+thrust_position(n,3)^2), 
                -masse_moteur*thrust_position(n,3)*thrust_position(n,2);
                -masse_moteur*thrust_position(n,1)*thrust_position(n,3), 
                -masse_moteur*thrust_position(n,3)*thrust_position(n,2), 
                masse_moteur*(thrust_position(n,1)^2+thrust_position(n,2)^2)];
end
I_tenseur{9} = [1/12 * (masse_sous_marin*(3*r^2+L^2)), 0 , 0;
                0, 1/12 * (masse_sous_marin*(3*r^2+L^2)), 0;
                0, 0, 1/2 * (masse_sous_marin*r^2)]

for n = 1:9
%Inertie_simple{n} = dot(I_tenseur{n}*[thrust_direction(n,1);thrust_direction(n,2);thrust_direction(n,3)],[thrust_direction(n,1);thrust_direction(n,2);thrust_direction(n,3)]);
Inertie_sans_angle = I_tenseur{n}+Inertie_sans_angle;
end

for n = 1:8
I_tenseur{n}
end
Inertie_sans_angle