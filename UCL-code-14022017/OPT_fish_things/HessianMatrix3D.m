function [Dxx, Dyy, Dzz, Dxy, Dxz, Dyz] = HessianMatrix3D(Volume,Sigma)

% defaults
if nargin < 2, Sigma = 1; end

if(Sigma>0)
    F=imgaussian(Volume,Sigma);
else
    F=Volume;
end

% Create first and second order diferentiations
Dz=gradient3(F,'z');
Dzz=(gradient3(Dz,'z'));
clear Dz;

Dy=gradient3(F,'y');
Dyy=(gradient3(Dy,'y'));
Dyz=(gradient3(Dy,'z'));
clear Dy;

Dx=gradient3(F,'x');
Dxx=(gradient3(Dx,'x'));
Dxy=(gradient3(Dx,'y'));
Dxz=(gradient3(Dx,'z'));
clear Dx;

function Direvative = gradient3(data_volume,option)
% This function does the same as the default matlab "gradient" function
% but with one direction at the time, less cpu and less memory usage.

[m,n,s] = size(data_volume);
Direvative  = zeros(size(data_volume),class(data_volume)); 

switch lower(option)
case 'x'
    % Take forward differences on left and right edges
    Direvative(1,:,:) = (data_volume(2,:,:) - data_volume(1,:,:));
    Direvative(m,:,:) = (data_volume(m,:,:) - data_volume(m-1,:,:));
    % Take centered differences on interior points
    Direvative(2:m-1,:,:) = (data_volume(3:m,:,:)-data_volume(1:m-2,:,:))/2;
case 'y'
    Direvative(:,1,:) = (data_volume(:,2,:) - data_volume(:,1,:));
    Direvative(:,n,:) = (data_volume(:,n,:) - data_volume(:,n-1,:));
    Direvative(:,2:n-1,:) = (data_volume(:,3:n,:)-data_volume(:,1:n-2,:))/2;
case 'z'
    Direvative(:,:,1) = (data_volume(:,:,2) - data_volume(:,:,1));
    Direvative(:,:,s) = (data_volume(:,:,s) - data_volume(:,:,s-1));
    Direvative(:,:,2:s-1) = (data_volume(:,:,3:s)-data_volume(:,:,1:s-2))/2;
otherwise
    disp('Unknown option')
end
        