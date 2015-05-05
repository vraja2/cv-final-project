function classifier
    addpath ./vlfeat-0.9.20
    labels = read_labels();
    [descriptors,labels] = get_sift('./training_data/train',labels,100);
    save('classifier.mat');
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

function labels = read_labels()
    f = fopen('./training_data/trainLabels.csv');
    parsed = textscan(f,'%s%f','delimiter',',');
    labels = parsed{2};
end

function [descriptors,labels] = get_sift(imdir,im_labels,vectors_per_im)
    files = dir(fullfile(imdir, '*.jpeg'));
    n = numel(files);
    descriptors = [];
    labels = [];
    for i = 1:2
        fn = files(i).name;
        im = imreadbw(fullfile(imdir,fn));
        im = im-min(im(:));
        im = im/max(im(:));
        tic
        [f,d] = vl_sift(im);
        %select 100 random sift feature vectors for each image
        perm = randperm(size(f,2));
        sel = perm(1:vectors_per_im);
        sel_descriptors = d(:,sel);
        descriptors = [descriptors sel_descriptors];
        descriptor_labels = im_labels(i)*ones(1,vectors_per_im);
        labels = [labels descriptor_labels];
        toc
    end
end

function training_im = get_training

end

function testing_im = get_testing

end