% Preprocess data
% ---------------
% This script opens 1-photon raw data, performs subsampling, prompts user
% to crop relevant area within imaging field, and performs motion correction

clear; clc; close all;

% Set file to analyze (files will be concatenated 
%filename = 'Y:\Daniel\ssub-2,tsub-2,MotionCorrected_crop_short_non-rigid.tif';
filename = { ...
    'Y:\Daniel\01.04.18\recording_20180401_102748.hdf5' ...
    'Y:\Daniel\01.04.18\recording_20180401_103351.hdf5' ...
    'Y:\Daniel\01.04.18\recording_20180401_103954.hdf5' ...
    'Y:\Daniel\01.04.18\recording_20180401_104556.hdf5' ...
    'Y:\Daniel\01.04.18\recording_20180401_105159.hdf5'};
sframe = 1;          % first frame to read (optional, default: 1)
num2read = Inf;      % number of frames to read (optional, default: Inf - read the whole file)
init_ssub = 2;       % spatial downsampling prior to processing
init_tsub = 1;       % temporal downsampling prior to processing
remove_margins = 20; % number of pixels to trim at imaging margins (prevents empty pixels inserted by motion correction algorithm)

if isa(filename,'cell')
    file_count = length(filename);
    for file_num = 1:file_count
        if ~exist(filename{file_num},'file')
            error('File %s does not exist, preprocessing aborted.',filename{file_num});
        end
    end
elseif isa(filename,'char')
    filename = {filename};
    file_count = 1;
    if ~exist(file_count{file_num},'file')
        error('File %s does not exist, preprocessing aborted.',filename{1});
    end
end

ConcatFrames = nan(1,file_count-1);
rect = [];
Y = [];
for file_num = 1:file_count
    % Open file
    fprintf('Opening raw imaging file %s...\n',filename{file_num});
    tOpenFile = tic;
    [dir_nm, file_nm, file_type] = fileparts(filename{file_num});
    filesep = '\';
    Y = read_file_coren(filename{file_num},sframe,num2read);
    fprintf('Spent %02d:%02d min opening imaging file.\n',floor(toc(tOpenFile)/60), round(rem(toc(tOpenFile),60)));

    % Perform early subsampling
    tDownsampling = tic;
    Y = dsData_coren(Y, init_ssub, init_tsub);
    fprintf('Spent %02d:%02d min downsampling data.\n',floor(toc(tDownsampling)/60), round(rem(toc(tDownsampling),60)));

    % Crop data
    if isempty(rect)
        fprintf('Cropping data: waiting for user input in a separate window.\n');
        [Y, rect] = CropData(Y,2,2,'AddMargin',remove_margins);
    else
        fprintf('Cropping data.\n');
        [Y, rect] = CropData(Y,2,2,'AddMargin',remove_margins,'DefaultRectangle',rect,'UserInput',false);
    end
    fprintf('Cropped relevant subregion.\n');
    
    if file_num == 1
        nam = [dir_nm filesep 'Preprocessed_Data.tif'];
        options.overwrite = true;
        options.append = false;
        saveastiff(Y,nam,options);
    else
        ConcatFrames(file_num-1) = size(Y,3);
        options.overwrite = false;
        options.append = true;
        saveastiff(Y,nam,options);
    end
end

% Perform motion correction
fprintf('Performing motion correction...\n');
tMotionCorrection = tic;
[Y_corrected, shifts] = PerformMotionCorrection(nam);
ArtifactHeaders = {'X,Y Shift', 'X Shift', 'Y Shift'};
ArtifactData = [sqrt(shifts(:,1).^2 .* shifts(:,2).^2), shifts];
fprintf('Spent %02d:%02d min performing motion correction.\n',floor(toc(tMotionCorrection)/60), round(rem(toc(tMotionCorrection),60)));

% Remove margins to avoid problems due to motion artifact at data margins
Y_corrected = Y_corrected(remove_margins+1:end-remove_margins,remove_margins+1:end-remove_margins,:);

% Save subsampled, cropped, motion corrected data
fprintf('Saving a file of subsampled, cropped, motion corrected data...\n');
tSaveIntermediate = tic;
nam = [dir_nm filesep 'Preprocessed_Data.tif'];
options.overwrite = true; options.append = false;
saveastiff(Y_corrected,nam,options);
fprintf('Spent %02d:%02d min saving file.\n',floor(toc(tSaveIntermediate)/60), round(rem(toc(tSaveIntermediate),60)));

% Save metadata (i.e., MotionArtifact Data, Frames where imaging sequences were concatenated
save([dir_nm '\PreprocessingMetadata.mat'],'ArtifactHeaders','ArtifactData','ConcatFrames');