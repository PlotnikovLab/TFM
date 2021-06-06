function  [ pos, vec, enlarged, found, startpos] = Xcorr_Track_Preestim_Beads(referenz_bild_datei, bild_datei, meshpos, meshvec, startpos, clust_shift, min_clust_size, max_clust_size)

        global_max_thresh = 0.6;
        signal_clear_thresh = 0.35;
        ref_corr_size = 5;
        
        if mod(min_clust_size,2) ~= 0
            disp('Please enter even numbers as cluster sizes. Now using next higher even number.');
            min_clust_size = min_clust_size +1;
        end
        
        b = imread(bild_datei);
        ref_b = imread(referenz_bild_datei);
        db = double(b)+1;
        dref_b = double(ref_b)+1;
        
        %startpos((startpos(:,1) < max_clust_size/2 + 1 + max(meshvec(:)) + clust_shift) | (startpos(:,2) < max_clust_size/2 + 1 + max(meshvec(:)) +clust_shift),:) = [];
        %startpos((startpos(:,1) > (size(ref_b,2) - max_clust_size/2 - max(meshvec(:)) - clust_shift-1)) | (startpos(:,2) > (size(ref_b,1) - max_clust_size/2 - max(meshvec(:)) -clust_shift-1)),:) = [];
        startpos((startpos(:,1) < max_clust_size/2 + 2 + clust_shift) | (startpos(:,2) < max_clust_size/2 + 2 +clust_shift),:) = [];
        startpos((startpos(:,1) > (size(ref_b,2) - max_clust_size/2  - clust_shift-2)) | (startpos(:,2) > (size(ref_b,1) - max_clust_size/2 -clust_shift-2)),:) = [];

        pos = round(startpos);
        vec = zeros(size(pos));
        precond_vec = zeros(size(pos));
        found = zeros(size(pos,1),1);    
        
        clust_shift = clust_shift +1;
        shift_vec = -clust_shift:1:clust_shift;
        
        if ~isempty(meshpos) & ~isempty(meshvec)
            for ip = 1:size(pos,1)
                 dist = ((pos(ip,1) - meshpos(:,1)).^2 + (pos(ip,2) - meshpos(:,2)).^2).^0.5;
                 [distance,nearest_ind] = min(dist(:));
                 precond_vec(ip,1:2) = meshvec(nearest_ind,1:2);
            end
            clear meshpos meshvec dist nearest_ind distance;
        end
        
        enlarged = [];
        
        for ip = 1:size(pos,1)
            look = [];
            slook = [];
            for clust_size = min_clust_size:2:max_clust_size
                     if clust_size > min_clust_size
                        enlarged(ip) = 1;
                     else
                        enlarged(ip) = 0;
                     end
                    
                    x_akt = (pos(ip,2) -clust_size/2);
                    y_akt = (pos(ip,1) -clust_size/2);
     
                    clust = dref_b(x_akt:(x_akt +clust_size -1),y_akt:(y_akt +clust_size -1));
                    for s = shift_vec
                        for z = shift_vec
                            cmp_clust = db((x_akt + precond_vec(ip,2) +(s:clust_size+s-1)), (y_akt + precond_vec(ip,1) +(z:z+clust_size-1)));                     
                            look(s +clust_shift +1,z+clust_shift +1) = corr2(clust, cmp_clust);                     
                        end
                    end                

            
                loc_max = find_local_max(look(:,:),1);
                if size(loc_max,1) > 0
                    ymin = min(loc_max(1,1)-1,ref_corr_size);
                    ymax = min(2*clust_shift-loc_max(1,1),ref_corr_size);
                    xmin = min(loc_max(1,2)-1,ref_corr_size);
                    xmax = min(2*clust_shift-loc_max(1,2),ref_corr_size);
                    
                  
                    ref_corr = mean(mean(look(loc_max(1,1)+(-ymin:ymax),loc_max(1,2)+(-xmin:xmax))));
                    
                    if ((size(loc_max,1) > 1) && ((loc_max(2,3)-ref_corr)/(loc_max(1,3) - ref_corr) <= global_max_thresh)) || (size(loc_max,1) == 1 && (loc_max(1,3) - ref_corr) >= signal_clear_thresh)   
                        peak = find_sub_pix_shift_gauss(look, loc_max(1,1),loc_max(1,2));
                        vec(ip,1) =  ((peak(2)-(clust_shift+1)) +precond_vec(ip,1)); 
                        vec(ip,2) =  ((peak(1)-(clust_shift+1)) +precond_vec(ip,2)); 
                        found(ip) = 1;
                        break;
                    end
                end
               
            end
        end
        
        found = logical(found);
        vec = vec(found,:);
        pos = pos(found,:);
        precond_vec = precond_vec(found,:);
        disp(['Could not track ', num2str(nnz(~found)),' beads.']);
