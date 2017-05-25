function rect2 = crop_3D(datafile,cropfile,rect2)
    
    volume = open(datafile);
    name = fieldnames(volume);
    volume = volume.(name{1});
    
    mip = max(volume,3);
    
    if nargin < 3
        finished = 0;
    else
        finished = 1;
    end
    while ~finished
        [~,rect2] = imcrop(mip);
        
        %for i=1:size(volume,3)
        %    RGB = insertShape(volume(:,:,i)./max(max(volume(:,:,i))),'rectangle',rect2,'LineWidth',5);
        %    imshow(RGB)
        %    pause(0.005)
        %end
        close all
        %prompt = 'Type 1 if crop is good, 0 if bad. ';
        %finished = input(prompt);
        finished = 1;
    end
    
    rect2 = round(rect2);
    sizeCheck = imcrop(volume(:,:,1),rect2);
    croppedVolume = zeros(size(sizeCheck,1),size(sizeCheck,2),size(volume,3));
    for i=1:size(volume,3)
        croppedVolume(:,:,i) = imcrop(volume(:,:,i),rect2);        
    end
    save(cropfile,'croppedVolume','-v7.3');
    %save cropfile croppedVolume -v7.3;
    close all
end