% This script belong to ICAN lab,BNU. adapted by Muen Zhao for his study

% -------------- Please specify the individualstats server: resting data, adults and kids, 5 HTT ----------------
%paralist.stats_path     = '/fs/musk2';
paralist.raw_server     = preprocessing_path;% preprocessing data
paralist.data_type      = 'nii';

paralist.imagefilter    = 'swcar'; 
paralist.NFRAMES = TR_number;% TR num
paralist.NUMTRUNC = cut_volume;%[8,2] cut former 8 TR , cut hinder 2tr

paralist.TR_val = 2; % tr = 2s
paralist.bandpass_on = bandpass_on; % bandpass filter open =1 , close = 0    
paralist.fl = 0.008;
% Upper frequency bound for filtering (in Hz)
paralist.fh = 0.1;

%-white matter and CSF roi files/brain/iCAN_admin/home/zhaommuen/SPM/spm8_scripts/rsFC_network
paralist.wm_csf_roi_file = cell(2,1);
%-white matter and csf rois
paralist.wm_csf_roi_file{1} = wmcsfroifile_path1; % modify
paralist.wm_csf_roi_file{2} = wmcsfroifile_path2; %modify

% Please specify file name holding subjects to be analyzed
% For one subject list files. For eg.,
paralist.subjlist_file  = {sublist_file}; % modify
 
paralist.ROI_dir        = timeseres_path;%modify 
paralist.output_folder  = timeseres_path;%modify
% get roiname:
niidir = dir(paralist.ROI_dir);
niidir = niidir(3:end);
niidir = struct2cell(niidir);
niidir = niidir(1,:);
niidir = niidir';
paralist.roi_list  = niidir;
%fullfile(paralist.roi_nii_folder,'.',niidir);
% ----- Please specify the session name: adults, kids, 5 HTT ----------------
paralist.non_year_dir = [''];
paralist.sess_folder  = session_folder;%data NB, RS 
paralist.preprocessed_folder = preprodcessed_folder; % fmri file name

%% run
creatingNetwork_ZME(paralist)