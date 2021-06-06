function loc_max = find_local_max(M, noedge)
    %remove simgleton dimensions
    M = squeeze(M);
    
    %Declarations
    Ms1 = size(M,1);
    Ms2 = size(M,2);
    ismax = zeros(Ms1,Ms2);
    [hor_pos,vert_pos] = meshgrid(1:Ms2,1:Ms1);

    %Find maxima
    ismax(2:Ms1-1,2:Ms2-1) = (M(2:end-1,2:end-1)  > M(3:end,2:end-1) & M(2:end-1,2:end-1)  > M(2:end-1,3:end) & M(2:end-1,2:end-1)  > M(1:end-2,2:end-1) & M(2:end-1,2:end-1)  > M(2:end-1,1:end-2));
    
    if nargin > 1 && logical(noedge) == true
        ismax(1,2:Ms2-1) = 0;
        ismax(2:Ms1-1,1) = 0;
    
        ismax(2:Ms1-1,Ms2) = 0;
        ismax(Ms1,2:Ms2-1) = 0;

        ismax(1,1) = 0;
        ismax(Ms1,1) = 0;
        ismax(1,Ms2) = 0;
        ismax(Ms1,Ms2) = 0;
    else
        ismax(1,2:Ms2-1) = (M(1,2:Ms2-1) > M(1,1:Ms2-2) & M(1,2:Ms2-1) > M(1,3:Ms2) & M(1,2:Ms2-1) > M(2,1:Ms2-2));
        ismax(2:Ms1-1,1) = (M(2:Ms1-1,1) > M(1:Ms1-2,1) & M(2:Ms1-1,1) > M(3:Ms1,1) & M(2:Ms1-1,1) > M(1:Ms1-2,2));
    
        ismax(2:Ms1-1,Ms2) = (M(2:Ms1-1,Ms2) > M(1:Ms1-2,Ms2) & M(2:Ms1-1,Ms2) > M(3:Ms1,Ms2) & M(2:Ms1-1,Ms2) > M(1:Ms1-2,Ms2-1));
        ismax(Ms1,2:Ms2-1) = (M(Ms1,2:Ms2-1) > M(Ms1,1:Ms2-2) & M(Ms1,2:Ms2-1) > M(Ms1,3:Ms2) & M(Ms1,2:Ms2-1) > M(Ms1-1,1:Ms2-2));

        ismax(1,1) = (M(1,1) > M(1,2) & M(1,1) > M(2,1) & M(1,1) > M(2,2));
        ismax(Ms1,1) = (M(Ms1,1) > M(Ms1-1,1) & M(Ms1,1) > M(Ms1,2) & M(Ms1,1) > M(Ms1-1,2));
        ismax(1,Ms2) = (M(1,Ms2) > M(1,Ms2-1) & M(1,Ms2) > M(2,Ms2) & M(1,Ms2) > M(2,Ms2-1));
        ismax(Ms1,Ms2) = (M(Ms1,Ms2) > M(Ms1-1,Ms2) & M(Ms1,Ms2) > M(Ms1,Ms2-1) & M(Ms1,Ms2) > M(Ms1-1,Ms2-1));
    end        
    
    %convert to vector
    ismax = logical(ismax);
    max_val = M(ismax);
    max_hor_pos = hor_pos(ismax);
    max_vert_pos = vert_pos(ismax);
    
    new_format = [size(max_val,1)*size(max_val,2),1];
    loc_max(:,1) = reshape(max_vert_pos,new_format);
    loc_max(:,2) = reshape(max_hor_pos,new_format);
    loc_max(:,3) = reshape(max_val,new_format);
    
    %sort result in descending order
    loc_max((size(loc_max,1):-1:1),:) = sortrows(loc_max,3);
end