%% calcul instabilité (en progret)




% =====================
% DONNÉES PROVENANT DE SIMULINK
% =====================
% A_log : timeseries contenant A(t)
% K_log : timeseries contenant K(t)
% B : matrice d'entrée (constante)


% Exemple :
% A_log.Time -> vecteur temps
% A_log.Data -> matrice [n x n x N]
    
Q = out.Q_s.signals.values;
R = out.R_s.signals.values;

A = out.A_s.signals.values;
K = out.K_s.signals.values;


% Définition de B (à adapter à ton système)
B = out.B_s.signals.values; % EXEMPLE



% =====================
% INITIALISATION
% =====================


t = out.A_s.time;
N = length(t);
n = size(out.A_s.signals.values,1);


poles = zeros(n, N);

% for k = 1:N
% K(:,:,k) = lqr(A(:,:,k), B(:,:,k), Q, R);
% end
% =====================
% CALCUL DES PÔLES GELÉS
% =====================


for k = 1:N
A_k = out.A_s.signals.values(:,:,k);
K_k = K(:,:,k);
B_k = B(:,:,k);
Acl = A_k - B_k*K_k; % matrice en boucle fermée
poles(:,k) = eig(Acl); % pôles instantanés
end


% =====================
% TRACE DES PÔLES
% =====================


figure
hold on
for i = 1:n
plot(real(poles(i,1:length(poles))), imag(poles(i,1:length(poles))), 'x')
end


grid on
xlabel('Partie réelle')
ylabel('Partie imaginaire')
title('Évolution des pôles gelés du système LQR')


% Ligne de stabilité (continu)
xline(0,'--r')


legend('Pôles','Frontière de stabilité')


% =====================
% VÉRIFICATION DE STABILITÉ
% =====================

nb_pole_instable = 0;

if all(real(poles(:)) < 0)
    
disp('Le système est localement stable pour tout t')
else
disp('Attention : instabilité locale détectée')
end

for erreur = 1:N
    for erreur2 = 1:12
        if real(poles(erreur2,erreur)) > 0
        nb_pole_instable = nb_pole_instable+1;
        end
    end
end
disp("pôle instable : " + nb_pole_instable + " / " + length(poles(:)) + " | " + 100*nb_pole_instable/length(poles(:)) + " %")

%%
poles_continue_reel = zeros(n,N);
poles_continue_imaginaire = zeros(n,N);

for i = 1:n
    for deux = 1:N
        poles_continue_reel(i,deux) = real(poles(i,deux));
        poles_continue_imaginaire(i,deux) = imag(poles(i,deux));
    end
end

% hold off
% figure()
% hold on
% for i = 1:n
% plot(poles_continue_reel(2,1:1000), poles_continue_imaginaire(2,1:1000), 'x')
% end
% xline(0,'--r')