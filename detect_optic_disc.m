function exudate_cell_array = detect_optic_disc(img)
    [h,w,d] = size(img);
    [img_h, img_w, img_d] = size(img);
    
    figure;
    imagesc(img);
    hold on;
    
    
    

    % get rid of the blue hue around the ring eye balls
    [eye_ball_center_x, eye_ball_center_y, eye_ball_radius, inner_eye_ball_radius, vec_ring_pixels] = find_eye_ball_center(img_w, img_h, img);

 %   eye_ball_ring_width = 60;
    
    plot(eye_ball_center_x, eye_ball_center_y, 'g.');
    plot_circle(eye_ball_center_x, eye_ball_center_y, eye_ball_radius);

   %   inner_eye_ball_radius = eye_ball_radius - eye_ball_ring_width;
    plot_circle(eye_ball_center_x, eye_ball_center_y, inner_eye_ball_radius);
    
    [ring_ys, ring_xs] = ind2sub([img_h, img_w], vec_ring_pixels);
    plot( ring_xs, ring_ys, 'g.');
    
    
    
    
    vec_img = reshape(img, [h*w,d]);
    vec_img(vec_ring_pixels, :) = 0;
    img = reshape(vec_img, [h,w,d]);
    
    %{
    figure;
    imagesc(img);
    %}
    
    
    total_pixel_count = h*w;
    top_green_percentage = round(total_pixel_count * 5 / 1000);
    
    vec_img = reshape(img, [h*w,d]);

    % sort based on one column
    % http://www.mathworks.com/matlabcentral/newsreader/view_thread/248731
    %{
    vec_img = [ 1,2,3;
                2,3,4;
                7,5,6;
                4,2,3;];
    %}
    
    
    [g_value, index] = sort(vec_img(:,2), 'descend');    

    % from high to low
    vec_img_g_sorted = vec_img(index,:);

    top_5_precent_g_pixels_index = index(1:top_green_percentage, :);
    top_5_percent_g_pixels = vec_img_g_sorted(1:top_green_percentage, :);

    temp = uint8(0);
    vec_bw_img(h*w,:) = temp;
    vec_bw_img(top_5_precent_g_pixels_index, :) = 1;
    vec_bw_img = reshape(vec_bw_img, [h,w]);
    figure;
    imagesc(vec_bw_img);
    hold on;
    
    CC = bwconncomp(vec_bw_img);
    
    CC_img(h*w,:) = temp;
    
    pixel_list = CC.PixelIdxList;
    [sorted_length, sorted_ind] = sort_cell_list(pixel_list);
    
    % getting the largest connected region
    optic_disc_pixel_list_ind = sorted_ind(1,1);
    optic_disc_pixel_list = pixel_list{1,optic_disc_pixel_list_ind};
    
    % computing optic_disc_center points
    [center_x, center_y, radius, vec_circle_pixels] = compute_bounding_disc(h,w,optic_disc_pixel_list);
    
    %{
    [optic_disc_ys, optic_disc_xs] = ind2sub([h,w], optic_disc_pixel_list);
    
    optic_disc_center_x = mean(optic_disc_ys);
    optic_disc_center_y = mean(optic_disc_xs);
    
    compute_bounding_disc(h,w, optic_disc_pixel_list)
    %}
    
   
    % plotting the largested connected region only
    CC_img(optic_disc_pixel_list,1) = 1;
    CC_img = reshape(CC_img, [h,w]);
    figure;
    imagesc(CC_img);
 
 
    
   % length_list = cellfun('length', pixel_list);
    
   
  
   % step2
   [hor_img_median, vert_img_median] = compute_50_pixel_median_filter(img_h,img_w,img);
   subtracted_img = subtract_min_median(hor_img_median, vert_img_median, img);
   [potential_exudate_map, potential_exudate_ys, potential_exudate_xs] = get_potential_exodus_pixels(h,w,subtracted_img, 10);
   
   confirmed_exudate_map = get_confirmed_exudate(img_h, img_w, subtracted_img, vec_img, vec_circle_pixels);
   figure;
   imagesc(confirmed_exudate_map);
   colormap gray;
   
   
   removed_exudate_map = remove_regions(img_h, img_w, potential_exudate_map, vec_img, vec_circle_pixels);
   figure;
   imagesc(removed_exudate_map);
   colormap gray;
   
   
   output_img = bitor(confirmed_exudate_map, removed_exudate_map);
   figure;
   imagesc(output_img);
   colormap gray;
   
   
   
   exudate_struct = bwconncomp(output_img); 
   exudate_cell_array  = exudate_struct.PixelIdxList;

