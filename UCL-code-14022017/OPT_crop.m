function rect2 = OPT_crop(dataFolder,cropFolder,rot_axis)

    dataFiles = dir(strcat(dataFolder,'*.tif'));
    dataNames = { dataFiles.name };
    sizeCheck = imread(strcat(dataFolder,dataNames{1}));
    sizeCheck = size(sizeCheck);
    volume = zeros(sizeCheck(1),sizeCheck(2),length(dataNames));
    
    for i=1:length(dataNames)
        volume(:,:,i) = imread(strcat(dataFolder,dataNames{i}));
    end

    finished = 0;    
    while ~finished
        [~,rect2] = imcrop(volume(:,:,1)./max(max(volume(:,:,1))));
        
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
        
        for i=1:length(dataNames)
            RGB = insertShape(volume(:,:,i)./max(max(volume(:,:,i))),'rectangle',rect2,'LineWidth',5);
            imshow(RGB)
        end
        prompt = 'Type 1 if crop is good, 0 if bad. ';
        finished = input(prompt);        
    end

    for i = 1:length(dataNames)
        I = imcrop(volume(:,:,i),rect2);
        imwrite(uint16(I),strcat(cropFolder,dataNames{i}));
    end
    close all
end