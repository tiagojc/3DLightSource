function y = clip(x)
%FUNCTION y = clip(x)
%
%   Clip all the values lower than 0 to 0 and bigger than 1 to 1
%
%PARAMETERS
%
%   x : a m-by-n matrix containing any values
%
%RETURNS
%
%   y : a m-by-n matrix similar to x but with values bigger than 1 clipped
%   to 1 and with values lower than 0 clipped to 0
    y = x;
    y(y>1) = 1;
    y(y<0) = 0;
end