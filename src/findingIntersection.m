function test_label = findingIntersection(test_img_hists, all_training_hist, num_training_images, levels, all_training_labels)
        
    intersections = zeros(num_training_images,1);
    weights = [1/4, 1/4, 1/2];
    
    training_img_hists = cell(1,3);
    for tf=1:num_training_images  

        intersection = 0;
        
        training_img_hists{1,1} = all_training_hist{tf,1};
        training_img_hists{1,2} = all_training_hist{tf,2};
        training_img_hists{1,3} = all_training_hist{tf,3};

    	for lv=1:levels

            train_img_cur_lv_hists = training_img_hists{1,lv};
            test_img_cur_lv_hists = test_img_hists{1,lv};
            
            lv_dim = 2^(lv-1);
            
            lv_sum = computeLevelIntersection(lv_dim, train_img_cur_lv_hists, test_img_cur_lv_hists);
            
            intersection = intersection + weights(1,lv) * lv_sum;
    	end
        intersections(tf,1) = intersection;
    end
    
    [max_value, max_index] = max(intersections);
    test_label = all_training_labels(max_index,1);
end


function min_vectors = computeLevelIntersection(lv_dim, train_img_cur_lv_hists, test_img_cur_lv_hists)
    min_vectors = zeros(lv_dim, lv_dim);

    for xi = 1:lv_dim
        for yi = 1:lv_dim

            hist1 = train_img_cur_lv_hists{yi, xi};
            hist2 = test_img_cur_lv_hists{yi, xi};
            
            min_vectors(yi, xi) = computeMinHistVec(hist1, hist2);
        end
    end
    min_vectors = sum(min_vectors(:));
end


function mag = computeMinHistVec(hist1, hist2)
    
    r_min = min(hist1(1,:), hist2(1,:));
    g_min = min(hist1(2,:), hist2(2,:));
    b_min = min(hist1(3,:), hist2(3,:));
    
    all = [r_min, g_min, b_min];
    mag = sum(all(:));
end
