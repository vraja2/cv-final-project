function showConfusionMatrix(predictions, truths, labelCount)
    confusion = zeros([labelCount, labelCount]);
    for trueLabel = 1:labelCount
        indices = find(truths == trueLabel);
        for j = indices
            predictedLabel = predictions(j);
            confusion(trueLabel, predictedLabel) = confusion(trueLabel, predictedLabel) + 1;
        end
    end
    imagesc(confusion), colorbar;
end
