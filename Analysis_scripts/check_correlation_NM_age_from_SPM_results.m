subject_list = [1:4, 6:8, 11:23, 25:34, 36, 38:40, 42:46, 48:50, 101, 103:107, ...
        111:113, 115:117, 118:122, 124, 127, 130, 132:133, 135:146, 148, 149];
dir_smoothed_CNR_QSM = '/data/pt_01923/TmpOut/QSM/QSM_pipeline/group_analysis/Deaveraged_images/Current_7th_bspline_deformation/';
dir_GM_QSM = '/data/pt_01923/TmpOut/QSM/QSM_pipeline/QSM_segmentation/CAT12_segmentation_deformation_7th_spline/Segmented_deaveraged/';
dir_WM_QSM = '/data/pt_01923/TmpOut/QSM/QSM_pipeline/QSM_segmentation/CAT12_segmentation_deformation_7th_spline/Segmented_deaveraged/';
mask_dir = '/data/pt_01923/TmpOut/QSM/QSM_pipeline/group_analysis/Reinforcement_learning_atlas/created_atlas_masks/';
SN_mask_name = 'modified_SN_manual_40.nii';
VTA_mask_name = 'modified_VTA_25_manual.nii';
LC_mask_name = 'modified_LC_manual.nii';

mask_SN_vol = niftiread( strcat( mask_dir, SN_mask_name ) );
coords_SN_mask = find( mask_SN_vol);

mask_VTA_vol = niftiread( strcat( mask_dir, VTA_mask_name ) );
coords_VTA_mask = find( mask_VTA_vol);

mask_LC_vol = niftiread( strcat( mask_dir, LC_mask_name ) );
coords_LC_mask = find( mask_LC_vol);

delimiterIn = ',';
headerlinesIn = 0;
age_file = importdata( '/data/pt_01923/TmpOut/QSM/QSM_pipeline/group_analysis/subs_age.txt', delimiterIn, headerlinesIn );
BMI_file = importdata( '/data/pt_01923/TmpOut/QSM/QSM_pipeline/group_analysis/subs_bmi.txt', delimiterIn, headerlinesIn );

data_all_subjects = cell( length( subject_list), 12);

for isub = 1:length( subject_list )
    subject = subject_list( isub );
%     if subject == 1
%         file_name_QSM = strcat( dir_registered_QSM_files, '001_QSM_masked.nii' );
%     else
%         file_name_QSM = strcat( dir_registered_QSM_files, sprintf( '%03d', subject ),  '_to_001_flirt_QSM_transformed_T1_space.nii' );
%     end
    file_name_QSM = strcat( dir_smoothed_CNR_QSM, '1mm_smoothed_', sprintf( '%03d', subject ),  '_deaveraged.nii' );
    QSM_vol = niftiread( file_name_QSM );

    %file_name_GM_QSM = strcat( dir_GM_QSM, '1mm_smoothed_', sprintf( '%03d', subject ), '_c1_QSM_subtracted_by_average.nii.gz');
    file_name_GM_QSM = strcat( dir_GM_QSM, sprintf( '%03d', subject ), '_1_deaveraged_not_reg.nii.gz');
    GM_QSM_vol = niftiread( file_name_GM_QSM );

    %file_name_WM_QSM = strcat( dir_WM_QSM, '1mm_smoothed_', sprintf( '%03d', subject ), '_c2_QSM_subtracted_by_average.nii.gz');
    file_name_WM_QSM = strcat( dir_WM_QSM, sprintf( '%03d', subject ), '_2_deaveraged_not_reg.nii.gz');
    WM_QSM_vol = niftiread( file_name_WM_QSM );

    SN_masked_QSM = QSM_vol( coords_SN_mask);
    VTA_masked_QSM = QSM_vol( coords_VTA_mask);
    LC_masked_QSM = QSM_vol( coords_LC_mask);
    
    % Extract the relevant voxels (coordinates taken from spm clusters
    % loaded into ITK snap)
    data_all_subjects{ isub, 1} = QSM_vol( sub2ind( size( QSM_vol ),102,108,63 ) );
    data_all_subjects{ isub, 2} = QSM_vol( sub2ind( size( QSM_vol ),102,109,64 ) );
    data_all_subjects{ isub, 3} = QSM_vol( sub2ind( size( QSM_vol ), 97,115,63 ) );
    data_all_subjects{ isub, 4} = QSM_vol( sub2ind( size( QSM_vol ), 80,108,62 ) );
    data_all_subjects{ isub, 5} = QSM_vol( sub2ind( size( QSM_vol ), 80,106,62 ) );
    data_all_subjects{ isub, 6} = age_file.data(isub);
    data_all_subjects{ isub, 7} = BMI_file.data(isub);
    data_all_subjects{ isub, 8} = mean( SN_masked_QSM );
    data_all_subjects{ isub, 9} = mean( VTA_masked_QSM );
    data_all_subjects{ isub, 10} = mean( LC_masked_QSM );
    data_all_subjects{ isub, 11} = mean( GM_QSM_vol, 'all');
    data_all_subjects{ isub, 12} = mean( WM_QSM_vol, 'all');

