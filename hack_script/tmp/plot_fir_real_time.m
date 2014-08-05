

clear
%  load fdr_group_average_sci10_scg7_scf7_reorder.mat;
%  load fdr_group_average_sci10_scg7_scf7.mat;
load fdr_group_average_sci440_scg440_scf339_clust1.mat
 ymaxtmp = max(test_fir.mean) + max(test_fir.std);
 ymintmp = min(test_fir.mean) - max(test_fir.std);
 ymax = max(ymaxtmp);
 ymin = min(ymintmp);
 abs=[1.5*(0:(size(test_fir.mean,1)))];
    xmin=min(1.5*(0:(size(test_fir.mean,1))));
    xmax=max(1.5*(0:(size(test_fir.mean,1))));
    axisvalues = [xmin xmax];
    axisvalues(1,3) = ymin;
    axisvalues(1,4) = ymax;
    
    
    xtick = [xmin:3:xmax];
    ytick = [ymin:ymax];
    ytick = round(10*ytick)/10;
    x=[];
    y=[];
    z=[];
%      e=[];
    l=size(test_fir.mean,2);
    
    
    figure
    hold on;
    axis(axisvalues);
    set(gca,'xtick',xtick);
%      set(gca,'ytick',ytick);
    
    xtemp=[1.5*(0:(size(test_fir.mean,1)-1))];
    
     pause(4);
for i= [(1:(size(test_fir.mean,1)))]
    
    y=[y,test_fir.mean(i,1)];
    z=[z,test_fir.mean(i,2)];
    x=[x,xtemp(1,i)];
%      e=[e,test_fir.std(i,1)];
%      errorbar(x,y,e)
    plot(x,y);
    plot(x,z,'r');
    pause(1.65);
end

hold off

