function x = enorm(M, p)
% FUNCTION x = enorm(M, p)
%   Computes the norm of each column of matrix M.  If there are multiple columns
%   computes the norm of each column.  Parameters are identical to Matlab 
%   norm(.) function.
%
%   See help norm for details on the options that you may specify.
%
% PARAMETERS
%   M : A MxN matrix or Mx1 vector.  Norm is computed along columns. 
%   p : (Optional) The type of norm to compute.  See help norm
%
% RETURNS
%   X : The norms, a 1xN vector
%

  if ~exist('p', 'var')
    x = arrayfun(@(x) norm(M(:,x)), 1:size(M,2));
  else
    x = arrayfun(@(x) norm(M(:,x),p), 1:size(M,2));
  end

end