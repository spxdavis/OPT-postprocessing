function tau = tau_picker(proj) 

    

    brightness = sum(sum(proj,3),1);
    [~,order] = sort(brightness,'descend');
    %proj = proj(:,order,:);
    proj = proj(:,randperm(size(proj,2)),:);

    taus = zeros(size(proj,2),1);
    
    mult = 0.7;
    
    options = optimset('TolFun',0.001,'MaxFunEvals',20);
    [N,M,Ntheta] = size(proj);
    angles = (0:(Ntheta-1))*360/Ntheta;
    
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
    
    
    for i = 1:length(taus)
        sino = squeeze(cast(proj(:,i,:),'single'));
        sino = sino-min(sino(:));
        
        %vshift = quickMidindex(sino,20,2,angles);
        %vshift
        %sino = imshift(sino,0,vshift,0);
        tic
        tau0 = 0.0001;
        tau1 = 0.02;
        outi = fminbnd(@(x)taupickercost(x,sino,angles,mask2), tau0,tau1,options);
        toc
        tic
        outi = fminsearch(@(x)taupickercost(x,sino,angles,mask2),-3);
        toc
        taus(i) = outi;
        %taus(i) = exp(outi);
        if i > 5
            prev = median(taus(1:(i-1)));
            current = median(taus(1:i));
            dif = abs(current-prev)/current;
            if dif < 0.1
                break
            end
        end                
    end
    figure; plot(taus(1:i));
    tau = median(taus(1:i));

end

    
    