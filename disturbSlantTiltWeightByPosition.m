function [ns nt] = disturbSlantWeightByPosition(slant, tilt, slantCenters, tiltCenters, slantBins, tiltBins, sourceAzimuth, sourceElevation, factor)
%FUNCTION function [ns nt] = disturbSlantWeightByPosition(slant, tilt, slantCenters, tiltCenters, slantBins, tiltBins, sourceAzimuth, sourceElevation, factor)
%
%   Given some slant and tilt angles (degrees) and CDFs (cumulative
%   distribution function) for slant and tilt, randomly disturb the 
%   original given angles based on distributions values
%
%PARAMETERS
%
%   slant : the slant angle (in degrees) to be disturbed
%
%   tilt : the tilt angle (in degrees) to be disturbed 
%
%   slantCenters : a vector comprising slant distribution centers values 
%
%   tiltCenters : a vector comprising tilt distribution centers values
%
%   slantBins : a matrix where each column is a cell vector which comprises
%   errors from user marks relative to the ground truth for slant
%
%   tiltBins : a matrix where each column is a cell vector which comprises
%   errors from user marks relative to the ground truth for tilt correlated
%   with slant
%
%   sourceAzimuth : the azimuth position for light source estimation 
%   without perturbation
%
%   sourceElevation : the elevation position for light source estimation 
%   without perturbation
%
%	factor : the amount of perturbation. Values between 0 and 1. 
%
%
%

    % Detect which bin better fit to user mark relative to slant
    [min_val, index] = min(abs(slantCenters - slant));
    
    % Get slant error distribution for slant bin selected in previously
    % step
    currentDistribution = slantBins{1,index}; 
   
    % Randomly get a position of distribution vector which gonna be
    % additive value of correction for tilt
    cumdist = linspace(0,1,numel(currentDistribution));
    dist = rand(1);
    angularDist = interp1(cumdist,currentDistribution,dist,'spline');
        
        
    % Calculate the scale which control the amount of correction based on a
    % previously light source estimation (without disturb normals)
    scaleSlant =(1 - abs(sourceAzimuth/180.0))/2.0; 
    scaleTilt = (1 - abs(sourceElevation/90.0))/2.0;
        
    % To get back implementation of SPIE paper just comment scale 
    % expressions above and uncomment these ones below    
    %scaleSlant = factor;
    %scaleTilt = factor;

        
    % Randomly decide if the amount of error will be increased or decreased
    flag = randi(2);
    if flag == 1
        ns = slant + (angularDist * scaleSlant);
    else
        ns = slant - (angularDist * scaleSlant);
    end
    if ns < 0
        ns = 0;
    end
    if ns > 90
        ns = 90;
    end

    
    % Detect which bin better fit to user mark relative to tilt. However,
    % tilt distribution is a conditional (associated with slant)
    % distribution. So, tilt bin is chosen based on slant mark
    [min_val, index] = min(abs(tiltCenters - slant));
    
    % Get slant error distribution for tilt bin selected in previously
    % step
    currentDistribution = tiltBins{1,index};  
    
    % Randomly get a position of distribution vector which gonna be
    % additive value of correction for tilt
    cumdist = linspace(0,1,numel(currentDistribution));
    dist = rand(1);
    angularDist = interp1(cumdist,currentDistribution,dist,'spline');
    flag = randi(2);
    
    % Randomly decide if the amount of error will be increased or decreased
    if flag == 1
        nt = tilt + (angularDist * scaleTilt);
    else
        nt = tilt - (angularDist * scaleTilt);
    end
    if nt < 0
        nt = 180 + (180 + nt);
    end
    if nt > 360
        nt = nt - 360 ;
    end
end