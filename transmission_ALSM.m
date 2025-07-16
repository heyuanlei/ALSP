
function [transmission] = transmission_ALSM(S_Vr,AA,r)
[m,n,~] = size(S_Vr);
transmission = zeros(m,n);
Dot_Product = sum(S_Vr.*AA,3);
Dot_Product_sum=boxfilter(Dot_Product, r);
Magnitude_A = sqrt(boxfilter(sum((AA.^2),3),r));
Magnitude_B = (((S_Vr(:,:,1).^2+S_Vr(:,:,2).^2+S_Vr(:,:,3).^2)));
Magnitude_B_sum=sqrt(boxfilter(Magnitude_B, r));
k1 =(sin(acos( Dot_Product_sum ./ (Magnitude_A .* Magnitude_B_sum))));  
% k1 =(sqrt(1-( Dot_Product_sum ./ (Magnitude_A .* Magnitude_B_sum)).^2));  
ss=(sum((S_Vr-AA).^2,3));
k2=sqrt(boxfilter(ss, r)) ./ Magnitude_A;
k=real(k1+k2);
transmission=transmission+k/1;

end


