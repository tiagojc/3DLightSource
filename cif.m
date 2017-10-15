function f = cif(H)
% FUNCTION f = cif(H)
%   Builds a discrete confidence interval function from a histogram.  The histogram
%   data H may be of any number of dimensions.
%
% PARAMETERS
%   H  : A histogram (any number of dimensions)
%
% RETURNS
%   f  : A confidence interval function. 
%          e.g.  f > 0.1  gives the bins that account for 90% of the probability mass
%

% Build a CIF (confidence interval function)
%  Idea is to quickly count the number of elements with each value without doing lots of finds:
%  Sort elements, compute the "level changes" where the sets of equivalent values change to a new
%  value.  For each new level, we count the number of elements with value less than that level
%  as the index in the sorted vector where the level began.

  [hv hi] = sort(H(:));               % Sort all histogram values
  b       = [0; diff(hv) > 0];        % Find the breaks between the levels
  cd      = sum(hv);                  % Curr cum density value starts at entire population 'cause we are working from highest to lowest
  hd      = zeros(size(hv));          % Make space for cumulative density
  for k = numel(b):-1:1               % Count downward 
    hd(k) = cd;
    if b(k)                           % If at a "break", we have descended to a new level in histogram 
      cd = sum(hv(1:k-1));            % New "density" is the number of pts in population at <= the new level
    end
  end
  hd  = hd/sum(hv);                   % Normalize data to have a max of 1 
  hd  = 1-hd;                         % Invert all probabilities so we are counting % of population that is MORE likely to occur

  f     = H;                          % Construct the final CIF in whatever num of dims user gave
  f(hi) = hd;
  f     = 1-f;                        % I added this line to make interpertation of the function more intuitive

end


