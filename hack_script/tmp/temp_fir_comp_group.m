sc_list={ 'sci10_scg7_scf7' 'sci140_scg140_scf147' 'sci20_scg16_scf18' 'sci240_scg264_scf268' 'sci40_scg36_scf38' 'sci440_scg440_scf339' 'sci80_scg72_scf73'}
path_fir ='/media/database3/twins_study/stability_fir_all_sad_blocs_test3_perc/'
mask= 'consensus'
for num_sc = 1:length(sc_list)
%      niak_brick_mnc2nii([path_fir 'dominic_r_' sc_list{num_sc}] , [path_fir '/dominic_r_' sc_list{num_sc} '_nii']);
    
    cd ([path_fir 'stability_group/' sc_list{num_sc}]);
    
    system( ['mnc2nii ' 'brain_partition_' mask '_group_' sc_list{num_sc} '.mnc.gz networks_consensus_' sc_list{num_sc} '.nii' ]);
    system( ['gzip networks_consensus_' sc_list{num_sc} '.nii'])
    system( ['cp ' path_fir 'stability_group/' sc_list{num_sc} '/networks_consensus_' sc_list{num_sc} '.nii.gz ' path_fir '/dominic_r_' sc_list{num_sc} '_nii/.']);
end


files_in.mask = [ path_fir 'stability_group/' sc_list{num_sc} '/brain_partition_concensus_group_' sc_list{num_sc} '.mnc.gz'];
%  sc = 'sci10_scg7_scf7';
%  sc = 'sci140_scg140_scf147';
%  sc = 'sci20_scg16_scf18';
%  sc = 'sci240_scg264_scf268';
%  sc = 'sci40_scg36_scf38';
%  sc = 'sci440_scg440_scf339';
%  sc = 'sci80_scg72_scf73';