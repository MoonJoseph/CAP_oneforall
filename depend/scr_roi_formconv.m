% written by hao (ver_18.06.05)
% rock3.hao@gmail.com
% qinlab.BNU
restoredefaultpath
clear

%% Set up
conv_func = 'nii2mat'; % 'nii2mat' or 'mat2nii'

% Directory with ROIs to convert
spm_dir = '/Users/haol/Dropbox/Toolbox/spm12';
roi_dir = '/Users/haol/Downloads/scr_test/ROI/NeuroSynth_Fan';

%% ROI format convert
% For batch converting the contents of a directory of ROIs
addpath(genpath(spm_dir));

if strcmp(conv_func,'mat2nii')
    roi_savedir = [roi_dir,'_nii',];
    if ~exist (roi_savedir,'dir')
        mkdir (roi_savedir)
    end
    
    roi_namearray = dir(fullfile(roi_dir, '*.mat'));
    for roi_num = 1:length(roi_namearray)
        roi_array{roi_num} = maroi(fullfile(roi_dir, roi_namearray(roi_num).name)); %#ok<*SAGROW>
        roi_conv = roi_array{roi_num};
        roi_name = strtok(roi_namearray(roi_num).name, '.');
        save_as_image(roi_conv, fullfile(roi_savedir, [roi_name,'.nii']))
    end
end

if strcmp(conv_func,'nii2mat')
    roi_savedir = [roi_dir,'_mat',];
    if ~exist (roi_savedir,'dir')
        mkdir (roi_savedir)
    end
    
    roi_namearray = dir(fullfile(roi_dir, '*.nii'));
    for roi_num = 1:length(roi_namearray)
        roi_name = roi_namearray(roi_num).name;
        roi_conv = maroi_image(struct('vol', spm_vol(fullfile(roi_dir,roi_name)), 'binarize', 0, 'func', 'img'));
        roi_conv = maroi_matrix(roi_conv);
        roi_conv = label(roi_conv, roi_name);
        saveroi(roi_conv, fullfile(roi_savedir, [strtok(roi_namearray(roi_num).name, '.'),'_roi.mat']))
    end
end
