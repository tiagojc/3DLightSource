function np = normalizeByNorm(points)
% FUNCTION np = normalizeByNorm(points)
%
%   Normalize vectors, dividing by the norm, to make sure that they have 
%   unit length
%
%PARAMETERS:
%
%   points : a matrix of m-by-n where each line contains a vector and each
%   colum contains one dimension of the vector
%
%RETURNS
%   
%   np : a matrix of m-by-n with the same input points but with unit length 
%

    % Get the size of input matrix
    [n,dimension]  = size(points);
    
    % Auxiliar vector with same number of lines from points and one in
    % all positions
    dim = ones(1,n);
    
    % Apply the operation (in this case, divide each vector by own norm)
    cellsSphere = mat2cell(points,dim,[dimension])';
    cellsSphere = cellfun(@(x) x/norm(x),cellsSphere,'UniformOutput',false);
    np = cell2mat(cellsSphere');
end