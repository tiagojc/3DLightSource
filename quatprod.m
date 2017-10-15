function Z = quatprod(X, Y, opt)
% FUNCTION X = quatprod(X,Y)
%   Computes the quaternion product between quaternions X and Y.  
%   The rows of X and Y are 1x4 quaternion vectors.
%
% PARAMETERS
%   X   :  An Nx4 matrix of quaternions
%   Y   :  An Nx4 matrix of quaternions
%   opt :  (Optional) if true, computes X*Y*bar(X), the
%                     quaternion rotation equation
%
% RETURNS
%   Z  : The quaternion products
%

  Z = [ X(:,1).*Y(:,1) - sum(X(:,2:end).*Y(:,2:end),2)   ...    % The constant term of the quaternions
        repmat(X(:,1),1,3).*Y(:,2:end)  + ...
        repmat(Y(:,1),1,3).*X(:,2:end)  + ...
        cross(X(:,2:end), Y(:,2:end), 2)
      ];
 
  if exist('opt') && opt
    Z = quatprod(Z, X*diag([1 -1 -1 -1]));
  end

end
