function  [pos, vec, enlarged, found, startpos] = Xcorr_Track_Preestim_2Channel_Beads(referenz_bild_datei1, bild_datei1, referenz_bild_datei2, bild_datei2, pre_pos, pre_vec, pos1, pos2, clust_shift, min_clust_size, max_clust_size, xshift_pos2, yshift_pos2)

        c1_global_max_thresh = 0.6;
        c1_signal_clear_thresh = 0.35;
        c1_ref_corr_size = 5;
        
        c2_global_max_thresh = 0.6;
        c2_signal_clear_thresh = 0.35;
        c2_ref_corr_size = 5;
        
        clust_shift = clust_shift +1;
        shift_vec = -clust_shift:1:clust_shift;
        
        if mod(min_clust_size,2) ~= 0
            disp('Please enter even numbers as cluster sizes. Now using next higher even number.');
            min_clust_size = min_clust_size +1;
        end
        if mod(max_clust_size,2) ~= 0
            disp('Please enter even numbers as cluster sizes. Now using next higher even number.');
            max_clust_size = max_clust_size +1;
        end
        
        b1 = imread(bild_datei1);
        ref_b1 = imread(referenz_bild_datei1);
        db1 = double(b1)+1;
        dref_b1 = double(ref_b1)+1;

        b2 = imread(bild_datei2);
        ref_b2 = imread(referenz_bild_datei2);
        db2 = double(b2)+1;
        dref_b2 = double(ref_b2)+1;
        
        clear b1 ref_b1 b2 ref_b2;
        %startpos((startpos(:,1) < max_clust_size/2 + 1 + max(meshvec(:)) + clust_shift) | (startpos(:,2) < max_clust_size/2 + 1 + max(meshvec(:)) +clust_shift),:) = [];
        %startpos((startpos(:,1) > (size(ref_b,2) - max_clust_size/2 - max(meshvec(:)) - clust_shift-1)) | (startpos(:,2) > (size(ref_b,1) - max_clust_size/2 - max(meshvec(:)) -clust_shift-1)),:) = [];
        
        pos1((isnan(pos1(:,1)) | isnan(pos1(:,2))),:) = [];
        pos2((isnan(pos2(:,1)) | isnan(pos2(:,2))),:) = [];
        
        if nargin > 11 && ~isempty(xshift_pos2) && ~isempty(yshift_pos2)
            pos2(:,1) = pos2(:,1) + xshift_pos2;
            pos2(:,2) = pos2(:,2) + yshift_pos2;
        end
        
        pos1((pos1(:,1) < max_clust_size/2 + 7 + clust_shift) | (pos1(:,2) < max_clust_size/2 + 7 +clust_shift),:) = [];
        pos1((pos1(:,1) > (size(dref_b1,2) - max_clust_size/2  - clust_shift-7)) | (pos1(:,2) > (size(dref_b1,1) - max_clust_size/2 -clust_shift-7)),:) = [];

        pos2((pos2(:,1) < max_clust_size/2 + 7 + clust_shift) | (pos2(:,2) < max_clust_size/2 + 7 +clust_shift),:) = [];
        pos2((pos2(:,1) > (size(dref_b2,2) - max_clust_size/2  - clust_shift-7)) | (pos2(:,2) > (size(dref_b2,1) - max_clust_size/2 -clust_shift-7)),:) = [];
        
        pos1 = round(pos1);
        vec1 = zeros(size(pos1));
        pos2 = round(pos2);
        vec2 = zeros(size(pos2));
        
        precond_vec1 = zeros(size(pos1));
        precond_vec2 = zeros(size(pos2));
       
        found1 = zeros(size(pos1,1),1);
        found2 = zeros(size(pos2,1),1);
        
        
        if ~isempty(pre_pos) & ~isempty(pre_vec)
            for ip = 1:size(pos1,1)
                 dist = ((pos1(ip,1) - pre_pos(:,1)).^2 + (pos1(ip,2) - pre_pos(:,2)).^2).^0.5;
                 [distance,nearest_ind] = min(dist(:));
                 precond_vec1(ip,1:2) = pre_vec(nearest_ind,1:2);
            end
            for ip = 1:size(pos2,1)
                 dist = ((pos2(ip,1) - pre_pos(:,1)).^2 + (pos2(ip,2) - pre_pos(:,2)).^2).^0.5;
                 [distance,nearest_ind] = min(dist(:));
                 precond_vec2(ip,1:2) = pre_vec(nearest_ind,1:2);
            end
            clear pre_pos pre_vec dist nearest_ind distance;
        end
        
        for ip = 1:size(pos1,1)
            for clust_size = min_clust_size:2:max_clust_size
                 if clust_size > min_clust_size
                        enlarged1(ip) = 1;
                     else
                        enlarged1(ip) = 0;
                 end
                     
                x_akt = (pos1(ip,2) -clust_size/2);
                y_akt = (pos1(ip,1) -clust_size/2);

                corr_mat1 = make_corr_mat(x_akt, y_akt, precond_vec1(ip,:), dref_b1,db1, shift_vec, clust_shift, clust_size);
                corr_mat2 = make_corr_mat(x_akt, y_akt, precond_vec1(ip,:), dref_b2,db2, shift_vec, clust_shift, clust_size);
                corr_mat = (corr_mat1 + corr_mat2)./2;
                loc_max = find_local_max(corr_mat,1);
                
                if size(loc_max,1) > 0
                    ymin = min(loc_max(1,1)-1,c1_ref_corr_size);
                    ymax = min(2*clust_shift-loc_max(1,1),c1_ref_corr_size);
                    xmin = min(loc_max(1,2)-1,c1_ref_corr_size);
                    xmax = min(2*clust_shift-loc_max(1,2),c1_ref_corr_size);
                  
                    ref_corr = mean(mean(corr_mat(loc_max(1,1)+(-ymin:ymax),loc_max(1,2)+(-xmin:xmax))));
                    
                    if ((size(loc_max,1) > 1) && ((loc_max(2,3)-ref_corr)/(loc_max(1,3) - ref_corr) <= c1_global_max_thresh)) || (size(loc_max,1) == 1 && (loc_max(1,3) - ref_corr) >= c1_signal_clear_thresh)   
                        peak = find_sub_pix_shift_gauss(corr_mat, loc_max(1,1),loc_max(1,2));
                        vec1(ip,1) =  ((peak(2)-(clust_shift+1)) +precond_vec1(ip,1)); 
                        vec1(ip,2) =  ((peak(1)-(clust_shift+1)) +precond_vec1(ip,2)); 
                        found1(ip) = 1;
                        %{
                        ip
                        pos1(ip,1)
                        pos1(ip,2)
                        close all
                        figure
                        colormap default; surf(corr_mat),shading interp ;view(0,-90); hold on; scatter3(peak(2),peak(1), 1,'k*'); scatter3(loc_max(1,2),loc_max(1,1), 1,'w*'); hold off;  set(gca, 'DataAspectRatio', [1,1,1],'Ydir','reverse');
                        figure
                        
                        imagesc(dref_b1), hold, scatter(pos1(ip,1),pos1(ip,2),'y*');
                        
                        figure
                        imagesc(db1), hold, scatter(pos1(ip,1)+vec1(ip,1),pos1(ip,2)+vec1(ip,2),'y*');

                        waitforbuttonpress;
                        %}
                        break;
                    end
                end
            end
        end
        found1 = logical(found1);
        startpos1 = pos1;
        vec1 = vec1(found1,:);
        pos1 = pos1(found1,:);
        disp(['Could not track ', num2str(nnz(~found1)),' beads in Channel 1.']);
        
        for ip = 1:size(pos2,1)
            for clust_size = min_clust_size:2:max_clust_size
                 if clust_size > min_clust_size
                        enlarged2(ip) = 1;
                     else
                        enlarged2(ip) = 0;
                 end
                     
                x_akt = (pos2(ip,2) -clust_size/2);
                y_akt = (pos2(ip,1) -clust_size/2);

                corr_mat1 = make_corr_mat(x_akt, y_akt, precond_vec2(ip,:), dref_b1,db1, shift_vec, clust_shift, clust_size);
                corr_mat2 = make_corr_mat(x_akt, y_akt, precond_vec2(ip,:), dref_b2,db2, shift_vec, clust_shift, clust_size);
                corr_mat = (corr_mat1 + corr_mat2)./2;
                loc_max = find_local_max(corr_mat,1);
                
                if size(loc_max,1) > 0
                    ymin = min(loc_max(1,1)-1,c2_ref_corr_size);
                    ymax = min(2*clust_shift-loc_max(1,1),c2_ref_corr_size);
                    xmin = min(loc_max(1,2)-1,c2_ref_corr_size);
                    xmax = min(2*clust_shift-loc_max(1,2),c2_ref_corr_size);
                  
                    ref_corr = mean(mean(corr_mat(loc_max(1,1)+(-ymin:ymax),loc_max(1,2)+(-xmin:xmax))));
                    
                    if ((size(loc_max,1) > 1) && ((loc_max(2,3)-ref_corr)/(loc_max(1,3) - ref_corr) <= c2_global_max_thresh)) || (size(loc_max,1) == 1 && (loc_max(1,3) - ref_corr) >= c2_signal_clear_thresh)   
                        peak = find_sub_pix_shift_gauss(corr_mat, loc_max(1,1),loc_max(1,2));
                        vec2(ip,1) =  ((peak(2)-(clust_shift+1)) +precond_vec2(ip,1)); 
                        vec2(ip,2) =  ((peak(1)-(clust_shift+1)) +precond_vec2(ip,2)); 
                        found2(ip) = 1;
                        break;
                    end
                end
            end
        end
        found2 = logical(found2);
        startpos2 = pos2;
        vec2 = vec2(found2,:);
        pos2 = pos2(found2,:);
        disp(['Could not track ', num2str(nnz(~found2)),' beads in Channel 2.']);
        
        enlarged = logical(vertcat(enlarged1', enlarged2'));
        found = vertcat(found1, found2);
        startpos = vertcat(startpos1,startpos2);
        pos = vertcat(pos1, pos2);
        vec = vertcat(vec1, vec2);
