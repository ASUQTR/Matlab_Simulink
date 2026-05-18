Position = out.Position.signals.values;
sensors = out.sensors.signals.values;
% z = sensors(:,10);
% x = Position(:,1);
% y = Position(:,2);
% z = Position(:,3);
% plot3(x, y, z)
SubFilePath = fullfile(matlabroot, 'toolbox', 'shared', 'robotics', 'robotcore', 'meshes');

sampleCount = size(Position, 1);
for ii = 1:50:sampleCount
    X_Y_Z = [Position(ii,1) Position(ii,2) Position(ii,3)];
 %   X_Y_Z = [Position(ii,1) Position(ii,2) sensors(ii,10)];
    Phi_Theta_psi = [Position(ii,4) Position(ii,5) Position(ii,6)];
    q_Phi_Theta_psi = eul2quat(Phi_Theta_psi);
    
            plotTransforms(X_Y_Z, q_Phi_Theta_psi,'MeshColor',[0.29 0.49 0.88], 'MeshFilePath', 'fixedwing.stl')
%               plotTransforms(X_Y_Z, q_Phi_Theta_psi,'MeshColor',[1 0 0], 'MeshFilePath', 'fixedwing.stl')
    
    axis([-3 3 -3 3 -3 3])
    %axis([-1 20 -1 20 -10 2])
    xlabel('x [m]');
    ylabel('y [m]');
    zlabel('z [m]');
    grid on
    light
%     view([0 90])
    set(gcf, 'Position', get(0, 'Screensize'));
    
    pause(0.00000000000000000001);
    %disp(ii)
end





