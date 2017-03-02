function Iout = add_registered(I,I2)

if size(I,1) == size(I2,1)
    delta = size(I,2)-size(I2,2);
    if delta < 0
        I = padarray(I,[0,floor(-delta/2)],0,'pre');
        I = padarray(I,[0,ceil(-delta/2)],0,'post');
    elseif delta > 0
        I2 = padarray(I2,[0,floor(delta/2)],0,'pre');
        I2 = padarray(I2,[0,ceil(delta/2)],0,'post');
    end    
else
    delta = size(I,1)-size(I2,1);
    if delta < 0
        I = padarray(I,[floor(-delta/2),0],0,'pre');
        I = padarray(I,[ceil(-delta/2),0],0,'post');
    elseif delta > 0
        I2 = padarray(I2,[floor(delta/2),0],0,'pre');
        I2 = padarray(I2,[ceil(delta/2),0],0,'post');
    end
end

Iout = I + I2;

end