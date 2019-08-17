% Writen by Muen Zhao, in BNU.
% This script is to get th maxim activated voxel in nii
% Attention, script need the latest varsion of xjview. And setpath spm12

 function y   = get_maxvoxel(input_path,y)  % input_path here is fslmath_mul ; spm_file is the 
cd(input_path);
roi = dir(input_path);
y =[]
for i=3:length(roi) % roi_path is all the path of roi
spm_file = roi(i).name;
xjview(spm_file);
         h   = spm_mip_ui('FindMIPax');
         loc = 'glmax';
         xyz = spm_mip_ui('Jump',h,loc);
         close(gcf)
         if xyz == [0;0;0];
             delete(spm_file);
         else y{i}.name   = spm_file;
              y{i}.maxroi = xyz;     
         end
if isempty(y)==1;
    y=['all nii has no activated voxel'];
    sprintf('all nii has no activated voxel');
    
end
 
end
 
