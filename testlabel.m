t  = Tiff('43.tiff');
imdata = read(t); close(t);
patch_trans = 1;
border_val = 20;
add_border = 0;
space_pixel = 1;
space_pixel_val = 1;
alpha = 0.5;
resize_img_label = 0;
bRGBVal = [0,0,0];
fRGBVal = [1,1,1];
iout = labelimg(imdata, 'Hello World', 1, patch_trans, add_border ,border_val, space_pixel, space_pixel_val, alpha, resize_img_label, bRGBVal, fRGBVal);
imshow(iout);