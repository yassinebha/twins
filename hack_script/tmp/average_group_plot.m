
%  clust_select=[20 23]                                                                           % clusters must be beteween braquet
%  sc='sci80_scg72_scf73'
%  path_folder= '/home/yassine/Dropbox/twins_study_basc/basc_fir/stability_fir_all_sad_blocs_test4_perc/dominic_r_sci80_scg72_scf73_nii/' % the hole path folder
%  fdr0_file='glm_average_group0_'                                                 % write the file_name without .mat extension
%  fdr1_file='glm_average_group1_'
%  fdr_comp_file='glm_group0_minus_group1_'
%  scale='sci80_scg72_scf73'
%  partition_nii_file='networks_consensus_sci80_scg72_scf73'                          % write the file_name without .nii.gz extension


clust_select=[20 23]                                                                           % clusters must be beteween braquet
sc='sci80_scg72_scf73'
path_folder= '/home/yassine/Dropbox/twins_study_basc/basc_fir/stability_fir_all_sad_blocs_test4_perc/dominic_r_sci80_scg72_scf73_nii/' % the hole path folder
fdr0_file='glm_average_group0_'                                                 % write the file_name without .mat extension
fdr1_file='glm_average_group1_'
fdr_comp_file='glm_group0_minus_group1_'
scale='sci80_scg72_scf73'
partition_nii_file='networks_consensus_sci80_scg72_scf73'                          % write the file_name without .nii.gz extension
fdr_file='glm_average_group0_sci80_scg72_scf73'

%  read .mat file 
cd ([path_folder 'average_group0']);
load(strcat(fdr_file,'.mat'));


% reorder matrix
test_fir.mean = eff;
test_fir.std = std_eff;
test_fir.fdr = fdr;
test_diff.fdr =fdr;


newfir = test_fir;
newdiff = test_diff;



 % fir
%    tmpfir.pce  = newfir.pce(:,clust_select);
  tmpfir.fdr  = newfir.fdr(:,clust_select);
  tmpfir.mean = newfir.mean(:,clust_select);
  tmpfir.std  = newfir.std(:,clust_select);

 % diff
%    tmpdiff.pce  = newdiff.pce(:,clust_select);
  tmpdiff.fdr  = newdiff.fdr(:,clust_select);
%    tmpdiff.mean = newdiff.mean(:,clust_select);
%    tmpdiff.std  = newdiff.std(:,clust_select);

test_fir = tmpfir;
test_diff = tmpdiff;

% save matrix
save( strcat(fdr_file,'_select_clust.mat'),'test_fir', 'test_diff');

%  reorder volumes
[hdr,vol] = niak_read_vol(strcat(path_folder,partition_nii_file,'.nii.gz'));
vol2 = zeros(size(vol));
for num = 1:length(clust_select)
vol2(vol==clust_select(num)) = num;
end

% save volumes
hdr.file_name = strcat(path_folder,partition_nii_file,'_select_clust.nii.gz');
niak_write_vol(hdr,vol2);



%  %  show brain patition reordered with mricron
A=[test_fir.mean(1,:)];
B=num2str(length(A));
system(['mricron ~/database/white_template.nii.gz -c -0 -o ',partition_nii_file,'_select_clust.nii.gz -m  ~/.mricron/multislice/fir_multi_slice.ini -c jet_linear -l 0.02 -h ',B,' -z & ']);

%  split cluster partition

niak_brick_clusters_to_3d(strcat(partition_nii_file,'_select_clust.nii.gz'));


%  plot reordered fir.mean matrix

name = strcat(fdr_file,'_select_clust');
linewidth = 0.5;
background = [0.9 0.9 0.9]; % color of the background for non-significant responses
namesave = strcat('_select_plots');
opt.ind_fir = [];
opt.flag_diff = false;
opt.flag_legend = false;
opt.flag_std = false;

 hf = figure;
    files_in = strcat(name,'.mat');
    load(strcat(name,'.mat'));
    [x,sizesubclust] =  size(test_fir.mean);
    
    ymaxtmp = max(test_fir.mean) + max(test_fir.std); % added the 1.5* (avant max) because of the '*' indicating significance
    ymintmp = min(test_fir.mean) - max(test_fir.std);
    ymaxtmp2 = max(ymaxtmp);
    ymintmp2 = min(ymintmp);
%      if ymaxtmp2 < 0
%          ymax = 0;
%      else 
        ymax = ymaxtmp2 + 0.001;
%      end
%      if ymintmp2 > 0
%          ymin = 0;
%      else 
        ymin = ymintmp2 - 0.001;
%      end
    absmin=min((0:(size(test_fir.mean,1)+1)));
    absmax=max((0:(size(test_fir.mean,1)+1)));
    axisvalues = [absmin absmax];
    axisvalues(1,3) = ymin;
    axisvalues(1,4) = ymax;
    
    real_absmin=min(2.65*(0:(size(test_fir.mean,1)-1)));
    real_absmax=max(2.65*(0:(size(test_fir.mean,1)-1)));
    xtick = [real_absmin:real_absmax/10: real_absmax];
    ytick = [ymin:ymax/3:ymax];
%      ytick = round(10*ytick)/10;

    
    subplot(sizesubclust,sizesubclust,1+(sizesubclust-1)*sizesubclust);
    ha = gca;
    axis(axisvalues)
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
        set(ha,'xtick',[])
        set(ha,'ytick',[])
        set(ha,'visible','on')

        for mm = 2:sizesubclust
            if mm > m
                subplot(sizesubclust,sizesubclust,mm+(m-1)*sizesubclust);
                opt.flag_diff = true;
                opt.flag_std = false;
                opt.background = background;
                opt.linewidth = linewidth;
                opt.ind_fir(1,1) = m;
                opt.ind_fir(1,2) = mm;
                files_out = '';
                niak_brick_fig_fir_ts(files_in,files_out,opt);
                ha = gca;
                set(ha,'xtick',[])
                set(ha,'ytick',[])
                set(ha,'visible','on')
            end
        end
    end
    
    
    %save .pdf and .svg files 
    
%      files_out = strcat(namesave,'.pdf');
%      print(files_out,'-dpdf','-r600')
    files_out = strcat(namesave,'.svg');
    print(files_out,'-dsvg','-r600')
    
%      clear test_fir.mean
%      load(strcat(name,'.mat'));
    load(files_in);
    figure,plot(test_fir.mean)
%      files_out = strcat(namesave,'_all_in_one.pdf');
%      print(files_out,'-dpdf','-r600')
    files_out = strcat(namesave,'_all_in_one.svg');
    print(files_out,'-dsvg','-r600')
    
    
%  %      isolated scale networks figure 
      
      B=sizesubclust
    for i=1:B
       if i < 10
          system(['mricron ~/database/white_template.nii.gz -c -0 -o ',partition_nii_file,'_select_clust_000',num2str(i),'.nii.gz -c jet_linear -l 0.02 -h ',num2str(B),' -z & ']);
          system(['echo ',partition_nii_file,'_select_clust_000',num2str(i)]);
       else
          system(['mricron ~/database/white_template.nii.gz -c -0 -o ',partition_nii_file,'_select_clust_00',num2str(i),'.nii.gz -c jet_linear -l 0.02 -h ',num2str(B),' -z & ']);
          system(['echo ',partition_nii_file,'_select_clust_00',num2str(i)]);
       endif
    end
    system(['echo ',partition_nii_file,'_select_clust_all']);
    
endfunction