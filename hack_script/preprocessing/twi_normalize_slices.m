function vol_n = twi_normalize_slices(vol);

%% Normalize the average of even vs odd slices
vol_n = zeros(size(vol));
mask = niak_mask_brain(vol);
mask1 = mask(:,:,1:2:end);
mask2 = mask(:,:,2:2:end);
for num_t = 1:size(vol,4);
    vol1 = vol(:,:,1:2:end,num_t);
    vol2 = vol(:,:,2:2:end,num_t);
    m1 = mean(vol1(mask1));
    m2 = mean(vol2(mask2));
    m = (m1+m2)/2;
    vol1(mask1) = vol1(mask1) - m1 + m;
    vol2(mask2) = vol2(mask2) - m2 + m;
    vol_n(:,:,1:2:end,num_t) = vol1;
    vol_n(:,:,2:2:end,num_t) = vol2;
end
