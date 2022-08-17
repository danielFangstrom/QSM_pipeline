#!/bin/bash
for filename in *_optimized_QSM.nii.gz ;
do
    #Get the min and max values, and use the highest absolute value
    min=`fslstats $filename -R | awk '{ print $1 }'`
    max=`fslstats $filename -R | awk '{ print $2 }'`
    std=`fslstats $filename -S | awk '{ print $1 }'`
    min=${min#-}
    minMax=($min $max)
    echo ${minMax[@]}
    IFS=$'\n'
    minMax=($(sort <<<"${minMax[*]}"))
    echo ${minMax[-1]}
    shiftValue=`echo ${minMax[-1]}+$std | bc -l`
    echo "Shift value: "$shiftValue
    newMax=`echo $shiftValue+${minMax[-1]} | bc -l`
    echo "New max: "$newMax
    multiplicationValue=`echo "2500 / $newMax" | bc -l`
    echo "Multiplication value: "$multiplicationValue
    #Use the file as input to fslmaths and multiple, add, and threshold the resulting image
    extRemoved=`$FSLDIR/bin/remove_ext ${filename}`
    outputID=${extRemoved%_optimized_QSM}
    echo "Creating images for $outputID"
    maskDir='/data/pt_01923/TmpOut/QSM/for_debugging_pipeline/output/Masks/Masks_from_preproc/'
    maskImg="${maskDir}${outputID}_BET_mask.nii.gz"
    echo "Mask image is "$maskImg
    #Add a value (currently 10) to make sure all qsm values are above zero before doing the rest
    `fslmaths $filename -add $shiftValue ${outputID}_above_zero_temp.nii.gz`
    `fslmaths ${outputID}_above_zero_temp.nii.gz -mul $multiplicationValue ${outputID}_multiplied_temp.nii.gz`
    `fslmaths ${outputID}_multiplied_temp.nii.gz -add 1500 ${outputID}_added_temp.nii.gz`
    echo "Re-adding mask from $maskDir before finishing"
    `fslmaths ${outputID}_added_temp.nii.gz -mas $maskImg ${outputID}_opt_zero_rescaled.nii.gz`
    echo "Done. Removing temporary files"
    `rm *_temp.nii.gz`
    echo "Temporary files removed."
    echo "Saving values to text file for the reversal."
    echo $multiplicationValue " " $shiftValue > ${outputID}_mult_shift_values.txt
    echo "Done, values saved to "${outputID}_mult_shift_values.txt
done