function [amap th ph] = sphareas(isz)
% FUNCTION [amap th ph] = sphareas(isz)
%   Returns the area that each differential element in the spherical
%   map occupies on a unit sphere.  These area's should sum to 4*pi
%   because the sphere has surface area 4*pi*r^2, where r=1. 
%   (Note: high resolution map is needed to get sum(amap(:)) close to 4*pi)
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
%   isz     : The size of the environment map, isz = size(map)
%
% RETURNS
%   amap    : A map of pixel areas on the unit sphere
%   th      : The azimuth steps on the x-axis of our map
%   ph      : The inclination steps on the y-axis of our map 
%               e.g. imagesc(th,ph,amap)
% 
% SEE ALSO: sph2vec, vec2sph, sphvecs, sphmaprange

  % Make the map
  [th ph] = sphmaprange(isz);
  [tm pm] = meshgrid(th, ph);
  
  % Compute the angular step sizes. These are constant across all pels in the envmap
  dth = abs(th(1) - th(2));
  dph = abs(ph(1) - ph(2));

  % We must multiply the differential elements dth and dph by 
  % a factor that accounts for the changing elevation
  % In mathworld, the volume element is
  %   dV = r^2 * sin(ph) * dth * dph * dr
  % 
  % We have changed conventions (see sph2vec.m), and
  %   dV = r^2 * cos(ph) * dth * dph * dr
  % 
  cosph = cos( pm(:,1) ); 
  
  % Construct the area map
  amap = repmat(cosph, 1, isz(2)); 
  amap = dph*dth*amap;             

end






