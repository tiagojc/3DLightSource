function cm = intrinsicCameraMatrix(principalPoint, focalLength)
%FUNCTION cm = intrinsicCameraMatrix(principalPoint, focalLength)
%
%   Construct a matrix with the intrinsic camera parameters. The matrix has
%   the form [ f  0 px
%              0 f  py
%              0  0 1]
%   where f is the focal length (in unit) and px, py are, respectively, the
%   x and y coordinates of the principal point from projection plane.
%
%PARAMETERS
%   
%   principalPoint: a 2D vector containing the position of the principal 
%   point from projection plane.
%
%   focalLength: the focal length distance in unit 
%
%RETURNS
%
%   cm : the intrinsic camera matrix. 
%
    cm = [focalLength 0 principalPoint(1,1);
          0 focalLength principalPoint(1,2);
          0 0 1];

end