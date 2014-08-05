



%  [order,orderd,reoder, reoderd]=mat_reorder_plot(10,'/home/yassine/twins_study_basc/basc_fir/stability_fir/sci10_scg7_scf7','fdr_group_average_sci10_scg7_scf7.mat')

%  %  %  order = [1:1:18];  % n clusters dans ordre croissant
%  %  %  orderd = [1:1:153]; % n comparaisons (3c -->3, 4 -->6, 5 --> 10, etc)
%  %  %  reorder = [1:1:18]; % n clusters reordonnés (eg 2 3 1 --> le cluster 2 à l'origine devient le cluster 1, 3=2 et 1=3)
%  %  %  reorderd = [1:1:153]; % n comparaisons entre clusters (semi-matrice: si 3 clusters à l'origine 12=1 13=2 23=3 --> 23=3 21=1 31=2)


% reorder volume

[hdr,vol] = niak_read_vol('/home/yassine/twins_study_basc/basc_fir/stability_fir/sci20_scg16_scf18/brain_partition_threshold_group_sci20_scg16_scf18.nii.gz');
vol2 = zeros(size(vol));
for num = 1:length(order)
vol2(vol==reorder(num)) = order(num); 
end
hdr.file_name = '/home/yassine/twins_study_basc/basc_fir/stability_fir/sci20_scg16_scf18/brain_partition_threshold_group_sci20_scg16_scf18_reorder.nii.gz';
niak_write_vol(hdr,vol2);

% reorder matrix
load('fdr_group_average_sci20_scg16_scf18.mat') 
newfir = test_fir;
newdiff = test_diff;
for n = 1:length(order) % fir
tmpfir.pce(:,order(n)) = newfir.pce(:,reorder(n));
tmpfir.fdr(:,order(n)) = newfir.fdr(:,reorder(n));
tmpfir.mean(:,order(n)) = newfir.mean(:,reorder(n));
tmpfir.std(:,order(n)) = newfir.std(:,reorder(n));
end
for n = 1:length(orderd) % diff
tmpdiff.pce(:,orderd(n)) = newdiff.pce(:,reorderd(n));
tmpdiff.fdr(:,orderd(n)) = newdiff.fdr(:,reorderd(n));
tmpdiff.mean(:,orderd(n)) = newdiff.mean(:,reorderd(n));
tmpdiff.std(:,orderd(n)) = newdiff.std(:,reorderd(n));
end
test_fir = tmpfir;
test_diff = tmpdiff;
save('fdr_group_average_sci20_scg16_scf18_reorder.mat','test_fir', 'test_diff')


% split


niak_brick_clusters_to_3d('brain_partition_threshold_group_sci20_scg16_scf18_reorder.nii.gz')


% mask

[hdr,vol] = niak_read_vol('/home/yassine/twins_study_basc/basc_fir/stability_fir/sci20_scg16_scf18/brain_partition_threshold_group_sci20_scg16_scf18_reorder_0007.nii.gz');
vol2 = zeros(size(vol));
vol2(vol>0) = 1; 
hdr.file_name = '/home/yassine/twins_study_basc/basc_fir/stability_fir/sci20_scg16_scf18/brain_partition_threshold_group_sci20_scg16_scf18_reorder_0007_mask.nii.gz';
niak_write_vol(hdr,vol2);



% subclusters

files_in.cluster = '/home/yassine/twins_study_basc/basc_fir/stability_fir/sci20_scg16_scf18/brain_partition_threshold_group_sci20_scg16_scf18_reorder_0007_mask.nii.gz';
files_in.subcluster = '/home/yassine/twins_study_basc/basc_fir/stability_fir/sci80_scg72_scf73/brain_partition_threshold_group_sci80_scg72_scf73.nii.gz';
files_in.fir = '/home/yassine/twins_study_basc/basc_fir/stability_fir/sci80_scg72_scf73/fdr_group_average_sci80_scg72_scf73.mat';

files_out.nomatch = '';
files_out.nomatch_fir = '';
files_out.subcluster = {};
files_out.subfir = {};
files_out.matching = '';

opt.perc_overlap = 0.5; 
opt.folder_out = '/home/yassine/twins_study_basc/basc_fir/stability_fir/subclusters_c7s18-s73/';
mkdir(opt.folder_out);
niak_brick_subclusters_ts(files_in,files_out,opt);
