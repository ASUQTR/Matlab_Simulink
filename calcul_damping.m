clc;
clear;
close all;

%% =====================================================
%  MINI ROV / MINI SOUS-MARIN
% ======================================================

%% -----------------------------------------------------
% PHYSICAL PARAMETERS
% ------------------------------------------------------

mass = 23.9;                     % kg
water_density = 1000.0;          % kg/m^3
gravity = 9.81;                  % m/s^2

radius = 0.26;                   % m
length = 0.55;                   % m

diameter = radius * 2;

displaced_water_volume = 0.0239; % m^3

%% =====================================================
% GEOMETRY
% ======================================================

% Frontal area (X direction)
Ax = pi * radius^2;

% Side areas (Y and Z directions)
Ay = length * diameter;
Az = Ay;

%% =====================================================
% DRAG COEFFICIENTS
% ======================================================

Cd_x = 0.82;
Cd_y = 1.20;
Cd_z = 1.20;

%% =====================================================
% QUADRATIC DAMPING
% D = 0.5 * rho * Cd * Area
% ======================================================

Xuu = 0.5 * water_density * Cd_x * Ax;
Yvv = 0.5 * water_density * Cd_y * Ay;
Zww = 0.5 * water_density * Cd_z * Az;

%% =====================================================
% LINEAR DAMPING
% 5% of quadratic damping
% ======================================================

Xu = 0.05 * Xuu;
Yv = 0.05 * Yvv;
Zw = 0.05 * Zww;

%% =====================================================
% ROTATIONAL DAMPING
% ======================================================

Kp = 1.5;
Mq = 3.0;
Nr = 3.0;

Kpp = 10.0;
Mqq = 18.0;
Nrr = 18.0;

%% =====================================================
% BUOYANCY
% ======================================================

buoyancy_force = water_density * gravity * displaced_water_volume;
weight_force = mass * gravity;

net_vertical_force = buoyancy_force - weight_force;

%% =====================================================
% ADDED MASS
% ======================================================

Ix = 0.578;
Iy = 0.645; 
Iz = 0.937;

added_mass = water_density*displaced_water_volume;
mass_ratio = added_mass/mass;
Xudot = mass_ratio*mass;
Yvdot = mass_ratio*mass;
Zwdot = mass_ratio*mass;
Kpdot = mass_ratio*Ix;
Mqdot = mass_ratio*Iy;
Nrdot = mass_ratio*Iz;

%% =====================================================
% DISPLAY RESULTS
% ======================================================

fprintf('\n');
fprintf('============================================\n');
fprintf(' MINI ROV PARAMETERS\n');
fprintf('============================================\n');

fprintf('\n');
fprintf('Mass                         : %.2f kg\n', mass);
fprintf('Water Density                : %.2f kg/m^3\n', water_density);

fprintf('\n');
fprintf('Radius                       : %.2f m\n', radius);
fprintf('Length                       : %.2f m\n', length);

fprintf('\n');
fprintf('Front Area Ax                : %.4f m^2\n', Ax);
fprintf('Side Area Ay                 : %.4f m^2\n', Ay);

%% -----------------------------------------------------
% DAMPING
% ------------------------------------------------------

fprintf('\n');
fprintf('============================================\n');
fprintf(' LINEAR DAMPING\n');
fprintf('============================================\n');

fprintf('Xu                            = %.2f\n', Xu);
fprintf('Yv                            = %.2f\n', Yv);
fprintf('Zw                            = %.2f\n', Zw);

fprintf('Kp                            = %.2f\n', Kp);
fprintf('Mq                            = %.2f\n', Mq);
fprintf('Nr                            = %.2f\n', Nr);

fprintf('\n');
fprintf('============================================\n');
fprintf(' QUADRATIC DAMPING\n');
fprintf('============================================\n');

fprintf('Xuu                           = %.2f\n', Xuu);
fprintf('Yvv                           = %.2f\n', Yvv);
fprintf('Zww                           = %.2f\n', Zww);

fprintf('Kpp                           = %.2f\n', Kpp);
fprintf('Mqq                           = %.2f\n', Mqq);
fprintf('Nrr                           = %.2f\n', Nrr);

%% -----------------------------------------------------
% BUOYANCY
% ------------------------------------------------------

fprintf('\n');
fprintf('============================================\n');
fprintf(' BUOYANCY\n');
fprintf('============================================\n');

fprintf('Buoyancy Force               = %.2f N\n', buoyancy_force);
fprintf('Weight Force                 = %.2f N\n', weight_force);
fprintf('Net Vertical Force           = %.2f N\n', net_vertical_force);

if abs(net_vertical_force) < 5
    fprintf('Status                       = Neutral Buoyancy\n');
elseif net_vertical_force > 0
    fprintf('Status                       = Floating Upward\n');
else
    fprintf('Status                       = Sinking\n');
end

%% -----------------------------------------------------
% ADDED MASS
% ------------------------------------------------------

fprintf('\n');
fprintf('============================================\n');
fprintf(' ADDED MASS\n');
fprintf('============================================\n');

fprintf('Xudot                         = %.2f\n', Xudot);
fprintf('Yvdot                         = %.2f\n', Yvdot);
fprintf('Zwdot                         = %.2f\n', Zwdot);

fprintf('Kpdot                         = %.2f\n', Kpdot);
fprintf('Mqdot                         = %.2f\n', Mqdot);
fprintf('Nrdot                         = %.2f\n', Nrdot);

fprintf('\n');
fprintf('============================================\n');
fprintf(' END\n');
fprintf('============================================\n');