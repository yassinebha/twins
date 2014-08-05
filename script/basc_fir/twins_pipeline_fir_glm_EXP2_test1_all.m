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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting input/output files %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% findout wich server and set root path fo each case server
type_pre        = 'EXP2_test1';
type_test       = 'conf_1';
type_desorder   = 'dominic_anxs_';
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
end

% set preprocessing and stab_fir path
path_twins.fmri_preprocess = [ root_path 'fmri_preprocess_' type_pre ];
path_twins.stability_fir   = [ root_path 'stability_fir_all_sad_blocs_' type_pre ];
niak_gb_vars
path_twins = psom_struct_defaults(path_twins,{'fmri_preprocess','stability_fir'},{NaN,NaN});
path_twins.fmri_preprocess = niak_full_path(path_twins.fmri_preprocess);
path_twins.stability_fir = niak_full_path(path_twins.stability_fir);

%%%%%%%%%%%%
%% Grabbing the results from the NIAK fMRI preprocessing and stab_fir
%%%%%%%%%%%%
%% Grab the results from the NIAK fMRI preprocessing pipeline
opt_g.min_nb_vol = 0;     % The minimum number of volumes for an fMRI dataset to be included. This option is useful when scrubbing is used, and the resulting time series may be too short.
opt_g.min_xcorr_func = 0.34; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of functional images in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
opt_g.type_files = 'fir'; % Specify to the grabber to prepare the files for the STABILITY_FIR pipeline
%opt_g.exclude_subject = {'TBED2051302'};
files_in = rmfield(niak_grab_fmri_preprocess(path_twins.fmri_preprocess,opt_g),{'mask','areas'}); 

%% Now grab the results from the STABILITY_FIR pipeline
files_in.networks = niak_grab_stability_fir(path_twins.stability_fir).networks ;

%% grab only selected scale for ROI analysis
%  files_in.networks.sci140_scg140_scf151 = niak_grab_stability_fir(path_twins.stability_fir).networks.sci140_scg140_scf151 ;

%% select region of interst
%  [hdr,vol] = niak_read_vol(files_in.networks.sci140_scg140_scf151);
%  vol2 = zeros(size(vol));
%  vol2(vol==124) = 124; % Caudate anterior cingulate (l/r)
%  vol2(vol==140) = 140; % precuneus (l/r)
%  vol2(vol==102) = 102; % Rostral anterior cingulate (l/r)
%  hdr.file_name = ([ char(files_in.networks.sci140_scg140_scf151(1:end-7)) '_roi.mnc.gz']);
%  niak_write_vol(hdr,vol2);
%  files_in.networks.sci140_scg140_scf151 = hdr.file_name;

%%%%%%%%%%%%
%% Set the models
%%%%%%%%%%%%
%% Set the individual and the group models
switch server
      case 'guillimin'
            files_in.model.group      = '/home/yassinebha/svn/yassine/script/models/twins/dominic_interactive.csv';
            files_in.model.individual = '/home/yassinebha/svn/yassine/script/basc_fir/twins_timing_EXP2_test1_all_sad_blocs_neut_ref.csv';
            dominic_test              = '/home/yassinebha/svn/yassine/script/models/twins/dominic_all_test.csv';
      case 'mammouth'
            files_in.model.group      = '/home/benhajal/svn/yassine/script/models/twins/dominic_interactive.csv';
            files_in.model.individual = '/home/benhajal/svn/yassine/script/basc_fir/twins_timing_EXP2_test1_all_sad_blocs_neut_ref.csv';
            dominic_test              = '/home/benhajal/svn/yassine/script/models/twins/dominic_all_test.csv';
      case 'peuplier'
            files_in.model.group      = '/home/yassinebha/svn/yassine/script/models/twins/dominic_interactive.csv';
            files_in.model.individual = '/home/yassinebha/svn/yassine/script/basc_fir/twins_timing_EXP2_test1_all_sad_blocs_neut_ref.csv';
            dominic_test              = '/home/yassinebha/svn/yassine/script/models/twins/dominic_all_test.csv';
end

