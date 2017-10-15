function s = n2ts(N, p, K)
% FUNCTION s = n2ts(N, p, K)
%   Converts a 3D normal to a tilt/slant value
%
% PARAMETERS
%   N  :  The 3D normal, 3x1
%   p  :  The point on the unit sensor
%   K  :  The camera parameters, [f px py]
%
% RETURNS
%   s  :  The tilt and slant, [tilt slant]
%

  % Force them to use column vectors for points
  N = N(:);          
  p = p(:);
  K = K(:);         % K is not a point, but K(2:3) are, so make K a column
  
  % Get camera data
  f  = K(1);        % Focal
  c  = K(2:3);      % Image center (principal point)
  V  = [p-c; -f];   % Camera vector.  Account for principal point
  V  = V/norm(V);   %  ..normalized
  
  % Compute the 3D tilt axis 
  A = cross(V,N);    
  A = A/norm(A);
  
  % Compute the vector that corresponds to a slant of 90 degrees
  % This would be a surface normal on an occluding contour
  Q = cross(A,V);
  Q = Q/norm(Q);

  % Compute the tilt. (see below for explanation)
  % Here we are computing the tilt angle that would be observed by a person 
  % who is orthographically viewing the perspective image.
  th = atan2(Q(1),Q(2))*180/pi;  
  
  % Compute the slant.  This is the angle between the normal N the 
  % camera ray, V.  We want normals that point toward the CoP to have 
  % slant = 0 degrees.  -V points toward the CoP, so 
  %   slant = acos(-V'*N)
  %
  ph = acosd(-V'*N);
   
  % Return
  s = [th ph];
   
end



% NOTE ON TILT
%
% The tilt is 
%   th = atan(q_x/q_y)
%
% To see this, note that Q is the same as an occluding surface normal, 
% which has the form:
%
%         [    q_x     ]
%     Q = [    q_y     ]
%         [ q'*(p-c)/f ]
%
% where q is the 2D direction of all projected vectors that have the same 
% tilt.  
%
% By definition, Q has the same tilt as N.  The tilt is therefore specified
% by the angle of q.  We measure this angle relative to the +y axis
%       
%             q_x
%            _____
%           |    /
%           |   /
%       q_y |  /q
%           | /
%           |/
%
% So, 
%     tilt = atan(q_x/q_y).
%   
  
  
% ADDITIONAL NOTE ON TILT
%
% To compute the tilt, we are constructing a vector Q, that is 
% orthogonal to the camera ray, and has the same tilt as the 3D surface
% normal, N.  This follows from our definition of slant and tilt.
%
% We define the tilt by an axis, A, that is orthogonal to the camera
% ray V, and the normal, N.  The slant specifies how far we should rotate 
% the camera ray around the tilt axis to create our 3D normal. 3D normals 
% that have the same tilt lie in the plane defined by A.  
%
% Because the tilt plane contains the camera ray, it passes through the
% center of projection.  Thus all vectors in the tilt plane project to a 
% line in the image -- the intersection of the tilt plane and the sensor.  
% We define the direction of this line to be the tilt angle.
%
% The tilt angle must be the same for all vectors that lie in the tilt
% plane, A.  These vectors include the vector Q that is orthogonal to both 
% V and A.
%         
%     Q = cross(A,V)
%
% We can use Q to compute the tilt angle.  We know that Q takes the form 
% of an occluding surface normal, which is given by
%
%         [    q_x     ]
%     Q = [    q_y     ] ,
%         [ q'*(p-c)/f ]
%
% where q is the direction of the line that is formed where the image plane 
% intersects the plane that contains Q and V -- the tilt plane, A.  So, the 
% 2D diretion of q specifies the tilt angle.
%






