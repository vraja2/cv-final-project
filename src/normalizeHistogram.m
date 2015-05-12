function norm_sub_hist = normalizeHistogram(sub_hist)
    length = sum(sub_hist);
    norm_sub_hist = sub_hist/length;
end