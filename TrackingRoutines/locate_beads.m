%This program was written by Benedikt Sabass in the group of U. Schwarz at
%the university of Heidelberg. The set of programs is described in the paper 
%"High resolution traction force microscopy based on experimental and
%computational advances" by Sabass et al.

function pos = locate_beads(bild_datei, win_size, filter_mask_size)
        if mod(win_size,2) ~= 0
            win_size = win_size + 1;
            disp(['Warning: The window size has to be an even number. Now using ', num2str(win_size), ' pix.']);
        end

        bild0 = imread(bild_datei);
        bild0 = (bild0 -min(min(bild0)));

        nearest_neighbor = 5;
        plain_illumination_factor = 1.0; 
        image_crop = max([win_size,(filter_mask_size/2 +1),10]);

        disp(['Nearest neighbor cutoff: ',num2str(nearest_neighbor)]);
        disp(['Crop image rim size: ',num2str(image_crop)]);

        h1 = figure;
        mean_kernel = 1/(filter_mask_size*filter_mask_size)*ones(filter_mask_size,filter_mask_size);
        mean_bild0 = conv2(double(bild0), mean_kernel,'same');
        bild = (double(bild0) - plain_illumination_factor*mean_bild0);
        bild = bild - min(min(bild)) +1;
        thresh = mean2(bild);

        warning off all
        imsiz =size(bild);
        max_candidates = zeros(imsiz);

        while 1
            max_candidates(2:imsiz(1)-1,2:imsiz(2)-1) = ...
                 ((bild(2:end-1,2:end-1) > bild(3:end,2:end-1))...
                & (bild(2:end-1,2:end-1) > bild(1:end-2,2:end-1))...
                & (bild(2:end-1,2:end-1) > bild(1:end-2,1:end-2))...
                & (bild(2:end-1,2:end-1) > bild(2:end-1,3:end))...
                & (bild(2:end-1,2:end-1) > bild(2:end-1,1:end-2))...
                & (bild(2:end-1,2:end-1) > bild(3:end,3:end))...
                & (bild(2:end-1,2:end-1) > bild(3:end,1:end-2))...
                & (bild(2:end-1,2:end-1) > bild(1:end-2,3:end))...
                & (bild(2:end-1,2:end-1) - bild(1:end-2,2:end-1)) < 0.3*bild(2:end-1,2:end-1) ... %Do not track edges!
                & (bild(2:end-1,2:end-1) - bild(2:end-1,1:end-2)) < 0.3*bild(2:end-1,2:end-1) ...
                & (bild(2:end-1,2:end-1) - bild(2:end-1,3:end)) < 0.3*bild(2:end-1,2:end-1) ...
                & (bild(2:end-1,2:end-1) - bild(3:end,2:end-1)) < 0.3*bild(2:end-1,2:end-1) ...
                & (bild(2:end-1,2:end-1)>=thresh));                         %set threshold


            max_candidates(1:image_crop,1:imsiz(2)) = 0;
            max_candidates(1:imsiz(1),1:image_crop) = 0;
            max_candidates((imsiz(1)-image_crop):imsiz(1),1:imsiz(2)) = 0;
            max_candidates(1:imsiz(1),(imsiz(2)-image_crop):imsiz(2)) = 0;

            figure(h1);
            imshow(max_candidates); title(['Found ',num2str(nnz(max_candidates)),' possible bead locations.']);
            %hold on;scatter(win_location(:,1),win_location(:,2),'.y'); hold off;

            answ = inputdlg({'Plain illumination',['Thresh. around:',num2str(mean2(bild))]},'Press CANCEL to resume',[1,30],{num2str(plain_illumination_factor),num2str(thresh)});
            if isempty(answ)
                break;
            else
               plain_illumination_factor = str2double(answ(1)); 
               thresh = str2double(answ(2)); 
               win_location = [];
               mean_kernel = 1/(filter_mask_size*filter_mask_size)*ones(filter_mask_size,filter_mask_size);
               mean_bild0 = conv2(double(bild0), mean_kernel,'same');
               bild = (double(bild0) - plain_illumination_factor*mean_bild0);
               bild = bild - min(min(bild)) +1;
            end  
        end
        warning on
        close(h1);
        %clear mean_kernel bild mean_bild0;
        pack;

        figure;
        imagesc(bild);
        
        figure;
        imagesc(bild0);

        if nnz(max_candidates) ==0
            disp('No beads found. Change parameters!');
            return;
        end  

        [i,j,v] = find(bild.*max_candidates);

        win_location(:,1:3)=[i,j,v];
        win_location = sortrows(win_location,3);
       for i = size(win_location,1):-1:1
          if  max_candidates(win_location(i,1),win_location(i,2))
              max_candidates(win_location(i,1)+(-nearest_neighbor:nearest_neighbor),win_location(i,2)+(-nearest_neighbor:nearest_neighbor))=0;
              max_candidates(win_location(i,1),win_location(i,2)) = 1;
          end
       end
       win_location = [];
       [i,j] = find(max_candidates);
       win_location(:,1:2)=[j,i];

       pos = fit_2Dparabola(bild0, win_location, win_size);   
       pos(isnan(pos(:,1))|isnan(pos(:,2)),:) = [];

       figure; colormap('gray'),axis equal;
       imagesc(bild0), hold on;scatter(win_location(:,1),win_location(:,2),'.g');scatter(pos(:,1),pos(:,2),'.y'); 
       title(['Located ',num2str(length(pos)),' beads.']); hold off;     

       pos_varname = genvarname(['startpos_',bild_datei((strfind(bild_datei,'ch'))+(0:4))]);
       eval([pos_varname,'=pos;']); 
       save(['startpos_',bild_datei((strfind(bild_datei,'ch'))+(0:4)),'.mat'],pos_varname,'-mat');
end