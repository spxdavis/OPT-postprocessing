gfpFolder = 'C:\Users\fogim\Desktop\GFP';
mCherryFolder = 'C:\Users\fogim\Desktop\mCherry';

angles = (0:63)*360/64;
N = 1024;

slice = phantom(N);

sino = radon(slice,angles);
sino = uint8((sino+min(sino(:)))/(max(sino(:))-min(sino(:)))*256);
proj = repmat(sino,[1,1,50]);

for i = 1:64
    imwrite(squeeze(proj(:,i,:)),strcat(gfpFolder,'\',sprintf('%03d', i),'.tif'))
    imwrite(squeeze(proj(:,i,:)),strcat(mCherryFolder,'\',sprintf('%03d', i),'.tif'))
end