% building a new csv model file from raw group model file by defining control and patient for a varaiable of intereset
switch type_test
      case 'conf_1'
      A = 1;
      case 'conf_2'
      A = 5;
      case 'conf_3'
      A = 9;
      case 'conf_4'
      A = 13;
end      
cell_all_test = niak_read_csv_cell (dominic_test);
model=struct();

%%%  separation anxiety 
model.hdi_anxs.min_control  = str2num(cell_all_test {2,A+1});
model.hdi_anxs.max_control  = str2num(cell_all_test {2,A+2});
model.hdi_anxs.min_pat      = str2num(cell_all_test {2,A+3});
model.hdi_anxs.max_pat      = str2num(cell_all_test {2,A+4});

%%%  generelised anxiety
model.hdi_anxg.min_control  = str2num(cell_all_test {3,A+1});
model.hdi_anxg.max_control  = str2num(cell_all_test {3,A+2});
model.hdi_anxg.min_pat      = str2num(cell_all_test {3,A+3});
model.hdi_anxg.max_pat      = str2num(cell_all_test {3,A+4});

%%%  Deression
model.hdi_dep.min_control   = str2num(cell_all_test {4,A+1});
model.hdi_dep.max_control   = str2num(cell_all_test {4,A+2});
model.hdi_dep.min_pat       = str2num(cell_all_test {4,A+3});
model.hdi_dep.max_pat       = str2num(cell_all_test {4,A+4});

%%%  sepecific phobias
model.hdi_phos.min_control  = str2num(cell_all_test {5,A+1});
model.hdi_phos.max_control  = str2num(cell_all_test {5,A+2});
model.hdi_phos.min_pat      = str2num(cell_all_test {5,A+3});
model.hdi_phos.max_pat      = str2num(cell_all_test {5,A+4});

%%%  conduct disorders
model.hdi_prbc.min_control  = str2num(cell_all_test {6,A+1});
model.hdi_prbc.max_control  = str2num(cell_all_test {6,A+2});
model.hdi_prbc.min_pat      = str2num(cell_all_test {6,A+3});
model.hdi_prbc.max_pat      = str2num(cell_all_test {6,A+4});

%%%  attention deficit-hyperactivity
model.hdi_ihi.min_control   = str2num(cell_all_test {7,A+1});
model.hdi_ihi.max_control   = str2num(cell_all_test {7,A+2});
model.hdi_ihi.min_pat       = str2num(cell_all_test {7,A+3});
model.hdi_ihi.max_pat       = str2num(cell_all_test {7,A+4});

%%%  oppositional disorders
model.hdi_opp.min_control   = str2num(cell_all_test {8,A+1});
model.hdi_opp.max_control   = str2num(cell_all_test {8,A+2});
model.hdi_opp.min_pat       = str2num(cell_all_test {8,A+3});
model.hdi_opp.max_pat       = str2num(cell_all_test {8,A+4});

%%%  force/competence
model.hdi_forc.min_control  = str2num(cell_all_test {9,A+1});
model.hdi_forc.max_control  = str2num(cell_all_test {9,A+2});
model.hdi_forc.min_pat      = str2num(cell_all_test {9,A+3});
model.hdi_forc.max_pat      = str2num(cell_all_test {9,A+4});

%%%  internalizing
model.hdi_int.min_control  = str2num(cell_all_test {10,A+1});
model.hdi_int.max_control  = str2num(cell_all_test {10,A+2});
model.hdi_int.min_pat      = str2num(cell_all_test {10,A+3});
model.hdi_int.max_pat      = str2num(cell_all_test {10,A+4});

%%%  externalizing
model.hdi_ext.min_control  = str2num(cell_all_test {11,A+1});
model.hdi_ext.max_control  = str2num(cell_all_test {11,A+2});
model.hdi_ext.min_pat      = str2num(cell_all_test {11,A+3});
model.hdi_ext.max_pat      = str2num(cell_all_test {11,A+4});

