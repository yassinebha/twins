clear all
% This is a script to run a BASC on the twins_study database for EXP2_test1 
%
% Copyright (c) Pierre Bellec, 
%               Centre de recherche de l'institut de Gériatrie de Montréal
%               Département d'informatique et de recherche opérationnelle
%               Université de Montréal, 2012.
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : fMRI, resting-state, clustering, BASC

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting input/output files %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opt_g.min_nb_vol = 70;
opt_g.min_xcorr_func = 0.3;
files_in = niak_grab_fmri_preprocess('/home/benhajal/database/twins/fmri_preprocess_EXP2_test1/',opt_g);

%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%

opt.folder_out = '/home/benhajal/database/twins/region_growing_EXP2_test1/'; % Where to store the results
opt.flag_roi = true; % Only generate the ROI parcelation
opt.region_growing.thre_size = 1000; % The critical size for regions, in mm3. A threshold of 1000 mm3 will give about 1000 regions on the grey matter

%%%%%%%%%%%%%%%%%%%%%%
%% Run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%

opt.flag_test = false; % Put this flag to true to just generate the pipeline without running it. Otherwise the region growing will start. 
%opt.psom.max_queued = 10; % Uncomment and change this parameter to set thenumber of parallel threads used to run the pipeline
[pipeline_rg,opt] = niak_pipeline_stability_rest(files_in,opt);

%% extra
system(['cp ' mfilename('fullpath') '.m ' opt.folder_out '.']); % make a copie of this script to output folder
