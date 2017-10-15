function [normalsV, positions, intensities] = readTestDataUsers(testName)
%FUNCTION readTestData(testName)
%
%   Read data from normals
%
%PARAMETERS
%
%   testName : name of file comprising normals information 
%
%RETURNS
%
%   normalsV : a m-by-3 matrix comprising the normals placed by the user
%
%   positions : a m-by-2 matrix comprising the position from each normal
%
%   intensities a m-by-1 vector containing the intesities from pixels where
%   the normals have been placed

    % Open normals file
    tt = strcat('object-normals/',testName,'.txt');
    fileID = fopen(tt,'r');
    tline = fgets(fileID);
    
    % Initialize output vectors
    normalsV = [];
    positions = [];
    intensities = [];
    groundTruth = [];
    
    % Load all normals in file
    while ischar(tline)
        
        % Read normal position in normalized image coordinates (unit
        % sphere)
        x = str2num(strsplit(tline,' ',2));
        y = str2num(strsplit(tline,' ',3));
        tt = [x y];
        positions = [positions;tt];
        
        % Read normal direction
        x = str2num(strsplit(tline,' ',5));
        y = str2num(strsplit(tline,' ',6));
        z = str2num(strsplit(tline,' ',7));
        tt = [x y z];
        normalsV = [normalsV;tt];
        
        % Read image intensity in normal position
        x = str2num(strsplit(tline,' ',9));
        intensities = [intensities; x];
        
        tline = fgets(fileID);
    end
    fclose(fileID);
end