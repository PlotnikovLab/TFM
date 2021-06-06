function make_traction_images(images_dir,TFM_results,TFM_settings, colorscale)
%this program saves the traction data as fig and as tif. The
%colorscale argument is optional and if given, it should be in in
%the format: [lower limit, upper limit] e.g. [0,1000].

%roi = [400, 685; 200, 400];    %Xmin, Xmax; Ymin, Ymax%
%clims = [60, 685];

result_dir = 'TFM_result_images';
if exist('roi')
    result_dir = [result_dir, '_cropped_', num2str(roi(1,1)), '_', num2str(roi(1,2)),...
        '_', num2str(roi(2,1)), '_', num2str(roi(2,2)), '_TC_010'];
end
dir_struct = vertcat(dir(fullfile(images_dir,'*.tif*')));
[sorted_dir_names,si] = sortrows({dir_struct.name}');
stacklen = size(sorted_dir_names,1);
if size(TFM_results,2) ~= stacklen
    disp('The number of images in the given directory is not equal to the number of traction datasets. Aborting!');
    return;
end
mkdir(result_dir);
h1 = figure;
h2 = figure;
%maximize(h1);
%maximize(h2);

pack;
for t = 1:stacklen
    bild = imread(fullfile(images_dir,sorted_dir_names{t}));

    if exist('clims')
        figure(h1); imagesc(bild, clims); hold on; colormap gray; axis equal;
    else
        figure(h1); imagesc(bild); hold on; colormap gray; axis equal;
    end
    
    
    quiver(TFM_results(t).pos(:,1)+TFM_results(t).vec(:,1),TFM_results(t).pos(:,2)+...
        TFM_results(t).vec(:,2),0.005*TFM_results(t).traction(:,1),0.005*TFM_results(t).traction(:,2),0,'r'); %coefficient is 0.005



    if exist('roi')
        xlim(roi(1,1:2)); ylim(roi(2,1:2)); axis off;
    end
    %title('Full stress data with locations corrected for substrate displacement');

    saveas(h1,fullfile(result_dir,['traction_vec_',num2str(t),'.tif']),'tiffn');
    %saveas(h1,fullfile(result_dir,['traction_vec_',num2str(t),'.fig']),'fig');
    saveas(h1,fullfile(result_dir,['traction_vec_',num2str(t),'.pdf']),'pdf');
    hold off;

    [grid_mat,tmat, i_max, j_max] = interp_vec2grid(TFM_results(t).pos+TFM_results(t).vec, TFM_results(t).traction, TFM_settings.meshsize);
    tnorm = (tmat(:,:,1).^2 + tmat(:,:,2).^2).^0.5;

    figure(h2); colormap jet; surf(grid_mat(:,:,1), grid_mat(:,:,2), tnorm),view(0,90), shading interp, axis equal; %colormap default
    set(gca, 'DataAspectRatio', [1,1,10],'YDir','reverse');
    if exist('roi')
        xlim(roi(1,1:2)); ylim(roi(2,1:2)); axis off;
    end
    if nargin >3
        set(gca,'CLim',colorscale);
    end
    colorbar;
    saveas(h2,fullfile(result_dir,['traction_mag_',num2str(t),'.tif']),'tiffn');
    %saveas(h2,fullfile(result_dir,['traction_mag_',num2str(t),'.fig']),'fig');
    saveas(h2,fullfile(result_dir,['traction_mag_',num2str(t),'.pdf']),'pdf');
end
close(h1); close(h2);
pack;