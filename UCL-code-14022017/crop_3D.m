function crop_3D(datafile,cropfile)

    volume = open(datafile);
    name = fieldnames(volume);
    volume = volume.(name{1});
    finished = 0;    
    while ~finished
        [~,rect2] = imcrop(volume(:,:,ceil(size(volume,3)/2))./max(max(volume(:,:,ceil(size(volume,3)/2)))));
        
        for i=1:size(volume,3)
            RGB = insertShape(volume(:,:,i)./max(max(volume(:,:,i))),'rectangle',rect2,'LineWidth',5);
            imshow(RGB)
            pause(0.1)
        end
        prompt = 'Type 1 if crop is good, 0 if bad. ';
        finished = input(prompt);        
    end
    
    rect2 = round(rect2);
    sizeCheck = imcrop(volume(:,:,1),rect2);
    croppedVolume = zeros(size(sizeCheck,1),size(sizeCheck,2),size(volume,3));
    for i=1:size(volume,3)
        croppedVolume(:,:,i) = imcrop(volume(:,:,i),rect2);        
    end
    %save(cropfile,'croppedVolume');
    save cropfile croppedVolume -v7.3;
    close all
end