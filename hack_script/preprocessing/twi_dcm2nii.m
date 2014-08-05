clear
path_dcm = '/database/twins_study/raw_dcm_MAJ/';
path_nii = '/database/twins_study/raw_nii_EXP2/';
opt_pipe.path_logs = [path_nii 'logs_conversion'];
list_subject = dir(path_dcm);
list_subject = {list_subject(3:end).name};

nb_subject = length(list_subject);
%nb_subject = 2;
pipeline = struct();
for num_s = 1:nb_subject
    subject = list_subject{num_s};
    fprintf('Subject %s\n',subject);
    path_sub = [path_dcm subject filesep];
    list_dates = dir(path_sub);
    list_dates = {list_dates(3:end).name};
    for num_d = 1:length(list_dates)
        date_v = list_dates{num_d};
        fprintf('    Date %s\n',date_v);
        path_read = [path_dcm subject filesep date_v filesep];        
        path_write = [path_nii subject filesep date_v filesep];
        path_tmp = [path_nii subject filesep date_v filesep 'tmp' filesep];
        name_job = strrep(subject,'-','_');
        name_job = sprintf('%s_date%i',name_job,num_d);
        pipeline.(name_job).files_in       = path_read;
        pipeline.(name_job).files_out.tmp  = path_tmp;
        pipeline.(name_job).files_out.func = [path_write 'func_' subject '_' date_v '.nii.gz'];
        pipeline.(name_job).files_out.anat = [path_write 'anat_' subject '_' date_v '.nii.gz'];
        pipeline.(name_job).opt.instr_conv = ['mcverter -o ' path_tmp ' -f nifti -n -u –fnformat=-PatientId+PatientName+SequenceName ' path_read];
        pipeline.(name_job).command        = 'system(opt.instr_conv); twi_mosaic2vol(files_out.tmp,files_out.func,files_out.anat);';        
        pipeline = psom_add_clean(pipeline,['clean_' name_job],path_tmp);
    end
end
psom_run_pipeline(pipeline,opt_pipe)

