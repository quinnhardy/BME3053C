% BME3053C Final Project - Cellular Gators
% Author: Kevin Li, Quinn Hardy, Lauren Snider
% Group Members: Kevin Li, Quinn Hardy, Lauren Snider
% Course: BME 3053C Computer Applications for BME 
% Term: Spring 2021
% J. Crayton Pruitt Family Department of Biomedical Engineering
% University of Florida
% Email: yli2@ufl.edu, quinnhardy@ufl.edu, lsnider@ufl.edu
% April 16, 2021

clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 22;
%=============================================================================

%% make a directory to save the images/subplots
mkdir('SavedSubplots')
mkdir('SavedDead')
mkdir('SavedTotal')

%===============================================================================
% Prior to using this code, you must use ImageJ to split the channels of
% each stain (blue or green), calculate the appropriate threshold values,
% and save the respective grayscale image to a folder to read in here

%% UPDATE THIS SECTION FOR EVERY RUN
% change the name of the new excel doc
% change the columns from A3:A# depending on the number of images
folder = pwd;
% read in the blue stained image of interest
excelname = 'LiveDead_ITO_0925.xlsx';
[~, name] = xlsread(excelname, 'Sheet1', 'A3:A4'); % read in the names of the images

%% make sure that the sheet you are reading in is titled Sheet1

threshold = xlsread(excelname, 'Sheet1'); % read in the high and low threshold values

amountOfimages = size(threshold);
halfOfimages = amountOfimages(1,1)/2;
averageintensity = zeros(halfOfimages,1);

for m = 1:halfOfimages
    odd = 2*m-1;
    even = 2*m;
    
    % read in all input information
    greenFileName(m,1) = name(odd);
    blueFileName(m,1) = name(even);
    greenThresholdLow(m,1) = threshold(odd,1);
    blueThresholdLow(m,1) = threshold(even,1);
    greenThresholdHigh(m,1) = threshold(odd,2);
    blueThresholdHigh(m,1) = threshold(even,2);
    
    % call the split channel blue of the blue image
    baseFileName = char(blueFileName(m,1));
    % Get the full filename, with path prepended.
    fullFileName = fullfile(folder, baseFileName);
    blueImage = imread(fullFileName);
    % Get the dimensions of the image.  
    % numberOfColorBands should be = 1 bc its already split
    [rows, columns, numberOfColorBands] = size(blueImage);
    if numberOfColorBands > 1
        % It's not really gray scale like we expected - it's color.
        % Convert it to gray scale by taking only the green channel.
        %grayImage = grayImage(:, :, 2); % Take green channel.  
        fprintf('Need to split channels first')
    end
   
    % Display the original gray scale blue image.
    figure
    subplot(2, 3, 1);
    imshow(blueImage, []);
    axis on;
    title('Grayscale Image (Blue Channel)', 'FontSize', fontSize);    
    %===============================================================================
    % Threshold (binarize) the image.
    thresholdValue1 = blueThresholdLow(m,1);
    thresholdValue2 = blueThresholdHigh(m,1);
    binaryImageblue = zeros(size(blueImage));
    for i = 1:rows
        for j = 1:columns
            if blueImage(i,j) >= thresholdValue1 && blueImage(i,j) <= thresholdValue2
                binaryImageblue(i,j) = blueImage(i,j); % Do the thresholding.
            else
                binaryImageblue(i,j) = 0;
            end
        end
    end
    
    % Display the binary image.
    subplot(2, 3, 2);
    imshow(binaryImageblue, []);
    axis on;
    title('Thresholded Blue', 'FontSize', fontSize);
    
    %% read in the green image
    baseFileNametwo = char(greenFileName(m,1)); %split green channel on green image beforehand

    fullFileNametwo = fullfile(folder, baseFileNametwo);

    % read in the green grayscale image to a matrix
    greenImage = imread(baseFileNametwo);

    % make sure that the image has been split prior to reading it in
    [rows, columns, numberOfColorBands] = size(greenImage);
    if numberOfColorBands > 1
        % It's not really gray scale like we expected - it's color.
        % Convert it to gray scale by taking only the green channel.
        %grayImage = grayImage(:, :, 2); % Take green channel.  
        fprintf('Need to split channels first')
    end

    % Display the original gray scale green image.
    subplot(2, 3, 4);
    imshow(greenImage, []);
    axis on;
    title('Grayscale Image (Green Channel)', 'FontSize', fontSize);
    %drawnow;
    % Enlarge figure to full screen.
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    % Give a name to the title bar.
    set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off') 
    
    %===============================================================================
    % Threshold (binarize) the image.
    thresholdValue1 = greenThresholdLow(m,1);
    thresholdValue2 = greenThresholdHigh(m,1);   
    binaryImagegreen = zeros(size(greenImage));
    [r2,c2,b2]=size(greenImage);
    if rows~=r2 || columns~=c2
     fprintf('The %f which is %s image set does not have same size for blue and green channels\n',m,baseFileNametwo)
    end
    for i = 1:rows
        %rows * columns is the size of the image
        for j = 1:columns
            if greenImage(i,j) >= thresholdValue1 && greenImage(i,j) <= thresholdValue2
                binaryImagegreen(i,j) = greenImage(i,j); % Do the thresholding.
            else
                binaryImagegreen(i,j) = 0;
            end
        end
    end
    
    % Display the binary image.
    subplot(2, 3, 5);
    imshow(binaryImagegreen, []);
    axis on;
    title('Thresholded Green', 'FontSize', fontSize);

    % mask the thresholded green onto the thresholded blue (we want blue)
    DeadExtract = zeros(rows,columns);

    for i = 1:rows
        for j = 1:columns
            if binaryImagegreen(i,j) ~= 0
                DeadExtract(i,j) = 0;
            else
                DeadExtract(i,j) = binaryImageblue(i,j);
            end
        end
    end

    % Display the dead cells
    subplot(2, 3, 6);
    imshow(DeadExtract, []);
    axis on;
    title('Dead Cells', 'FontSize', fontSize);

    % Display the total cells
    subplot(2, 3, 3);
    imshow(binaryImageblue, []);
    axis on;
    title('Total Cells', 'FontSize', fontSize);

    %name the saved subplot figure
    subplotfiles = ['subplot' num2str(m) '.tif'];
    set(gcf, 'visible', 'off')
    cd('SavedSubplots')
    print(subplotfiles, '-dpng','-r100')
    cd('../')
    
    %Trim extension
    baseFileName_trim = baseFileName(1:strfind(baseFileName,'.')-1);
    
    %Save dead images
    cd('SavedDead')
    deadfilename=strcat(baseFileName_trim,'_dead.jpg');
    imwrite(DeadExtract,deadfilename);
    cd('../')
    
    %Save total images
    cd('SavedTotal')
    livefilename=strcat(baseFileName_trim,'_total.jpg');
    imwrite(binaryImageblue,livefilename);
    cd('../')
end