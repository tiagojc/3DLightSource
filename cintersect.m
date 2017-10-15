function pts = cintersect(contours)

  % Get the maps
  for k = 1:size(contours,1)
    tt = contours{k};

    
    parray{k} = tt;
  end
  %keyboard
  % This function should do it
  pts = cintersect_sub(parray);

end




function pts = cintersect_sub(parray)
% FUNCTION pts = cintersect_sub(parray)
%   Takes as input N contours, and computes their
%   intersection.  Parameter parray is a cell array
%   of point lists.
%
% PARAMETERS
%   parray   :  A cell array, 1xN of lists of points, 
%               each having size 2xM in [x y]' format
%
% RETURNS
%   pts      :  The points on the boundary of the region 
%               where all of the contours intersect.
%                 2xP
%

  % Make a high resolution mesh
  fac       = 8;
  sz        = fac*[180 360];
  [az1 el1] = sphmaprange(sz);
  az1       = az1*180/pi;
  el1       = el1*180/pi;
  [am1 em1] = meshgrid(az1, el1);
  
  % Compute the intersection of all masks
  map = true(sz);
  for k = 1:numel(parray)
    fprintf('\rComputing high-resolution intersection ... %2.2f%%  ', 100*k/numel(parray));
      
    % WARNING: impoly() will fail if region touches image boundaries from
    % file exchange, but seems to work 10x faster than Matlab's inpolygon()
    tt  = inpoly([am1(:), em1(:)], parray{k}');      
    
    
    %%%%%% I added this part to use matlab function inpolygon. To restore
    %%%%%% Erics function uncomment previous line and comment this block
%     ttpt = parray{k}';
%     xv = ttpt(:,1);
%     yv = ttpt(:,2);
%     tt  = inpolygon(am1(:),em1(:),xv,yv);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    tt  = reshape(tt, sz);                                   
    map = map & tt;
  end
  fprintf('...Done.\n');

  % Handle the no-intersection case gracefully
  if ~any(map(:))
    pts = [];
    return;
  end
  
  % Trace the boundary & map points into azimuth elevation range
  pts      = ebwtraceboundary(map, 'W')';
  pts(:,1) = interp1(1:sz(2), az1, pts(:,1));
  pts(:,2) = interp1(1:sz(1), el1, pts(:,2));
  
  % Remove any remaining uglyness by low pass filtering the shape
  n   = size(pts,1);
  p   = fftpairs(n);
  pts = uniformsample(pts,7);    
  PTS = fft(pts); 
  cut = floor( [floor(n/2)+1]/8);
  PTS(p(cut:end,:),:) = 0;
  ext = setdiff(1:n, p(:));
  PTS(ext,:) = 0;
  pts = ifft(PTS);

  % Sample the shape uniformly, and connect the ends together
  pts = uniformsample(pts,7);
  pts(end+1,:) = pts(1,:);

  % Compute length of boundary, and reduce the number of samples to
  % 2 per pixel
  astep     = az1(2) - az1(1);
  astep     = norm([astep astep]);
  len       = ceil(sum(sqrt(sum(diff(pts).^2,2)))/astep);
  len       = round(len/fac);
  n         = size(pts,1);
  ti        = linspace(0, 1, n);
  pnew(:,1) = interp1(ti, pts(:,1)', linspace(0,1,len));
  pnew(:,2) = interp1(ti, pts(:,2)', linspace(0,1,len));
  
  % Plot
  figure(1); clf; imagesc(az1, el1, map,[0 5]); %aiocg; 
  hold on;  axis xy on;
  plot(pnew(:,1), pnew(:,2), '-r.', 'linewidth', 1);


  % Return in 2xP format
  pts = pts';



end




function pts = ebwtraceboundary(msk, varargin)
% FUNCTION pts = ebwtraceboundary(msk, varargin)
%   The same as bwtraceboundary, but it doesn't require that
%   you specify a starting point.  This assumes that there
%   is only one thing to trace, and it picks the first 
%   pixel it finds for you.  This saves a hassle in the code.
%
% PARAMETERS
%   msk      :  A logical mask to trace
%   varargin :  Any parameters that you would pass to
%               Matlab's function after specifying the
%               starting point of the trace
%
% RETURNS
%   pts      :  The traced points, 2xN, and in [x y] format,
%               not [j i] format.
%
   pts = [];

  [j i] = find(msk);
  if ~isempty(j) & ~isempty(i)
    j     = j(1);
    i     = i(1);
    pts   = bwtraceboundary(msk, [j i], varargin{:});
    pts   = pts(:,[2 1])';
  end
  
 

end




function [p0 p] = fftpairs(n)
% FUNCTION [p0 p] = fftpairs(n)
%   Returns the indices in a 1D FFT that
%   correspond to identical frequencies.
%
%   NOTE:  p0(1,:) and p(1,:) identify the DC term
%
%   WARNING: If n is even, p will exclude one coefficient
%            which has no pair in the FFT output. It should
%            be the first sample of the fft-shifted signal.
%
% PARAMETERS
%   n  :  Number of samples in the FFT
%
% RETURNS
%   p0 :  Indices into the 1D FFT, n-by-2
%           p(k,:) are indices of the same frequency
%
%   p  :  The pairs in the fft-shifted vector
%
  mid = floor(n/2)+1;
  t1  = [mid-1:-1:1];
  t2  = [mid+1: 1:n];
  nt  = min(numel(t1), numel(t2));
  t1  = t1(1:nt);
  t2  = t2(1:nt);
  p   = [t1(:) t2(:)];
  p   = [ mid mid; p ];

  % Get pairs for the un-shifted FFT
  tt  = ifftshift(1:n);
  nei = neighbors(p(:)', tt, 1);
  p0  = reshape(nei, [], 2);

end


function P = uniformsample(X,recur)
% FUNCTION P = uniformsample(X,recur)
%   Resamples the curve specified by the points
%   in X with the same number of samples, but
%   with each sample placed at equal distances
%   around the length of the curve.
%
% PARAMETERS
%   X     : Points on the curve, Nx2
%   recur : Number of times to apply uniform resampling.
%             (this will reduce small inaccuracies in the
%              the algorithm that result in slightly non-
%              equally-distanced points).
%
%           recur = 0 will simply return your points.
%
%
% RETURNS
%   P  :  The resampled curve
%

% Default to 3 recursions on this function
  if ~exist('recur')
    recur = 3;
  end

  % Base case in recursion
  if (recur <= 0)
    P = X;
    return;
  end

  % Get distance increments
  d = sqrt(sum(diff(X,[],1).^2,2));

  % Remove any points that are redundant
  keeps = [true; d>0];
  X     = X(keeps,:);
  d     = d(d>0);

  % Compute cumulative curve length (normalized into [0 1])
  c0 = [0; cumsum(d)];
  c0 = c0/c0(end);

  % Resample the curve
  c1     = linspace(0,1,numel(c0));
  P(:,1) = interp1(c0,X(:,1),c1);
  P(:,2) = interp1(c0,X(:,2),c1);

  % Recursive call
  if (recur > 1)
    P = uniformsample(P,recur-1);
  end

end



function [NI DI] = neighbors(X, DX, opt)
% FUNCTION [NI DI] = neighbors(X, DX, n)
%   Computes the nearest neighbor of the points X in dataset DX.
%
%   You can also use this to compute the distances between pts in X and 
%   pts in DX.  Call [n d] = neighbors(X,DX, false) and use d.
%
% PARAMETERS
%   X    :  Points in columns. X = NxM. N dimensions, M points.
%   DX   :  Dataset, each data element in a column. 
%            DX = NxK. N dimensions, K points.
%   opt  :  (Optional) May be:
%              - [Integer] The number of nearest neighbors to return. 
%                    If not present, returns all neighbors.  May be Inf.
%
%              - [Logical] Sorting option.
%                    TRUE:  Same behavior as neighbors(X, DX)
%                    FALSE: Calcs distances d between each X and each DX
%
% RETURNS
%   NI : The nearest point in DX that is nearest to each column of X
%   DI : The distances between points in X and points in DX
%
% REVISION
%   2010.06.02 : Initial revision
%   2010.06.09 : Modified so it can handle scalars in X and DX (use sum(..., 1) )
%   2010.07.13 : Modified so 'n' is optional
%   2010.07.14 : Modified so empty 'X' and 'DX' return empty NI and DI
%   2011.03.04 : Created 'opt' option.
%

  if isempty(X) || isempty(DX)
    NI = [];
    DI = [];
    return;
  end

  numDX = size(DX,2);
  numX  = size(X, 2);

  % Handle option argument
  if ~exist('opt', 'var')  
    n   = numDX;
    srt = true;
  elseif isnumeric(opt)
    n   = opt;
    srt = true;
  elseif islogical(opt) 
    n   = numDX;
    srt = opt;
  else
    error('neighbors: Invalid option argument.');
  end


  for k = 1:numX
    x = X(:,k);
    d = sum((DX - repmat(x,1,numDX)).^2,1);         % Compute distance.  Don't take sqr-root because its monotonic
    
    if srt
      [vv ii] = sort(d, 'ascend');
    else
      vv = d;
      ii = 1:numel(d);
    end
    NI(:,k) = ii(1:n);
    DI(:,k) = vv(1:n);
  end

  DI = sqrt(DI);

end



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
