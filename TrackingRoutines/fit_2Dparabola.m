
function pnts = fit_2Dparabola(b, mess_pnts, clust_size)

beadnum = size(mess_pnts,1);
x_mat = repmat(1:clust_size,clust_size,1);

x_sum = sum(sum(x_mat));
x_sq_sum = sum(sum(x_mat.^2));
x_tr_sum = sum(sum(x_mat.^3));


M = [ clust_size^2,     x_sum,  x_sum,  2*x_sq_sum;
    x_sum, x_sq_sum, sum(sum(x_mat.*x_mat')), x_tr_sum +  sum(sum(x_mat.^2.*x_mat'));
    x_sum, sum(sum(x_mat.*x_mat')), x_sq_sum, x_tr_sum +  sum(sum(x_mat.^2.*x_mat'));
    2*x_sq_sum, x_tr_sum + sum(sum(x_mat.^2.*x_mat')), x_tr_sum + sum(sum(x_mat.^2.*x_mat')), sum(sum((x_mat.^2 + x_mat'.^2).^2))];

    skipped = 0;
    for i = 1:beadnum
        if any(mess_pnts(i,:)) == 0
            continue
        end
        x_akt = (mess_pnts(i,2) -clust_size/2);
        y_akt = (mess_pnts(i,1) -clust_size/2);
        
        clust = double(b(x_akt:x_akt +clust_size -1,y_akt:y_akt +clust_size -1));
        clust = clust-mean(mean(clust));
                
        bildvar = std2(clust)^2;

        z = [sum(sum(clust));...
        sum(sum(x_mat.*clust));...
        sum(sum(x_mat'.*clust));...
        (sum(sum(x_mat.^2.*clust + x_mat'.^2.*clust)))]/ bildvar;

        Minv = M/bildvar;
        a = Minv\z;
        y_pos_sub_pix = -a(2)/(a(4)*2);
        x_pos_sub_pix = -a(3)/(a(4)*2);
        
        if y_pos_sub_pix -1 > clust_size   || x_pos_sub_pix -1 > clust_size   || y_pos_sub_pix < 0    || x_pos_sub_pix < 0  
            pnts(i,:) = nan;
            skipped = skipped +1;
        else
            pnts(i,1:2) =  [ (y_akt + y_pos_sub_pix -1), (x_akt + x_pos_sub_pix - 1)];
        end
    end
    disp(['Number of bead candidates where the center could not be determined: ', num2str(skipped)]);
    %{
    n = 1;
    while n <= beadnum
        if all(pnts(n,:)==0)
            pnts(n,:) = [];
            beadnum = beadnum -1;
        else
            n = n +1;
        end
    end
         
    figure;
    subplot(1,2,1)
        hist(mod(pnts(:,1),1),20);
        title('X-Displacement mod 1');
    subplot(1,2,2)
        hist(mod(pnts(:,2),1),20);
        title('Y-Displacement mod 1');
      %} 
end
        