#!/bin/bash

for filename in *_new_opt_zero_rescaled.nii.gz ;
do
    extRemoved=`$FSLDIR/bin/remove_ext ${filename}`
    outputID=${extRemoved%_new_opt_zero_rescaled}
    echo "Creating image for $outputID"
    maskDir='/data/pt_01923/TmpOut/QSM/for_debugging_pipeline/output/Masks/Masks_from_preproc'
    maskImg=$(ls $maskDir/${outputID}*BET_mask.nii.gz)
    echo "Mask image is "$maskImg
    echo "Adding mask from "$maskDir
    `fslmaths $filename -mas $maskImg ${outputID}_masked_QSM.nii.gz`
    echo "Created ${outputID}_masked_QSM.nii.gz"
    `flirt -in ${outputID}_masked_QSM.nii.gz -ref 001_masked_rescaled_QSM.nii.gz -out ${outputID}_QSM_transformed.nii.gz -omat affine_transform_${outputID}.mat`
done