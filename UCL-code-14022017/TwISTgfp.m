function TwISTgfp(dataFolder,savename)

    dataFiles = dir(strcat(dataFolder,'*.tif'));
    dataNames = { dataFiles.name };
    sizeCheck = imread(strcat(dataFolder,dataNames{1}));
    sizeCheck = size(sizeCheck);    
    
    anglestep = 360/length(dataNames);
    angles = 0:anglestep:(360-anglestep);

    recon = zeros(sizeCheck(1),sizeCheck(1),sizeCheck(2));
    
    hR = @(x)  radon(x, angles);
    hRT = @(x) iradon(x, angles,'linear','Hann',0.6,sizeCheck(1));
    % denoising function;
    tv_iters =25; %tumour 25, vasc 10
    Psi = @(x,th)  tvdenoise(x,2/th,tv_iters);

    % set the penalty function, to compute the objective
    Phi = @(x) TVnorm_gpu(x);

    % regularization parameters (empirical)
    tau = gpuArray(0.015); %tumour 0.015 vasc 0.004

    tolA = 0.001;    
    
    for i = 1:sizeCheck(2)
        display(strcat('Reconstructing slice ',int2str(i),' of ',' ',int2str(sizeCheck(2))))        
         
        sino = sinogram(dataFolder,i,2);
        sino = pad_sinogram_for_iradon(sino);
        y = gpuArray(sino);
        %y=gpuArray(sino./max(sino(:)));


        % -- TwIST ---------------------------
        % stop criterium:  the relative change in the objective function 
        % falls below 'ToleranceA'         
         [x_twist,dummy,obj_twist,...
            times_twist,dummy,mse_twist]= ...
                 TwIST_gpu_OPT(y,hR,tau,...
                 'Lambda', 1e-4, ...
                 'AT', hRT, ...
                 'Psi', Psi, ...
                 'Phi',Phi, ...
                 'Monotone',1,...
                 'MaxiterA', 10, ...
                 'Initialization',0,...
                 'StopCriterion',1,...
                 'ToleranceA',tolA,...
                 'Verbose', 0);

        recon(:,:,i) = gather(x_twist); 
    end
    %save(savename,'recon');
    save savename recon -v7.3;
end