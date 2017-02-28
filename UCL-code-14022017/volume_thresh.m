function pixel_volume = volume_thresh(datafile,threshfile)

    volume = open(datafile);
    name = fieldnames(volume);
    volume = volume.(name{1});

    finished = 0;
    LL = 300;    
    while ~finished    
    [LL,~] = manual_thresh(volume(:,:,ceil(size(volume,3)/2)),'jet',LL);
    close all
        for i=1:size(volume,3)            
            img = volume(:,:,i);
            img = [img.*(img>=LL);img.*(img<LL)];
            imshow(img,[]);
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
    %save threshfile volume -v7.3;
end