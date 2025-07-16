function [A] = Ambient_light(image,ImageType)
patch_size= 55; % larger patch size to filter out the local white regions
dark_channel=minfilt2(min(image,[],3),patch_size);
R = image(:,:,1);
G = image(:,:,2);
B = image(:,:,3);
if ImageType==2
    dark_channel=minfilt2(B./(R+0.05),patch_size);
end
[m,n]=size(dark_channel);
number = m * n;
dark_channel_sort=sort(reshape(dark_channel,1,[]),'descend');
threshold=dark_channel_sort(floor(number*0.001));
index=dark_channel>=threshold;
A=ones(1,3);
A(1) = median(R(index));
A(2) = median(G(index));
A(3) = median(B(index));
end

