close all

Position = out.Position.signals.values;
sensors = out.sensors.signals.values;
thrust = out.Thrust.signals.values;
target = out.target.signals.values;
time = out.Thrust.time;
% z = sensors(:,10);
x = Position(:,1);
y = Position(:,2);
z = Position(:,3);
roll_ = Position(:,4);
pitch_ = Position(:,5);
yaw_ = Position(:,6);
M1 = thrust(:,1);
M2 = thrust(:,2);
M3 = thrust(:,3);
M4 = thrust(:,4);
M5 = thrust(:,5);
M6 = thrust(:,6);
M7 = thrust(:,7);
M8 = thrust(:,8);
figure(1)
hold on
plot(x,y)

carrer = 1;
pentagone = 0;
ligne = 0;
cercle = 0;
cercleX = 2*sin(0:0.01:2*pi); cercleY = 2*cos(0:0.01:2*pi)-2;

%plot(time,target(:,1))
if (carrer == 1)

    plot(0,0,'r*')
    plot(2,0,'r*')
    plot(2,2,'r*')
    plot(0,2,'r*')
    hold off
    title('Réponse au déplacement 2m x 2m en XY')
    xlabel('Position du sous-marin en X')
    ylabel('Position du sous-marin en Y')
    grid on
elseif (pentagone == 1)
    plot(0.000 , 0.000,'r*')
    plot(2.000 , 0.000,'r*')
    plot(2.618 , 1.902,'r*')
    plot(1.000 , 3.078,'r*')
    plot(-0.618, 1.902,'r*')
    hold off
    title('Réponse au déplacement d un pentagone en XY')
    xlabel('Position du sous-marin en X')
    ylabel('Position du sous-marin en Y')
    grid on
elseif (ligne == 1)
    plot(0,0,'r*')
    plot(2,0,'r*')
    hold off
    title('Réponse au déplacement d une ligne en x')
    xlabel('Position du sous-marin en X')
    ylabel('Position du sous-marin en Y')
    % ylim([-1 1]);
elseif (cercle == 1)
    plot(0,0,'r*')
    plot(0,-4,'r*')
    plot(2,-2,'r*')
    plot(-2,-2,'r*')
    plot(cercleX,cercleY)
    hold off
    title('Réponse au déplacement d un cercle en XY')
    xlabel('Position du sous-marin en X')
    ylabel('Position du sous-marin en Y')
    ylim([-4.5 0.5]);
    xlim([-2.5 2.5]);
    
end



% plot3(x, y, z)
% zlim([-1 1])
% xlim([-2 2])
% ylim([-2 2])

figure(2)
hold on
plot(time,x)
hold off
title('Réponse au déplacement 2m x 2m en XY')
ylabel('Position en X')
xlabel('Temps (s)')

grid on
figure(3)
plot(time,y)
title('Réponse au déplacement 2m x 2m en XY')
ylabel('Position en Y')
xlabel('Temps (s)')

figure(3)
plot(time,z)
title('Réponse au déplacement 2m x 2m en XY')
ylabel('Position en Z')
xlabel('Temps (s)')
ylim([-1 1]);

% figure(4)
% plot(time,z)
% title('Réponse au déplacement 2m x 2m en 40 secondes')
% ylabel('Position en Z')
% xlabel('Temps (s)')
% figure(5)
% plot(time,thrust)
% title('Réponse au déplacement 2m x 2m en 40 secondes')
% ylabel('Puissance des moteurs en Newton')
% xlabel('Temps (s)')

%%


