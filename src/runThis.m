function main()
    close all;
    [names, labels] = read_labels();

    img_path = './training_data/train/train.zip/train';
    
    bins = 16;
    levels = 3;
    num_images = 100;

    [all_train_img_names, all_train_img_labels] = get_labeled_images(names, labels, num_images);

    
    %{
    num_train_images = size(all_train_img_indices,1);
    all_train_img_hists = cell(num_train_images, 3);
    b = all_train_img_labels';
  %}  
 %   copy_files(all_train_img_names, all_train_img_labels);




 
 
 
    % training SVM
    
    
 
 
 
 
 
 
 
 
 
 
 

    img_path = './training_data/sub4';
    imagefiles = dir('./training_data/sub4/*.jpeg');
    nfiles = length(imagefiles);
    
   % n = numel(files);
    
    file_exudates_count = zeros(50,1);

    
    tic;
    for f = 1:18
       f
    %    train_img = imread(fn);
       %  train_img = imread('16_left.jpeg');
    %    train_img = imread('225_left.jpeg');
     %  train_img = imread('19367_left.jpeg'); 
     %   train_img = imread('1034_left.jpeg');   
     %    train_img = imread('10727_left.jpeg');               
   %     filename = get_file_name(f, all_train_img_names, img_path);      
   %     train_img = imread(filename);       
%        fn = fullfile(img_path, fn);
   %     filename = '10653_left.jpeg'; 
   
        filename = '11896_left.jpeg';  
  %      filename = imagefiles(f).name;
        
        filename = fullfile(img_path, filename);

        train_img = imread(filename);
        ori_img = train_img;
        
        [img_h, img_w, color] = size(train_img);
        
        figure;
        imagesc(train_img);
        
        train_img = normalize_red(train_img);
        
        figure;
        imagesc(train_img);       
        
        a = 1;
        

   
        [confirmed_exudate_map, potential_exudate_map, potential_exudate_cell_array, center_x, center_y, radius] = detect_optic_disc(train_img, ori_img);

%{
        confirmed_exudate_struct = bwconncomp(confirmed_exudate_map);
        confirmed_exudate_cell_array = confirmed_exudate_struct.PixelIdxList;
        new_confirmed_exudate_map = step3_using_average_back_up(train_img, img_h, img_w, ...
                                                        confirmed_exudate_map, confirmed_exudate_cell_array, center_x, center_y, radius);
%}
        new_confirmed_exudate_map = step3_using_average(train_img, img_h, img_w, ...
                                                        potential_exudate_map, potential_exudate_cell_array, center_x, center_y, radius);
                                                    
                                                    

        all_connected_regions = bwconncomp(new_confirmed_exudate_map);
        connected_pixel_list = all_connected_regions.PixelIdxList;
        connected_pixel_length_list = cellfun('length', connected_pixel_list);

        % using 20 pixels instead of 5
        filtered_connected_pixel_length_mask = (connected_pixel_length_list >= 5);
        filtered_connected_pixel_index = (filtered_connected_pixel_length_mask == 1);
        filtered_connected_pixel_list = connected_pixel_list(1, filtered_connected_pixel_index);
        [temp, list_length] = size(filtered_connected_pixel_list);
        img_map = get_uint8_img(img_h, img_w);
        for pi=1:list_length
            p_group = filtered_connected_pixel_list{1,pi};
            img_map(p_group) = 1;
            
        end                                      
        
        
                
        img_map = bitor(img_map, confirmed_exudate_map);
     
        
      %  img_map = new_confirmed_exudate_map;
        figure;
        imagesc(img_map);
        colormap gray;                                    
                                                    
                       

        
        pixel_count = get_pixel_count(new_confirmed_exudate_map);      
        file_exudates_count(f, 1) = pixel_count;
    end
    toc;

    a = 1;
    a = 1;
    a = 1;
    a = 1;    a = 1;
    a = 1;    a = 1;
    a = 1;



















