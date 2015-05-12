function categorizationHistogram
    imdir = 'categorization/train';
    files = dir(fullfile(imdir, '*.jpg'));
    test_files = dir(fullfile('categorization/test','*.jpg'));
    data = load('categorization/gs.mat');
    train_gs = data.train_gs;
    test_gs = data.test_gs;
    num_bins = 10;
    %evaluate_euclid(test_files,test_gs);
%     feature_vectors = zeros(21*3*num_bins,numel(files));
%     training_pyramids = zeros(21*3*num_bins,numel(files));
%     for i = 1:1888
%         im = double(imread(sprintf('categorization/train/%d.jpg', i)));
%         training_pyramids(:,i) = get_feature_vector(im,num_bins);
%     end
%     test_pyramids = zeros(21*3*num_bins,numel(test_files));
%     for i = 1:800
%         im = double(imread(sprintf('categorization/test/%d.jpg', i)));
%         test_pyramids(:,i) = get_feature_vector(im, num_bins);
%     end
%     save('pyramids.mat');
    pyramids = load('pyramids.mat');
    training_pyramids = pyramids.training_pyramids;
    test_pyramids = pyramids.test_pyramids;

    %feature_vectors
%     for f = 1:numel(files)
%         fprintf('On image %i\n',f);
%         fn = files(f).name;
%         im = double(imread(fullfile(imdir, fn)));
%         feature_vector = get_feature_vector(im,num_bins);
%         feature_vectors(:,f) = feature_vector;
%     end
    train_labels = train_gs;
    model = fitcknn(training_pyramids',train_labels);
    evaluate_intersection(model,test_pyramids,training_pyramids,train_labels,test_gs);
end

function feature_vector = get_feature_vector(im,num_bins)
    [m,n,z] = size(im);
    %level 1
    l1_hist = compute_color_histogram(im,num_bins);
    %level 2
    mid_y = m/2;
    mid_x = n/2;
    l2_hist1 = compute_color_histogram(im(1:mid_y,1:mid_x,:),num_bins);
    l2_hist2 = compute_color_histogram(im(1:mid_y,mid_x+1:end,:),num_bins);
    l2_hist3 = compute_color_histogram(im(mid_y+1:end,1:mid_x,:),num_bins);
    l2_hist4 = compute_color_histogram(im(mid_y+1:end,mid_x+1:end,:),num_bins);
    l2_hists = [l2_hist1;l2_hist2;l2_hist3;l2_hist4];
    %level 3
    patch_y = m/4;
    patch_x = n/4;
    l3_hists = zeros(num_bins*3,16);
    curr_ind = 1;
    for y=1:patch_y:m
       for x=1:patch_x:n
          curr_patch=im(y:y+patch_y-1,x:x+patch_x-1,:);
          curr_hist = compute_color_histogram(curr_patch,num_bins);
          l3_hists(:,curr_ind) = curr_hist;
          curr_ind = curr_ind + 1;
       end
    end
    l3_hists = l3_hists(:);
    %concatenate levels
    feature_vector = [(0.5*l1_hist);(0.25*l2_hists);(0.25*l3_hists)];
end

function histogram = compute_color_histogram(I,num_bins)
    im=reshape(I,[size(I,1)*size(I,2),3]);
    r_hist = hist(im(:,1),num_bins);
    g_hist = hist(im(:,2),num_bins);
    b_hist = hist(im(:,3),num_bins);
    r_hist = r_hist/norm(r_hist,1);
    g_hist = g_hist/norm(g_hist,1);
    b_hist = b_hist/norm(b_hist,1);
    histogram = [r_hist';g_hist';b_hist'];
end

function evaluate_euclid(test_files,test_gs)
    data = load('num2.mat');
    train_labels = data.train_gs;
    feature_vectors = data.feature_vectors;
    num_correct = 0;
    imdir = 'categorization/test';
    num_bins = 16;
    for f=1:800
        fn = test_files(f).name;
        im = double(imread(fullfile(imdir, fn)));
        feature_vector = get_feature_vector(im,num_bins);
        mindist = Inf;
        label = NaN;
        for j=1:1888
            train_vec = feature_vectors(:,j);
            dist = compute_euclid(train_vec,feature_vector);
            if dist < mindist
               mindist = dist;
               label = train_labels(j);
            end
        end
        if label == test_gs(1,f)
           num_correct = num_correct + 1; 
        end
    end
    fprintf('Num correct: %i\n', num_correct);
end

function K = hist_intersection(A, B)
    K = sum(min(A,B));
end


function dist = compute_euclid(vec1,vec2)
    dist = sqrt(sum((vec1 - vec2) .^ 2));
end

function evaluate_intersection(model,test_pyramids,training_pyramids,train_gs,test_gs)
    errCount = 0;
    pred_labels = zeros(1,800);
    for i = 1:800
        currPyramid = test_pyramids(:,i);
        bestMatchIdx = -1;
        bestIntersection = -Inf;
        for j = 1:1888
            intersection = hist_intersection(currPyramid,training_pyramids(:,j));
            if intersection > bestIntersection
                bestIntersection = intersection;
                bestMatchIdx = j;
            end
        end
        pred_labels(i) = train_gs(1,bestMatchIdx); 
        if(test_gs(1,i) ~= train_gs(1,bestMatchIdx))
            errCount = errCount + 1;
        end
    end
    buildConfusionMatrix(test_gs,pred_labels);
end

function evaluate(model,test_pyramids,training_pyramids,train_gs,test_gs)
    errCount = 0;
    for i = 1:800
        currPyramid = test_pyramids(:,i);
        bestMatchIdx = -1;
        bestDist = Inf;
        for j = 1:1888
            dist = norm(currPyramid - training_pyramids(:,j));
            if dist < bestDist
                bestDist = dist;
                bestMatchIdx = j;
            end
        end
        if(test_gs(1,i) ~= train_gs(1,bestMatchIdx))
            errCount = errCount + 1;
        end
    end
end

function evaluate_model(model,test_pyramids,training_pyramids,train_gs,test_gs)
    errCount = 0;
    for i=1:800
        curr_pyramid = test_pyramids(:,i);
        prediction = predict(model,curr_pyramid');
        if prediction ~= test_gs(1,i)
           errCount = errCount + 1;
        end
    end
end

