function locate_beads_in_stack(bild_dir, win_size,nearest_neighbor, use_filters)
        if mod(win_size,2) ~= 0
            win_size = win_size + 1;
            disp(['Warning: The window size has to be an even number. Now using ', num2str(win_size), ' pix.']);
        end

        if nargin <4 || isempty(use_filters)
            use_filters = 1;
        end
            
        dir_struct = vertcat(dir(fullfile(bild_dir,'*.tif*')));
        [sorted_dir_names,si] = sortrows({dir_struct.name}');

        if isempty(sorted_dir_names)
            disp('Directory is empty. End.');
            return;
        end
        
        stacklen = size(sorted_dir_names,1);
        
        if use_filters     
            filter_mask_size = 18;
            image_crop = max([win_size,(filter_mask_size/2 +1),10]);
            disp(['Background subtraction with a median filter of ',num2str(filter_mask_size),' pixels.']);
        else
            image_crop = max([win_size,10]);
        end
        disp(['Nearest neighbor cutoff: ',num2str(nearest_neighbor)]);
        disp(['Crop image rim with: ',num2str(image_crop),' pixels.']);
        
        bild0 = double(imread(fullfile(bild_dir,sorted_dir_names{1})));        

        imsiz =size(bild0);        
        h1 = figure;   
        warning off all
        thresh = 1;      
        while 1
            max_candidates = find_max_candidates;
 
            [i,j] = find(max_candidates);
            startpos.pos =[j,i];        
            figure(h1); 
            imagesc(bild), colormap gray;title(['Found ',num2str(nnz(max_candidates)),' possible bead locations.']);hold on;
            scatter(startpos.pos(:,1),startpos.pos(:,2),'y.'); hold off;
            
            answ = input(['Local threshold around mean (now ', num2str(thresh),'). Hit enter to resume:']);
          
            if isempty(answ)
                break;
            else
               thresh = double(answ); 
            end  
        end
        warning on
        pack;

        if nnz(max_candidates) ==0
            disp('No beads found. Change parameters!');
            return;
        end  
        
        
       for t = 1:stacklen
           bild0 = double(imread(fullfile(bild_dir,sorted_dir_names{t})));        
             
            max_candidates = find_max_candidates;
            
            [i,j] = find(max_candidates);
            startpos(t).pos =[j,i];            
            startpos(t).pos = round(fit_2Dparabola(bild0, startpos(t).pos, win_size));   
            startpos(t).pos(isnan(startpos(t).pos(:,1))|isnan(startpos(t).pos(:,2)),:) = [];
            
            %imagesc(bild0), colormap gray;hold on
            %scatter(startpos(t).pos(:,1),startpos(t).pos(:,2),'y.'); hold off;
  
            disp(['Located ', num2str(length(startpos(t).pos(:,1))),' beads in frame ', num2str(t),'.']);
       end
    save(['startpos_',sorted_dir_names{1}((strfind(sorted_dir_names{1},'ch'))+(0:4)),'.mat'],'startpos','-mat');
      
    function max_candidates = find_max_candidates
            if use_filters
                bild = medfilt2(bild0,[3 3]);
                bild = bild - medfilt2(bild,[filter_mask_size filter_mask_size]);
            else
                bild = bild0;
            end
            bild = bild - min(min(bild)) +1;
            bild_mean = mean2(bild);
            
            max_candidates(2:imsiz(1)-1,2:imsiz(2)-1) = ...
             ((bild(2:end-1,2:end-1) > bild(3:end,2:end-1))...
            & (bild(2:end-1,2:end-1) > bild(1:end-2,2:end-1))...
            & (bild(2:end-1,2:end-1) > bild(1:end-2,1:end-2))...
            & (bild(2:end-1,2:end-1) > bild(2:end-1,3:end))...
            & (bild(2:end-1,2:end-1) > bild(2:end-1,1:end-2))...
            & (bild(2:end-1,2:end-1) > bild(3:end,3:end))...
            & (bild(2:end-1,2:end-1) > bild(3:end,1:end-2))...
            & (bild(2:end-1,2:end-1) > bild(1:end-2,3:end))...
            & (bild(2:end-1,2:end-1) > thresh.*bild_mean));
            
            max_candidates(1:image_crop,1:imsiz(2)) = 0;
            max_candidates(1:imsiz(1),1:image_crop) = 0;
            max_candidates((imsiz(1)-image_crop):imsiz(1),1:imsiz(2)) = 0;
            max_candidates(1:imsiz(1),(imsiz(2)-image_crop):imsiz(2)) = 0;
            
            [i,j,v] = find(bild.*max_candidates);
            win_location = [];
            win_location(:,1:3)=[i,j,v];
            win_location = sortrows(win_location,3);
            
            for i = size(win_location,1):-1:1
              if  max_candidates(win_location(i,1),win_location(i,2))
                  max_candidates(win_location(i,1)+(-nearest_neighbor:nearest_neighbor),win_location(i,2)+(-nearest_neighbor:nearest_neighbor))=0;
                  max_candidates(win_location(i,1),win_location(i,2)) = 1;
              end
            end
    end        
end