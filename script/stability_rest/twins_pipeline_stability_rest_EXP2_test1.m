% This is a template to run the BASC pipeline on twins  for EXP2_test1.
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


clear all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting input/output files %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setting root path fo each case server
type_pre        = 'EXP2_test1'
type_scale      = 'mstep'; % could be 'all' for systematic scale grid ,or 'mstep'
[status,cmdout] = system ('uname -n');
server          = strtrim(cmdout);
if strfind(server,'lg-1r')
   server = 'guillimin';
elseif strfind(server,'ip05')
   server = 'mammouth';
endif
switch server
      case 'guillimin'
            root_path = '/gs/scratch/yassinebha/twins/';
            fprintf ('server: %s\n',server)
      case 'mammouth'
            root_path = '/mnt/parallel_scratch_ms2_wipe_on_april_2014/pbellec/benhajal/twins/';
            fprintf ('server: %s\n',server)
      case 'peuplier'
            root_path = '/media/database3/twins_study/';
            fprintf ('server: %s\n',server)
      case 'noisetier'
            root_path = '/media/database1/twins_study/';
            fprintf ('server: %s\n',server)
end

files_in = niak_grab_region_growing( [root_path 'region_growing_' type_pre '/rois/'] );

%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%
switch type_scale
       case 'mstep'
       opt.folder_out  = [root_path 'basc_' type_pre '/']; % Where to store the results
       opt.scales_maps = [2     2     2;...
       3     3     3;...
       4     6     6;...
      12    12    12;...
      17    21    20;...
      29    35    35;...
      60    60    60;...
     100   100    99;...
     185   167   167;...
     310   279   285;...
     410   451   433;...
     700   700   539];
       case 'all'
       opt.folder_out  = [root_path 'basc_' type_pre '/']; % Where to store the results
       opt.scales_maps = repmat ([5:5:100 110:10:200 220:20:400]',1,3); % The scales that will be used to generate the maps of brain clusters and stability
end
opt.grid_scales = [2:49 50:5:200 210:10:500 500:50:950]; % Search in the range 2-950 clusters
opt.stability_tseries.nb_samps = 100; % Number of bootstrap samples at the individual level. 100: the CI on indidividual stability is +/-0.1
opt.stability_group.nb_samps = 500; % Number of bootstrap samples at the group level. 500: the CI on group stability is +/-0.05

opt.flag_ind = false; % Generate maps/time series at the individual level
opt.flag_mixed = false; % Generate maps/time series at the mixed level (group-level networks mixed with individual stability matrices).
opt.flag_group = true; % Generate maps/time series at the group level
opt.flag_tseries_network = true; % permet de réduire le temps de calcul au niveau de glm-connectome

%%%%%%%%%%%%%%%%%%%%%%
%% Run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%
%opt.psom.qsub_options = '-q qwork@ms -l nodes=1:m32G,walltime=05:00:00';
opt.flag_test = false; % Put this flag to true to just generate the pipeline without running it. Otherwise the region growing will start. 
%opt.psom.max_queued = 10; % Uncomment and change this parameter to set the number of parallel threads used to run the pipeline
pipeline = niak_pipeline_stability_rest(files_in,opt);

%  extra
system(['cp ' mfilename('fullpath') '.m ' opt.folder_out '.']); % make a copie of this script to output folder 
