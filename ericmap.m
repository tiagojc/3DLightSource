function map = ericmap
%FUNCTION ericmap
%
%   Creates an specific color map for confidences intervals courves
%
%RETURNS
%
%   map : a color map
%
%
  tt = jet(256);
  for k = 1:3
    tt(:,k)  = interp1(tt(:,k), linspace(1,256,256));
  end

  uu = flipud(gray(256));
  ramp = linspace(0,1,256).^(1/1.2);
  ramp = repmat(ramp',1,3);

  tt  = ramp.*tt + (1-ramp).*uu;

  tt      = rgb2hsv(tt);
  ramp    = linspace(1, 0.4, 256)'.^1.75;
  tt(:,2) = tt(:,2).*ramp;

  ramp    = linspace(1, 1.1, 256)'.^(2);
  tt(:,3) = clip(tt(:,3).*ramp);
  tt      = hsv2rgb(tt);
  
  map = tt;

end