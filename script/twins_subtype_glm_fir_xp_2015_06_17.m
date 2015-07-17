% Twins Movie subgoups fir

%  EXP1a: Scrubbing off - Normalisation 'fir_shape' - scale sci140_scg140_scf151

clear all

%% Parameters
path_root =  '/media/yassinebha/database2/twins_movie/twins_tmp/';
list_scale = { 'sci140_scg140_scf151'};
tr = {'3000'};

fir = 'fir_shape';
scrub = '_noscrub';
list_cov = { 'dominic_dep','sexe','FD' };
list_remove_pheno = { 'frames_OK','frames_scrubbed'};

%%Load phenotypes and scrubbing data
%combine pheno and scrubbing
pheno_raw = niak_read_csv_cell('~/github_repos/twins/script/models/twins/dominic_dep_group0a1_minus_group11a20_tmp2.csv');
master_cell = pheno_raw;
files_out  = niak_grab_all_preprocess([path_root 'fmri_preprocess_EXP2_test2']);
slave_cell = niak_read_csv_cell(files_out.quality_control.group_motion.scrubbing);
ly = slave_cell(1,:);
slave_cell = slave_cell(2:end,:);
%mask_slave_cell = strfind(slave_cell(:,1),[task tr{1}]);%mask selected task and tr
%mask_slave_cell = cellfun(@isempty,mask_slave_cell);
%slave_cell(mask_slave_cell,:) = [];
slave_cell = [ly; slave_cell];
for cc = 1:length(slave_cell)-1;
    slave_cell{cc+1,1} = slave_cell{cc+1,1}(1:end-14);
end
pheno = combine_cell_tab(master_cell,slave_cell);
niak_write_csv_cell('/home/yassinebha/Desktop/pheno_test.csv',pheno)
%%cleannig data
%remove unused pheno
mask_remove_pheno = ones(1,size(pheno,2));
for cc = 1: length(list_remove_pheno)
    mask_tmp = strfind(pheno(1,:),list_remove_pheno{cc});
    mask_tmp = cellfun(@isempty,mask_tmp);
    mask_remove_pheno = mask_remove_pheno & mask_tmp ;
end
pheno(:,~mask_remove_pheno)=[];
pheno(:,9)=[];%remove extra id colomn
%pheno(:,3) = strrep(pheno(:,3),'M','1'); %replace male 'M' by '1'
%pheno(:,3) = strrep(pheno(:,3),'F','0'); %replace female 'F' by '0'
%pheno(:,4) = strrep(pheno(:,4),'Right','1'); %replace 'Right' by '1'
%pheno(:,4) = strrep(pheno(:,4),'Left','0'); %replace 'Left' by '0'
%pheno(:,4) = strrep(pheno(:,4),'None','NaN'); %replace 'None' by 'NaN'
%mask_pheno = cellfun(@(x) str2num(x)>100, pheno(2:end,2));%create mask for wrong age cells less than 100
lx = pheno(2:end,1);
%lx(mask_pheno,:) = [];%remove wrong age cells ID
ly = pheno(1,2:end)';
pheno = pheno(2:end,2:end);
%pheno(mask_pheno,:) = [];%remove wrong age cells data



%% Load data
for tt = 1:length(list_scale)
    path_read  = [path_root 'stability_fir_all_sad_blocs_EXP2_test2/stability_group/fir/'];
    path_fmri  = [path_root 'fmri_preprocess_EXP2_test2/fmri/'];
    list_files = dir([path_read 'fir_group_level_*']);
    list_files = {list_files.name};
    
    for ff = 1:length(list_files);
        subject = list_files{ff}(17:end-4);
        ind_s = find(ismember(lx,subject));
        if isempty(ind_s)
            warning('Could not find subject %s',subject)
            list_files{ff}= [];
        end
    end
    list_files(cellfun(@isempty,list_files)) = [];   %remove empty cells 
    pheno_r = cell(length(list_files),size(pheno,2));
    for ff = 1:length(list_files);
        subject = list_files{ff}(17:end-4);
        ind_s = find(ismember(lx,subject));
        pheno_r(ff,:) = pheno(ind_s,:);
        data = load([path_read list_files{ff}],list_scale{tt});
        fir_all{tt}(:,:,ff) = data.(list_scale{tt}).fir_mean;
    end
end

%%convert all pheno from string to numeric
pheno_num = zeros(size(pheno_r));
for xx = 1:size(pheno_r,1)
    %for yy = 1:size(pheno_r,2)
    for yy = 1:size(pheno_r,2)
        if isempty(pheno_r{xx,yy})
            pheno_num(xx,yy) = NaN;
        else
            pheno_num(xx,yy) = str2num(pheno_r{xx,yy});
        end
    end
end

