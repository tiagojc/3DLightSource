function N = ts2n(s, p, K)
% FUNCTION N = ts2n(s, p, K)
%   Converts a tilt/slant value to a 3D normal.
%
% PARAMETERS
%   s  :  The tilt and slant vector, [tilt slant]
%   p  :  The point on the unit sensor
%   K  :  The camera parameters, [f px py]
%
% RETURNS
%   N  :  The 3D normal
%

  % Force them to use column vectors for points
  p = p(:);
  K = K(:);         % K is not a point, but K(2:3) are, so make K a column
  
  % Pull out tilt and slant values
  th = s(1);        % Tilt
  ph = s(2);        % Slant

  % Get camera data
  f  = K(1);        % Focal
  c  = K(2:3);      % Image center (principal point)
  V  = [p-c; -f];   % Camera vector.  Account for principal point
  V  = V/norm(V);   %  ..normalized
  
  % 2D vector in image
  n = [sind(th); cosd(th)];
  
  % Make 3D vector, Q, that they would want if their slant was 90 degrees.
  % This would be an occluding surface normal, and we are assuming that 
  % they are orthographically viewing the perspective image, so:
  Q = [n; (1/f)*n'*(p-c)];           
  Q = Q/norm(Q);
  
  % Compute the 3D tilt axis.  It's perpendicular to the camera ray and
  % the occluding normal
  A  = cross(Q,V);                  
  A  = A/norm(A);
  
  % Rotate camera vector V around the tilt axis
  % Specifically, rotate the vector that points to the CoP: -V
  N  = quatrot_local(ph, A, -V);  
  
end





function X = quatrot_local(th, ax, X)
% FUNCTION X = quatrot(th, ax, X)
%   Rotates points X by the quaternion defined by
%   angle th and axis ax.  
%
%   Note: ax need not have unit length
%   Note: If only one angle and axis is specified
%         all points are rotated by that.  
%         Otherwise 
%           size(th,2) == size(ax,2) == size(X,2)
%         must hold.
%
% PARAMETERS
%   th  :  Rotation angle, degrees, a 1xN vector
%   ax  :  A 3D axis, a 3xN matrix of row vectors
%   X   :  3D points, a 3xN matrix of points (in the rows)
%
% RETURNS
%   X  : The rotated points
%

  % Make the quaternion rotations
  ax = ax./repmat(sqrt(sum(ax.^2,1)),3,1);            % Make sure axes have unit length
  th = th(:)/2;                                       % Conversion from axis/angle to quaternion. See mathworld.
  Q  = [cosd(th) ax'.*sind([th th th])];              %  ..

  % If they passed only one rotation for multiple points...
  nx = size(X,2);
  if size(Q,1) == 1
    Q  = repmat(Q, nx, 1);
  end
  
  % Rotate the points
  X  = [zeros(nx,1)  X'];
  X  = quatprod(Q,X,true);                            % Quatprod will handle rotations internally if you pass 'true'
  X  = X(:,2:4)';

end




