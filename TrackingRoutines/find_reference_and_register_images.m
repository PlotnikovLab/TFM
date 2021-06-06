function find_reference_and_register_images(ref_bild_dir, bild_dir, max_z_drift_per_frame, crop_image)
if nargin < 3
    max_z_drift_per_frame = 5;
end

result_folder = [ref_bild_dir,'_aligned'];

mkdir(result_folder);
ref_dir_struct = vertcat(dir(fullfile(ref_bild_dir,'*.tif*')));
% Remove hidden files from the list (DS_files)
i=0;
for t = 1:size(ref_dir_struct,1)
    if ref_dir_struct(t-i).name(1)=='.'
        ref_dir_struct(t-i)=[];
        i=i+1;
    end
end

dir_struct = vertcat(dir(fullfile(bild_dir,'*.tif*')));
% Remove hidden files from the list (DS_files)
i=0;
for t = 1:size(dir_struct,1)
    if dir_struct(t-i).name(1)=='.'
        dir_struct(t-i)=[];
        i=i+1;
    end
end

[sorted_refdir_names,si] = sortrows({ref_dir_struct.name}');
[sorted_dir_names,si] = sortrows({dir_struct.name}');
    
stacklen = size(sorted_refdir_names,1); 

for t = 1:stacklen
    rbild_clust = double(imread(fullfile(ref_bild_dir,sorted_refdir_names{t})));
    fft_size = size(rbild_clust);
    rbild_clust = (rbild_clust -mean2(rbild_clust)- min(min(rbild_clust - mean2(rbild_clust))) +1);
    refstack(t).bild = fft2(rbild_clust,fft_size(1),fft_size(2));
end

z_drift_span = 1:stacklen;
ref_image=[];

for f= 1:size(sorted_dir_names,1);
    pack('tmp.mat');  % was pack;
    bild_clust = imread(fullfile(bild_dir,sorted_dir_names{f}));
    bild_clust = double(bild_clust);
    
    bild_clust = (bild_clust - mean2(bild_clust)- min(min(bild_clust - mean2(bild_clust))) +1);
    F_bild_clust = fft2(rot90(bild_clust,2),fft_size(1),fft_size(2));
    
    for t = z_drift_span                    
        %I calculate the PHASE SHIFT between different images by normalizing
        %with the amplitude of the complex fourier spectrum. This is
        %equivalent to calculating the (normalized) correlation coefficient in real
        %space.      
        cc = ifft2(refstack(t).bild.*F_bild_clust./abs(refstack(t).bild.*F_bild_clust),'symmetric');

        max_val(t) = max(cc(:));
        [i,j] = find(cc == max_val(t));
        max_pos(t,1) =(size(cc,1)/2 <= i)*(size(cc,1)-i)+(size(cc,1)/2 > i)*(-i);
        max_pos(t,2) =(size(cc,1)/2 <= j)*(size(cc,2)-j)+(size(cc,2)/2 > j)*(-j);
    end   
    
    %find frame which correlates best
    [corr_max,t_max] = max(max_val);
    clear max_val;
    rbild_clust = imread(fullfile(ref_bild_dir,sorted_refdir_names{t_max}));
     
    %calculate the range where we expect the next frame to be in
    z_drift_span = max([(t_max-max_z_drift_per_frame),1]):min((t_max+max_z_drift_per_frame),stacklen);
    
    %make the shifted image
    max_shift = max(abs(max_pos(t_max,:)));
    hilf_bild =uint16(zeros(2*max_shift+size(rbild_clust,1),2*max_shift+size(rbild_clust,2)));
    hilf_bild((max_shift +max_pos(t_max,1))+(1:size(rbild_clust,1)),(max_shift +max_pos(t_max,2))+(1:size(rbild_clust,2))) = rbild_clust;
    best_match_bild = hilf_bild(max_shift +(1:size(rbild_clust,1)),max_shift +(1:size(rbild_clust,2)));
    
     
    save_bild_name = fullfile(result_folder,[sorted_dir_names{f}(1:end-4),'_ref.tif']);

    ref_bild_info = imfinfo(fullfile(ref_bild_dir,sorted_refdir_names{t_max}));
    %imwrite(best_match_bild, save_bild_name,'tif','Compression','none','Description',ref_bild_info.ImageDescription);
    %This was written by Benedikts, but Nikon elements does no have field ImageDescription. So I replaced it with FileMane. 
    
    imwrite(best_match_bild, save_bild_name,'tif','Compression','none','Description',ref_bild_info.Filename);
    
    ref_image = [ref_image; max_pos(t_max,2), max_pos(t_max,1),t_max];
    
    disp([sprintf('\n'),'Frame nr. ', num2str(f),':'])
    disp(['Reference image nr. ',num2str(t_max),' matches the original image best.']);
    disp(['Shifted images by: ', num2str(max_pos(t_max,2)),' pixels in x, and ',num2str(max_pos(t_max,1)),' in y.']);   
    disp(['Saved best reference file as: ',save_bild_name]);
end
figure; plot (1:1:length(ref_image(:,3)), ref_image(:,3), '--rs', 'LineWidth', 2);
set(gca, 'YLim', [min(ref_image(:,3))-1, max(ref_image(:,3))+1]);
set(gca, 'YTick', min(ref_image(:,3))-1:1:max(ref_image(:,3))+1);
figure; plot (1:1:length(ref_image(:,3)), abs(ref_image(:,1)), 1:1:length(ref_image(:,3)), abs(ref_image(:,2)));
end
