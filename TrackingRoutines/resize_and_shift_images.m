function resize_and_shift_images
update_image

while 1
    c = waitforbuttonpress;
    if c == 1
        a = get(gcf,'CurrentCharacter');
        switch a
            case 'i'
                move_vert = move_vert +1;
                Ydat = Ydat +1;
            case 'm'   
                move_vert = move_vert -1;
                Ydat = Ydat -1;
            case 'k'   
                move_hor = move_hor +1;
                Xdat = Xdat +1;
            case 'j'   
                move_hor = move_hor -1;
                Xdat = Xdat -1;
            case 'u'   
                enlarge = enlarge +1;
                a = imresize(a,(1+1/max(size(a))));
            case 'k'   
                enlarge = enlarge -1;
            case 'q'
                break;
        end
    else
        break
    end
end

function update_image
h1 = imagesc(a), colormap gray , hold on;
h2 = imagesc(b), colormap gray, hold off;
Xdat = get(h1,'XData');
Ydat = get(h1,'YData')
end
end