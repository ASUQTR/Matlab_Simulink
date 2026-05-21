function draw_auv(pos, euler_rad, scale)
%DRAW_AUV  Dessine un AUV simplifie avec triedre d'orientation RGB.
%
%   draw_auv(pos, euler_rad)
%   draw_auv(pos, euler_rad, scale)
%
%   pos       - [x y z]  position monde
%   euler_rad - [roll pitch yaw]  en radians
%   scale     - longueur de reference en metres (defaut 0.25)
%
%   Axes : X (rouge) = avant, Y (vert) = babord, Z (bleu) = haut

if nargin < 3, scale = 0.25; end

% Convention ZYX : eul2rotm attend [yaw pitch roll]
R = eul2rotm([euler_rad(3), euler_rad(2), euler_rad(1)], 'ZYX');

N = 28;                       % resolution angulaire
t = linspace(0, 2*pi, N)';   % colonne

color_hull = [0.18 0.42 0.82];

% ---- Corps cylindrique (axe local X, de -0.75 a +0.42) ----
r_h = 0.18 * scale;
Xh = repmat([-0.75, 0.42] * scale, N, 1);
Yh = r_h * cos(t) * [1 1];
Zh = r_h * sin(t) * [1 1];
surf_local(Xh, Yh, Zh, pos, R, color_hull);

% ---- Cone avant (de +0.42 a +0.92, rayon 0.18 -> 0) ----
Xn = repmat([0.42, 0.92] * scale, N, 1);
Yn = [r_h*cos(t), zeros(N,1)];
Zn = [r_h*sin(t), zeros(N,1)];
surf_local(Xn, Yn, Zn, pos, R, color_hull);

% ---- Capot arriere (disque ferme) ----
Xt = repmat([-0.75, -0.75] * scale, N, 1);
Yt = [r_h*cos(t), zeros(N,1)];
Zt = [r_h*sin(t), zeros(N,1)];
surf_local(Xt, Yt, Zt, pos, R, color_hull);

% ---- Derive dorsale (petit aileron sur le dessus) ----
fin_x = [-0.50, -0.10, -0.10, -0.50] * scale;
fin_y = [0,     0,     0,     0     ];
fin_z = [r_h,  r_h,  r_h+0.14*scale, r_h+0.10*scale];
pts = R * [fin_x; fin_y; fin_z] + pos(:);
patch(pts(1,:), pts(2,:), pts(3,:), color_hull*0.8, 'EdgeColor', 'none', 'FaceAlpha', 0.9);

% ---- Triedre RGB (X=rouge avant, Y=vert babord, Z=bleu haut) ----
L = 0.60 * scale;
ax_colors  = {[0.9 0.1 0.1], [0.1 0.75 0.1], [0.1 0.1 0.9]};
ax_labels  = {'X', 'Y', 'Z'};
for k = 1:3
    e_k = zeros(3,1); e_k(k) = 1;
    d   = R * (L * e_k);
    quiver3(pos(1), pos(2), pos(3), d(1), d(2), d(3), ...
        0, 'Color', ax_colors{k}, 'LineWidth', 2.5, 'MaxHeadSize', 0.55);
    tip = pos(:) + d * 1.20;
    text(tip(1), tip(2), tip(3), ax_labels{k}, ...
        'Color', ax_colors{k}, 'FontSize', 8, 'FontWeight', 'bold');
end

end

% ---- helper : transforme et affiche une surface locale ----
function surf_local(X, Y, Z, pos, R, color)
n   = numel(X);
pts = R * [X(:)'; Y(:)'; Z(:)'] + pos(:) * ones(1, n);
Xw  = reshape(pts(1,:), size(X));
Yw  = reshape(pts(2,:), size(Y));
Zw  = reshape(pts(3,:), size(Z));
surf(Xw, Yw, Zw, 'FaceColor', color, 'EdgeColor', 'none', 'FaceAlpha', 0.92);
end
