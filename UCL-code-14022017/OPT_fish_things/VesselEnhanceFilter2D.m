function vessel_data = VesselEnhanceFilter2D(img,scale_range,scale_ratio,vasculature)
%
% inputs: 
% img : The input image
% ScaleRange : The range of sigmas used
% ScaleRatio : Step size between sigmas
% vasculature: Detect bright vessel is false, for dark vessel set to true.
%
% outputs: 
% vessel_data: The vessel enhanced image
%
% Example,
%   vessel_data = VesselEnhanceFilter2D(double(img),[1 10],false);

cd('./support');
sigma = scale_range(1):scale_ratio:scale_range(2);
sigma = sort(sigma, 'ascend');


% Make matrices to store all filterd images
ALLfiltered=zeros([size(img) length(sigma)]);
ALLangles=zeros([size(img) length(sigma)]);

% Frangi filter for all sigmas
for i = 1:length(sigma),
    % Show progress
    disp(['Current Filter Sigma: ' num2str(sigma(i)) ]);
    
    % Make 2D hessian
    [Dxx,Dxy,Dyy] = HessianMatrix2D(img,sigma(i));
    
    % Correct for scale
    Dxx = (sigma(i)^2)*Dxx;
    Dxy = (sigma(i)^2)*Dxy;
    Dyy = (sigma(i)^2)*Dyy;
   
    % Calculate (abs sorted) eigenvalues and vectors
    [Lambda2,Lambda1,Ix,Iy] = eigenValue2D(Dxx,Dxy,Dyy);

    % Compute the direction of the minor eigenvector
    angles = atan2(Ix,Iy);

    % Compute some similarity measures
    Lambda1(Lambda1==0) = eps;
    Rb = (Lambda2./Lambda1).^2;
    S2 = Lambda1.^2 + Lambda2.^2;
   
    % Compute the output image
    Ifiltered = exp(-Rb/(2*0.5^2)) .*(ones(size(img))-exp(-S2/(2*15^2)));
    
    if(vasculature)
        Ifiltered(Lambda1<0)=0;
    else
        Ifiltered(Lambda1>0)=0;
    end
    % store the results in 3D matrices
    ALLfiltered(:,:,i) = Ifiltered;
    ALLangles(:,:,i) = angles;
end

% Return for every pixel the value of the scale(sigma) with the maximum 
% output pixel value
if length(sigma) > 1,
    [vessel_data,whatScale] = max(ALLfiltered,[],3);
    vessel_data = reshape(vessel_data,size(img));
else
    vessel_data = reshape(ALLfiltered,size(img));
end