% visualise the partition
path_scales =  [path_root 'stability_fir_all_sad_blocs_EXP2_test2/stability_group/' list_scale{1} ];
opt.flag_zip = true;
niak_brick_mnc2nii(path_scales,[path_scales '_nii'],opt)
cd([path_scales '_nii'])
max_effect_vol(['brain_partition_consensus_group_' list_scale{1} '.nii.gz'],['fdr_group_average_' list_scale{1} '.mat']);
system('mricron  ~/database/white_template.nii.gz -c -0 -o max_abs_eff.nii.gz -c "5redyell" -l 0.005 -h 0.5 -z  &');
system(['mricron ~/database/white_template.nii.gz -c -0 -o ' path_scales '_nii/brain_partition_consensus_group_' list_scale{1} '.nii.gz -c NIH -l 1 -h 152 -z &']);

%% More parameters    0104892
%list_ind = [ 19 , 33 ];
list_ind = [ 32 , 81, 87];
list_color = {'r','b','g','k','p'};
clf

%% Hierarchical clustering
for tt = 1:length(tr)
    hold off
    for ii = 1:length(list_ind)
        % Clustering of subtypes
        figure(ii)
        clf
        fir_td = squeeze(fir_all{tt}(:,list_ind(ii),:));
        fir_td = fir_td./repmat(sqrt(sum(fir_td.^2,1)),[size(fir_td,1) 1]);
        fir_td(isnan(fir_td)) = 0;
        fir_td = fir_td - repmat(mean(fir_td,2),[1 size(fir_td,2)]);
        D = niak_build_distance (fir_td);
        hier = niak_hierarchical_clustering (-D);
        sil = niak_build_avg_silhouette(-D,hier);
        %[val,nb_clust(tt)] = max(sil(1:50));
        val = NaN;
        nb_clust(tt) = 5;
        fprintf('Twins_movie, max silhouette %1.2f at scale %i\n',val,nb_clust(tt))
        part = niak_threshold_hierarchy (hier,struct('thresh',nb_clust(tt)));
        order = niak_hier2order (hier);
        subplot(3,length(tr),tt)
        niak_visu_matrix(D(order,order));
        title(sprintf('Twins movie scale %s cluster %i',list_scale{1},list_ind(ii)));
        subplot(3,length(tr),tt+length(tr))
        niak_visu_part(part(order))
        subplot(3,length(tr),tt+2*length(tr))
        plot(sil)
        %hold on
        %plot(nb_clust(tt),val,'rx')
        %hold off
        % Show the subtypes
        figure(ii+length(list_ind))
        clf
        subplot(1,length(tr),tt)
        title(sprintf('Twins-Movie  scale %s cluster %i',list_scale{1},list_ind(ii)));
        for cc = 1:nb_clust(tt)        
            hold on 
            plot(mean(fir_all{tt}(:,list_ind(ii),part==cc),3),list_color{cc})
        end
        hold off
        %% Build distance scores for all subtypes
        for cc = 1:nb_clust(tt)        
            avg_clust(:,cc) = mean(fir_td(:,part==cc),2);
            %weights(:,cc) = sum((fir_td-repmat(avg_clust(:,cc),[1 size(fir_td,2)])).^2);
            weights(:,cc) = corr(fir_td,avg_clust(:,cc));
        end
        
        %% GLM analysis 
        list_cov = { 'dominic_dep','sexe','FD' };
        mask_covar = [];
        ind=[];
        covar = [];
        for cco = 1:length(list_cov)
            ind_cov = find(ismember(ly,list_cov{cco}));
            covar = [covar pheno_num(:,ind_cov)];
            mask_covar =[mask_covar ~isnan(covar)];   
        end
        [y,x]=find(mask_covar == 0);
        ind = ones(size(mask_covar),1);
        ind(unique(y)) = 0;
        model_tmp = [];
        % load model
        for ccx = 1 : length(list_cov)
            model_tmp = [model_tmp niak_normalize_tseries(covar(logical(ind),ccx),'none')];
        end    
        model_covar.x = [ones(sum(ind),1) model_tmp];
        model_covar.y = weights(logical(ind),:);
        for cco = 1:length(list_cov) 
            ind_cov = find(ismember(ly,list_cov{cco}));
            model_covar.c = zeros(1,size(model_covar.x,2))';           
            model_covar.c(cco+1) = 1;
            opt_glm.test = 'ttest';
            opt_glm.flag_beta = true;
            res_covar = niak_glm(model_covar,opt_glm);
            fprintf('%s\n',ly{ind_cov});
            pce(cco,:,ii) = res_covar.pce;
        end
        %plot glm
        hold off
        for pp = 1:nb_clust(tt)
            figure(ii+pp+length(list_ind))
            clf
            plot(model_covar.x(:,2),model_covar.y(:,pp),[list_color{pp} '.'])
            title(sprintf('Breath-hold %s scale %s cluster %i, subtype %i',tr{tt},list_scale{1},list_ind(ii),pp));
        end
    end
end
[fdr,test] = niak_fdr(pce(:),'BH',0.05);