end

% http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2769953/#b21
% http://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=7095378





% step 3: 








% step 2: Find Exudates Using Median Filter
function removed_exudate_map = remove_regions(img_h, img_w, potential_exudate_map, vec_img, vec_circle_pixels)
    
    vec_intensity_img = sum(vec_img,2);

    vec_potential_exudate_map = reshape(potential_exudate_map, [img_h*img_w,1]);
    all_connected_regions = bwconncomp(vec_potential_exudate_map);

    connected_pixel_list = all_connected_regions.PixelIdxList;
    
    connected_pixel_length_list = cellfun('length', connected_pixel_list);
    
    % using 10 pixels instead of 5
    filtered_connected_pixel_length_mask = (connected_pixel_length_list >= 10);
    
    filtered_connected_pixel_index = (filtered_connected_pixel_length_mask == 1);
    filtered_connected_pixel_list = connected_pixel_list(1, filtered_connected_pixel_index);
    
    
    img_map = get_uint8_img(img_h, img_w);
    
    
    [temp, list_length] = size(filtered_connected_pixel_list);
    
    exudates_pixel_regions = cell(0);
    
    for i=1:list_length
       
        p_group = filtered_connected_pixel_list{1,i};
        
        
        % checking the intensity
        p_group_intensity = vec_intensity_img(p_group);
        
        filter_flag = (p_group_intensity < 60);
        l = p_group_intensity(filter_flag);
        
        [m,n] = size(l);
        if ( m >= 1)
           continue;
        end
      
        
        % checking if it's in the optic disk
        filter_flag = ismember(p_group, vec_circle_pixels);
        if( all(filter_flag))
            continue;
        end
        
        i
        
        if(i==2360)
           a = 1; 
        end
        
        % check if it's near the boundary of the eye ball
        [p_group_ys, p_group_xs] = ind2sub( [img_h, img_w], p_group );
     
        [mean_x, mean_y] = compute_region_center( p_group_xs, p_group_ys);
        vec_boundary_pixels_idx = compute_window(mean_x, mean_y, img_h, img_w);
        boundary_pixels = vec_intensity_img(vec_boundary_pixels_idx);
        if( ~all(boundary_pixels))
            continue;
        end
        
        
        
        
        [h, cur_idx] = size(exudates_pixel_regions);
        exudates_pixel_regions{1,cur_idx+1} = p_group;
        img_map(p_group) = 1;
        %{
        figure;
        imagesc(img_map);
        colormap gray;
        %}
    end
    %{
    figure;
    imagesc(img_map);
    colormap gray;
    %}
    removed_exudate_map = img_map;
end





function [cx, cy] = compute_region_center(xs, ys)
    cx = round(mean(xs));
    cy = round(mean(ys));

end

function vec_boundary_pixels_idx = compute_window(cx, cy, img_h, img_w)
    window_width = 40;
    
    left = max(cx - window_width, 1);
    right = min(cx + window_width, img_w);
    top = max(cy - window_width, 1);
    bot = min(cy + window_width, img_h);
    
    [window_xs, window_ys] = meshgrid( left:right, top:bot); 
 
    linear_idx = sub2ind([img_h, img_w], window_ys, window_xs);
    [m,n] = size(linear_idx);
    linear_idx = reshape(linear_idx, [m*n,1]);
    
    vec_boundary_pixels_idx = linear_idx; 
    
end


function [hor_median, vert_median] = compute_50_pixel_median_filter(img_h, img_w, img)
    
    hor_median = zeros(img_h, img_w);
    vert_median = zeros(img_h, img_w);

