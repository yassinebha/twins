
%%%%This script concatenate dominic with scrubbing 

% read ID list from twins/stability_fir_all_sad_blocs_EXP2_test1/stability_ind
subjects_list = dir(pwd);
subjects_list = subjects_list(3:end-3);
subjects_list={subjects_list.name}';

% read dominic file
csv_cell_dominic= niak_read_csv_cell ('/home/benhajal/svn/yassine/script/models/twins/dominic_fir_group0a1_minus_group11a20.csv');

%Loop over fir's ID'subject and concatenatethen with dominic-subject
csv_cell_combin = cell(size(subjects_list,1),size(subjects_list,2)+size(csv_cell_dominic,2));
n_shift = 0;
for n_cell_subj_list = 2:size(subjects_list(1:end,1),1)
    n_rep = 0;
    for n_cell_dom = 2:size(csv_cell_dominic(1:end,1),1)
        subj_match = strfind(subjects_list{n_cell_subj_list,1},char(csv_cell_dominic{n_cell_dom,1}));
        if ~isempty(subj_match)
           n_rep = n_rep + 1;
           if n_rep > 1 
              n_shift = n_shift + 1;
              csv_cell_combin(n_cell_subj_list + n_shift,:) = [ subjects_list(n_cell_subj_list,:)  csv_cell_dominic(n_cell_dom,:) ];
           else
              csv_cell_combin(n_cell_subj_list + n_shift ,:) = [ subjects_list(n_cell_subj_list,:)  csv_cell_dominic(n_cell_dom,:) ];
           end
        end
    end
    if n_rep == 0
    csv_cell_combin(n_cell_subj_list + n_shift ,:) = [ subjects_list(n_cell_subj_list,:) cell(size(csv_cell_dominic(n_cell_dom,:)))  ];
    end
end
csv_cell_combin(cellfun(@isempty,csv_cell_combin))='NaN';
niak_write_csv_cell('/home/benhajal/svn/yassine/script/models/twins/test_combi_scanfir_dom.csv',csv_cell_combin);

%Loop over ID's and concatenate dominic-fir and scrubbing
csv_cell_scrub  = niak_read_csv_cell ('/home/benhajal/database/twins/fmri_preprocess_EXP2_test1/quality_control/group_motion/qc_scrubbing_group.csv');
csv_cell_combin_final = cell(size(csv_cell_combin,1),size(csv_cell_combin,2)+size(csv_cell_scrub,2));
%empties_id = find(cellfun(@isempty,csv_cell_combin(1:end,1)));
n_shift = 0;
%for n_cell_combin = 2:(size(csv_cell_combin(1:end,1),1)-size(empties_id,1)+1)
for n_cell_combin = 2:(size(csv_cell_combin(1:end,1),1))
    n_rep = 0;
    for n_cell_scrub = 2:size(csv_cell_scrub(1:end,1),1)
        subj_match = strfind(csv_cell_combin{n_cell_combin,1},char((csv_cell_scrub{n_cell_scrub,1})(1:end-14)));
        if ~isempty(subj_match)
           n_rep = n_rep + 1;
           if n_rep > 1 
              n_shift = n_shift + 1;
              csv_cell_combin_final(n_cell_combin + n_shift,:) = [ csv_cell_combin(n_cell_combin,:)  csv_cell_scrub(n_cell_scrub,:) ];
           else
              csv_cell_combin_final(n_cell_combin + n_shift,:) = [ csv_cell_combin(n_cell_combin,:)  csv_cell_scrub(n_cell_scrub,:) ];
           end
        end
    end
    if n_rep == 0;
       csv_cell_combin_final(n_cell_combin + n_shift ,:) = [ csv_cell_combin(n_cell_combin,:)  cell(size(csv_cell_scrub(n_cell_scrub,:))) ];
    end
end
    

%add tables headers
csv_cell_combin_final(1,:) = [ 'ID_fir'  csv_cell_dominic(1,:) csv_cell_scrub(1,:) ];
%Wright csv
[err,msg] = niak_write_csv_cell('/home/benhajal/svn/yassine/script/models/twins/test_combi_scanfirdom_scrub.csv',csv_cell_combin_final);