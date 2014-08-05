function [mat,reorder] = fir_mat_reorder(order)





%%%% Reoreder matrix fonction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% example %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If original order vector = [1 2 3 4...n]. the number of comparison in matrix 
% m= n-by-n is k= ((n*n)-n)/2.
% So we have K comparisons vector in the original order (e.g [1 2 3 4 5 6...K].
% If we reorder the original vector (eg [1 4 3 2...n]), comparison vector order 
% has to be changed with respect to the original order vector (e.g [3 2 1 6 5 4...K].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



n = length(order);
table = zeros(n,1);

a = n-1;
for i = 2:n-1
  table(i) = table(i-1)+a;
  a = a-1;
end

mat = diag(order);
for i = 1:n
  for j = i+1:n
    I = min(order(i),order(j));
    J = max(order(i),order(j));
    mat(i,j) = table(I) + J - I;
  end
end

reorder=[];
for i=1:size(mat,1);
 reorder= [reorder mat(i,i+1:end)];
end


endfunction
