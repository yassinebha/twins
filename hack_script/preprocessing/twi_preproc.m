% Create the inputs of and launch the NIAK_PIPELINE_FMRI_PREPROCESS on the
% specified dataset (RECONSOLIDATION dataset)
 clear 
clc 
p=genpath('/home/yassinebha/quarantaine/niak_current');
addpath(p);

path_raw_fmri   = '/home/yassinebha/database/twins_study/raw_mnc';
path_preprocess = '/sb/scratch/yassinebha/database/twins_study/fmri_preprocess/';
%/data/lepore/mpelland/minc_conv/anat/CB/VD_AlCh

    groups_list = dir([path_raw_fmri]);
    groups_list = groups_list(3:end);
    groups_list = char(groups_list.name);
   
    for group_n = 1:size(groups_list,1)
        group = groups_list(group_n,1:end);
	group(strfind(group," "))="";
        fprintf('Subject %s\n',group)
        subjects_list = dir([path_raw_fmri,filesep,group]);
        subjects_list = subjects_list(3:end);
	subjects_list = char(subjects_list.name);

	n_sess = 0;
        for num_s = 1:size(subjects_list,1)
	    n_sess=n_sess+1;
            fmri = struct();

            %% Subject file names
            subject = subjects_list(num_s,:);
            fprintf('    session %s\n',subject)
            path_fmri = [path_raw_fmri filesep group filesep subject filesep];
            fmri_file = dir([path_fmri "func_*"]);
            %fmri_file = fmri_file(3:end);
            fmri.(["session" num2str(n_sess)]){1}=[path_fmri fmri_file.name];
          
            path_anat = [path_raw_fmri filesep group filesep subject filesep];
            anat_file = dir([path_anat "anat_*"]);
            %anat_file = anat_file(3:end);
            anat= [path_anat anat_file.name];

            %% Adding the subject to the list of files that need to be preprocessed

            files_in.([group ]).fmri = fmri;
            files_in.([group ]).anat = anat;
        end
    end
%% Building the optional inputs
opt.folder_out = path_preprocess;
opt.size_output = 'all';

%%%%%%%%%%%%%%%%%%%%
%% Bricks options %%
%%%%%%%%%%%%%%%%%%%%

%% Slice timing
opt.slice_timing.type_acquisition = 'interleaved ascending'; % Slice timing order (available options : 'sequential ascending', 'sequential descending', 'interleaved ascending', 'interleaved descending')
opt.slice_timing.type_scanner     = 'Siemens';               % Scanner manufacturer. Only the value 'Siemens' will actually have an impact
opt.slice_timing.delay_in_tr      = 0;                       % The delay in TR ("blank" time between two volumes) tr =  2.6500
opt.slice_timing.suppress_vol = 3; % Remove the first three dummy scans

%% Linear and non-linear fit of the anatomical image in the stereotaxic
%% space
opt.t1_preprocess.nu_correct.arg = '-distance 200'; % Parameter for non-uniformity correction. 200 is a suggested value for 1.5T images, 25 for 3T images. If you find that this stage did not work well, this parameter is usually critical to improve the results.

% T1-T2 coregistration (niak_brick_anat2func)
opt.anat2func.init = 'identity'; % An initial guess of the transform. Possible values 'identity', 'center'. 'identity' is self-explanatory. The 'center' option usually does more harm than good. Use it only if you have very big misrealignement between the two images (say, 2 cm).

%% Temporal filetring (niak_brick_time_filter)
opt.time_filter.hp = 0.01; % Apply a high-pass filter at cut-off frequency 0.01Hz (slow time drifts)
opt.time_filter.lp = Inf; % Do not apply low-pass filter. Low-pass filter induce a big loss in degrees of freedom without sgnificantly improving the SNR.

%% Correction of physiological noise (niak_pipeline_corsica)
opt.corsica.sica.nb_comp = 60;
opt.corsica.component_supp.threshold = 0.15;

%% Resampling in the stereotaxic space (niak_brick_resample_vol) 3.3063   3.3063   4.9211 # 3.3298   3.3298   4.9559 # 3.2370   3.2370   4.8179
opt.resample_vol.interpolation       = 'trilinear'; % The resampling scheme. The most accurate is 'sinc' but it is awfully slow
opt.resample_vol.voxel_size          = [3 3 3];    % The voxel size to use in the stereotaxic space

%% Spatial smoothing (niak_brick_smooth_vol)
opt.bricks.smooth_vol.fwhm = 6; % Apply an isotropic 6 mm gaussin smoothing.

%% Region growing
opt.region_growing.flag_skip = 1; % Turn on/off the region growing

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generation of the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opt.flag_test = false;
%opt.psom.max_queued = 15; % Please try to use the two processors of my laptop, thanks !
[pipeline,opt] = niak_pipeline_fmri_preprocess(files_in,opt);
