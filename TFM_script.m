find_reference_and_register_images('ch560_ref', 'ch560_04um', 20);
locate_beads_in_stack('ch560_ref_aligned', 32,6);
xcorr_track_stack('ch560_ref_aligned', 'ch560_04um', 'ch655_ref_aligned', 'ch655_04um', 'startpos_ch560.mat', 'startpos_ch655.mat', 18, 20, 26, 1:26);
idx = 1; strain(idx) = remove_strain_vectors(strain(idx), 'single_color', 3);
make_traction_images('ch488', TFM_results, TFM_settings, [0, 600]); %Make images of traction vectors overlap with cell image and heat map of traction magnitude