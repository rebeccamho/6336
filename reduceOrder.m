% reduceOrder.m
% Takes a system defined by matrices A, B, and C and returns the same
% matrices for a system of the specified order.
% Inputs: A (node relationships), B (inputs), C (outputs), order, k (model
% is too big so can only calculate k eigenvalues)
% Outputs: Reduced A, B, and C
function [At,Bt,Ct] = reduceOrder(A,B,C,order,k)

[V,D] = eigs(A,k);

val = diag(D);

Bt = V'*B;
Ct = V'*C;
effect = zeros(1,length(val));
for i = 1:length(val)
    effect(i) = abs((Ct(i)*Bt(i))/val(i));
end
[effect_sort,index] = sort(effect,'descend');
% [val_sort,index] = sort(abs(val),'ascend');

Vq = V(:,index(1:order));
At = Vq'*A*Vq;
Bt = Vq.'*B;
Ct = C.'*Vq;
Ct = Ct';
% Ct = Vq'*C*Vq;

% function [A_, b_, c_, sys] = reduceOrder(A, b, c, q, k)
%   % Inputs
%   % d/dt x = Ax + bu(t)
%   % y = c^T x
%   %
%   % A: system matrix
%   % b: u(t) multipliers
%   % c: output selection vector
%   % q: number of vectors to include in reduced model
%   %
% 	% Eigenvector truncation MOR
% 
%   % Compute eigenvalues and eigenvectors
%   [V, D] = eigs(A,k);
% 
%   % Rotate b and c in eigenvector space
%   b_ = V.'*b;
%   c_ = c.'*V;
% 
%   % Check |c_i*b_i/lambda_i|
%   metric = c_.'.*b_./diag(D);
%   metric = abs(metric);
%   [~, I] = sort(metric, 'descend');
% 
%   % Select important vectors
%   Vq = V(:, I(1:q));
% 
%   % Reduce equation to q x q
%   A_ = Vq.'*A*Vq;
%   b_ = Vq.'*b;
%   c_ = c.'*Vq;
%   c_ = c_';
% end


