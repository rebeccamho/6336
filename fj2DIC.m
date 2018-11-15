function [F J] = fj2DIC(x,t,A_mat,U_vec)

F = A_mat*x+U_vec; 
J = A_mat;

end