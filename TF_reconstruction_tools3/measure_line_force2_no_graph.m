function [lines,line_vars] = measure_line_force_preestim(bild_datei,stress,step,cutoff, line_vars)

    colorstring ='rgbcmky';
    cutoff = round(cutoff);
    bild = imread(bild_datei);
                
    h = figure; axis equal; colormap gray; imagesc(bild); hold on;     
     
%     figure('Position', [0,0 1274, 971]), colormap gray; imagesc(bild);
%     hold on;
%     color_scale = caxis;
%     caxis([color_scale(1)*2, color_scale(2)/2]);
    
    quiver(stress(1).pos(:,1),stress(1).pos(:,2),stress(1).traction(:,1),stress(1).traction(:,2),1,'r');
    drawnow;
    lines = [];
        
    j = 1;
    x(1:2) =line_vars(j,1,1:2);
    y(1:2) =line_vars(j,2,1:2);
        
    plot(x,y,'-','Color',colorstring(mod(j,6)+1), 'LineWidth', 3);
    
    %% Define size of image window
    window_width = abs(x(1)-x(2));
    window_hight = abs(y(1)-y(2));
    window_x_lim(1) = min(x)- window_width/2;
    window_x_lim(2) = max(x)+window_width/2;
    window_y_lim(1) = min(y)- window_hight/2;
    window_y_lim(2) = max(y)+window_hight/2;
    xlim(window_x_lim);
    ylim(window_y_lim);
    
    
    
    [x,y] = getline;
    if isempty(x)==0
        L = [(x(2)-x(1)),y(2)-y(1)];
        Lnorm = L/norm(L);                             %Store cos and sin of the drawn line               
        plot(x,y,'-','Color',colorstring(mod(j,6)+1), 'LineWidth', 3); %Draw selected line accross the FA
    else
        x(1:2) =line_vars(j,1,1:2);
        y(1:2) =line_vars(j,2,1:2);
        L = [(x(2)-x(1)),y(2)-y(1)];
        Lnorm = L/norm(L);
    end
    [lines(j).u,lines(j).b] = line_vec(L,step,cutoff,stress(1).pos,stress(1).traction);
    lines(j).unorm = (lines(j).u(:,1).^2 + lines(j).u(:,2).^2).^0.5;
    fa_length = length(lines(j).u(:,1));
    lines(j).unormr(1) = mean(lines(j).unorm(1:round(fa_length/3)));
    lines(j).unormr(2) = mean(lines(j).unorm(round(fa_length/3):round(2*fa_length/3)));
    lines(j).unormr(3) = mean(lines(j).unorm(round(2*fa_length/3):end));

    lines(j).br(1) = mean(lines(j).b(round(1:fa_length/3)));
    lines(j).br(2) = mean(lines(j).b(round(fa_length/3:2*fa_length/3)));
    lines(j).br(3) = mean(lines(j).b(round(2*fa_length/3):end));
    line_vars(j,1,:) = x(1:2);
    line_vars(j,2,:) = y(1:2);
                    
    hold off;  
    close;
        
    
    b_sum = sum(lines(j).b);
    u_sum = sum(lines(j).unorm);
    r = [1:length(lines(j).b)]';

    lines(j).b_cms = sum(r.*lines(j).b')/b_sum;
    lines(j).u_cms = sum(r.*lines(j).unorm)/u_sum;

    [bm,lines(j).b_max] = max(lines(j).b(:));
    [bm,lines(j).u_max] = max(lines(j).unorm(:));
    
	    

function [u,b] = line_vec(L,step,cutoff,pos,vec)
    clear u b;
    vector_pos=[]; vector_mag=[];
    for i = 1:round(norm(L)/step)
        act_pos = (i-1)*step*Lnorm + [x(1),y(1)];
        clear fk;
        fk = find(((pos(:,1) - act_pos(1)).^2 + (pos(:,2) - act_pos(2)).^2).^0.5 <= cutoff);    %Search for a vector within 'cutoff distance from act_pos
        if ~isempty(fk)
            u(i,1:2) = [mean(vec(fk,1)), mean(vec(fk,2))];
            b(i) = mean2(bild(round(act_pos(2)+(-cutoff:cutoff)),round(act_pos(1)+(-cutoff:cutoff))));      
        else
            disp(['No data available at node:', num2str(i),'. Setting Vektor to zero here!']);
            u(i,1:2) = 0;
            b(i) = 0;
        end
    end


end
end
