function o=whitebalance(img)
Ir = img(:,:,1);
Ig = img(:,:,2);
Ib = img(:,:,3);

Ir_mean = mean(Ir(:));
Ig_mean = mean(Ig(:));
Ib_mean = mean(Ib(:));
% A=A(:);
% Ir_mean = A(1);
% Ig_mean = A(2);
% Ib_mean = A(3);
%% Color compensation
alpha = 0.2;
Irc = Ir + alpha*(Ig_mean - Ir_mean);
alpha = 0.5; % 0 does not compensates blue channel. 

Ibc = Ib + alpha*(Ig_mean - Ib_mean);

%% White Balance

I = cat(3, Irc, Ig, Ibc);
I_lin = rgb2lin(I);
percentiles = 5;
illuminant = illumgray(I_lin,percentiles);
I_lin = chromadapt(I_lin,illuminant,'ColorSpace','linear-rgb');
o = lin2rgb(I_lin);
end