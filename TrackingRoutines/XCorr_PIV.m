function [pos,vec] = XCorr_PIV(referenz_bild_datei, bild_datei,clust_shift,clust_size,required_correlation)
        %Dies ist ein kleines Werkzeug Ding von Benedikt. Die oberen
        %Parameter steuern das ganze Programm. 
        
        
        %reading images
        b = imread(bild_datei);
        ref_b = imread(referenz_bild_datei);
        db = double(b)+1;
        dref_b = double(ref_b)+1;

        %some declarations
        shift_vec = -clust_shift:1:clust_shift;
        shift_vec_length = length(shift_vec);
        
        [Xmat,Ymat] = meshgrid((clust_size/2 + clust_shift +1):clust_size:(size(ref_b,2)-(clust_size/2 + clust_shift +1)), (clust_size/2 + clust_shift +1):clust_size:(size(ref_b,1)-(clust_size/2 + clust_shift +1)));
        pos = [reshape(Xmat,size(Xmat,1)*size(Xmat,2),1),reshape(Ymat,size(Ymat,1)*size(Ymat,2),1)];
        vec = zeros(size(pos));
        
        %Pixel-level location
        for i = 1:size(pos,1)
            x_akt = (pos(i,2) -clust_size/2);
            y_akt = (pos(i,1) -clust_size/2);

            clust = db(x_akt:x_akt +clust_size -1,y_akt:y_akt +clust_size -1);            

            for s = shift_vec
                for z = shift_vec
                    cmp_clust = dref_b((x_akt+(s:clust_size+s-1)),(y_akt+(z:z+clust_size-1)));
                    look(s +clust_shift +1,z+clust_shift +1) = corr2(clust, cmp_clust);
                end
            end
            loc_max = find_local_max(look(:,:));
            if loc_max(1,3) > required_correlation
                 vec(i,1) =  -(loc_max(1,2)-(clust_shift+1));
                 vec(i,2) =  -(loc_max(1,1)-(clust_shift+1));
            end
        end
        
        %Plot output
        figure; imagesc(ref_b), colormap gray, axis image,hold on;
        quiver(pos(:,1),pos(:,2),vec(:,1),vec(:,2),'b'); title('Displacement field'); hold off;
end