%{
    img_path = './training_data/0';

    tic;
    for f = 1:size(all_train_img_names)
        f

        if(f>1)
            break;
        end
        
     %   fn = strtrim(all_train_img_names(f,:));
%        fn = fullfile('.', 'training_data', 'train', fn);
%        fn = fullfile(img_path, fn);

        files = dir(fullfile(img_path, '*.jpeg'));
        fn = fullfile(img_path, fn);
        
        
        
        
 %       train_img = imread(fn);
    %    train_img = imread('15138_left.jpeg');
     
 %       train_img = imread('22131_left.jpeg');
 %        train_img = imread('100_left.jpeg');
 %       train_img = imread('16410_left.jpeg');
 %       train_img = imread('16_left.jpeg');
        
   %     train_img = imread('2194_left.jpeg');
   %     train_img = imread('17546_left.jpeg');
   
   %     train_img = imread('169_left.jpeg');
   
        [img_h, img_w, color] = size(train_img);
   
        [confirmed_exudate_map, potential_exudate_map, potential_exudate_cell_array, center_x, center_y, radius] = detect_optic_disc(train_img);
%        new_potential_exudate_map = confirm_exudates(train_img, img_h, img_w, potential_exudate_map, potential_exudate_cell_array, center_x, center_y, radius);

        confirmed_exudate_struct = bwconncomp(confirmed_exudate_map);
        confirmed_exudate_cell_array = confirmed_exudate_struct.PixelIdxList;

        new_confirmed_exudate_map = step3_using_average(train_img, img_h, img_w, ...
                                                        confirmed_exudate_map, confirmed_exudate_cell_array, center_x, center_y, radius);

                                                    
        pixel_count = get_pixel_count(new_confirmed_exudate_map);
    end
    toc;
    a = 1
%}



    %{
    tic;
    for f = 1:size(all_train_img_names)
        f

        fn = strtrim(all_train_img_names(f,:))

        fn = fullfile('.', 'training_data', 'train', fn);

        train_img = imread(fn);

        %{
        if(f>10)
           break; 
        end
        %}
      %  figure;
      %  imshow(train_img);

        for lv = 1:levels
            layer = getPyramidHist(train_img, lv-1, bins);        
            all_train_img_hists{f,lv} = layer;
        end

    end
    toc;
    a = 1
    %}
    
    
    all_train_img_labels = all_train_img_labels'; 
    
    load('saved data\train_img_hist_L_100.mat')

    a = 1;
    
    test_labels = zeros(size(all_train_img_labels));
    


    % perform cross validation
    num_samples = num_train_images;
    num_folds = 10;
    indices = crossvalind('Kfold',num_samples,num_folds);
    for i = 1:num_folds
        test_mask = (indices == i); 
        train_mask = ~test_mask;
    
  %      test_names = all_train_img_names(test_mask,:);
   %     train_names = all_train_img_names(train_mask,:);
        
        [test_row,test_col] = find(test_mask == 1);
        [train_row,train_col] = find(train_mask == 1);
        
       % test_hists = all_train_img_hists{test_row,:};
        train_labels = all_train_img_labels(train_row,:);
      %  train_hists = all_train_img_hists{train_row,:}; 
        train_hists = assign_train_hists(train_row, all_train_img_hists);
        
        test_labels = test_labels + predict_test_labels(train_hists, all_train_img_hists, test_row, num_train_images, levels, train_labels);
        
    %    train_data = training(:,train_mask);
    %    train_labels = labels(train_mask);

        %1 vs all svm training
    end


    error_count = compareLabels(all_train_img_labels, test_labels);
    %}
end



function fn = get_file_name(index, all_train_img_names, img_path)
     
        fn = all_train_img_names(index,:);
        fn = fn{1,1};
        fn = strcat(fn, '.jpeg');
        fn = fullfile(img_path, fn);

end




function pixel_count = get_pixel_count(new_confirmed_exudate_map)
    pixel_count = (new_confirmed_exudate_map == 1);
    pixel_count = sum(sum(pixel_count));
end


function train_hists = assign_train_hists(train_row, all_train_img_hists)

    count = size(train_row,1);
    train_hists = cell(count, 3);
    for i = 1:count
        
        r = train_row(i,1);
        
        train_hists{i,1} = all_train_img_hists{r,1};
        train_hists{i,2} = all_train_img_hists{r,2};
        train_hists{i,3} = all_train_img_hists{r,3};
    end
    
end




function test_labels = predict_test_labels(train_hists, all_train_img_hists, test_row, num_train_images, levels, train_labels)
    tic; 
    test_labels = zeros(num_train_images,1);
    count = size(test_row);
    
    for f = 1:count
        f
        r = test_row(f,1);
        
        test_hist{1,1} = all_train_img_hists{r,1};
        test_hist{1,2} = all_train_img_hists{r,2};
        test_hist{1,3} = all_train_img_hists{r,3};
        
   %     test_labels(r,1) = findingIntersection(test_hist, train_hists, size(train_hists,1), levels, train_labels);
        
        test_labels(r,1) = evaluate_hist_euclid(test_hist, train_hists, size(train_hists,1), levels, train_labels);
    end
    toc;
    
end




