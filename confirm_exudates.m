function selected_pixels = confirm_exudates(im,exudates,x,y,radius)
    [h,w,~] = size(im);
    [cols, rows] = meshgrid(1:w, 1:h);
    get_pixels_disk(x,y,radius,rows,cols);
    for i=1:size(exudates,2)
        curr_exudate = exudates{i};
        [ys, xs] = ind2sub([h,w], curr_exudate);
        red_intensities = [];
        green_intensities = [];
        %get red/green intensities
        for j=1:length(ys)
            curr_pixel = im(ys(j),xs(j),:);
            red_intensities = [red_intensities curr_pixel(1)];
            green_intensities = [green_intensities curr_pixel(2)];
        end
        I_green_low = prctile(green_intensities,5,2);
        I_red_low = prctile(red_intensities,5,2);
        I_green_high = prctile(green_intensities,95,2);
        I_red_high = prctile(red_intensities,95,2);
        center_x = floor(mean(xs));
        center_y = floor(mean(ys));
        %get +-100 pixel neighborhood
        lb = max(center_x-100,1);
        rb = min(center_x+100,size(im,2));
        tb = max(center_y-100,1);
        bb = min(center_y+100,size(im,1));
        [X,Y] = meshgrid(lb:rb,tb:bb);
        X = X(:);
        Y = Y(:);
        neighborhood = [];
        points = [Y X];
        for j=1:size(points,1)
            if ~ismember(points(j,:),[ys xs],'rows')
                %unique neighbors
                neighborhood = vertcat(neighborhood,points(j,:));
            end
        end
        %go through each neighbor and check whether it's RG components like
        %within the range
        selected_pixels = [];
        for j=1:size(neighborhood,1)
            pixel_components = im(neighborhood(j,1),neighborhood(j,2),:);
            r_val = pixel_components(1);
            g_val = pixel_components(2);
            if g_val >= I_green_low && g_val <= I_green_high && r_val >= I_red_low && r_val <= I_red_high
                selected_pixels = vertcat(selected_pixels,neighborhood(j,:));
            end
        end 
    end
end

function disk_pixels = get_pixels_disk(x,y,radius,rows,cols)
    disk_pixels = (rows - y).^2 + (cols - x).^2 <= radius.^2;
end