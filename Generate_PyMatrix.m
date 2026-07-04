clear all
close all
clc
%% Note
%Remplacer les ^ par des ** dams le .txt
%cos(roll_) -> cos_roll
%cos(pitch_) -> cos_pitch
%cos(yaw_) -> cos_yaw

%sin(roll_) -> sin_roll
%sin(pitch_) -> sin_pitch
%sin(yaw_) -> sin_yaw

%tan(roll_) -> tan_roll
%tan(pitch_) -> tan_pitch
%tan(yaw_) -> tan_yaw

%% Parameters
    
    syms x y z roll_ pitch_ yaw_ u v w p q r du0 du1 du2 du3 du4 du5 du6 du7 % state and control input
    
    syms mass Ix Iy Iz Ixy Ixz Iyz mzg %Mrd matrix
    
    syms Xu_dot Yv_dot Zw_dot Kp_dot Mq_dot Nr_dot Xq_dot Yp_dot % Ma matrix
    
    syms Xu Xuu Yv Yvv Zw Zww Kp Kpp Mq Mqq Nr Nrr % Damping matrices
    
    syms gx gy gz bx by bz gravity radius water_density displaced_water_volume % G matrix
    
    % Position du sous-marin
    pose = [x y z roll_ pitch_ yaw_];
    
    %Vitesse du sous-marin
    vel = [u v w p q r];
    
    % Vecteur d'état du sous-marin
    state = sym(zeros(12,1));
    state(1:6) = transpose(pose);
    state(7:12) = transpose(vel);
    
    % Throttle des moteurs symbolique
    du = [du0; du1; du2; du3; du4; du5; du6; du7];
    
    % Centre de gravité et de flottabilité symbolique
    gravity_center = [gx gy gz];
    buoyancy_center = [bx by bz];

    % Rigid body inertia matrix Page 66 ou 192
    Mrb = sym([ mass,  0.0,  0.0,  0.0,  0.0,  0.0;
                0.0,  mass,  0.0,  0.0,  0.0,  0.0;
                0.0,   0.0, mass,  0.0,  0.0,  0.0;
                0.0,   0.0,  0.0,   Ix,  -Ixy,  -Ixz;
                0.0,   0.0,  0.0,  -Ixy,   Iy,  -Iyz;
                0.0,   0.0,  0.0,  -Ixz,  -Iyz,   Iz]);
            
    % Added mass matrix Page 11
    Ma = sym([  -Xu_dot,     0.0,    0.0,     0.0,     0.0,   0.0;
                0.0,     -Yv_dot,    0.0,     0.0,     0.0,   0.0;
                0.0,        0.0, -Zw_dot,     0.0,     0.0,   0.0;
                0.0,        0.0,    0.0,  -Kp_dot,     0.0,   0.0;
                0.0,        0.0,    0.0,     0.0,  -Mq_dot,   0.0;
                0.0,        0.0,    0.0,     0.0,     0.0, -Nr_dot]);
                
    linear_damping = sym([  -Xu, 0.0, 0.0, 0.0, 0.0, 0.0;
                            0.0, -Yv, 0.0, 0.0, 0.0, 0.0;
                            0.0, 0.0, -Zw, 0.0, 0.0, 0.0;
                            0.0, 0.0, 0.0, -Kp, 0.0, 0.0;
                            0.0, 0.0, 0.0, 0.0, -Mq, 0.0;
                            0.0, 0.0, 0.0, 0.0, 0.0, -Nr]);
                        
                        
                        
    quadratic_damping = sym([ -Xuu,  0.0,  0.0,  0.0,  0.0,  0.0;
                               0.0, -Yvv,  0.0,  0.0,  0.0,  0.0;
                               0.0,  0.0, -Zww,  0.0,  0.0,  0.0;
                               0.0,  0.0,  0.0, -Kpp,  0.0,  0.0;
                               0.0,  0.0,  0.0,  0.0, -Mqq,  0.0;
                               0.0,  0.0,  0.0,  0.0,  0.0, -Nrr]);
                           
    thrust_position = [    0.2987,  0.2130, 0;  %thruster 1
                           0.2987, -0.2130, 0;  %thruster 2
                          -0.1073,  0.2725, 0;  %thruster 3
                          -0.1073, -0.2725, 0;  %thruster 4
                           0.1073,  0.2725, 0;  %thruster 5
                           0.1073, -0.2725, 0;  %thruster 6
                          -0.2987,  0.2130, 0;  %thruster 7
                          -0.2987, -0.2130, 0]; %thruster 8
     
    % thrust_direction = [     -0.707,   0.707,    0;   %thruster 1
    %                          -0.707,  -0.707,    0;   %thruster 2
    %                          0.0,      0.0,      -1;   %thruster 3
    %                          0.0,      0.0,      -1;   %thruster 4
    %                          0.0,      0.0,      -1;   %thruster 5
    %                          0.0,      0.0,      -1;   %thruster 6
    %                          0.707,    0.707,    0;   %thruster 7
    %                          0.707,   -0.707,    0];  %thruster 8

    thrust_direction = [     0.707,   -0.707,    0;   %thruster 1
                             0.707,  0.707,      0;   %thruster 2
                             0.0,      0.0,      1;   %thruster 3
                             0.0,      0.0,      1;   %thruster 4
                             0.0,      0.0,      1;   %thruster 5
                             0.0,      0.0,      1;   %thruster 6
                             -0.707,  -0.707,    0;   %thruster 7
                             -0.707,   0.707,    0];  %thruster 8
                       
      %% Dynamics
      M = sym(Mrb + Ma);
      
      C = sym(coriolisMatrix(M,state));
      
      D = sym(linear_damping + quadratic_damping);
      
      G = sym(gravityMatrix(state, mass, gravity, displaced_water_volume, water_density, gravity_center, buoyancy_center));
      
      %Non-linear dynamics funciton f (state-space)
      %Page 138 of computer-aided Control System Design, Chin 2013
      
      f1 = sym(zeros(12,12));
      f1(1:6,7:12) = J(state);
      f1(7:12,7:12) = -inv(M)*(C + D);
      
      f2 = sym(zeros(12,1));
      f2(7:12,1) = -inv(M)*G;
      
      f = f1*state + f2;
      
      %% Control
      thrust_allocation = zeros(8,6);
      thrust_allocation(1:8,1:3) = thrust_direction; %map XYZ Froces
      
      for i = 1:8
           thrust_allocation(i,4:6) = cross(thrust_position(i,1:3),thrust_direction(i,1:3)); %maps XYZ torques
      end
      
      thrust_allocation = transpose(thrust_allocation);
      
      %control input u
      u_control = sym(zeros(1,8));
      
      for i = 1:8
          u_control(i) = du(i);%*abs(du(i));
      end
      
      tau = thrust_allocation*transpose(u_control);
      
      %control function g
      %page 138 of computer-aided Control System Design, Chin 2013
      g = sym(zeros(12,1));
      g(7:12,1) = M\tau;
      
      %% State space
      
      %non-linear state space model F_dot
      F_dot = sym(zeros(12,1));
      
      for i = 1:length(f)
          F_dot(i,1) = f(i,1) + g(i,1);
      end

