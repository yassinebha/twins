function [] = yass_conv_mnc2nii(glm_fir)


niak_brick_mnc2nii('.','')
if glm_fir='glm'
delete */*.mnc.gz
else
delete */*.mnc.gz
delete */*/*.mnc.gz
end

endfunction
