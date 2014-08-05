% This is a template to run the BASC pipeline on resting-state fMRI.
%
% The file names used here do not correspond to actual files and were used 
% for illustration purpose only. To actually run a demo of the 
% preprocessing data, please see NIAK_DEMO_PIPELINE_STABILITY_REST
%
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008-2010.
%               Centre de recherche de l'institut de Gériatrie de Montréal
%               Département d'informatique et de recherche opérationnelle
%               Université de Montréal, 2010-2012.
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

clear
type_pre = 'EXP1'; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting input/output files %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

files_in = niak_grab_region_growing(['/home/benhajal/database/dcd_t1w_rest/region_growing_' type_pre '/rois/']);

%% Extra infos 
files_in.infos = '/home/benhajal/svn/yassine/script/models/dcd/dcd_sex.csv'; % Stratify the database by sex in bootstrap resampling

%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%

opt.folder_out = ['/home/benhajal/database/dcd_t1w_rest/basc_' type_pre '/']; % Where to store the results
opt.grid_scales = [2:40 50:10:100 120:20:400 500:50:950]; % Search in the range 2-950 clusters
opt.scales_maps = [ 10 10 10; 50 50 50; 100 100 100 ; 200 200 200; 500 500 500 ]; % The scales that will be used to generate the maps of brain clusters and stability
opt.stability_tseries.nb_samps = 100; % Number of bootstrap samples at the individual level. 100: the CI on indidividual stability is +/-0.1
opt.stability_group.nb_samps = 500; % Number of bootstrap samples at the group level. 500: the CI on group stability is +/-0.05

opt.flag_ind = false; % Generate maps/time series at the individual level
opt.flag_mixed = false; % Generate maps/time series at the mixed level (group-level networks mixed with individual stability matrices).
opt.flag_group = true; % Generate maps/time series at the group level
opt.flag_tseries_network = true; % permet de réduire le temps de calcul au niveau de glm-connectome
%%%%%%%%%%%%%%%%%%%%%%
%% Run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%
%opt.psom.max_queued = 10;
pipeline = niak_pipeline_stability_rest(files_in,opt); 
