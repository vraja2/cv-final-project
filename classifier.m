function classifier
    addpath ./vlfeat-0.9.20
    labels = read_labels();
    %[descriptors,labels] = get_sift('./training_data/train',labels,100);
    %save('classifier.mat');
    [descriptors,~] = load_sift();
    labels = construct_sift_labels();
    [reduced_samples,reduced_labels] = reduce_sample_size(descriptors,labels);
    [sliced_descriptors,sliced_labels] = slice_sift(reduced_samples,reduced_labels,10);
    perform_cross_validation(sliced_descriptors,sliced_labels);
end

function [descriptors,labels] = load_sift
    classifier_mat = load('classifier.mat');
    descriptors = classifier_mat.descriptors;
    labels = classifier_mat.labels;
end

function labels = construct_sift_labels
    labels(1:50000) = 0;
    labels(50001:100000) = 1;
    labels(100001:150000) = 2;
    labels(150001:200000) = 3;
    labels(200001:250000) = 4;
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
        for j=1:25
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

function perform_cross_validation(training,labels)
    num_samples = size(training,2);
    num_folds = 10;
    indices = crossvalind('Kfold',num_samples,num_folds);
    for i = 1:num_folds
        test = (indices == i); 
        train = ~test;
        test_data = training(:,test);
        test_labels = labels(test);
        train_data = training(:,train);
        train_labels = labels(train);
        %1 vs all svm training
        models = build_models(double(train_data),train_labels);    
        evaluate(models,test_data,test_labels);
    end
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

function evaluate(models,test_data,test_labels)
    num_correct = 0;
    preds = []
    for j=1:numel(test_labels)
        max_pred = -1;
        max_score = -Inf;
        for k=1:5
            [prediction,score] = predict(models{k},double(test_data(:,j)'));
            if score(2) > max_score
                max_pred = prediction;
                max_score = score(1);
            end
        end
        preds = [preds max_pred];
        if max_pred == test_labels(j)
           num_correct = num_correct + 1; 
        end
    end
    display(preds);
    display(num_correct);
end

