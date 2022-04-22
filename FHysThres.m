function [x,y,areaMean,areaSize]  = FHysThres(imPrep)
% This function performs extraction of seed coordinates for region growing
% from preprocessed RGB colonoscopy image using hysteresis thresholding and
% finding centroid of biggest obtained object
% -------------------------------------------------------------------------
% Input: 
% imPrep - input preprocessed RGB image obtained during colonoscopy (after 
% cropping in evaluation function, removal of specular highlights and 
% adjustment of lighting)
%
% Output:
% x - x coordinate of seed for region growing
% 
% y - y coordinate of seed for region growing
% 
% areaMean - mean value of area which is assigned as potential polyp region
% 
% areaSize - size of area which is assigned as potential polyp region
% -------------------------------------------------------------------------
% Authors: Terezie Dobrovolná, Ondřej Nantl, Jan Šíma
% =========================================================================
imPre = rgb2gray(im2double(imPrep));% converting input image into grayscale
thresholds = multithresh(imPre,2); % obtaining thresholds using Otsu method
T1 = thresholds(2);
T2 = thresholds(1);
h=hyst_thresh(imPre,T1,T2); % hysteresis thresholding using downloaded function

% finding the centroid of largest segmented object using region properties 
centers = regionprops(h);
loc = find(max([centers.Area]));
positions = centers(loc).Centroid;
x = round(positions(1));
y = round(positions(2));
% figure
% imshow(imPrep.*~h,[])
% hold on
% plot(x,y,'r+','LineWidth',20)
%% features for data analysis
h2 = bwareafilt(h,1);
areaPixels = imPre(h2);
areaSize = sum(h2(:));
areaMean = mean(areaPixels(:));

end