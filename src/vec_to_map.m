function img_map = vec_to_map(vec_img, img_h, img_w)

    img_map = reshape(vec_img, [img_h, img_w, 3]);
    
end