% building new csv model with control set to 0 , pathologic to 1  and the in between to 2, for all variabale of interest
csv_cell          = niak_read_csv_cell(files_in.model.group );
var_interest      = fieldnames (model);
cell_var_interest = cell(size(csv_cell,1),length (var_interest));
csv_cell_combin   = cell(size(csv_cell,1),size(csv_cell,2)+length (var_interest));
for v_interest = 1 : length (var_interest)
    cell_var_interest(:,v_interest) = csv_cell(:,strcmp(csv_cell(1,:),var_interest{v_interest}));
    for n_interest = 2 : length(cell_var_interest)
        cmp = str2num(cell_var_interest{n_interest,v_interest});
        LC  = model.(var_interest{v_interest}).min_control;
        HC  = model.(var_interest{v_interest}).max_control;
        LP  = model.(var_interest{v_interest}).min_pat;
        HP  = model.(var_interest{v_interest}).max_pat;
        if cmp >= LC && cmp <= HC
           cell_var_interest(n_interest,v_interest) = 0;
        elseif cmp >= LP && cmp <= HP
           cell_var_interest(n_interest,v_interest) = 1;
        else cell_var_interest(n_interest,v_interest) = 2;
        end
    end
    cell_var_interest(1,v_interest)  = [ 'group0_vs_group1_' var_interest{v_interest} ];
end


%% writting the new csv model
csv_cell_combin        = [ csv_cell(:,1) cell_var_interest csv_cell(:,(2:end)) ];
csv_cell_combin        = strtrim(csv_cell_combin);
name_save              = [ path_twins.stability_fir 'dominic_interactive_model_' type_test '.csv' ];
niak_write_csv_cell (name_save ,csv_cell_combin);

%set path for newly created group model file
files_in.model.group   =  name_save;

%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%%
opt = struct();
opt = psom_struct_defaults(opt,{'folder_out'},{[path_twins.stability_fir,'glm_fir_',type_desorder,type_test,filesep]},false);
opt.folder_out = niak_full_path(opt.folder_out);
opt.fdr = 0.05; % The maximal false-discovery rate that is tolerated both for individual (single-seed) maps and whole-connectome discoveries, at each particular scale (multiple comparisons across scales are addressed via permutation testing)
opt.fwe = 0.05; % The overall family-wise error, i.e. the probablity to have the observed number of discoveries, agregated across all scales, under the global null hypothesis of no association.
opt.nb_samps = 1000; % The number of samples in the permutation test. This number has to be multiplied by OPT.NB_BATCH below to get the effective number of samples
opt.nb_batch = 10; % The permutation tests are separated into NB_BATCH independent batches, which can run on parallel if sufficient computational resources are available
opt.flag_rand = false; % if the flag is false, the pipeline is deterministic. Otherwise, the random number generator is initialized based on the clock for each job.

%% FIR estimation 
opt.fir.type_norm     = 'fir_shape'; % The type of normalization of the FIR. "fir_shape" (starts at zero, unit sum-of-squares)or 'perc'(without normalisation)
opt.fir.time_window   = 246;          % The size (in sec) of the time window to evaluate the response, in this cas it correspond to 90 volumes for tr=3s
opt.fir.time_sampling = 3;         % The time between two samples for the estimated response. Do not go below 1/2 TR unless there is a very large number of trials.
opt.fir.max_interpolation = 60;
opt.fir.nb_min_baseline = 10;
opt.fir.name_condition = 'sad';
opt.fir.name_baseline  = 'rest';

%%%%%%%%%%%
%% TESTS %%
%%%%%%%%%%%  

% Comparisons between groups

%%hdi_anxs
opt.test.hdi_anxs.contrast.hdi_anxs= 1;

%%dominic_anxs_AA : control_anxs vs pathologic_anxs
opt.test.(strcat(type_desorder,type_test,'AA')).select.label                       = 'group0_vs_group1_hdi_anxs';
opt.test.(strcat(type_desorder,type_test,'AA')).select.values                      = [0 1];
opt.test.(strcat(type_desorder,type_test,'AA')).contrast.hdi_anxs                  = 1;

