close all

Position = out.Position.signals.values;
sensors = out.sensors.signals.values;
thrust = out.Thrust.signals.values;
target = out.target.signals.values;
time = out.Thrust.time;

x = Position(:,1);
y = Position(:,2);
z = Position(:,3);

M1 = thrust(:,1);
M2 = thrust(:,2);
M3 = thrust(:,3);
M4 = thrust(:,4);
M5 = thrust(:,5);
M6 = thrust(:,6);
M7 = thrust(:,7);
M8 = thrust(:,8);

carrer = 1;
pentagone = 0;
ligne = 0;
cercle = 0;

figure(1)
hold on
plot(x, y, 'b', 'LineWidth', 1.2)
plot(target(:,1), target(:,2), 'r--')

if (carrer == 1)
    plot(0,0,'r*')
    plot(2,0,'r*')
    plot(2,2,'r*')
    plot(0,2,'r*')
    title('Reponse au deplacement 2m x 2m en XY')
elseif (pentagone == 1)
    plot(0.000 , 0.000,'r*')
    plot(2.000 , 0.000,'r*')
    plot(2.618 , 1.902,'r*')
    plot(1.000 , 3.078,'r*')
    plot(-0.618, 1.902,'r*')
    title('Reponse au deplacement d''un pentagone en XY')
elseif (ligne == 1)
    plot(0,0,'r*')
    plot(2,0,'r*')
    title('Reponse au deplacement d''une ligne en X')
elseif (cercle == 1)
    plot(0,0,'r*')
    plot(0,-4,'r*')
    plot(2,-2,'r*')
    plot(-2,-2,'r*')
    title('Reponse au deplacement d''un cercle en XY')
    ylim([-4.5 0.5]);
    xlim([-2.5 2.5]);
end

hold off
xlabel('Position du sous-marin en X')
ylabel('Position du sous-marin en Y')
grid on
axis equal

figure(2)
plot(time, x)
grid on
title('Position en X')
ylabel('Position en X')
xlabel('Temps (s)')

figure(3)
plot(time, y)
grid on
title('Position en Y')
ylabel('Position en Y')
xlabel('Temps (s)')

figure(4)
plot(time, z)
grid on
title('Position en Z')
ylabel('Position en Z')
xlabel('Temps (s)')
ylim([-1 1]);

figure(5)
motorNames = {'M1', 'M2', 'M3', 'M4', 'M5', 'M6', 'M7', 'M8'};
motorLimits = [min(thrust(:)), max(thrust(:))];
if motorLimits(1) == motorLimits(2)
    motorLimits = motorLimits + [-1 1];
end

set(gcf, 'Name', 'Commandes des moteurs', 'NumberTitle', 'off')
layout = tiledlayout(4, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
title(layout, 'Commandes individuelles des moteurs')

for motorIndex = 1:numel(motorNames)
    nexttile
    plot(time, thrust(:, motorIndex), 'LineWidth', 1.1)
    yline(0, 'k:')
    grid on
    title(sprintf('Moteur %s', motorNames{motorIndex}))
    ylim(motorLimits)
    if motorIndex > 6
        xlabel('Temps (s)')
    end
    if mod(motorIndex, 2) == 1
        ylabel('Force (N)')
    end
end
