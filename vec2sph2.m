function s = vec2sph2(v)
% FUNCTION s = vec2sph2(v)
%   Converts a 3d vector into a spherical coordinate, in 
%   the coordinate system in which az/el = (0,0) looks down +z.
%
%   Azimuth 
%     th =  0     : +z axis  (when phi = 0)
%     th =  pi/2  : -x axis  (when phi = 0)
%     th = -pi/2  : +x axis  (when phi = 0)
%     th =  pi    : -z axis  (when phi = 0)
%  
%   Elevation
%     ph =  0     : -z axis  (when th = 0)
%     ph =  pi/2  : +y axis  (when th = 0)
%     ph = -pi/2  : -y axis  (when th = 0) 
%
%
% PARAMETERS
%   v  :  3D vectors, v(1,:) = x coord
%                     v(2,:) = y coord
%                     v(3,:) = z coord
% RETURNS
%   s  :  Spherical coordinates, s(1,:) = azimuth,     [-pi    pi   ]
%                                s(2,:) = inclination, [-pi/2  pi/2 ]
%                                s(3,:) = radius       [  0    Inf  ]
%
%
% SEE ALSO: sph2vec, sphareas, sphvecs, sphmaprange
%
  % I am relating this convention to Mathworld's so I don't have to figure
  % out how to derive the area of the differential element when integrating
  % For convienence, I make the following changes from their convention
  % http://mathworld.wolfram.com/SphericalCoordinates.html
  %     - Our x = Mathworld y
  %     - Our y = Mathworld z
  %     - Our z = Mathworld x 
  %
  %     - Mathworld phi is measured from their +z, 
  %         our phi is from their x-y plane
  %     - Mathworld theta is measured from their +x axis, 
  %         our theta is measured from their -x axis

  % Convert our vectors into mathworld's axes (see figure at http ref.)
  y = v(1,:);     % mathworld y
  z = v(2,:);     % mathworld z
  x = v(3,:);     % mathworld x
  
  % We use mathworld's radius
  r  = sqrt(x.^2 + y.^2 + z.^2);
  
  % We now measure our th relative to mathworld's +x axis, just like mathworld does...
  %
  % But we want a negative azimuth to cause us to turn toward our +x axis, which
  % which is Mathworld's +y axis.  We just need to flip the direction of theta...
  %
  % Thus 
  %   mathworld_th =  atan2(mathworld_y, mathworld_x)
  % 
  % And 
  %   our_th       = -atan2(mathworld_y, mathworld_x)
  %
  th = atan2(y, x);
  
  % We measure our phi relative to mathworld's x-y plane, so phi differs
  %   Mathworld uses:  ph = acos(z./r)
  %   We use        :  ph = asin(z./r)
  ph = asin(z./r);
  
  % Put the spherical coordinates into the columns
  s = [th; ph; r];
  
end


function old_version
% This is the old version, before I changed convention to have
% the +z axis in the center of the plot

  % We measure our th relative to mathworld's -x axis, rather than +x
  % Thus 
  %   mathworld_th = atan2(mathworld_y, mathworld_x)
  % 
  % And 
  %   our_th       = atan2(mathworld_y, -mathworld_x)
  %
  th = atan2(y, -x);
  
end