%%dominic_anxs_AB : control_anxs (AND-low internalizing score) vs pathologic_anxs
opt.test.(strcat(type_desorder,type_test,'AB')).select(1).label                    = 'group0_vs_group1_hdi_anxs';
opt.test.(strcat(type_desorder,type_test,'AB')).select(1).values                   = [0];
opt.test.(strcat(type_desorder,type_test,'AB')).select(2).label                    = 'hdi_anxg';
opt.test.(strcat(type_desorder,type_test,'AB')).select(2).max                      = model.hdi_anxg.max_control;
opt.test.(strcat(type_desorder,type_test,'AB')).select(2).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'AB')).select(3).label                    = 'hdi_dep';
opt.test.(strcat(type_desorder,type_test,'AB')).select(3).max                      = model.hdi_dep.max_control;
opt.test.(strcat(type_desorder,type_test,'AB')).select(3).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'AB')).select(4).label                    = 'hdi_phos';
opt.test.(strcat(type_desorder,type_test,'AB')).select(4).max                      = model.hdi_phos.max_control;
opt.test.(strcat(type_desorder,type_test,'AB')).select(4).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'AB')).select(5).label                    = 'hdi_forc';
opt.test.(strcat(type_desorder,type_test,'AB')).select(5).min                      = model.hdi_forc.min_control;
opt.test.(strcat(type_desorder,type_test,'AB')).select(5).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'AB')).select(6).label                    = 'group0_vs_group1_hdi_anxs';
opt.test.(strcat(type_desorder,type_test,'AB')).select(6).values                   = [1];
opt.test.(strcat(type_desorder,type_test,'AB')).contrast.group0_vs_group1_hdi_anxs = 1;

%%dominic_anxs_AC : control_anxs (AND-low internalizing score AND-low externalizing score) vs pathologic_anxs
opt.test.(strcat(type_desorder,type_test,'AC')).select(1).label                    = 'group0_vs_group1_hdi_anxs';
opt.test.(strcat(type_desorder,type_test,'AC')).select(1).values                   = [0];
opt.test.(strcat(type_desorder,type_test,'AC')).select(2).label                    = 'hdi_anxg';
opt.test.(strcat(type_desorder,type_test,'AC')).select(2).max                      = model.hdi_anxg.max_control;
opt.test.(strcat(type_desorder,type_test,'AC')).select(2).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'AC')).select(3).label                    = 'hdi_dep';
opt.test.(strcat(type_desorder,type_test,'AC')).select(3).max                      = model.hdi_dep.max_control;
opt.test.(strcat(type_desorder,type_test,'AC')).select(3).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'AC')).select(4).label                    = 'hdi_phos';
opt.test.(strcat(type_desorder,type_test,'AC')).select(4).max                      = model.hdi_phos.max_control;
opt.test.(strcat(type_desorder,type_test,'AC')).select(4).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'AC')).select(5).label                    = 'hdi_forc';
opt.test.(strcat(type_desorder,type_test,'AC')).select(5).min                      = model.hdi_forc.min_control;
opt.test.(strcat(type_desorder,type_test,'AC')).select(5).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'AC')).select(6).label                    = 'hdi_prbc';
opt.test.(strcat(type_desorder,type_test,'AC')).select(6).max                      = model.hdi_prbc.max_control;
opt.test.(strcat(type_desorder,type_test,'AC')).select(6).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'AC')).select(7).label                    = 'hdi_ihi';
opt.test.(strcat(type_desorder,type_test,'AC')).select(7).max                      = model.hdi_ihi.max_control;
opt.test.(strcat(type_desorder,type_test,'AC')).select(7).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'AC')).select(8).label                    = 'hdi_opp';
opt.test.(strcat(type_desorder,type_test,'AC')).select(8).max                      = model.hdi_opp.max_control;
opt.test.(strcat(type_desorder,type_test,'AC')).select(8).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'AC')).select(9).label                    = 'group0_vs_group1_hdi_anxs';
opt.test.(strcat(type_desorder,type_test,'AC')).select(9).values                   = [1];
opt.test.(strcat(type_desorder,type_test,'AC')).contrast.group0_vs_group1_hdi_anxs = 1;

