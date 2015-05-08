function selected_pixels = confirm_exudates(im,exudates,x,y,radius)
    [h,w,~] = size(im);
    [cols, rows] = meshgrid(1:w, 1:h);
    disk_pixels = get_pixels_disk(x,y,radius,rows,cols);
    %sub2ind(size(im),disk_pixels
    disk_pts = [rows(disk_pixels) cols(disk_pixels)];
    num_pts = size(disk_pts,1);
    %im(sub2ind(size(im),disk_pts(:,1),disk_pts(:,2),ones(num_pts,1))) = 0;
    %im(sub2ind(size(im),disk_pts(:,1),disk_pts(:,2),2*ones(num_pts,1))) = 0;
    %im(sub2ind(size(im),disk_pts(:,1),disk_pts(:,2),3*ones(num_pts,1))) = 0;
    %figure,imshow(im);
    for i=1:size(exudates,2)
        curr_exudate = exudates{i};
        [ys, xs] = ind2sub([h,w], curr_exudate);
        rg_ratios = [];
        %get red/green intensities
        for j=1:length(ys)
            curr_pixel = im(ys(j),xs(j),:);
            rg_ratios = [rg_ratios curr_pixel(1)/curr_pixel(2)];
        end
        I_rg_low = prctile(rg_ratios,5,2);
        I_rg_high = prctile(rg_ratios,95,2);
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
            rg_ratio = r_val/g_val;
            if rg_ratio >= I_rg_low && rg_ratio <= I_rg_high
                selected_pixels = vertcat(selected_pixels,neighborhood(j,:));
            end
        end 
    end
end

function disk_pixels = get_pixels_disk(x,y,radius,rows,cols)
    disk_pixels = (rows - y).^2 + (cols - x).^2 <= radius.^2;
end