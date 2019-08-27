% writen by muen zhao, in BNU
%------------------------------------------------------------------%
restoredefaultpath
clear all
clear classes
%% task choice 
%task choice
step1_mat2nii      =0;
step2_fslmath_mul  =0;
step3_delete0voxel =0;
step4_nii2mat      =0;
step5_timeseries   =0;
step6_combine      =0;
step7_kmeans       =1;
%% ste up1 (step1 get roi)
current_path= pwd;
%set up mat2nii
depend_path = '/brain/iCAN_admin/home/zhaomuen/SPM/spm8_scripts/Roi_analysis_ZME/depend'; 
roi_path    = '/brain/iCAN_admin/home/zhaomuen/CAP/Original/ROIs_mats_old';
temp_path   = '/brain/iCAN_admin/home/zhaomuen/SPM/spm8_scripts/temp';
outmat2nii_path    = '/brain/iCAN_admin/home/zhaomuen/CAP/Outputs/Results_nii2mat';
marsbar_path= '/brain/iCAN_admin/home/zhaomuen/SPM/spm8/toolbox/marsbar';
spm8_dir    = '/brain/iCAN_admin/home/zhaomuen/SPM/spm8_scripts/Roi_analysis_ZME/depend/spm8';

%setup fslmaths mul
marsk_path      = '/brain/iCAN_admin/home/zhaomuen/Second_level/AMDD-CBD_Fullfactor_Lu/myMask.nii';
marsk_name      = 'myMask.nii';
outfslmath_path = '/brain/iCAN_admin/home/zhaomuen/CAP/Outputs/Result_fslmath_mul';

%get roi timeserises    %basic set up. More detail change in creatingNetwork_config_ZME
preprocessing_path  = '/brain/iCAN_admin/home/zhaomuen/Data_AMDD_noFM/'; %modify
wmcsfroifile_path1  = '/brain/iCAN_admin/home/zhaomuen/SPM/spm8_scripts/Roi_analysis_ZME/white_mask_p08_d1_e1_roi.mat';
wmcsfroifile_path2  = '/brain/iCAN_admin/home/zhaomuen/SPM/spm8_scripts/Roi_analysis_ZME/csf_mask_p08_d1_e1_roi.mat';
ROI_dir_path        = '/brain/iCAN_admin/home/zhaomuen/CAP/Outputs/Result_fslmath_mul';
timeseres_path        = '/brain/iCAN_admin/home/zhaomuen/CAP/Outputs/Result_roitimeseries/AMDD/' ;   %modify
creatingNetwork_path= '/brain/iCAN_admin/home/zhaomuen/SPM/spm8_scripts/Roi_analysis_ZME/depend/creatingNetwork_config_ZME.m';
session_folder      = 'NB';
preprodcessed_folder= 'smoothed_spm12';
TR_number           = 228;
cut_volume          = [0,0];%[8,2] cut former 8 TR , cut hinder 2tr
bandpass_on         =  0;   % bandpass filter open =1 , close = 0 
sublist_file        = 'sublist_AMDD.txt';                              %modify
xjview_dir          = '/brain/iCAN_admin/home/zhaomuen/SPM/spm8_scripts/Roi_analysis_ZME/depend/xjview_muen_modify';
spm12_dir           = '/brain/iCAN_admin/home/zhaomuen/SPM/spm12';
%kmeans
k                   = 3;
sub_all_roi_ts_mat      = 'sub_all_roi_ts.mat'
%addpath
addpath(depend_path);
addpath(fullfile(depend_path,'Bandpass'));
addpath(fullfile(depend_path,'code'));
addpath(fullfile(depend_path,'Misc'));
addpath(fullfile(depend_path,'SeedAnalysis'));
addpath(spm8_dir);
addpath(marsbar_path);
addpath(xjview_dir);
%%  mat2nii
if step1_mat2nii==1

%brain_nii2mat
brain_mat2nii(roi_path,outmat2nii_path);
disp('finish mat2nii');

end
%% fslmath()  multiply two image       %Before this step,you need firstly make a mask useing Masbar/spm fmri review/wfu. And this mask is all your activation area, the vaule is activated value 
if step2_fslmath_mul==1

roi0        = dir(outmat2nii_path);
roi_num    = length(roi0)  ;
marsk      = marsk_name(3:end-4);

%check and delete other files
for file = 3:length(roi0)
    if isempty(strfind(roi0(file).name,'roi.nii'))
        delete(roi0(file).name)
    end
end
roi        = dir(outmat2nii_path);

%move mask to current folder,   mask should be nii,if not fslmath dont work
cd(outmat2nii_path);
if exist(marsk_name,'file')==0
   copyfile(marsk_path,outmat2nii_path) ; 
end


%fslmaths -mul
   
for       i   = 3:roi_num
    file_name = strcat(roi(i).name(1:end-4),'_oooo_',marsk);
    unix(sprintf(['fslmaths ',roi(i).name,' -mul ',marsk_name,' ',file_name]));
end
sprintf('---------------------finish fslmaths -mul finished--------------');

%move to out folder
    nii       = dir(outmat2nii_path);
for       j   = 3:roi_num
    if strfind(nii(j).name,'oooo')>0
       outmat2niipath   = fullfile(outmat2nii_path,nii(j).name);
       copyfile(outmat2niipath,outfslmath_path) ;
    end
end
sprintf('-----------------send files to destination folder finished---------------')

end

%% delete all nii which has no activated voxels
if step3_delete0voxel==1   
%gunzip
roi = dir(ROI_dir_path); cd(ROI_dir_path);
for ii=3:length(roi); 
    if strfind(roi(ii).name,'.gz')>0; unix(sprintf('gunzip -fq %s',roi(ii).name));end  
end
y   = get_maxvoxel(outfslmath_path);
sprintf('--------delete all nii which has no activated voxels finished!---------')
end
%% nii to mat
if step4_nii2mat==1;
% make output folder
if exist(timeseres_path)==0; mkdir(timeseres_path); end
% nii to mat
brain_nii2mat(outfslmath_path,timeseres_path);
sprintf('----------------------nii to mat finished!-----------------------')
end
%% gettimeseries
if step5_timeseries==1
creatingNetwork_config_ZME
sprintf('----------------------gettimeseries finished!--------------------')
end
%% combine all subject to one
% delete previous data
if step6_combine==1;
roi = dir(timeseres_path); cd(timeseres_path);
for iii = 3:length(roi)
    if strfind(roi(iii).name,'oooo')>1; delete(roi(iii).name);end
end
roi = dir(timeseres_path);

sub_all_roi_ts = []; sub_roi_names = {}; j = 1;
for iii = 3:length(roi) 
    if strfind(roi(iii).name,'timeseris')>1;
               subj = load(roi(iii).name);
       subj_roi_ts  = subj.all_roi_ts;
     sub_all_roi_ts = [sub_all_roi_ts;subj_roi_ts];
    end
end
cd(depend_path); filename='sub_all_roi_ts';
save(filename,sub_all_roi_ts);
sprintf('----------------combine all subject to one finished!-------------')
end
%% kmeans
if step7_kmeans == 1
cd(depend_path); load(sub_all_roi_ts_mat);roi = dir(timeseres_path);
myfunc = @(x,y)(kmeans(x,k,'emptyaction','singleton','MaxIter',1000,'replicates',100));
sub_num= length(roi)-4;
eva    = evalclusters(sub_all_roi_ts,myfunc,'CalinskiHarabasz','kList',[2:sub_num]);
figure;
plot(eva);
end
