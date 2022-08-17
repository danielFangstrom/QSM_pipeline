
After the QSM files have been created, there are a few things that are needed still. The QSM images need to be registered to a common space. If the QSM imaging is part of a fMRI study, the SPM preprocessed brain images are good to use for masking and registration purposes. A template can be created for all QSM images (if feasible - the GREADT QSM data is not easy to use for this purpose) but it is not necessary.
The rescaling script was originally made for this purpose, to rescale the QSM images to values that closer resembles T1 values, which is expected by ANTS.

In the workflow for the GREADT1 QSM analysis, the QSM images are rescaled and then registered to MNI space. The resulting affine transform is then used for the actual registration (the other resulting files can be deleted since they are not particularly useful). This affine transform is used with FLIRT (FSL suite) to register the QSM images to the space of the 1st subject's anatomical scan ('Brain' image from the preprocessing pipeline).
`flirt -in 'QSM.nii.gz' -ref 'sub-001_ses-1_Brain.nii' -out 'output.nii.gz' -init affine_transform.mat`

Some images have artefacts that severly affect the FLIRT registration. Using 'applyxfm' can help producing better registrations:
`flirt -in 'QSM.nii.gz' -ref 'sub-001_ses-1_Brain.nii' -out 'output.nii.gz' -init affine_transform.mat-applyxfm`

There needs to be at least a T1-image template, created by registering all the anatomical scans to the same space (1st subject) and adding those as inputs to ANTS. The resulting image can be used to draw/pick area labels for use in the upcoming group analysis. For QSM, a refernce region is needed (crus cerebri was used in the GREADT1 QSM study), as well as the regions of interest. ITKsnap was used in the GREADT1 QSM study.

Using the reference region area label, contrast-to-noise ratio images can be created. First, the average value of the reference area is calculated and saved.
`fslmeants -i 'registered_QSM_image.nii' -m 'crus_cerebri_average_mask.nii.gz' -o 'CCR_avg.txt'

This value is then used in the 'create_QSM_CNR_files.sh' to create contrast-to-noise ratio images. These image can then be smoothed (using SPM, for example). A 1mm smoothing kernel was used in the GREADT1 QSM study.

For the group analysis, the regions of interest-labels that were created before can be used in SPM to select the ROIs of the study.
