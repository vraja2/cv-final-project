function ConfMx = buildConfusionMatrix(test_labels,predicted_labels)
    ConfMx = zeros(5,5);
    for i=1:length(test_labels)
      ConfMx(test_labels(i)+1,predicted_labels(i)+1) = ConfMx(test_labels(i)+1,predicted_labels(i)+1) + 1;
    end
    figure,imagesc(ConfMx), colorbar;
    sum(trace(ConfMx))/sum(sum(ConfMx))
end
