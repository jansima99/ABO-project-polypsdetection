function [resultCell,Se,PPV,diceCoef,IoU,P,N,imList] = polypsEval(datasetPath)
% This function can be used for evaluating the performance of polyp
% detection/segmentation algorithm
% 
% All black edges in images are cropped, then evaluated using our detection
% and segmentation method a the performance of our method is evaluated
% using sensitivity, positive predictive value (both for object-wise
% evaluation), IoU and Dice coefficient (metrics for evaluation of
% segmentation)
% 
% Input:
% datasetPath - complete pathway to folders with original images in folder
% Original and ground truth masks in folder Ground Truth
% 
% Output:
% resultCell - cell array containing all binary masks as an output of our 
% algorithm - one row corresponds one input image
% 
% Se - calculated sensitivity as decimal number
% 
% PPV - calculated positive predictive value as decimal number
% 
% IoU - numeric array containing calculated value of Intersection over
% Union for every input image individually
% 
% diceCoef - numeric array containing calculated value of Sorensen-Dice
% coefficient for every input image individually
% 
% P - the ratio between positive pixels in both masks and the number of
% positive pixels in GT mask
% 
% N - the ratio between negative pixels in both masks and the number of
% positive pixels in GT mask
% 
% imList - list of images in the dataset
% -------------------------------------------------------------------------
% Authors: Ondřej Nantl, Terezie Dobrovolná, Jan Šíma
% =========================================================================
% Gaining the names of images  - original and ground truth
imDS = imageDatastore([datasetPath '\Original'],'ReadFcn', @read2double);%,'ReadFcn', @read2gray
groundTruthDS = imageDatastore([datasetPath '\Ground Truth']);

% Obtaining information about dimensions of input images and their count
% imForDim = size(imread(imDS.Files{1}));
numImages = size(imDS.Files,1);

% resultDataMatrix = double(zeros(imForDim(1),imForDim(2),numImages));
resultCell = cell(numImages,1);
diceCoef = zeros(numImages,1);
IoU = zeros(numImages,1);
TP = 0; FP = 0; FN = 0;

for imIter = 1:numImages
    % loading one image and its ground truth mask
    image = readimage(imDS,imIter);
    GT = im2double(readimage(groundTruthDS,imIter));
    GT(GT<1) = 0;
    % displaying the progress
    if mod(imIter,10) == 0
        disp(imIter)
    end
    % cropping of the black frame
    clear bEdgeMask bEdgeMask2 bEdgeMask3 imCropped imCroppedRow GTCropped GTCroppedRow
    imHSV = rgb2hsv(image); % transfer into HSV color space
    bEdgeMask = (imHSV(:,:,3) <= 0.2); % obtaining mask of black edge
    newRowCount = 0;
    % cropping the rows which are only dark 
    for i = 1:size(bEdgeMask,1)
        if any(bEdgeMask(i,:) ~= 1)
            newRowCount = newRowCount + 1;
            bEdgeMask2(newRowCount,:) = bEdgeMask(i,:);
            imCroppedRow(newRowCount,:,:) = image(i,:,:);
            GTCroppedRow(newRowCount,:) = GT(i,:);
        end
    end
    newColCount = 0;
    % cropping the colums which are only dark 
    for j = 1:size(bEdgeMask2,2)
        if any(bEdgeMask2(:,j) ~= 1)
            newColCount = newColCount + 1;
            bEdgeMask3(:,newColCount) = bEdgeMask2(:,j);
            imCropped(:,newColCount,:) = imCroppedRow(:,j,:);
            GTCropped(:,newColCount) = GTCroppedRow(:,j);
        end
    end
    % analysis of the image using our algorithm
    % this is important
    %     resultDataMatrix(:,:,imIter) = detectPolyps(imCropped,bEdgeMask3);
    resultCell{imIter} = detectPolyps(imCropped,bEdgeMask3);

    %     figure(1)
    %     imshow(imCropped.*resultCell{imIter})
    % evaluation of our algorithm using Dice and Jaccard (IoU) coefficients
%     diceCoef(imIter) = dice(resultDataMatrix(:,:,imIter),GTCropped);
%     IoU(imIter) = jaccard(resultDataMatrix(:,:,imIter),GTCropped);
    diceCoef(imIter) = dice(resultCell{imIter},logical(GTCropped));
    IoU(imIter) = jaccard(resultCell{imIter},logical(GTCropped));
%     resultCC = bwconncomp(resultCell{imIter});
%     GTCC = bwconncomp(logical(GTCropped));
    % classifing detection with object-wise approach 
    if IoU(imIter) > .5 % threshold can be changed
        TP = TP + 1;
    else
        if any(any(logical(GTCropped)>0)) && all(all(resultCell{imIter} == 0))
            FN = FN + 1;
        else
            FP = FP + 1;
        end
    end
    % Honza pokus
    new = resultCell{imIter}+logical(GTCropped);
    prekryv = sum(new==2);
    mimo = sum(new==0);
    maska = sum(logical(GTCropped)==1);
    maska2 = sum(logical(GTCropped)==0);
    P{imIter} = prekryv/maska;
    N{imIter} = mimo/maska2;
end
% estimating the pixelwise and objectwise performance metrics
P = mean(cell2mat(P));
N = mean(cell2mat(N));
Se = TP/(TP + FN);
PPV = TP/(TP + FP);
imList = imDS.Files;
end

function image = read2double(path)
image = im2double(imread(path));
end

% function image = read2gray(path)
%     image = rgb2gray(im2double(imread(path)));
% end

