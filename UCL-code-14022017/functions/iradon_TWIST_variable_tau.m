function slice = iradon_TWIST_variable_tau(sino, angles)

    mult = 0.7;

    taus = (0.5:1.5:3.5)*10^-4;

    [N,Ntheta] = size(sino); 
    hR = @(x)  radon(x, angles);


    hRT = @(x) iradon(x, angles,'linear','Ram-Lak',N);


    slice0 = zeros(N);
    if mod(N,2) == 0 
        slice0(N/2:(N/2+1),N/2:(N/2+1)) = 1;
        [X,Y] = meshgrid(-N/2:(N/2-1),-N/2:(N/2-1));
    else
        slice0(ceil(N/2),ceil(N/2)) = 1;
        [X,Y] = meshgrid(-floor(N/2):floor(N/2),-floor(N/2):floor(N/2));
    end
        
    slice0 = hRT(hR(slice0));
    spectrum0 = abs(fftshift(fft2(slice0)));

    
    R = sqrt(X.^2+Y.^2);

    anglestep = angles(2)-angles(1);
    sampled = 1/tand(anglestep);
    lcutoff = min(spectrum0(R<sampled));
    mask0 = spectrum0<lcutoff;

    ksampled = R(spectrum0>lcutoff);
    ksampled = sort(ksampled);
    dk = diff(ksampled);
    maxk = min(ksampled(dk>sqrt(2)));
    
    

    mask = spectrum0<lcutoff.*(R<(mult*maxk));

    
    mask2 = mask & (flipud(mask)) & fliplr(mask) & rot90(mask,2);

    slices = gpuArray(zeros(N,N,length(taus)));
    costs = zeros(length(taus),1);
    
    for i = 1:length(taus)
        slices(:,:,i) = iradon_TWIST(sino,angles,taus(i));
        normslice = slices(:,:,i)./max(max(slices(:,:,i)));
        spectrum = abs(fftshift(fft2(normslice)));
        costs(i) = -gather(sum(sum(mask2.*spectrum))/sum(sum(spectrum)));
    end
    
    [~,I] = min(costs);
    slice = slices(:,:,I);
end