function GFP_crop(dataFolder,cropFolder,rect2)

    dataFiles = dir(strcat(dataFolder,'*.tif'));
    dataNames = { dataFiles.name };
    
    for i = 1:length(dataNames)
        I = imread(strcat(dataFolder,dataNames{i}));
        I = imcrop(I,rect2);
        imwrite(I,strcat(cropFolder,dataNames{i}));
    end
    
end