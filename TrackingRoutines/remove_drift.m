function strain = remove_drift(bild_datei, strain)
    bild = imread(bild_datei);
    
    hnew = figure; imagesc(bild); colormap gray; hold on;  
    title('Please select reference area where you believe the strain to be zero!');    
    quiver(strain.pos(:,1),strain.pos(:,2),strain.vec(:,1),strain.vec(:,2),2,'y'); hold off;
    
    area_bound = getline('closed');
    in_ref_area = inpolygon(strain.pos(:,1),strain.pos(:,2),area_bound(:,1),area_bound(:,2));
    strain.vec(:,1) = strain.vec(:,1) - mean(strain.vec(in_ref_area,1));
    strain.vec(:,2) = strain.vec(:,2) - mean(strain.vec(in_ref_area,2));
    
    figure(hnew); imagesc(bild); colormap gray, hold on; 
    quiver(strain.pos(:,1),strain.pos(:,2),strain.vec(:,1),strain.vec(:,2),2,'y'); 
    title('Corrected strain.'); hold off;   
end