
function img_hist = computeImageColorHistogram(img, bins)
    [m,n,c] = size(img);  
    num_pixels = (m*n);

    vec_image = double(reshape(img, [num_pixels,c]));
    vec_image_r = vec_image(:,1)';
    vec_image_g = vec_image(:,2)';
    vec_image_b = vec_image(:,3)';
    
    rh = hist(vec_image_r, bins)/num_pixels;
    gh = hist(vec_image_g, bins)/num_pixels;
    bh = hist(vec_image_b, bins)/num_pixels;

    img_hist = zeros(3,bins);

    img_hist(1,:) = rh;
    img_hist(2,:) = gh;
    img_hist(3,:) = bh;
    
end




%{
function [r, g, b] = getColorHistogram(im, bins)
    [rows, cols, ~] = size(im);
    count = rows * cols;
    im = reshape(im, [count, 3]);
    % for hist()
    bounds = linspace(0, 255, bins + 1);
    width = bounds(2) - bounds(1);
    center = bounds(1:bins) + 0.5 * width;
    
    r = hist(im(:, 1), center) / count;
    g = hist(im(:, 2), center) / count;
    b = hist(im(:, 3), center) / count;
end
%}




%{
function vec_img_hist = computeImageColorHistogram(img, bins)
% function [img_hist, vec_img_hist] = computeImageColorHistogram(img, bins)
    img = double(img);
    [m,n,c] = size(img);  
    num_pixels = (m*n);
    
    bin_width = 256/bins;
    
    vec_img = reshape(img, [num_pixels, c]);
    img_hist = zeros(bins, bins, bins, 1);
    
    indices = floor(vec_img / bin_width) + 1;

    for i = 1:num_pixels
        pixel_color = indices(i,:);
        img_hist(pixel_color(1), pixel_color(2), pixel_color(3)) = img_hist(pixel_color(1), pixel_color(2), pixel_color(3)) + 1;
    end
    vec_img_hist = img_hist(:);
end
%}


  %  vec_bin_image = double(reshape(bin_img, [m*n,c]));
%{
    vec_img_hist = zeros(bins*bins*bins, 1);
    for ind = 1:num_pixels
        pixel_color = vec_bin_image(ind,:);
          
        bin_r = pixel_color(1,1);
        bin_g = pixel_color(1,2);
        bin_b = pixel_color(1,3);
           
        index = (bin_b-1) * bins * bins + (bin_g-1) * bins + bin_r;
        
        vec_img_hist(index,:) = vec_img_hist(index,:)+1;
    end

    a = 1;
  %}










%{
function vec_img_hist = computeImageColorHistogram(img, bins)
% function [img_hist, vec_img_hist] = computeImageColorHistogram(img, bins)

    [m,n,c] = size(img);  
    num_pixels = (m*n);
    
    bin_width = 256/bins;
    
    img_hist = zeros(bins, bins, bins);    

    
    bin_img = floor(img / bin_width);
    bin_img(find(bin_img == 0)) = 1;
  %  bin_img(find(bin_img > bins)) = bins;

    
    vec_bin_image = double(reshape(bin_img, [m*n,c]));

    vec_img_hist = zeros(bins*bins*bins, 1);
    for ind = 1:num_pixels
        pixel_color = vec_bin_image(ind,:);
          
        bin_r = pixel_color(1,1);
        bin_g = pixel_color(1,2);
        bin_b = pixel_color(1,3);
           
        index = (bin_b-1) * bins * bins + (bin_g-1) * bins + bin_r;
        
        vec_img_hist(index,:) = vec_img_hist(index,:)+1;
    end

    a = 1;
end

%}


















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
hist
    vec_image = double(reshape(img, [num_pixels,c]));
    vec_image_r = vec_image(:,1)';
    vec_image_g = vec_image(:,2)';
    vec_image_b = vec_image(:,3)';
    
    rh = hist(vec_image_r, bins);
    gh = hist(vec_image_g, bins);
    bh = hist(vec_image_b, bins);
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    
    % indices = sub2ind([bins,bins,bins], );
    
 %   img_hist() = rh
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
% 2 for loop way
    for yi = 1:m 
        for xi = 1:n
            
            pixel_color = double(bin_img(yi,xi,:));
            bin_r = pixel_color(1,1,1);
            bin_g = pixel_color(1,1,2);
            bin_b = pixel_color(1,1,3);
            
            img_hist(bin_r, bin_g, bin_b) = img_hist(bin_r, bin_g, bin_b) + 1; 
        end
    end
    
    vec_img_hist = reshape(img_hist, [bins*bins*bins,1]);
    a = 1;
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




















