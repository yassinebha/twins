function [] = twi_mosaic2vol(path_read,func,anat);

%% Generate the list of files
path_read = niak_full_path(path_read);
list_files = dir([path_read '*FMRI_JUMEAUX_1RUN*']);
list_files = {list_files(:).name};
if isempty(list_files)
    error('I could not find the functional images !')
end
%% Unpack the mosaic
vol = zeros(64,64,28,length(list_files));
for num_t = 1:size(vol,4);
    num_t
    [hdr,mosaic] = niak_read_vol([path_read list_files{num_t}]);
    vol(:,:,:,num_t) = sub_mosaic2vol(mosaic);
end

%% Normalize slices
%vol = twi_normalize_slices(vol);

%% Write functional 
hdr = hdr(1);
hdr.file_name = func;
hdr.info.tr = 3;
hdr.info.mat(:,1) = -8*hdr.info.mat(:,1);
hdr.info.mat(:,2) = -8*hdr.info.mat(:,2);
hdr.info.mat(:,3) =   -hdr.info.mat(:,3);
niak_write_vol(hdr,vol);

%% Copy anat
anat_r = dir([path_read '*SAGITTAL_FLASH_3D*']);
if isempty(anat_r)
    anat_r = dir([path_read '*MPRAGE*']);
    if isempty(anat_r)
        error('I could not find the anatomical image !')
    end
end

anat_r = [path_read anat_r(1).name];
system(['cp ' anat_r ' ' anat(1:(end-3))]);
system(['gzip ' anat(1:(end-3))]);

function vol = sub_mosaic2vol(mosaic);
siz = 512;
slic = 64;

vol = zeros(64,64,28);
num_s = 0;
for ny = 1:4
    if ny == 4
        maxx = 4;
    else
        maxx = 8;
    end
    for nx = 1:maxx
        num_s = num_s+1;
        vol(:,:,num_s) = mosaic( (1+((nx-1)*64)):(nx*64) , (1+((ny-1)*64)):(ny*64));
    end
end

vol2 = vol;
for num_s = 1:14
    vol(:,:,2*num_s-1) = vol2(:,:,num_s);
    vol(:,:,2*num_s) = vol2(:,:,num_s+14);
end
