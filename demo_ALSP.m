% TIP'25,  ALSP+: Fast Scene Recovery via Ambient Light Similarity Prior
% DEMO of ALSP; Matlab 2019b and higher verision
% @ ImageType is the type of the input image
% @ 1: hazy image; 
% @ 2: underwaterimage;
% @ 3: low light image;      
% clear
I = im2double(imread('./images/13.png'));
ImageType= 3;
[J,transmission] = Processing_ALSP(I,ImageType);
figure,imshow(J);


