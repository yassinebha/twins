
clear
type_pre = 'exp1';
network_ref = 'exp1';
root_path = '/sb/scratch/yassinebha/database/twins_study/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting input/output files %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opt_g.level = 'group';
opt_g.flag_tseries = false;
files_in = niak_grab_stability_rest([root_path 'basc_' network_ref],opt_g);
files_in.model = [root_path 'models/dominic_exp1.csv'];

clear opt_g
opt_g.min_nb_vol = 70;
%list_exc = load('/sb/scratch/cdansereau/cambridge/list_exclude_xp2.mat');
%opt_g.exclude_subject = list_exc.list_exclude;
opt_g.exclude_subject = {'M_P_2038291','LPLB_1278618','TBED_2051302','L_L_12800105','F_D_2039587','L_L_12800105','D_P_2035225'};
opt_g.min_xcorr_func = 0.39;
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

% Effect of age alone
opt.test(1).label               = 'diff_dominic';
opt.test(1).contrast.dominic    = 1;
opt.test(1).type_normalization  = 'med_mad';


opt.psom.restart = {'glm'};
opt.psom.restart = {'summary'}


%%%%%%%%%%%%%%%%%%%%%%
%% Run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%
opt.flag_test  = false;
[pipeline,opt] = niak_pipeline_glm_connectome(files_in,opt);