%This function populates the symbolic state space model with the robot's
%actual parameters, and generates the lqr cost matrices

syms x y z roll_ pitch_ yaw_ u v w p q r du0 du1 du2 du3 du4 du5 du6 du7 displaced_water_volume

%Gravity matrix parameters
% displaced_water_volume = 0.045;
% displaced_water_volume = 0.01; 
% displaced_water_volume = 0.0147;
displaced_water_volume = 0.024;
water_density = 1000.0;
gx = 0;
gy = 0;
gz = 0;
bx = 0;
by = 0;
bz = -0.05;
gravity = 9.81;

%Mass matrix parameters
mass = 23.9; % original (28)
Ix = 0.578; % original (0.35)
Iy = 0.645; % original (0.36)
Iz = 0.937; % original (0.62)
Ixy = 0;
Ixz = 0;
Iyz = 0;
mzg = mass*abs(gz);

% Added mass matrix parameters
% Dimensions du sous-marin
a = 0.30;  % demi-longueur X [m]
b = 0.25;  % demi-largeur  Y [m]
c = 0.17;  % demi-hauteur  Z [m]

% Coefficients de Lamb (ellipsoïde)
e      = sqrt(1 - (b/a)^2);
alpha0 = (2*(1-e^2)/e^3) * (0.5*log((1+e)/(1-e)) - e);
beta0  = (1/e^2) - (1-e^2)/(2*e^3) * log((1+e)/(1-e));
k1     = alpha0 / (2 - alpha0);
k2     = beta0  / (2 - beta0);

