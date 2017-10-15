function v = sphvecs(isz)
% FUNCTION norms = sphvecs(isz)
%   Returns the surface normals in our spherical map around the camera.
%   
%   Our spherical coordinate system looks down the -z axis. Azimuth looks 
%   left/right, Inclination looks up/down.
%
%   Azimuth 
%     th =  0     : -z axis  (when phi = 0)
%     th =  pi/2  : +x axis  (when phi = 0)
%     th = -pi/2  : -x axis  (when phi = 0)
%     th =  pi    : +z axis  (when phi = 0)
%  
%   Elevation
%     ph =  0     : -z axis  (when th = 0)
%     ph =  pi/2  : +y axis  (when th = 0)
%     ph = -pi/2  : -y axis  (when th = 0) 
%
%
% PARAMETERS
%   isz   : The size of the environment map [M N].  
%
% RETURNS
%   varargout : Returns either
%                  norms   : A MxNx3 matrix specifying x,y,z
%               OR
%                  [x y z] : Each individual plane
%
% SEE ALSO: sph2vec, vec2sph, sphareas, sphmaprange
%

  % Make the map
  [th ph] = sphmaprange(isz);
  [tm pm] = meshgrid(th, ph);

  % Vectors
  v = sph2vec2([tm(:)'; pm(:)']);
  x = reshape(v(1,:), isz);
  y = reshape(v(2,:), isz);
  z = reshape(v(3,:), isz);
  
  % Return norms to user
  if nargout == 1
    varargout{1} = cat(3, x, y, z);
  elseif nargout == 3
    varargout{1} = x;
    varargout{2} = y;
    varargout{3} = z;
  else
    error('Can only output 1 or 3 return values.')
  end

end












