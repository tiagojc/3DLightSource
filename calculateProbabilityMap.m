function PB = calculateProbabilityMap(fileName, pw, sl, id, ci)
%FUNCTION calculateProbabilityMap(fileName, pw, sl, id, ci)
%
%   Calculates the probability map over the sphere surface and projects,
%   choose a countour with X degrees of confidence, this  
%   countour back to the image plane
%
%PARAMETERS
%
%   fileName : the file containing the light sources estimates
%
%   pw : parzen width
%
%   sl : the size of sensor
%
%   id : the size of the image (usually 180)
%
%   ci : the confidence interval
%
%RETURNS
%
%   pb : a id-by-id matrix containing the probability distribution
%   calculated over the unit sphere and projected into the image plane
%
    
    % Set default parameters
    ls = [0 0 0];
    fl = 10.0;
    pp = [0.0 0.0];


    % Read the light source estimations from a source file adding these
    % estimatives into nn variable
    %[normalsV, positions, intensities] = readNormalsFile(fileName);
    
    % Construct intrinsic matrix
    K = intrinsicCameraMatrix(pp,fl);
    
    % Read disturbed light source estimations file
    tt = strcat('disturbed-light-source-estimations/',fileName);
    nn = dlmread(tt, ' ');
    
    % Keep just the light source position
    nn = nn(:,1:3);

    % Calculates the azimuth/elevation map distribution 
    P2D = azimuthElevationParzen(nn',pw,id,fl,pp,sl);
    
    % Calculates the weight of each pixel in a true probability
    % distribution over the entire sphere
    [wp th ph] = sphareas([id 2*id]);
    
    % Convert map axis ranges to degrees 
    th = th*180/pi;
    ph = ph*180/pi;
    
    % Calculates the true probability map
    TPM = P2D .* wp;
    
    % Get a grid of the same size of probability map but pointing the
    % confidence interval of each position 
    CM = cif(TPM);
    
    % Take the position with a confidence bigger than 90% and take the 
    % contour of this region
    tt1 = CM > (1-ci);
    
    %Scale confidence intervals values by 100
    cit = ci*100;
    
    % Write into a text file the probability map
    apm = strcat('probabilities-distributions/',fileName,'-azimuth-elevation-prob-map-',num2str(cit),'.txt');
    fileIDapm = fopen(apm,'w');
    dlmwrite(apm,TPM,'delimiter', '\t')
    fclose(fileIDapm);
   
    % Write into a text file the confidence interval points
    apm = strcat('probabilities-distributions/',fileName,'-azimuth-elevation-conf-interv-',num2str(cit),'.txt');
    fileIDapm = fopen(apm,'w');
    dlmwrite(apm,tt1,'delimiter', '\t');
    fclose(fileIDapm);
    

end