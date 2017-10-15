function expContoursMultipleObjects(outname)
%
%   Read probability maps and combine them printing confidence intervals 
%   and heat maps from resulting combination
%  
%
%PARAMETERS
%
%   outname  : the base name of probability map which will be recorded in
%   confidenceMaps folder
%
%OUTPUT
%
%   write in confidenceMaps folder two files, one with contours and another
%   corresponding to heat map
%

    % Probability maps to be combined (files need to be in
    % probabilities-distributions folder
    objectsList = {'users-tests-spie01-20000';...
                   'users-tests-spie02-20000';...
                   'users-tests-spie03-20000';...
                   'users-tests-spie04-20000';...
                   'users-tests-spie05-20000';...
                   'users-tests-spie09-20000';...
                   'users-tests-spie06-20000'
                   };

    % Get the number of maps which will be combined
    numObj = size(objectsList,1);    
    users = [100 100 100 100 100 100 100];
    
    % Create three dimensional matrix to keep probability maps read from
    % text files
    mapsConf = zeros(180,360,numObj);
    mapsProb = zeros(180,360,numObj);
    
    % The last part of input file.
    ci = 99;
    
    % Read probability maps from txt files 
    for i=1:numObj
        fileName = objectsList{i};
        userid = users(1,i);
        apm = strcat('probabilities-distributions/',fileName,'-azimuth-elevation-prob-map-',num2str(ci),'.txt');
        tt = dlmread(apm,'\t');
        maps = cif(tt);   
        [az el] = sphmaprange(size(maps));
        az = az*180/pi;
        el = el*180/pi;  
        mapsConf(:,:,i) = maps(:,:);
        mapsProb(:,:,i) = tt(:,:);
    end
    
    % The curves of confidence intervals
    cis = [0.6 0.90 0.95 0.99];
    
    %Plot a initial blank heat map
    tpf = figure(1); 
    clf;
    blankMap = ones(180,360);
    imagesc(az,el,blankMap,(0:1)); axis equal xy tight; colormap gray; hold on; 
    set(gca, 'xtick', linspace(-180,180,9));
    set(gca, 'ytick', linspace(-90,90,5));
    set(gca,'TickDir','out');

    % Get contour points from maps and combine them (Eric code) ploting
    % debug lines
    pointsList = [];
    listIni = 1;
    originalPoints = [];	
    ciValues = [];
    for i = 1:size(cis,2)
        c = contourc(az, el, mapsConf(:,:,1),1 - [cis(1,i) cis(1,i)]);
        c(:,1) = [];
        pts = c;
        pointsOut = pts;
        contourspts{1,1} = pts;
        for j = 2:size(mapsConf,3)
             c = contourc(az, el, mapsConf(:,:,j),1 - [cis(1,i) cis(1,i)]);
             c(:,1) = [];
             pts2 = c; 
             contourspts{j,1} = pts2;
        end
        pointsOut = cintersect(contourspts);
        if ~isempty(pointsOut)
            ciValues   = [ciValues cis(1,i)];
            pointsList = [pointsList [listIni + 1; listIni + size(pointsOut,2)]];
            pointsList = [pointsList pointsOut];
            listIni = listIni + size(pointsOut,2) + 1;
        else
          fprintf('CI %2.2f is empty\n', cis(1,i));
        end
    end

    % Plot contours
    j = 1;
    while true
        beg = j + 1;
        ned = floor(pointsList(2,j));
        pts = pointsList(:,beg:ned);
        plot(pts(1,:), pts(2,:), '-k');
        if ned < size(pointsList,2)
          j = ned+1;
        else
          break;
        end
    end

    %tempName = strcat('confidenceMaps/',outname,'-contour-',num2str(numObj),'-constraints_debug.pdf');
    %saveas(tpf,tempName);
    
    %Plot heat map and confidence interval without debug
    tpf = figure(1); 
    clf;
    blankMap = ones(180,360);
    imagesc(az,el,blankMap,(0:1)); axis equal xy tight; colormap gray; hold on; 
    set(gca, 'xtick', linspace(-180,180,9));
    set(gca, 'ytick', linspace(-90,90,5));
    set(gca,'TickDir','out');
    
    % Plot contours
    j = 1;
    while true
        beg = j + 1;
        ned = floor(pointsList(2,j));
        pts = pointsList(:,beg:ned);
        plot(pts(1,:), pts(2,:), '-k');
        if ned < size(pointsList,2)
          j = ned+1;
        else
          break;
        end
    end
    title(['Non-empty confidience intervals: ' sprintf('%2.0f%%  ', 100*sort(ciValues,'descend'))]);
    
    v = [0.5442 0.5442 0.4317 0.3851; 
         2.6908 2.5180 2.1904 2.3655; 
         5.0000 5.0000 5.0000 5.0000];
    m = sqrt(sum(v.^2));

    v = v./[m;m;m];

    a = vec2sph2(v) * 180/pi;
    a = a(1:2,:);
    a = [a a(:,1)];  % Make closed boundary

    %figure(1); hold on;
    %plot(a(1,:), a(2,:), '-r.');
    

    % Save output file
    tempName = strcat('confidenceMaps/',outname,'-contour-',num2str(numObj),'-constraints.pdf');
    saveas(tpf,tempName);
    %keyboard
end