%{
    [m,n,c] = size(img);  

    num_pixels = (m*n);
    
    img_hist = zeros(bins, bins, bins);    
    bin_width = 256/bins;
    
    bin_img = img / bin_width;
    bin_img(find(bin_img == 0)) = 1;

    for yi = 1:m 
        for xi = 1:n
            
            pixel_color = double(bin_img(yi,xi,:));
            bin_r = pixel_color(1,1,1);
            bin_g = pixel_color(1,1,2);
            bin_b = pixel_color(1,1,3);
            
            img_hist(bin_r, bin_g, bin_b) = img_hist(bin_r, bin_g, bin_b) + 1; 
        end
    end
    
    
    vec_img_hist = reshape(img_hist, [bins*bins*bins,1]);
    a = 1;
    %}
    
    
    
    
    %{
    for yi = 1:m 
        for xi = 1:n
          %{
            pixel_color = double(img(yi,xi,:));
            
            bin_r = floor(pixel_color(1,1,1) / bin_width);
            bin_g = floor(pixel_color(1,1,2) / bin_width);
            bin_b = floor(pixel_color(1,1,3) / bin_width);
            %}
            
            pixel_color = double(img(yi,xi,:));
            bin_r = floor(pixel_color(1,1,1) / bin_width);
            bin_g = floor(pixel_color(1,1,2) / bin_width);
            bin_b = floor(pixel_color(1,1,3) / bin_width);
   %{
            pixel_color2 = img(yi,xi,:);
            
            bin_r2 = (pixel_color(1,1,1) / bin_width);
            bin_g2 = (pixel_color(1,1,2) / bin_width);
            bin_b2 = (pixel_color(1,1,3) / bin_width);
            
            if(bin_r ~= bin_r2)
                a = 1
            end
            
            if(bin_g ~= bin_g2)
                a = 1
            end
            
            if(bin_b ~= bin_b2)
                a = 1
            end    
                    
            %}
            
            %{
            if(bin_r == 0)
                bin_r = 1;
            end
            
            if(bin_g == 0)
                bin_g = 1;
            end
            
            if(bin_b == 0)
                bin_b = 1;
            end
            %}
            
            
            bin_r(bin_r == 0) = 1;
            bin_g(bin_g == 0) = 1;
            bin_b(bin_b == 0) = 1;
            
            
            img_hist(bin_r, bin_g, bin_b) = img_hist(bin_r, bin_g, bin_b) + 1; 

            index = sub2ind(size(img_hist), bin_r, bin_g, bin_b);
      %      index2 = double(bin_r * bins * bins + bin_g * bins + bin_b);
            vec_img_hist(index, :) = img_hist(bin_r, bin_g, bin_b);
            
        end
    end
    %}
%    a = 1;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    %{
    vec_image = reshape(img, [m*n,c]);
    
    for ind = 1:num_pixels
        pixel_color = vec_image(ind,:);
          
        bin_r = double(pixel_color(1,1) / bin_width);
        bin_g = double(pixel_color(1,2) / bin_width);
        bin_b = double(pixel_color(1,3) / bin_width);
           
        index = double(bin_r * bins * bins + bin_g * bins + bin_b);
        
        
        vec_img_hist(index,:) = vec_img_hist(index,:)+1;
    end
    %}
    
    
  %  hist();
    
    %{
        r_count = zeros(1,256);
        g_count = zeros(1,256);
        b_count = zeros(1,256);
    %}
  
    %{
    for ind = 1:num_pixels
        pixel_color = vec_image(ind,:);
          
        bin_r = double(pixel_color(1,1) / bin_width);
        bin_g = double(pixel_color(1,2) / bin_width);
        bin_b = double(pixel_color(1,3) / bin_width);
           
        index = double(bin_r * bins * bins + bin_g * bins + bin_b);
        
        
        vec_img_hist(index,:) = vec_img_hist(index,:)+1;
    end
    %}
%    a = 1;
    
  
  

