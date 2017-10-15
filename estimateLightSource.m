function [lightDirection,condition,ambient] = estimateLightSource(normals,intensities)
%FUNCTION [lightDirection,condition,ambient] = estimateLightSource(normals,intensities)      
%
%   Take the normals from four or more points and estimate light source
%   using 3D information and based on M. Johnson and H. Farid, Exposing 
%   digital forgeries by detecting inconsistencies in lighting
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
%   lightDirection : a 1-by-3 vector containing the 3D coordinates for the
%   normal direction
%
%   condition : check if the linear system is possible to be solved
%
%   ambient : ambient term value
%

    % Transfor the normal matrix in homogeneous coordinates
    hv = ones(size(normals,1),1);
    M = [normals hv];
    
    % Apply the algorithm described by Jonhson and Farid to solve a linear
    % system
    b = intensities;
    M1 = M'*M;
    condition = cond(M1);
    M2 = pinv(M1);
    M3 = M2 * M';
    M4 = M3*b;
    M5 = [M4(1,1) M4(2,1) M4(3,1)];
    ambient = M4(4,1);
    M6 = M5/norm(M5);
    lightDirection = M6;
end