%%dominic_anxs_BA : control_anxs vs pathologic_anxs (AND-low externalizing score)
opt.test.(strcat(type_desorder,type_test,'BA')).select(1).label                    = 'group0_vs_group1_hdi_anxs';
opt.test.(strcat(type_desorder,type_test,'BA')).select(1).values                   = [1];
opt.test.(strcat(type_desorder,type_test,'BA')).select(2).label                    = 'hdi_prbc';
opt.test.(strcat(type_desorder,type_test,'BA')).select(2).max                      = model.hdi_prbc.max_control;
opt.test.(strcat(type_desorder,type_test,'BA')).select(2).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'BA')).select(3).label                    = 'hdi_ihi';
opt.test.(strcat(type_desorder,type_test,'BA')).select(3).max                      = model.hdi_ihi.max_control;
opt.test.(strcat(type_desorder,type_test,'BA')).select(3).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'BA')).select(4).label                    = 'hdi_opp';
opt.test.(strcat(type_desorder,type_test,'BA')).select(4).max                      = model.hdi_opp.max_control;
opt.test.(strcat(type_desorder,type_test,'BA')).select(4).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'BA')).select(5).label                    = 'group0_vs_group1_hdi_anxs';
opt.test.(strcat(type_desorder,type_test,'BA')).select(5).values                   = [0];
opt.test.(strcat(type_desorder,type_test,'BA')).contrast.group0_vs_group1_hdi_anxs = 1;

%%dominic_anxs_BB : control_anxs (AND-low internalizing score) vs pathologic_anxs (AND-low externalizing score)
opt.test.(strcat(type_desorder,type_test,'BB')).select(1).label                    = 'group0_vs_group1_hdi_anxs';
opt.test.(strcat(type_desorder,type_test,'BB')).select(1).values                   = [1];
opt.test.(strcat(type_desorder,type_test,'BB')).select(2).label                    = 'hdi_prbc';
opt.test.(strcat(type_desorder,type_test,'BB')).select(2).max                      = model.hdi_prbc.max_control;
opt.test.(strcat(type_desorder,type_test,'BB')).select(2).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'BB')).select(3).label                    = 'hdi_ihi';
opt.test.(strcat(type_desorder,type_test,'BB')).select(3).max                      = model.hdi_ihi.max_control;
opt.test.(strcat(type_desorder,type_test,'BB')).select(3).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'BB')).select(4).label                    = 'hdi_opp';
opt.test.(strcat(type_desorder,type_test,'BB')).select(4).max                      = model.hdi_opp.max_control;
opt.test.(strcat(type_desorder,type_test,'BB')).select(4).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'BB')).select(5).label                    = 'group0_vs_group1_hdi_anxs';
opt.test.(strcat(type_desorder,type_test,'BB')).select(5).values                   = [0];
opt.test.(strcat(type_desorder,type_test,'BB')).select(6).label                    = 'hdi_anxg';
opt.test.(strcat(type_desorder,type_test,'BB')).select(6).max                      = model.hdi_anxg.max_control;
opt.test.(strcat(type_desorder,type_test,'BB')).select(6).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'BB')).select(7).label                    = 'hdi_dep';
opt.test.(strcat(type_desorder,type_test,'BB')).select(7).max                      = model.hdi_dep.max_control;
opt.test.(strcat(type_desorder,type_test,'BB')).select(7).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'BB')).select(8).label                    = 'hdi_phos';
opt.test.(strcat(type_desorder,type_test,'BB')).select(8).max                      = model.hdi_phos.max_control;
opt.test.(strcat(type_desorder,type_test,'BB')).select(8).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'BB')).select(9).label                    = 'hdi_forc';
opt.test.(strcat(type_desorder,type_test,'BB')).select(9).min                      = model.hdi_forc.min_control;
opt.test.(strcat(type_desorder,type_test,'BB')).select(9).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'BB')).contrast.group0_vs_group1_hdi_anxs = 1;

