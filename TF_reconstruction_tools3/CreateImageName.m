function [name_of_image] = CreateImageName(file_idx)
    if file_idx < 10
    name_of_image = ['ch488/ch488_0', num2str(file_idx), '.tif'];
else
    name_of_image = ['ch488/ch488_', num2str(file_idx), '.tif'];
end;