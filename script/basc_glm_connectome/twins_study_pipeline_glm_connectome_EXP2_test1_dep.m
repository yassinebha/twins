
clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting root path for selected server%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% findout wich server and set root path fo each case server
type_pre        = 'EXP2_test1';
type_test       = {'conf_1','conf_2','conf_3','conf_4'};
type_desorder   = 'dominic_dep_'
%  type_desorder   = {'dominic_anxs_','dominic_anxg_','dominic_dep_','dominic_phos_','dominic_prbc_','dominic_ihi_','dominic_opp_','dominic_forc_'};
for tt = 1:length (type_test)
    fprintf ('desorder: %s\n', type_desorder)
    fprintf ('test: %s\n',type_test{tt})
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

    %%%%%%%%%%%%
    %% Grabbing the results from BASC
    %%%%%%%%%%%%
    files_in = niak_grab_stability_rest([root_path 'basc_' type_pre]);

    %%%%%%%%%%%%
    %% Grabbing the results from the NIAK fMRI preprocessing pipeline
    %%%%%%%%%%%%
    opt_g.min_nb_vol = 100;     % The minimum number of volumes for an fMRI dataset to be included. This option is useful when scrubbing is used, and the resulting time series may be too short.
    opt_g.type_files = 'glm_connectome'; % Specify to the grabber to prepare the files for the glm_connectome pipeline
    files_in.fmri = niak_grab_fmri_preprocess([root_path 'fmri_preprocess_' type_pre ],opt_g).fmri; % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 

    %%%%%%%%%%%%
    %% Set the models
    %%%%%%%%%%%%
    %individual models and raw group model
    switch server
          case 'guillimin'
                subj= fieldnames(files_in.fmri);
                for n= 1:length(subj)
                files_in.model.individual.(subj{n}).intra_run.session1.run1.event= '/home/yassinebha/svn/yassine/script/models/twins/twins_model_intra_run.csv';
                end
                files_in.model.group = '/home/yassinebha/svn/yassine/script/models/twins/dominic_interactive.csv';
                dominic_test         = '/home/yassinebha/svn/yassine/script/models/twins/dominic_all_test.csv';
          case 'mammouth'
                subj= fieldnames(files_in.fmri);
                for n= 1:length(subj)
                files_in.model.individual.(subj{n}).intra_run.session1.run1.event= '/home/benhajal/svn/yassine/script/models/twins/twins_model_intra_run.csv';
                end
                files_in.model.group = '/home/benhajal/svn/yassine/script/models/twins/dominic_interactive.csv';
                dominic_test         = '/home/benhajal/svn/yassine/script/models/twins/dominic_all_test.csv';
          case 'peuplier'
                subj= fieldnames(files_in.fmri);
                for n= 1:length(subj)
                files_in.model.individual.(subj{n}).intra_run.session1.run1.event= '/home/yassinebha/svn/yassine/script/models/twins/twins_model_intra_run.csv';
                end
                files_in.model.group = '/home/yassinebha/svn/yassine/script/models/twins/dominic_interactive.csv';
                dominic_test         = '/home/yassinebha/svn/yassine/script/models/twins/dominic_all_test.csv';
    end           

    % building a new csv model file from raw group model file by defining control and patient for a varaiable of intereset
    switch type_test{tt}
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
    name_save              = [ root_path 'basc_' type_pre filesep 'dominic_interactive_model_' type_test{tt} '.csv' ];
    niak_write_csv_cell ( name_save ,csv_cell_combin);

    %set path for newly created group model file
    files_in.model.group   =  name_save ;


    %%%%%%%%%%%%%
    %% Options %%
    %%%%%%%%%%%%%
    opt = struct();
    opt = psom_struct_defaults(opt,{'folder_out'},{[root_path,'glm_connectome_',type_pre,filesep,type_desorder,type_test{tt},filesep]},false);
    opt.folder_out = niak_full_path(opt.folder_out);
    opt.fdr = 0.05; % The maximal false-discovery rate that is tolerated both for individual (single-seed) maps and whole-connectome discoveries, at each particular scale (multiple comparisons across scales are addressed via permutation testing)
    opt.fwe = 0.05; % The overall family-wise error, i.e. the probablity to have the observed number of discoveries, agregated across all scales, under the global null hypothesis of no association.
    opt.nb_samps = 1000; % The number of samples in the permutation test. This number has to be multiplied by OPT.NB_BATCH below to get the effective number of samples
    opt.nb_batch = 10; % The permutation tests are separated into NB_BATCH independent batches, which can run on parallel if sufficient computational resources are available
    opt.flag_rand = false; % if the flag is false, the pipeline is deterministic. Otherwise, the random number generator is initialized based on the clock for each job.

    %%%%%%%%%%%
    %% TESTS %%
    %%%%%%%%%%%  

    % Main effects of blocs
    %% neutral
    opt.test.main_neutral.group.contrast.intercept           = 1;
    opt.test.main_neutral.intra_run.type                     = 'correlation';
    opt.test.main_neutral.intra_run.select(1).label          = 'neutral';
    opt.test.main_neutral.intra_run.select(1).min            = 0.9;

    %% sad
    opt.test.main_sad.group.contrast.intercept              = 1;
    opt.test.main_sad.intra_run.type                        = 'correlation';
    opt.test.main_sad.intra_run.select(1).label             = 'neutral';
    opt.test.main_sad.intra_run.select(1).min               = 0.9;

    % Comparisons between Blocs
    opt.test.neutral_VS_sad.group.contrast.intercept        = 1;
    opt.test.neutral_VS_sad.intra_run.type                  = 'correlation';
    opt.test.neutral_VS_sad.intra_run.select(1).label       = 'neutral';
    opt.test.neutral_VS_sad.intra_run.select(1).min         = 0.9;
    opt.test.neutral_VS_sad.intra_run.select_diff(1).label  = 'sad';
    opt.test.neutral_VS_sad.intra_run.select_diff(1).min    = 0.9;


    % Comparisons between groups

    %%hdi_dep
    opt.test.hdi_dep.group.contrast.hdi_dep= 1;

    %%dominic_dep_AA : control_anxs vs pathologic_anxs
    opt.test.(strcat(type_desorder,type_test{tt},'AA')).group.select.label                       = 'group0_vs_group1_hdi_dep';
    opt.test.(strcat(type_desorder,type_test{tt},'AA')).group.select.values                      = [0 1];
    opt.test.(strcat(type_desorder,type_test{tt},'AA')).group.contrast.hdi_dep                  = 1;

    %%dominic_dep_AB : control_anxs (AND-low internalizing score) vs pathologic_anxs
    opt.test.(strcat(type_desorder,type_test{tt},'AB')).group.select(1).label                    = 'group0_vs_group1_hdi_dep';
    opt.test.(strcat(type_desorder,type_test{tt},'AB')).group.select(1).values                   = [0];
    opt.test.(strcat(type_desorder,type_test{tt},'AB')).group.select(2).label                    = 'hdi_anxs';
    opt.test.(strcat(type_desorder,type_test{tt},'AB')).group.select(2).max                      = model.hdi_anxs.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'AB')).group.select(2).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'AB')).group.select(3).label                    = 'hdi_anxg';
    opt.test.(strcat(type_desorder,type_test{tt},'AB')).group.select(3).max                      = model.hdi_anxg.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'AB')).group.select(3).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'AB')).group.select(4).label                    = 'hdi_phos';
    opt.test.(strcat(type_desorder,type_test{tt},'AB')).group.select(4).max                      = model.hdi_phos.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'AB')).group.select(4).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'AB')).group.select(5).label                    = 'hdi_forc';
    opt.test.(strcat(type_desorder,type_test{tt},'AB')).group.select(5).min                      = model.hdi_forc.min_control;
    opt.test.(strcat(type_desorder,type_test{tt},'AB')).group.select(5).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'AB')).group.select(6).label                    = 'group0_vs_group1_hdi_dep';
    opt.test.(strcat(type_desorder,type_test{tt},'AB')).group.select(6).values                   = [1];
    opt.test.(strcat(type_desorder,type_test{tt},'AB')).group.contrast.group0_vs_group1_hdi_dep = 1;

    %%dominic_dep_AC : control_anxs (AND-low internalizing score AND-low externalizing score) vs pathologic_anxs
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(1).label                    = 'group0_vs_group1_hdi_dep';
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(1).values                   = [0];
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(2).label                    = 'hdi_anxs';
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(2).max                      = model.hdi_anxs.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(2).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(3).label                    = 'hdi_anxg';
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(3).max                      = model.hdi_anxg.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(3).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(4).label                    = 'hdi_phos';
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(4).max                      = model.hdi_phos.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(4).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(5).label                    = 'hdi_forc';
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(5).min                      = model.hdi_forc.min_control;
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(5).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(6).label                    = 'hdi_prbc';
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(6).max                      = model.hdi_prbc.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(6).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(7).label                    = 'hdi_ihi';
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(7).max                      = model.hdi_ihi.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(7).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(8).label                    = 'hdi_opp';
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(8).max                      = model.hdi_opp.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(8).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(9).label                    = 'group0_vs_group1_hdi_dep';
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.select(9).values                   = [1];
    opt.test.(strcat(type_desorder,type_test{tt},'AC')).group.contrast.group0_vs_group1_hdi_dep = 1;

    %%dominic_dep_BA : control_anxs vs pathologic_anxs (AND-low externalizing score)
    opt.test.(strcat(type_desorder,type_test{tt},'BA')).group.select(1).label                    = 'group0_vs_group1_hdi_dep';
    opt.test.(strcat(type_desorder,type_test{tt},'BA')).group.select(1).values                   = [1];
    opt.test.(strcat(type_desorder,type_test{tt},'BA')).group.select(2).label                    = 'hdi_prbc';
    opt.test.(strcat(type_desorder,type_test{tt},'BA')).group.select(2).max                      = model.hdi_prbc.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'BA')).group.select(2).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'BA')).group.select(3).label                    = 'hdi_ihi';
    opt.test.(strcat(type_desorder,type_test{tt},'BA')).group.select(3).max                      = model.hdi_ihi.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'BA')).group.select(3).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'BA')).group.select(4).label                    = 'hdi_opp';
    opt.test.(strcat(type_desorder,type_test{tt},'BA')).group.select(4).max                      = model.hdi_opp.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'BA')).group.select(4).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'BA')).group.select(5).label                    = 'group0_vs_group1_hdi_dep';
    opt.test.(strcat(type_desorder,type_test{tt},'BA')).group.select(5).values                   = [0];
    opt.test.(strcat(type_desorder,type_test{tt},'BA')).group.contrast.group0_vs_group1_hdi_dep = 1;

    %%dominic_dep_BB : control_anxs (AND-low internalizing score) vs pathologic_anxs (AND-low externalizing score)
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(1).label                    = 'group0_vs_group1_hdi_dep';
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(1).values                   = [1];
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(2).label                    = 'hdi_prbc';
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(2).max                      = model.hdi_prbc.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(2).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(3).label                    = 'hdi_ihi';
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(3).max                      = model.hdi_ihi.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(3).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(4).label                    = 'hdi_opp';
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(4).max                      = model.hdi_opp.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(4).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(5).label                    = 'group0_vs_group1_hdi_dep';
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(5).values                   = [0];
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(6).label                    = 'hdi_anxs';
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(6).max                      = model.hdi_anxs.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(6).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(7).label                    = 'hdi_anxg';
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(7).max                      = model.hdi_anxg.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(7).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(8).label                    = 'hdi_phos';
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(8).max                      = model.hdi_phos.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(8).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(9).label                    = 'hdi_forc';
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(9).min                      = model.hdi_forc.min_control;
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.select(9).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'BB')).group.contrast.group0_vs_group1_hdi_dep = 1;

    %%dominic_dep_BC : control_anxs (AND-low internalizing score AND-low externalizing score) vs pathologic_anxs (AND-low externalizing score)
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(1).label                    = 'group0_vs_group1_hdi_dep';
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(1).values                   = [1];
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(2).label                    = 'hdi_prbc';
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(2).max                      = model.hdi_prbc.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(2).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(3).label                    = 'hdi_ihi';
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(3).max                      = model.hdi_ihi.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(3).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(4).label                    = 'hdi_opp';
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(4).max                      = model.hdi_opp.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(4).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(5).label                    = 'group0_vs_group1_hdi_dep';
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(5).values                   = [0];
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(6).label                    = 'hdi_anxs';
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(6).max                      = model.hdi_anxs.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(6).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(7).label                    = 'hdi_anxg';
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(7).max                      = model.hdi_anxg.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(7).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(8).label                    = 'hdi_phos';
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(8).max                      = model.hdi_phos.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(8).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(9).label                    = 'hdi_forc';
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(9).min                      = model.hdi_forc.min_control;
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(9).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(10).label                   = 'hdi_prbc';
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(10).max                     = model.hdi_prbc.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(10).operation               = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(11).label                   = 'hdi_ihi';
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(11).max                     = model.hdi_ihi.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(11).operation               = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(12).label                   = 'hdi_opp';
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(12).max                     = model.hdi_opp.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.select(12).operation               = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'BC')).group.contrast.group0_vs_group1_hdi_dep = 1;

    %%dominic_dep_CA : control_anxs vs pathologic_anxs (AND-low internalizing score AND-low externalizing score)
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(1).label                    = 'group0_vs_group1_hdi_dep';
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(1).values                   = [1];
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(2).label                    = 'hdi_prbc';
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(2).max                      = model.hdi_prbc.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(2).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(3).label                    = 'hdi_ihi';
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(3).max                      = model.hdi_ihi.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(3).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(4).label                    = 'hdi_opp';
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(4).max                      = model.hdi_opp.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(4).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(5).label                    = 'hdi_anxs';
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(5).max                      = model.hdi_anxs.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(5).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(6).label                    = 'hdi_anxg';
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(6).max                      = model.hdi_anxg.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(6).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(7).label                    = 'hdi_phos';
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(7).max                      = model.hdi_phos.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(7).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(8).label                    = 'hdi_forc';
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(8).min                      = model.hdi_forc.min_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(8).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(9).label                    = 'group0_vs_group1_hdi_dep';
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.select(9).values                   = [0];
    opt.test.(strcat(type_desorder,type_test{tt},'CA')).group.contrast.group0_vs_group1_hdi_dep = 1;

    %%dominic_dep_CB : control_anxs (AND-low internalizing score) vs pathologic_anxs (AND-low internalizing score AND-low externalizing score)
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(1).label                    = 'group0_vs_group1_hdi_dep';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(1).values                   = [1];
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(2).label                    = 'hdi_prbc';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(2).max                      = model.hdi_prbc.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(2).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(3).label                    = 'hdi_ihi';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(3).max                      = model.hdi_ihi.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(3).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(4).label                    = 'hdi_opp';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(4).max                      = model.hdi_opp.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(4).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(5).label                    = 'hdi_anxs';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(5).max                      = model.hdi_anxs.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(5).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(6).label                    = 'hdi_anxg';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(6).max                      = model.hdi_anxg.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(6).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(7).label                    = 'hdi_phos';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(7).max                      = model.hdi_phos.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(7).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(8).label                    = 'hdi_forc';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(8).min                      = model.hdi_forc.min_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(8).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(9).label                    = 'group0_vs_group1_hdi_dep';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(9).values                   = [0];
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(10).label                   = 'hdi_anxs';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(10).max                     = model.hdi_anxs.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(10).operation               = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(11).label                   = 'hdi_anxg';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(11).max                     = model.hdi_anxg.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(11).operation               = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(12).label                   = 'hdi_phos';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(12).max                     = model.hdi_phos.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(12).operation               = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(13).label                   = 'hdi_forc';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(13).min                     = model.hdi_forc.min_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.select(13).operation               = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CB')).group.contrast.group0_vs_group1_hdi_dep = 1;

    %%dominic_dep_CC : control_anxs (AND-low internalizing score AND-low externalizing score) vs pathologic_anxs (AND-low internalizing score AND-low externalizing score)
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.select(1).label                    = 'group0_vs_group1_hdi_dep';
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.select(1).values                   = [0 1];
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.select(2).label                    = 'hdi_prbc';
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.select(2).max                      = model.hdi_prbc.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.select(2).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.select(3).label                    = 'hdi_ihi';
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.select(3).max                      = model.hdi_ihi.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.select(3).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.select(4).label                    = 'hdi_opp';
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.select(4).max                      = model.hdi_opp.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.select(4).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.select(5).label                    = 'hdi_anxs';
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.select(5).max                      = model.hdi_anxs.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.select(5).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.select(6).label                    = 'hdi_anxg';
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.select(6).max                      = model.hdi_anxg.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.select(6).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.select(7).label                    = 'hdi_phos';
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.select(7).max                      = model.hdi_phos.max_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.select(7).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.select(8).label                    = 'hdi_forc';
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.select(8).min                      = model.hdi_forc.min_control;
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.select(8).operation                = 'and';
    opt.test.(strcat(type_desorder,type_test{tt},'CC')).group.contrast.group0_vs_group1_hdi_dep = 1;

    %%%%%%%%%%%%%%%%%%%%%%
    %% Run the pipeline %%
    %%%%%%%%%%%%%%%%%%%%%%
    switch server
          case 'guillimin'
          opt.psom.qsub_options = '-q sw -l nodes=1:ppn=2,walltime=09:00:00';
          case 'mammouth'
          %opt.psom.qsub_options = '-q qwork@ms -l nodes=1:m32G,walltime=05:00:00';
          opt.psom.qsub_options = '-q qwork@ms -l nodes=1:ppn=2,walltime=09:00:00';
    end      
    opt.flag_test  = false;
    opt.psom.flag_pause = false;
    [pipeline,opt] = niak_pipeline_glm_connectome(files_in,opt);

    %extra
    system(['cp ' mfilename('fullpath') '.m ' opt.folder_out '.']); % make a copie of this script to output folder
    system(['mv ' files_in.model.group  ' ' opt.folder_out '.']); % move th generated model file  to output folder
end