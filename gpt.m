% MATLAB implementation of abandoned object detection
% Dependencies: Computer Vision Toolbox
clc
close all
clear all
% Load the video
videoFile = 'mu.mp4';
videoReader = VideoReader(videoFile);

% Read the first frame for reference and removing minor deatils by blur
firstFrame = readFrame(videoReader);
firstFrameGray = rgb2gray(firstFrame);
firstFrameBlur = imgaussfilt(firstFrameGray, 1);

% Initialize object tracker
tracker = ObjectTracker();

% Get video dimensions
videoWidth = videoReader.Width;
videoHeight = videoReader.Height;
videoAspectRatio = videoWidth / videoHeight;

% Create a figure with an appropriate aspect ratio
figure('Position', [100, 100, 1000, round(1000 / videoAspectRatio)]);

% Main loop for processing video frames
while hasFrame(videoReader)
    % Read the frame
    frame = readFrame(videoReader);

    % Preprocess the frame
    frameGray = rgb2gray(frame);
    
    % Preprocess the frame
    frameBlur = imgaussfilt(frameGray, 1);
    
    
    

    % Calculate frame difference
    frameDiff = imabsdiff(firstFrameBlur, frameBlur);
    
    
    % Perform edge detection,
    edges = edge(frameDiff, 'Canny',[.6]);
     % figure(3)
     % imshow(edges)
     % title("edges");
    
    % Perform morphological closing
    se = strel('square', 10);
    closedEdges = imclose(edges, se);
    
    % Find contours of objects
    [contours, ~] = bwlabel(closedEdges);
    stats = regionprops(contours, 'BoundingBox', 'Area');

    % Filter out small and large objects
    detections = {};
    for i = 1:numel(stats)
        if stats(i).Area > 300 && stats(i).Area < 6000
            detections{end+1} = stats(i).BoundingBox;
        end
    end
    
    % Update object tracker
    [movingObjects, abandonedObjects] = tracker.update(detections);

% Draw rectangles around moving objects with yellow boxes
for i = 1:numel(movingObjects)
    object = movingObjects{i};
    %fprintf('Type of variablemains x: %s\n', class(object(1)))
    x = object(1);
    y = object(2);
    w = object(3); 
    h = object(4); 
    frame = insertShape(frame, 'Rectangle', [x, y, w, h], 'Color', 'yellow', 'LineWidth', 2);
end

% Draw rectangles around abandoned objects with red boxes
for i = 1:numel(abandonedObjects)
    object = abandonedObjects{i};
    id = object(1);
    x = object(2);
    y = object(3);
    w = object(4); 
    h = object(5);
    frame = insertShape(frame, 'Rectangle', [x, y, w, h], 'Color', 'red', 'LineWidth', 2);
    frame = insertText(frame, [x, y-10], 'Suspicious object detected', 'FontSize', 12, 'BoxColor', 'red', 'BoxOpacity', 0.7, 'TextColor', 'white');
end

    % Display the frame
    figure(1)
    imshow(frame);
    drawnow;

    % Uncomment the following line if you want to play the video in real-time
    pause(0.01);
end
