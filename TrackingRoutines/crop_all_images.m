function crop_all_images(phase_datei,ch488_datei,ch561_datei,ch561_ref_datei,ch655_datei,ch655_ref_datei, onefolder)
    phase = imread(phase_datei);
    beads = imread(ch561_ref_datei);
    ch488 = imread(ch488_datei);
    h1 = figure; alpha(0.5);
    imagesc(ch488); hold;imagesc(beads); 
    title('Select region you want to crop.Keep mouse button down while dragging.');
    crop_coords = round(getrect(h1));
    rectangle('Position',crop_coords,'EdgeColor','y');hold off;
    
    
    xcrop_field = [crop_coords(2)-1+(1:crop_coords(4))];
    ycrop_field = [crop_coords(1)-1+(1:crop_coords(3))]; 
    
    if nargin ==6 || logical(onefolder) == false
        mkdir('ch488');
        mkdir('ch561');
        mkdir('ch655');
        mkdir('phase');
        
        ch488_folder = 'ch488/';
        phase_folder = 'phase/';
        ch561_folder = 'ch561/';
        ch655_folder = 'ch655/';
    else
        ch488_folder = '';
        phase_folder = '';
        ch561_folder = '';
        ch655_folder = '';
    end
   
    bild_info = imfinfo(ch488_datei);
    stacklen = size(bild_info,2);
    for t = 1:stacklen
        bild = imread(ch488_datei,t);
        imwrite(bild(xcrop_field,ycrop_field), [ch488_folder,ch488_datei(1:end-4),'_nr',num2str(t),'.tif'],'tif','Compression','none','Description',bild_info(t).ImageDescription);
    end    
    
    bild_info = imfinfo(ch561_datei);
    stacklen = size(bild_info,2);
    for t = 1:stacklen
        bild = imread(ch561_datei,t);
        imwrite(bild(xcrop_field,ycrop_field), [ch561_folder,ch561_datei(1:end-4),'_nr',num2str(t),'.tif'],'tif','Compression','none','Description',bild_info(t).ImageDescription);
    end    
    
    bild_info = imfinfo(ch561_ref_datei);
    stacklen = size(bild_info,2);
    for t = 1:stacklen
        bild = imread(ch561_ref_datei,t);
        imwrite(bild(xcrop_field,ycrop_field), [ch561_folder,ch561_ref_datei(1:end-4),'_nr',num2str(t),'.tif'],'tif','Compression','none','Description',bild_info(t).ImageDescription);
    end
    
    bild_info = imfinfo(ch655_datei);
    stacklen = size(bild_info,2);
    for t = 1:stacklen
        bild = imread(ch655_datei,t);
        imwrite(bild(xcrop_field,ycrop_field), [ch655_folder,ch655_datei(1:end-4),'_nr',num2str(t),'.tif'],'tif','Compression','none','Description',bild_info(t).ImageDescription);
    end    
    
    bild_info = imfinfo(ch655_ref_datei);
    stacklen = size(bild_info,2);
    for t = 1:stacklen
        bild = imread(ch655_ref_datei,t);
        imwrite(bild(xcrop_field,ycrop_field), [ch655_folder,ch655_ref_datei(1:end-4),'_nr',num2str(t),'.tif'],'tif','Compression','none','Description',bild_info(t).ImageDescription);
    end    
    
    bild_info = imfinfo(phase_datei);
    stacklen = size(bild_info,2);
    for t = 1:stacklen
        bild = imread(phase_datei,t);
        imwrite(bild(xcrop_field,ycrop_field), [phase_folder,phase_datei(1:end-4),'_nr',num2str(t),'.tif'],'tif','Compression','none','Description',bild_info(t).ImageDescription);
    end    