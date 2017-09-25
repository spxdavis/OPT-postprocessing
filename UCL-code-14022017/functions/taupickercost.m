function cost = taupickercost(tau,sino,angles,mask2)


mult = 0.8;

%tau = exp(logtau);
%tau = abs(tau);

[N,Ntheta] = size(sino); 
hR = @(x)  radon(x, angles);
hRT = @(x) iradon(x, angles,'linear','Hann',0.6,N);

if nargin < 4
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
end

slice = iradon_TWIST(sino,angles,tau);
normslice = slice./max(slice(:));
% slice = slice.*(slice>0);
% cost = entropy(double(gather(slice)));
%figure; imshow(normslice,[]);
spectrum = abs(fftshift(fft2(normslice)));
cost = -gather(sum(sum(mask2.*spectrum))/sum(sum(spectrum)));

end