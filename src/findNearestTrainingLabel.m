function test_label = findNearestTrainingLabel(vec_test_img_hists, training_img_hists, training_img_labels)
    
    temp_vector = bsxfun(@minus, training_img_hists, vec_test_img_hists);
    temp_vector = sqrt(sum(abs(temp_vector).^2));
    [min_value, min_index] = min(temp_vector);
    test_label = training_img_labels(:,min_index);
end