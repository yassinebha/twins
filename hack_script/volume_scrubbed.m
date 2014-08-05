% read fmri extra.mat from preprocessing, then extract for each subject the supressed mack volme after scrubbing then concatenate them in one csv file
% read 
subjects_list = dir(pwd);
subjects_list = subjects_list(3:end);
subjects_list={subjects_list.name}';


mask_suppressed_final= []
n_shift = 0;
for n_subj_list = 1:size(subjects_list(1:end,1),1)
    
    subj_match = strfind(subjects_list{n_subj_list,1},'.mat');
        if ~isempty(subj_match)
              load ( subjects_list{n_subj_list,1} )
              mask_suppressed_final= [mask_suppressed_final mask_suppressed] ;
              n_shift = n_shift + 1;      
        end
end
niak_write_csv('/home/benhajal/mask_suppressed_final.csv',mask_suppressed_final);