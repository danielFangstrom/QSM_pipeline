subject_list = [1:4, 6:8, 11:23, 25:34, 36, 38:40, 42:46, 48:50, 101, 103:107, ...
        111:113, 115:117, 118:122, 124, 127, 130, 132:133, 135:146, 148, 149];
dir_smoothed_QSM = '/data/pt_01923/TmpOut/QSM/QSM_pipeline/group_analysis/Deaveraged_images/Current/';
mask_dir = '/data/pt_01923/TmpOut/QSM/QSM_pipeline/group_analysis/Reinforcement_learning_atlas/created_atlas_masks/';
SN_mask_name = 'SN_manual_40.nii';
VTA_mask_name = 'VTA_25_manual.nii';
LC_mask_name = 'LC_manual.nii';
whole_brain_mask_name = 'whole_brain_mask_mask.nii';
reference_mask_name = 'crus_cerebri_manual_more_restrictive.nii';
occ_WM_reference_region_mask_name = 'occipital_WM_ref.nii'; %'crus_cerebri_manual_more_restrictive.nii';
CSF_reference_region_mask_name = 'CSF_lateral_ventricles_ref.nii';


delimiterIn = ',';
headerlinesIn = 0;
BMI_file = importdata( '/data/pt_01923/TmpOut/QSM/QSM_pipeline/group_analysis/subs_bmi.txt', delimiterIn, headerlinesIn );
age_file = importdata( '/data/pt_01923/TmpOut/QSM/QSM_pipeline/group_analysis/subs_age.txt', delimiterIn, headerlinesIn );

mask_SN = load_nifti( strcat( mask_dir, SN_mask_name ) );
coords_SN_mask = find( mask_SN.vol);

mask_VTA = load_nifti( strcat( mask_dir, VTA_mask_name ) );
coords_VTA_mask = find( mask_VTA.vol);

mask_LC = load_nifti( strcat( mask_dir, LC_mask_name ) );
coords_LC_mask = find( mask_LC.vol);

mask_whole_brain = load_nifti( strcat( mask_dir, whole_brain_mask_name ) );
coords_whole_brain_mask = find( mask_whole_brain.vol);

mask_reference = load_nifti( strcat( mask_dir, reference_mask_name ) );
coords_reference_mask = find( mask_reference.vol);

occ_WM_mask_reference = load_nifti( strcat( mask_dir, occ_WM_reference_region_mask_name ) );
occ_WM_coords_reference_mask = find( occ_WM_mask_reference.vol);

CSF_mask_reference = load_nifti( strcat( mask_dir, CSF_reference_region_mask_name ) );
CSF_coords_reference_mask = find( CSF_mask_reference.vol);

% All VTA masked data goes into the 1st (left) and 2nd (right) columns, all SN masked data goes
% into the 3rd (left) and 4th(right) columns, and the all the LC masked data
% goes into the 5th (left) and 6th (right) columns.
data_all_subjects = cell( length( subject_list), 9);

for isub = 1:length( subject_list )
    subject = subject_list( isub );
