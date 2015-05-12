function cur_layer = getPyramidHist(img, cur_level, bins)
    [h,w,c] = size(img);

    cell_dim = 2^cur_level;
    cur_layer = cell(cell_dim,cell_dim);
    sub_x = round(linspace(1, w, cell_dim+1));
    sub_y = round(linspace(1, h, cell_dim+1));
    
    for xi = 1:cell_dim
        cols = sub_x(xi):sub_x(xi+1);
        
        for yi = 1:cell_dim
            rows = sub_y(yi):sub_y(yi+1);
            
            sub_img = img(rows, cols, :);
       %     figure;
       %     imshow(sub_img);
            histogram = computeImageColorHistogram(sub_img, bins);
            cur_layer{xi,yi} = histogram;   

        end
    end
    
end

