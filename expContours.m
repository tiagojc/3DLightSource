function expContours(fileName,ci)
%FUNCTION expContours(testName)
%
%   Read probability maps and print confidence intervals and heat maps
%   images
%
%PARAMETERS
%
%   fileName : the base name of probability map
%
%   ci : the confidence interval which is just used to select correct 
%   probability map file (last part of probability distribution name)
%
%OUTPUT
%
%   write in confidenceMaps folder two files, one with contours and another
%   corresponding to heat map
%

    % Set default parameters
    
    % Light source position
    ls = [0 0 0];
    
    % Focal Length 
    fl = 10.0;
    
    % Principal point
    pp = [0.0 0.0];
  
    % For images generated with Mitsuba applied into SPIE paper test,
    % transpose light source position.
    % cp is a 1-by-3 vector containing the camera rotations angles in X Y 
    % and Z respectively
    cp = [0 0 0];
    T = [0 4 30];
    T = normalizeByNorm(T);
    tt = rmtx(cp');
    nls = (tt * ls');
  
    % Convert ground truth light source position to azimuth/elevation
    % coordinates. 
    %nls = [0; 0.8944; -0.4472];
    posAE = vec2sph2(nls);
    posAE(1:2,:) = posAE(1:2,:)*180/pi;

    % Read the probability map
    apm = strcat('probabilities-distributions/',fileName,'-azimuth-elevation-prob-map-',num2str(ci),'.txt');
    probmap = dlmread(apm,'\t');
    
    % Get confidence interval from probability map
    map = cif(probmap);
    
    % Get spherical range into azimuth/elevation coordinates
    [az el] = sphmaprange(size(map));
    az = az*180/pi;
    el = el*180/pi;

    % Specify contour levels and obtain it from confidence interval map
    levels = [0.0:0.3:0.9 0.95 0.99];
    c = contourc(az, el, map, 1-levels);

    % Plot heat map
    tpf = figure(1); 
    clf;
    img = mapData(flipud(probmap),[],colormap(ericmap));
    imagesc(az,el,map,(0:1)); 
    axis equal xy tight; 
    colormap ericmap; 
    hold on; 
    
    % Set image ranges
    set(gca, 'xtick', linspace(-180,180,9));
    set(gca, 'ytick', linspace(-90,90,5));
    set(gca,'TickDir','out');
    
    % Plot ground truth light source position
    scatter(posAE(1,1),posAE(2,1),30,'k','filled');
    
    % Write result image
    tempName = strcat('confidenceMaps/',fileName,'-heat-map.png');
    imwrite(img,tempName,'png');

    
    % Plot contours
    j = 1;
    while true
        beg = j + 1;
        ned = j + c(2,j);

        pts = c(:,beg:ned);
        plot(pts(1,:), pts(2,:), '-k');

        if ned < size(c,2)
            j = ned+1;
        else
            break;
        end
    end

    % Save contour image
    tempName = strcat('confidenceMaps/',fileName,'-contour.pdf');
    saveas(tpf,tempName);
    keyboard
end


