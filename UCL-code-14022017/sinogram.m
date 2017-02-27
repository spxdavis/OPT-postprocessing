function Sinogram = sinogram(dataFolder,n,rot_axis,timegates,timegate)
    
    if nargin < 4
        timegates = 1;
        timegate = 1;
    end
    
    dataFiles = dir(strcat(dataFolder,'*.tif'));
    dataNames = { dataFiles.name };    
    sizeCheck = imread(strcat(dataFolder,dataNames{1}));
    
    if rot_axis == 1
        numOfSlices = size(sizeCheck,1);
        numOfParallelProjections = size(sizeCheck,2);
        numOfAngularProjections  = length(dataNames)/timegates;     

        Sinogram = zeros(numOfAngularProjections,numOfParallelProjections);

            for i = 1:numOfAngularProjections
                Sinogram(i,:) = double(imread(strcat(dataFolder,dataNames{timegate + (i-1)*timegates}),'PixelRegion',{[n,n],[1,numOfParallelProjections]}));
            end
    else
        numOfSlices = size(sizeCheck,2);
        numOfParallelProjections = size(sizeCheck,1);
        numOfAngularProjections  = length(dataNames)/timegates;
        
        Sinogram = zeros(numOfParallelProjections,numOfAngularProjections);
            for i = 1:numOfAngularProjections
                Sinogram(:,i) = double(imread(strcat(dataFolder,dataNames{timegate + (i-1)*timegates}),'PixelRegion',{[1,numOfParallelProjections],[n,n]}));
            end
    end
end