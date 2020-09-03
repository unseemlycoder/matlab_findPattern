%% Matlab Project 2020
% Pattern / Object Matching
% Visualize SURF features of an image. 
% 
% Created by 
% Akash Murthy    PES2201800266
% Babu Siva Surya PES2201800475

% Clear Workspace
clear all; close all; clc;

%% Load reference image, and compute surf features
ref_img = imread('pattern.jpg');
ref_img_gray = rgb2gray(ref_img);
ref_pts = detectORBFeatures(ref_img_gray);
[ref_features,  ref_validPts] = extractFeatures(ref_img_gray,  ref_pts);

figure; imshow(ref_img);
hold on; plot(ref_pts.selectStrongest(50));
%pause
%% Visual 25 SURF features
figure;
subplot(5,5,3); title('First 25 Features');
for i=1:25
    scale = ref_pts(i).Scale;
    image = imcrop(ref_img,[ref_pts(i).Location-10*scale 20*scale 20*scale]);
    subplot(5,5,i);
    imshow(image);
    hold on;
    rectangle('Position',[5*scale 5*scale 10*scale 10*scale],'Curvature',1,'EdgeColor','g');
end
%pause
%% Compare to video frame

%image = imread('main.jpg');   %Image with pattern/object
image = imread('main.jpg'); %Image without pattern/object
I = rgb2gray(image);

% Detect features
I_pts = detectORBFeatures(I);
[I_features, I_validPts] = extractFeatures(I, I_pts);
figure;imshow(image);
hold on; plot(I_pts.selectStrongest(50));
%pause
%% Compare card image to video frame
index_pairs = matchFeatures(ref_features, I_features);

ref_matched_pts = ref_validPts(index_pairs(:,1)).Location;
I_matched_pts = I_validPts(index_pairs(:,2)).Location;

figure, showMatchedFeatures(image, ref_img, I_matched_pts, ref_matched_pts, 'montage');
title('Showing all matches');
%pause
%% Define Geometric Transformation Objects
try %Test this block of code for pattern matches
    [tform,inlierPtsDistorted,inlierPtsOriginal] = estimateGeometricTransform(I_matched_pts,ref_matched_pts,'affine');
    figure; 
    showMatchedFeatures(ref_img,image,...
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
%pause
%% Crop Object / Pattern from Actual Image

outputView = imref2d(size(ref_img));
Ir = imwarp(image,tform,'OutputView',outputView);
figure; 
%imshow(Ir); 
imshowpair(Ir, ref_img, 'montage')
title('Recovered image');
h = msgbox('Pattern / Object found!','Success');
set(h, 'position', [400 440 180 50]); %makes box bigger
ah = get( h, 'CurrentAxes' );
ch = get( ah, 'Children' );
set( ch, 'FontSize', 16 ); %makes text bigger