function orphan_tumour_processing
    %single script to batch process data - it assumes that each mCherry set has
    %a matching GFP acquisition - if there are orphaned datasets,
    %process them separately with orphan_tumour_processing. It can handle
    %single or multiple camera datasets

    % folder containing ometiffs
    mCherryFolder = 'C:\Users\fogim\Desktop\mCherry';

    % open and combine ome-tiffs, then save as tiffs in new folder
    %display('Unpacking ometiffs')
    %two_camera_ometiff_unpack(strcat(gfpFolder,'\'));
    %two_camera_ometiff_unpack(strcat(mCherryFolder,'\'));
    %display('Ometiffs unpacked')
    
    mCherryRawFolder = strcat(mCherryFolder,'\raw\');
    
    mCherryDataFolders = dir(mCherryRawFolder);
    mCherryDataFolders = mCherryDataFolders(arrayfun(@(x) x.name(1), mCherryDataFolders) ~= '.');
    mCherryDataNames = { mCherryDataFolders.name };    
    
    mCherryCropFolder = strcat(mCherryFolder,'\cropped');
    mkdir(mCherryCropFolder);     
    
    for n = 1:(length(mCherryDataNames))
        display(strcat('Cropping projections ',int2str(n),' of',' ',int2str(length(mCherryDataNames))))        
        OPT_crop(strcat(mCherryRawFolder,mCherryDataNames{n},'\'),strcat(mCherryCropFolder,'\',mCherryDataNames{n},'.mat'),2);       
    end
    
    for n = 1:(length(mCherryDataNames))
        display(strcat('Aligning projections ',int2str(n),' of',' ',int2str(length(mCherryDataNames))))
        dataFile = strcat(mCherryCropFolder,'\',mCherryDataNames{n},'.mat');
        proj = open(dataFile);
        name = fieldnames(proj);
        proj = proj.(name{1});
        [~, ~, proj] = one_camera_registration(proj,2);
        save(dataFile,'proj','-v7.3');
        clear proj
    end

    mCherryReconFolder = strcat(mCherryFolder,'\reconstructions');
    mkdir(mCherryReconFolder);    
    
    for n = 1:length(mCherryDataNames)
        display(strcat('Reconstructing projections ',int2str(n),' of',' ',int2str(length(mCherryDataNames))))        
        cropfile = strcat(mCherryCropFolder,'\',mCherryDataNames{n},'.mat');
        %threshedfile = strcat(mCherryCropFolder,'\',mCherryDataNames{n},'.mat');
        TwISTmCherry(cropfile,strcat(mCherryReconFolder,'\',mCherryDataNames{n},'.mat'));
    end
    
    for n = 1:length(mCherryDataNames)
        saveFolder = strcat(mCherryReconFolder,'\',mCherryDataNames{n},'\');
        mkdir(saveFolder)
        dataFile = strcat(mCherryReconFolder,'\',mCherryDataNames{n},'.mat');
        volume = open(dataFile);
        name = fieldnames(volume);
        volume = volume.(name{1});        
        maxvalue = max(volume(:));
        volume = volume/maxvalue*2^16;
        for i = 1:size(volume,3)
            imwrite(uint16(volume(:,:,i)),strcat(saveFolder,sprintf('%04d',i),'.tif'));
        end
    end



    mCherryReconCropFolder = strcat(mCherryReconFolder,'\Cropped');  
    mkdir(mCherryReconCropFolder);        
    mCherryReconThreshFolder = strcat(mCherryReconFolder,'\Thresholded');  
    mkdir(mCherryReconThreshFolder);  
    mCherryReconVesselFolder = strcat(mCherryReconFolder,'\Vessels');  
    mkdir( mCherryReconVesselFolder);  
    
    scale=5;
    
    for n = 1:length(mCherryDataNames)
        volumefile = strcat(mCherryReconFolder,'\',mCherryDataNames{n},'.mat');
        croppedfile = strcat(mCherryReconCropFolder,'\',mCherryDataNames{n},'.mat');
        threshedfile = strcat(mCherryReconThreshFolder,'\',mCherryDataNames{n},'.mat');
        vesselfile = strcat(mCherryReconVesselFolder,'\',mCherryDataNames{n},'.mat');
        vesselfile2 = strcat(mCherryReconVesselFolder,'\',mCherryDataNames{n},'2.mat');
        display(strcat('Cropping vasculature volume ',int2str(n),' of',' ',int2str(length(mCherryDataNames))))                        
        crop_3D(volumefile,croppedfile);
        display(strcat('Thresholding vasculature volume ',int2str(n),' of',' ',int2str(length(mCherryDataNames))))
        volume_thresh(croppedfile,threshedfile);
        
        vessel_data = open(threshedfile);
        name = fieldnames(vessel_data);
        vessel_data = vessel_data.(name{1});
        vessel_data = VesselEnhanceFilter3D(vessel_data,[1 scale],2,false);
        display(strcat('Enhancing vessels ',int2str(n),' of',' ',int2str(length(mCherryDataNames))))
        save(vesselfile ,'vessel_data','-v7.3');
        %save vesselfile vessel_data -v7.3;
        
        vessel_data = uint8(vessel_data./max(vessel_data(:)).*256);
        save(vesselfile2 ,'vessel_data','-v7.3'); 
        %save vesselfile2 vessel_data -v7.3;
        
    end
    
end