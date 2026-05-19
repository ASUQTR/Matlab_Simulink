%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Émile Lahaie
%   19 mai 2026
%   calcul d'inertie sous marin
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% =========================================================================
% CALCUL DES COMPOSANTES D'INERTIE PROPRE DES 8 MOTEURS
% =========================================================================
clear; clc;

%% 1. PARAMÈTRES D'ENTRÉE DU ROV
masse_total = 28;                   % [kg] Masse totale du sous-marin
L = 0.33;                           % [m] Longueur du cylindre principal
r = 0.11;                           % [m] Rayon du cylindre principal
masse_un_moteur = 0.427;            % [kg] Masse d'un moteur
I_total = [0.578, 0.645, 0.9366];   % [kg.m²] Inertie totale [Ixx, Iyy, Izz]

%% 2. POSITIONS DES MOTEURS
thrust_position = [  0.2987,  0.2130, 0;   % Moteur 1
                     0.2987, -0.2130, 0;   % Moteur 2
                    -0.1073,  0.2725, 0;   % Moteur 3
                    -0.1073, -0.2725, 0;   % Moteur 4
                     0.1073,  0.2725, 0;   % Moteur 5
                     0.1073, -0.2725, 0;   % Moteur 6
                    -0.2987,  0.2130, 0;   % Moteur 7
                    -0.2987, -0.2130, 0];  % Moteur 8

%% 3. CALCULS PHYSIQUES
% Masse du corps seul
masse_cylindre = masse_total - (8 * masse_un_moteur);

% Inertie du corps principal (Cylindre selon l'axe X)
Ixx_cyl = 0.5 * masse_cylindre * r^2;
Iyy_cyl = (1/12) * masse_cylindre * (3*r^2 + L^2);
Izz_cyl = Iyy_cyl;
I_cylindre = [Ixx_cyl, Iyy_cyl, Izz_cyl];

% Effet de transport (Théorème de Huygens)
I_transport_total = [0, 0, 0];
for i = 1:8
    x = thrust_position(i, 1);
    y = thrust_position(i, 2);
    z = thrust_position(i, 3);
    
    I_transport_total(1) = I_transport_total(1) + masse_un_moteur * (y^2 + z^2);
    I_transport_total(2) = I_transport_total(2) + masse_un_moteur * (x^2 + z^2);
    I_transport_total(3) = I_transport_total(3) + masse_un_moteur * (x^2 + y^2);
end

% Isolation de l'inertie propre de chaque moteur
I_moteurs_propre_total = I_total - I_cylindre - I_transport_total;
I_un_moteur = I_moteurs_propre_total / 8;

%% 4. ATTRIBUTION DES VARIABLES SOUHAITÉES
lx1 = I_un_moteur(1); ly1 = I_un_moteur(2); lz1 = I_un_moteur(3);
lx2 = I_un_moteur(1); ly2 = I_un_moteur(2); lz2 = I_un_moteur(3);
lx3 = I_un_moteur(1); ly3 = I_un_moteur(2); lz3 = I_un_moteur(3);
lx4 = I_un_moteur(1); ly4 = I_un_moteur(2); lz4 = I_un_moteur(3);
lx5 = I_un_moteur(1); ly5 = I_un_moteur(2); lz5 = I_un_moteur(3);
lx6 = I_un_moteur(1); ly6 = I_un_moteur(2); lz6 = I_un_moteur(3);
lx7 = I_un_moteur(1); ly7 = I_un_moteur(2); lz7 = I_un_moteur(3);
lx8 = I_un_moteur(1); ly8 = I_un_moteur(2); lz8 = I_un_moteur(3);

%% 5. AFFICHAGE DES VALEURS OBTENUES INLINE
fprintf('lx1 = %.4f; ly1 = %.4f; lz1 = %.4f;\n', lx1, ly1, lz1);
fprintf('lx2 = %.4f; ly2 = %.4f; lz2 = %.4f;\n', lx2, ly2, lz2);
fprintf('lx3 = %.4f; ly3 = %.4f; lz3 = %.4f;\n', lx3, ly3, lz3);
fprintf('lx4 = %.4f; ly4 = %.4f; lz4 = %.4f;\n', lx4, ly4, lz4);
fprintf('lx5 = %.4f; ly5 = %.4f; lz5 = %.4f;\n', lx5, ly5, lz5);
fprintf('lx6 = %.4f; ly6 = %.4f; lz6 = %.4f;\n', lx6, ly6, lz6);
fprintf('lx7 = %.4f; ly7 = %.4f; lz7 = %.4f;\n', lx7, ly7, lz7);
fprintf('lx8 = %.4f; ly8 = %.4f; lz8 = %.4f;\n', lx8, ly8, lz8);