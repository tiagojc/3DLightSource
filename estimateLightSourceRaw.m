function [lightDirection] = estimateLightSourceRaw(normals,intensities)
%FUNCTION lightDirection = estimateLightSource(normals,intensitiesIllumination)      
%
%   Take the normals from four or more points and estimate light source
%   using 3D information and based on M. Johnson and H. Farid, Exposing 
%   digital forgeries by detecting inconsistencies in lighting. Different
%   from previously light source estimation function, this one doesnt
%   normalize light source vector 
%
%
%PARAMETERS
%
%   normals : a m-by-3 matrix where each line contains a 3D normal surface
%   coordinates
%
%   intensities : the grayscale value for each normal
%
%RETURNS
%
%   lightDirection : a 1-by-4 vector containing the 3D coordinates of light
%   source direction and ambient term

    % Transform the normal matrix in homogeneous coordinates
    hv = ones(size(normals,1),1);
    M = [normals hv];
    
    % Apply the algorithm described by Jonhson and Farid
    b = intensities;
    M1 = M'*M;
    M2 = pinv(M1);
    M3 = M2 * M';
    M4 = M3*b;
    
    lightDirection = M4;
    
    % Separates light source direction an ambient term normalizing light
    % source direction vector
    %M5 = [M4(1,1) M4(2,1) M4(3,1)];
    %ambient = M4(4,1);
    %M6 = M5/norm(M5);
    
end