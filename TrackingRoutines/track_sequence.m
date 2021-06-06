function strain = track_sequence(referenz_bild_datei, bild_file_template, frames, start_pos, pre_data, clust_shift, min_clust_size, max_clust_size)
    
    strain = [];
    for t = frames
        if ~isempty(pre_data)
            pre_pos = pre_data(t).pos;
            pre_vec = pre_data(t).vec;
        end
        t
        bild_datei = [bild_file_template, sprintf('%02u',t),'.tif'];
        [startpos, strain(t).pos, strain(t).vec, precond_vec] = Xcorr_Track_Preestim_Beads(referenz_bild_datei, bild_datei, pre_pos, pre_vec, start_pos, clust_shift, min_clust_size, max_clust_size);
    end
    