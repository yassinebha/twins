

function [] = fir_clust_select_plot_test(clust_select,path_folder,fdr_file,partition_nii_file)


%  %  clust_select=[2 6 7]
%  %  path_folder='/home/yassine/twins_study_basc/basc_fir/stability_fir_all_sad_blocs_test3_perc/sci10_scg7_scf7/'   % the hole path folder
%  %  fdr_file='fdr_group_average_sci10_scg7_scf7'                                                                  % write the file_name without .mat extension
%  %  partition_nii_file='brain_partition_threshold_group_sci10_scg7_scf7'                                             % write the file_name without .nii.gz extension



%% plot reordered fir responses regarding to a  specified time point
%  Usage : fir_reorder_plot(time,path_folder,fdr_file,partition_nii_file,sync_order)
%%%%%%%%%% example %%%%%%%%%%%%%%%%%%%%%%
%  %  time=9			% time in sec must be integer
%  %  path_folde=''  		% the hole path folder
%  %  fdr_file=''		% write the file_name without .mat extension
%  %  partition_nii_file=''	% write the file_name without .nii.gz extension
%  %  sync_order= true or false % TRUE is for sychronise plot order with the last executed fir_reorder_plot function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%  read .mat file 
cd (path_folder);
load(strcat(fdr_file,'.mat'));



%  split each clusters to volumes
niak_brick_clusters_to_3d(strcat(partition_nii_file,'.nii.gz'));


%  show brain patition reordered with mricron
A=[test_fir.mean(1,:)];
B=num2str(length(A));

system(['mricron ~/database/white_template.nii.gz -c -0 -o ',partition_nii_file,'_reorder.nii.gz -m  ~/.mricron/multislice/fir_multi_slice.ini -c jet_linear -l 0.02 -h ',B,' -z & '])


%  plot reordered fir.mean matrix
%  name = strcat(fdr_file,'_reorder');
linewidth = 0.8;
background = [0.9 0.9 0.9]; % color of the background for non-significant responses
namesave = strcat('s_', num2str(clust_select) ,'_plots');
opt.ind_fir = [];
opt.flag_diff = false;
opt.flag_legend = false;
opt.flag_std = false;

 hf = figure;
    files_in = strcat(fdr_file,'.mat');
    [x,sizesubclust] =  size(clust_select);
    
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
    print(files_out,'-dsvg','-r600');
    
%      clear test_fir.mean
%      load(strcat(name,'.mat'));
    load(files_in);
    figure,plot(test_fir.mean)
%      files_out = strcat(namesave,'_all_in_one.pdf');
%      print(files_out,'-dpdf','-r600')
    files_out = strcat(namesave,'_all_in_one.svg');
    print(files_out,'-dsvg','-r600');
    
    
%  %      isolated scale networks figure 
    B=length(A)
    for i=clust_select
    if i < 10
    system(['mricron ~/database/white_template.nii.gz -c -0 -o ',partition_nii_file,'_000',num2str(i),'.nii.gz -c jet_linear -l 0.02 -h ',num2str(B),' -z & ']);
    system(['echo ',partition_nii_file,'_000',num2str(i)]);
    else
    system(['mricron ~/database/white_template.nii.gz -c -0 -o ',partition_nii_file,'_00',num2str(i),'.nii.gz -c jet_linear -l 0.02 -h ',num2str(B),' -z & ']);
    system(['echo ',partition_nii_file,'_00',num2str(i)]);
    endif
    end
    system(['echo ',partition_nii_file,'_all']);
endfunction
