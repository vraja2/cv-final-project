function error_count = compareLabels(ori_labels, test_labels)

    mask = (ori_labels ~= test_labels);
    
    error_count = nnz(mask);
end