function [rect2, rect1] = crop_3D(datafile,cropfile,rect2,rect1)
    
    volume = open(datafile);
    name = fieldnames(volume);
    volume = volume.(name{1});
    
    volume(isnan(volume(:))) = 0;
    
    mip2 = squeeze(max(volume,[],2)/max(volume(:)));
    
    if nargin < 3
        finished = 0;
    else
        finished = 1;
    end
    while ~finished
        [~,rect2] = imcrop(mip2);        
        
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
    sizeCheck = imcrop(squeeze(volume(:,1,:)),rect2);
    croppedVolume = zeros(size(sizeCheck,1),size(volume,2),size(sizeCheck,2));
    for i=1:size(volume,2)
        croppedVolume(:,i,:) = imcrop(squeeze(volume(:,i,:)),rect2);        
    end
    
    if nargin < 3
        finished = 0;
    else
        finished = 1;
    end
    volume = croppedVolume;
    mip1 = squeeze(max(volume,[],1)/max(volume(:)));
    while ~finished
        [~,rect1] = imcrop(mip1);        
        
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
    
    rect1 = round(rect1);
    sizeCheck = imcrop(squeeze(volume(1,:,:)),rect1);
    croppedVolume = zeros(size(volume,1),size(sizeCheck,1),size(sizeCheck,2));
    for i=1:size(volume,1)
        croppedVolume(i,:,:) = imcrop(squeeze(volume(i,:,:)),rect1);        
    end    
    
    save(cropfile,'croppedVolume','-v7.3');
    %save cropfile croppedVolume -v7.3;
    close all
end