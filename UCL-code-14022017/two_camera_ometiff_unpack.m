function two_camera_ometiff_unpack(dataFolder)
    
    %
    mkdir(strcat(dataFolder,'tiffs'));
    % list of ome-tiffs
    dataFiles = dir(strcat(dataFolder,'*.ome.*'));
    dataNames = { dataFiles.name };

    % vector to say which files have been dealt with
    not_done = ones(length(dataNames),1);

    for i = 1:length(dataNames)

        if not_done(i)
            % if naming convention of ome-tiffs is changed this will need to be
            % changed
            name_stub = dataNames{i}(1:end-16);
            newFolder = strcat(dataFolder,raw,'\',name_stub);
            mkdir(newFolder);
            all_cams = strfind(dataNames,name_stub);
            first = 1;
            for ii = 1:length(all_cams)
                if all_cams{ii}
                    data = bfopen(strcat(dataFolder,dataNames{ii}));
                    Nangles = size(data{1,1},1);
                    for iii = 1:Nangles
                        I = data{1,1}{iii,1};
                        % if not the first cam, add in other image
                        if ~first
                            I2 = imread(strcat(newFolder,'\',sprintf('%05d', iii),'.tif'));
                            I = add_registered(I,I2);
                        end
                        imwrite(I,strcat(newFolder,'\',sprintf('%05d', iii),'.tif'));
                    end
                    first = 0;
                    not_done(ii) = 0;
                end          
            end
        end
    end
end