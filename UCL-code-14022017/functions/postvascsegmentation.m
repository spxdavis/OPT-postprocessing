function postvascsegmentation(datafile,threshedfile,savefile)

    vessels = open(datafile);
    name = fieldnames(vessels);
    vessels = vessels.(name{1});
    
    %SAVE AS NII FILES
    nii=make_nii(vessels);
    save_nii(nii,strcat(datafile(1:end-3),'nii')); %CHANGE THIS ACCORDINGLY

    %EXTRACT TUMOUR VASCULATURE- MASK
    %LOAD TUMOUR DATASET AGAIN
    tumour = open(threshedfile);
    name = fieldnames(tumour);
    tumour = tumour.(name{1});
    
    tumour(isnan(tumour(:)))=0;
    tumour = tumour>0;
    se = strel('disk',50,0);
    tumour=gpuArray(single(tumour));

    % Sam speed up
    SE = gpuArray(single(se.getnhood()));
    for i=1:size(tumour,3)
        tumour(:,:,i) = conv2(tumour(:,:,i),SE,'same');
    end

    vessels(~tumour) = 0;

    save(savefile,'vessels','-v7.3');
    %save savefile vessels -v7.3;
    nii=make_nii(vessels);
    save_nii(nii,strcat(savefile(1:end-3),'nii'));
end
