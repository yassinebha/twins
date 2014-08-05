
% Generate subclusters by decomposing a spacific cluster n from scale K into a higher scale K' ( K < K')  

cluster              = 1;
from_scale           = 17;
at_scale             = 151;
path_folder          = '/home/yassinebha/Dropbox/twins_study_basc/basc_fir/stability_fir_all_sad_blocs_EXP2_test1/FIR_EXP2_test1_nii/';
files_in.cluster     = [ path_folder  'sci20_scg16_scf17/brain_partition_consensus_group_sci20_scg16_scf17.nii.gz' ];
files_in.subcluster  = [ path_folder  'sci140_scg140_scf151/brain_partition_consensus_group_sci140_scg140_scf151.nii.gz' ];
files_in.fir         = [ path_folder  'sci140_scg140_scf151/fdr_group_average_sci140_scg140_scf151.mat' ];


%  
%  files_in.cluster= strcat ( path_folder, files_in_cluster);
%  files_in.subcluster = strcat ( path_folder, files_in_subcluster);
%  files_in.fir =strcat ( path_folder, files_in_fir);

files_out.nomatch = '';
files_out.nomatch_fir = '';
files_out.subcluster = {};
files_out.subfir = {};
files_out.matching = '';

opt.perc_overlap = 0.5; 
opt.folder_out =[ path_folder,'subclusters_c',num2str(cluster),'s',num2str(from_scale),'@s_',num2str(at_scale),'/'];
mkdir(opt.folder_out);
niak_brick_subclusters(files_in,files_out,opt);


