
%  before preprocessing Twins dataset , this script removes blank and "-" character in the name fild for each subject.
%  It also correct raw _mnc header for listed subject below.
%  %  -------------------clearing blank and special caracter------------------------------------------------% %

clear all
path_raw_fmri = '/database/twins_study/raw_mnc_EXP2/';
cd (path_raw_fmri)
groups_list = dir([path_raw_fmri]);
groups_list = groups_list(3:end);
groups_list = char(groups_list.name);


for group_n = 1:size(groups_list,1)
    group = groups_list(group_n,1:end);
    group_new = group;
    group_new(findstr(group,"-")) = "_";
    group_new(strfind(group," "))="";
    fprintf('Subject %s\n',group)
    system(["mv " group " " group_new]);
    
end

%  %  -------------------correct raw _mnc funct header for listed subjecs to z=-5------------------------------------------------% %

label_s = {
'ARV_2039589',
'ASA_2070322',
'A_D_2054080',
'A_R_2084201',
'B_E_2061226',
'B_G_2061815',
'C_D_2079893',
'DAK_2078552',
'D_B_2085392',
'D_P_2042676',
'EBL_2039585',
'ERB_2066405',
'E_R_2049899',
'E_R_2087767',
'E_T_2048019',
'G_B_2073423',
'G_C_2058859',
'IRT_2049901',
'J_B_2061222',
'KAM_2088969',
'K_M_2051299',
'L_C_2082791',
'L_L_2069687',
'MAB_2055334',
'NGD_2057635',
'R_B_2066407',
'R_G_1294341',
'S_B_2090415',
'S_G_1294342',
'T_T_2078556',
'V_D_2079869',
'V_G_2083559',
'V_L_2065305',
'J_R_2053029',
'F_E_2072774'};


for ss=1:size(label_s,1)

    file_list = dir([path_raw_fmri label_s{ss}]);
    file_list = file_list(3:end);
    file_list = char(file_list.name);
    
    
    for date_s=1:size(file_list,1)
        func_file = dir([path_raw_fmri label_s{ss} filesep file_list(date_s,:) filesep 'f*mnc.gz']);
        func_file = char(func_file.name);
        parent_file = [path_raw_fmri label_s{ss} filesep file_list(date_s,:) filesep func_file];
        fprintf('correcting Subject %s\n',func_file)
        [hdr,vol]=niak_read_vol(parent_file);
        hdr.info.mat(3,3) = -5;
        hdr.file_name = parent_file;
        niak_write_vol(hdr,vol);
    end
end

