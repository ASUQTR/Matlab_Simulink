function p = params_inertie_emile()
% Variante : inertie calculee par Emile.
% Differe de params_nominal uniquement sur I_x, I_y, I_z.

p = params_nominal();

p.I_x = 0.5380;
p.I_y = 0.5057;
p.I_z = 0.5432;

end
