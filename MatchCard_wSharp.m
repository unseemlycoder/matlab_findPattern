%% Copyright 2011-2013 The MathWorks, Inc.
% Pattern / Object Matching
% Visualize SURF features of an image. 
% 
% Created by 
% Akash Murthy    PES2201800266
% Babu Siva Surya PES2201800475

% Clear Workspace
clear all; close all; clc;

%% Load reference image, and compute surf features
ref_img = im2double(imread('pattern.jpg'));
lap = [-1 -1 -1; -1 8 -1; -1 -1 -1]; %// Change - Centre is now positive
res = imfilter(ref_img, lap, 'conv'); %// Change

%// Change - Normalize the response image
minR = min(res(:));
maxR = max(res(:));
res = (res - minR) / (maxR - minR);

%// Change - Adding to original image now
sharpPattern = ref_img + res;

%// Change - Normalize the sharpPattern result
minA = min(sharpPattern(:));
maxA = max(sharpPattern(:));
sharpPattern = (sharpPattern - minA) / (maxA - minA);

%// Change - Perform linear contrast enhancement
sharpPattern = imadjust(sharpPattern, [60/255 200/255], [0 1]);

ref_img_gray = rgb2gray(sharpPattern);
ref_pts = detectSURFFeatures(ref_img_gray);
[ref_features,  ref_validPts] = extractFeatures(ref_img_gray,  ref_pts);

figure; imshow(sharpPattern);
hold on; plot(ref_pts.selectStrongest(50));

%% Visual 25 SURF features
figure;
subplot(5,5,3); title('First 25 Features');
for i=1:25
    scale = ref_pts(i).Scale;
    image = imcrop(sharpPattern,[ref_pts(i).Location-10*scale 20*scale 20*scale]);
    subplot(5,5,i);
    imshow(image);
    hold on;
    rectangle('Position',[5*scale 5*scale 10*scale 10*scale],'Curvature',1,'EdgeColor','g');
end

%% Compare to video frame
image = im2double(imread('main.jpg'));
lap = [-1 -1 -1; -1 8 -1; -1 -1 -1]; %// Change - Centre is now positive
resp = imfilter(image, lap, 'conv'); %// Change

%// Change - Normalize the response image
minR = min(resp(:));
maxR = max(resp(:));
resp = (resp - minR) / (maxR - minR);

%// Change - Adding to original image now
sharpMain = image + resp;

%// Change - Normalize the sharpPattern result
minA = min(sharpMain(:));
maxA = max(sharpMain(:));
sharpMain = (sharpMain - minA) / (maxA - minA);

%// Change - Perform linear contrast enhancement
sharpMain = imadjust(sharpMain, [60/255 200/255], [0 1]);

   %Image with pattern/object
%image = imread('clean.jpg'); %Image without pattern/object
I = rgb2gray(sharpMain);

% Detect features
I_pts = detectSURFFeatures(I);
[I_features, I_validPts] = extractFeatures(I, I_pts);
figure;imshow(sharpMain);
hold on; plot(I_pts.selectStrongest(50));

%% Compare card image to video frame
index_pairs = matchFeatures(ref_features, I_features);

ref_matched_pts = ref_validPts(index_pairs(:,1)).Location;
I_matched_pts = I_validPts(index_pairs(:,2)).Location;

figure, showMatchedFeatures(sharpMain, sharpPattern, I_matched_pts, ref_matched_pts, 'montage');
title('Showing all matches');

%% Define Geometric Transformation Objects
try %Test this block of code for pattern matches
    [tform,inlierPtsDistorted,inlierPtsOriginal] = estimateGeometricTransform(I_matched_pts,ref_matched_pts,'affine');
    figure; 
    showMatchedFeatures(sharpPattern,sharpMain,...
        inlierPtsOriginal,inlierPtsDistorted);
    title('Matched inlier points');
catch %If low matches error is caught here
    h = msgbox('Pattern / Object not found!','Fail');
    set(h, 'position', [400 440 195 50]); %makes box bigger
    ah = get( h, 'CurrentAxes' );
    ch = get( ah, 'Children' );
    set( ch, 'FontSize', 15 ); %makes text bigger
    return %Exit program
end

%% Crop Object / Pattern from Actual Image

outputView = imref2d(size(sharpPattern));
Ir = imwarp(sharpMain,tform,'OutputView',outputView);
figure; 
%imshow(Ir); 
imshowpair(Ir, sharpPattern, 'montage')
title('Recovered image');
h = msgbox('Pattern / Object found!','Success');
set(h, 'position', [400 440 180 50]); %makes box bigger
ah = get( h, 'CurrentAxes' );
ch = get( ah, 'Children' );
set( ch, 'FontSize', 16 ); %makes text bigger