%%dominic_anxs_BC : control_anxs (AND-low internalizing score AND-low externalizing score) vs pathologic_anxs (AND-low externalizing score)
opt.test.(strcat(type_desorder,type_test,'BC')).select(1).label                    = 'group0_vs_group1_hdi_anxs';
opt.test.(strcat(type_desorder,type_test,'BC')).select(1).values                   = [1];
opt.test.(strcat(type_desorder,type_test,'BC')).select(2).label                    = 'hdi_prbc';
opt.test.(strcat(type_desorder,type_test,'BC')).select(2).max                      = model.hdi_prbc.max_control;
opt.test.(strcat(type_desorder,type_test,'BC')).select(2).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'BC')).select(3).label                    = 'hdi_ihi';
opt.test.(strcat(type_desorder,type_test,'BC')).select(3).max                      = model.hdi_ihi.max_control;
opt.test.(strcat(type_desorder,type_test,'BC')).select(3).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'BC')).select(4).label                    = 'hdi_opp';
opt.test.(strcat(type_desorder,type_test,'BC')).select(4).max                      = model.hdi_opp.max_control;
opt.test.(strcat(type_desorder,type_test,'BC')).select(4).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'BC')).select(5).label                    = 'group0_vs_group1_hdi_anxs';
opt.test.(strcat(type_desorder,type_test,'BC')).select(5).values                   = [0];
opt.test.(strcat(type_desorder,type_test,'BC')).select(6).label                    = 'hdi_anxg';
opt.test.(strcat(type_desorder,type_test,'BC')).select(6).max                      = model.hdi_anxg.max_control;
opt.test.(strcat(type_desorder,type_test,'BC')).select(6).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'BC')).select(7).label                    = 'hdi_dep';
opt.test.(strcat(type_desorder,type_test,'BC')).select(7).max                      = model.hdi_dep.max_control;
opt.test.(strcat(type_desorder,type_test,'BC')).select(7).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'BC')).select(8).label                    = 'hdi_phos';
opt.test.(strcat(type_desorder,type_test,'BC')).select(8).max                      = model.hdi_phos.max_control;
opt.test.(strcat(type_desorder,type_test,'BC')).select(8).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'BC')).select(9).label                    = 'hdi_forc';
opt.test.(strcat(type_desorder,type_test,'BC')).select(9).min                      = model.hdi_forc.min_control;
opt.test.(strcat(type_desorder,type_test,'BC')).select(9).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'BC')).select(10).label                   = 'hdi_prbc';
opt.test.(strcat(type_desorder,type_test,'BC')).select(10).max                     = model.hdi_prbc.max_control;
opt.test.(strcat(type_desorder,type_test,'BC')).select(10).operation               = 'and';
opt.test.(strcat(type_desorder,type_test,'BC')).select(11).label                   = 'hdi_ihi';
opt.test.(strcat(type_desorder,type_test,'BC')).select(11).max                     = model.hdi_ihi.max_control;
opt.test.(strcat(type_desorder,type_test,'BC')).select(11).operation               = 'and';
opt.test.(strcat(type_desorder,type_test,'BC')).select(12).label                   = 'hdi_opp';
opt.test.(strcat(type_desorder,type_test,'BC')).select(12).max                     = model.hdi_opp.max_control;
opt.test.(strcat(type_desorder,type_test,'BC')).select(12).operation               = 'and';
opt.test.(strcat(type_desorder,type_test,'BC')).contrast.group0_vs_group1_hdi_anxs = 1;

