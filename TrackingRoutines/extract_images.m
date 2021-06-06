function extract_images(bild_datei, ziel)
    mkdir(ziel);
    bild_info = imfinfo(bild_datei);
    
    for t= 1:size(bild_info,2)
         bild = imread(bild_datei,t);
         imwrite(bild, [ziel,'/',bild_datei(1:end-4),'-',sprintf('%03d',t),'.tif'],'tif','Compression','none','Description',bild_info(t).ImageDescription);
    end
