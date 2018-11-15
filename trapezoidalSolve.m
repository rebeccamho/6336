function [F J] = trapezoidalSolve(f,t,dt,phi,gamma)

[F,J] = f(phi,t);
F = phi - dt/2*F - gamma; 
sizeJ = size(J,1);
J = eye(sizeJ) - dt/2*J;

end