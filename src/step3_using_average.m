function new_confirmed_exudate_map = step3_using_average(im, img_h, img_w, confirmed_exudate_map, confirmed_exudate_cell_array, x, y, radius)
    new_confirmed_exudate_map = confirmed_exudate_map;
    vec_new_confirmed_exudate_map = reshape(new_confirmed_exudate_map, [img_h * img_w, 1]);
    %{
    figure;
    imagesc(confirmed_exudate_map);
    colormap gray;
    %}
    [h,w,~] = size(im);
    [cols, rows] = meshgrid(1:w, 1:h);
    disk_pixels = get_pixels_disk(x,y,radius,rows,cols);
    %sub2ind(size(im),disk_pixels
    disk_pts = [rows(disk_pixels) cols(disk_pixels)];
    num_pts = size(disk_pts,1);
    

    vec_img = reshape(im, [img_h * img_w, 3]);
    
    for i=1:size(confirmed_exudate_cell_array,2)
        curr_exudate = confirmed_exudate_cell_array{i};
        [ys, xs] = ind2sub([h,w], curr_exudate);
        
        
        curr_pixels = double(vec_img(curr_exudate, :));
        
                
        r_colors = curr_pixels(:,1);
        g_colors = curr_pixels(:,2);
        
        
        rg_ratios = r_colors./g_colors;
        I_rg_low = prctile(rg_ratios,10);
        I_rg_high = prctile(rg_ratios,90);

        
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
        
        points = [Y X];
        neighborhood = points;

        pixel_inds = sub2ind([img_h, img_w], Y, X);
        
        
        pixel_components = double(vec_img(pixel_inds,:));
        r_val = pixel_components(:,1);
        g_val = pixel_components(:,2);
        b_val = pixel_components(:,3);
        

        
        rg_ratio = r_val./g_val;
        r_flag = (r_val > 140);
        g_flag = (g_val > 130);
        rg_flag = (rg_ratio >= I_rg_low) & (rg_ratio <= I_rg_high);
        b_flag = (b_val < 40);
        
        add_pixel_flag = r_flag & g_flag & rg_flag & b_flag;
        
        add_pixel_indx = pixel_inds(add_pixel_flag==1);
        
        %{
        rg_ratios = curr_pixels(:,1)./curr_pixels(:,2);
        I_rg_low = prctile(rg_ratios,35);
        I_rg_high = prctile(rg_ratios,65);
        
        rg_flag = (r_val >= I_r_low) & (r_val <= I_r_high);
        %}
        
     %   add_pixel_flag = (rg_ratio >= I_rg_low && rg_ratio <= I_rg_high);
        
        i
        
        % [ys, xs] 
        [add_pixel_ys, add_pixel_xs] = ind2sub([img_h, img_w], add_pixel_indx);
        
        num_pts = size(add_pixel_ys, 1);
        

        
        vec_new_confirmed_exudate_map(add_pixel_indx) = 1;
        a=1;
        
        new_confirmed_exudate_map = reshape(vec_new_confirmed_exudate_map, [img_h, img_w]);

        
        

    end
    a = 1;
    
    new_confirmed_exudate_map = reshape(vec_new_confirmed_exudate_map, [img_h, img_w]);
    %{
    figure;
    imagesc(new_confirmed_exudate_map);
    colormap gray;
    %}
end

%{
function new_confirmed_exudate_map = step3_using_average(im, img_h, img_w, confirmed_exudate_map, confirmed_exudate_cell_array, x, y, radius)
    new_confirmed_exudate_map = confirmed_exudate_map;
    vec_new_confirmed_exudate_map = reshape(new_confirmed_exudate_map, [img_h * img_w, 1]);
    
    figure;
    imagesc(confirmed_exudate_map);
    colormap gray;
    
    [h,w,~] = size(im);
    [cols, rows] = meshgrid(1:w, 1:h);
    disk_pixels = get_pixels_disk(x,y,radius,rows,cols);
    %sub2ind(size(im),disk_pixels
    disk_pts = [rows(disk_pixels) cols(disk_pixels)];
    num_pts = size(disk_pts,1);
    

    vec_img = reshape(im, [img_h * img_w, 3]);
    
    for i=1:size(confirmed_exudate_cell_array,2)
        curr_exudate = confirmed_exudate_cell_array{i};
        [ys, xs] = ind2sub([h,w], curr_exudate);
        
        
        curr_pixels = double(vec_img(curr_exudate, :));
        
                
        r_colors = curr_pixels(:,1);
        g_colors = curr_pixels(:,2);
        b_colors = curr_pixels(:,3);
        
        I_r_low = prctile(r_colors,35);
        I_r_high = prctile(r_colors,65);
        
        I_g_low = prctile(g_colors,35);
        I_g_high = prctile(g_colors,65);
        
        I_b_low = prctile(b_colors,35);
        I_b_high = prctile(b_colors,65);


        
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
        
        points = [Y X];
        neighborhood = points;

        pixel_inds = sub2ind([img_h, img_w], Y, X);
        
        
        pixel_components = double(vec_img(pixel_inds,:));
        r_val = pixel_components(:,1);
        g_val = pixel_components(:,2);
        b_val = pixel_components(:,3);
        
        r_flag = (r_val >= I_r_low) & (r_val <= I_r_high);
        g_flag = (g_val >= I_g_low) & (g_val <= I_g_high);
        b_flag = (b_val >= I_b_low) & (b_val <= I_b_high);
        add_pixel_flag = r_flag & g_flag & b_flag;
        add_pixel_indx = pixel_inds(add_pixel_flag==1);
        
        %{
        rg_ratios = curr_pixels(:,1)./curr_pixels(:,2);
        I_rg_low = prctile(rg_ratios,35);
        I_rg_high = prctile(rg_ratios,65);
        
        rg_flag = (r_val >= I_r_low) & (r_val <= I_r_high);
        %}
        
     %   add_pixel_flag = (rg_ratio >= I_rg_low && rg_ratio <= I_rg_high);
        
        i
        
        % [ys, xs] 
        [add_pixel_ys, add_pixel_xs] = ind2sub([img_h, img_w], add_pixel_indx);
        
        num_pts = size(add_pixel_ys, 1);
        

        
        vec_new_confirmed_exudate_map(add_pixel_indx) = 1;
        a=1;
        
        new_confirmed_exudate_map = reshape(vec_new_confirmed_exudate_map, [img_h, img_w]);

        
        

    end
    a = 1;
    
    new_confirmed_exudate_map = reshape(vec_new_confirmed_exudate_map, [img_h, img_w]);
    
    figure;
    imagesc(new_confirmed_exudate_map);
    colormap gray;
    
end
%}













function disk_pixels = get_pixels_disk(x,y,radius,rows,cols)
    disk_pixels = (rows - y).^2 + (cols - x).^2 <= radius.^2;
end