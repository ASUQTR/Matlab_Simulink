%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Émile Lahaie
%   19 mai 2026
%   calcul d'inertie sous marin
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Masse moteur
m = 0.427;   % kg

%% Positions moteurs
r = [
  0.2987  0.2130  0;
  0.2987 -0.2130  0;
 -0.1073  0.2725  0;
 -0.1073 -0.2725  0;
  0.1073  0.2725  0;
  0.1073 -0.2725  0;
 -0.2987  0.2130  0;
 -0.2987 -0.2130  0
];

%% Initialisation
Ix = zeros(8,1);
Iy = zeros(8,1);
Iz = zeros(8,1);

%% Calcul inertie pour chaque moteur
for i = 1:8
    
    x = r(i,1);
    y = r(i,2);
    z = r(i,3);
    
    Ix(i) = m * (y^2 + z^2);
    Iy(i) = m * (x^2 + z^2);
    Iz(i) = m * (x^2 + y^2);
end

fprintf('I1x = %.6f; I1y = %.6f; I1z = %.6f;\n', Ix(1), Iy(1), Iz(1));
fprintf('I2x = %.6f; I2y = %.6f; I2z = %.6f;\n', Ix(2), Iy(2), Iz(2));
fprintf('I3x = %.6f; I3y = %.6f; I3z = %.6f;\n', Ix(3), Iy(3), Iz(3));
fprintf('I4x = %.6f; I4y = %.6f; I4z = %.6f;\n', Ix(4), Iy(4), Iz(4));
fprintf('I5x = %.6f; I5y = %.6f; I5z = %.6f;\n', Ix(5), Iy(5), Iz(5));
fprintf('I6x = %.6f; I6y = %.6f; I6z = %.6f;\n', Ix(6), Iy(6), Iz(6));
fprintf('I7x = %.6f; I7y = %.6f; I7z = %.6f;\n', Ix(7), Iy(7), Iz(7));
fprintf('I8x = %.6f; I8y = %.6f; I8z = %.6f;\n', Ix(8), Iy(8), Iz(8));