% function [train_img_indices, train_img_labels, train_img_names, test_img_indices, test_img_labels, test_img_names] = get_labeled_images(imdir,im_labels, num_train_imgs, num_test_imgs)
function [train_img_names, train_img_labels] = get_labeled_images(im_names, im_labels, num_train_imgs_per_class)
 
    left_files = im_names(1:2:end);
    left_files_labels = im_labels(1:2:end);

    right_files = im_names(2:2:end);
    right_files_labels = im_labels(2:2:end);
    
    l0_im = find(left_files_labels == 0);
    l1_im = find(left_files_labels == 1);
    l2_im = find(left_files_labels == 2);
    l3_im = find(left_files_labels == 3);
    l4_im = find(left_files_labels == 4);
    
    l0_ind = l0_im(1 : num_train_imgs_per_class);
    l1_ind = l1_im(1 : num_train_imgs_per_class);
    l2_ind = l2_im(1 : num_train_imgs_per_class);
    l3_ind = l3_im(1 : num_train_imgs_per_class);
    l4_ind = l4_im(1 : num_train_imgs_per_class);
    
    names0 = left_files(l0_ind);
    names1 = left_files(l1_ind);
    names2 = left_files(l2_ind);
    names3 = left_files(l3_ind);
    names4 = left_files(l4_ind);
                     
    labels0(1:num_train_imgs_per_class,1) = 0;
    labels1(1:num_train_imgs_per_class,1) = 1;
    labels2(1:num_train_imgs_per_class,1) = 2;
    labels3(1:num_train_imgs_per_class,1) = 3;
    labels4(1:num_train_imgs_per_class,1) = 4;
    

    train_img_names = [names0;
                       names1;
                       names2;
                       names3;
                       names4];
      
    train_img_labels = [labels0;
                        labels1;
                        labels2; 
                        labels3;
                        labels4];
end

    %{
    train_img_labels(                    		   1 : 1*num_train_imgs_per_class) = 0;
    train_img_labels(     num_train_imgs_per_class+1 : 2*num_train_imgs_per_class) = 1;
    train_img_labels(   2*num_train_imgs_per_class+1 : 3*num_train_imgs_per_class) = 2;
    train_img_labels(   3*num_train_imgs_per_class+1 : 4*num_train_imgs_per_class) = 3;
    train_img_labels(   4*num_train_imgs_per_class+1 : 5*num_train_imgs_per_class) = 4;
    %}
	
    
    %{
    %create a list to store all the indices of images you want sift vectors
    l0_im = find(left_files_labels == 0);
    l1_im = find(left_files_labels == 1);
    l2_im = find(left_files_labels == 2);
    l3_im = find(left_files_labels == 3);
    l4_im = find(left_files_labels == 4);

    train_img_indices = get_image_indices(l0_im, l1_im, l2_im, l3_im, l4_im, 1, num_train_imgs_per_class);
                        
    train_img_labels(                    		   1 : 1*num_train_imgs_per_class) = 0;
    train_img_labels(     num_train_imgs_per_class+1 : 2*num_train_imgs_per_class) = 1;
    train_img_labels(   2*num_train_imgs_per_class+1 : 3*num_train_imgs_per_class) = 2;
    train_img_labels(   3*num_train_imgs_per_class+1 : 4*num_train_imgs_per_class) = 3;
    train_img_labels(   4*num_train_imgs_per_class+1 : 5*num_train_imgs_per_class) = 4;
    
	names = transpose(extractfield(files, 'name'));
    train_img_names = names(train_img_indices,:);

    train_img_names = cellstr(train_img_names);
    train_img_names = char(train_img_names);
    %}






function img_indices = get_image_indices(l0, l1, l2, l3, l4, i1, i2)
    
    img_indices = [l0(i1:i2);   
                   l1(i1:i2);   
                   l2(i1:i2);   
                   l3(i1:i2);   
                   l4(i1:i2)];
end


%{
function [train_img_indices, train_img_labels, train_img_names] = get_labeled_images(imdir,im_labels, num_train_imgs)
    files = dir(fullfile(imdir, '*left.jpeg'));
    n = numel(files);

    %create a list to store all the indices of images you want sift vectors
    %for
    l0_im = find(im_labels == 0);
    l1_im = find(im_labels == 1);
    l2_im = find(im_labels == 2);
    l3_im = find(im_labels == 3);
    l4_im = find(im_labels == 4);
    %slice 500 images from each label
    %{
    train_img_indices = [   l0_im(1:num_train_imgs);
                            l1_im(1:num_train_imgs);
                            l2_im(1:num_train_imgs);
                            l3_im(1:num_train_imgs);
                            l4_im(1:num_train_imgs)];
    %}
    train_img_indices = get_image_indices(l0_im, l1_im, l2_im, l3_im, l4_im, 1, num_train_imgs);
                        
    
    train_img_labels(                    1 : 1*num_train_imgs) = 0;
    train_img_labels(     num_train_imgs+1 : 2*num_train_imgs) = 1;
    train_img_labels(   2*num_train_imgs+1 : 3*num_train_imgs) = 2;
    train_img_labels(   3*num_train_imgs+1 : 4*num_train_imgs) = 3;
    train_img_labels(   4*num_train_imgs+1 : 5*num_train_imgs) = 4;
    
	names = transpose(extractfield(files, 'name'));
    train_img_names = names(train_img_indices,:);

    train_img_names = cellstr(train_img_names);
    train_img_names = char(train_img_names);
    
end
%}