%     if subject == 1
%         file_name_QSM = strcat( dir_registered_QSM_files, '001_QSM_masked.nii' );
%     else
%         file_name_QSM = strcat( dir_registered_QSM_files, sprintf( '%03d', subject ),  '_to_001_flirt_QSM_transformed_T1_space.nii' );
%     end
    %file_name_QSM = strcat( dir_smoothed_CNR_QSM, 'positive_smoothed_1mm_', sprintf( '%03d', subject ),  '_CNR.nii' );
    file_name_QSM = strcat( dir_smoothed_CNR_QSM, '1mm_smoothed_', sprintf( '%03d', subject ),  '_deaveraged.nii' );
    QSM = load_nifti( file_name_QSM );

    SN_masked_QSM = QSM.vol( coords_SN_mask);
    VTA_masked_QSM = QSM.vol( coords_VTA_mask);
    LC_masked_QSM = QSM.vol( coords_LC_mask);
    whole_brain_masked_QSM = QSM.vol( coords_whole_brain_mask);
    CC_ref_masked_QSM = QSM.vol( coords_reference_mask );
    occ_WM_masked_QSM = QSM.vol( occ_WM_coords_reference_mask);
    CSF_masked_QSM = QSM.vol( CSF_coords_reference_mask);

    data_all_subjects{ isub, 1} = mean( round( SN_masked_QSM, 9 ) );
    data_all_subjects{ isub, 2} = mean( round( VTA_masked_QSM, 9 ) );
    data_all_subjects{ isub, 3} = mean( round( LC_masked_QSM, 9 ) );
    data_all_subjects{ isub, 4} = mean( round( whole_brain_masked_QSM, 9 ) );
    data_all_subjects{ isub, 5} = mean( round( CC_ref_masked_QSM, 9 ) );
    data_all_subjects{ isub, 6} = mean( round( occ_WM_masked_QSM, 9 ) );
    data_all_subjects{ isub, 7} = mean( round( CSF_masked_QSM, 9 ) );
%     data_all_subjects{ isub, 1} = SN_masked_QSM;
%     data_all_subjects{ isub, 2} = VTA_masked_QSM;
%     data_all_subjects{ isub, 3} = LC_masked_QSM;
%     data_all_subjects{ isub, 4} = whole_brain_masked_QSM;
%     data_all_subjects{ isub, 5} = CC_ref_masked_QSM;
%     data_all_subjects{ isub, 6} = occ_WM_masked_QSM;
%     data_all_subjects{ isub, 7} = CSF_masked_QSM;
    data_all_subjects{ isub, 8} = BMI_file.data(isub);
    data_all_subjects{ isub, 9} = age_file.data(isub);

end

% [h_VTA,p_VTA,ci_VTA,stats_VTA] = ttest( cell2mat( data_all_subjects( : , 1 ) ), cell2mat( data_all_subjects( : , 2 ) ), Alpha=0.001 );
% [h_SN,p_SN,ci_SN,stats_SN] = ttest( cell2mat( data_all_subjects( : , 3 ) ), cell2mat( data_all_subjects( : , 4 ) ), Alpha=0.001 );
% [h_LC,p_LC,ci_LC,stats_LC] = ttest( cell2mat( data_all_subjects( : , 5 ) ), cell2mat( data_all_subjects( : ,6 ) ), Alpha=0.001 );

global_values_removed_SN = cell2mat( data_all_subjects( : , 1 ) ) -  cell2mat( data_all_subjects( : , 4 ) );
global_values_removed_VTA = cell2mat( data_all_subjects( : , 2 ) ) -  cell2mat( data_all_subjects( : , 4 ) );
global_values_removed_LC = cell2mat( data_all_subjects( : , 3 ) ) -  cell2mat( data_all_subjects( : , 4 ) );

[R_SN_BMI_old,P_SN_BMI_old,RL_SN_BMI_old,RU_SN_BMI_old] = corrcoef( cell2mat( data_all_subjects( : , 1 ) ), cell2mat( data_all_subjects( : , 8) ) );
[R_VTA_BMI_old,P_VTA_BMI_old,RL_VTA_BMI_old,RU_VTA_BMI_old] =  corrcoef( cell2mat( data_all_subjects( : , 2 ) ), cell2mat( data_all_subjects( : , 8) ) );
[R_LC_BMI_old,P_LC_BMI_old,RL_LC_BMI_old,RU_LC_BMI_old] = corrcoef( cell2mat( data_all_subjects( : , 3 ) ), cell2mat( data_all_subjects( : , 8) ) );
[R_SN_BMI,P_SN_BMI,RL_SN_BMI,RU_SN_BMI] = corrcoef( global_values_removed_SN, cell2mat( data_all_subjects( : , 8) ) );
[R_VTA_BMI,P_VTA_BMI,RL_VTA_BMI,RU_VTA_BMI] =  corrcoef( global_values_removed_VTA, cell2mat( data_all_subjects( : , 8) ) );
[R_LC_BMI,P_LC_BMI,RL_LC_BMI,RU_LC_BMI] = corrcoef( global_values_removed_LC, cell2mat( data_all_subjects( : , 8) ) );
[R_whole_brain_BMI,P_whole_brain_BMI,RL_whole_brain_BMI,RU_whole_brain_BMI] = corrcoef( cell2mat( data_all_subjects( : , 4 ) ), cell2mat( data_all_subjects( : , 8) ) );

