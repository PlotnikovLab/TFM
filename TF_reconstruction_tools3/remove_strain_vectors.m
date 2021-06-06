function strain = remove_strain_vectors(strain, color_flag, mag, median_filt)
accuracy=5;
ScrSize = get(0, 'ScreenSize');    

if ~exist('color_flag'), color_flag='single_color'; end;
if ~exist('mag'), mag=0; end

if (exist('median_filt') & strcmp(median_filt, 'auto'))
    vect_length = sqrt(strain.vec(:,1).^2 + strain.vec(:,2).^2);
    median_length = median(vect_length);
    ind = find(vect_length>10*median_length);   %vector is removed if vector length exceed 10*media length for the given map
    if (length(ind)>0)
        disp([num2str(length(ind)) ' vectors were removed']);
        strain.vec(ind,:) = [];
        strain.pos(ind,:) = [];
    end;
    clear ('vect_length', 'ind');
end
    
graph_win=figure('Position', [1,1, ScrSize(3), ScrSize(4)]);
while 1
    if (strcmp(color_flag, 'multi_color'))
        idx = find(strain.vec(:,1)>=0 & strain.vec(:,2)>=0);
        quiver(strain.pos(idx(:),1),strain.pos(idx(:),2),strain.vec(idx(:),1).*mag,strain.vec(idx(:),2).*mag,0,'r'); hold on;
        
        idx = find(strain.vec(:,1)>=0 & strain.vec(:,2)<0);
        quiver(strain.pos(idx(:),1),strain.pos(idx(:),2),strain.vec(idx(:),1).*mag,strain.vec(idx(:),2).*mag,0,'g');
                    
        idx = find(strain.vec(:,1)<0 & strain.vec(:,2)>=0);
        quiver(strain.pos(idx(:),1),strain.pos(idx(:),2),strain.vec(idx(:),1).*mag,strain.vec(idx(:),2).*mag,0,'m');
        
        idx = find(strain.vec(:,1)<0 & strain.vec(:,2)<0);
        quiver(strain.pos(idx(:),1),strain.pos(idx(:),2),strain.vec(idx(:),1).*mag,strain.vec(idx(:),2).*mag,0,'b'); hold off;
    else
        quiver(strain.pos(:,1),strain.pos(:,2),10*strain.vec(:,1),10*strain.vec(:,2),mag,'r');
    end
        
    title('Select individual vectors to delete. Press enter to end.');
    rm = ginput(1)
    if isempty(rm)
        close(graph_win);
        break;
    else
        fj = find(((strain.pos(:,1)-rm(1)).^2 + (strain.pos(:,2)-rm(2)).^2).^(1/2) < accuracy);
        if ~isempty(fj)
            [max_val, max_idx] = max(sqrt(strain.vec(fj,1).^2+strain.vec(fj,2).^2));    %Removes the largest vector in the neighborhood only
            strain.vec(fj(max_idx),:) = [];
            strain.pos(fj(max_idx),:) = [];
        end
    end
end