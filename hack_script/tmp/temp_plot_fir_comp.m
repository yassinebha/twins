
cd /home/yassinebha/Dropbox/twins_study_basc/basc_fir/stability_fir_all_sad_blocs_EXP2_test1/glm_fir_neut_ref_nii/sci40_scg36_scf36
cd average_group0
load glm_average_group0_sci40_scg36_scf36.mat;
eff0=eff;
std_eff0=std_eff;

cd ..
cd average_group1
load glm_average_group1_sci40_scg36_scf36.mat;
eff1=eff;
std_eff1=std_eff;

cd ..
cd group0_minus_group1
load glm_group0_minus_group1_sci40_scg36_scf36.mat;
effd=eff;
std_effd=std_eff;

num = 12;%cingulaire anterieur droite plus que gauche
%num= 11; %thalamus L&R
%num= 66; % temporal inf and mid only right
%num= 44; % lingual L&R
%num= 79; % lingual L&R
%num= 12; % cuneus L&R (difference marqué)
%num= 34; % calcarine L&R (difference marqué)

figure, errorbar(eff0(:,num),std_eff0(:,num),'b'); hold on, errorbar(eff1(:,num),std_eff1(:,num),'r'); errorbar(effd(:,num),std_effd(:,num),'g');

