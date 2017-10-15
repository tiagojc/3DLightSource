function xc = mapdata2(x, bnd, varargin)
% FUNCTION x = mapdata2(x, bnd, map)
%   Converts MxN matrix x into an image according to the current colormap.  
%   A colormap may be optionally provided as varargin.  See below.
% 
% PARAMETERS
%   x   : The data
%   rng : The range to map the data into.  Set [] if you want to pass varargin but not specify.
%   varargin : If present, must be a colormap, a Kx3 matrix of values in [0 1]. 
%               e.g. 'jet'
%
% RETURNS
%   xc  : A colormapped image
%

  if numel(varargin) == 0;
    if isempty(get(0,'Children'))    % If no figures exist
      map = jet(256);
    else
      map = jet;
    end
  else
    map = varargin{1};
  end
  
  n  = size(map,1);

  if ~exist('bnd', 'var') || isempty(bnd)
    x  = round((n-1)*imnorm(x)+1);
  else
    x  = round((n-1)*clip(imnorm(x, bnd))+1);
  end
  xc = zeros([sizes(x,1,2) 3]);
  for k = 1:3
    bads       = isnan(x);
    xct(~bads) = map(x(~bads),k);
    xct( bads) = 0;
    xc(:,:,k) = reshape(xct, size(x)); %reshape(map(x(:),k), size(x));
  end

end


function varargout = sizes(x, varargin)
% FUNCTION varargout = sizes(x, varargin)
%   Returns the size of x.  If dims is specified, returns
%   the size of x along each of the dimensions in 'dims'.
%   This overcomes an annoying limitation of matlab's "size".
%
% REVISION
%   2010.04.25 : Eric Kee
%

   if numel(varargin) == 0
     s = size(x);
   elseif numel(varargin) == 1
     s = arrayfun(@(y) size(x,y), varargin{1});
   else
     s = cellfun(@(y) size(x,y), varargin);
   end

   if nargout <= 1
     varargout{1} = s;
   else
     tt        = mat2cell(s, 1, ones(1,numel(s)));
     varargout = tt(1:nargout);
   end

end




function [img mmin mmax] = imnorm(img, varargin)
% FUNCTION [img mmin mmax] = imnorm(img)
%   Normalizes an image onto the range [0 1].  If the image is not a double, it is converted to a double.
%
% PARAMETERS
%   img      : the image to normalize
%   varargin : (optional) Can be
%                <type> : (string) type casts to <type>  (e.g. 'single')
%                         Defaults to 'double'
%
%                range  : (vector) the upper and lower range to normalize into
%                         range = [lower  upper]
%                
%
% RETURNS
%   img  : the normalized image
%   mmin : the image's minimum value before normalizing
%   mmax : the image's maximum value before normalizing  
%
% REVISIONS
%   2010.06.09 : Added type casting and user-defined ranges
%

  args = parseargs(varargin);
  img  = cast(img, args.type);
  if isempty(args.range)
    args.range = [min(img(:))  max(img(:))];
    if abs(diff(args.range)) == 0
      args.range = [0 1];
    end
  end
  img  = (img-args.range(1))/(args.range(2) - args.range(1));

  mmin = args.range(1);
  mmax = args.range(2);

end



function varargs = parseargs(args)

  % Defaults
  varargs.type  = 'double';
  varargs.range = [];

  % Parse user specfied mods to defaults
  for k = 1:numel(args)
    if isstr(args{k})
      varargs.type = args{k};
    elseif isa(args{k}, 'numeric')
      varargs.range = args{k};
    end
  end

end


function x = clip(x, varargin)
% FUNCTION y = clip(x, range)
%   Clips values in x into range [0 1].
%
% PARAMETERS
%   x      : A matrix of any size
%   range  : (optional) The min and max clip values [min max]
%   range2 : (optional)
% 
% RETURNS
%   y : a clipped version of x
%
% REVISION
%   2010.06.02 : Initial revision
%   2010.06.09 : Revised to include an optional range parameter
%

  if numel(varargin) == 0
    x(x>1)=1;
    x(x<0)=0;
  elseif numel(varargin) == 1
    range         = varargin{1};
    x(x<range(1)) = range(1);
    x(x>range(2)) = range(2);
  elseif numel(varargin) == 2
    rangeL      = varargin{1};
    rangeH      = varargin{2};
    x(x<rangeL) = rangeL;
    x(x>rangeH) = rangeH;
  end

end

