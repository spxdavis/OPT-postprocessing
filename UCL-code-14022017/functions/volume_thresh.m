function pixel_volume = volume_thresh(datafile,threshfile)

    volume = open(datafile);
    name = fieldnames(volume);
    volume = volume.(name{1});

    finished = 0;
    LL = floor(max(volume(:))/4);
    
    [valmax,locmax] = max(volume(:));
    [~,~,z] = ind2sub(size(volume),locmax);
    
    while ~finished    
    [LL,~] = manual_thresh(volume(:,:,z),'jet',LL);
    %[LL,~] = manual_thresh(volume(:,:,1));    
    close all
    
        for i=1:size(volume,3)            
            img = volume(:,:,i);
            catimg = vertcat(img.*(img>=LL),img);
            imshow(catimg,[0,valmax]);
            %pause(0.1)
        end
        close all
        prompt = 'Type 1 if threshold is good, 0 if bad. ';
        finished = input(prompt); 
    end

    for i=1:size(volume,3) 
        volume(:,:,i) = volume(:,:,i).*(volume(:,:,i)>=LL);
    end
    pixel_volume = sum(volume(:)>=LL);
    save(threshfile,'volume','-v7.3');
    nii=make_nii(volume);
    save_nii(nii,strcat(threshfile(1:end-3),'nii'));    
    %save threshfile volume -v7.3;
end