[R_SN_age,P_SN_age,RL_SN_age,RU_SN_age] = corrcoef( [ cell2mat( data_all_subjects( : , 1 ) ), cell2mat( data_all_subjects( : , 9) ) ] );
[R_VTA_age,P_VTA_age,RL_VTA_age,RU_VTA_age] =  corrcoef( [ cell2mat( data_all_subjects( : , 2 ) ), cell2mat( data_all_subjects( : , 9) ) ] );
[R_LC_age,P_LC_age,RL_LC_age,RU_LC_age] = corrcoef( [ cell2mat( data_all_subjects( : , 3 ) ), cell2mat( data_all_subjects( : , 9) ) ] );
[R_whole_brain_age,P_whole_brain_age,RL_whole_brain_age,RU_whole_brain_age] = corrcoef( [ cell2mat( data_all_subjects( : , 4 ) ), cell2mat( data_all_subjects( : , 9) ) ] );

[R_age_BMI,P_age_BMI,RL_age_BMI,RU_age_BMI] = corrcoef( cell2mat( data_all_subjects( : , 8) ), cell2mat( data_all_subjects( : , 9) ) );

[h_DFS_age, p_DFS_age, ci_DFS_age, stats_DFS_age] = ttest2( cell2mat( data_all_subjects( 1:42 , 9) ), cell2mat( data_all_subjects( 43:78 , 9) ) );
[h_DFS_overweight, p_DFS_overweight, ci_DFS_overweight, stats_DFS_overweight] = ttest2( cell2mat( data_all_subjects( 1:42 , 8) )>=25, cell2mat( data_all_subjects( 43:78 , 8) )>=25 );
[h_DFS_BMI, p_DFS_BMI, ci_DFS_BMI, stats_DFS_BMI] = ttest2( cell2mat( data_all_subjects( 1:42 , 8) ), cell2mat( data_all_subjects( 43:78 , 8) ) );

% figure(2); hold on;
% scatter( cell2mat( data_all_subjects( :, 1 ) ), cell2mat( data_all_subjects( : , 8) ) );
% hold off;
% figure(3); hold on;
% scatter( cell2mat( data_all_subjects( :, 2 ) ), cell2mat( data_all_subjects( : , 8) ) );
% hold off;
% figure(4); hold on;
% scatter( cell2mat( data_all_subjects( :, 3 ) ), cell2mat( data_all_subjects( : , 8) ) );
% hold off;
% figure(5); hold on;
% scatter( cell2mat( data_all_subjects( :, 4 ) ), cell2mat( data_all_subjects( : , 8) ) );
% hold off;
% figure(6); hold on;
% scatter( cell2mat( data_all_subjects( :, 5 ) ), cell2mat( data_all_subjects( : , 8) ) );
% hold off;
% figure(7); hold on;
% scatter( cell2mat( data_all_subjects( :, 6 ) ), cell2mat( data_all_subjects( : , 8) ) );
% hold off;
% figure(8); hold on;
% scatter( cell2mat( data_all_subjects( :, 7 ) ), cell2mat( data_all_subjects( : , 8) ) );
% hold off;
figure(9); hold on;
corrplot( [ cell2mat( data_all_subjects( :, 1 ) ), cell2mat( data_all_subjects( :, 2 ) ), cell2mat( data_all_subjects( :, 3 ) ), ...
    cell2mat( data_all_subjects( :, 5 ) ), cell2mat( data_all_subjects( :, 6 ) ), ...
    cell2mat( data_all_subjects( :, 7 ) ), cell2mat( data_all_subjects( : , 8) ) ] );