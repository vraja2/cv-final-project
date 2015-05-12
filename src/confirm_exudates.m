function new_potential_exudate_map = confirm_exudates(im, img_h, img_w, potential_exudate_map, exudates, x, y, radius)
    new_potential_exudate_map = potential_exudate_map;
    vec_new_potential_exudate_map = reshape(new_potential_exudate_map, [img_h * img_w, 1]);
    
%    figure;
 %   imagesc(new_potential_exudate_map);
 %   colormap gray;
    
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
    
    vec_img = reshape(im, [img_h * img_w, 3]);
    
    for i=1:size(exudates,2)
        curr_exudate = exudates{i};
        [ys, xs] = ind2sub([h,w], curr_exudate);
        
        
     %   rg_ratios = zeros(1,length(ys));
        curr_pixels = double(vec_img(curr_exudate, :));
        rg_ratios = curr_pixels(:,1)./curr_pixels(:,2);
        
        
        %{
        rg_ratios = [];    
        %get red/green intensities
        for j=1:length(ys)
            curr_pixel = double(im(ys(j),xs(j),:));
            rg_ratios(1,j) = curr_pixel(1)/curr_pixel(2);
        end
        %}
        
        I_rg_low = prctile(rg_ratios,5);
        I_rg_high = prctile(rg_ratios,95);
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
        
        %go through each neighbor and check whether it's RG components like
        %within the range
%        selected_pixels = [];

        
        pixel_components = double(vec_img(pixel_inds,:));
        r_val = pixel_components(:,1);
        g_val = pixel_components(:,2);
        rg_ratio = r_val./g_val;
        
        low_flag = (rg_ratio >= I_rg_low);
        high_flag = (rg_ratio <= I_rg_high);
        add_pixel_flag = low_flag & high_flag;
        
        add_pixel_indx = pixel_inds(add_pixel_flag==1);
        
     %   add_pixel_flag = (rg_ratio >= I_rg_low && rg_ratio <= I_rg_high);
        
        i
        
        % [ys, xs] 
        [add_pixel_ys, add_pixel_xs] = ind2sub([img_h, img_w], add_pixel_indx);
        
        num_pts = size(add_pixel_ys, 1);
        
        %{
        for pts = 1:num_pts
            pt_x = add_pixel_xs(pts,:);
            pt_y = add_pixel_ys(pts,:);
            a = 1;
                
            %{
            x_l = pt_x - 1;
            x_r = pt_x + 1;
            
            y_u = pt_y - 1;
            y_d = pt_y + 1;
            
            x_l_flag = ismember(pt_x, xs);
            x_r_flag = ismember(pt_x, xs);
            x_flag = ismember(pt_x, xs);
            
            y_u_flag = ismember(pt_y, ys);
            y_d_flag = ismember(pt_y, ys);
            y_flag = ismember(pt_y, ys);
%}
            dist_x = pdist2(pt_x, xs);
            dist_y = pdist2(pt_y, ys);
            
            dist_x_flag = (dist_x <= 1);
            dist_y_flag = (dist_y <= 1);
            
            dist_x_flag = any(dist_x_flag);
            dist_y_flag = any(dist_y_flag);

            a = 1;
            % if(x_l_flag
            
            if ( dist_x_flag || dist_y_flag)
               
                new_potential_exudate_map(pt_y, pt_x) = 1;
                xs = cat(1, xs, pt_x);
                ys = cat(1, ys, pt_y);
            end
            
        end
        
        
        %{
        add_pixel_ys_u = add_pixel_ys-1;
        add_pixel_ys_d = add_pixel_ys+1;
        add_pixel_xs_l = add_pixel_xs-1;
        add_pixel_ys_r = add_pixel_xs+1;
        %}
        % case 1, Up
     %   up_flag_x = 
     %   up_flag_y = 
         
        % case 2, Down
        
        % case 3, Left
        
        % case 4, Right
        
        %}
        
        
        vec_new_potential_exudate_map(add_pixel_indx) = 1;
        a=1;
        
        
        new_potential_exudate_map = reshape(vec_new_potential_exudate_map, [img_h, img_w]);
    %{
        figure;
        imagesc(new_potential_exudate_map);
        colormap gray;
        a = 1;
      %}  
        
     %   new_potential_exudate_map(neighborhood(j,1),neighborhood(j,2)) = 1;
        
        %{
        for j=1:size(neighborhood,1)
            pixel_components = im(neighborhood(j,1),neighborhood(j,2),:);
            r_val = pixel_components(1);
            g_val = pixel_components(2);
            
            j
            
            rg_ratio = r_val/g_val;
            if rg_ratio >= I_rg_low && rg_ratio <= I_rg_high
                % selected_pixels = vertcat(selected_pixels,neighborhood(j,:));
                new_potential_exudate_map(neighborhood(j,1),neighborhood(j,2)) = 1;
            end
        end 
        %}
        
        
        

    end
    a = 1;
    
    new_potential_exudate_map = reshape(vec_new_potential_exudate_map, [img_h, img_w]);
    
    figure;
    imagesc(new_potential_exudate_map);
    colormap gray;
    
end

function disk_pixels = get_pixels_disk(x,y,radius,rows,cols)
    disk_pixels = (rows - y).^2 + (cols - x).^2 <= radius.^2;
end