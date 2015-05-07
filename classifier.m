function classifier
    addpath ./vlfeat-0.9.20
    labels = read_labels();
    %[descriptors,labels] = get_sift('./training_data/train',labels,100);
    %save('classifier.mat');
    %get_left_right(labels);
    %build the sift matrix
    [descriptors,~] = load_sift();
    matrices = construct_cell_arrays(descriptors);
    [left_matrices,left_labels,right_matrices,right_labels] = separate_images(labels,matrices);
    %labels = construct_sift_labels();
    %[sliced_descriptors,sliced_labels] = slice_sift(descriptors,labels,10);
    perform_cross_validation(left_matrices,left_labels);
    perform_cross_validation(right_matrices,right_labels);
end

function [left_im,left_labels,right_im,right_labels] = separate_images(im_labels,matrices)
    l0_im = find(im_labels == 0);
    l1_im = find(im_labels == 1);
    l2_im = find(im_labels == 2);
    l3_im = find(im_labels == 3);
    l4_im = find(im_labels == 4);
    files = dir(fullfile('./training_data/train', '*.jpeg'));
    l0_images = files(l0_im);
    [l0_left,l0_right] = get_left_right(l0_images(1:500),matrices(1:500));
    l1_images = files(l1_im);
    [l1_left,l1_right] = get_left_right(l1_images(1:500),matrices(501:1000));
    l2_images = files(l2_im);
    [l2_left,l2_right] = get_left_right(l2_images(1:500),matrices(1001:1500));
    l3_images = files(l3_im);
    [l3_left,l3_right] = get_left_right(l3_images(1:500),matrices(1501:2000));
    l4_images = files(l4_im);
    [l4_left,l4_right] = get_left_right(l4_images(1:500),matrices(2001:2500));
    left_im = [l0_left l1_left l2_left l3_left l4_left];
    right_im = [l0_right l1_right l2_right l3_right l4_right];
    left_labels = [zeros(1,numel(l0_left)),ones(1,numel(l1_left)),2*ones(1,numel(l2_left)),3*ones(1,numel(l3_left)),4*ones(1,numel(l4_left))];
    right_labels = [zeros(1,numel(l0_right)),ones(1,numel(l1_right)),2*ones(1,numel(l2_right)),3*ones(1,numel(l3_right)),4*ones(1,numel(l4_right))];
end

function [left_images,right_images] = get_left_right(files,matrices)
    leftind=1;
    rightind=1;
    for i=1:numel(files)
        curr_file = files(i);
        if strfind(curr_file.name,'left')
            left_images{leftind} = matrices{i};
            leftind = leftind+1;
        else
            right_images{rightind} = matrices{i};
            rightind = rightind+1;
        end
    end
end

function [descriptors,labels] = load_sift
    classifier_mat = load('classifier.mat');
    descriptors = classifier_mat.descriptors;
    labels = classifier_mat.labels;
end

function matrices = construct_cell_arrays(descriptors)
    j=1;
    for i=1:100:size(descriptors,2)
        matrices{j} = descriptors(:,i:i+100-1);
        j=j+1;
    end
end

function means = select_k_means(k,matrix)
    [m,n] = size(matrix);
    means = matrix(:,randperm(n,k));
end

function closest_means = find_closest(sift_matrix,k_means)
    d = pdist2(k_means',sift_matrix');
    [~,closest_means] = min(d);
end

function new_means = compute_new_means(closest_means, sift_matrix,K)
    new_means = zeros(128,K);
    for i=1:K
       cluster_elements = find(closest_means==i); 
       cluster_vectors = sift_matrix(:,cluster_elements);
       new_means(:,i) = mean(cluster_vectors,2);
    end
end

function labels = construct_sift_labels
    labels(1:500) = 0;
    labels(501:1000) = 1;
    labels(1001:1500) = 2;
    labels(1501:2000) = 3;
    labels(2001:2500) = 4;
end

function I = imreadbw(file)
    %   IMREADBW  Reads an image as gray-scale
    %   I=IMREADBW(FILE) reads the image FILE and converts the result to a
    %   gray scale image (with DOUBLE storage class anr range normalized
    %   in [0,1]).
    I = imread(file);
    if(size(I,3) > 1)
        I = single(rgb2gray(I)) ;
    end
end

function [reduced_samples,reduced_labels] = reduce_sample_size(descriptors,labels)
    reduced_samples = [];
    reduced_labels = [];
    %50,000 vectors per class
    for i=1:50000:size(descriptors,2)
        %reduce to 150 images per class from 500
        for j=1:100
            reduced_samples = [reduced_samples descriptors(:,i+((j-1)*100):i+(j*100)-1)];
            reduced_labels = [reduced_labels labels(i+((j-1)*100):i+(j*100)-1)];
        end
    end
end

function labels = read_labels()
    f = fopen('./training_data/trainLabels.csv');
    parsed = textscan(f,'%s%f','delimiter',',');
    labels = parsed{2};
end