end

function corr_mat = make_corr_mat(x_akt, y_akt,precond_vec,dref_b,db, shift_vec,clust_shift, clust_size)
            clust = dref_b(x_akt:(x_akt +clust_size -1),y_akt:(y_akt +clust_size -1));
            for s = shift_vec
                for z = shift_vec
                    cmp_clust = db((x_akt + precond_vec(2) +(s:clust_size+s-1)), (y_akt + precond_vec(1) +(z:z+clust_size-1)));                     
                    corr_mat(s +clust_shift +1,z+clust_shift +1) = corr2(clust, cmp_clust);                     
                end
            end                
end

function  peak = find_sub_pix_shift_gauss(corr_mat, x_max,y_max)
                peak(1) = x_max + (log(corr_mat(x_max-1,y_max)) - log(corr_mat(x_max+1,y_max)))/2/(log(corr_mat(x_max-1,y_max)) + log(corr_mat(x_max+1,y_max)) - 2*log(corr_mat(x_max,y_max)));
                peak(2) = y_max + (log(corr_mat(x_max,y_max-1)) - log(corr_mat(x_max,y_max+1)))/2/(log(corr_mat(x_max,y_max-1)) + log(corr_mat(x_max,y_max+1)) - 2*log(corr_mat(x_max,y_max)));
end

