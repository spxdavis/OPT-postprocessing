function  hR= hR2(y,angles)
hR=[radon(y,angles) radon(fliplr(flipud(y)),angles)];
