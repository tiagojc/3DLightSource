function R = rmtx(varargin)
% FUNCTION R = rmtx(varargin)
%   Returns a rotation matrix that rotates about the x y and z axes
%   by the angles specified in the parameters.  Angles are in degrees.
%
% PARAMETERS
%   varargin : May be either
%                rmtx(R), where R = [rx ry rz]
%              or
%                rmtx(rx, ry, rz)
%
%              a 4th parameter may be "2D" for a 2d matrix
%
% RETURNS
%   R  : A rotation matrix
%
%

  D2 = false;
  if (nargin == 1)
    R  = varargin{1};
    
    if (numel(R) > 1)
      xt = R(1);
      yt = R(2);
      zt = R(3);
    else
      xt = 0;
      yt = 0;
      zt = R;
      D2 = true;
    end
    
  elseif (nargin >= 3)
    xt = varargin{1};
    yt = varargin{2};
    zt = varargin{3};
    if nargin == 4
      D2 = true;
    end
  end


  theta = xt*pi/180; c = cos(theta); s = sin(theta);
  xrmtx = [[1   0  0]; [0  c -s]; [0  s  c]];

  theta = yt*pi/180; c = cos(theta); s = sin(theta);
  yrmtx = [[c   0  s]; [0  1  0]; [-s 0  c]];

  theta = zt*pi/180; c = cos(theta); s = sin(theta);
  zrmtx = [[c  -s  0]; [s  c  0]; [0  0  1]];
  
  R = zrmtx*yrmtx*xrmtx;

  if D2        %nargin == 4 && ischar(varargin{4}) && strcmp('2D', upper(varargin{4}))
    R = R(1:2,1:2);
  end

end
