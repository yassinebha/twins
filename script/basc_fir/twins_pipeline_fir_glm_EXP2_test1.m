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

clear 
path_twins.fmri_preprocess = '/mnt/scratch/bellec/bellec_group/twins/fmri_preprocess_EXP2_test1';
path_twins.stability_fir= '/mnt/scratch/bellec/bellec_group/twins/stability_fir_all_sad_blocs_EXP2_test1/';

niak_gb_vars
path_twins = psom_struct_defaults(path_twins,{'fmri_preprocess','stability_fir'},{NaN,NaN});
path_twins.fmri_preprocess = niak_full_path(path_twins.fmri_preprocess);
path_twins.stability_fir = niak_full_path(path_twins.stability_fir);
opt = struct();
opt = psom_struct_defaults(opt,{'folder_out'},{[path_twins.stability_fir,'glm_fir',filesep]},false);
opt.folder_out = niak_full_path(opt.folder_out);

%% Grab the results from the NIAK fMRI preprocessing pipeline
opt_g.min_nb_vol = 0;     % The minimum number of volumes for an fMRI dataset to be included. This option is useful when scrubbing is used, and the resulting time series may be too short.
opt_g.min_xcorr_func = 0.34; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of functional images in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
opt_g.type_files = 'fir'; % Specify to the grabber to prepare the files for the STABILITY_FIR pipeline

files_in = rmfield(niak_grab_fmri_preprocess(path_twins.fmri_preprocess,opt_g),{'mask','areas'}); 

%% Now grab the results from the STABILITY_FIR pipeline
files_in.networks = niak_grab_stability_fir(path_twins.stability_fir).networks;

%% Set the timing of events;
files_in.model.group      = '/home/benhajal/svn/yassine/script/models/twins/dominic_dep_group0a1_minus_group11a20.csv';
files_in.model.individual ='/home/benhajal/svn/yassine/script/basc_fir/twins_timing_EXP2_test2_all_sad_blocs.csv';

%% FIR estimation 
opt.fir.type_norm     = 'fir_shape'; % The type of normalization of the FIR. "fir_shape" (starts at zero, unit sum-of-squares)or 'perc'(without normalisation)
opt.fir.time_window   = 246;          % The size (in sec) of the time window to evaluate the response, in this cas it correspond to 90 volumes for tr=3s
opt.fir.time_sampling = 3;         % The time between two samples for the estimated response. Do not go below 1/2 TR unless there is a very large number of trials.
opt.fir.max_interpolation = 45;
opt.fir.nb_min_baseline = 10;
opt.fir.name_condition = 'sad';
opt.fir.name_baseline  = 'rest';

%% The tests

% Test : average FIR in the normal group
   opt.test.average_group0.contrast.intercept = 1;
   opt.test.average_group0.select.label = 'group0_minus_group1';
   opt.test.average_group0.select.values = 0;

 % Test : average FIR in the "depressed" group
   opt.test.average_group1.contrast.intercept = 1;
   opt.test.average_group1.select.label = 'group0_minus_group1';
   opt.test.average_group1.select.values = 1;
   
   
 % Test : comparison between the normal and the "depressed" group
   opt.test.group0_minus_group1.contrast.group0_minus_group1 = 1;
   opt.test.group0_minus_group1.select.label = 'group0_and_group1';
   opt.test.group0_minus_group1.select.values = 1;
  

 % dominic_dep
   opt.test.dominic_dep.contrast.dominic_dep= 1;



% The permutation tests
opt.nb_samps = 1;
opt.nb_batch = 1;

%% Generate the pipeline
[pipeline,opt_pipe] = niak_pipeline_glm_fir(files_in,opt);

%%extra
system(['cp ' mfilename('fullpath') '.m ' opt.folder_out '.']); % make a copie of this script to output folder
system(['cp ' files_in.model ' ' opt.folder_out '.' ]); % make a copie of time events file used to output folder
save ([opt.folder_out 'pipiline_envir.mat']);
