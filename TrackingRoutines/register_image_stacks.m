function  [max_val,max_pos] = register_image_stacks(ref_bild_datei, bild_datei)

    bild_info = imfinfo(ref_bild_datei);
    stacklen = size(bild_info,2);
    
    bild_clust = imread(bild_datei);

    
    for t = 1:stacklen
        rbild_clust = imread(ref_bild_datei,t);
        
        %get size of image and zero pad it a bit
        fft_size = max(size(rbild_clust),size(bild_clust));
                   
        %Note that the conversion to double can be done AFTER
        %subtracting the mean.      
       
        bild_clust = double(bild_clust);
        rbild_clust = double(rbild_clust);
        bild_clust = (bild_clust - mean2(bild_clust)- min(min(bild_clust - mean2(bild_clust))) +1);
        rbild_clust = (rbild_clust -mean2(rbild_clust)- min(min(rbild_clust - mean2(rbild_clust))) +1);

       %bild_clust = double(bild_clust - mean(bild_clust(:)));
       %rbild_clust = double(rbild_clust - mean(rbild_clust(:)));

        F_bild_clust = fft2(rot90(bild_clust,2),fft_size(1),fft_size(2));
        F_rbild_clust = fft2(rbild_clust,fft_size(1),fft_size(2));              

       % F_bild_clust = fft2(rot90(double(bild_clust),2),fft_size(1),fft_size(2));
       % F_rbild_clust = fft2(double(rbild_clust),fft_size(1),fft_size(2));              


        %I calculate the PHASE SHIFT between different images by normalizing
        %with the amplitude of the complex fourier spectrum. This is
        %equivalent to calculating the (normalized) correlation coefficient in real
        %space.      
        cc = real(ifft2(F_rbild_clust.*F_bild_clust./abs(F_rbild_clust.*F_bild_clust)));

        %imshow(cc,[]);
        %waitforbuttonpress;
        max_val(t) = max(cc(:));
        [i,j] = find(cc == max_val(t));
        max_pos(t,1) =(size(cc,1)/2 <= i)*(size(cc,1)-i)+(size(cc,1)/2 > i)*(-i);
        max_pos(t,2) =(size(cc,1)/2 <= j)*(size(cc,2)-j)+(size(cc,2)/2 > j)*(-j);
        pack;
    end   
    
    %find frame which correlates best
    [corr_max,t_max] = max(max_val);
    rbild_clust = imread(ref_bild_datei,t_max);
     
    %make the shifted image
    max_shift = max(abs(max_pos(t_max,:)));
    hilf_bild =uint16(zeros(2*max_shift+size(rbild_clust,1),2*max_shift+size(rbild_clust,2)));
    hilf_bild((max_shift +max_pos(t_max,1))+(1:size(rbild_clust,1)),(max_shift +max_pos(t_max,2))+(1:size(rbild_clust,2))) = rbild_clust;
    best_match_bild = hilf_bild(max_shift +(1:size(rbild_clust,1)),max_shift +(1:size(rbild_clust,2)));
    
    figure; axis equal;
        imagesc(best_match_bild);hold on;
        imagesc(bild_clust); alpha(0.5); hold off;
        title('Merged images');
 
    
    disp(['Reference image nr. ',num2str(t_max),' matches the original image best.']);
    disp(['Shifted images by: ', num2str(max_pos(t_max,2)),' pixels in x, and ',num2str(max_pos(t_max,1)),' in y.']);
    
    channel_nr_position = strfind(ref_bild_datei,'ch');
    if isempty(channel_nr_position)
        save_bild_name =['Saving best reference file as: ',ref_bild_datei(1:end-4),'_ref.tif'];
    else        
        save_bild_name = [ref_bild_datei(channel_nr_position+(0:4)),'_ref.tif'];
    end
    
    disp(['Saving best reference file as: ',save_bild_name]);
    imwrite(best_match_bild, save_bild_name,'tif','Compression','none','Description',bild_info(t_max).ImageDescription);

end
