function [hshift, rotation] = one_camera_registration(dataFolder,rotaxis,angleList,szT)
    % function to return the shift and rotation needed to register the projections
    % found in dataFolder for reconstruction. rotaxis = 1 for a vertical
    % rotation axis and 2 for a horizontal rotation axis
    M1_brightness_quantile_threshold = 0.8;
    
    if ischar(dataFolder)
        % find file names and check size of projections
        dataFiles = dir(strcat(dataFolder,'*.tif'));
        dataNames = { dataFiles.name };    
        sizeCheck = imread(strcat(dataFolder,dataNames{1}));

        rawproj = zeros(size(sizeCheck,1),size(sizeCheck,2),length(dataNames));
        for i = 1:size(rawproj,3)
            rawproj(:,:,i) = imread(strcat(dataFolder,dataNames{i}));
        end
    else
        rawproj = dataFolder;
    end

    
    
    if nargin == 4
        dataNames = dataNames(mod(1:length(dataNames),szT)==2);
        M1_brightness_quantile_threshold = 0.5;
    end
    
    if nargin < 3
        anglestep = 360/size(rawproj,3);
        angleList = (0:(size(rawproj,3)-1))*anglestep;
    end
    
    

    
    offset = min(rawproj(:));
    rawproj = rawproj-offset;
    
    if rotaxis == 1
        for i = 1:size(rawproj,3)
            rawproj(:,:,i) = rawproj(:,:,i)';
        end
    end
    
    hshift = 0;
    rotation = 0;
    finished = 0;
    
    while ~finished
        clear proj
        for i = 1:size(rawproj,3)
            proj(:,:,i) = imshift(rawproj(:,:,i),0,hshift,-rotation);
        end 
        projBrightness = squeeze(mean(mean(proj,1),2));
        %if min(projBrightness) < max(projBrightness)/2

        %    [~,index] = min(projBrightness);
        %    if index <= size(proj,3)/4
        %        first = index + 1 + size(proj,3)/4;
        %        last = index + size(proj,3)*3/4;
        %        proj = proj(:,:,first:last);
        %        angleList = angleList(first:last);
        %    elseif  index >= size(proj,3)*3/4
        %        first = index + 1 - size(proj,3)*3/4;
        %        last = index - size(proj,3)/4;
        %        proj = proj(:,:,first:last);
        %        angleList = angleList(first:last);            
        %    else
        %        first = index + size(proj,3)/4+1;
        %        last = index - size(proj,3)/4;
        %        proj = cat(3,proj(:,:,first:end),proj(:,:,1:last));
        %        angleList = [angleList(first:end), angleList(1:last)];            
        %    end
        %end

        sample = zeros(size(rawproj,2),1);
        for y=1:size(rawproj,2)
            sino = squeeze(cast(proj(:,y,:),'single'));
            sample(y) = mean(sino(:));
        end
        T = quantile(sample, M1_brightness_quantile_threshold);
        brightEnough = sample > T;

        %nRegions = 16;
        %regions = ceil([1,(1:nRegions)*size(sizeCheck,2)/nRegions]);
        %for i = 1:nRegions
        %    [~,dim] = sort(sample(regions(i):regions(i+1)));
        %    brightEnough(dim(1:(end-10))+regions(i)-1) = 0;
        %end

        % The shift correction and spearman correlation for individual slices are then
        % found

        if isGpuAvailable
            shift = gpuArray(NaN(length(brightEnough),1));
            r = gpuArray(NaN(length(brightEnough),1));
        else
            shift = NaN(length(brightEnough),1);
            r = NaN(length(brightEnough),1);
        end

        for n = 1:length(brightEnough)
            if brightEnough(n)
                sino = squeeze(proj(:,n,:));
                [shift(n), r(n)] = quickMidindex(sino,20,2,angleList);
            end    
        end


        if isGpuAvailable
            shift = gather(shift);
        end

        % filter out shifts which imply large image rotation
        for n = 1:2
            delt = abs(shift-nanmean(shift));
            shift(delt>9) = NaN;
        end

        % slice numbers relative to centre of image, filtered, and then cropped
        ns = (1:length(brightEnough))'-length(brightEnough)/2;
        ns = ns(~isnan(shift));
        shift = shift(~isnan(shift));
        figure(2); histogram2(ns,shift,'YBinEdges',-21:2:21,'DisplayStyle','tile','ShowEmptyBins','on');
        drawnow;
        %figure(1); plot(ns,shift,'r+');

        % fit shift and rotation
        %p = polyfit(ns,shift,1);
        %shift1 = polyval(p,ns);
        %hold; plot(ns,shift1); hold;
        %hshift = round(p(2));
        %rotation = atan(p(1));
        fitobject = fit(ns,shift,'poly1','Robust','on');
        newshift = round(fitobject.p2);
        newrotation = fitobject.p1;
        if (abs(tan(newrotation)) < 1/size(proj,2)) & (abs(newshift) < 1) 
            finished = 1;
        else
            hshift = hshift + newshift
            rotation = rotation + newrotation/2
        end
    end
end