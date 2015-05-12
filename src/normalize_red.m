function output_img = normalize_red(input_img)

    
    ref_img = imread('4130_left.jpeg');
%    input_img = imread('4793_left.jpeg'); 
    
    img2 = input_img;

    [img2_h, img2_w, img2_c] = size(img2);
 
 
    vec_img2 = reshape(img2, [img2_w * img2_h, img2_c]);
    vec_img2_inten = sum(vec_img2, 3);
    
    [row, col] = find(vec_img2_inten <=20);
    
    new_img2 = imhistmatch(img2, ref_img);
 
%    figure;
%    imagesc(new_img2);
    
    vec_new_img2 = map_to_vec(new_img2, img2_h, img2_w);
    vec_new_img2(row,1) = 0;
    vec_new_img2(row,2) = 0;
    vec_new_img2(row,3) = 0;
    
    new_img2 = vec_to_map(vec_new_img2, img2_h, img2_w);
    
%    figure;
%    imagesc(new_img2);
    
    
    output_img = new_img2;
    
end


function img_map = vec_to_map(vec_img, img_h, img_w)

    img_map = reshape(vec_img, [img_h, img_w, 3]);
    
end

function vec_img = map_to_vec(img_map, img_h, img_w)

    vec_img = reshape(img_map, [img_h * img_w, 3]);

end

function [Hadj] = HistNorm( Rim, Him, chan )
  if nargin > 2
    R = histc(reshape(Rim(:,:,chan),1,[]), 0:255);
    H = histc(reshape(Him(:,:,chan),1,[]), 0:255);
    Rc = cumsum(R);
    Hc = cumsum(H);      
    Hmap = arrayfun( @(val) find(Rc >= val, 1), Hc, 'UniformOutput', false)
    Hadj = uint8(Hmap(Him(:,:,chan)+1)-1);
  else
    Hadj = uint8(zeros(size(Him)));
    for c = 1:3
      Hadj(:,:,c) = HistNorm( Rim, Him, c );
    end
  end
end






function [rs, gs, bs] = get_rgb(img)
    [img_h, img_w, img_d] = size(img);
    vec_img = (reshape(img, [img_h * img_w, img_d]));

    rs = vec_img(:,1);
    gs = vec_img(:,2);
    bs = vec_img(:,3);
end

% http://www.mathworks.com/matlabcentral/answers/35227-how-to-normalize-two-images-which-have-different-lighting-conditions
function [rh, gh, bh] = get_color_hist(vec_r, vec_g, vec_b)
    
    rh = histc(vec_r, 0:255);
    gh = histc(vec_g, 0:255);
    bh = histc(vec_b, 0:255);

end

