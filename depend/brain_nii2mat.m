% writer by muen ZHAO in BNU,
%this script is used to transform the nii file of brain to mat
%this script used functions of spm12, so remmember setpath
function brain_nii2mat(roi_path,out_path)
if ~exist(out_path,'dir')
    mkdir(out_path);
    disp('making a folder in out_dir');
end

path1 = dir (fullfile(out_path));
% if length(path1) > 2
%     prompt    = 'You have files in output folder, do you want to delete them all?(if not stop condecting script),press y/n';
%     x   = input(prompt);
%     if x == 'y'
%         delete(out_path);   mkdir(out_path);
%     else
%         return;
%     end
% end
         

roiname_array=dir(fullfile(roi_path,'*.nii'));  
for roi_num = 1:length(roiname_array) %3
   roi_name = roiname_array(roi_num).name;
   roi_conv = maroi_image(struct('vol',spm_vol(fullfile(roi_path,roi_name)),'binarize',0,'func','img')); % maroi_image - class constructor
   roi_conv = maroi_matrix(roi_conv);
   roi_conv = label(roi_conv,roi_name);
   saveroi(roi_conv,fullfile(out_path,[strtok(roiname_array(roi_num).name,'.'),'_roi.mat']))
end



end