%    load('15138_left_hor_median.mat');
 %   load('15138_left_vert_median.mat')

  
    img_int = sum(img,3);
    
    a=1;
    hor_median = zeros(img_h,img_w);
    vert_median = zeros(img_h,img_w);

    % along horizontal line
    for i=1:img_h
        i
        if(i>1700)
            a = 1;
        end
        
        hor_pixels = double(img(i,:,:));
        hor_pixels_int = sum(hor_pixels,3);
        
        med = medfilt1(hor_pixels_int, 50);
        hor_median(i,:) = round(med);
    end  
    a = 1
    
    
 
    % along horizontal line
    for i=1:img_w
        i
        vert_pixels = double(img(:,i,:));
        vert_pixels_int = sum(vert_pixels,3);
    
        if(i>1200)
            a = 1;
        end
        
        med = medfilt1(vert_pixels_int, 50);
        vert_median(:,i) = round(med);
    end
    % along vertical
   
    a = 1;

end



function subtracted_img = subtract_min_median(hor_median, vert_median, img)
    img_int = sum(img,3);

    min_median = min(hor_median, vert_median);

    subtracted_img = abs(img_int - min_median);
    
    
end




function [potential_exudate_map, potential_exudate_ys, potential_exudate_xs] = get_potential_exodus_pixels(h, w, subtracted_img, threshold)

  %  vec_potential_exodus_map = get_vec_uint8_img(h, w);
    
  %  vec_subtracted_img = reshape(subtracted_img, [h*w,1]);

  %  vec_potential_exodus_map = (vec_subtracted_img >= threshold);
    
  %  potential_exodus_map = reshape(vec_potential_exodus_map, [h,w]);
   
    potential_exudate_map = (subtracted_img >= threshold);
    [potential_exudate_ys, potential_exudate_xs] = find(subtracted_img >= threshold);
  
    figure;
    imagesc(potential_exudate_map);
  %  colormap gray
    


end


%function confirmed_exudate_map = get_confirmed_exudate(h, w, potential_exudate_map, potential_exudate_ys, potential_exudate_xs, subtracted_img, vec_img)
function confirmed_exudate_map = get_confirmed_exudate(h, w, subtracted_img, vec_img, vec_circle_pixels)
    
    confirmed_exudate_map = get_uint8_img(h,w);
  
    
    
  %  linear_ind = sub2ind([h,w], potential_exudate_ys, potential_exudate_xs);
    
    filtered_intensity_pixels = subtracted_img;
    green_intensity_pixels = vec_img(:, 2);
    green_intensity_pixels = reshape(green_intensity_pixels, [h,w]);
    
    filtered_intensity_map = (filtered_intensity_pixels > 30);
    green_intensity_map = (green_intensity_pixels > 100);
    
    filtered_intensity_map(vec_circle_pixels) = 0;
    green_intensity_map(vec_circle_pixels) = 0;
    
    result = filtered_intensity_map + green_intensity_map;
    
    [row, col] = find(result == 2);
    
    linear_ind = sub2ind([h,w], row, col);    
    confirmed_exudate_map(linear_ind) = 1;
    figure;
    imagesc(confirmed_exudate_map);
end







function vec_uint8_img = get_vec_uint8_img(h, w)
    temp = uint8(0);
    vec_uint8_img(h*w, :) = temp;
end


function uint8_img = get_uint8_img(h, w)
    temp = uint8(0);
    uint8_img(h,w) = temp;
end












% step 1: Find optical disc
function [sorted_l, sorted_ind] = sort_cell_list(cell_list)
    vec_list = cellfun('length', cell_list);
    [values, ind] = sort(vec_list(1,:),'descend');
    
    sorted_l = values;
    sorted_ind = ind;
end



function [center_x, center_y, radius, vec_circle_pixels]=compute_bounding_disc(h,w, p_list)
    
    [ys, xs] = ind2sub([h,w], p_list);
    
    center_x = round(mean(xs));
    center_y = round(mean(ys));

    top = min(ys);
    bot = max(ys);
    left = min(xs);
    right = max(xs);

    rect_w = left-right;
    rect_h = top - bot;
    
    radius = max(rect_w, rect_h);
    radius = radius + radius/2;
    
    plot( [left, right], [top, top], 'r-' ); 
    plot( [left, right], [bot, bot], 'r-' ); 
    plot( [left, left],  [top, bot], 'r-' ); 
    plot( [right, right],[top, bot], 'r-' ); 
    
    left_edge_mid_x = left;
    left_edge_mid_y = top + (bot - top)/2;
    
    plot( left_edge_mid_x, left_edge_mid_y, 'g.' ); 
    
    plot_circle(left_edge_mid_x, left_edge_mid_y, radius);
    
    
    center_x = left_edge_mid_x; 
    center_y = left_edge_mid_y;
    
    [img_c, img_r] = meshgrid(1:w, 1:h);
    
    circle_pixels = (img_r - center_y).^2 + (img_c - center_x).^2 <= radius.^2;
    
 %   [circle_pixel_ys, circle_pixel_xs] = find(circle_pixels == 1);
    
    vec_circle_pixels = find(circle_pixels == 1);
    
