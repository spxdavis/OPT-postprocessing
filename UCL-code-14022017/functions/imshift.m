function shiftedImage = imshift(img,hShift,vShift,rotation)

dark = min(img(:));
hsize = size(img,2);
vsize = size(img,1);

if hShift < 0
    img = img(:,(1-hShift):hsize);
else
    img = img(:,1:(hsize-hShift));
end

if vShift < 0
    img = img((1-vShift):vsize,:);
else
    img = img(1:(vsize-vShift),:);
end
if nargin > 3
    if abs(tan(rotation)) > 1/min(hsize,vsize)
        img = imrotate(img,rotation*180/pi,'bicubic','crop');
        img(img==0)=dark;
    end
end
shiftedImage = img;

end