function [J,transmission] = Processing_ALSP(image,ImageType)
    if ImageType == 1
        %%%% the hazy image   
        param.image = im2double(image);
        param.gamma = 1;
        %Increase Omega for preventing over-enhancement, for naturally, [5,50] is suggested
        param.Omega=2;
        [J,transmission]=ALSP(param,ImageType);
    elseif ImageType == 2
        %%%% The underwater image 
        param.image = (im2double(image));
        param.gamma = 0.9;
        %Increase Omega for preventing over-enhancement, for naturally, [5,50] is suggested
        param.Omega=20;
        [J,transmission]=ALSP(param,ImageType);
        %color correct
        J=whitebalance(J);
        mi = prctile2019(J,1,[1 2]);
        ma = prctile2019(J,99,[1 2]);
        J = ( J - mi)./(ma-mi);
        J=whitebalance(J);
    elseif ImageType == 3
        %%%% the low light image   
        param.image = 1-im2double(image)+0.01;
        param.gamma = 0.9;
        param.Omega=20;
        [J,transmission]=ALSP(param,ImageType);
        J=1-J;
    end
end
