
clear
type_pre = 'exp2';
network_ref = 'exp2';
root_path = '/sb/scratch/yassinebha/database/twins_study/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting input/output files %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opt_g.level = 'group';
opt_g.flag_tseries = false;
files_in = niak_grab_stability_rest([root_path 'basc_' network_ref],opt_g);
files_in.model = [root_path 'models/dominic_exp2.csv'];

clear opt_g
opt_g.min_nb_vol = 70;
%list_exc = load('/sb/scratch/cdansereau/cambridge/list_exclude_xp2.mat');
%opt_g.exclude_subject = list_exc.list_exclude;
%opt_g.exclude_subject = {'M_P_2038291','LPLB_1278618','TBED_2051302','L_L_12800105','F_D_2039587','L_L_12800105','D_P_2035225'};
opt_g.min_xcorr_func = 0.34;
files_in_ts = niak_grab_fmri_preprocess([root_path 'fmri_preprocess_' type_pre '/'],opt_g);
files_in.fmri = files_in_ts.data;

%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%
opt.folder_out = [root_path 'glm_ref_' network_ref '/glm_connectome_' type_pre '/']; % Where to store the results
opt.flag_global_avg = false;
opt.fdr = 0.1;

%%%%%%%%%%%
%% TESTS %%
%%%%%%%%%%%

% Effect of dominc R: three group for MDD Dominc score (group_1:0-10;group_2:11-13;group_3:14-20)
opt.test(1).label = 'group3_minus_group1';
opt.test(1).contrast.group_1_vs_3 = 1;
opt.test(1).select.label = 'group_1_3';
opt.test(1).select.values = 1;
%opt.test(1).type_normalization  = 'med_mad';


opt.psom.restart = {'glm'};
opt.psom.restart = {'summary'}


%%%%%%%%%%%%%%%%%%%%%%
%% Run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%
opt.flag_test  = false;
[pipeline,opt] = niak_pipeline_glm_connectome(files_in,opt);

