function padded_sinogram = pad_sinogram_for_iradon(sinogram)
            
           [N,n_angles] = size(sinogram);
           szproj = [N N];
            
           zpt = ceil((2*ceil(norm(szproj-floor((szproj-1)/2)-1))+3 - N)/2);
           zpb = floor((2*ceil(norm(szproj-floor((szproj-1)/2)-1))+3 - N)/2);
           %st = abs(zpb - zpt); 
                        
           R = single(padarray(sinogram,[zpt 0], 'replicate' ,'pre'));
           R = single(padarray(R,[zpb 0], 'replicate' ,'post'));                                                                                                                                   
           padded_sinogram = R;                                                
end