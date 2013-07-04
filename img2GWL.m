%%% Program to convert an image to GWL code     %%%
%%%                                             %%%
%%% Author: Vijay Parsi - Date: 04.07.2013      %%%
%%% email: vijayparsi@gmail.com                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                             %%%
%%% To use this program, you need an image      %%%
%%% to be converted into GWL code and           %%%
%%% writing parameters for Nanoscribe's         %%%
%%% Photonic Professional.                      %%%
%%%                                             %%%
%%% To begin, do the following...               %%%
%%%                                             %%%
%%% Set GWLmode to true if you want to          %%%
%%% convert the image, else in the false        %%%
%%% mode you can only see the previews.         %%%
%%% false mode is recommended, initially.       %%%  
%%%                                             %%%
%%% Set the imageName to the input image path.  %%%
%%%                                             %%%
%%% Choose the output GWL file dimensions (µm)  %%%
%%%                                             %%%
%%% Select a suitable black and white level     %%%
%%% bwLevel: 0.6-0.7 is close to optimal.       %%%
%%%                                             %%%
%%% Set gwlFile to output GWL file path.        %%%
%%%                                             %%%
%%% Additional input values is for optimisation %%%
%%%                                             %%%
%%% Have fun writing!                           %%%
%%%                                             %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% INPUT VALUES - TO BE SET BY THE USER %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
GWLmode = true; %Set this to true to generate GWL
imageName='testImg/stripes.jpg'; %Change this to the imagepath
xSize = 300; %Change this to the desired x length in µm
ySize = 300; %Change this to the desired y length in µm
zPos = 0.1; %Change this to set your voxel position (Default: 0.1)
bwLevel = 0.7; %Change this to select bw level. 0 is black, 1 is white.
gwlFile = 'theGWLcode.gwl'; %Change this to the desired outputname + .gwl

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%        ADDITIONAL INPUT VALUES       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
bwImgInvert = false; %Set this to true to invert your image
verticalSlicing = false; %Set this to false to slice horizontally

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%             CODE BEGINS              %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Declarations
Write = 'Write';
fid = fopen(gwlFile,'w'); 
time = datestr(now, 'HH:MM:SS');
fprintf(fid,'%s %s %s %s \n','%%% File created on', date, 'at', time);
fclose('all');

if(~GWLmode)
%%% Read
origImage = imread(imageName);

if(bwImgInvert)
    origImage = imcomplement(origImage);
end

%%% Show
% Original Image
subplot(3,5,2), imshow(origImage);
title('Original Image');

% Chosen bwLevel Image
bwImageTitle = sprintf('You chose bwLevel = %.2f', bwLevel);
subplot(3,5,4), imshow(im2bw(origImage, bwLevel));
title(bwImageTitle);

% BW Images from 0.5 - 0.9 bwLevels
subplot(3,5,6), imshow(im2bw(origImage, 0.1));
title('bwLevel = 0.1');
subplot(3,5,7), imshow(im2bw(origImage, 0.2));
title('bwLevel = 0.2');
subplot(3,5,8), imshow(im2bw(origImage, 0.3));
title('bwLevel = 0.3');
subplot(3,5,9), imshow(im2bw(origImage, 0.4));
title('bwLevel = 0.4');
subplot(3,5,10), imshow(im2bw(origImage, 0.5));
title('bwLevel = 0.5');
subplot(3,5,11), imshow(im2bw(origImage, 0.6));
title('bwLevel = 0.6');
subplot(3,5,12), imshow(im2bw(origImage, 0.7));
title('bwLevel = 0.7');
subplot(3,5,13), imshow(im2bw(origImage, 0.8));
title('bwLevel = 0.8');
subplot(3,5,14), imshow(im2bw(origImage, 0.9));
title('bwLevel = 0.9');
subplot(3,5,15), imshow(im2bw(origImage, 1.0));
title('bwLevel = 1.0');

end % GWLmode

