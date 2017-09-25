function [hshift, r] = quickMidindex(sino,maxshift,rotaxis,angleList)
%checksize

    if rotaxis == 2;
        sino = sino';
    end

    numOfAngularProjections = size(sino,1);
    thetastep = 360/numOfAngularProjections;
    
    spectrum_peak2 = gpuArray(zeros([maxshift+1, 1]));    
    
    if nargin < 4
        angleList = thetastep;
    end

    sino = gpuArray(sino);
    
%    for i = 1:maxshift
%        shiftsino = sinoshift(sino,i,maxshift,0,0);
%        slice = iradon(shiftsino',angleList,'linear','Hann');  
%        spectrum_peak(i) = sqrt(sum(abs(slice(:).^2)));
%    end

%    [sorted, I] = sort(spectrum_peak,'descend');
%    first_bid = sorted(1)/sorted(2);

    for i = 1:(maxshift+1)
        shiftsino = sinoshift(sino,i,maxshift+1,0,0);
        slice = iradon(shiftsino',angleList,'linear','Hann');
        %figure
        %imshow(slice,[]);
        spectrum_peak2(i) = sqrt(sum(abs(slice(:).^2)));
    end

    [sorted2, I2] = sort(spectrum_peak2,'descend');
%    second_bid = sorted2(1)/sorted2(2);
    diff = abs(I2-I2(1));
    r = gpuArray(corr(gather(diff(:)),gather(sorted2(:)),'type','Spearman'));

    
    %figure
    %plot(-maxshift:2:maxshift,spectrum_peak2);
    %ylabel('Autocorrelation/a.u.')
    %xlabel('rotation axis shift/pixels')
    %box off    
    %drawnow
    
%    if second_bid > first_bid
%        hshift = maxshift - 2*I2(1) + 2;
%    else
%        hshift = maxshift - 2*I(1) + 1;
%    end
if r < 1
    hshift = maxshift - 2*I2(1) + 2;
else
    hshift = NaN;
end

end