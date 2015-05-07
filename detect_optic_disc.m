function detect_optic_disc(img)
    [h,w,d] = size(img);
    
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
    compute_bounding_disc(h,w,optic_disc_pixel_list);
    
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
   compute_50_pixel_median_filter(h,w,img);
   
   
end







%{
% step 2: Find Exudates Using Median Filter
function compute_50_pixel_median_filter(h,w,img)

    hor_median = zeros(h,1);
    vert_median = zeros(1,w);

    % along horizontal line
    for i=1:h
        hor_pixels = double(img(i,:,:));
        
        med = medfilt1(hor_pixels, 50);
        int_med = sum(med,3);
        hor_median(i,1) = med;
    end
    
    a = 1;
    % along vertical
end
%}







% step 1: Find optical disc
function [sorted_l, sorted_ind] = sort_cell_list(cell_list)
    vec_list = cellfun('length', cell_list);
    [values, ind] = sort(vec_list(1,:),'descend');
    
    sorted_l = values;
    sorted_ind = ind;
end



function compute_bounding_disc(h,w, p_list)
    
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
    
end


function plot_circle(x,y,r)
    
    th = 0:pi/50:2*pi;
    xunit = r * cos(th) + x;
    yunit = r * sin(th) + y;
    h = plot(xunit, yunit, 'g.' ); 


end