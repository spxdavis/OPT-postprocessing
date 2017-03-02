function projection_thresh(dataFolder, savename)

    dataFiles = dir(strcat(dataFolder,'*.tif'));
    dataNames = { dataFiles.name };
    sizeCheck = imread(strcat(dataFolder,dataNames{1}));
    sizeCheck = size(sizeCheck);
    volume = zeros(sizeCheck(1),sizeCheck(2),length(dataNames));
    
    for i=1:length(dataNames)
        volume(:,:,i) = imread(strcat(dataFolder,dataNames{i}));
    end
    
    LL = floor(max(volume(:))/4);    
    finished = 0;
    while ~finished    
    %[LL,~] = manual_thresh(volume(:,:,1));
    [LL,~] = manual_thresh(volume(:,:,ceil(size(volume,3)/2)),'jet',LL);
    close all
        for i=1:length(dataNames)            
            img = volume(:,:,i);
            img = [img.*(img>=LL);img.*(img<LL)];
            imshow(img,[])
            %pause(0.1)
        end
        close all
        prompt = 'Type 1 if threshold is good, 0 if bad. ';
        finished = input(prompt); 
    end


    %for i = 1:length(dataNames)
    %    img = volume(:,:,i);
    %    img = img.*(img>=LL);
    %    imwrite(uint16(img),strcat(threshFolder,dataNames{i}));
    %end
    
    volume = volume.*(volume>=LL);
    save(savename,'volume','-v7.3');
end