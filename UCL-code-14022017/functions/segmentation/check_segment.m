function good = check_segment(dataFolder)

    dataFiles = dir(strcat(dataFolder,'*.tif'));
    dataNames = { dataFiles.name };
    
    for i=1:length(dataNames)
        figure(1)
        imagesc(imread(strcat(dataFolder,dataNames{i}))); 
        pause(0.05);
    end
    close all
    prompt = 'Type 1 if good, 0 if too much data removed. ';
    good = input(prompt);
    
end