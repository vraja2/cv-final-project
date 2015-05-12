function [names, labels] = read_labels()
    f = fopen('./training_data/trainLabels.csv');
    parsed = textscan(f,'%s%f','delimiter',',');
    names = parsed{1};
    labels = parsed{2};
end