% Masse ajoutée
Xu_dot = -k1 * mass;
Yv_dot = -k2 * mass;
Zw_dot = -k2 * mass;
Kp_dot = -0.0;
Mq_dot = -(0.2 * mass * (a^2 - b^2)^2 * (k2-k1) / max((a^2-b^2), 1e-9));
Nr_dot = -Mq_dot;
Xq_dot = -0.0;
Yp_dot = -0.0;

% Damping matrix parameters

    % Linear Damping
    % Xu = 4.03;
    % Yv = 6.22;
    % Zw = 5.15; % original (-5.15)
    % Kp = 0.07;
    % Mq = 0.07;
    % Nr = 0.07;

    Xu = -23.9201;
    Yv = -43.6523;
    Zw = -52.9362;
    Kp = -1.0752;
    Mq = -1.4659;
    Nr = -1.3090;
    

    % Quadratic Damping
    % Xuu = 18.18;
    % Yvv = 21.66;
    % Zww = 36.99;
    % Kpp = 1.55;
    % Mqq = 1.55;
    % Nrr = 1.55;

    Xuu = -26.7035;
    Yvv = -80.1106;
    Zww = -117.8097;
    Kpp = -3.1250;
    Mqq = -5.0470;
    Nrr = -2.9207;
        
%     % Linear Damping
%     Xu = 4.35;
%     Yv = 8.58;
%     Zw = 8.58; % original (-5.15)
%     Kp = 1.5;
%     Mq = 3;
%     Nr = 3;
% 
% % Quadratic Damping
%     Xuu = 87.07;
%     Yvv = 171.60;
%     Zww = 171.60;
%     Kpp = 10;
%     Mqq = 18.00;
%     Nrr = 18.00;

% Substitute constant parameters
state_dot = subs(F_dot);
G = subs(G);

% rayon

radius = 0.26;
% The system is linearized via the jacobian
df_dstate = jacobian(state_dot,state);
A = df_dstate;
df_dcontrol(du0, du1, du2, du3, du4, du5, du6, du7) = jacobian(state_dot,transpose(du));
df_dcontrol = df_dcontrol(0, 0, 0, 0, 0, 0, 0, 0);
B = df_dcontrol;
% Gravity matrix G

save("ABmatrice","A","B")


%% Print in TXT file

fid = fopen( 'Matrix_centrer.txt', 'wt' );
% A matrix
for i = 1:12
    for j = 1:12
    fprintf( fid, 'Am[%1.0f][%1.0f] = %s\n',i-1,j-1, char(vpa(df_dstate(i,j))));
    end
end
fprintf(fid,'\n\n\n');
for i = 1:12
    for j = 1:8
    fprintf( fid, 'Bm[%1.0f][%1.0f] = %s\n',i-1,j-1, char(vpa(B(i,j))));
    end
