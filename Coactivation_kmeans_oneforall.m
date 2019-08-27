% writen by muen zhao, in BNU, Email:772878614@qq.com
% This script is to do coactivation pattern kmeans
% usually you do not need  
%------------------------------------------------------------------%
restoredefaultpath
clear all;
spm12_dir           = '/brain/iCAN_admin/home/zhaomuen/SPM/spm12';
addpath(spm12_dir);
clear classes;
%% task choice 
%task choice
Step1_get_preprocesseddata = 0; 
get_allframes  = 0;% usually you dont need it .
Step2_get_primarilyroi = 1;
%% set
% general path set
marsbar_path        = '/brain/iCAN_admin/home/zhaomuen/SPM/spm8/toolbox/marsbar';
depend_path         = '/brain/iCAN_admin/home/zhaomuen/SPM/spm8_scripts/Roi_analysis_ZME/depend'; 
wmcsfroifile_path1  = '/brain/iCAN_admin/home/zhaomuen/SPM/spm8_scripts/Roi_analysis_ZME/white_mask_p08_d1_e1_roi.mat';
wmcsfroifile_path2  = '/brain/iCAN_admin/home/zhaomuen/SPM/spm8_scripts/Roi_analysis_ZME/csf_mask_p08_d1_e1_roi.mat';
timeseres_path      = '/brain/iCAN_admin/home/zhaomuen/CAP/Outputs/Result_roitimeseries/AMDD/' ;   %modify
subjlist_file       = 'sublist_AMDD.txt';  
% get frames
preprocessing_path  = '/brain/iCAN_admin/home/zhaomuen/Data_AMDD_noFM/';  %modify
creatingNetwork_path= '/brain/iCAN_admin/home/zhaomuen/SPM/spm8_scripts/Roi_analysis_ZME/depend/creatingNetwork_config_ZME.m';
preprodcessed_folder= 'smoothed_spm12';
timeseries_folder   = 'timeseries';
session_folder      = 'NB';
TR_number           = 228;
cut_volume          = [0,0];%[8,2] cut former 8 TR , cut hinder 2tr
bandpass_on         =  0;   % bandpass filter open =1 , close = 0 
non_year_dir        = [''];
imagefilter         = 'swcar';
%get primarily roi
spmT_filepath       = '/brain/iCAN_admin/home/zhaomuen/Second_level/AMDD-CBD_Fullfactor_Lu/spmF_0013.nii'
xjview_dir          = '/brain/iCAN_admin/home/zhaomuen/SPM/spm8_scripts/Roi_analysis_ZME/depend/xjview_muen_modify';
mask_dir            = '/brain/iCAN_admin/home/zhaomuen/SPM/spm8_scripts/Roi_analysis_ZME/Frontal_Sup_LR.nii';
thresholdmask_dir   = '/brain/iCAN_admin/home/zhaomuen/SPM/spm8_scripts/Roi_analysis_ZME/AMDD_CBD20NB.nii';
thre_precent        = [0.7;0.8;0.9];
%kmeans
sub_all_roi_ts_mat  = 'sub_all_roi_ts.mat'
%addpath
addpath(depend_path);
addpath(fullfile(depend_path,'Bandpass'));
addpath(fullfile(depend_path,'code'));
addpath(fullfile(depend_path,'Misc'));
addpath(fullfile(depend_path,'SeedAnalysis'));
addpath(marsbar_path);
addpath(xjview_dir);
% Load subject list, constrast file and batchfile
fid = fopen(subjlist_file); subjects={}; int=1;
while ~feof(fid);
    linedata = textscan(fgetl(fid),'%s','Delimiter','\t');
    subjects(int,:) = linedata{1}; int = int+1; 
end
fclose(fid);
cd(pwd)
%parent_folder   = ReadList(parent_folder);
numsubj         = length(subjects);
imagedir        = cell(numsubj,1);
%% step1 get all tr(Frame) form preprocessed data
if Step1_get_preprocesseddata==1
%movement states
mvmntdir = cell(numsubj,2);
run_FC_dir = pwd;
%-Update path 
if isempty(non_year_dir)
  for i = 1:numsubj
    pfolder{i} = ['20', subjects{i}(1:2)];
  end
else
  for i = 1:sublength
    pfolder{i} = non_year_dir;
  end
