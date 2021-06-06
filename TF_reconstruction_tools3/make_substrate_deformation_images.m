function make_substrate_deformation_images(images_dir,strain)
%this program saves the traction data as fig and as tif. The
%colorscale argument is optional and if given, it should be in in
%the format: [lower limit, upper limit] e.g. [0,1000].

roi =  [220, 355; 165, 315];    %Xmin, Xmax; Ymin, Ymax

result_dir = 'Substrate_deformation';
if exist('roi')
    result_dir = [result_dir, '_cropped_', num2str(roi(1,1)), '_', num2str(roi(1,2)),...
        '_', num2str(roi(2,1)), '_', num2str(roi(2,2))];
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

pack;
for t = 1:stacklen
    bild = imread(fullfile(images_dir,sorted_dir_names{t}));

    figure(h1); imagesc(bild); hold on; colormap gray; axis equal;
    quiver(strain(t).pos(:,1), strain(t).pos(:,2), 2*strain(t).vec(:,1), 2*strain(t).vec(:,2),0,'r');

    if exist('roi')
        xlim(roi(1,1:2)); ylim(roi(2,1:2)); axis off;
    end
    saveas(h1,fullfile(result_dir,['traction_vec_',num2str(t),'.tif']),'tiffn');
    saveas(h1,fullfile(result_dir,['traction_vec_',num2str(t),'.fig']),'fig');
    saveas(h1,fullfile(result_dir,['traction_vec_',num2str(t),'.pdf']),'pdf');
    hold off; close(h1);
    saveas(h2,fullfile(result_dir,['traction_mag_',num2str(t),'.pdf']),'pdf');
end