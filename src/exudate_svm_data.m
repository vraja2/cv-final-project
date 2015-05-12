
group0_exudate_pixel_count = [ 18641	3993	6201	17729	7249	8715	15323	94	13055	4875  3543] ;
group1_exudate_pixel_count = [ 40532	77964	5164	9304	59171	17479	12734	51011	56326	8928	15054];
group2_exudate_pixel_count = [ 31814	288	128553	343760	109769	6640	24522	49912	40701	20026	14304];
group3_exudate_pixel_count = [ 44857	15428	105027	81109	11069	4615	62824	110261	122195	21719	134171];
group4_exudate_pixel_count = [ 60137	88588	180435	61920	96647	59548	110793	172774	43930	63574	86324];

len = length(group0_exudate_pixel_count);

group0_labels(1:len) = 0;
group1_labels(1:len) = 1;
group2_labels(1:len) = 2;
group3_labels(1:len) = 3;
group4_labels(1:len) = 4;
a = 1;


all_exudate_pixel_count = [ group0_exudate_pixel_count';
                            group1_exudate_pixel_count';
                            group2_exudate_pixel_count';
                            group3_exudate_pixel_count';
                            group4_exudate_pixel_count'];
                        
all_labels = [ group0_labels';
               group1_labels';
               group2_labels';
               group3_labels';
               group4_labels'];
           
           a = 1;
           
      
           

 
 % perform cross validation
num_samples = len * 5;
num_folds = 10;
indices = crossvalind('Kfold',num_samples,num_folds);

all_predictions = zeros(num_samples, 1);

for i = 1:num_folds
    test_mask = (indices == i); 
    train_mask = ~test_mask;

    [test_row,test_col] = find(test_mask == 1);
    [train_row,train_col] = find(train_mask == 1);   
    
    test_pixel_count = all_exudate_pixel_count(test_row);
    train_pixel_count = all_exudate_pixel_count(train_row);
    train_labels = all_labels(train_row);
    
    svm_model = fitcecoc(train_pixel_count, train_labels);    
    test_labels = predict(svm_model, test_pixel_count); 
    
    
    all_predictions(test_row) = test_labels;
    %{
    for ii = 1:size(test_labels)
        index = test_row(ii,1);
        
        all_predictions(index
    end
    %}
end

error_count = compareLabels(all_labels, all_predictions);
a = 1;