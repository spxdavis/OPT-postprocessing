function TwISTmCherry(datafile,savename)

    % Function to reconstruct optical projection tomography data, using
    % TwIST. Regularisation parameter tau is approximately optimised for to
    % produce good streak reduction, regardless of reconstruction size and
    % signal to noise.

    % load data
    proj = open(datafile);
    name = fieldnames(proj);
    proj = proj.(name{1});

    % slice size
    [N,Nslices,Ntheta] = size(proj);
    
    tic
    
    % work out angles for reconstruction    
    anglestep = 360/Ntheta;   
    angles = 0:anglestep:(360-anglestep);
    %angles2 = linspace(0,180-180/size(proj,3),size(proj,3)/2);
    
    % prepare reconstruction volume
    recon = zeros(N,N,Nslices);
    
    % prepare TwIST functions: Forward model (hR), inverse model (hRT)   
    %hR = @(x)  hR2(x, angles2);
    hR = @(x)  radon(x, angles);
    hRT = @(x) iradon(x, angles,'linear','Hann',0.6,N);
    
    % denoising function;
    tv_iters = 50; %tumour 25, vasc 10
    Psi = @(x,th)  tvdenoise(x,2/th,tv_iters);

    % set the penalty function, to compute the objective
    Phi = @(x) TVnorm_gpu(x);
    tolA = 0.001;   

    % Create mask for picking regularisation parameter. First create a
    % point object slice to find "modulus transfer function" of hRT(hR()).
        
    slice0 = zeros(N);
    if mod(N,2) == 0 
        slice0(N/2:(N/2+1),N/2:(N/2+1)) = 1;
        [X,Y] = meshgrid(-N/2:(N/2-1),-N/2:(N/2-1));
        R = sqrt(X.^2+Y.^2);
    else
        slice0(ceil(N/2),ceil(N/2)) = 1;
        [X,Y] = meshgrid(-floor(N/2):floor(N/2),-floor(N/2):floor(N/2));
        R = sqrt(X.^2+Y.^2);
    end
        
    PSF = hRT(hR(slice0));
    MTF = abs(fftshift(fft2(PSF)));

    % First define how much of k space is well sampled, then define
    % sampling spokes as those regions at least as bright as the central,
    % well-sampled region. Clean up the mask and reduce its extent using
    % mult, so as to not amplify noise. 
    sampled = 1/tand(anglestep);
    lcutoff = min(MTF(R<sampled));

    ksampled = R(MTF>lcutoff);
    ksampled = sort(ksampled);
    dk = diff(ksampled);
    maxk = min([ksampled(dk>sqrt(2)),max(ksampled)]);
    
    mult = 0.8; 
    mask = MTF<lcutoff.*(R<(mult*maxk));
    
    % make the mask symmetrical
    mask2 = mask & (flipud(mask)) & fliplr(mask) & rot90(mask,2);
    
    % perform full search to find best tau values for a few slices
    tau = zeros(1,4);
    options = optimset('TolFun',0.0001,'MaxFunEvals',20); 
    for i = 1:length(tau)
        index = round(i/(length(tau)+1)*Nslices);
        sino = squeeze(proj(:,index,:));
        tau0 = 0.00005;
        tau1 = 0.02;
        tau(i) = fminbnd(@(x)taupickercost(x,sino,angles,mask2), tau0,tau1,options);
    end
    
    % use the median of these values to make some new ones
    medtau = median(tau);
    taus = [medtau/1.4, medtau, medtau*1.4];
    metric = gpuArray(zeros(1,length(taus)));
    
    % reconstruct for each value of tau and pick favorite of these -
    % quicker than doing a full search, but avoids slight variations in
    % happy tau region.
    slices = gpuArray(zeros(N,N,length(taus)));
    normslices = slices;
 
    for i = 1:size(recon,3)
        
        display(strcat('Reconstructing slice ',int2str(i),' of ',' ',int2str(size(recon,3))))           
        %sino = sinogram(dataFolder,i,2);
        sino = squeeze(proj(:,i,:));
        sinopadded = pad_sinogram_for_iradon(sino);
        y = gpuArray(sinopadded);
        rescale = max(y(:));
        y=y./rescale;
        for ii = 1:length(taus)

        % -- TwIST ---------------------------
        % stop criterium:  the relative change in the objective function 
        % falls below 'ToleranceA'         
         [x_twist,dummy,obj_twist,...
            times_twist,dummy,mse_twist]= ...
                 TwIST_gpu_OPT(y,hR,taus(ii),...
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

        slices(:,:,ii) = x_twist*rescale;
        normslices(:,:,ii) = x_twist./max(x_twist(:));
        spectrum = abs(fftshift(fft2(normslices(:,:,ii))));
        metric(ii) = -(sum(sum(mask2.*spectrum))./sum(sum(spectrum)));
        %figure(ii); imshow(slices(:,:,ii),[])
        end

        %figure(4); plot(taus,squeeze(metric),'r+');
        [~,I] = min(metric);
        recon(:,:,i) = gather(slices(:,:,I));
    end
    toc
    save(savename,'recon','-v7.3');
    %save savename recon -v7.3;
end