end


function plot_circle(x,y,r)
    
    th = 0:pi/50:2*pi;
    xunit = r * cos(th) + x;
    yunit = r * sin(th) + y;
    h = plot(xunit, yunit, 'g.' ); 


end


function [eye_ball_center_x, eye_ball_center_y, eye_ball_radius, inner_eye_ball_radius, vec_ring_pixels] = find_eye_ball_center(img_w, img_h, img)


    width = round(img_w/2);
    eye_ball_center_y = round(img_h/2);
    eye_ball_center_x_pixels = img(eye_ball_center_y, :, :);
    eye_ball_center_x_pixels_int = sum(eye_ball_center_x_pixels, 3);
    eye_ball_center_x_pixels_b = img(eye_ball_center_y, :, 3);

    int_threshold = 60;
%{    
    r_threshold = 40;
    g_threshold = 30;
    b_threshold = 20;
   
    eye_ball_left_edge = find(eye_ball_center_x_pixels_b >= b_threshold, 1, 'first');
    eye_ball_right_edge = find(eye_ball_center_x_pixels_b >= b_threshold, 1, 'last');    
  %}  
    
    eye_ball_left_edge = find(eye_ball_center_x_pixels_int >= int_threshold, 1, 'first');
    eye_ball_right_edge = find(eye_ball_center_x_pixels_int >= int_threshold, 1, 'last');
    
    eye_ball_left_edge_intensity = eye_ball_center_x_pixels(1,eye_ball_left_edge,:);
    eye_ball_right_edge_intensity = eye_ball_center_x_pixels(1,eye_ball_right_edge,:);
 %{
   eye_ball_edge_intensity = max(eye_ball_left_edge_intensity, eye_ball_right_edge_intensity);
%}
    
    %{
    eye_ball_left_edge = eye_ball_center_x_pixels(1,1:img_w/2);
    eye_ball_right_edge = eye_ball_center_x_pixels(1,img_w/2:end);
    
    eye_ball_left_edge = find(eye_ball_left_edge >= 20, 1, 'last');
    eye_ball_right_edge = find(eye_ball_right_edge >= 20, 1, 'first') + width;    
%}
    
    % 16_left  left_edge  12,15,20
    % 16_left  right_edge 15,19,20

    % 15138_left    left_edge 82 52 26
    % 15138_left    right_edge 38 30 20
    
    eye_ball_center_x = round( mean([eye_ball_left_edge, eye_ball_right_edge]));
    
    eye_ball_radius = eye_ball_center_x - eye_ball_left_edge;
    
    red_color = double(eye_ball_left_edge_intensity(1,1,1));
    green_color = double(eye_ball_left_edge_intensity(1,1,2));
    blue_color = double(eye_ball_left_edge_intensity(1,1,3));
    
    rgb_diff = abs(red_color + green_color - blue_color);
    if(rgb_diff == 0)
       rgb_diff = 1; 
    end
    
    eye_ball_ring_width = round(2000/rgb_diff);
    inner_eye_ball_radius = eye_ball_radius - eye_ball_ring_width;


    vec_circle_pixels = get_circle_pixel_list(img_h, img_w, eye_ball_center_x, eye_ball_center_y, eye_ball_radius);
    vec_inner_circle_pixels = get_circle_pixel_list(img_h, img_w, eye_ball_center_x, eye_ball_center_y, inner_eye_ball_radius);

    vec_ring_pixels = setdiff(vec_circle_pixels, vec_inner_circle_pixels);
    

    
  %  plot( ring_xs, ring_ys, 'g.');
end



function vec_circle_pixels = get_circle_pixel_list(img_h, img_w, center_x, center_y, radius)

    [img_c, img_r] = meshgrid(1:img_w, 1:img_h);
    circle_pixels = (img_r - center_y).^2 + (img_c - center_x).^2 <= radius.^2;
    vec_circle_pixels = find(circle_pixels == 1);
end