
clear
%on Peuplier
path_glm = '/media/database3/twins_study/stability_fir_all_sad_blocs_EXP2_test1/glm_fir_neut_ref/sci40_scg36_scf36/dominic_dep';
path_fmri = '/media/database3/twins_study/fmri_preprocess_EXP2_test1/fmri';
%on lemur ultra
path_glm = '/home/yassinebha/Dropbox/twins_study_basc/basc_fir/stability_fir_all_sad_blocs_EXP2_test1/glm_fir_neut_ref/sci40_scg36_scf36/dominic_dep';

%% Load the GLM
data = load([path_glm '/glm_dominic_dep_sci40_scg36_scf36.mat']);
x = data.model_group.x;
y = data.model_group.y;
c = data.model_group.c;
lx = data.model_group.labels_x;
ly = data.model_group.labels_y;

% Try a regression on residuals
opt_glm_gr.test  = 'ttest' ;
opt_glm_gr.flag_beta = true ; 
opt_glm_gr.flag_residuals = true ;
y_x_c.x = data.model_group.x;
y_x_c.y = data.model_group.y;
y_x_c.c = data.model_group.c; 
[results, opt_glm_gr] = niak_glm(y_x_c , opt_glm_gr);
%y_x_c.y = results.e.^2;
%[results, opt_glm_gr] = niak_glm(y_x_c , opt_glm_gr);
nt = size(data.ttest,1);
nn = size(data.ttest,2);
beta    =  results.beta; 
e       = results.e ;
std_e   = results.std_e ;
ttest   = results.ttest ;
pce     = results.pce ; 
eff     =  results.eff ;
std_eff =  results.std_eff ; 
ttest(isnan(pce)) = 0;
pce(isnan(pce)) = 1;
ttest = reshape (ttest,[nt nn]);
eff = reshape (eff,[nt nn]);
std_eff   = reshape (std_eff,[nt nn]);
[fdr,test_q] = niak_fdr(pce,'LSL',0.05);  
nb_discovery = sum(test_q,1);
perc_discovery = nb_discovery/size(fdr,1);
% Plot the regression in network 12, time point 33
figure
y_x_c.y = reshape(y_x_c.y,[length(lx) size(data.ttest)]);
vc = squeeze(y_x_c.y(:,33,12));
plot(x(:,2)+randn(size(x(:,2))),vc,'b.')
hold on
vc_pred = x*beta;
vc_pred = reshape(vc_pred,[length(lx) size(ttest)]);
plot(x(:,2),squeeze(vc_pred(:,33,12)),'r')

%% Load the scrubbing masks
for xx = 1:length(lx)
    subject = lx{xx};
    file_extra = [path_fmri '/fmri_' subject '_session1_run1_extra.mat'];
    extra = load(file_extra);
    if xx == 1
        mask = zeros(length(lx),size(data.ttest,1));
    end
    mask(xx,:) = extra.mask_suppressed(end-size(data.ttest,1)+1:end);
end

