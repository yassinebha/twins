

% Generate subclusters by decomposing a spacific cluster n from scale K into a higher scale K' ( K < K')  
clear
cluster              = 13;
from_scale           = 17;
at_scale             = 73;
path_folder          = ['/home/yassinebha/Dropbox/twins_study_basc/basc_fir/stability_fir_all_sad_blocs_EXP2_test1/FIR_EXP2_test1_nii/'];


files_in_sub.cluster     = [ path_folder  'sci20_scg16_scf17/brain_partition_consensus_group_sci20_scg16_scf17_0013.nii.gz' ];
files_in_sub.subcluster  = [ path_folder  'sci80_scg72_scf73/brain_partition_consensus_group_sci80_scg72_scf73.nii.gz' ];
files_in_sub.fir         = [ path_folder  'sci80_scg72_scf73/fdr_group_average_sci80_scg72_scf73.mat' ];

files_out_sub.nomatch = '';
files_out_sub.nomatch_fir = '';
files_out_sub.subcluster = {};
files_out_sub.subfir = {};
files_out_sub.matching = '';

opt.perc_overlap = 0.7; 
opt.folder_out =[ path_folder 'subclusters_c' num2str(cluster) 's' num2str(from_scale) '@s_',num2str(at_scale) ];
mkdir(opt.folder_out);
[files_in_sub,files_out_sub,opt]=niak_brick_subclusters(files_in_sub,files_out_sub,opt);



%  load matching file 
cd (opt.folder_out);
load (char(files_out_sub.matching));

for ii = 1:length(matching)
    if isempty(matching{ii})
       continue
    end
    data = load(char(files_out_sub.subfir{ii}));  
    % show brain patition reordered with mricron
    B=size(data.test_fir.mean)(2);
    system(['mricron ~/database/white_template.nii.gz -c -0 -o ' char(files_out_sub.subcluster{ii}) ' -m  ~/.mricron/multislice/default.ini -c jet_linear -l 0.02 -h ' num2str(B) ' -z & '])

   % plot fir
    linewidth = 0.1;
    %background = [0.9 0.9 0.9]; % color of the background for non-significant responses
    opt_fig.flag_legend = false;

    hf = figure;
    files_in_fig = char(files_out_sub.subfir{ii});
    load (files_in_fig);
    [x,sizesubclust] =  size(data.test_fir.mean);
    
    ymaxtmp = max(data.test_fir.mean) + max(data.test_fir.std);
    ymintmp = min(data.test_fir.mean) - max(data.test_fir.std);
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
    absmin=min((0:(size(data.test_fir.mean,1)+1)));
    absmax=max((0:(size(data.test_fir.mean,1)+1)));
    axisvalues = [absmin absmax];
    axisvalues(1,3) = ymin;
    axisvalues(1,4) = ymax;
    
    real_absmin=min(1*(0:(size(data.test_fir.mean,1)-1)));
    real_absmax=max(1*(0:(size(data.test_fir.mean,1)-1)));
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
        opt_fig.ind_fir = m;
        opt_fig.flag_diff = false;
        opt_fig.flag_std = true;
        %opt_fig.background = background;
        opt_fig.linewidth = linewidth;
        opt_fig.axis = axisvalues;
        niak_brick_fig_fir(files_in_fig,'',opt_fig);
        ha = gca;
        set(ha,'xtick',[xtick])
        set(ha,'ytick',[ytick])
        set(ha,'visible','on')

        for mm = 2:sizesubclust
            if mm > m
                subplot(sizesubclust,sizesubclust,mm+(m-1)*sizesubclust);
                opt_fig.flag_diff = true;
                opt_fig.flag_std = true;
                %opt_fig.background = background;
                opt_fig.linewidth = linewidth;
                opt_fig.ind_fir(1,1) = m;
                opt_fig.ind_fir(1,2) = mm;
                files_out = '';
                niak_brick_fig_fir(files_in_fig,files_out,opt_fig);
                ha = gca;
                set(ha,'xtick',xtick)
                set(ha,'ytick',ytick)
                set(ha,'visible','on')
            end
        end
    end
    
    
    % save .pdf and .svg files 
    str=num2str(matching{ii});
    str(~isstrprop(str,'alphanum')) = '_';
    namesave = [ opt.folder_out 'stab_fir_c' num2str(cluster) '_from' num2str(from_scale) '_at' num2str(at_scale) '-' str ];
    files_out = strcat(namesave,'.svg');
    print(files_out,'-dsvg','-r600');
    
    %  split each clusters to volumes
    [files_in_clust,files_out_clust,opt_clust]=niak_brick_clusters_to_3d(char(files_out_sub.subcluster{ii}));

    %   isolated scale networks figure in mricron
   
    for i=1:length(files_out_clust)
        if i < 10
           system(['mricron ~/database/white_template.nii.gz -c -0 -o ' files_out_clust{i} ' -c jet_linear -l 0.02 -h ' num2str(B) ' -z & ']);
           system(['echo ' 'fig_' files_out_sub.subcluster{ii}([135:end-7]) '_000' num2str(i) '_' num2str(matching{ii}(i)) ]);
        else
           system(['mricron ~/database/white_template.nii.gz -c -0 -o ' files_out_clust{i} ' -c jet_linear -l 0.02 -h ' num2str(B) ' -z & ']);
           system(['echo ' 'fig_' files_out_sub.subcluster{ii}([135:end-7]) '_00' num2str(i) '_' num2str(matching{ii}(i)) ]);
        endif
    end
    system(['echo ' 'fig_' files_out_sub.subcluster{ii}([135:end-7]) '_all-' str]);
end