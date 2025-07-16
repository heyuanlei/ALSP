function A1=get_near_AL(I1_dsample,t_sl,t1_mask,mask,Omega)
    R = I1_dsample(:,:,1);
    G = I1_dsample(:,:,2);
    B = I1_dsample(:,:,3);
    dark_channel_sort=sort(reshape(t_sl,1,[]));
    threshold=dark_channel_sort(floor(length(dark_channel_sort)*Omega*0.01));
    t1_mask(mask==0)=1;
    t_sl = reshape(t1_mask,1,[]);
    index=t_sl<=threshold;
    A1=ones(1,3);
    A1(1) = mean(R(index));
    A1(2) = mean(G(index));
    A1(3) = mean(B(index));
end