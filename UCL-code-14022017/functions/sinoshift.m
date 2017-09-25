function shiftedSino = sinoshift(sino,n,steps,shift,split)
        numOfParallelProjections = size(sino,2);
        numOfAngularProjections = size(sino,1);
        
        if split == 1
            sino1 = sino(shift:(numOfAngularProjections/2+shift-1),n:(numOfParallelProjections+n-steps));
            sino2 = fliplr(sino1);
            shiftedSino = cat(1,sino1,sino2);
        else
            shiftedSino = sino(:,n:(numOfParallelProjections+n-steps));
        end
       
end