%% Check that the masks are reasonable
y = reshape(y,[length(lx) size(data.ttest)]);
plot(squeeze(y(2,:,1)),'bo-');
hold on
plot(double(mask(2,:)'),'r*')

%% Check the stats for network 12: the ACC
[b1,e1,std_e1,ttest1,pce1] = niak_lse(y(:,:,12),x,c);
max(abs(ttest1(:))) % 3.8406r0 = squeeze(mean(y(mask_0,:,12),1));
x2 = [x (x(:,2)-mean(x(:,2))).^2];
[b2,e2,std_e2,ttest2,pce2] = niak_lse(y(:,:,12),x2,[0 0 1]');
max(abs(ttest2(:))) % ans =  1.7913
[b3,e3,std_e3,ttest3,pce3] = niak_lse(y(:,:,12),x2,[0 1 0]');
max(abs(ttest3(:))) % ans =  3.8677

%% Plot the regression in network 12, time point 33
figure
y = reshape(y,[length(lx) size(data.ttest)]);
vc = squeeze(y(:,33,12));
plot(x(:,2),vc,'b.')
hold on
vc_pred = x*data.beta;
vc_pred = reshape(vc_pred,[length(lx) size(data.ttest)]);
plot(x(:,2),squeeze(vc_pred(:,33,12)),'r')

files_out = strcat(path_glm, 'plot_s36_c12_t12_glm_dom.svg');
print(files_out,'-dsvg','-r600');
%% Plot the regression in network 21, time point 33
figure
y = reshape(y,[length(lx) size(data.ttest)]);
vc = squeeze(y(:,33,21));
plot(x(:,2),vc,'.')
hold on
vc_pred = x*data.beta;
vc_pred = reshape(vc_pred,[length(lx) size(data.ttesty = reshape(y,[length(lx) size(data.ttest)]);)]);
plot(x(:,2),squeeze(vc_pred(:,33,21)),'r')

%% Plot the respon ses for the two groups - netwok 19 visual
figure
mask_0 = x(:,2)<=6;
mask_1 = x(:,2)>=11;
r0 = squeeze(mean(y(mask_0,:,19),1));
std_r0 = squeeze(std(y(mask_0,:,19),[],1))/sqrt(sum(mask_0));
errorbar(r0,std_r0);

hold on
r1 = squeeze(mean(y(mask_1,:,19),1));y = reshape(y,[length(lx) size(data.ttest)]);
std_r1 = squeeze(std(y(mask_1,:,19),[],1))/sqrt(sum(mask_1));
errorbar(r1,std_r1,'r');


%% Plot the responses for the two groups - netwok 21 prefrontal
figure
mask_0 = x(:,2)<=6;
mask_1 = x(:,2)>=11;
r0 = squeeze(mean(y(mask_0,:,21),1));
std_r0 = squeeze(std(y(mask_0,:,21),[],1))/sqrt(sum(mask_0));
errorbar(r0,std_r0);

hold on
r1 = squeeze(mean(y(mask_1,:,21),1));
std_r1 = squeeze(std(y(mask_1,:,21),[],1))/sqrt(sum(mask_1));
errorbar(r1,std_r1,'r');


%% Plot the responses for the two groups - network 12 ACC
figure
mask_0 = x(:,2)<=6;
mask_1 = x(:,2)>=11;
r0 = squeeze(mean(y(mask_0,:,12),1));
std_r0 = squeeze(std(y(mask_0,:,12),[],1))/sqrt(sum(mask_0));
errorbar(r0,std_r0);y = reshape(y,[length(lx) size(data.ttest)]);

hold on
r1 = squeeze(mean(y(mask_1,:,12),1));
std_r1 = squeeze(std(y(mask_1,:,12),[],1))/sqrt(sum(mask_1));
errorbar(r1,std_r1,'r');

[ttest,pce,eff,std_eff,df] = niak_ttest(squeeze(y(mask_0,:,12)),squeeze(y(mask_1,:,12)),true);
[val,ind] = max(abs(ttest)); %val =  3.7210, ind =  33

%% Now check the impact of scrubbing
mask_t = max(mask(:,[43:45]),[],2);
[ttest,pce,eff,std_eff,df] = niak_ttest(squeeze(y(mask_0&~mask_t,:,12)),squeeze(y(mask_1&~mask_t,:,12)),true);
ttest(33) % ans = -3.2464
ttest(44) % ans = -3.2464

%% Plot the responses for the two groups on scale 12, excluding subjects with interpolation
figure
mask_0 = x(:,2)<6;
mask_1 = x(:,2)>11;
r0 = squeeze(mean(y(mask_0&~mask_t,:,12),1));
std_r0 = squeeze(std(y(mask_0&~mask_t,:,12),[],1))/sqrt(sum(mask_0&~mask_t));
errorbar(r0,std_r0);

hold on
r1 = squeeze(mean(y(mask_1&~mask_t,:,12),1));
std_r1 = squeeze(std(y(mask_1&~mask_t,:,12),[],1))/sqrt(sum(mask_1&~mask_t));
errorbar(r1,std_r1,'r');

%% What would we get with a glm analysis and the two groups defined above ???
%% Let's find out ...
glm = data.model_group;
mask_0 = x(:,2)<=6;
mask_1 = x(:,2)>=11;
mask_01 = mask_0|mask_1;
glm.x = glm.x(mask_01,:);
glm.y = glm.y(mask_01,:);
glm.labels_x = glm.labels_x(mask_01,:);
glm.x(:,2) = mask_1(mask_01);
opt_glm.test = 'ttest';
opt_glm.flag_beta = true;
opt_glm.flag_residuals = true;
results = niak_glm(glm,opt_glm);
glm.y = (results.e);
results = niak_glm(glm,opt_glm);
nt = size(data.ttest,1);
nn = size(data.ttest,2);
beta    =  results.beta; 
std_e   = results.std_e ;
ttest   = results.ttest ;
pce     = results.pce ; 
eff     =  results.eff ;
std_eff =  results.std_eff ; 
ttest(isnan(pce)) = 0;
pce(isnan(pce)) = 1;
ttest = reshape (ttest,[nt nn]);
eff = reshape (eff,[nt nn]);
std_eff   = reshape (std_eff,[nt nn]);
q = 0.05;
[fdr,test_q] = niak_fdr(pce,'LSL',0.1);    
nb_discovery = sum(test_q,1);
perc_discovery = nb_discovery/size(fdr,1);
% bother ... no discovery

%% Plot the responses for the two groups on scale 12, excluding subjects with interpolation
figure
y = reshape(glm.y,[sum(mask_01) nt nn]);
plot(randn(sum(mask_0),1),y(mask_0(mask_01),33,12),'*')
hold on
plot(randn(sum(mask_1),1)+10,y(mask_1(mask_01),33,12),'r*')
r0 = squeeze(mean(y(mask_0(mask_01),:,12),1));
std_r0 = squeeze(std(y(mask_0(mask_01),:,12),[],1))/sqrt(sum(mask_0(mask_01)));
errorbar(r0,std_r0);

hold on
r1 = squeeze(mean(y(mask_1(mask_01),:,12),1));
std_r1 = squeeze(std(y(mask_1(mask_01),:,12),[],1))/sqrt(sum(mask_1(mask_01)));
errorbar(r1,std_r1,'r');
