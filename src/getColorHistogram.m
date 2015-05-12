function [r, g, b] = getColorHistogram(im, bins)
    [rows, cols, ~] = size(im);
    count = rows * cols;
    im = reshape(im, [count, 3]);
    % for hist()
    bounds = linspace(0, 255, bins + 1);
    width = bounds(2) - bounds(1);
    center = bounds(1:bins) + 0.5 * width;
    
    r = hist(im(:, 1), center) / count;
    g = hist(im(:, 2), center) / count;
    b = hist(im(:, 3), center) / count;
end

