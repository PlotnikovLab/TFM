function shift_image(bild_datei,xshift,yshift)
    maxdisp = max([abs(xshift),abs(yshift)]);
    bild = imread(bild_datei);
    
    hilf = zeros(size(bild,1) + 2*maxdisp,size(bild,2) + 2*maxdisp);
    hilf(maxdisp:end-maxdisp-1,maxdisp:end-maxdisp-1) = bild;
    
    bild_neu = uint16(hilf((maxdisp-yshift) + (0:size(bild,1)-1),(maxdisp-xshift) + (0:size(bild,2)-1)));
    imwrite(bild_neu,[bild_datei(1:end-4),'_regist',bild_datei(end-3:end)],'Compression','none');
end