end

function  peak = find_sub_pix_shift_gauss(corr_mat, x_max,y_max)
                peak(1) = x_max + (log(corr_mat(x_max-1,y_max)) - log(corr_mat(x_max+1,y_max)))/2/(log(corr_mat(x_max-1,y_max)) + log(corr_mat(x_max+1,y_max)) - 2*log(corr_mat(x_max,y_max)));
                peak(2) = y_max + (log(corr_mat(x_max,y_max-1)) - log(corr_mat(x_max,y_max+1)))/2/(log(corr_mat(x_max,y_max-1)) + log(corr_mat(x_max,y_max+1)) - 2*log(corr_mat(x_max,y_max)));
end


%{
        sub_pix_accuracy = 10;
                        
                        [hor_pos,vert_pos] = meshgrid(1:clust_size+2,1:clust_size+2);

                        [hor_pos_interp,vert_pos_interp] = meshgrid(1:1/sub_pix_accuracy:clust_size+2,1:1/sub_pix_accuracy:clust_size+2);
                        sub_pix_shift_vec = 1:2*sub_pix_accuracy+1;
                        sub_pix_db = interp2(hor_pos, vert_pos, db(x_akt + precond_vec(ip,2) +(loc_max(1,1)-clust_shift-1) +(-1:clust_size), y_akt + precond_vec(ip,1) +(loc_max(1,2)-clust_shift-1)  +(-1:clust_size)), hor_pos_interp, vert_pos_interp,'linear');
                        for s = sub_pix_shift_vec
                            for z = sub_pix_shift_vec
                                cmp_clust = sub_pix_db((s:sub_pix_accuracy:clust_size*sub_pix_accuracy+s -1), (z:sub_pix_accuracy:z+clust_size*sub_pix_accuracy -1));                     
                                slook(s,z) = corr2(clust, cmp_clust);                     
                            end
                        end                
                        hilf = find_local_max(slook);            
                        peak = hilf(1,1:2)./sub_pix_accuracy - 1;
                        %close all
                        %figure
                        %colormap default; surf(slook(:,:)),shading interp ;view(0,-90); hold on; scatter3(hilf(:,1),hilf(:,2), hilf(:,3)*1.5,'k*'); hold off;  set(gca, 'DataAspectRatio', [1,1,1]);
                        %figure
                        %colormap default; surf(look(:,:,ip)),shading interp; hold on; scatter3(peak(2)+loc_max(1,2),peak(1)+loc_max(1,1), loc_max(1,3)*1.5,'k*'); scatter3(squeeze(loc_max(1,2)),squeeze(loc_max(1,1)), squeeze(loc_max(1,3))*1.5,'w*'); view(0,-90); hold off;  set(gca, 'DataAspectRatio', [1,1,1]);waitforbuttonpress;
                        vec(ip,1) =  ((peak(2)+loc_max(1,2)-(clust_shift+1)) +precond_vec(ip,1)); 
                        vec(ip,2) =  ((peak(1)+loc_max(1,1)-(clust_shift+1)) +precond_vec(ip,2)); 
                        found(ip) = 1;
%}