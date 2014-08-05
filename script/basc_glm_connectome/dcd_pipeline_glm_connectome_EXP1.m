
clear all
type_pre = 'EXP1';
root_path = '/home/benhajal/database/dcd_t1w_rest/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting input/output files %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opt_g.level = 'group';
opt_g.flag_tseries = true;
files_in = niak_grab_stability_rest([root_path 'basc_' type_pre],opt_g);
files_in.model.group = '/home/benhajal/svn/yassine/script/models/dcd/dcd_EXP1_basc_glm.csv';

%  clear opt_g
%  opt_g.min_nb_vol = 60;
%  %list_exc = load('/sb/scratch/cdansereau/cambridge/list_exclude_xp2.mat');
%  %opt_g.exclude_subject = list_exc.list_exclude;
%  %opt_g.exclude_subject = {'M_P_2038291','LPLB_1278618','TBED_2051302','L_L_12800105','F_D_2039587','L_L_12800105','D_P_2035225'};
%  files_in_ts = niak_grab_fmri_preprocess([root_path 'fmri_preprocess_' type_pre '/'],opt_g);
%  files_in.fmri = files_in_ts.data;

%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%
opt.folder_out = [root_path 'glm_ref_' type_pre '/glm_connectome_' type_pre 'DCD_vs_cont/']; % Where to store the results
opt.flag_global_avg = false;
opt.fdr = 0.1;
opt.nb_samps = 1000;
opt.nb_batch = 10;
opt.flag_rand = false; % if the flag is false, the pipeline is deterministic. Otherwise, the random number generator is initialized based on the clock for each job.
opt.min_nb_vol = 60;
%%%%%%%%%%%
%% TESTS %%
%%%%%%%%%%%


% DCD vs ctrl (DCD=1, ctrl=0) 
opt.test.dcdVSctrl.group.contrast.Group = 1;

% DCD vs ctrl  regressing out age
opt.test.dcdVSctrl_age.group.contrast.Group      = 1;
opt.test.dcdVSctrl_age.group.contrast.Age_MRI    = 0;

% DCD vs ctrl  regressing out puberty score
opt.test.dcdVSctrl_pub.group.contrast.Group      = 1;
opt.test.dcdVSctrl_pub.group.contrast.Puberty    = 0;

% DCD average maps
opt.test.dcd_avg.group.select(1).label           = 'Group';
opt.test.dcd_avg.group.select(1).values          = 1;
opt.test.dcd_avg.group.contrast.intercept        = 1;

% DCD average maps regressing out age
opt.test.dcd_avg_age.group.select(1).label       = 'Group';
opt.test.dcd_avg_age.group.select(1).values      = 1;
opt.test.dcd_avg_age.group.contrast.intercept    = 1;
opt.test.dcd_avg_age.group.contrast.Age_MRI      = 0;

% CTRL average maps
opt.test.ctrl_avg.group.select(1).label          = 'Group';
opt.test.ctrl_avg.group.select(1).values         = 0;
opt.test.ctrl_avg.group.contrast.intercept       = 1;

% CTRL average maps regressing out puberty score
opt.test.ctrl_avg_pub.group.select(1).label      = 'Group';
opt.test.ctrl_avg_pub.group.select(1).values     = 0;
opt.test.ctrl_avg_pub.group.contrast.intercept   = 1;
opt.test.ctrl_avg_pub.group.contrast.Puberty     = 0;


%  opt.psom.restart = {'glm'};
%  opt.psom.restart = {'summary'}
%  opt.psom.qsub_options = '-q lm -l walltime=5:00:00';
%%%%%%%%%%%%%%%%%%%%%%
%% Run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%
opt.flag_test  = false;
[pipeline,opt] = niak_pipeline_glm_connectome(files_in,opt);

%% extra %%
system(['cp ' mfilename('fullpath') '.m ' opt.folder_out '.']); % make a copie of this script to output folder
system(['cp ' files_in.model.group ' ' opt.folder_out '.']); % make a copie of model.csv file used by this script to output folder
