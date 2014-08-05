% Script to run a STABILITY_FIR pipeline analysis on the twins database.
%
% Copyright (c) Pierre Bellec, Yassine Benhajali
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
%%%%%%%%%%%%%%%%%%%%%
%% Parameters
%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%
%% Grabbing the results from the NIAK fMRI preprocessing pipeline
%%%%%%%%%%%%%%%%%%%%%
opt_g.min_nb_vol     = 0;     % The minimum number of volumes for an fMRI dataset to be included. This option is useful when scrubbing is used, and the resulting time series may be too short.
opt_g.min_xcorr_func = 0.34; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of functional images in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
opt_g.type_files     = 'fir'; % Specify to the grabber to prepare the files for the STABILITY_FIR pipeline

%Temporary grabber for debugging
%liste_exclude = dir ([root_path 'fmri_preprocess/anat']);
%liste_exclude = liste_exclude(13:end -1);
%liste_exclude = {liste_exclude.name};
%opt_g.exclude_subject = liste_exclude;

files_in = niak_grab_fmri_preprocess([root_path 'fmri_preprocess'],opt_g);%  Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 

%%%%%%%%%%%%%%%%%%%%%
%% Event times
%%%%%%%%%%%%%%%%%%%%%
%% Set the timing of events;
files_in.timing = ['/home/' my_user_name '/svn/projects/twins/script/models/twins_stab_fir_timing.csv'];

%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%

%% BASC
opt.folder_out  = [root_path 'stability_fir_exp1' ]; % Where to store the results
opt.grid_scales = [10:10:100 120:20:200 240:40:500]' ; % Search for stable clusters in the range 10 to 500 
opt.scales_maps = [ 10   7   6 ;
                    20  16  18 ;
                    40  36  38 ;
                    80  80  83 ;
                   160 160 164 ;
                   320 288 296 ;
                   440 484 451 ]; 
opt.stability_fir.nb_samps   = 1;    % Number of bootstrap samples at the individual level. 100: the CI on indidividual stability is +/-0.1
opt.stability_fir.std_noise  = 0;     % The standard deviation of the judo noise. The value 0 will not use judo noise. 
opt.stability_group.nb_samps = 500;  % Number of bootstrap samples at the group level. 500: the CI on group stability is +/-0.05
opt.stability_fir.nb_min_fir = 1;    % the minimum response windows number. By defaut is set to 3

%% Set the conditions
opt.name_condition = 'sad';
opt.name_baseline  = 'rest';

%% FIR estimation 
opt.fir.type_norm         = 'fir_shape'; % The type of normalization of the FIR. "fir_shape" (starts at zero, unit sum-of-squares)or 'perc'(without normalisation)
opt.fir.time_window       = 246;          % The size (in sec) of the time window to evaluate the response, in this cas it correspond to 90 volumes for tr=3s
opt.fir.time_sampling     = 3;         % The time between two samples for the estimated response. Do not go below 1/2 TR unless there is a very large number of trials.
opt.fir.max_interpolation = 15;
opt.fir.nb_min_baseline   = 10;

%% FDR estimation
opt.nb_samps_fdr = 10000; % The number of samples to estimate the false-discovery rate

%%%%%%%%%%%%%%%%%%%%%%
%% Run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%
%opt.psom.qsub_options = '-q qwork@ms -l nodes=2,walltime=07:00:00';
opt.flag_test = false; % Put this flag to true to just generate the pipeline without running it. Otherwise the pipeline will start.
pipeline = niak_pipeline_stability_fir(files_in,opt);

%%extra
system(['cp ' mfilename('fullpath') '.m ' opt.folder_out '/.']); % make a copie of this script to output folder
system(['cp ' files_in.timing ' ' opt.folder_out '/.' ]); % make a copie of time events file used to output folder
