function rect2 = OPT_crop(dataFolder,cropfile,rot_axis)

    dataFiles = dir(strcat(dataFolder,'*.tif'));
    dataNames = { dataFiles.name };
    sizeCheck = imread(strcat(dataFolder,dataNames{1}));
    sizeCheck = size(sizeCheck);
    volume = zeros(sizeCheck(1),sizeCheck(2),length(dataNames));
    
    for i=1:length(dataNames)
        volume(:,:,i) = imread(strcat(dataFolder,dataNames{i}));
    end
    
    mip = max(volume,[],3)/max(volume(:));    
    
    finished = 0;    
    while ~finished
        [~,rect2] = imcrop(mip);
        rect2 = round(rect2);
        if rot_axis == 2
            delta = (sizeCheck(1)-rect2(4)-rect2(2))-rect2(2);
            if delta > 0
                rect2(4) = sizeCheck(1)-2*rect2(2);
            else
                rect2(2) = sizeCheck(1)-rect2(4)-rect2(2);
                rect2(4) = sizeCheck(1)-2*rect2(2);
            end
        else
            delta = (sizeCheck(2)-rect2(3)-rect2(1))-rect2(1);
            if delta > 0
                rect2(3) = sizeCheck(2)-2*rect2(1);
            else
                rect2(1) = sizeCheck(2)-rect2(3)-rect2(1);
                rect2(3) = sizeCheck(2)-2*rect2(1);
            end     
        end
        
        %for i=1:length(dataNames)
        %    RGB = insertShape(volume(:,:,i)./max(max(volume(:,:,i))),'rectangle',rect2,'LineWidth',5);
        %    imshow(RGB)
        %end
        close all
        %prompt = 'Type 1 if crop is good, 0 if bad. ';
        %finished = input(prompt);        
        finished = 1;
    end
    
    sizeCheck = imcrop(volume(:,:,1),rect2);
    croppedVolume = zeros(size(sizeCheck,1),size(sizeCheck,2),size(volume,3));
    for i=1:size(volume,3)
        croppedVolume(:,:,i) = imcrop(volume(:,:,i),rect2);        
    end
    save(cropfile,'croppedVolume','-v7.3');
    %save cropfile croppedVolume -v7.3;
    close all    
end