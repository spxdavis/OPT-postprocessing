function tumour_volumes = tumour_processing
    %single script to batch process data - it assumes that each mCherry set has
    %a matching GFP acquisition - if there are orphaned datasets,
    %process them separately with orphan_tumour_processing. It can handle
    %single or multiple camera datasets

    % folder containing ometiffs
    gfpFolder = 'C:\workfolder\GFP_folder';
    mCherryFolder = 'C:\workfolder\mCherry_folder';

    % open and combine ome-tiffs, then save as tiffs in new folder
    %display('Unpacking ometiffs')
    %two_camera_ometiff_unpack(strcat(gfpFolder,'\'));
    %two_camera_ometiff_unpack(strcat(mCherryFolder,'\'));
    %display('Ometiffs unpacked')
    
    gfpRawFolder = strcat(gfpFolder,'\raw\');
    mCherryRawFolder = strcat(mCherryFolder,'\raw\');

    gfpDataFolders = dir(gfpRawFolder);
    gfpDataFolders = gfpDataFolders(arrayfun(@(x) x.name(1), gfpDataFolders) ~= '.');
    gfpDataNames = { gfpDataFolders.name };
    
    tumour_volumes = zeros(length(gfpDataNames),1);
    
    mCherryDataFolders = dir(mCherryRawFolder);
    mCherryDataFolders = mCherryDataFolders(arrayfun(@(x) x.name(1), mCherryDataFolders) ~= '.');
    mCherryDataNames = { mCherryDataFolders.name };    

    if length(mCherryDataNames) ~= length(gfpDataNames)
        error('Check that each mCherry dataset has a matching GFP dataset')
    end
    
    mCherryCropFolder = strcat(mCherryFolder,'\cropped');
    mkdir(mCherryCropFolder);
    
    gfpCropFolder = strcat(gfpFolder,'\cropped');
    mkdir(gfpCropFolder);

    for n = 1:(length(mCherryDataNames))
        display(strcat('Cropping projections ',int2str(n),' of',' ',int2str(length(mCherryDataNames))))        
        mkdir(strcat(mCherryCropFolder,'\',mCherryDataNames{n}));
        mkdir(strcat(gfpCropFolder,'\',gfpDataNames{n}));
        rectangle = OPT_crop(strcat(mCherryRawFolder,mCherryDataNames{n},'\'),strcat(mCherryCropFolder,'\',mCherryDataNames{n},'\'),2);
        GFP_crop(strcat(gfpRawFolder,gfpDataNames{n},'\'),strcat(gfpCropFolder,'\',gfpDataNames{n},'\'),rectangle);
    end

    mCherryThreshFolder = strcat(mCherryFolder,'\thresholded');
    mkdir(mCherryThreshFolder);
        
    gfpThreshFolder = strcat(gfpFolder,'\thresholded');    
    mkdir(gfpThreshFolder);
    
    for n = 1:(length(gfpDataNames))
        display(strcat('Thresholding projections ',int2str(n),' of',' ',int2str(length(mCherryDataNames))))                
        mkdir(strcat(mCherryThreshFolder,'\',mCherryDataNames{n}));      
        mkdir(strcat(gfpThreshFolder,'\',gfpDataNames{n}));
        threshedfile = strcat(mCherryThreshFolder,'\',mCherryDataNames{n},'.mat');          
        projection_thresh(strcat(mCherryCropFolder,'\',mCherryDataNames{n},'\'),threshedfile);
        threshedfile = strcat(gfpThreshFolder,'\',gfpDataNames{n},'.mat');        
        projection_thresh(strcat(gfpCropFolder,'\',gfpDataNames{n},'\'),threshedfile);
    end

    mCherryReconFolder = strcat(mCherryFolder,'\reconstructions');
    mkdir(mCherryReconFolder);    
    gfpReconFolder = strcat(gfpFolder,'\reconstructions');  
    mkdir(gfpReconFolder);
    
    for n = 1:length(gfpDataNames)
        display(strcat('Reconstructing projections ',int2str(n),' of',' ',int2str(length(mCherryDataNames))))        
        threshedfile = strcat(mCherryThreshFolder,'\',mCherryDataNames{n},'.mat');                 
        TwISTmCherry(threshedfile,strcat(mCherryReconFolder,'\',mCherryDataNames{n},'.mat'));
        threshedfile = strcat(gfpThreshFolder,'\',gfpDataNames{n},'.mat');         
        TwISTgfp(threshedfile,strcat(gfpReconFolder,'\',gfpDataNames{n},'.mat'));
    end

    gfpReconCropFolder = strcat(gfpReconFolder,'\Cropped');  
    mkdir(gfpReconCropFolder);        
    gfpReconThreshFolder = strcat(gfpReconFolder,'\Thresholded');  
    mkdir(gfpReconThreshFolder);    
    
    for n = 1:length(gfpDataNames)
        
        volumefile = strcat(gfpReconFolder,'\',gfpDataNames{n},'.mat');
        croppedfile = strcat(gfpReconCropFolder,'\',gfpDataNames{n},'.mat');
        threshedfile = strcat(gfpReconThreshFolder,'\',gfpDataNames{n},'.mat');
        display(strcat('Cropping tumour volume ',int2str(n),' of',' ',int2str(length(mCherryDataNames))))        
        crop_3D(volumefile,croppedfile);
        display(strcat('Thresholding tumour volume ',int2str(n),' of',' ',int2str(length(mCherryDataNames))))        
        tumour_volumes(n) = volume_thresh(croppedfile,threshedfile)*(0.013^3);
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
        save(vesselfile2 ,'vessel_data','v7.3'); 
        %save vesselfile2 vessel_data -v7.3;
        
        threshedfile = strcat(gfpReconThreshFolder,'\',gfpDataNames{n},'.mat');
        postvascsegfile = strcat(mCherryReconVesselFolder,'\',mCherryDataNames{n},'3.mat');
        postvascsegmentation(vesselfile2,threshedfile,postvascsegfile);
        
    end
    
end