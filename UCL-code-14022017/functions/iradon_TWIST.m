function slice = iradon_TWIST(sino,angleList,tau)

    [N,Ntheta] = size(sino); 

    hR = @(x)  radon(x, angleList);
    hRT = @(x) iradon(x, angleList,'linear','Hann',0.6,N);
    
    tv_iters =50; %tumour 25, vasc 10
    Psi = @(x,th)  tvdenoise(x,2/th,tv_iters);
    % set the penalty function, to compute the objective
    Phi = @(x) TVnorm_gpu(x);

    % regularization parameters (empirical)
    if nargin < 3
        tau = 0.015; %tumour 0.015 vasc 0.004
    end
    tau = gpuArray(tau);
    tolA = 0.001;       
    y = pad_sinogram_for_iradon(sino);
    rescale = max(y(:));
    y = y./rescale;
%
    [slice,dummy,obj_twist,...
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
             
    slice = slice*rescale;
    
end