function [binaryMap] = detectPolyps(inputImage,bEdgeMask)
% UNTITLED Summary of this function goes here
% Detailed explanation goes here
% 
% Authors: Ondřej Nantl, Terezie Dobrovolná, Jan Šíma
% =========================================================================
%% elimination of specular highlights and correction of variant lighting
% % elimination of specular highlights
% pm = rangefilt(rgb2gray(inputImage),true(7));
% T = graythresh(pm);
% reflMask = imbinarize(imfill(pm,'holes'),T);
% imCropped = inpaintCoherent(inputImage,logical((~bEdgeMask).*reflMask),'SmoothingFactor',5,'Radius',5);
% 
% % correction of variant lighting
% [m,n,o] = size(imCropped);
% mm = zeros(m,n,o);
% N = 20;
% meanMask = 1/(N^2).*ones(N,N);
% for j = 1:o
%     mm(:,:,j) = 0.3.*conv2(imCropped(:,:,j),meanMask,'same'); % slight change in constant compared to Sanchez2018
% end
% imPrep = imCropped - mm;
% imPrepLab = rgb2lab(imPrep);
% imPrepGray = rgb2gray(imPrep);
% % %% hysteresis thresholding
% % BW = hysthresh(imPrepLab(:,:,2),0.75*max(imPrepLab(:,:,2),[],'all'),0.65*max(imPrepLab(:,:,2),[],'all'));
% % % BW = imerode(BW,strel('disk',2));
% % props = regionprops(BW,'Area','Centroid','Circularity','ConvexHull','ConvexImage','FilledImage','MajorAxisLength','MinorAxisLength');
% % [~,idx] = sort([props.Area]);
% % biggest = idx(1) ;
% % seedRow = round(props(biggest).Centroid(2));
% % seedCol = round(props(biggest).Centroid(1));
% % if (props(biggest).Area>0.4*m*n) && length(props)>1
% %     sbiggest = idx(2);
% %     seedRow = round(props(sbiggest).Centroid(2));
% %     seedCol = round(props(sbiggest).Centroid(1));
% % end
% % segIm = grayconnected(imPrepGray,seedRow,seedCol,0.1*std(imPrepGray,[],'all'));
% % % segIm = grayconnected(imPrepLab(:,:,2),seedRow,seedCol,0.5*std(imPrepGray,[],'all'));
% % binaryMap = imfill(segIm,'holes');
% 
% 
% %% Hough transform for circles
% imEdge = edge(rgb2gray(imPrep),'canny',[.03 .1],sqrt(2)); % constants set according to Sanchez2018
% rs = 5:40; % range of diameters
% HS = zeros(size(imPrep,1),size(imPrep,2),length(rs));
% r_ind = 1;
% [X,Y] = find(imEdge == 1);
% for r = rs
%     tmp_c = gen_circle(r);
%     for i = 1:length(X)
%         c1 = X(i);
%         c2 = Y(i);
%         if c1 > r && c1< (size(imPrep,1) - r)
%             if c2 > r && c2< (size(imPrep,2) - r)
%                 HS((c1-r):(c1+r),(c2-r):(c2+r),r_ind) = HS((c1-r):(c1+r),(c2-r):(c2+r),r_ind)+tmp_c;
%             end
%         end
%     end
%     r_ind = r_ind + 1;
% end
% % finding the center of the most probable circle in edge representation
% [linInd] = find(HS == max(HS,[],'all'),1,'first');
% [y,x,r] = ind2sub(size(HS),linInd); 
% 
% % if length(x)>1 || length(y)>1
% %     x = floor(mean(x));
% %     y = floor(mean(y));
% % end
% % 
% %% region growing
% for i = 1:o
% segIm(:,:,i) = grayconnected(imPrep(:,:,i),y,x,0.1*std(imPrepGray,[],'all')); % position is defined by Hough t.
% end
% sumRegion = reshape(sum(sum(segIm)),[3 1 1]);
% [~,smallObjChannel] = min(sumRegion);
% binaryMap = imfill(segIm(:,:,smallObjChannel),'holes');
% % %% geometric contours
% % % finding the smallest object in 3 results of region growing
% % sumRegion = reshape(sum(sum(segIm)),[3 1 1]);
% % [~,smallObjChannel] = min(sumRegion);
% % % level sets
% % binaryMap = activecontour(rgb2gray(imCropped),imdilate(segIm(:,:,smallObjChannel),[1 1 1; 1 1 1; 1 1 1]));

%% Method with hysteresis thresholding and Region Growing

inputImage=FClear(inputImage,bEdgeMask);
imPrep = FLight(inputImage);
[x,y]  = FHysThres(imPrep);
binaryMap = FRegionGrow(imPrep,x,y);

end

