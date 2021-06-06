function xcorr_track_stack(ref_ch1_dir_name,ch1_dir_name,ref_ch2_dir_name,ch2_dir_name,ch1_startpos_file,ch2_startpos_file, move_dist, min_win, max_win, frames)

    dir_struct = vertcat(dir(fullfile(ch1_dir_name,'*.tif*')));
    dir_struct = remove_hidden_files(dir_struct);
    [ch1_dat_name,si] = sortrows({dir_struct.name}');
    
    dir_struct = vertcat(dir(fullfile(ref_ch1_dir_name,'*.tif*')));
    dir_struct = remove_hidden_files(dir_struct);
    [ref_ch1_dat_name,si] = sortrows({dir_struct.name}');
    
    dir_struct = vertcat(dir(fullfile(ch2_dir_name,'*.tif*')));
    dir_struct = remove_hidden_files(dir_struct);
    [ch2_dat_name,si] = sortrows({dir_struct.name}');
    
    dir_struct = vertcat(dir(fullfile(ref_ch2_dir_name,'*.tif*')));
    dir_struct = remove_hidden_files(dir_struct);
    [ref_ch2_dat_name,si] = sortrows({dir_struct.name}');
    
    ch1_dat = load(ch1_startpos_file);
    ch2_dat = load(ch2_startpos_file);
    
    if length(ch2_dat_name)~= length(ch1_dat_name) || length(ch1_dat_name) ~= size(ch1_dat.startpos,2) ||  size(ch2_dat.startpos,2)~= size(ch1_dat.startpos,2)
        disp('Data inconsistent. Quiting');
        return;
    end
    
    for d = frames            %specify what frames will be processed as x:y
        disp(['Frame ' num2str(d) ' out of ' num2str(frames(end))]);
        [strain(d).pos, strain(d).vec, enlarged, found, startpos] = Xcorr_Track_Preestim_2Channel_Beads(fullfile(ref_ch1_dir_name,ref_ch1_dat_name{d}),fullfile(ch1_dir_name,ch1_dat_name{d}), fullfile(ref_ch2_dir_name,ref_ch2_dat_name{d}), fullfile(ch2_dir_name,ch2_dat_name{d}), [], [], ch1_dat.startpos(d).pos, ch2_dat.startpos(d).pos, move_dist, min_win, max_win);
        save('strain.mat','strain');
    end
end

    
    function dir_struct_no_hidden_files = remove_hidden_files(dir_struct_input)
        i=0;
        for t = 1:size(dir_struct_input,1)
            if dir_struct_input(t-i).name(1)=='.'
                dir_struct_input(t-i)=[];
            i=i+1;
            end
        end
    dir_struct_no_hidden_files = dir_struct_input;    
    end

