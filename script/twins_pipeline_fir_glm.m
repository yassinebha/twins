% Script to run a GLM_FIR pipeline analysis on the twins database.
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
else
    root_path = '/media/database3/twins_study/';
    fprintf ('server: %s\n',server)
    my_user_name = 'yassinebha';
end
path_twins.fmri_preprocess = [ root_path 'fmri_preprocess' filesep];
path_twins.stability_fir   = [ root_path 'stability_fir_exp1' filesep];

%% Grabbing the results from the NIAK fMRI preprocessing and stab_fir
opt_g.min_nb_vol     = 0;     % The minimum number of volumes for an fMRI dataset to be included. This option is useful when scrubbing is used, and the resulting time series may be too short.
opt_g.min_xcorr_func = 0.34; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of functional images in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
opt_g.type_files     = 'fir'; % Specify to the grabber to prepare the files for the STABILITY_FIR pipeline
files_in             = rmfield(niak_grab_fmri_preprocess(path_twins.fmri_preprocess,opt_g),{'mask','areas'}); 
files_in.networks    = niak_grab_stability_fir(path_twins.stability_fir).networks ;

%% Set the models
files_in.model.group      = ['/home/' my_user_name '/svn/projects/twins/script/models/twins_dominic_interactive_dep.csv'];
files_in.model.individual = ['/home/' my_user_name '/svn/projects/twins/script/models/twins_stab_fir_timing.csv'];

%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%
opt.folder_out = [path_twins.stability_fir,'glm_fir_dep/'];
opt.fdr        = 0.05; % The maximal false-discovery rate that is tolerated both for individual (single-seed) maps and whole-connectome discoveries, at each particular scale (multiple comparisons across scales are addressed via permutation testing)
opt.fwe        = 0.05; % The overall family-wise error, i.e. the probablity to have the observed number of discoveries, agregated across all scales, under the global null hypothesis of no association.
opt.nb_samps   = 1000; % The number of samples in the permutation test. This number has to be multiplied by OPT.NB_BATCH below to get the effective number of samples
opt.nb_batch   = 10; % The permutation tests are separated into NB_BATCH independent batches, which can run on parallel if sufficient computational resources are available

%% FIR estimation 
opt.fir.type_norm         = 'fir_shape'; % The type of normalization of the FIR. "fir_shape" (starts at zero, unit sum-of-squares)or 'perc'(without normalisation)
opt.fir.time_window       = 246;          % The size (in sec) of the time window to evaluate the response, in this cas it correspond to 90 volumes for tr=3s
opt.fir.time_sampling     = 3;         % The time between two samples for the estimated response. Do not go below 1/2 TR unless there is a very large number of trials.
opt.fir.max_interpolation = 60;
opt.fir.nb_min_baseline   = 10;
opt.fir.name_condition    = 'sad';
opt.fir.name_baseline     = 'rest';

%%%%%%%%%%%
%% TESTS %%
%%%%%%%%%%%  

% Comparisons between groups

%%hdi_dep
opt.test.hdi_dep.contrast.hdi_dep     = 1;
opt.test.hdi_dep.contrast.hdi_dep2    = 0; 
opt.test.hdi_dep.contrast.sexe        = 0;    
opt.test.hdi_dep.contrast.FD_scrubbed = 0;
opt.test.hdi_dep.interaction.label    = 'hdi_dep2';
opt.test.hdi_dep.interaction.factor   = {'hdi_dep','hdi_dep'};

%%hdi_dep2
opt.test.hdi_dep2.contrast.hdi_dep     = 0;
opt.test.hdi_dep2.contrast.hdi_dep2    = 1;    
opt.test.hdi_dep2.contrast.sexe        = 0;    
opt.test.hdi_dep2.contrast.FD_scrubbed = 0;
opt.test.hdi_dep2.interaction.label    = 'hdi_dep2';
opt.test.hdi_dep2.interaction.factor   = {'hdi_dep','hdi_dep'};

%%dominic_dep_AA : control_dep vs pathologic_dep after regressing out sex and FD
opt.test.dep_vs_ctlAA.contrast.dep_group   = 1;
opt.test.dep_vs_ctlAA.contrast.sexe        = 0;    
opt.test.dep_vs_ctlAA.contrast.FD_scrubbed = 0; 

%%dominic_dep_AA1 : control_dep vs pathologic_dep after regressing out sex
opt.test.dep_vs_ctlAA1.contrast.dep_group = 1;
opt.test.dep_vs_ctlAA1.contrast.sexe      = 0;    

%%dominic_dep_AA2 : control_dep vs pathologic_dep after regressing out  FD
opt.test.dep_vs_ctlAA2.contrast.dep_group  = 1;    
opt.test.dep_vs_ctlAA2.contrast.FD_scrubbed = 0;  

%%dominic_dep_AA3 : control_dep vs pathologic_dep
opt.test.dep_vs_ctlAA3.contrast.dep_group = 1;

%%dominic_dep_AB : control_dep (AND-low internalizing/externalizing score) vs pathologic_dep after regressing out sex and FD
opt.test.dep_vs_ctlAB.contrast.dep_group1  = 1;
opt.test.dep_vs_ctlAB.contrast.sexe        = 0;    
opt.test.dep_vs_ctlAB.contrast.FD_scrubbed = 0;
opt.test.dep_vs_ctlAB.select(1).label      = 'dep_group1'; 
opt.test.dep_vs_ctlAB.select(1).values     = [0 1];

%%dominic_dep_AB3 : control_dep (AND-low internalizing/externalizing score) vs pathologic_dep
opt.test.dep_vs_ctlAB3.contrast.dep_group1 = 1;
opt.test.dep_vs_ctlAB3.select(1).label     = 'dep_group1'; 
opt.test.dep_vs_ctlAB3.select(1).values    = [0 1];

%%dominic_dep_AB4 : control_dep (AND-low internalizing/externalizing score) vs pathologic_dep with medium(maybe) subsyndromal score after regressing out sex and FD
opt.test.dep_vs_ctlAB4.contrast.dep_group2  = 1;
opt.test.dep_vs_ctlAB4.contrast.sexe        = 0;    
opt.test.dep_vs_ctlAB4.contrast.FD_scrubbed = 0;
opt.test.dep_vs_ctlAB4.select(1).label      = 'dep_group2'; 
opt.test.dep_vs_ctlAB4.select(1).values     = [0 1];

%%dominic_dep_AB5 : control_dep (AND-low internalizing/externalizing score) vs pathologic_dep with medium(maybe) subsyndromal score
opt.test.dep_vs_ctlAB5.contrast.dep_group2  = 1;
opt.test.dep_vs_ctlAB5.select(1).label      = 'dep_group2'; 
opt.test.dep_vs_ctlAB5.select(1).values     = [0 1];

%%dominic_dep_AC : control_dep (AND-low internalizing/externalizing score) vs pathologic_dep combined with pathologic oppositional defiant disorer
opt.test.dep_vs_ctlAC.contrast.dep_group3 = 1;
opt.test.dep_vs_ctlAC.select(1).label     = 'dep_group3'; 
opt.test.dep_vs_ctlAC.select(1).values    = [0 1];

%%%%%%%%%%%%%%%%%%%%%%
%% Run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%
opt.flag_test  = false;
opt.psom.flag_pause = true;
[pipeline,opt_pipe] = niak_pipeline_glm_fir(files_in,opt);
system(['cp ' mfilename('fullpath') '.m ' opt.folder_out '.']); % make a copie of this script to output folder