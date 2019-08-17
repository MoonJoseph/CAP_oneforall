% writen by muen zhao,
%this function print fslmath... in linux
%fslmath -mul couldy multiply first image/nii to second image/nii
%In this function ,your mask should bi in depend folder
function fslmathmul(datapath,marsk_name)

   roi        = dir(datapath);
   roi_num    = length(roi)  ;
   marsk      = marsk_name(1:end-4);
for       i   = 3:roi_num
    file_name = strcat(roi(i).name(1:end-4),'_&_',marsk);
    unix(sprintf(strcat('fslmaths %s -mul ',marsk,'.nii %s'),roi(i).name,file_name));
end


end

