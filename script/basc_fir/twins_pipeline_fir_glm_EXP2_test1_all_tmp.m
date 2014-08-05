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
%  path_twins.fmri_preprocess = '/mnt/parallel_scratch_ms2_wipe_on_april_2014/pbellec/benhajal/twins/fmri_preprocess_EXP2_test1';
%  path_twins.stability_fir= '/mnt/parallel_scratch_ms2_wipe_on_april_2014/pbellec/benhajal/twins/stability_fir_all_sad_blocs_EXP2_test1';

niak_gb_vars
path_twins = psom_struct_defaults(path_twins,{'fmri_preprocess','stability_fir'},{NaN,NaN});
path_twins.fmri_preprocess = niak_full_path(path_twins.fmri_preprocess);
path_twins.stability_fir = niak_full_path(path_twins.stability_fir);
opt = struct();
opt = psom_struct_defaults(opt,{'folder_out'},{[path_twins.stability_fir,'glm_fir_all',filesep]},false);
opt.folder_out = niak_full_path(opt.folder_out);

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

%% Set the timing of events;
% peuplier
files_in.model.group      = '/home/yassinebha/svn/projects/twins/script/models/twins/dominic_interactive.csv';
files_in.model.individual ='/home/yassinebha/svn/projects/twins/script/basc_fir/twins_timing_EXP2_test1_all_sad_blocs_neut_ref.csv';
%  % mammouth
%  files_in.model.group      = '/home/benhajal/svn/projects/twins/script/models/twins/dominic_interactive.csv';
%  files_in.model.individual ='/home/benhajal/svn/projects/twins/script/basc_fir/twins_timing_EXP2_test1_all_sad_blocs_neut_ref.csv';

% building a csv model file by defining control and patient for a varaiable of intereset
model=struct();

%%%  Deression
model.hdi_dep.min_control  = 0;
model.hdi_dep.max_control  = 10;
model.hdi_dep.min_pat      = 11;
model.hdi_dep.max_pat      = 20;

%%%  sepecific phobias
model.hdi_phos.min_control  = 0;
model.hdi_phos.max_control  = 2;
model.hdi_phos.min_pat      = 3;
model.hdi_phos.max_pat      = 9;

%%%  separation anxiety 
model.hdi_anxs.min_control  = 0;
model.hdi_anxs.max_control  = 4;
model.hdi_anxs.min_pat      = 5;
model.hdi_anxs.max_pat      = 8;

%%%  generelised anxiety
model.hdi_anxg.min_control  = 0;
model.hdi_anxg.max_control  = 9;
model.hdi_anxg.min_pat      = 10;
model.hdi_anxg.max_pat      = 15;

%%%  internalizing
model.hdi_int.min_control  = 0;
model.hdi_int.max_control  = 5;
model.hdi_int.min_pat      = 15;
model.hdi_int.max_pat      = 47;

%%%  attention deficit-hyperactivity
model.hdi_ihi.min_control  = 0;
model.hdi_ihi.max_control  = 10;
model.hdi_ihi.min_pat      = 11;
model.hdi_ihi.max_pat      = 19;

%%%  oppositional disorders
model.hdi_opp.min_control  = 0;
model.hdi_opp.max_control  = 4;
model.hdi_opp.min_pat      = 5;
model.hdi_opp.max_pat      = 9;

%%%  conduct disorders
model.hdi_prbc.min_control  = 0;
model.hdi_prbc.max_control  = 2;
model.hdi_prbc.min_pat      = 3;
model.hdi_prbc.max_pat      = 14;

%%%  externalizing
model.hdi_ext.min_control  = 0;
model.hdi_ext.max_control  = 10;
model.hdi_ext.min_pat      = 20;
model.hdi_ext.max_pat      = 40;

%%%  force/competence
model.hdi_forc.min_control  = 0;
model.hdi_forc.max_control  = 7;
model.hdi_forc.min_pat      = 8;
model.hdi_forc.max_pat      = 10;

%% building new csv model with control set to 0 , pathologic to 1  and the in between to 2, for all variabale of interest
csv_cell          = niak_read_csv_cell(files_in.model.group );
var_interest      = fieldnames (model);
cell_var_interest = cell(size(csv_cell,1),length (var_interest));
csv_cell_combin   = cell(size(csv_cell,1),size(csv_cell,2)+length (var_interest));

