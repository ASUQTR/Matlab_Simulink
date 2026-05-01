clear; clc; close all;
syms x y z roll_ pitch_ yaw_ u v w p q r radius
load("ABmatrice.mat","A","B")

% Paramètres fixes
radius1 = 0.26;
R = 0.1 * eye(8);
B_num = double(B);
P_targets = [-3+2i, -3-2i, -5+1i, -5-1i, -8, -9, -7, -6, -2.5, -3, -3.5, -4.5];

% Conversion en fonction numérique (indispensable pour la vitesse)
A_fcn = matlabFunction(A, 'Vars', [x y z roll_ pitch_ yaw_ u v w p q r radius]);

stable_found = false;
max_essais = 5000000; % 5 millions d'essais
essais = 0;

fprintf('Recherche aléatoire continue en cours...\n');
fprintf('Plages : Angles [0, 1.57], Vitesses [0, 2]\n');

while ~stable_found && essais < max_essais
    essais = essais + 1;
    
    % Génération de valeurs aléatoires
    val_rll = 1.57 * rand;
    val_ptc = 1.57 * rand;
    val_yw  = 1.57 * rand;
    
    val_u = 2 * rand;
    val_v = 2 * rand;
    val_w = 2 * rand;
    val_p = 2 * rand;
    val_q = 2 * rand;
    val_r = 2 * rand;

    % Évaluation de la matrice A
    A_num = A_fcn(0, 0, 0, val_rll, val_ptc, val_yw, val_u, val_v, val_w, val_p, val_q, val_r, radius1);
    
    try
        % Placement de pôles
        K_place = place(A_num, B_num, P_targets);
        Ac = A_num - B_num * K_place;
        
        % Test 1 : stabilité
        if all(real(eig(Ac)) < 0)

            % Test 2 : Lyapunov
            P_mat = K_place' * R * K_place;
            Q_inverse = -(Ac' * P_mat + P_mat * Ac);

            % TEST 3 : P > 0
            if all(eig(Q_inverse) >= 0) && all(eig(P_mat) > 1e-9)
                
                stable_found = true;
                
                
                Q_final = P_mat;
                save("calcul_Q", "Q_final");
                
                % Visualisation du résultat
                figure;
                pzmap(ss(Ac, B_num, eye(size(Ac)), 0));
                title(sprintf('Pôles en boucle fermée à l''essai %d', essais));
                grid on;
            end
        end

    catch
        % Passe si système non commandable ou erreur numérique
    end
    
    % Affichage de la progression
    if mod(essais, 10000) == 0
        fprintf('Essais : %d (recherche toujours en cours...)\n', essais);
    end
end

if ~stable_found
    disp('Aucune solution stable n''a été trouvée dans les plages spécifiées.');
end