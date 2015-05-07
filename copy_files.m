function copy_files(all_train_img_names, all_train_img_labels)

    tic;
    for f = 1:size(all_train_img_names)
        f

        fn = strtrim(all_train_img_names(f,:))

        fn = fullfile('.', 'training_data', 'train', fn);

         
    %    train_img = imread(fn);
        lb = all_train_img_labels(f,:);
        fdn = fullfile('.', 'training_data', int2str(lb));
        copyfile(fn, fdn);
    end
    toc;
end