end

 [R_1, p_1] = corrcoef( cell2mat( data_all_subjects( : , 1 ) ), cell2mat( data_all_subjects( : , 6 ) ) );
 [R_2, p_2] = corrcoef( cell2mat( data_all_subjects( : , 2 ) ), cell2mat( data_all_subjects( : , 6 ) ) );
 [R_3, p_3] = corrcoef( cell2mat( data_all_subjects( : , 3 ) ), cell2mat( data_all_subjects( : , 6 ) ) );
 [R_4, p_4] = corrcoef( cell2mat( data_all_subjects( : , 4 ) ), cell2mat( data_all_subjects( : , 6 ) ) );
 [R_5, p_5] = corrcoef( cell2mat( data_all_subjects( : , 5 ) ), cell2mat( data_all_subjects( : , 6 ) ) );

 [R_age_mean_SN, p_age_mean_SN] = corrcoef( cell2mat( data_all_subjects( : , 8 ) ), cell2mat( data_all_subjects( : , 6 ) ), 'rows', 'pairwise' );
 [R_BMI_mean_SN, p_BMI_mean_SN] = corrcoef( cell2mat( data_all_subjects( : , 8 ) ), cell2mat( data_all_subjects( : , 7 ) ), 'rows', 'pairwise' );

 [R_age_mean_VTA, p_age_mean_VTA] = corrcoef( cell2mat( data_all_subjects( : , 9 ) ), cell2mat( data_all_subjects( : , 6 ) ), 'rows', 'pairwise' );
 [R_BMI_mean_VTA, p_BMI_mean_VTA] = corrcoef( cell2mat( data_all_subjects( : , 9 ) ), cell2mat( data_all_subjects( : , 7 ) ), 'rows', 'pairwise' );

 [R_age_mean_LC, p_age_mean_LC] = corrcoef( cell2mat( data_all_subjects( : , 10 ) ), cell2mat( data_all_subjects( : , 6 ) ), 'rows', 'pairwise' );
 [R_BMI_mean_LC, p_BMI_mean_LC] = corrcoef( cell2mat( data_all_subjects( : , 10 ) ), cell2mat( data_all_subjects( : , 7 ) ), 'rows', 'pairwise' );

 [R_age_mean_GM, p_age_mean_GM] = corrcoef( cell2mat( data_all_subjects( : , 11 ) ), cell2mat( data_all_subjects( : , 6 ) ), 'rows', 'pairwise' );
 [R_BMI_mean_GM, p_BMI_mean_GM] = corrcoef( cell2mat( data_all_subjects( : , 11 ) ), cell2mat( data_all_subjects( : , 7 ) ), 'rows', 'pairwise' );

 [R_age_mean_WM, p_age_mean_WM] = corrcoef( cell2mat( data_all_subjects( : , 12 ) ), cell2mat( data_all_subjects( : , 6 ) ), 'rows', 'pairwise' );
 [R_BMI_mean_WM, p_BMI_mean_WM] = corrcoef( cell2mat( data_all_subjects( : , 12 ) ), cell2mat( data_all_subjects( : , 7 ) ), 'rows', 'pairwise' );