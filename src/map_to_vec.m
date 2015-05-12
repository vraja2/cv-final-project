function vec_img = map_to_vec(img_map, img_h, img_w, dim)

    vec_img = reshape(img_map, [img_h * img_w, dim]);

end