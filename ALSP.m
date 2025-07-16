function [J,t_final]=ALSP(param,ImageType)
I1=param.image;
[m,n,~] = size(I1);
gamma=param.gamma;
Omega=param.Omega;
% pre-defined hyper-parameters
coff=0.02;
patch_size = round(coff*sqrt(m*n));
dsample=0.2;
tic
% calculate the Ambient light
A = Ambient_light(I1,ImageType);% A is the Ambient light of far region

%%downsample for low computing time
I1_dsample=imresize(I1,dsample);
%%Ambient light for estimating transmission
[m1,n1,~] = size(I1_dsample);
x_AA = reshape(repmat(A,[m1*n1,1]),m1,n1,3);
t1 = real(transmission_ALSM(I1_dsample,x_AA,round(coff*sqrt(m1*n1))));
% mean value as atmospheric light; 
A1 = mean( mean(I1_dsample),2); % A1 is the Ambient light of near region
x_RGB = reshape(repmat(A1,[m1*n1,1]),m1,n1,3);
thr=1;
for step = 1 :5
    %%mean value for estimating transmission
    transmission1 = real(transmission_ALSM(I1_dsample,x_RGB,round(coff*sqrt(m1*n1))));
    ss=t1./transmission1;
    mask  = ss>thr;
    t1_mask=mask.*t1;
    t_sl = reshape(t1_mask(mask),1,[]);
    temp_A=get_near_AL(I1_dsample,t_sl,t1_mask,mask,Omega);
    if step>=1
        %remove sky region effect
        t_l = prctile(t_sl,5);
        t_min = mean(t_sl(t_sl<t_l));
    end
    %mean(sqrt(((temp_A(:)-A1(:)).^2)))
    if mean(sqrt(((temp_A(:)-A1(:)).^2)))>0.03
        A1=temp_A;
    else
        A1=temp_A;
       % step
       break;
   end
    x_RGB = reshape(repmat(A1,[m1*n1,1]),m1,n1,3);
end

mask_full=imresize(mask,[m n]);
mask_full=imgaussfilt(double(mask_full),10*patch_size); 

% % calculate transmission map 
if ImageType==3
    AA = reshape(repmat(A,[m*n,1]),m,n,3);
    transmission = real(transmission_ALSM(I1,AA,patch_size));
    t_final = min(max(transmission, 0.05),0.95);
else
    %refine the ambient light
    AA = reshape(repmat(A1,[m*n,1]),m,n,3).*mask_full+reshape(repmat(A,[m*n,1]),m,n,3).*(1-mask_full);
    transmission = real(transmission_ALSM(I1,AA,patch_size));

    %set low bound for sky region or far region
    transmission_dsample=imresize(transmission,dsample);
    t1_mask=mask.*transmission_dsample;
    t_sl = reshape(t1_mask(mask),1,[]);
    t_l = prctile(t_sl,5);
    t_m = mean(t_sl(t_sl<t_l));
    t1_mask(mask==1)=t_m;
    t1_mask(mask==0)=t_min;
    transmission2=imresize(t1_mask,[m n]);
    transmission=max(transmission2,transmission);
    %avoiding over-exposure
    tm=(I1-AA)./(1-AA+0.01);tm=median(tm,3)+0.02;
    
    % t_final = min(max(transmission, t_min),1);
    t_final = min(max(transmission, tm),0.95);
end

t_final = guidedfilter(rgb2gray(I1),t_final,3*patch_size,0.01); % non-overlapping patches calls for larger patch size in smoothing
J = (I1-AA)./(t_final.^gamma)+AA;
% J(J>1)=1;
J(J<0)=0.01;
toc

end