% Check and start GWL
if (GWLmode)
    
    % Read the Image
    chosenImage = imread(imageName);
   
    if(bwImgInvert)
        chosenImage = imcomplement(chosenImage);
    end
    
    chosenImage = im2bw(chosenImage, bwLevel);
    
    % Set the scale
    [xImgSize, yImgSize] = size(chosenImage);
    xStep = xSize/xImgSize;
    yStep = ySize/yImgSize;
    
    % Loop through the Image
    startFlag = false;
    emptyLine = false;
    
    %Vertical Slicing
    if(verticalSlicing)
    for i = 1:xImgSize
        for j = 1:yImgSize
            % Optimise and write to GWL
            gwlRow = [(i*xStep)-xStep,(j*yStep)-yStep,zPos]; %Subtract to get the offset right
                           
            % Check for zeros
            if((chosenImage(i,j) == 0) && (startFlag == false))
                dlmwrite(gwlFile, gwlRow, '-append','delimiter', ' ');
                startFlag = true;
                lastPoint = gwlRow; %To take care of single points
                
                if(j == yImgSize) %End of row
                    startFlag = false;
                end
            
            elseif((chosenImage(i,j) == 0) && (startFlag == true))
                lastPoint = gwlRow;
                
                if(j == yImgSize) %End of row
                    dlmwrite(gwlFile, lastPoint, '-append','delimiter', ' ');
                    dlmwrite(gwlFile, Write, '-append','delimiter', '');
                    startFlag = false;   
                end
            
            elseif((chosenImage(i,j) ~= 0) && (startFlag == true))
                dlmwrite(gwlFile, lastPoint, '-append','delimiter', ' ');
                dlmwrite(gwlFile, Write, '-append','delimiter', '');
                startFlag = false;
            
            else %((chosenImage(i,j) ~= 0) && (startFlag == false))
                % For empty lines (usually at the borders)
                emptyLine = true;
            end 
            
        end % j loop end
        
        % Inform User about progress
        fprintf('Vertical Slicing - Looping through column %d\n', i)
        
        % Set emptyLine to false
        if (emptyLine)
            emptyLine = false;
        end %if statement to correct errors with empty lines
   
    end % i loop end
    %end Vertical slicing
    
    else
    %Horizontal Slicing
    for i = 1:yImgSize
        for j = 1:xImgSize
            % Optimise and write to GWL
            gwlRow = [(j*xStep)-xStep,(i*yStep)-yStep,zPos]; %Subtract to get the offset right
                           
            % Check for zeros
            if((chosenImage(j,i) == 0) && (startFlag == false))
                dlmwrite(gwlFile, gwlRow, '-append','delimiter', ' ');
                startFlag = true;
                lastPoint = gwlRow; %To take care of single points
                
                if(j == xImgSize) %End of row
                    startFlag = false;
                end
            
            elseif((chosenImage(j,i) == 0) && (startFlag == true))
                lastPoint = gwlRow;
                
                if(j == xImgSize) %End of row
                    dlmwrite(gwlFile, lastPoint, '-append','delimiter', ' ');
                    dlmwrite(gwlFile, Write, '-append','delimiter', '');
                    startFlag = false;   
                end
            
            elseif((chosenImage(j,i) ~= 0) && (startFlag == true))
                dlmwrite(gwlFile, lastPoint, '-append','delimiter', ' ');
                dlmwrite(gwlFile, Write, '-append','delimiter', '');
                startFlag = false;
            
            else %((chosenImage(j,i) ~= 0) && (startFlag == false))
                % For empty lines (usually at the borders)
                emptyLine = true;
            end 
            
        end % j loop end
        
        % Inform User about progress
        fprintf('Horizontal Slicing - Looping through row %d\n', i)
        
        % Set emptyLine to false
        if (emptyLine)
            emptyLine = false;
        end %if statement to correct errors with empty lines
        
    end % i loop end
    end % End Horizontal Slicing
    
    % Save the corresponding GWL Image with the chose bwLevel
    resultGWLimageFile = strcat(gwlFile,'-Image.png');
    imwrite(chosenImage, resultGWLimageFile, 'png');
end % if end

