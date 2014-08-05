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
% peuplier 
path_twins.fmri_preprocess = '/media/database3/twins_study/fmri_preprocess_EXP2_test1';
path_twins.stability_fir= '/media/database3/twins_study/stability_fir_all_sad_blocs_EXP2_test1/';
%mammouth
%path_twins.fmri_preprocess = '/mnt/scratch/bellec/bellec_group/twins/fmri_preprocess_EXP2_test1';
%path_twins.stability_fir= '/mnt/scratch/bellec/bellec_group/twins/stability_fir_all_sad_blocs_EXP2_test1/';

niak_gb_vars
path_twins = psom_struct_defaults(path_twins,{'fmri_preprocess','stability_fir'},{NaN,NaN});
path_twins.fmri_preprocess = niak_full_path(path_twins.fmri_preprocess);
path_twins.stability_fir = niak_full_path(path_twins.stability_fir);
opt = struct();
opt = psom_struct_defaults(opt,{'folder_out'},{[path_twins.stability_fir,'glm_fir_roi',filesep]},false);
opt.folder_out = niak_full_path(opt.folder_out);

%% Grab the results from the NIAK fMRI preprocessing pipeline
opt_g.min_nb_vol = 0;     % The minimum number of volumes for an fMRI dataset to be included. This option is useful when scrubbing is used, and the resulting time series may be too short.
opt_g.min_xcorr_func = 0.34; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of functional images in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
opt_g.type_files = 'fir'; % Specify to the grabber to prepare the files for the STABILITY_FIR pipeline
%opt_g.exclude_subject = {'TBED2051302'};
files_in = rmfield(niak_grab_fmri_preprocess(path_twins.fmri_preprocess,opt_g),{'mask','areas'}); 

%% Now grab the results from the STABILITY_FIR pipeline
%  files_in.networks = niak_grab_stability_fir(path_twins.stability_fir).networks ;
%% grab only selected scale for ROI analysis
files_in.networks.sci140_scg140_scf151 = niak_grab_stability_fir(path_twins.stability_fir).networks.sci140_scg140_scf151 ;

%% select region of interst
[hdr,vol] = niak_read_vol(files_in.networks.sci140_scg140_scf151);
vol2 = zeros(size(vol));
vol2(vol==124) = 124; % Caudate anterior cingulate (l/r)
vol2(vol==140) = 140; % precuneus (l/r)
vol2(vol==102) = 102; % Rostral anterior cingulate (l/r)
hdr.file_name = ([ char(files_in.networks.sci140_scg140_scf151(1:end-7)) '_roi.mnc.gz']);
niak_write_vol(hdr,vol2);
files_in.networks.sci140_scg140_scf151 = hdr.file_name;

%% Set the timing of events;
%peuplier
files_in.model.group      = '/home/yassinebha/svn/yassine/script/models/twins/dominic_dep_group0a6_minus_group11a20.csv';
files_in.model.individual ='/home/yassinebha/svn/yassine/script/basc_fir/twins_timing_EXP2_test1_all_sad_blocs_neut_ref.csv';
%mammouth
%files_in.model.group      = '/home/benhajal/svn/yassine/script/models/twins/dominic_dep_group0a6_minus_group11a20.csv';
%files_in.model.individual ='/home/benhajal/svn/yassine/script/basc_fir/twins_timing_EXP2_test1_all_sad_blocs_neut_ref.csv';
%% FIR estimation 
opt.fir.type_norm     = 'fir_shape'; % The type of normalization of the FIR. "fir_shape" (starts at zero, unit sum-of-squares)or 'perc'(without normalisation)
opt.fir.time_window   = 246;          % The size (in sec) of the time window to evaluate the response, in this cas it correspond to 90 volumes for tr=3s
opt.fir.time_sampling = 3;         % The time between two samples for the estimated response. Do not go below 1/2 TR unless there is a very large number of trials.
opt.fir.max_interpolation = 60;
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
   
 % Test : comparison between the normal and the "depressed" 
   opt.test.group0_minus_group1.contrast.group0_minus_group1 = 1;
   opt.test.group0_minus_group1.select.label = 'group0_and_group1';
   opt.test.group0_minus_group1.select.values = 1;   
   
 % Test : comparison between the normal and the "depressed" group after regressing out sex 
   opt.test.group0_minus_group1_s.contrast.group0_minus_group1 = 1;
   opt.test.group0_minus_group1_s.select.label = 'group0_and_group1';
   opt.test.group0_minus_group1_s.select.values = 1;
   opt.test.group0_minus_group1_s.contrast.sexe = 0;
   
 % dominic_dep
   opt.test.dominic_dep.contrast.dominic_dep= 1;
   
 % dominic_dep after regressing out sex 
   opt.test.dominic_dep_s.contrast.dominic_dep= 1;   
   opt.test.dominic_dep_s.contrast.sexe = 0;
   
 % dominic_dep_group1
   opt.test.dominic_dep_group1.select.label = 'group0_minus_group1';
   opt.test.dominic_dep_group1.select.values = 1;
   opt.test.dominic_dep_group1.contrast.dominic_dep= 1;

 % dominic_dep_group1 and regressing out sex
   opt.test.dominic_dep_group1_s.select.label = 'group0_minus_group1';
   opt.test.dominic_dep_group1_s.select.values = 1;
   opt.test.dominic_dep_group1_s.contrast.dominic_dep= 1;
   opt.test.dominic_dep_group1_s.contrast.sexe= 0;
   
 % dominic_dep_group0
   opt.test.dominic_dep_group0.select.label = 'group0_minus_group1';
   opt.test.dominic_dep_group0.select.values = 0;
   opt.test.dominic_dep_group0.contrast.dominic_dep= 1;

 % dominic_dep_group0 and regressing out sex
   opt.test.dominic_dep_group0_s.select.label = 'group0_minus_group1';
   opt.test.dominic_dep_group0_s.select.values = 0;
   opt.test.dominic_dep_group0_s.contrast.dominic_dep= 1;
   opt.test.dominic_dep_group0_s.contrast.sexe= 0;

 % dominic_dep_inter_group1VS0
   opt.test.dominic_dep_inter_group1VS0.interaction.label = 'dom_dep_inter_group1VS0';
   opt.test.dominic_dep_inter_group1VS0.interaction.factor = {'dominic_dep','group0_minus_group1'};
   opt.test.dominic_dep_inter_group1VS0.select.label = 'group0_minus_group1';
   opt.test.dominic_dep_inter_group1VS0.select.values = [0 1];
   opt.test.dominic_dep_inter_group1VS0.contrast.dom_dep_inter_group1VS0 = 1;
   opt.test.dominic_dep_inter_group1VS0.contrast.sexe= 0;
   
% The permutation tests
opt.nb_samps = 100;
opt.nb_batch = 3;

%% Generate the pipeline
[pipeline,opt_pipe] = niak_pipeline_glm_fir(files_in,opt);

%%extra
system(['cp ' mfilename('fullpath') '.m ' opt.folder_out '.']); % make a copie of this script to output folder
