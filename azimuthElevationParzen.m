function [P] = azimuthElevationParzen(N, winang, imwid, fl, pp, ssl)
% FUNCTION [P] = azimuthElevationParzen(N, winang, imwid, fl, pp, ssl)
%   Visualizes the sphericial distribution of vectors into
%   azimuth/elevation domain
%   
%   Note that a parzen density is really the only way to visualize the distribution of normals
%   because a sphere cannot be evenly divided into histogram bins.
% 
%   WARNING: If your vectors N are not unit length you'll get a weighted density.
%            This is not a weighted sum, though.  Your vector lengths are simply multplied into
%            the parzen windows.
%
%
% PARAMETERS
%   N      :  A 3xN matrix of normal vectors in the form [x y z;  x y z; ... ]
%   winang :  The standard deviation parzen window.  This is a half-angle.  
%   imwid  :  Optional.  Specifies the size of the (square) distribution image. 
%             Default: 100 pixels
%   fl     :  camera focal lenght
%   pp     :  camera principal point
%   ssl    :  the limit of sensor range
%
% RETURNS:
%   P      :  An image in which each pixel represents the percentage of vectors that 
%             are within 'binang' degrees of that direction on the +z hemisphere.
%

  if ~exist('imwid', 'var') imwid = 100;  end
  %keyboard
  % Construct image properties
  SZ     = imwid([1 1]);
  H      = zeros(SZ);
  center = SZ/2;
  rad    = SZ(1)/2;
  
  % Construct the normals using envmapnorms function
  normals = sphvecs([imwid 2*imwid]);
  %tt = reshape(normals,imwid*(2*imwid),3,1);
  tt = normals';
  
  
  X = tt';
  X = (normalizeByNorm(X'))';
  Nn = N./repmat(sqrt(sum(N.^2)), 3, 1);           % Make sure all vectors in N are unit length 
  %keyboard
% Change Y and Z to adapt normals into PBRT convention
%    Nn = Nn';
%   Nn = ([Nn(:,1) Nn(:,3) Nn(:,2)]'; 
  tic
  
%   D  = X'*Nn;                                      % Calc cosine of angle between all vectors
 

  % Use parzen window if user desires
  sd = 1-cosd(winang);
  %keyboard

  XT = X';
  nl = (size(XT,1)/50);
  D = zeros(nl,size(Nn,2));
  j = 1;

  %keyboard
  for i=1:size(XT,1)
      rest = mod(i,nl);
      if rest == 0 
         rest = nl;
      end
      tt = XT(i,:);
      ans = tt * Nn;
      D(rest,:) = ans;
      %keyboard
      if (rest == nl)
          ttt = num2str(i/nl);
          pw = exp(-(1-D).^2/(2*sd^2));
          nw = repmat(enorm(N), size(pw,1), 1); 
          D  = sum(pw.*nw, 2);
          %keyboard
          tt = strcat('tmp/tmp-',ttt,'.bin');
          fid = fopen(tt,'w');
          fwrite(fid, D, 'double');
          fclose(fid);
          D = zeros(nl,size(Nn,2)); 
          %keyboard
      end
  end
  D = zeros(size(XT,1),1);
  di = 1;
  de = nl;
  j = size(XT,1)/nl;
  for i=1:(j)
      i
      tt = strcat('tmp/tmp-',num2str(i),'.bin');
      fid = fopen(tt,'r'); 
      tt = fread(fid,[nl,size(Nn,2)],'double');
      D(di:de,:) = tt;
      di = di + nl;
      de = de + nl;
      fclose(fid);
  end
  toc
  
 
%   try
%                     % Calc parzen weights for each normal at each pixel
%            % Calc vector length weights for each vector at each pixel
%                                % The weighted parzen density
%   catch ME                                         % Catch out of memory error
%     D  = D(:,1:2:end);
%     N  = N(:,1:2:end);
%     pw = exp(-(1-D).^2/(2*sd^2));                  % Calc parzen weights for each normal at each pixel
%     nw = repmat(enorm(N), size(pw,1), 1);          % Calc vector length weights for each vector at each pixel
%     D  = sum(pw.*nw, 2);                           % The weighted parzen density
%   end
  %keyboard
  P = reshape(D,imwid,2*imwid);
  %keyboard
end



function mask = ringmask(sz)

  n    = max(sz)-1;
  t    = 0:1/(0.5*n):(1-1/n)*2*pi;
  cent = mean([1 sz(1); 1 sz(2)], 2);
  xs   = (cent(2)-1)*cos(t) + mean([1 sz(2)]);   xs = round(xs);
  ys   = (cent(1)-1)*sin(t) + mean([1 sz(1)]);   ys = round(ys);
  rems = sub2ind(sz, xs, ys);

  mask = false(sz);
  mask(rems) = true;

end



function SB = histbins(ns, opt)

  c = 0;
  for ph = linspace(-pi/2, pi/2, ns)
    nl = round(ns*cos(ph) + 1);
    th = linspace(-pi, pi, nl); 

    SB(1:2,c+1:c+numel(th)) = [th; repmat(ph, 1, numel(th))];
  
    c = c+numel(th);
  end
  SB(3,:) = ones(1,size(SB,2));

  if exist('opt', 'var') && opt 
    [x y z] = sph2cart(SB(1,:), SB(2,:), SB(3,:));
    SB      = [x; y; z];
  end

end

function v = world2light(v)
      v = v([1 3 2]);
end