function test_label = evaluate_hist_euclid(test_img_hist, all_training_hist, num_training_images, levels, all_training_labels)
    

    test_hist_mat = convert_cell_hist_to_mat(test_img_hist, levels);

    
    min_dist = Inf;
    min_ind = 0;
    for tf=1:num_training_images  

        train_hist{1,1} = all_training_hist{tf,1};
        train_hist{1,2} = all_training_hist{tf,2};
        train_hist{1,3} = all_training_hist{tf,3};

        
        train_hist_mat = convert_cell_hist_to_mat(train_hist, levels);
        
        dist = compute_hist_dist(test_hist_mat, train_hist_mat);
        
        if(dist < min_dist)
            min_dist = dist;
            test_label = all_training_labels(tf,1);
            min_ind = tf;
        end
        %{
    	for lv=1:levels

            train_img_cur_lv_hists = training_img_hists{1,lv};
            test_img_cur_lv_hists = test_img_hists{1,lv};
            
            lv_dim = 2^(lv-1);
            
            lv_sum = computeLevelIntersection(lv_dim, train_img_cur_lv_hists, test_img_cur_lv_hists);
            
            intersection = intersection + weights(1,lv) * lv_sum;
    	end
        intersections(tf,1) = intersection;
        %}
    end
    
end



function vec_img_hist = convert_cell_hist_to_mat(cell_hist, levels)
    rows = 1 + 4 + 16;
    vec_img_hist = zeros(3*rows,16);
    
    cur_ind = 1;
    for lv=1:levels

       w = 2 ^ (lv-1);
        
   %     i1 = cur_ind + count;
        for r = 1:w
            for c = 1:w

                h = cell_hist{1,lv};
                mat = h{r,c};
                vec_img_hist( cur_ind : cur_ind+2, :) = mat;
                cur_ind = cur_ind + 3;
            end
        end
        

    end
        
end


function dist = compute_hist_dist(h1, h2)
    dist = h1 - h2;
    dist = sqrt(sum (sum (abs(dist).^2)));
end


function copy_files(all_train_img_names, all_train_img_labels)

    tic;
    for f = 1:size(all_train_img_names)
        f

        fn = all_train_img_names(f,:);
        fn = fn{1,1};% + '.jpeg';
        fn = strcat(fn, '.jpeg');
        fn = fullfile('.', 'training_data', 'train', 'train.zip', 'train', fn);

         
    %    train_img = imread(fn);
        lb = all_train_img_labels(f,:);
        fdn = fullfile('.', 'training_data', int2str(lb));
        copyfile(fn, fdn);
    end
    toc;
end

%{

% recognition with Eigenfaces (PCA)
close all;
% clear all;


load('gs.mat');

train_imdir = 'categorization\train';
train_files = dir(fullfile(train_imdir, '*.jpg'));

test_imdir = 'categorization\test';
test_files = dir(fullfile(test_imdir, '*.jpg'));


bins = 16;
levels = 3;

level_weights = [1/2, 1/4, 1/4];
level_weights_1 = [1/4, 1/4, 1/2];

num_training_images = 1888;
num_test_images = 800;

all_training_hist = cell(num_training_images, 3);
all_training_labels = train_gs';

tic;
for f = 1:numel(train_files)
    f
    
   % fn = train_files(f).name;
   % train_img = imread(fn);
    
    fn = fullfile('.', 'categorization', 'train', strcat(int2str(f), '.jpg'));
    train_img = imread(fn);
    
    for lv = 1:levels
        layer = getPyramidHist(train_img, lv-1, bins);        
        all_training_hist{f,lv} = layer;
    end
end
toc;




all_testing_hist = cell(num_test_images, 3);
tic;
for f = 1:numel(test_files)
    f
    
    % fn = test_files(f).name;
    % test_img = imread(fn);
    
    fn = fullfile('.', 'categorization', 'test', strcat(int2str(f), '.jpg'));
    test_img = imread(fn);
    
    for lv = 1:levels
        test_layer = getPyramidHist(test_img, lv-1, bins);
        all_testing_hist{f,lv} = test_layer;
    end
end
toc;





estimated_test_labels = zeros(num_test_images, 1);
test_img_hists = cell(1,3);

end_ind = 800;

for f = 1:num_test_images
    
    if(f>end_ind)
        break;
    end
    
    f
    test_img_hists{1,1} = all_testing_hist{f,1};
    test_img_hists{1,2} = all_testing_hist{f,2};
    test_img_hists{1,3} = all_testing_hist{f,3};
    estimated_test_labels(f,1) = findingIntersection(test_img_hists, all_training_hist, num_training_images, levels, all_training_labels);
end

ori_test_labels = zeros(num_test_images, 1);
ori_test_labels(1:end_ind, 1) = test_gs(1,1:end_ind);
error_count = compareLabels(ori_test_labels, estimated_test_labels);

a = 1;

%}