end
% copy preprocessing data to the folder
for cnt = 1:numsubj
    %sessionlink_dir{cnt} = fullfile(raw_server, pfolder{cnt}, ....
    %                                subjects{cnt}, 'fmri', sess_folder);
    imagedir{cnt} = fullfile(preprocessing_path, pfolder{cnt}, subjects{cnt}, ...
                              'fmri', session_folder, preprodcessed_folder);  
    mvmntdir{cnt,1} = fullfile(preprocessing_path, pfolder{cnt}, subjects{cnt}, ...
                               'fmri', session_folder, 'unnormalized');
    mvmntdir{cnt,2} = fullfile(preprocessing_path, pfolder{cnt}, subjects{cnt}, ...
                               'fmri', session_folder, preprodcessed_folder); %  
    % move data
    for FCi = 1:numsubj
      secondpart = subjects{FCi}(1:2);
        if str2double(secondpart) > 96
         pfolder = ['19' secondpart];
        else
         pfolder = ['20' secondpart];
        end
    end
    output_dir = strcat(timeseres_path, subjects{FCi}, '/', session_folder);
    mkdir(output_dir)
    % copy files
    fprintf('Copy files from folder: %s \n',imagedir{cnt});
    fprintf('to path: %s',output_dir);
    unix(['cp ',fullfile(imagedir{cnt},'swcarI.nii'),' ',output_dir])
end
fprintf('-------------------move swcarI.nii to temp folder finished!----------------------')
end
%% get all frames
% spm_select() get all dir
if get_allframes  == 1;
  for subi = 1:numsubj
      nifti_file = spm_select('ExtFPList',fullfile(timeseres_path,subjects{subi},session_folder),['^',imagefilter,'I.*\.nii']); 
      V = spm_vol(deblank(nifti_file(1,:)));
      if length(V.private.dat.dim) == 4
      nframes = V.private.dat.dim(4);
      files = spm_select('ExtFPList',fullfile(timeseres_path,subjects{subi},session_folder),['^',imagefilter,'I.*\.nii'],1:nframes);
      else
      error('Please your data, your data has to be 4D NIFTI');
      end
      nscans = size(files,1);
      clear nifti_file V nframes;     
 % make sure frames exist
 if nscans ==0; error('NO image data found'); end    
 % get frames of all subject
 for fi = 1:length(files)
     Vi = spm_vol(files(fi,:));
     Yi = spm_read_vols(Vi);
     frames{fi}.sub = Yi;
     frames{fi}.fnum = fi;
 end
 sub{subi}=frames
  end
save(fullfile(depend_path,'sub_frames.mat'),'sub'); 
end
%% get primarily roi and get frames based on it
if Step2_get_primarilyroi==1
load(fullfile(depend_path,'sub_frames.mat'));
% fslmath -mul two mask
unix(sprintf(['fslmaths ',spmT_filepath,' -mul ',mask_dir,' ',depend_path,'/conbined_mask']));
cd(depend_path); 
unix(sprintf('gunzip -fq conbined_mask*'));
% use xjview get the coordination of biggest voxel in area
xjview('conbined_mask.nii');
h = spm_mip_ui('FindMIPax');
loc = 'glmax';
xyz = spm_mip_ui('Jump',h,loc) ;
close(gcf);
% get threshold precentage
for threi = 1:length(thre_precent)
% get the timeseries of this coordination
roi_tr = [];
 for   subii = 1:length(subjects)
% spm_select() get dir
 nifti_file = spm_select('ExtFPList',fullfile(timeseres_path,subjects{subii},session_folder),['^',imagefilter,'I.*\.nii']); 
 V = spm_vol(deblank(nifti_file(1,:)));
    if length(V.private.dat.dim) == 4
    nframes = V.private.dat.dim(4);
    files = spm_select('ExtFPList',fullfile(timeseres_path,subjects{subii},session_folder),['^',imagefilter,'I.*\.nii'],1:nframes);
    else
    error('Please your data, your data has to be 4D NIFTI');    
    end 
%  get the timeseries of single sub  
for fii = 1: TR_number 
    roi_tr(fii,subii)=spm_get_data(files(fii,:),xyz);
end
% sortrow() and get data above threshold
   I = 1:TR_number;
   I = I';
   temp_tr =[I, roi_tr];
   temp_tr = sortrows(temp_tr,2);
   len_tr  = round(length(temp_tr(:,1))*thre_precent(threi));
   roi_tr  = temp_tr(len_tr+1:end,:);
% get tr number
   tr_num  = roi_tr(:,1);
% get tr_dir
tr_dirs    = [];
for tri    = 1:length(tr_num)
    tr_dir = files(tr_num(tri),:);
    tr_dirs= [tr_dirs;tr_dir]
end
% get tr(frames)
for trii = 1:length(tr_dirs(:,1))
    V = spm_vol(tr_dirs(trii,:));
    Yi= spm_read_vols(V);
     sub{subii}.frames{trii}.frame = Yi;
     sub{subii}.frames{trii}.dir  = tr_dirs(trii,:);
end 
 end
end

end


















