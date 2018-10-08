function Jf = eval_Jf_SquareDiagonal(x,u,p)
% example of function that evaluates the Jacobian
% of vector field f() at state x, with inputs u.
% p is a structure containing all model parameters
% in particular p.A and p.B and p.d
% in state space model dx/dt = Ax+ sqd(x)+ Bu
% where the i-th component of d(x) is just sqd_i * (x[i])^2
%
% Jf=eval_Jf_SquareDiagonal(x,u,p);

% copyright Luca Daniel, MIT 2018

Jf = p.A  + diag(2 * p.sqd .* x);
