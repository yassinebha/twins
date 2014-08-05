 clear 
clc 

path_raw_fmri   = '/home/benhajal/database/twins/raw_mnc_EXP2/';
path_preprocess = '/home/benhajal/database/twins/fmri_preprocess_EXP3/';

%% Grab the raw data set

subjects_list = dir([path_raw_fmri]);
subjects_list = subjects_list(3:end);
subjects_list = char(subjects_list.name);

%%  Subject names
    for subject_n = 1:size(subjects_list,1)
        subject = subjects_list( subject_n,1:end);
        subject(strfind(subject," "))="";
        fprintf('Subject %s\n',subject)
        
        subject_sessions = dir([path_raw_fmri,subject]);
        subject_sessions = subject_sessions(3:end);
        subject_sessions = char(subject_sessions.name);
        
%%      Subject sessions names
        for num_sess = 1:size(subject_sessions,1)
            session = subject_sessions(num_sess,:);
            fprintf('    session %s\n',session)
            subject = subjects_list( subject_n,1:end);
%%          Adding the subject to the list of files
            path_fmri = [path_raw_fmri subject filesep session filesep];
            fmri_file = dir([path_fmri "func_*"]);
            path_anat = [path_raw_fmri subject filesep session filesep];
            anat_file = dir([path_anat "anat_*"]);
            
            subject(strfind(subject,"_"))="";
            subject(strfind(subject," "))="";
            files_in.([subject "s" num2str(num_sess)]).fmri.session1=[path_fmri fmri_file.name];   
            files_in.([subject "s" num2str(num_sess)]).anat=[path_anat anat_file.name];

        end
    end