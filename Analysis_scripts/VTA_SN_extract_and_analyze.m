subject_list = [1:4, 6:8, 11:23, 25:34, 36, 38:40, 42:46, 48:50, 101, 103:107, ...
        111:113, 115:117, 118:122, 124, 127, 130, 132:133, 135:146, 148, 149];
dir_smoothed_CNR_QSM = '/data/pt_01923/TmpOut/QSM/QSM_pipeline/group_analysis/Deaveraged_images/Current_7th_bspline_deformation/';
%cd( dir_smoothed_CNR_QSM );
mask_dir = '/data/pt_01923/TmpOut/QSM/QSM_pipeline/group_analysis/Reinforcement_learning_atlas/created_atlas_masks/';
SN_mask_name = 'eroded_modified_SN_manual_40.nii.gz';
VTA_mask_name = 'modified_VTA_25_manual.nii';

mask_SN_vol = niftiread( strcat( mask_dir, SN_mask_name ) );
coords_SN_mask = find( mask_SN_vol);

mask_VTA_vol = niftiread( strcat( mask_dir, VTA_mask_name ) );
coords_VTA_mask = find( mask_VTA_vol);

% All VTA masked data goes into the 1st column and all SN masked data goes
% into the 2nd column.
data_all_subjects = cell( length( subject_list), 4);

for isub = 1:length( subject_list )
    subject = subject_list( isub );
%     if subject == 1
%         file_name_QSM = strcat( dir_registered_QSM_files, '001_QSM_masked.nii' );
%     else
%         file_name_QSM = strcat( dir_registered_QSM_files, sprintf( '%03d', subject ),  '_to_001_flirt_QSM_transformed_T1_space.nii' );
%     end
    file_name_QSM = strcat( dir_smoothed_CNR_QSM, '1mm_smoothed_', sprintf( '%03d', subject ),  '_deaveraged.nii' );
    QSM_vol = niftiread( file_name_QSM );
    SN_masked_QSM = QSM_vol( coords_SN_mask);
    VTA_masked_QSM = QSM_vol( coords_VTA_mask);

    data_all_subjects{ isub, 1} = VTA_masked_QSM;
    data_all_subjects{ isub, 2} = SN_masked_QSM;
    data_all_subjects{ isub, 3} = mean( VTA_masked_QSM );
    data_all_subjects{ isub, 4} = mean( SN_masked_QSM );

end

[h,p,ci,stats] = ttest2( cell2mat( data_all_subjects( : , 3 ) ), cell2mat( data_all_subjects( : , 4 ) ) );