function filter_image_stacks(bild_dir)
        new_dir_name = [bild_dir,'_filt'];
        dir_struct = vertcat(dir(fullfile(bild_dir,'*.tif*')));
        [sorted_dir_names,si] = sortrows({dir_struct.name}');

        stacklen = size(sorted_dir_names,1);       
        
        mkdir(new_dir_name);

       for t = 1:stacklen
            bild = imread(fullfile(bild_dir,sorted_dir_names{t}));   
            bild_s = medfilt2(bild,[3 3]);
            bild_bg = medfilt2(bild_s,[23 23]);
            
            bild = uint16(double(bild_s)-double(bild_bg)- min(min(double(bild_s)-double(bild_bg)))+1);
            imwrite(bild, fullfile(new_dir_name,sorted_dir_names{t}),'tif','Compression','none');
       end

            