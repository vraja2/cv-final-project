function layer = getPyramidLayer(im, layerLevel, bins)
    [rows, cols, ~] = size(im); % assume rows == cols...
    dimCells = 2^layerLevel;
    layer = cell(dimCells, dimCells);
    slices = round(linspace(1, rows, dimCells + 1));
    for i = 1:dimCells
        rows = slices(i):slices(i+1);
        for j = 1:dimCells
            cols = slices(j):slices(j + 1);
            [r, g, b] = getColorHistogram(im(rows, cols, :), bins);
            layer{i, j} = [r; g; b];
        end
    end
end