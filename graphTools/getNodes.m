%> Name: getInitialNodes
%>
%> Description: When given an image, this function is used to get initial
%> simple nodes by applying Gabor filters over edge mask of the image. Each
%> response peak is considered as a simple feature instance.
%>
%> @param img Input image
%> @param gtFileName An empty param either means the gt for that image is not
%> given, or it is of invalid size and cannot be used. If not empty, feel
%> free to use it in elimination of nodes (given the gt use is enabled in 
%> options).
%> @param options Program options.
%> 
%> @retval nodes The nodes to form further graphs.
%>
%> Author: Rusen
%>
%> Updates
%> Ver 1.0 on 18.11.2013
%> Ver 1.1 on 03.12.2013 Response inhibition added.
%> Ver 1.2 on 12.01.2014 Comment changes to create unified code look.
%> Ver 1.3 on 17.01.2014 GT use implemented.
function [ nodes, smoothedImg ] = getNodes( img, gtFileName, options )
    %% Step 1: Get grayscaled image.
    if size(img,3)>1
        img = rgb2gray(img(:,:,1:3));
    end
    filterCount = numel(options.filters);
    
    %% Get gt info in the form of a mask.
    if options.useGT && ~isempty(gtFileName)
        gtMask = imread(gtFileName);
        if strcmp(options.gtType, 'contour')
            gtMask = imdilate(gtMask, strel('disk', options.contourGTNeighborhood, 8));
        else
            gtMask = imfill(gtMask, 'holes');
        end
    else
        gtMask = ones(size(img(:,:,1))) > 0;
    end
    
    %% Apply denoising to get better responses.
    for bandItr = 1:size(img,3);
        myfilter = fspecial('gaussian',[3 3], 2);
        img(:,:,bandItr) = imfilter(img(:,:,bandItr), myfilter, 'replicate', 'same', 'conv');
        img(:,:,bandItr)=medfilt2(img(:,:,bandItr), [3,3]);
        img = double(img);
    end
    
    %% Get response by applying each filter to the image.
    responseImgs = zeros(size(img,1), size(img,2), filterCount);
  
    %% Low-level feature extraction.
    for filtItr = 1:filterCount
        % Get the filter and convolve with the image.
        currentFilter = double(options.filters{filtItr});
        responseImg = conv2(img, currentFilter, 'same');

        % Save response for future processing
        responseImgs(:,:,filtItr) = responseImg;
    end
    
    %% We apply a minimum response threshold over response image.
    gaborFilterThr = options.gaborFilterThr * max(max(max(responseImgs)));
    responseImgs(responseImgs<max(gaborFilterThr, options.absGaborFilterThr)) = 0;
    
   %% Write smooth object boundaries to an image based on responseImgs.
    smoothedImg = max(responseImgs,[],3);
    smoothedImg = (smoothedImg - min(min(smoothedImg))) / (max(max(smoothedImg)) - min(min(smoothedImg)));
   
   %% Inhibit weak responses in vicinity of powerful peaks.
    inhibitionHalfSize = options.gabor.inhibitionRadius;
    filterSize = options.gaborFilterSize;
    halfSize=floor(filterSize/2);
    responseImgs([1:inhibitionHalfSize, (end-inhibitionHalfSize):end],:) = 0;
    responseImgs(:,[1:inhibitionHalfSize, (end-inhibitionHalfSize):end]) = 0;

    %% Here, we will run a loop till we clear all weak responses.
    peaks = find(responseImgs);
    peakCount = numel(peaks);
    [~, orderedPeakIdx] = sort(responseImgs(peaks), 'descend');
    orderedPeaks = peaks(orderedPeakIdx);
    validPeaks = ones(size(orderedPeaks))>0;
    [xInd, yInd, ~] = ind2sub(size(responseImgs), orderedPeaks);
    for peakItr = 1:(peakCount-1)
       if validPeaks(peakItr)
           nextPeakItr = peakItr+1;
           nearbyPeakIdx = ~(xInd(nextPeakItr:end) >= (xInd(peakItr) - inhibitionHalfSize) & xInd(nextPeakItr:end) <= (xInd(peakItr) + inhibitionHalfSize) & ...
                yInd(nextPeakItr:end) >= (yInd(peakItr) - inhibitionHalfSize) & yInd(nextPeakItr:end) <= (yInd(peakItr) + inhibitionHalfSize));
           validPeaks(nextPeakItr:end) = nearbyPeakIdx & validPeaks(nextPeakItr:end);
       end
    end
    responseImgs(orderedPeaks(~validPeaks)) = 0;

    % Write the responses in the final image.
    responseImgs = double(responseImgs>0);
    for filtItr = 1:filterCount
      responseImgs(:,:,filtItr) = responseImgs(:,:,filtItr) .* filtItr;
    end
    responseImg = sum(responseImgs,3);
    responseImg([1:halfSize, (end-halfSize):end],:) = 0;
    responseImg(:,[1:halfSize, (end-halfSize):end]) = 0;

    %% Eliminate nodes outside GT mask. If gt is not used, this does not have effect.
    responseImg(~gtMask) = 0;

    %% Out of this response image, we will create the nodes and output them.
    finalNodeIdx = find(responseImg);
    nodes = cell(numel(finalNodeIdx), 2);
    for nodeItr = 1:numel(finalNodeIdx)
       [centerX, centerY] = ind2sub(size(responseImg), finalNodeIdx(nodeItr));
       nodes(nodeItr,:) = {responseImg(finalNodeIdx(nodeItr)), round([centerX, centerY])};
    end
end