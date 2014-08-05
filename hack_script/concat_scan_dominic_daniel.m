%%%%This script concatenate scan.s ID and dominic from Daniel, then with wisc-hand file, anfinally with test_combi_scanfirdom_scrub.csv

% read csv
csv_id_scan= niak_read_csv_cell('/home/yassinebha/Dropbox/twins_study/twins_data/behavioral_data_yassine/Data_combine/Correspondance_Scans_Jumeaux_daniel.csv' );
csv_id_domi= niak_read_csv_cell('/home/yassinebha/Dropbox/twins_study/twins_data/behavioral_data_yassine/Data_combine/dominic_daniel.csv' );
csv_id_concat= niak_read_csv_cell('/home/yassinebha/Dropbox/twins_study/twins_data/behavioral_data_yassine/Data_combine/test_combi_scanfirdom_scrub.csv' );
csv_id_hand= niak_read_csv_cell('/home/yassinebha/Dropbox/twins_study/twins_data/behavioral_data_yassine/Data_combine/hand_wisc.csv' );

% format scan ID's
for n_col=1:size(csv_id_scan)(2)
    for n_lin=1:size(csv_id_scan)(1)
    csv_id_scan{n_lin,n_col}(strfind(csv_id_scan{n_lin,n_col},'-'))='';
    csv_id_scan{n_lin,n_col}(strfind(csv_id_scan{n_lin,n_col},' '))='';
    end
end

% Loop over ID's and concatenate scans with dominic file from Daniel
csv_cell_combin = cell(size(csv_id_scan,1),size(csv_id_domi,2)+size(csv_id_scan,2));
n_shift = 0;
for n_cell_scan = 2:size(csv_id_scan(1:end,2),1)
    n_rep = 0;
    for n_cell_domi = 2:size(csv_id_domi(1:end,1),1)
        subj_match = strfind(csv_id_scan{n_cell_scan,2},char(csv_id_domi{n_cell_domi,1}));
        if ~isempty(subj_match)
           n_rep = n_rep + 1;
           if n_rep > 1 
              n_shift = n_shift + 1;
              csv_cell_combin(n_cell_scan + n_shift,:) = [ csv_id_scan(n_cell_scan,:)  csv_id_domi(n_cell_domi,:) ];
           else
              csv_cell_combin(n_cell_scan + n_shift ,:) = [ csv_id_scan(n_cell_scan,:)  csv_id_domi(n_cell_domi,:) ];
           end
        end
    end
    if n_rep == 0
    csv_cell_combin(n_cell_scan + n_shift ,:) = [ csv_id_scan(n_cell_scan,:) cell(size(csv_id_domi(n_cell_domi,:)))  ];
    end
end
csv_cell_combin(cellfun(@isempty,csv_cell_combin))='NaN';

% add tables headers and write a temporary combine file
csv_cell_combin(1,:) = [ csv_id_scan(1,:)  csv_id_domi(1,:) ];
%niak_write_csv_cell('/home/yassinebha/Dropbox/twins_study/twins_data/behavioral_data_yassine/Data_combine/tmp_combi_scan_dom_daniel.csv',csv_cell_combin);

% Loop over ID's and concatenate scan-domDaniel with handednes
csv_cell_combin_tmp = cell(size(csv_cell_combin,1),size(csv_cell_combin,2)+size(csv_id_hand,2));
n_shift = 0;
for n_cell_tmp = 2:size(csv_cell_combin(1:end,2),1)
    n_rep = 0;
    for n_cell_hand = 2:size(csv_id_hand(1:end,1),1)
        subj_match = strfind(csv_cell_combin{n_cell_tmp,2},char(csv_id_hand{n_cell_hand,1}));
        if ~isempty(subj_match)
           n_rep = n_rep + 1;
           if n_rep > 1 
              n_shift = n_shift + 1;
              csv_cell_combin_tmp(n_cell_tmp + n_shift,:) = [ csv_cell_combin(n_cell_tmp,:)  csv_id_hand(n_cell_hand,:) ];
           else
              csv_cell_combin_tmp(n_cell_tmp + n_shift,:) = [ csv_cell_combin(n_cell_tmp,:)  csv_id_hand(n_cell_hand,:) ];
           end
        end
    end
    if n_rep == 0
    csv_cell_combin_tmp(n_cell_scan + n_shift ,:) = [ csv_cell_combin(n_cell_tmp,:) cell(size(csv_id_hand(n_cell_hand,:)))  ];
    end
end
csv_cell_combin_tmp(cellfun(@isempty,csv_cell_combin_tmp))='NaN';
% add tables headers and write a temporary combine file
csv_cell_combin_tmp(1,:) = [ csv_cell_combin(1,:)  csv_id_hand(1,:) ];
niak_write_csv_cell('/home/yassinebha/Dropbox/twins_study/twins_data/behavioral_data_yassine/Data_combine/tmp_combi_scan_domdaniel_hand.csv',csv_cell_combin_tmp);

%Loop over ID's and concatenate firscan-domi-acrub with scan-domDaniel-hand 
clear csv_cell_combin
csv_cell_combin = csv_cell_combin_tmp;
csv_cell_combin_final = cell(size(csv_id_concat,1),size(csv_id_concat,2)+size(csv_cell_combin,2));
n_shift = 0;
for n_cell_concat = 2:(size(csv_id_concat(1:end,1),1))
    n_rep = 0;
    for n_combi = 2:size(csv_cell_combin(1:end,1),1)
        subj_match = strfind(csv_id_concat{n_cell_concat,1},char(csv_cell_combin{n_combi,1}));
        if ~isempty(subj_match)
           n_rep = n_rep + 1;
           if n_rep > 1 
              n_shift = n_shift + 1;
              csv_cell_combin_final(n_cell_concat + n_shift,:) = [ csv_id_concat(n_cell_concat,:) csv_cell_combin(n_combi,:) ];
           else
              csv_cell_combin_final(n_cell_concat + n_shift,:) = [ csv_id_concat(n_cell_concat,:) csv_cell_combin(n_combi,:) ];
           end
        end
    end
    if n_rep == 0;
       csv_cell_combin_final(n_cell_concat + n_shift ,:) = [ csv_id_concat(n_cell_concat,:)  cell(size(csv_cell_combin(n_combi,:))) ];
    end
end
    

%add tables headers
csv_cell_combin_final(1,:) = [ csv_id_concat(1,:) csv_cell_combin(1,:) ];
%Wright csv
[err,msg] = niak_write_csv_cell('/home/yassinebha/Dropbox/twins_study/twins_data/behavioral_data_yassine/Data_combine/concat_scan_dom_daniel.csv',csv_cell_combin_final);
