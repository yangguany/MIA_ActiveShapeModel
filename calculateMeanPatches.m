function [meanpatches] = calculateMeanPatches(copo, images)
    h = fspecial('sobel');
    [~,npoints,nimages] = size(copo);
    meanpatches = zeros(15,15,npoints);
    for currentpoint = 1:npoints
        for currentimage = 1:nimages
            point = round(copo(:,currentpoint, currentimage));
            image = images(:,:,currentimage);
            patch = image((point(2)-7):(point(2)+7),(point(1)-7):(point(1)+7));
            X = double(imfilter(patch,h, 'same', 'replicate')).^2;
            Y = double(imfilter(patch,h', 'same', 'replicate')).^2;
            tmp_patch = sqrt(X+Y);  
            meanpatches(:,:,currentpoint) = meanpatches(:,:,currentpoint) + tmp_patch;
        end
    end
    meanpatches = meanpatches./nimages;
%     for k = 1:npoints
%         figure;
%         imagesc(meanpatches(:,:,k));
%     end
end