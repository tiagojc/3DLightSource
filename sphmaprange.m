function [th ph] = sphmaprange(isz)
% FUNCTION [th ph] = sphmaprange(isz)
%   Returns ranges of the spherical coordinates in our 2D map of the sphere
%   around our camera.
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
%   th    : The theta (azimuth)   steps in the map -- the x-axis of the map
%   ph    : The phi (inclination) steps in the map -- the y-axis of the map
%
% SEE ALSO: sph2vec, vec2sph, sphareas, sphvecs
%

  % Azimuth 
  th = linspace(-pi, pi, isz(2));
  
  % Elevation
  ph = linspace(-pi/2, pi/2, isz(1));
  
end