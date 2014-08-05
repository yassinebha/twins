clear
path_fir = '/sb/scratch/yassinebha/database/twins_study/stability_fir_all_sad_blocs/';
files_in.model = '/home/yassinebha/script/models/dominic_dep_group0a4_minus_group11a20.csv';
%sc = 'sci10_scg7_scf7';
sc = 'sci140_scg140_scf147';
path_out = ['/sb/scratch/yassinebha/database/twins_study/glm_fir/' sc '/'];

%% Generate the list of FIR responses
list_fir = dir([path_fir 'rois/fir_tseries*']);
list_fir = {list_fir.name};
for num_s = 1:length(list_fir)
    files_in.fir_all.(list_fir{num_s}(13:23)) = [path_fir 'rois/' list_fir{num_s}];
end

%% The atoms
files_in.atoms = [path_fir 'rois/brain_rois.mnc.gz'];

%% The target clusters
files_in.mask = [path_fir '/stability_group/' sc '/brain_partition_consensus_group_' sc '.mnc.gz'];

%% Options - Misc
opt.fdr = 0.05; % The maximal false-discovery rate that is tolerated both for individual (single-seed) maps and whole-connectome discoveries
opt.normalize.type = 'fir_shape';
opt.normalize.time_norm = 1;

%% Test : average FIR in the normal group
opt.test.average_normal.contrast.intercept = 1;
opt.test.average_normal.select.label = 'group0_minus_group1';
opt.test.average_normal.select.values = 0;

%% Test : average FIR in the "depressed" group
opt.test.average_depressed.contrast.intercept = 1;
opt.test.average_depressed.select.label = 'group0_minus_group1';
opt.test.average_depressed.select.values = 1;

%% Test : comparison between the normal and the "depressed" group
opt.test.dep_minus_norm.contrast.group0_minus_group1 = 1;
opt.test.dep_minus_norm.select.label = 'group0_and_group1';
opt.test.dep_minus_norm.select.values = 1;

%% Build the pipeline
list_test = fieldnames(opt.test);
pipeline = struct();
for num_t = 1:length(list_test);
    opt_tmp = opt;
    opt_tmp.test = struct;
    opt_tmp.test.(list_test{num_t}) = opt.test.(list_test{num_t});
    
    %% Where to store the results
    path_test = [path_out sc filesep list_test{num_t} '/'];
    files_out.results = [path_test 'glm_' list_test{num_t} '_' sc '.mat'];
    files_out.ttest = [path_test 'ttest_' list_test{num_t} '_' sc '.mnc.gz'];
    files_out.effect = [path_test 'effect_' list_test{num_t} '_' sc '.mnc.gz'];
    files_out.std_effect = [path_test 'std_' list_test{num_t} '_' sc '.mnc.gz'];
    files_out.fdr = [path_test 'fdr_' list_test{num_t} '_' sc '.mnc.gz'];
    files_out.perc_discovery = [path_test 'perc_disc_' list_test{num_t} '_' sc '.mnc.gz'];
    
    %% Run the analysis
    pipeline = psom_add_job(pipeline,list_test{num_t},'niak_brick_glm_fir',files_in,files_out,opt_tmp);
end
