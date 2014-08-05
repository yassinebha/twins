clear
path_fir = '/home/benhajal/database/twins/stability_fir_all_sad_blocs_EXP2_test1/';
sc_list={'sci10_scg7_scf7' 'sci140_scg140_scf151' 'sci20_scg16_scf17' 'sci280_scg280_scf298' 'sci400_scg480_scf438' 'sci40_scg36_scf36' 'sci80_scg72_scf73'};
files_in.model = '/home/yassinebha/svn/yassine/script/models/dominic_dep_group0a1_minus_group11a20.csv';
mask='consensus'

%sc = 'sci10_scg7_scf7';
%sc = 'sci140_scg140_scf147';
%sc = 'sci20_scg16_scf18';
%sc = 'sci240_scg264_scf268';
%sc = 'sci40_scg36_scf38';
%sc = 'sci440_scg440_scf339';
%sc = 'sci80_scg72_scf73';


for num_sc = 1:length(sc_list)

    %path_out = [path_fir 'dominic_r_' sc '/'];
    path_out = [path_fir 'dominic_r_' sc_list{num_sc} '/'];

    %% Generate the list of FIR responses
    list_fir = dir([path_fir 'rois/fir_tseries*']);
    list_fir = {list_fir.name};
    for num_s = 1:length(list_fir)
        files_in.fir_all.(list_fir{num_s}(13:23)) = [path_fir 'rois/' list_fir{num_s}];
    end

    %% The atoms
    files_in.atoms = [path_fir 'rois/brain_rois.mnc.gz'];

    %% The target clusters
    files_in.mask = [path_fir 'stability_group/' sc_list{num_sc} '/brain_partition_consensus_group_'  sc_list{num_sc} '.mnc.gz'];

    %% Options - Misc
   opt.fdr = 0.1; % The maximal false-discovery rate that is tolerated both for individual (single-seed) maps and whole-connectome discoveries
    %opt.normalize.type = 'fir_shape';
    opt.normalize.type = 'perc';
    opt.normalize.time_norm = 15;

   %% Test : average FIR in the normal group
   opt.test.average_group0.contrast.intercept = 1;
   opt.test.average_group0.select.label = 'group0_minus_group1';
   opt.test.average_group0.select.values = 0;

   %% Test : average FIR in the "depressed" group
   opt.test.average_group1.contrast.intercept = 1;
   opt.test.average_group1.select.label = 'group0_minus_group1';
   opt.test.average_group1.select.values = 1;

   %% Test : comparison between the normal and the "depressed" group
   opt.test.group0_minus_group1.contrast.group0_minus_group1 = 1;
   opt.test.group0_minus_group1.select.label = 'group0_and_group1';
   opt.test.group0_minus_group1.select.values = 1;

   %%dominic_dep
   opt.test.dominic_dep.contrast.dominic_dep= 1;

   %% Build the pipeline
   list_test = fieldnames(opt.test);
   pipeline = struct();
   for num_t = 1:length(list_test);
       opt_tmp = opt;
       opt_tmp.test = struct;
       opt_tmp.test.(list_test{num_t}) = opt.test.(list_test{num_t});
    
      %% Where to store the results
      path_test = [path_out list_test{num_t} '/'];
      files_out.results = [path_test 'glm_' list_test{num_t} '_' sc_list{num_sc} '.mat'];
      files_out.ttest = [path_test 'ttest_' list_test{num_t} '_' sc_list{num_sc} '.mnc.gz'];
      files_out.effect = [path_test 'effect_' list_test{num_t} '_' sc_list{num_sc} '.mnc.gz'];
      files_out.std_effect = [path_test 'std_' list_test{num_t} '_' sc_list{num_sc} '.mnc.gz'];
      files_out.fdr = [path_test 'fdr_' list_test{num_t} '_' sc_list{num_sc} '.mnc.gz'];
      files_out.perc_discovery = [path_test 'perc_disc_' list_test{num_t} '_' sc_list{num_sc} '.mnc.gz'];
    
      %% Run the analysis
      pipeline = psom_add_job(pipeline,list_test{num_t},'niak_brick_glm_fir',files_in,files_out,opt_tmp);
   end
   opt_psom.path_logs = [path_out,'logs/'];
   opt_psom.flag_pause = false;
   psom_run_pipeline(pipeline,opt_psom);

   system(['cp ' mfilename('fullpath') '.m ' path_out '/.']); % make a copie of this script to output folder
   system(['cp ' files_in.model ' ' path_out '/.' ]); % make a copie of time events file used to output folder
   save ([path_out 'pipiline_envir.mat']);


   %convert to nii

    niak_brick_mnc2nii([path_fir 'dominic_r_' sc_list{num_sc}] , [path_fir '/dominic_r_' sc_list{num_sc} '_nii']);

    cd ([path_fir 'stability_group/' sc_list{num_sc}]);

    system( ['mnc2nii ' 'brain_partition_' mask '_group_' sc_list{num_sc} '.mnc.gz networks_' mask '_' sc_list{num_sc} '.nii' ]);
    system( ['gzip networks_' mask '_' sc_list{num_sc} '.nii'])
    system( ['cp ' path_fir 'stability_group/' sc_list{num_sc} '/networks_' mask '_' sc_list{num_sc} '.nii.gz ' path_fir '/dominic_r_' sc_list{num_sc} '_nii/.']);

end
    
