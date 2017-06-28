function GFP_crop(dataFolder,cropfile,rect2)

    dataFiles = dir(strcat(dataFolder,'*.tif'));
    dataNames = { dataFiles.name };
    
    sizeCheck = imread(strcat(dataFolder,dataNames{1}));
    sizeCheck = imcrop(sizeCheck,rect2);
    croppedVolume = zeros(size(sizeCheck,1),size(sizeCheck,2),length(dataNames));   
    
    for i = 1:length(dataNames)
        I = imread(strcat(dataFolder,dataNames{i}));
        croppedVolume(:,:,i) = imcrop(I,rect2);
        %imwrite(I,strcat(cropFolder,dataNames{i}));
    end
    save(cropfile,'croppedVolume','-v7.3');
    %save cropfile croppedVolume -v7.3;
    close all    
end