function estimateDisturbedLightSourceRawData(testName, np, factor)
%FUNCTION estimateDisturbedLightSourceRawData(testName, np, factor)
%
%   Estimates light source many times based in a previously provided 
%   normals, which are disturbed based on incertainly model. 
%
%PARAMETERS
%
%
%   testName : name of input file comprising normals information
%
%   np : the number of times that the light will be disturbed and
%   re-estimated
%
%   factor : the factor which controls the amount of perturbation
%   
%RETURNS
%
%   none
%

    % Set default parameters
    ls = [0 0 0];
    fl = 10.0;
    pp = [0.0 0.0];
     
    %Read slant and tilt distributions. 
    tt = load('distributions/slant-centers.mat');
    slantCenters = tt.centers;
    tt = load('distributions/tilt-centers.mat');
    tiltCenters = tt.centers;
    tt = load('distributions/slant-bins.mat');
    slantBins = tt.bins;
    tt = load('distributions/tilt-bins.mat');
    tiltBins = tt.bins;
     
     
    tic;
    outFile = strcat('disturbed-light-source-estimations/raw-',testName,'-',num2str(np));
     
    % Read normals from a text file
    [normalsV, positions, intensities] = readNormalsFile(testName);
    
    % Get de number of normals provided by the file
    nn = size(normalsV,1);
    
    % Create a vector to hold light source estimations
    lightSourceEstimations = [];
     
    % Get intrinsic camera matrix
    K = intrinsicCameraMatrix(pp,fl);
    
    % Open output file
    fileID = fopen(outFile,'w');
    
    %Estimate light source without disturb normals 
    [ld cond amb] = estimateLightSource(normalsV,intensities);
    
    % Convert 3-D light source position into Azimuth and Elevation
    % positions
    posAE = vec2sph2(ld'); 
    
    % Convert from radians to degrees 
    posAE(1:2,:) = posAE(1:2,:)*180/pi;
    sourceAzimuth = posAE(1,1);
    sourceElevation = posAE(2,1);
     

     i = 1;
     rng(1);
     
     %disturb normals np times for create distribution of light source
     %position
     while i <= np
         i
         disturbedNormals = [];
         for j=1:nn
            tt = normalsV(j,:);
            
            % Convert from 3-D coordinates to tilt and slant coordinates
            ttts = n2ts(tt',positions(j,:)',K);
            s = ttts(1,2);
            t = ttts(1,1);
           
            % Keeps tilt between 0 and 360 because corretion models works
            % with tilt between 0 and 360
            if t < 0
                t = 180 + (180 + t);
            else
                t = t;
            end
            
            % This perturbation approach is a little different from my 
            % previously approach proposed by Kee and Farid. At that 
            % approach, the amount of perturbation is weighted just by a 
            % factor. Here we consider this factor and also the position of
            % the light source estimation without perturbation
            [ns nt] = disturbSlantTiltWeightByPosition(s,t, slantCenters, tiltCenters, slantBins, tiltBins, sourceAzimuth, sourceElevation, factor);
            
            
            % Convert tilt back to range -180 to 180 (Erick domain
            % function)
            if nt > 180
                nt = -180 + (nt - 180);
            end
            
            % Convert new disturbed normal from slant and tilt back to 3-D
            % coordinates
            newnormal = ts2n([nt;ns],positions(j,:)',K);
            
            % Include disturbed normal into a matrix
            disturbedNormals = [disturbedNormals;newnormal'];
         end
        
         % Estimate light source direction and ambient term withou
         % normalize light source direction vector.
         lightDirection = estimateLightSourceRaw(disturbedNormals,intensities);
         lightDirection = lightDirection';
         
         % Normalize light source vector and write values in output file;
         M5 = [lightDirection(1,1) lightDirection(1,2) lightDirection(1,3)];
         normalvalue = norm(M5);
         ambient = lightDirection(1,4);
         M6 = M5/normalvalue;
         lst = M6;
         fprintf(fileID, '%.4f %.4f %.4f %.4f ',lightDirection(1,1),lightDirection(1,2),lightDirection(1,3),ambient);
      
         % Calculates the number of disturbed normals (in current light 
         % sourc estimation) in shadow region. If a normal (after to be 
         % disturbed) has an angle with light source position.
         tlz = 0;
         for j = 1:(size(disturbedNormals,1))
         	nnn = disturbedNormals(j,:);
            pos = positions(j,:);
            int = intensities(j,1);
            nnnt = nnn/norm(nnn);
            fprintf(fileID, '%.4f %.4f %.4f ',nnn(1,1),nnn(1,2),nnn(1,3));
            fprintf(fileID, '%.4f ',int);
            fprintf(fileID, '%.4f %.4f ',pos(1,1),pos(1,2));
            tdp = lst * nnnt';
            if tdp < 0
                tlz = tlz + 1;
            end
         end
         fprintf(fileID, '%.1f %.4f \n',tlz,normalvalue);
         i = i + 1;
     end
     fclose(fileID);
     toc
end