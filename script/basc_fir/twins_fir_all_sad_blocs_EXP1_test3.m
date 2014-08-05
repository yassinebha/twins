% Script to run a STABILITY_FIR pipeline analysis on the twins database.
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

%%%%%%%%%%%%%%%%%%%%%
%% Grabbing the results from the NIAK fMRI preprocessing pipeline
%%%%%%%%%%%%%%%%%%%%%
ext = 'EXP2';
opt_g.exclude_subject = {'C_R_2049900_session1' 'E_C_2076689_session1' 'E_R_2037194_session1' 'F_E_2072774_session2' 'J_B_2064232_session2' 'J_H_2067477_session2' 'J_R_2053029_session1' 'KAC_2037803_session2' 'LPL_1278618_session2' 'MPV_2076687_session2' 'M_A_2061811_session2' 'M_H_2037806_session1' 'TBED_2051302_session2' 'A_A_2071574_session1' 'A_P_2058893_session1' 'C_J_2080359_session1' 'D_C_2082280_session1' 'E_G_2048018_session1' 'F_D_2039587_session1' 'J_C_2033780_session1' 'J_T_2047402_session2' 'AJP_2060198_session1' 'A_A_2071574_session1' 'A_L_2065306_session1' 'A_M_2051300_session1' 'A_P_2038290_session1' 'C_N_2068592_session1' 'J_H_2067477_session2' 'K_B_2069160_session1' 'K_P_2055338_session1' 'M_D_2087771_session1' 'O_G_2089782_session1' 'S_F_2034453_session1' 'V_L_2065305_session1'}
opt_g.max_translation = 3 ; % the maximal transition (difference between two adjacent volumes) in translation motion parameters within-run (in mm)
opt_g.max_rotation = 3 ; % the maximal transition (difference between two adjacent volumes) in rotation motion parameters within-run (in degrees)
opt_g.type_files = 'fir'; % Specify to the grabber to prepare the files for the STABILITY_FIR pipeline
files_in = niak_grab_fmri_preprocess(['/sb/scratch/yassinebha/database/twins_study/fmri_preprocess_' ext ],opt_g);%  Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 
%%%%%%%%%%%%%%%%%%%%%
%% Event times
%%%%%%%%%%%%%%%%%%%%%

% The file for the final "clean" analysis with a TR of 3 sec
files_in.timing ='/home/yassinebha/svn/yassine/script/basc_fir/twins_timing_EXP2_all_sad_blocs.mat';

%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%

%% BASC
opt.folder_out = ['/sb/scratch/yassinebha/database/twins_study/stability_fir_all_sad_blocs_' ext '/']; % Where to store the results
opt.grid_scales = [10:10:100 120:20:200 240:40:500]' ; % Search for stable clusters in the range 10 to 500 
opt.scales_maps = [ 10   7   7 ; 
                    20  16  18 ; 
                    40  36  38 ; 
                    80  72  73 ; 
                   140 140 147 ; 
                   240 264 268 ; 
                   440 440 339 ]; 
opt.stability_fir.nb_samps = 1;    % Number of bootstrap samples at the individual level. 100: the CI on indidividual stability is +/-0.1
opt.stability_fir.std_noise = 0;     % The standard deviation of the judo noise. The value 0 will not use judo noise. 
opt.stability_group.nb_samps = 500;  % Number of bootstrap samples at the group level. 500: the CI on group stability is +/-0.05

%% FIR estimation 
opt.fir.type_norm     = 'perc'; % The type of normalization of the FIR. "fir_shape" (starts at zero, unit sum-of-squares)or 'perc'(without normalisation)
opt.fir.time_norm     = 15;           % The time window (in sec) to define the 0 value
opt.stability_fir.nb_min_fir = 1;    % the minimum response windows number. By defaut is set to 3
opt.fir.time_window   = 270;          % The size (in sec) of the time window to evaluate the response, in this cas it correspond to 90 volumes for tr=3s
opt.fir.time_sampling = 3;         % The time between two samples for the estimated response. Do not go below 1/2 TR unless there is a very large number of trials.

%% FDR estimation
opt.nb_samps_fdr = 10000; % The number of samples to estimate the false-discovery rate

%% Multi-level options
opt.flag_ind = false;   % Generate maps/FIR at the individual level
opt.flag_mixed = false; % Generate maps/FIR at the mixed level (group-level networks mixed with individual stability matrices).
opt.flag_group = true;  % Generate maps/FIR at the group level

%%%%%%%%%%%%%%%%%%%%%%
%% Run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%
opt.psom.qsub_options = '-q lm -l walltime=7:00:00';
opt.flag_test = false; % Put this flag to true to just generate the pipeline without running it. Otherwise the pipeline will start.
%opt.psom.max_queued = 10; % Uncomment and change this parameter to set the number of parallel threads used to run the pipeline
pipeline = niak_pipeline_stability_fir(files_in,opt);
system(['cp ' mfilename('fullpath') '.m ' opt.folder_out '/.']); % make a copie of this script to output folder
system(['cp ' files_in.timing ' ' opt.folder_out '/.' ]); % make a copie of time events file used to output folder