for v_interest = 1 : length (var_interest)
    cell_var_interest(:,v_interest) = csv_cell(:,strcmp(csv_cell(1,:),var_interest{v_interest}));
    for n_interest = 2 : length(cell_var_interest)
        if (str2num(cell_var_interest{n_interest,v_interest}) >= (model.(var_interest{v_interest}).min_control)) && (str2num(cell_var_interest{n_interest,v_interest}) <= (model.(var_interest{v_interest}).max_control))
           cell_var_interest(n_interest,v_interest) = 0;
        elseif (str2num(cell_var_interest{n_interest,v_interest}) >= (model.(var_interest{v_interest}).min_pat)) && (str2num(cell_var_interest{n_interest,v_interest}) <= (model.(var_interest{v_interest}).max_pat)) 
           cell_var_interest(n_interest,v_interest) = 1;
        else cell_var_interest(n_interest,v_interest) = 2;
        end
    end
    cell_var_interest(1,v_interest)  = [ 'group0_vs_group1_' var_interest{v_interest} ];
end


%% writting the new csv model
csv_cell_combin        = [ csv_cell(:,1) cell_var_interest csv_cell(:,(2:end)) ];
csv_cell_combin        = strtrim(csv_cell_combin);
name_save              = [ 'dominic_interactive_model.csv' ];
niak_write_csv_cell ([ path_twins.stability_fir name_save ] ,csv_cell_combin);

%set path for newly created group model file
files_in.model.group   = [ path_twins.stability_fir name_save ];

%% FIR estimation 
opt.fir.type_norm     = 'fir_shape'; % The type of normalization of the FIR. "fir_shape" (starts at zero, unit sum-of-squares)or 'perc'(without normalisation)
opt.fir.time_window   = 246;          % The size (in sec) of the time window to evaluate the response, in this cas it correspond to 90 volumes for tr=3s
opt.fir.time_sampling = 3;         % The time between two samples for the estimated response. Do not go below 1/2 TR unless there is a very large number of trials.
opt.fir.max_interpolation = 60;
opt.fir.nb_min_baseline = 10;
opt.fir.name_condition = 'sad';
opt.fir.name_baseline  = 'rest';

%% The tests 

%  %%hdi_dep 
%  opt.test.hdi_dep.contrast.hdi_dep= 1;
%  
%  %%dominic_dep
%  opt.test.dominic_dep.select.label = 'group0_vs_group1_hdi_dep';
%  opt.test.dominic_dep.select.values = [0 1];
%  opt.test.dominic_dep.contrast.hdi_dep = 1;
%  
%  %%hdi_phos
%  opt.test.hdi_phos.contrast.hdi_phos= 1;
%  
%  %%dominic_phos
%  opt.test.dominic_phos.select.label = 'group0_vs_group1_hdi_phos';
%  opt.test.dominic_phos.select.values = [0 1];
%  opt.test.dominic_phos.contrast.hdi_phos = 1;
%  
%  %%hdi_anxs
%  opt.test.hdi_anxs.contrast.hdi_anxs= 1;
%  
%  %%dominic_anxs
%  opt.test.dominic_anxs.select.label = 'group0_vs_group1_hdi_anxs';
%  opt.test.dominic_anxs.select.values = [0 1];
%  opt.test.dominic_anxs.contrast.hdi_anxs = 1;
%  
%  %%hdi_anxg
%  opt.test.hdi_anxg.contrast.hdi_anxg= 1;
%  
%  %%dominic_anxg
%  opt.test.dominic_anxg.select.label = 'group0_vs_group1_hdi_anxg';
%  opt.test.dominic_anxg.select.values = [0 1];
%  opt.test.dominic_anxg.contrast.hdi_anxg = 1;

%%hdi_int
opt.test.hdi_int.contrast.hdi_int = 1;

%%dominic_int
opt.test.dominic_int.select.label = 'group0_vs_group1_hdi_int';
opt.test.dominic_int.select.values = [0 1];
opt.test.dominic_int.contrast.group0_vs_group1_hdi_int = 1;

