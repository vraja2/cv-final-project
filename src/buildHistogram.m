function train_hist = buildHistogram(k_centers_descriptors, image_desc, num_k_centers)

    [m, num_desc] = size(image_desc);
    
    train_hist = zeros(1,num_k_centers);
    
    for i=1:num_desc
        
        desc = double(image_desc(:,i));
        
        k_ind = findNNKcenter(k_centers_descriptors, desc);
        
        train_hist(1,k_ind) = train_hist(1,k_ind) + 1;
        
    end
    
    train_hist = train_hist';
end