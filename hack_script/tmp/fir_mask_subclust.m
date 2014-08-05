
function [] = fir_mask_subclust(files_in_splited_partition)

%  Usage: [] = fir_mask_subclust(files_in_splited_partition)
%% write the hole path and the files_name without .nii.gz extention
%%%%%%%%%%%%% example %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %  files_in_splited_partition='/home/yassine/twins_study_basc/basc_fir/stability_fir/sci20_scg16_scf18/brain_partition_threshold_group_sci20_scg16_scf18_reorder_0007'
%  %  write the hole path and the files_name without .nii.gz extention
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% mask

[hdr,vol] = niak_read_vol([files_in_splited_partition,'.nii.gz']);
vol2 = zeros(size(vol));
vol2(vol>0) = 1; 
hdr.file_name = ([files_in_splited_partition,'_mask.nii.gz']);
niak_write_vol(hdr,vol2);



endfunction