%%dominic_anxs_CA : control_anxs vs pathologic_anxs (AND-low internalizing score AND-low externalizing score)
opt.test.(strcat(type_desorder,type_test,'CA')).select(1).label                    = 'group0_vs_group1_hdi_anxs';
opt.test.(strcat(type_desorder,type_test,'CA')).select(1).values                   = [1];
opt.test.(strcat(type_desorder,type_test,'CA')).select(2).label                    = 'hdi_prbc';
opt.test.(strcat(type_desorder,type_test,'CA')).select(2).max                      = model.hdi_prbc.max_control;
opt.test.(strcat(type_desorder,type_test,'CA')).select(2).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'CA')).select(3).label                    = 'hdi_ihi';
opt.test.(strcat(type_desorder,type_test,'CA')).select(3).max                      = model.hdi_ihi.max_control;
opt.test.(strcat(type_desorder,type_test,'CA')).select(3).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'CA')).select(4).label                    = 'hdi_opp';
opt.test.(strcat(type_desorder,type_test,'CA')).select(4).max                      = model.hdi_opp.max_control;
opt.test.(strcat(type_desorder,type_test,'CA')).select(4).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'CA')).select(5).label                    = 'hdi_anxg';
opt.test.(strcat(type_desorder,type_test,'CA')).select(5).max                      = model.hdi_anxg.max_control;
opt.test.(strcat(type_desorder,type_test,'CA')).select(5).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'CA')).select(6).label                    = 'hdi_dep';
opt.test.(strcat(type_desorder,type_test,'CA')).select(6).max                      = model.hdi_dep.max_control;
opt.test.(strcat(type_desorder,type_test,'CA')).select(6).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'CA')).select(7).label                    = 'hdi_phos';
opt.test.(strcat(type_desorder,type_test,'CA')).select(7).max                      = model.hdi_phos.max_control;
opt.test.(strcat(type_desorder,type_test,'CA')).select(7).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'CA')).select(8).label                    = 'hdi_forc';
opt.test.(strcat(type_desorder,type_test,'CA')).select(8).min                      = model.hdi_forc.min_control;
opt.test.(strcat(type_desorder,type_test,'CA')).select(8).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'CA')).select(9).label                    = 'group0_vs_group1_hdi_anxs';
opt.test.(strcat(type_desorder,type_test,'CA')).select(9).values                   = [0];
opt.test.(strcat(type_desorder,type_test,'CA')).contrast.group0_vs_group1_hdi_anxs = 1;

%%dominic_anxs_CB : control_anxs (AND-low internalizing score) vs pathologic_anxs (AND-low internalizing score AND-low externalizing score)
opt.test.(strcat(type_desorder,type_test,'CB')).select(1).label                    = 'group0_vs_group1_hdi_anxs';
opt.test.(strcat(type_desorder,type_test,'CB')).select(1).values                   = [1];
opt.test.(strcat(type_desorder,type_test,'CB')).select(2).label                    = 'hdi_prbc';
opt.test.(strcat(type_desorder,type_test,'CB')).select(2).max                      = model.hdi_prbc.max_control;
opt.test.(strcat(type_desorder,type_test,'CB')).select(2).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'CB')).select(3).label                    = 'hdi_ihi';
opt.test.(strcat(type_desorder,type_test,'CB')).select(3).max                      = model.hdi_ihi.max_control;
opt.test.(strcat(type_desorder,type_test,'CB')).select(3).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'CB')).select(4).label                    = 'hdi_opp';
opt.test.(strcat(type_desorder,type_test,'CB')).select(4).max                      = model.hdi_opp.max_control;
opt.test.(strcat(type_desorder,type_test,'CB')).select(4).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'CB')).select(5).label                    = 'hdi_anxg';
opt.test.(strcat(type_desorder,type_test,'CB')).select(5).max                      = model.hdi_anxg.max_control;
opt.test.(strcat(type_desorder,type_test,'CB')).select(5).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'CB')).select(6).label                    = 'hdi_dep';
opt.test.(strcat(type_desorder,type_test,'CB')).select(6).max                      = model.hdi_dep.max_control;
opt.test.(strcat(type_desorder,type_test,'CB')).select(6).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'CB')).select(7).label                    = 'hdi_phos';
opt.test.(strcat(type_desorder,type_test,'CB')).select(7).max                      = model.hdi_phos.max_control;
opt.test.(strcat(type_desorder,type_test,'CB')).select(7).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'CB')).select(8).label                    = 'hdi_forc';
opt.test.(strcat(type_desorder,type_test,'CB')).select(8).min                      = model.hdi_forc.min_control;
opt.test.(strcat(type_desorder,type_test,'CB')).select(8).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'CB')).select(9).label                    = 'group0_vs_group1_hdi_anxs';
opt.test.(strcat(type_desorder,type_test,'CB')).select(9).values                   = [0];
opt.test.(strcat(type_desorder,type_test,'CB')).select(10).label                   = 'hdi_anxg';
opt.test.(strcat(type_desorder,type_test,'CB')).select(10).max                     = model.hdi_anxg.max_control;
opt.test.(strcat(type_desorder,type_test,'CB')).select(10).operation               = 'and';
opt.test.(strcat(type_desorder,type_test,'CB')).select(11).label                   = 'hdi_dep';
opt.test.(strcat(type_desorder,type_test,'CB')).select(11).max                     = model.hdi_dep.max_control;
opt.test.(strcat(type_desorder,type_test,'CB')).select(11).operation               = 'and';
opt.test.(strcat(type_desorder,type_test,'CB')).select(12).label                   = 'hdi_phos';
opt.test.(strcat(type_desorder,type_test,'CB')).select(12).max                     = model.hdi_phos.max_control;
opt.test.(strcat(type_desorder,type_test,'CB')).select(12).operation               = 'and';
opt.test.(strcat(type_desorder,type_test,'CB')).select(13).label                   = 'hdi_forc';
opt.test.(strcat(type_desorder,type_test,'CB')).select(13).min                     = model.hdi_forc.min_control;
opt.test.(strcat(type_desorder,type_test,'CB')).select(13).operation               = 'and';
opt.test.(strcat(type_desorder,type_test,'CB')).contrast.group0_vs_group1_hdi_anxs = 1;

