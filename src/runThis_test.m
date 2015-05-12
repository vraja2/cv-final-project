function main()

%{    
    [img_h, img_w, img_d] = size(img);

    vec_img = double(reshape(img, [img_h * img_w, img_d]));

    vec_img_r = vec_img(:,1);
    vec_img_g = vec_img(:,2);
    vec_img_b = vec_img(:,3);
%}

  
    %{
    rh = histc(vec_img_r, 0:255);
    gh = histc(vec_img_g, 0:255);
    bh = histc(vec_img_b, 0:255);
%}
    %{
    img = imread('4130_left.jpeg');
    img2 = imread('4793_left.jpeg'); 

    Hadj = HistNorm(img,img2);
    image(Hadj);
    a = 1;
    %}
    
    
    img = imread('4130_left.jpeg');
    img2 = imread('4793_left.jpeg'); 
    
 %   [vec_img_r, vec_img_g, vec_img_b] = get_rgb(img);
 %   [rh, gh, bh] = get_color_hist(vec_img_r, vec_img_g, vec_img_b);
    
    a = 1;

    figure;
    imagesc(img2);
    [img2_h, img2_w, img2_c] = size(img2);
    
 %   [vec_img2_r, vec_img2_g, vec_img2_b] = get_rgb(img2);
 %   [rh2, gh2, bh2] = get_color_hist(vec_img2_r, vec_img2_g, vec_img2_b);
 
 
    vec_img2 = reshape(img2, [img2_w * img2_h, img2_c]);
    vec_img2_inten = sum(vec_img2, 3);
    
    [row, col] = find(vec_img2_inten == 0);
    
    new_img2 = imhistmatch(img2, img);
 
    figure;
    imagesc(new_img2);
    
    vec_new_img2 = map_to_vec(new_img2, img2_h, img2_w);
    vec_new_img2(row,1) = 0;
    vec_new_img2(row,2) = 0;
    vec_new_img2(row,3) = 0;
    
    new_img2 = vec_to_map(vec_new_img2, img2_h, img2_w);
    
    figure;
    imagesc(new_img2);
    %{   
    new_img2_r = imhistmatch(vec_img2_r, vec_img_r);
    new_img2_g = imhistmatch(vec_img2_g, vec_img_g);
    new_img2_b = imhistmatch(vec_img2_b, vec_img_b);
   %} 
    
%    new_img2_r = histeq(vec_img2_r, rh);
 %   new_img2_g = histeq(vec_img2_g, gh);
 %   new_img2_b = histeq(vec_img2_b, bh);
    
 %   new_img2 = [new_img2_r new_img2_g new_img2_b];

    
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

