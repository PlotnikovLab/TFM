function  register_images(bild1_datei, bild2_datei, maxdisp, do_fft)
    
    if nargin == 2 || isempty(maxdisp)
        maxdisp = 20;
        do_fft = false;
    elseif nargin == 3
        do_fft = false;
    end
    
    bild1 = imread(bild1_datei);
    bild2 = imread(bild2_datei);
    
    rbild_clust = double(bild1);
 
    if do_fft
        bild_clust = bild2;
        fft_size = max(size(rbild_clust),size(bild_clust));
        F_bild_clust = fft2(rot90(double(bild_clust - mean(bild_clust(:))),2),fft_size(1),fft_size(2));
        F_rbild_clust = fft2(double(rbild_clust - mean(rbild_clust(:))),fft_size(1),fft_size(2));

        cc = real(ifft2(F_rbild_clust.*F_bild_clust./abs(F_rbild_clust.*F_bild_clust)));
       
        max_val = max(cc(:));
        [i,j] = find(cc == max_val);
        y1 =(size(cc,1)/2 <= i)*(size(cc,1)-i)+(size(cc,1)/2 > i)*(-i);
        x1 =(size(cc,1)/2 <= j)*(size(cc,2)-j)+(size(cc,2)/2 > j)*(-j);

    else
           bild_clust = double(bild2(maxdisp:size(bild1,1)-maxdisp, maxdisp:size(bild1,2)-maxdisp));
           for s = 1:maxdisp
               for z = 1:maxdisp
                    cmp_clust = rbild_clust((s:(size(bild1,1)-2*maxdisp)+s),(z:z+(size(bild1,2)-2*maxdisp)));
                    look(s,z) = corr2(bild_clust, cmp_clust);
                end
           end
           loc_max = find_local_max(look(:,:));
           x1 =  (loc_max(1,2)-(maxdisp));
           y1 =  (loc_max(1,1)-(maxdisp));
    end
    
    disp(['Shifted image by: ', num2str(x1),',', num2str(y1),' Pixels.']);
    
    hilf = zeros(size(bild1,1) + 2*maxdisp,size(bild1,2) + 2*maxdisp);
    hilf(maxdisp:end-maxdisp-1,maxdisp:end-maxdisp-1) = bild2;
    
    bild2_neu = uint16(hilf((maxdisp-y1) + (0:size(bild1,1)-1),(maxdisp-x1) + (0:size(bild1,2)-1)));
    imwrite(bild2_neu,[bild2_datei(1:end-4),'_regist',bild2_datei(end-3:end)],'Compression','none');
    
    figure; colormap gray;
    subplot(2,2,1)
        imagesc(bild1);
        title('Reference Image');
    subplot(2,2,3)
        imagesc(bild2);
        title('Original Image');
    subplot(2,2,4)
        imagesc(bild2_neu);
        title('Shifted Image');
