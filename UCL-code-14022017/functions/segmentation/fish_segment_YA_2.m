function fish_segment_YA_2(dataFolder,saveFolder)

dataFiles = dir(strcat(dataFolder,'*.tif'));
dataNames = { dataFiles.name };


for i = 1:length(dataNames)
    i
    img = double(imread(strcat(dataFolder,dataNames{i})));
    if isGpuAvailable
        img = gpuArray(img);
    end
    [u,sgm] = do_segmetnation(img);    
    u(sgm==0)=min(u(:));
    if isGpuAvailable
        u = gather(u);
    end
    imwrite(uint16(u),strcat(saveFolder,dataNames{i}));
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [u,sgm] = do_segmetnation(fullfilename)
    dataType = class(fullfilename);
    switch dataType
    case {'char'}
        u = double(imread(fullfilename));
        otherwise
        u = fullfilename;
    end
                

                K = 2.5;
                S1 = 10;
                S2 = 30;
                %
                
                nth1 = nonlinear_tophat(u,S1,K)-1;
                nth1(nth1<0)=0;
                nth2 = nonlinear_tophat(u,S2,K)-1;
                nth2(nth2<0)=0;
                
                str1 = zeros(size(u));
                str2 = zeros(size(u));
                if isGpuAvailable
                    str1 = gpuArray(str1);
                    str2 = gpuArray(str2);
                end
                
                %
                sigma1 = fix(S1/2);
                sigma2 = fix(S2/2);
                [uxx1,uxy1,uyy1] = gsderiv(u,sigma1,2);
                [uxx2,uxy2,uyy2] = gsderiv(u,sigma2,2);
                %
                % dirty solution
                str1 = -(uxx1+uyy1);
                str2 = -(uxx2+uyy2);
                %hw = waitbar(0,'Conducting Ridge segmentation, please wait');
                %for x=1:size(u,1)
                %    if ~isempty(hw), waitbar(x/size(u,1),hw); drawnow, end;                            
                %    for y=1:size(u,2)
                %        H = [uxx1(x,y) uxy1(x,y); uxy1(x,y) uyy1(x,y)];
                %        [~,D] = eig(H);
                %        upp = D(1,1); 
                %        uqq = D(2,2);
                %        str1(x,y) = -upp-uqq;
                        %                                                        
                            % case 'Ridge'
                                %if upp < 0 % && uqq~=0
                                %    str1(x,y) = abs(upp);
                                %    %str1(x,y) = uqq - upp;
                                %end                                                                
                        %
                %        H = [uxx2(x,y) uxy2(x,y); uxy2(x,y) uyy2(x,y)];
                %        [~,D] = eig(H); 
                %        upp = D(1,1); 
                %        uqq = D(2,2);
                        %                                
                            % case 'Ridge'
                                %if upp < 0 % && uqq~=0
                                %    str2(x,y) = abs(upp);
                                %    %str2(x,y) = uqq - upp;
                                %end  
                %        str2(x,y) = -upp-uqq;
                %    end                    
                %end
%                if ~isempty(hw), delete(hw), drawnow; end;
                %                             
                z = max(nth1.*map((str1),0,1),nth2.*map((str2),0,1));
                t = 0.003; % threshold 
                z1 = z>t;                                  

                S1 = 800;
                nth = nonlinear_tophat(u,S1,K)-1;
                t = 0.01;
                nth(nth<t)=0;
                
                z2 = nth;
                if isGpuAvailable
                    z2 = gather(z2);
                    z1 = gather(z1);
                end
                z2 = imopen(z2,strel('disk',30));
                z = z2 | z1;
                z = imopen(z,strel('disk',30)); %?
                
                L = bwlabel(z);
                stats = regionprops(L,'Area');
                idx = find([stats.Area] == max([stats.Area]));
                z = ismember(L,idx);
                z = (z~=0);
                sgm = imclose(z,strel('disk',10));
                sgm = imfill(sgm,'holes');
                close all                
end