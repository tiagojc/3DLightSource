function filterRawData(fileName,selectedFilter,numUser)

    % Read raw data
    tt = strcat('disturbed-light-source-estimations/raw-',fileName);
    nn = dlmread(tt, ' ');
    
    % Create future new file
    tt = strcat('disturbed-light-source-estimations/',fileName);
    fid = fopen(tt,'w');
    
    % Select kind of light source estimations to be add in filtered file
    switch selectedFilter
        case 1      %select just estimations where normals and light source has an angle lower than 90
            
            % Get the column which contains the number of normals where the
            % angle between normal and light source direction bigger than 0
            col = size(nn,2) - 2;
            
            % Get just the lines where the angle between normal and light
            % source is bigger than 0 writting these lines in filtered file
            idx = find(nn(:,col) >= 0.0);
            tempTable = nn(idx,:);
            for i=1:size(tempTable,1)
               tx = tempTable(i,1);
               ty = tempTable(i,2);
               tz = tempTable(i,3);
               ls = [tx ty tz]/norm([tx ty tz]);
               fprintf(fid, '%.4f %.4f %.4f \n',ls(1,1),ls(1,2),ls(1,3));
            end
            
         case 2  %select just estimations where ambient is bigger than zero
            
            col = 4;
            % Get the columns where the ambient term is bigger than 0
            idx = find(nn(:,col) >= 0.0);
            tempTable = nn(idx,:);
            for i=1:size(tempTable,1)
               tx = tempTable(i,1);
               ty = tempTable(i,2);
               tz = tempTable(i,3);
               ls = [tx ty tz]/norm([tx ty tz]);
               fprintf(fid, '%.4f %.4f %.4f \n',ls(1,1),ls(1,2),ls(1,3));
            end 
        otherwise % not exclude any line
            tempTable = nn;
            %idx
            for i=1:size(tempTable,1)
               tx = tempTable(i,1);
               ty = tempTable(i,2);
               tz = tempTable(i,3);
               ls = [tx ty tz]/norm([tx ty tz]);
               fprintf(fid, '%.4f %.4f %.4f \n',ls(1,1),ls(1,2),ls(1,3));
            end
    end
    fclose(fid);
end