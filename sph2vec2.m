function v = sph2vec2(s)
% FUNCTION v = sph2vec2(s)
%   Converts a spherical coordinate into a 3D vector, in the coordinate 
%   system in which az/el = (0,0) looks down +z.
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
%   s  :  Spherical coordinates, s(1,:) = azimuth,     [-pi    pi   ]
%                                s(2,:) = inclination, [-pi/2  pi/2 ]
%                                s(3,:) = radius       [  0    Inf  ]
%
% RETURNS
%   v  :  3D vectors, v(1,:) = x coord
%                     v(2,:) = y coord
%                     v(3,:) = z coord
%
% SEE ALSO: vec2sph, sphareas, sphvecs, sphmaprange
%
 
  % Assume a unit sphere if no radius is specified
  r = 1;
  if size(s,1) >= 3
    r = s(3,:);
  end
  
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

  
  % Compute the vector in mathworld's convention.
  % Matworld's phi is different than ours: we measure phi out of
  % mathworld's x-y plane, and they measure it away from their +z axis
  % So,
  %   sin(mathworld_phi) = cos(our_phi)                                 (1)
  %   cos(mathworld_phi) = sin(our_phi)                                 (2)
  %
  % Thus matworld defines
  %   mathworld_x = r*cos(mathworld_th)*sin(mathworld_ph)               (3)
  %   mathworld_y = r*sin(mathworld_th)*sin(mathworld_ph)               (4)
  %   mathworld_z = r*cos(mathworld_ph)                                 (5)
  %
  % And we revise to
  %   mathworld_x = r*cos(mathworld_th)*cos(our_ph)                     (6)
  %   mathworld_y = r*sin(mathworld_th)*cos(our_ph)                     (7)
  %   mathworld_z = r*sin(our_ph)                                       (8)
  %
  % 
  % Also, mathworld's th (azimuth) is different than ours: we measure th
  % starting from mathworld's +x axis, just like mathworld...
  % But we want negative azimuths to turn us toward our +x axis,
  % which is mathworld's +y axis.  So our theta's are simply
  % negated versions of mathworld's.  Thus...
  %
  % So,
  %   cos(mathworld_th) =  cos(-our_th)                                 (9)
  %   sin(mathworld_th) =  sin(-our_th)                                (10)
  %   
  % Thus we once more modify mathworld's equations.
  % Starting from Equations (6)-(8)
  %   mathworld_x = -r*cos(our_th)*cos(our_ph)                         (11)
  %   mathworld_y =  r*sin(our_th)*cos(our_ph)                         (12)
  %   mathworld_z =  r*sin(our_ph)                                     (13)
  %
  mathworld_x = r.*cos(s(1,:)).*cos(s(2,:));
  mathworld_y = r.*sin(s(1,:)).*cos(s(2,:));
  mathworld_z = r.*sin(s(2,:));
  
  % Transform mathworld's axes into ours
  our_x = mathworld_y;
  our_y = mathworld_z;
  our_z = mathworld_x;
  
  % Return the vectors in the columns of v
  v = [our_x; our_y; our_z];
  
end



function old_version
% This is the old version, before I changed convention to have
% the +z axis in the center of the plot

  % Compute the vector in mathworld's convention.
  % Matworld's phi is different than ours: we measure phi out of
  % mathworld's x-y plane, and they measure it away from their +z axis
  % So,
  %   sin(mathworld_phi) = cos(our_phi)                                 (1)
  %   cos(mathworld_phi) = sin(our_phi)                                 (2)
  %
  % Thus matworld defines
  %   mathworld_x = r*cos(mathworld_th)*sin(mathworld_ph)               (3)
  %   mathworld_y = r*sin(mathworld_th)*sin(mathworld_ph)               (4)
  %   mathworld_z = r*cos(mathworld_ph)                                 (5)
  %
  % And we revise to
  %   mathworld_x = r*cos(mathworld_th)*cos(our_ph)                     (6)
  %   mathworld_y = r*sin(mathworld_th)*cos(our_ph)                     (7)
  %   mathworld_z = r*sin(our_ph)                                       (8)
  %
  %
  % Also, mathworld's th (azimuth) is different than ours: we measure th
  % starting from mathworld's -x axis, and they measure it from their +x
  % So,
  %   cos(mathworld_th) = -cos(our_th)                                  (9)
  %   sin(mathworld_th) =  sin(our_th)                                 (10)
  %   
  % Thus we once more modify mathworld's equations.
  % Starting from Equations (6)-(8)
  %   mathworld_x = -r*cos(our_th)*cos(our_ph)                         (11)
  %   mathworld_y =  r*sin(our_th)*cos(our_ph)                         (12)
  %   mathworld_z =  r*sin(our_ph)                                     (13)
  %
  mathworld_x = -r.*cos(s(1,:)).*cos(s(2,:));
  mathworld_y =  r.*sin(s(1,:)).*cos(s(2,:));
  mathworld_z =  r.*sin(s(2,:));
  
end




