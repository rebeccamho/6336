function [xf, x] = newtonNd(fhand,x0,P)
% function newton1d(fhand,x0,itpause)
% from 6.336 Problem Set 4 Solutions Code
% 
% INPUTS:
%   fhand - function handle
%   x0 - initial guess
%   itpause - parameter for plotting
%
% Use Newton's method to solve the nonlinear function
% defined by function handle fhand with initial guess x0.
% Returns solution xf and all intermediate solutions
% x = [x1...xk...xf].
%
% itpause is parameter for plotting and defines the
% number of Newton steps that are plotted sequentially
% pauses between sub-steps.

tolf = 1e-9;         % function convergence tolerance
tolx = 1e-9;          % step convergence tolerance
maxIters = 500;       % max # of iterations
x00 = x0;             % initial guess

% Newton loop
for iter = 1:maxIters
    [f, J] = fhand(x0);          % evaluate function
    dx = (-J\f);                   % solve linear system
    nf(iter) = norm(f,Inf);      % norm of f at step k+1
    ndx(iter) = norm(dx,Inf);    % norm of dx at step k+1
    x(:,iter) = x0 + dx;         % solution x at step k+1
    x0 = x(:,iter);              % set value for next guess
    if nf(iter) < tolf && ndx(iter) < tolx % check for convergence
%             fprintf('Converged in %d iterations\n',iter);
        break
    end
end
xf = x(:,iter);

if iter == maxIters % check for non-convergence
    fprintf('Non-Convergence after %d iterations!!!\n',iter);
end

x = [x00,x];
% x_full = zeros(size(x,1),size(x,2),size(x,3)+1);
% x_full(:,:,1) = x00;
% x_full(:,:,2:end) = x;

end
