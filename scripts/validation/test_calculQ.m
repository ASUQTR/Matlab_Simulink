%% PROGRAMME DE CALCUL LQR - MINI SOUS-MARIN
clear all; clc; close all;
projectRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
generatedDataDir = fullfile(projectRoot, 'data', 'generated');

% --- 1. Paramètres Physiques (Valeurs numériques) ---
radius = 0.26; 
pi_val = pi; 

% État de linéarisation (Point d'équilibre)
% On définit des valeurs numériques pour que MATLAB puisse remplacer les variables
roll_ = 0; pitch_ = 0; yaw_ = 0;
u = 0; v = 0; w = 0;
p = 0; q = 0; r = 0;

% --- 2. ESPACE POUR LES MATRICES A ET B (SYMBOLIQUE OU NUMÉRIQUE) ---

% [ COLLE TA MATRICE A ICI ]

load(fullfile(generatedDataDir, "ABmatrice.mat"), "A", "B");

% --- 3. CONVERSION NUMÉRIQUE (CRUCIAL POUR L'ERREUR "SYM") ---
% Cette étape remplace les variables (radius, roll_, etc.) par les chiffres définis en haut
A_num = double(subs(A));
B_num = double(subs(B));

% --- 4. CONFIGURATION DES POIDS Q ET R ---

load(fullfile(generatedDataDir, "calcul_Q.mat"), "Q_final")
Q = Q_final;
R = 0.04 * eye(8); 

% --- 5. CALCUL DU GAIN OPTIMAL LQR ---

try
    % On utilise les versions numériques (_num) ici
    [K, S, P] = lqr(A_num, B_num, Q, R);
    
    fprintf('Matrice K calculée avec succès (8x12).\n');
    
    % --- 6. VÉRIFICATION DES PÔLES ---
    poles = eig(A_num - B_num*K);
    figure;
    plot(real(poles), imag(poles), 'ro', 'LineWidth', 2);
    grid on; xline(0, 'k--');
    title('Stabilité du système (Pôles)');
    
catch ME
    fprintf('Erreur lors du calcul LQR : %s\n', ME.message);
end