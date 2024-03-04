root_dir='/data/pt_01923/TmpOut/QSM/QSM_pipeline/group_analysis/Deaveraged_images'
maskRootDir='/data/pt_01923/TmpOut/QSM/QSM_pipeline/QSM_segmentation/CAT12_segmentations'
outDir='/data/pt_01923/TmpOut/QSM/QSM_pipeline/QSM_segmentation/'

fsl_dir='/afs/cbs.mpg.de/software/fsl/currentversion.ubuntu-bionic-amd64/ubuntu-bionic-amd64/bin'


subject_list=(001 002 003 004 006 007 008 011 012 013 014 015 016 017 018 019 020 021 022 023 025 026 027 028 029 \
030 031 032 033 034 036 038 039 040 042 043 044 045 046 048 049 050 101 103 104 105 106 107 111 112 113 115 116 117 \
118 119 120 121 122 124 127 130 132 133 135 136 137 138 139 140 141 142 143 144 145 146 148 149)

length_subject_list=${#subject_list[@]}


for (( j=0; j<${length_subject_list}; j++ )) ;
do
    for segmentation in 1 2 ;
    do
        outputID=${subject_list[$j]}
        # Find the file corresponding to the current subject and the current 
        # type of segmentation (1 is gray matter, and 2 is white matter)
        QSM_img=$(ls $root_dir/$outputID*$segmentation*QSM.nii)
        echo "Current QSM file is "$QSM_img
        # Remove the file extension to get the string we will use for the subject
        extRemoved=`$fsl_dir/remove_ext ${QSM_img}`
        outputID=${extRemoved%_${subject_list[$j]}}
    
    
        echo "Creating images for $outputID"
        # Make sure the segmentation image does not contain NaNs (introduced 
        # by CAT12)
        no_nan_Img="${outputID}_QSM_no_nans.nii"
        `fslmaths $QSM_img -nan $no_nan_Img`
        echo "Modified image is $no_nan_Img"    
        # Get the average value (image mean)
        refValue=`fslmeants -i $no_nan_Img  | awk '{ print $1 }'`
        echo "reference value is $refValue"
        #Subtract the reference value from eaxh voxel in the brain
        `fslmaths $no_nan_Img -sub $refValue ${outputID}_deaveraged.nii.gz`
    
        echo "Done."
    done
    
done