function [descriptors,labels] = get_sift(imdir,im_labels,vectors_per_im)
    files = dir(fullfile(imdir, '*.jpeg'));
    n = numel(files);
    %create a list to store all the indices of images you want sift vectors
    %for
    l0_im = find(im_labels == 0);
    l1_im = find(im_labels == 1);
    l2_im = find(im_labels == 2);
    l3_im = find(im_labels == 3);
    l4_im = find(im_labels == 4);
    %slice 500 images from each label
    img_indices = [l0_im(1:500)',l1_im(1:500)',l2_im(1:500)',l3_im(1:500)',l4_im(1:500)'];
    descriptors = [];
    labels = [];
    for i = 1:numel(img_indices)
        display(i);
        fn = files(img_indices(i)).name;
        im = imreadbw(fullfile(imdir,fn));
        im = im-min(im(:));
        im = im/max(im(:));
        [f,d] = vl_sift(im);
        %select 100 random sift feature vectors for each image
        perm = randperm(size(f,2));
        sel = perm(1:vectors_per_im);
        sel_descriptors = d(:,sel);
        descriptors = [descriptors sel_descriptors];
        descriptor_labels = im_labels(i)*ones(1,vectors_per_im);
        labels = [labels descriptor_labels];
    end
end

function means = initialize_means(K,descriptors)
    K = 100;
    %initialize means
    means = select_k_means(K,descriptors);
    for i=1:100
        fprintf('%i\n',i);
        closest_means = find_closest(double(descriptors),double(means));
        means = compute_new_means(closest_means,descriptors,K);
    end  
end

function sift_matrix = construct_sift_matrix(matrices,vectors_per_im)
    sift_matrix = zeros(128,size(matrices,2)*vectors_per_im);
    curr_idx = 1;
    for i=1:size(matrices,2)
        curr_matrix = matrices{i};
        [m,n] = size(curr_matrix);
        rand_vectors = randperm(n,vectors_per_im);
        sift_matrix(:,curr_idx:curr_idx+vectors_per_im-1) = curr_matrix(:,rand_vectors);
        curr_idx = curr_idx+vectors_per_im;
    end
end

function histogram = compute_histogram(matrices,k_means)
    K = size(k_means,2);
    histogram = zeros(size(matrices,2),K);
    [~,num_matrices] = size(matrices);
    for i=1:num_matrices
        curr_matrix = double(matrices{i});
        d = pdist2(k_means',curr_matrix');
        [~,I] = min(d,[],1);
        for j=1:size(I,2)
            histogram(i,I(1,j)) = histogram(i,I(1,j))+1;
        end
    end
end

function evaluate(training_histograms,testing_histograms,train_labels,test_labels)
    d = pdist2(testing_histograms,training_histograms);
    [M,I] = min(d,[],2);
    num_correct = 0;
    pred_labels = zeros(1,numel(test_labels));
    for i=1:size(testing_histograms,2)
        true_label = test_labels(1,i);
        pred_label = train_labels(1,I(i,1));
        pred_labels(i) = pred_label;
        if true_label == pred_label
           num_correct = num_correct+1; 
        end
    end
    buildConfusionMatrix(test_labels,pred_labels);
end


function perform_cross_validation(matrices,labels)
    num_samples = size(matrices,2);
    num_folds = 10;
    indices = crossvalind('Kfold',num_samples,num_folds);
    K=100;
    for i=1:num_folds
        test = (indices == i);
        train = ~test;
        test_matrices = matrices(test);
        test_labels = labels(test);
        train_matrices = matrices(train);
        train_labels = labels(train);
        sift_matrix = construct_sift_matrix(train_matrices,20);
        means = initialize_means(K,sift_matrix);
        training_histograms = compute_histogram(train_matrices,means);
        testing_histograms = compute_histogram(test_matrices,means);
        svmModel = fitcecoc(training_histograms,train_labels');
        predictions = predict(svmModel,testing_histograms);
        %evaluate(training_histograms,testing_histograms,train_labels,test_labels);
        evaluateSVM(predictions,test_labels);
    end
end

function evaluateSVM(predictions,test_labels)
    num_correct = 0;
    for i=1:length(test_labels)
        if predictions(i) == test_labels(i)
          num_correct = num_correct+1; 
        end
    end
    display(num_correct);
end

function [sliced_descriptors,sliced_labels] = slice_sift(descriptors,labels,num_per_slice)
    sliced_descriptors = [];
    sliced_labels = [];
    for i=1:100:size(descriptors,2)
        sliced_descriptors = [sliced_descriptors descriptors(:,i:i+num_per_slice-1)];
        sliced_labels = [sliced_labels labels(i:i+num_per_slice-1)];
    end
end

function models = build_models(train,labels)
    for k=1:5
        display(k);
        %binarize group so that only current group is selected
        G1vAll = (labels==(k-1));
        tic
        models{k} = fitcsvm(train',G1vAll','KernelFunction','linear');
        toc
    end
end
