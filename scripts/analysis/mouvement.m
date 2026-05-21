Position    = out.Position.signals.values;
time_pos    = out.Position.time;

fig = figure('Name', 'Animation AUV');
set(fig, 'Position', get(0, 'Screensize'));

% Trace de la trajectoire complete (reference grisee)
if evalin('base', 'exist(''out'',''var'')')
    try
        target = out.target.signals.values;
        x_ref  = target(:,1);
        y_ref  = target(:,2);
    catch
        x_ref = []; y_ref = [];
    end
else
    x_ref = []; y_ref = [];
end

sampleCount = size(Position, 1);
step        = max(1, round(sampleCount / 300));   % ~300 frames max

for ii = 1:step:sampleCount
    clf

    hold on

    % Trace du chemin parcouru
    plot3(Position(1:ii,1), Position(1:ii,2), Position(1:ii,3), ...
        '-', 'Color', [0.55 0.55 0.55], 'LineWidth', 1.2);

    % Trace de la reference (si disponible)
    if ~isempty(x_ref)
        n_ref = min(ii, length(x_ref));
        plot3(x_ref(1:n_ref), y_ref(1:n_ref), zeros(n_ref,1), ...
            'r--', 'LineWidth', 1.0);
    end

    % AUV a la position courante
    xyz   = double(Position(ii, 1:3));
    euler = double(Position(ii, 4:6));   % [roll pitch yaw] en rad
    draw_auv(xyz, euler, 0.25);

    % Axes et apparence
    lim = 3.5;
    axis([-lim lim -lim lim -lim lim]);
    xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
    grid on;
    camlight('headlight');
    material dull;
    view(45, 30);
    title(sprintf('AUV — t = %.1f s  (pos: %.2f, %.2f, %.2f m)', ...
        time_pos(ii), xyz(1), xyz(2), xyz(3)));

    drawnow
end
