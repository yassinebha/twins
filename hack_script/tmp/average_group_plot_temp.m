%  clear
%  clust_select=[73]                                                                           % clusters must be beteween braquet
%  sc='sci140_scg140_scf147'
%  path_folder= '/home/yassinebha/Dropbox/twins_study_basc/basc_fir/stability_fir_all_sad_blocs_test4_perc/' % the hole path folder
%  group_0='average_group0'                                                 % write the file_name without .mat extension
%  group_1='average_group1'
%  comp_group='group0_minus_group1'
%  fdr_file='glm_'
%  partition_nii_file= 'networks_consensus_sci80_scg72_scf73'

clear 
clust_select=[1]
mask = [124] % the same as clust_select but different for roi analysis clusters
sc='sci140_scg140_scf151'
contrast = 'dominic_dep'
path_folder= '/home/yassinebha/Dropbox/twins_study_basc/basc_fir/stability_fir_all_sad_blocs_EXP2_test1/glm_fir_roi_restrict/' % the hole path folder
group_0='average_group0_restric'                                                 % write the file_name without .mat extension
group_1='average_group1'
comp_group='group0_vs_group1_restric'
fdr_file='glm_'
partition_nii_file= 'networks_sci140_scg140_scf151'


cd ([path_folder sc filesep ]);
%  il faut loader le .mat du groupe0 
cd (group_0);
load([fdr_file group_0 '_' sc '.mat']);

test_fir.mean = eff(:,clust_select);
test_fir.std = std_eff(:,clust_select);
test_fir.fdr = fdr(:,clust_select);

cd ..
%  il faut allare loader le .mat du groupe 1
cd (group_1);
load([fdr_file group_1 '_' sc '.mat']);
test_fir.mean = [test_fir.mean eff(:,clust_select)];
test_fir.std = [test_fir.std std_eff(:,clust_select)];
test_fir.fdr = [test_fir.fdr fdr(:,clust_select)];

cd ..
%  il faut aller loader le .mat du groupe 0 vs 1
cd (comp_group);
load([fdr_file comp_group '_' sc '.mat']);
test_diff.mean = eff(:,clust_select);
test_diff.std  = std_eff(:,clust_select);
test_diff.fdr  = fdr(:,clust_select);
%  dupliquer test_diff pour avoir une matrice de meme taille que test_fir
test_diff.mean = [test_diff.mean test_diff.mean];
test_diff.std  = [test_diff.std test_diff.std];
test_diff.fdr  = [test_diff.fdr test_diff.fdr];

%mettre le mean et le std à l'echelle
%  test_diff.std=(test_diff.std)*10e2
test_fir.std=(test_fir.std);
test_fir.mean=(test_fir.mean);

% save matrix
num_clust=num2str(clust_select);
save_glm=strcat(fdr_file, 'group0_vs_group1_c', num_clust, '.mat');
save (save_glm , 'test_fir' , 'test_diff');
%clust_select= [1 2];

%  reorder volumes
cd ..
[hdr,vol] = niak_read_vol([partition_nii_file '.nii.gz']);
vol2 = zeros(size(vol));
for num = 1:length(mask)
vol2(vol==mask(num)) = num;
end

% save volumes
hdr.file_name = [partition_nii_file '_select_clust' num2str(clust_select) '.nii.gz'];
niak_write_vol(hdr,vol2);

%niak_brick_clusters_to_3d(strcat(partition_nii_file,'.nii.gz'));

%  %  show brain networks

system(['mricron ~/database/white_template.nii.gz -c -0 -o ' hdr.file_name ' -m  ~/.mricron/multislice/default.ini -c jet_linear -l 1 -h 2 -z& ']);



%  plot fir
cd (comp_group);
linewidth = 0.2;
background = [0.9 0.9 0.9]; % color of the background for non-significant responses
opt.flag_legend = false;

 hf = figure;
    files_in = save_glm;
    load (save_glm);
    [x,sizesubclust] =  size(test_fir.mean);
    
    ymaxtmp = max(test_fir.mean) + max(test_fir.std); % added the 1.5* (avant max) because of the '*' indicating significance
    ymintmp = min(test_fir.mean) - max(test_fir.std);
    ymaxtmp2 = max(ymaxtmp);
    ymintmp2 = min(ymintmp);
    if ymaxtmp2 < 0
        ymax = 0;
    else 
        ymax = ymaxtmp2 + 0.001;
    end
    if ymintmp2 > 0
        ymin = 0;
    else 
        ymin = ymintmp2 - 0.001;
    end
    absmin=min((0:(size(test_fir.mean,1)+1)));
    absmax=max((0:(size(test_fir.mean,1)+1)));
    axisvalues = [absmin absmax];
    axisvalues(1,3) = ymin;
    axisvalues(1,4) = ymax;
    
    real_absmin=min(1*(0:(size(test_fir.mean,1)-1)));
    real_absmax=max(1*(0:(size(test_fir.mean,1)-1)));
    xtick = [real_absmin 11 16 29 34 47 52 65 70 83 ];
    ytick = [ymin ymin/2 0 ymax/4 ymax/2  ymax*3/4 ymax];
    ytick = round(100*ytick)/100;

    
    subplot(sizesubclust,sizesubclust,1+(sizesubclust-1)*sizesubclust);
    ha = gca;
    axis(axisvalues);
    set(ha,'xtick',xtick)
    set(ha,'ytick',ytick)
    set(ha,'linewidth',linewidth);
    for m = 1:sizesubclust
        subplot(sizesubclust,sizesubclust,m+(m-1)*sizesubclust);
        opt.ind_fir = m;
        opt.flag_diff = false;
        opt.flag_std = true;
        opt.background = background;
        opt.linewidth = linewidth;
        opt.axis = axisvalues;
        niak_brick_fig_fir_ts(files_in,'',opt);
        ha = gca;
        set(ha,'xtick',[xtick])
        set(ha,'ytick',[ytick])
        set(ha,'visible','on')

        for mm = 2:sizesubclust
            if mm > m
                subplot(sizesubclust,sizesubclust,mm+(m-1)*sizesubclust);
                opt.flag_diff = true;
                opt.flag_std = true;
                opt.background = background;
                opt.linewidth = linewidth;
                opt.ind_fir(1,1) = m;
                opt.ind_fir(1,2) = mm;
                files_out = '';
                niak_brick_fig_fir_ts(files_in,files_out,opt);
                ha = gca;
                set(ha,'xtick',xtick)
                set(ha,'ytick',ytick)
                set(ha,'visible','on')
            end
        end
    end
    
    
    %save .pdf and .svg files 
    namesave = strcat('plot_', comp_group, '_c',num_clust );
    files_out = strcat(namesave,'.svg');
    print(files_out,'-dsvg','-r600');
    
%      clear test_fir.mean
%      load(strcat(name,'.mat'));
  
%     subplot(2,2,2)
%     errorbar(test_fir.mean(:,1),test_fir.std(:,1),'b'); hold on, errorbar(test_fir.mean(:,2),test_fir.std(:,2),'r');
%  %      files_out = strcat(namesave,'_all_in_one.pdf');
%  %      print(files_out,'-dpdf','-r600')
%      files_out = strcat(namesave,'_all.svg');
%      print(files_out,'-dsvg','-r600')
    
endfunction