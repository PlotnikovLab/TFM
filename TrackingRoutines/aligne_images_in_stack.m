function align_images_in_stack(bild_dir, folders_to_aligne, output_folder)

if ~exist('output_folder')
    output_folder = 'DriftCorrected_';
    result_folder = [output_folder, bild_dir];
else
    result_folder = output_folder;
end
mkdir(result_folder);
mkdir([result_folder, '/', bild_dir]);

ref_dir_struct = vertcat(dir(fullfile(bild_dir,'*.tif*')));
dir_struct = ref_dir_struct(1);
[sorted_refdir_names,si] = sortrows({ref_dir_struct.name}');
[sorted_dir_names,si] = sortrows({dir_struct.name}');

if exist('folders_to_aligne')
    for idx=1:length(folders_to_aligne)
        mkdir([result_folder, '/', folders_to_aligne{idx}]);
        files_to_aligne(:,idx) = vertcat(dir(fullfile(folders_to_aligne{idx},'*.tif*')));
        [sorted_files_to_aligne(:,idx), si] = sortrows({files_to_aligne(:,idx).name}');
    end
end

stacklen = size(sorted_refdir_names,1);

for t = 2:stacklen
    rbild_clust = double(imread(fullfile(bild_dir,sorted_refdir_names{t})));        
    fft_size = size(rbild_clust);
    rbild_clust = (rbild_clust -mean2(rbild_clust)- min(min(rbild_clust - mean2(rbild_clust))) +1);
    refstack(t).bild = fft2(rbild_clust,fft_size(1),fft_size(2));
end

ref_image=[];

bild_clust = imread(fullfile(bild_dir,sorted_dir_names{1}));

save_bild_name = fullfile(result_folder,bild_dir, sorted_refdir_names{1});
ref_bild_info = imfinfo(fullfile(bild_dir,sorted_refdir_names{1}));
imwrite(bild_clust, save_bild_name,'tif','Compression','none','Description',ref_bild_info.ImageDescription);

bild_clust = double(bild_clust);
bild_clust = (bild_clust - mean2(bild_clust)- min(min(bild_clust - mean2(bild_clust))) +1);
F_bild_clust = fft2(rot90(bild_clust,2),fft_size(1),fft_size(2));



for t= 2:size(sorted_refdir_names,1);
    %I calculate the PHASE SHIFT between different images by normalizing
    %with the amplitude of the complex fourier spectrum. This is
    %equivalent to calculating the (normalized) correlation coefficient in real
    %space.      
    cc = ifft2(refstack(t).bild.*F_bild_clust./abs(refstack(t).bild.*F_bild_clust),'symmetric');

    max_val(t) = max(cc(:));
    [i,j] = find(cc == max_val(t));
    max_pos(t,1) =(size(cc,1)/2 <= i)*(size(cc,1)-i)+(size(cc,1)/2 > i)*(-i);
    max_pos(t,2) =(size(cc,1)/2 <= j)*(size(cc,2)-j)+(size(cc,2)/2 > j)*(-j);
       
    
    %find frame which correlates best
    [corr_max,t_max] = max(max_val);
    clear max_val;
    rbild_clust = imread(fullfile(bild_dir,sorted_refdir_names{t_max}));
     
    %make the shifted image
    max_shift = max(abs(max_pos(t_max,:)));
    hilf_bild =uint16(zeros(2*max_shift+size(rbild_clust,1),2*max_shift+size(rbild_clust,2)));
    hilf_bild((max_shift +max_pos(t_max,1))+(1:size(rbild_clust,1)),(max_shift +max_pos(t_max,2))+(1:size(rbild_clust,2))) = rbild_clust;
    best_match_bild = hilf_bild(max_shift +(1:size(rbild_clust,1)),max_shift +(1:size(rbild_clust,2)));
    
    for i=1:length(folders_to_aligne)
        image_to_aligne = imread(fullfile(folders_to_aligne{i}, sorted_files_to_aligne{t_max,i}));
        hilf_image_to_aligne = uint16(zeros(2*max_shift+size(image_to_aligne,1),2*max_shift+size(image_to_aligne,2)));
        hilf_image_to_aligne((max_shift +max_pos(t_max,1))+(1:size(image_to_aligne,1)),(max_shift +max_pos(t_max,2))+(1:size(image_to_aligne,2))) = image_to_aligne;
        aligned_image = hilf_image_to_aligne(max_shift +(1:size(image_to_aligne,1)),max_shift +(1:size(image_to_aligne,2)));
        save_aligned_image_name = fullfile(result_folder, folders_to_aligne{i}, sorted_files_to_aligne{t,i});
        imwrite(aligned_image, save_aligned_image_name,'tif','Compression','none');
    end
    

    save_bild_name = fullfile(result_folder,bild_dir, sorted_refdir_names{t});
    ref_bild_info = imfinfo(fullfile(bild_dir,sorted_refdir_names{t_max}));
    imwrite(best_match_bild, save_bild_name,'tif','Compression','none','Description',ref_bild_info.ImageDescription);
    
    ref_image = [ref_image; max_pos(t_max,2), max_pos(t_max,1),t_max];
    disp([sprintf('\n'),'Frame nr. ', num2str(t),':'])
    disp(['Reference image nr. ',num2str(t_max),' matches the original image best.']);
    disp(['Shifted images by: ', num2str(max_pos(t_max,2)),' pixels in x, and ',num2str(max_pos(t_max,1)),' in y.']);   
    disp(['Saved best reference file as: ',save_bild_name]);
end

t_max = 1; t=1;
for i=1:length(folders_to_aligne)
    image_to_save = imread(fullfile(folders_to_aligne{i}, sorted_files_to_aligne{t_max,i}));
    save_image_name = fullfile(result_folder, folders_to_aligne{i}, sorted_files_to_aligne{t,i});
    imwrite(image_to_save, save_image_name,'tif','Compression','none');
end
    
%figure; plot (1:1:length(ref_image(:,3)), ref_image(:,3), '--rs', 'LineWidth', 2);
% set(gca, 'YLim', [min(ref_image(:,3))-1, max(ref_image(:,3))+1]);
% set(gca, 'YTick', min(ref_image(:,3))-1:1:max(ref_image(:,3))+1);
figure; plot (1:1:length(ref_image(:,3)), abs(ref_image(:,1)), 1:1:length(ref_image(:,3)), abs(ref_image(:,2)));
end