end
fprintf(fid,'\n\n\n');
for i = 1:6
  fprintf( fid, 'Gm[%1.0f] = %s\n',i-1, char(vpa(G(i))));
end
fclose(fid);

%% Sub-functions

function [ret] = s(vec)
% Creates the 3x3 anti-symmetric matrix from a 3 elements input vector
% page 20 of handbook of marine craft Fossen 2011
    ret = [    0.0, -vec(3),  vec(2);
            vec(3),     0.0, -vec(1);
           -vec(2),  vec(1),    0.0];
end

function [C] = coriolisMatrix(M,state)
    v1 = state(7:9);
    v2 = state(10:12);
    
    s1 = s(M(1:3,1:3)*v1 + M(1:3,4:6)*v2);
    s2 = s(M(4:6,1:3)*v1 + M(4:6,4:6)*v2);
    C = sym(zeros(6,6));
    C(1:3,4:6) = -s1;
    C(4:6,1:3) = -s1;
    C(4:6,4:6) = -s2;

end

function [G, test] = gravityMatrix(state,mass,gravity,displaced_water_volume,water_density,gravity_center,buoyancy_center)
%create the gravity matrix Page 60 of handbook of marine craft 2011

    [phi, theta, psi] = deal(state(4), state(5), state(6));
    
    %weight, W and buoyancy force, F
    W = mass*gravity; %Newton
    
    % F_buoyancy = ((4/3)*pi*radius^3)*water_density*gravity;
    F_buoyancy = displaced_water_volume*water_density*gravity;
    
    %Gravity center position in the robot fixed frame (gx, gy, gz) [m]
    gx = gravity_center(1);
    gy = gravity_center(2);
    gz = gravity_center(3);
    
    %Gravity center position in the robot fixed frame (bx, by, bz) [m]
    bx = buoyancy_center(1);
    by = buoyancy_center(2);
    bz = buoyancy_center(3);
    
    G = [(W - F_buoyancy)*sin(theta);
        - (W - F_buoyancy)*cos(theta)*sin(phi);
        - (W - F_buoyancy)*cos(theta)*cos(phi);
        -(gy*W - by*F_buoyancy)*cos(theta)*cos(phi) + (gz*W - bz*F_buoyancy)*cos(theta)*sin(phi);
        (gz*W - bz*F_buoyancy)*sin(theta) + (gx*W - bx*F_buoyancy)*cos(theta)*cos(phi);
        -(gx*W - bx*F_buoyancy)*cos(theta)*sin(phi) - (gy*W - by*F_buoyancy)*sin(theta)];
    test = [W, F_buoyancy, W - F_buoyancy];
    
end
      
function [ret] = J(state)
% Transforms from BODY to NED coordinates Page 26 of Handbook of marine
% craft 2011
    [phi, theta, psi] = deal(state(4), state(5), state(6));
    
    %The velocity is transformed from BODY to NED cooridinate system
    vel_NED = [cos(psi)*cos(theta), -sin(psi)*cos(phi)+cos(psi)*sin(theta)*sin(phi),  sin(psi)*sin(phi)+cos(psi)*cos(phi)*sin(theta);
               sin(psi)*cos(theta), cos(psi)*cos(phi) + sin(phi)*sin(theta)*sin(psi), sin(theta)*sin(psi)*cos(phi) - cos(psi)*sin(phi);
               -sin(theta),         cos(theta)*sin(phi),                              cos(theta)*cos(phi)];
    %Angular velocity is transformed from body to NED coordinate system
    angular_vel_NED = [ 1.0, sin(phi)*tan(theta), cos(phi)*tan(theta);
                        0.0, cos(phi), -sin(phi);
                        0.0, sin(phi)/cos(theta), cos(phi)/cos(theta)];
                    
    [ret] = sym(zeros(6,6));
    
    ret(1:3,1:3) = vel_NED;
    ret(4:6,4:6) = angular_vel_NED;
    
end


