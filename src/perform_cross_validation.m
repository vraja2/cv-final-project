function perform_cross_validation(training,labels)
    num_samples = size(training,2);
    num_folds = 10;
    indices = crossvalind('Kfold',num_samples,num_folds);
    for i = 1:num_folds
        test = (indices == i); 
        train = ~test;
        train_data = training(:,train);
        train_labels = labels(train);
        %1 vs all svm training
        
        
        
    end
end

