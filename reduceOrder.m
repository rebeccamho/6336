% reduceOrder.m
% Takes a system defined by matrices A, B, and C and returns the same
% matrices for a system of the specified order.
% Inputs: A (node relationships), B (inputs), C (outputs), order, k (model
% is too big so can only calculate k eigenvalues)
% Outputs: Reduced A, B, and C
function [At,Bt,Ct] = reduceOrder(A,B,C,order,k)

[V,D] = eigs(A,k);

val = diag(D);

% Bt = V'*B;
% Ct = V'*C;
% effect = zeros(1,length(val));
% for i = 1:length(val)
%     effect(i) = abs((Ct(i)*Bt(i))/val(i));
% end
% [effect_sort,index] = sort(effect,'descend');
[val_sort,index] = sort(abs(val),'descend');


Vq = V(:,index(1:order));
At = -Vq'*A*Vq;
Bt = -Vq'*B;
Ct = -Vq'*C*Vq;
