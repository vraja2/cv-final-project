function classifier
    images = read_images('./training_data/train');
    labels = read_labels();
    [descriptors,labels] = get_sift(images);
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

function images = read_images(imdir)
    addpath ./vlfeat-0.9.20
    files = dir(fullfile(imdir, '*.jpeg'));
    for f = 1:2
        fn = files(f).name;
        im = imreadbw(fullfile(imdir,fn));
        im = im-min(im(:));
        im = im/max(im(:));
        images{f} = im;
    end
end 

function [descriptors,labels] = get_sift(images,im_labels)
    addpath ./sift
    addpath ./vlfeat-0.9.20
    [m,n] = size(images);
    for i = 1:n
        tic
        %[frames,descr,gss,dogss] = sift(images{i},'Verbosity',1);    
        [f,d] = vl_sift(images{i});
        perm = randperm(size(f,2));
        sel = perm(1:100);
        sel_descriptors = d(:,sel);
        descriptors = [descriptors sel_descriptors];
        toc
    end
end

function training_im = get_training

end

function testing_im = get_testing

end