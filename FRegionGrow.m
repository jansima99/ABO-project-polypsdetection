function [final,areaMean,areaSize] = FRegionGrow(imPrep,x,y)
% This function performs segmentation of polyp in preprocessed RGB 
% colonoscopy image using region growing technique with seed coordinates
% obtained using function FHysThres
% -------------------------------------------------------------------------
% Input: 
% imPrep - input preprocessed RGB image obtained during colonoscopy (after 
% cropping in evaluation function, removal of specular highlights and 
% adjustment of lighting)
%
% x - x coordinate of seed for region growing
% 
% y - y coordinate of seed for region growing
% 
% Output:
% final - final mask of segmented polyp after region growing and final 
% adjustments
% 
% areaMean - mean value of area which is assigned as potential polyp region
% 
% areaSize - size of area which is assigned as potential polyp region
% -------------------------------------------------------------------------
% Authors: Terezie Dobrovolná, Ondřej Nantl, Jan Šíma
% =========================================================================
[m,n,~] = size(imPrep);
% segmenting using red component of an input image
segIm = zeros(size(imPrep(:,:,1)));
% threshold estimated from standard deviation
Trg = 0.8*std(imPrep(:,:,1),[],'all');
% change threshold and segment again until the object is at least of 0.00005 of size on the
% input image
while sum(segIm == 1)< 0.00005*m*n
% segIm = grayconnected(imPrep(:,:,1),seedRow,seedCol,Trg);
segIm = grayconnected(imPrep(:,:,1),y,x,Trg);
Trg = 1.25*Trg;
end

% % segmenting using grayscale image
% imPrepGray = rgb2gray(imPrep);
% segIm = zeros(size(imPrepGray));
% % threshold estimated from standard deviation
% Trg = 0.8*std(imPrepGray,[],'all');
% % change threshold and segment again until the object is at least of 0.00005 of size on the
% % input image
% while sum(segIm == 1)< 0.00005*m*n
% % segIm = grayconnected(imPrep(:,:,1),seedRow,seedCol,Trg);
% segIm = grayconnected(imPrepGray,y,x,Trg);
% Trg = 1.25*Trg;
% end


% final adjustments
% final = imfill(segIm,'holes');
final = bwconvhull(segIm,'objects');

%% features for data analysis
imPrepRed = imPrep(:,:,1);
areaPixels = imPrepRed(final);
areaSize = sum(final(:));
areaMean = mean(areaPixels(:));
%% commented block
% seedRow = randi(size(imPrep,1)); % je nutne vymyslet jak zjistit pozici seminka
% seedCol = randi(size(imPrep,2));
% [~,seedRow] = max(sum(imPrep(:,:,1),2)); % je nutne vymyslet jak zjistit pozici seminka
% [~,seedCol] = max(sum(imPrep(:,:,1),1));
% [~,~,o] = size(imPrep);
% figure;
% for i = 1:o
% segIm(:,:,i) = grayconnected(imPrep(:,:,i),round(y),round(x),0.02); 
% % segIm(:,:,i) = grayconnected(imPrep(:,:,i),y,x,0.02); % pozici definuje Houghova t.
% % segIm(:,:,i) = regiongrowing(imPrep(:,:,i),y,x,0.02); % jina region growing funkce, pozici definuje Houghova t.
% % subplot(1,3,i)
% % imshow(segIm(:,:,i));hold on; plot(x,y,'rx')
% end
% sumRegion = reshape(sum(sum(segIm)),[3 1 1]);
% [~,smallObjChannel] = min(sumRegion);
% final = imfill(segIm(:,:,smallObjChannel),'holes');
% figure
% imshowpair(maskCropped,final)
end
