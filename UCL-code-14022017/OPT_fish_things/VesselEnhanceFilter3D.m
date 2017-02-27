function vessel_data = VesselEnhanceFilter3D(volume_data,ScaleRange,ScaleRatio,vasculature)
%
% Inputs: 
% volume_data: The input image volume
% ScaleRange : The range of sigmas used
% ScaleRatio : Step size between sigmas
% vasculature: Detect bright vessel is false, for dark vessel set to true.
%
% Outputs: 
% vessel_data: The vessel enhanced image
% 
% Example,
%   vessel_data = VesselEnhanceFilter3D(volume_data,[1 5],2,false);

%mex eigenValue3D.c
% Constants vesselness measurement
Alpha = 0.5;
Beta = 0.5;
parameter_C = 500;

% Use single or double for calculations
if(~isa(volume_data,'double')) 
    volume_data = single(volume_data); 
end

sigma = ScaleRange(1):ScaleRatio:ScaleRange(2);
sigma = sort(sigma, 'ascend');

% Hessian filter for all sigmas
for i = 1:length(sigma),
    % Show progress
    disp(['Current Filter Sigma: ' num2str(sigma(i)) ]);

    % Calculate 3D hessian Matrix
    [Dxx, Dyy, Dzz, Dxy, Dxz, Dyz] = HessianMatrix3D(volume_data,sigma(i));

    if(sigma(i)>0)
        % Correct for scaling
        Dxx = (sigma(i)^2)*Dxx; 
        Dxy = (sigma(i)^2)*Dxy;
        Dxz = (sigma(i)^2)*Dxz; 
        Dyy = (sigma(i)^2)*Dyy;
        Dyz = (sigma(i)^2)*Dyz; 
        Dzz = (sigma(i)^2)*Dzz;
    end
    
    % Sam NaN fix
    Dxx(isnan(Dxx))=0;
    Dxy(isnan(Dxy))=0;
    Dxz(isnan(Dxz))=0;
    Dyy(isnan(Dyy))=0;
    Dyz(isnan(Dyz))=0;
    Dzz(isnan(Dzz))=0;
    
    % Calculate eigen values
    if(nargout>2)
        [lambda1,lambda2,lambda3,Vx,Vy,Vz] = eigenValue3D(Dxx,Dxy,Dxz,Dyy,Dyz,Dzz);
    else
        [lambda1,lambda2,lambda3] = eigenValue3D(Dxx,Dxy,Dxz,Dyy,Dyz,Dzz);
    end
    
    % Free memory
    %clear Dxx Dyy  Dzz Dxy  Dxz Dyz;
    Dxx = [];
    Dyy = [];
    Dzz = [];
    Dxy = [];
    Dxz = [];
    Dyz = [];

    % Calculate absolute values of eigen values
    abs_lambda1 = abs(lambda1);
    abs_lambda2 = abs(lambda2);
    abs_lambda3 = abs(lambda3);

    % The Vesselness Features
    Ra = abs_lambda2./abs_lambda3;
    Rb = abs_lambda1./sqrt(abs_lambda2.*abs_lambda3);

    % Second order structureness. S = sqrt(sum(L^2[i])) met i =< D
    S = sqrt(abs_lambda1.^2 + abs_lambda2.^2 + abs_lambda3.^2);

    % Free memory
    %clear LambdaAbs1 LambdaAbs2 LambdaAbs3
    abs_lambda1 = [];
    abs_lambda2 = [];
    abs_lambda3 = [];

    %Compute Vesselness function
    expRa = (1-exp(-(Ra.^2./(2*Alpha^2))));
    expRb =    exp(-(Rb.^2./(2*Beta^2)));
    expS  = (1-exp(-S.^2./(2*parameter_C^2)));
    % Free memory
    %clear S Ra Rb
    S = [];
    Ra = [];
    Rb = [];

    %Compute Vesselness function
    Voxel_data = expRa.* expRb.* expS;
    
    % Free memory
    %clear expRa expRb expRc;
    expRa = [];
    expRb = [];
    expRc = [];
    expS=[];
    
    if(vasculature)
        Voxel_data(lambda2 < 0)=0; 
        Voxel_data(lambda3 < 0)=0;
    else
        Voxel_data(lambda2 > 0)=0; 
        Voxel_data(lambda3 > 0)=0;
    end
        
    % Remove NaN values
    Voxel_data(~isfinite(Voxel_data))=0;
    lambda1=[];
    lambda2=[];
    lambda3=[];
      
    % Add result of this scale to output
    if(i==1)
        vessel_data=Voxel_data;
    else
        % Keep maximum filter response
        vessel_data=max(vessel_data,Voxel_data);
    end
    Voxel_data=[];
end

