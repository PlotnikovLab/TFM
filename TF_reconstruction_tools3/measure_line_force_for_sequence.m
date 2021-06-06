%function Summary = measure_line_force_for_sequence(images_dir, input_data, fa_idx)

%input_data = Summary;
%fa_idx = 8; 
%load('Reg-FTTC_results_14-09-10.mat');
clc;
max_traction_pos = []; 
max_traction_mag = [];
max_brightness_pos = [];
max_brightness_mag = [];
line_pos = [];

line_vars(1,1,:) = [462,391];       % X_coord of start point, X_coord of end point
line_vars(1,2,:) = [104,131];       % Y_coord of start point, Y_coord of end point

if ~exist('input_data')
    index_of_first_image = 1;
    index_of_last_image = 8; 
    
end

color_scale = [100, 500];



images_dir = 'ch488';

if ~exist('images_dir'); images_dir = 'ch488    '; end;

step = 1;
cutoff = 7;

dir_struct = vertcat(dir(fullfile(images_dir,'*.tif*')));
[sorted_dir_names,si] = sortrows({dir_struct.name}');



for idx = index_of_first_image:index_of_last_image
    clear ('lines');
        
    [lines, line_vars] = measure_line_force_preestim(fullfile(images_dir, sorted_dir_names{idx}),...
        TFM_results(idx), step, cutoff, line_vars,1, color_scale);
    max_traction_pos = [max_traction_pos; lines.u_max];
    max_traction_mag = [max_traction_mag; lines.unorm(lines.u_max)];
    max_brightness_pos = [max_brightness_pos; lines.b_max];
    max_brightness_mag = [max_brightness_mag; lines.b(lines.b_max)];
    line_pos = [line_pos; line_vars];
end;
figure;
x_axis = 1:length(max_traction_pos);
plotyy(x_axis, max_traction_mag, x_axis, max_brightness_pos - max_traction_pos);

if (exist('Summary')~=1)
    Summary = struct('max_traction_pos', max_traction_pos, 'max_traction_mag', max_traction_mag,...
        'max_brightness_pos', max_brightness_pos, 'max_brightness_mag', max_brightness_mag,...
        'first_frame', index_of_first_image, 'last_frame', index_of_last_image, 'line_pos', line_pos, 'step', step, 'cutoff', cutoff);
else
    struct_idx = length(Summary)+1;
    Summary(struct_idx).max_traction_pos = max_traction_pos;
    Summary(struct_idx).max_traction_mag = max_traction_mag;
    Summary(struct_idx).max_brightness_pos = max_brightness_pos;
    Summary(struct_idx).max_brightness_mag = max_brightness_mag;
    Summary(struct_idx).first_frame = index_of_first_image;
    Summary(struct_idx).last_frame = index_of_last_image;
    Summary(struct_idx).line_pos = line_pos;
    Summary(struct_idx).step = step;
    Summary(struct_idx).cutoff = cutoff;
end
save('Summary.mat', 'Summary');




    
  
    