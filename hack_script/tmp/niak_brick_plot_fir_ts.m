
clear
close all
name = 'fdr_group_average_sci80_scg72_scf73_clust1';     
linewidth = 0.5;
background = [0.9 0.9 0.9]; % color of the background for non-significant responses
namesave = 'c7s18@s73_plots';
opt.ind_fir = [];
opt.flag_diff = false;
opt.flag_legend = false;
opt.flag_std = false;
%opt.color = [0/255 30/255 111/255; 0 42/255 255/255; 0 233/255 170/255; 79/255 255/255 79/255; 255/255 159/255 0/255; 255/255 13/255 0/255; 185/255 0/255 0/255 ]; %s7_reorder_plots
%opt.color = [0/255 0/255 249/255; 0 255/255 53/255; 255/255 127/255 0/255; 169/255 0/255 0/255]; %c4s7@s38
%opt.color = [0/255 0/255 185/255; 0 191/255 170/255; 127/255 255/255 63/255; 255/255 68/255 0/255; 192/255 0 0]; %c3s7@s38
%opt.color = [0/255 0/255 185/255; 0 191/255 170/255; 127/255 255/255 63/255; 255/255 68/255 0/255; 192/255 0/255 0/255]; %c7s18@s73
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    hf = figure;
    files_in = strcat(name,'.mat');
    load(strcat(name,'.mat'));
    [x,sizesubclust] =  size(test_fir.mean);                 
    
    ymaxtmp = max(test_fir.mean) + max(test_fir.std); % added the 1.5* (avant max) because of the '*' indicating significance
    ymintmp = min(test_fir.mean) - max(test_fir.std);
    ymaxtmp2 = max(ymaxtmp);
    ymintmp2 = min(ymintmp);
    if ymaxtmp2 < 0
        ymax = 0;
    else 
        ymax = ymaxtmp2 + 0.1;
    end
    if ymintmp2 > 0
        ymin = 0;
    else 
        ymin = ymintmp2 - 0.1;
    end
    axisvalues = [1 31];
    axisvalues(1,3) = ymin;
    axisvalues(1,4) = ymax;
    
    xtick = [11 21 31];
    ytick = [-0.9:0.3:0.9];
    ytick = round(10*ytick)/10;

    
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
        set(ha,'visible','off')

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
                set(ha,'visible','off')
            end
        end
    end
    files_out = strcat(namesave,'.pdf');
    print(files_out,'-dpdf','-r600')

    
    