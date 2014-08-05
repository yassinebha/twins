% Script to run a GLM_CONECTOM pipeline analysis on the twins database.
%
% Copyright (c) Pierre Bellec, 
%   Research Centre of the Montreal Geriatric Institute
%   & Department of Computer Science and Operations Research
%   University of Montreal, Québec, Canada, 2010-2012
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : fMRI, FIR, clustering, BASC
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.
clear all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting root path for selected server%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setting input/output files 
[status,cmdout] = system ('uname -n');
server          = strtrim(cmdout);
if strfind(server,'lg-1r') % This is guillimin
    root_path = '/gs/scratch/yassinebha/twins/';
    fprintf ('server: %s\n',server)
    my_user_name = 'yassinebha';
elseif strfind(server,'ip05') % this is mammouth
    root_path = '/mnt/parallel_scratch_ms2_wipe_on_april_2014/pbellec/benhajal/twins/';
    fprintf ('server: %s\n',server)
    my_user_name = 'benhajal';
else % this is peuplier
    root_path = '/media/database3/twins_study/';
    fprintf ('server: %s\n',server)
    my_user_name = 'yassinebha';
end
%%%%%%%%%%%%
%% Grabbing the results from BASC
%%%%%%%%%%%%
files_in = niak_grab_stability_rest([root_path 'basc_exp1']);

%%%%%%%%%%%%
%% Grabbing the results from the NIAK fMRI preprocessing pipeline
%%%%%%%%%%%%
opt_g.min_nb_vol = 100;     % The minimum number of volumes for an fMRI dataset to be included. This option is useful when scrubbing is used, and the resulting time series may be too short.
opt_g.type_files = 'glm_connectome'; % Specify to the grabber to prepare the files for the glm_connectome pipeline
files_in.fmri = niak_grab_fmri_preprocess([root_path 'fmri_preprocess'],opt_g).fmri; % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 

%%%%%%%%%%%%
%% Set the models
%%%%%%%%%%%%
%individual models and raw group model
subj= fieldnames(files_in.fmri);    
for n= 1:length(subj)
    files_in.model.individual.(subj{n}).intra_run.session1.run1.event= ['/home/' my_user_name '/svn/projects/twins/script/models/twins_model_intra_run.csv'];
end
files_in.model.group      = ['/home/' my_user_name '/svn/projects/twins/script/models/twins_dominic_interactive_dep.csv'];

%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%
opt = struct();
opt = psom_struct_defaults(opt,{'folder_out'},{[root_path 'glm_connectome_exp2']},false);
opt.folder_out = niak_full_path(opt.folder_out);
opt.fdr = 0.05; % The maximal false-discovery rate that is tolerated both for individual (single-seed) maps and whole-connectome discoveries, at each particular scale (multiple comparisons across scales are addressed via permutation testing)
opt.fwe = 0.05; % The overall family-wise error, i.e. the probablity to have the observed number of discoveries, agregated across all scales, under the global null hypothesis of no association.
opt.nb_samps = 1000; % The number of samples in the permutation test. This number has to be multiplied by OPT.NB_BATCH below to get the effective number of samples
opt.nb_batch = 10; % The permutation tests are separated into NB_BATCH independent batches, which can run on parallel if sufficient computational resources are available
opt.flag_rand = false; % if the flag is false, the pipeline is deterministic. Otherwise, the random number generator is initialized based on the clock for each job.

%%%%%%%%%%%
%% TESTS %%
%%%%%%%%%%%  

% Main effects of blocs
%% neutral
opt.test.main_neutral.group.contrast.intercept           = 1;
opt.test.main_neutral.intra_run.type                     = 'correlation';
opt.test.main_neutral.intra_run.select(1).label          = 'neutral';
opt.test.main_neutral.intra_run.select(1).min            = 0.9;

%% sad
opt.test.main_sad.group.contrast.intercept              = 1;
opt.test.main_sad.intra_run.type                        = 'correlation';
opt.test.main_sad.intra_run.select(1).label             = 'sad';
opt.test.main_sad.intra_run.select(1).min               = 0.9;

% Comparisons between Blocs
opt.test.neutral_VS_sad.group.contrast.intercept        = 1;
opt.test.neutral_VS_sad.intra_run.type                  = 'correlation';
opt.test.neutral_VS_sad.intra_run.select(1).label       = 'neutral';
opt.test.neutral_VS_sad.intra_run.select(1).min         = 0.9;
opt.test.neutral_VS_sad.intra_run.select_diff(1).label  = 'sad';
opt.test.neutral_VS_sad.intra_run.select_diff(1).min    = 0.9;


% Comparisons between short Blocs
opt.test.neutral_short_VS_sad_short.group.contrast.intercept        = 1;
opt.test.neutral_short_VS_sad_short.intra_run.type                  = 'correlation';
opt.test.neutral_short_VS_sad_short.intra_run.select(1).label       = 'neutral_short';
opt.test.neutral_short_VS_sad_short.intra_run.select(1).min         = 0.9;
opt.test.neutral_short_VS_sad_short.intra_run.select_diff(1).label  = 'sad_short';
opt.test.neutral_short_VS_sad_short.intra_run.select_diff(1).min    = 0.9;

% Comparisons within short short neutral blocs
opt.test.neutral_p1p2.group.contrast.intercept        = 1;
opt.test.neutral_p1p2.intra_run.type                  = 'correlation';
opt.test.neutral_p1p2.intra_run.select(1).label       = 'neutral_p1';
opt.test.neutral_p1p2.intra_run.select(1).min         = 0.9;
opt.test.neutral_p1p2.intra_run.select_diff(1).label  = 'neutral_p2';
opt.test.neutral_p1p2.intra_run.select_diff(1).min    = 0.9;

% Comparisons within short short sad blocs
opt.test.sad_p1p2.group.contrast.intercept        = 1;
opt.test.sad_p1p2.intra_run.type                  = 'correlation';
opt.test.sad_p1p2.intra_run.select(1).label       = 'sad_p1';
opt.test.sad_p1p2.intra_run.select(1).min         = 0.9;
opt.test.sad_p1p2.intra_run.select_diff(1).label  = 'sad_p2';
opt.test.sad_p1p2.intra_run.select_diff(1).min    = 0.9;


%%%%%%%%%%%%%%%%%%%%%%
%% Run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%
opt.psom.qsub_options = '-A gsf-624-aa -q sw -l nodes=1:ppn=2 -l walltime=10:00:00';     
opt.flag_test           = false;
opt.psom.flag_pause     = false;
[pipeline,opt] = niak_pipeline_glm_connectome(files_in,opt);

%extra
system(['cp ' mfilename('fullpath') '.m ' opt.folder_out '.']); % make a copie of this script to output folder
system(['mv ' files_in.model.group  ' ' opt.folder_out '.']); % move th generated model file  to output folder
