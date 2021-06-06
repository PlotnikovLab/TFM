function crop_image_stacks(crop_dir_names, selection_image)
    bild = imread(selection_image);
    h1 = figure; 
    
    while 1
        imagesc(bild); colormap gray; hold on; 
        title('Select region you want to crop.Keep mouse button down while dragging. Hit c to continue.');
        crop_coords = round(getrect(h1));
        
        %-------------------------------------------------------------- 
        %I added this section of the code to extend crop window by 30*2
        % and 40*2pixels in x and y dimensions, respectively. 
%         if crop_coords(1) > 30
%             crop_coords(1) = crop_coords(1)-30;
%         else
%             crop_coords(1) = 1;
%         end;
%         if crop_coords(2) > 40
%             crop_coords(2) = crop_coords(2)-40;
%         else
%             crop_coords(2)=1;
%         end;
        %--------------------------------------------------------------
        rectangle('Position',crop_coords,'EdgeColor','y');hold off;

       %---------------------------------------------------------------
%         xcrop_field = [crop_coords(2)+29+(1:crop_coords(4))];
%         ycrop_field = [crop_coords(1)+39+(1:crop_coords(3))]; 
        
        %Benedikt's code 
        xcrop_field = [crop_coords(2)-1+(1:crop_coords(4))];
        ycrop_field = [crop_coords(1)-1+(1:crop_coords(3))]; 
       %---------------------------------------------------------------
       
        ww = waitforbuttonpress;
        buttonpressed =get(gcf,'CurrentCharacter');
        if strcmpi(buttonpressed,'c')
            break;
        end
    end
        
        
    for d = 1:length(crop_dir_names)
        cropdir = [fullfile('crop2',[crop_dir_names{d},'_crop'])];
        mkdir(cropdir);
        
        dir_struct = vertcat(dir(fullfile(crop_dir_names{d},'*.tif*')));
        [sorted_dir_names,si] = sortrows({dir_struct.name}');
        stacklen = size(sorted_dir_names,1);
        pack;
        
        for t = 1:stacklen
            bild = imread(fullfile(crop_dir_names{d},sorted_dir_names{t}));
            bild_info = imfinfo(fullfile(crop_dir_names{d},sorted_dir_names{t}));
            imwrite(bild(xcrop_field,ycrop_field), fullfile(cropdir,sorted_dir_names{t}),'tif','Compression','none','Description',bild_info.ImageDescription);
        end
    end
