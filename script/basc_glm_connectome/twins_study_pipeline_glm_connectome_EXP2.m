
clear all
type_pre = 'EXP2';
root_path = '/sb/scratch/yassinebha/database/twins_study/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting input/output files %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opt_g.level = 'group';
opt_g.flag_tseries = true;
files_in = niak_grab_stability_rest([root_path 'basc_' type_pre],opt_g);
files_in.model.group = '/home/yassinebha/svn/yassine/script/models/twins/dominic_dep_group0a1_minus_group10a14.csv';

%  clear opt_g
%  opt_g.min_nb_vol = 70;
%  %list_exc = load('/sb/scratch/cdansereau/cambridge/list_exclude_xp2.mat');
%  %opt_g.exclude_subject = list_exc.list_exclude;
%  %opt_g.exclude_subject = {'M_P_2038291','LPLB_1278618','TBED_2051302','L_L_12800105','F_D_2039587','L_L_12800105','D_P_2035225'};
%  opt_g.exclude_subject ={'S_D_2063084','K_B_2069160','M_D_2087771','SJB_2054082','A_M_2051300','A_P_2038290','O_G_2089782','A_L_2065306','V_L_2065305','K_P_2055338','C_N_2068592','AJP_2060198','J_H_2067477'};
%  opt_g.min_xcorr_func = 0.34;
%  files_in_ts = niak_grab_fmri_preprocess([root_path 'fmri_preprocess_' type_pre '/'],opt_g);
%  files_in.fmri = files_in_ts.data;

%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%
opt.folder_out = [root_path 'glm_ref_' type_pre '/glm_connectome_' type_pre '_goup0_1_vs_10_14/']; % Where to store the results
opt.flag_global_avg = false;
opt.fdr = 0.1;
opt.nb_samps = 1000;
opt.nb_batch = 10;
opt.flag_rand = false; % if the flag is false, the pipeline is deterministic. Otherwise, the random number generator is initialized based on the clock for each job.
opt.min_nb_vol = 70;
%%%%%%%%%%%
%% TESTS %%
%%%%%%%%%%%

% Effect of dominc R:test(group_0:0-1;group_1:10-14)

opt.test.depressif.group.select.all_select_group = 1;
opt.test.depressif.group.contrast.group0to1_vs_group10to14 = 1;



opt.psom.qsub_options = '-q lm -l walltime=6:00:00';
%%%%%%%%%%%%%%%%%%%%%%
%% Run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%
opt.flag_test  = false;
[pipeline,opt] = niak_pipeline_glm_connectome(files_in,opt);
system(['cp ' mfilename('fullpath') '.m ' opt.folder_out '.']); % make a copie of this script to output folder
system(['cp ' files_in.model.group ' ' opt.folder_out '.']); % make a copie of model.csv file used by this script to output folder
