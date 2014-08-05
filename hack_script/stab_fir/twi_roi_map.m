% scrip to generate roi maps
%  split concenus partition between hemisphere
clear

in  = '/media/database3/twins_study/stability_fir_exp1/stability_group/sci440_scg484_scf451/brain_partition_consensus_group_sci440_scg484_scf451.mnc.gz';
out = '/media/database3/twins_study/stability_fir_exp1/stability_group/sci440_scg484_scf451/brain_partition_consensus_group_sci440_scg484_scf451_split.mnc.gz';

%  in = '/home/yassinebha/tmp/brain_partition_consensus_group_sci440_scg484_scf451_.mnc.gz';
%  out = 'brain_partition_consensus_group_sci440_scg484_scf451_split.mnc.gz';

niak_brick_cluster2parcel (in,out,struct('flag_hemisphere',true));

coord_w   = niak_read_csv('/home/yassinebha/svn/projects/twins/script/models/twins_roi.csv');
%  [hdr,vol] = niak_read_vol('/media/database3/twins_study/stability_fir_exp1/stability_group/sci160_scg160_scf164/brain_partition_consensus_group_sci160_scg160_scf164.mnc.gz');
%  [hdr,vol] = niak_read_vol('/home/yassinebha/tmp/brain_partition_consensus_group_sci440_scg484_scf451_split.mnc.gz');
[hdr,vol] = niak_read_vol('/media/database3/twins_study/stability_fir_exp1/stability_group/sci440_scg484_scf451/brain_partition_consensus_group_sci440_scg484_scf451_split.mnc.gz');
coord_v = niak_coord_world2vox(coord_w,hdr.info.mat);
ind = sub2ind(size(vol),coord_v(:,1),coord_v(:,2),coord_v(:,3));
%  ind_tmp = niak_sub2ind_3d(size(vol),coord_v);
unique(vol(ind))
length(unique(vol(ind)))
val = unique(vol(ind))
coord_w(vol(ind) == 0,:)

mask = zeros(size(vol));
for rr = 1:length(val)
mask(vol==val(rr)) = rr-1;
end
niak_montage (mask)
hdr.file_name = '/media/database3/twins_study/stability_fir_exp1/stability_group/sci440_scg484_scf451/brain_partition_consensus_group_sci440_scg484_scf451_split_mask_roi.mnc.gz';
niak_write_vol (hdr,mask);

mask = zeros(size(vol));
mask(ismember(vol,vol(ind))) = vol(ismember(vol,vol(ind)));
hdr.file_name = '/media/database3/twins_study/stability_fir_exp1/stability_group/sci440_scg484_scf451/brain_partition_consensus_group_sci440_scg484_scf451_split_mask_roi_original.mnc.gz';
niak_write_vol (hdr,mask);




% niak_brick_table_networks : use this fonction to see the percentage of overlap with word coordinate and th partition