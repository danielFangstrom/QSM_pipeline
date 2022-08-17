#!/bin/bash
for filename in *_to_001_flirt_QSM_transformed_T1_space.nii ;
do
    #Use the file as input to fslmaths and multiple, add, and threshold the resulting image
    extRemoved=`$FSLDIR/bin/remove_ext ${filename}`
    outputID=${extRemoved%_to_001_flirt_QSM_transformed_T1_space}
    echo "Creating images for $outputID"
    #Get the average value (previously calculated) of the reference area
    refValue=`cat ${outputID}_CCR_avg.txt | awk '{ print $1 }'`
    #Subtract the reference value from eaxh voxel in the brain
    `fslmaths $filename -sub $refValue ${outputID}_subtracted_by_reference_value_temp.nii.gz`
    `fslmaths ${outputID}_subtracted_by_reference_value_temp.nii.gz -div $refValue ${outputID}_CNR.nii.gz`
    echo "Done. Removing temporary files"
    `rm *_temp.nii.gz`
    echo "Temporary files removed."
done