%%dominic_anxs_CC : control_anxs (AND-low internalizing score AND-low externalizing score) vs pathologic_anxs (AND-low internalizing score AND-low externalizing score)
opt.test.(strcat(type_desorder,type_test,'CC')).select(1).label                    = 'group0_vs_group1_hdi_anxs';
opt.test.(strcat(type_desorder,type_test,'CC')).select(1).values                   = [0 1];
opt.test.(strcat(type_desorder,type_test,'CC')).select(2).label                    = 'hdi_prbc';
opt.test.(strcat(type_desorder,type_test,'CC')).select(2).max                      = model.hdi_prbc.max_control;
opt.test.(strcat(type_desorder,type_test,'CC')).select(2).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'CC')).select(3).label                    = 'hdi_ihi';
opt.test.(strcat(type_desorder,type_test,'CC')).select(3).max                      = model.hdi_ihi.max_control;
opt.test.(strcat(type_desorder,type_test,'CC')).select(3).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'CC')).select(4).label                    = 'hdi_opp';
opt.test.(strcat(type_desorder,type_test,'CC')).select(4).max                      = model.hdi_opp.max_control;
opt.test.(strcat(type_desorder,type_test,'CC')).select(4).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'CC')).select(5).label                    = 'hdi_anxg';
opt.test.(strcat(type_desorder,type_test,'CC')).select(5).max                      = model.hdi_anxg.max_control;
opt.test.(strcat(type_desorder,type_test,'CC')).select(5).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'CC')).select(6).label                    = 'hdi_dep';
opt.test.(strcat(type_desorder,type_test,'CC')).select(6).max                      = model.hdi_dep.max_control;
opt.test.(strcat(type_desorder,type_test,'CC')).select(6).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'CC')).select(7).label                    = 'hdi_phos';
opt.test.(strcat(type_desorder,type_test,'CC')).select(7).max                      = model.hdi_phos.max_control;
opt.test.(strcat(type_desorder,type_test,'CC')).select(7).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'CC')).select(8).label                    = 'hdi_forc';
opt.test.(strcat(type_desorder,type_test,'CC')).select(8).min                      = model.hdi_forc.min_control;
opt.test.(strcat(type_desorder,type_test,'CC')).select(8).operation                = 'and';
opt.test.(strcat(type_desorder,type_test,'CC')).contrast.group0_vs_group1_hdi_anxs = 1;


%%%%%%%%%%%%%%%%%%%%%%
%% Run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%
opt.flag_test  = false;
[pipeline,opt_pipe] = niak_pipeline_glm_fir(files_in,opt);

%%extra
system(['cp ' mfilename('fullpath') '.m ' opt.folder_out '.']); % make a copie of this script to output folder
system(['mv ' files_in.model.group  ' ' opt.folder_out '.']); % move the generated model file  to output folder