%  %%hdi_ihi
%  opt.test.hdi_ihi.contrast.hdi_ihi= 1;
%  
%  %%dominic_ihi
%  opt.test.dominic_ihi.select.label = 'group0_vs_group1_hdi_ihi';
%  opt.test.dominic_ihi.select.values = [0 1];
%  opt.test.dominic_ihi.contrast.hdi_ihi = 1;
%  
%  %%hdi_opp
%  opt.test.hdi_opp.contrast.hdi_opp= 1;
%  
%  %%dominic_opp
%  opt.test.dominic_opp.select.label = 'group0_vs_group1_hdi_opp';
%  opt.test.dominic_opp.select.values = [0 1];
%  opt.test.dominic_opp.contrast.hdi_opp = 1;
%  
%  %%hdi_prbc
%  opt.test.hdi_prbc.contrast.hdi_prbc= 1;
%  
%  %%dominic_prbc
%  opt.test.dominic_prbc.select.label = 'group0_vs_group1_hdi_prbc';
%  opt.test.dominic_prbc.select.values = [0 1];
%  opt.test.dominic_prbc.contrast.hdi_prbc = 1;
%  
%  %%hdi_ext
%  opt.test.hdi_ext.contrast.hdi_ext = 1;
%  
%  %%dominic_ext
%  opt.test.dominic_ext.select.label = 'group0_vs_group1_hdi_ext';
%  opt.test.dominic_ext.select.values = [0 1];
%  opt.test.dominic_ext.contrast.hdi_ext = 1;
%  
%  %%hdi_forc
%  opt.test.hdi_forc.contrast.hdi_forc = 1;
%  
%  %%dominic_forc
%  opt.test.dominic_forc.select.label = 'group0_vs_group1_hdi_forc';
%  opt.test.dominic_forc.select.values = [0 1];
%  opt.test.dominic_forc.contrast.hdi_forc = 1;

%  
%  % Test : comparison between the normal and the phobic  group
%  opt.test.group0_vs_group1_restric.select(1).label = 'hdi_phos';
%  opt.test.group0_vs_group1_restric.select(1).max = [3];
%  opt.test.group0_vs_group1_restric.select(2).label = 'hdi_anxs';
%  opt.test.group0_vs_group1_restric.select(2).max = [4];
%  opt.test.group0_vs_group1_restric.select(2).operation = 'and';
%  opt.test.group0_vs_group1_restric.select(3).label = 'hdi_anxg';
%  opt.test.group0_vs_group1_restric.select(3).max = [9];
%  opt.test.group0_vs_group1_restric.select(3).operation = 'and';
%  opt.test.group0_vs_group1_restric.select(4).label = 'hdi_opp';
%  opt.test.group0_vs_group1_restric.select(4).max = [4];
%  opt.test.group0_vs_group1_restric.select(4).operation = 'and';
%  opt.test.group0_vs_group1_restric.select(5).label = 'hdi_prbc';
%  opt.test.group0_vs_group1_restric.select(5).max = [3];
%  opt.test.group0_vs_group1_restric.select(5).operation = 'and';
%  opt.test.group0_vs_group1_restric.select(6).label = 'hdi_ihi';
%  opt.test.group0_vs_group1_restric.select(6).max = [10];
%  opt.test.group0_vs_group1_restric.select(6).operation = 'and';
%  opt.test.group0_vs_group1_restric.select(7).label = 'group0_vs_group1';
%  opt.test.group0_vs_group1_restric.select(7).values = [0 1]; 
%  opt.test.group0_vs_group1_restric.select(7).operation = 'and';
%  opt.test.group0_vs_group1_restric.contrast.group0_vs_group1 = 1;
%  
%  % dominic_dep_inter_group1VS0
%  opt.test.dominic_dep_inter_group1VS0.interaction.label = 'dom_sph_inter_group1VS0';
%  opt.test.dominic_dep_inter_group1VS0.interaction.factor = {'hdi_phos','group0_vs_group1'};
%  opt.test.dominic_dep_inter_group1VS0.select.label = 'group0_vs_group1';
%  opt.test.dominic_dep_inter_group1VS0.select.values = [0 1];
%  opt.test.dominic_dep_inter_group1VS0.contrast.dom_sph_inter_group1VS0 = 1;
   
% The permutation tests
opt.nb_samps = 100;
opt.nb_batch = 3;

%% Generate the pipeline
[pipeline,opt_pipe] = niak_pipeline_glm_fir(files_in,opt);

%%extra
system(['cp ' mfilename('fullpath') '.m ' opt.folder_out '.']); % make a copie of this script to output folder
system(['mv ' files_in.model.group  ' ' opt.folder_out '.']); % move th generated model file  to output folder