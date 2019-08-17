% writer by muen ZHAO in BNU,
%this script is used to transform the mat file of brain to nii
%this script used functions of spm12, so remmember setpath
function brain_mat2nii(roi_path,out_path)
if ~exist(out_path,'dir')
    mkdir(out_path);
    disp('making a folder in out_dir');
end

path1 = dir (fullfile(out_path));
if length(path1) > 2
    prompt    = 'You have files in output folder, do you want to delete them all?(if not stop condecting script),press y/n';
    x   = input(prompt);
    if x == 'y'
        delete(out_path);   mkdir(out_path);
    else
        return;
    end
end
         

roiname_array=dir(fullfile(roi_path,'*.mat'));  
for roi_num = 1:length(roiname_array) 
   
    roi_array{roi_num} = maroi(fullfile(roi_path,roiname_array(roi_num).name));%not sure
    roi_conv  = roi_array{roi_num};
    roi_name  = strtok(roiname_array(roi_num).name,'.');
    save_as_image(roi_conv,fullfile(out_path,[roi_name,'.nii']))
end



end