% This is a script to run a BASC on the dcd_t1w_rest database on mammouth
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
ext = 'EXP1';
opt_g.min_nb_vol = 60;
%opt_g.exclude_subject = {'M_P_2038291','LPLB_1278618','TBED_2051302','L_L_12800105','F_D_2039587','L_L_12800105','D_P_2035225'};
opt_g.min_xcorr_func = 0.34;
files_in = niak_grab_fmri_preprocess(['/home/benhajal/database/dcd_t1w_rest/fmri_preprocess_EXP1/'],opt_g);

%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%
opt.folder_out = ['/home/benhajal/database/dcd_t1w_rest/region_growing_' ext '/']; % Where to store the results
opt.flag_roi = true; % Only generate the ROI parcelation
opt.region_growing.thre_size = 1000; % The critical size for regions

%% Run the pipeline
opt.flag_test = false;
[pipeline,opt] = niak_pipeline_stability_rest(files_in,opt); 
