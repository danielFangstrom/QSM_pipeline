subject_list = [1:4, 6:8, 11:23, 25:34, 36, 38:40, 42:46, 48:50, 101, 103:107, ...
        111:113, 115:117, 118:122, 124, 127, 130, 132:133, 135:146, 148, 149];
dir_smoothed_CNR_QSM = '/data/pt_01923/TmpOut/QSM/QSM_pipeline/group_analysis/Deaveraged_images/Current/';
%dir_smoothed_CNR_QSM = '/data/pt_01923/TmpOut/QSM/QSM_pipeline/group_analysis/Deaveraged_images/Current/Positive_images/';
%cd( dir_smoothed_CNR_QSM );
mask_dir = '/data/pt_01923/TmpOut/QSM/QSM_pipeline/group_analysis/Reinforcement_learning_atlas/created_atlas_masks/';
cerebellum_mask_name = 'eroded_modified_cerebellum_mask_MATLAB_reduced_more_inclusive.nii.gz'; %'cerebellum_mask_MATLAB_reduced_more_inclusive.nii'; % 'cerebellum_manual_conservative_correct.nii.gz'; %'cerebellum_wfu_applyxfm_binary_09.nii.gz';
putamen_mask_name = 'eroded_putamen_mask_MATLAB_reduced_more_inclusive.nii.gz'; %'Putamen_40_MNI.nii.gz'; %'putamen_mask_MATLAB_reduced_more_inclusive.nii'; 
premotor_mask_name = 'eroded_modified_premotor_manual.nii.gz'; %'premotor_manual.nii'; %'premotor_mask_MATLAB_reduced_more_inclusive.nii'; %'premotor_no_SMA_wfu_applyxfm_binary.nii.gz';
reference_mask_name = 'modified_crus_cerebri_manual_more_restrictive.nii'; %'crus_cerebri_manual_more_restrictive.nii';
occ_WM_reference_region_mask_name = 'eroded_modified_occipital_WM_ref.nii.gz'; %'occipital_WM_ref.nii';
CSF_reference_region_mask_name = 'eroded_modified_CSF_lateral_ventricles_ref.nii.gz'; %'CSF_lateral_ventricles_ref.nii';

pad_mask = 0;
write_mask_file = 0;

%% Just for test purposes
% SN_mask_name = 'SN_manual_40.nii.gz';
% VTA_mask_name = 'VTA_25_manual.nii.gz';
% 
% mask_SN = load_nifti( strcat( mask_dir, SN_mask_name ) );
% coords_SN_mask = find( mask_SN.vol);
% 
% mask_VTA = load_nifti( strcat( mask_dir, VTA_mask_name ) );
% coords_VTA_mask = find( mask_VTA.vol);
%%

if pad_mask == 1 || write_mask_file == 1
    maskFunctions = maskFunctionsContainer;
    file_name_QSM = strcat( dir_smoothed_CNR_QSM, '1mm_smoothed_001_deaveraged.nii' );
    QSM_vol = niftiread( file_name_QSM );
    QSM_info = niftiinfo( file_name_QSM );
end

mask_cerebellum_vol = niftiread( strcat( mask_dir, cerebellum_mask_name ) );
mask_cerebellum_info = niftiinfo( strcat( mask_dir, cerebellum_mask_name ) );
if pad_mask == 1
    zeros_to_add = floor( (QSM_info.ImageSize-mask_cerebellum_info.ImageSize(1:3))/2);
    % Although this is how many zeroes that are needed, we need to account
    % for the offfset, otherwise the mask will be misaligned. These are
    % added instead of those calculated above, but only in one direction
    % (and in the rigth dimension)
    %adjustment_zeroes = maskFunctions.CalculateOffsetAdjustment(mask_dir, cerebellum_mask_name, file_name_QSM, zeros_to_add);
    % Hardcoded for now
    mask_cerebellum_vol = padarray( mask_cerebellum_vol, [12 14 2], 0, 'both');
    mask_cerebellum_vol = padarray( mask_cerebellum_vol, [0 0 10], 0, 'post');
    mask_cerebellum_vol(end, end, end+1) = 0;
end
coords_cerebellum_mask = find( mask_cerebellum_vol);

mask_putamen_vol = niftiread( strcat( mask_dir, putamen_mask_name ) );
if pad_mask == 1
    % Hardcoded for now
    mask_putamen_vol = padarray( mask_putamen_vol, [12 14 2], 0, 'both');
    mask_putamen_vol = padarray( mask_putamen_vol, [0 0 10], 0, 'post');
    mask_putamen_vol(end, end, end+1) = 0;
end
coords_putamen_mask = find( mask_putamen_vol);

mask_premotor_vol = niftiread( strcat( mask_dir, premotor_mask_name ) );
if pad_mask == 1
    % Hardcoded for now
    mask_premotor_vol = padarray( mask_premotor_vol, [12 14 2], 0, 'both');
    mask_premotor_vol = padarray( mask_premotor_vol, [0 0 10], 0, 'post');
    mask_premotor_vol(end, end, end+1) = 0;
end
coords_premotor_mask = find( mask_premotor_vol);

mask_reference_vol = niftiread( strcat( mask_dir, reference_mask_name ) );
if pad_mask == 1
    % Hardcoded for now
    mask_reference_vol = padarray( mask_reference_vol, [12 14 2], 0, 'both');
    mask_reference_vol = padarray( mask_reference_vol, [0 0 10], 0, 'post');
    mask_reference_vol(end, end, end+1) = 0;
end
coords_reference_mask = find( mask_reference_vol);

occipital_WM_mask_reference_vol = niftiread( strcat( mask_dir, occ_WM_reference_region_mask_name ) );
if pad_mask == 1
    % Hardcoded for now
    occipital_WM_mask_reference_vol = padarray( occipital_WM_mask_reference_vol, [12 14 2], 0, 'both');
    occipital_WM_mask_reference_vol = padarray( occipital_WM_mask_reference_vol, [0 0 10], 0, 'post');
    occipital_WM_mask_reference_vol(end, end, end+1) = 0;
end
coords_occipital_WM_reference_mask = find( occipital_WM_mask_reference_vol);

mask_CSF_reference_vol = niftiread( strcat( mask_dir, CSF_reference_region_mask_name ) );
if pad_mask == 1
    % Hardcoded for now
    mask_CSF_reference_vol = padarray( mask_CSF_reference_vol, [12 14 2], 0, 'both');
    mask_CSF_reference_vol = padarray( mask_CSF_reference_vol, [0 0 10], 0, 'post');
    mask_CSF_reference_vol(end, end, end+1) = 0;
end
coords_CSF_reference_mask = find( mask_CSF_reference_vol);

if write_mask_file == 1
    % In order to save the file with the correct information, we copy info
    % stored in the header of the QSM file
    maskFunctions.WriteUpdatedMasks( mask_cerebellum_vol, mask_dir, cerebellum_mask_name, file_name_QSM );
    maskFunctions.WriteUpdatedMasks( mask_putamen_vol, mask_dir, putamen_mask_name, file_name_QSM );
    maskFunctions.WriteUpdatedMasks( mask_premotor_vol, mask_dir, premotor_mask_name, file_name_QSM );
    maskFunctions.WriteUpdatedMasks( mask_reference_vol, mask_dir, reference_mask_name, file_name_QSM );
    maskFunctions.WriteUpdatedMasks( occipital_WM_mask_reference_vol, mask_dir, occ_WM_reference_region_mask_name, file_name_QSM );
    maskFunctions.WriteUpdatedMasks( mask_CSF_reference_vol, mask_dir, CSF_reference_region_mask_name, file_name_QSM );
end


% All cerebellum masked data goes into the 1st column, all putamen masked data goes
% into the 2nd column, and all premotor masked data goes into the 3rd column.
data_all_subjects = cell( length( subject_list), 12);

for isub = 1:length( subject_list )
    subject = subject_list( isub );

    file_name_QSM = strcat( dir_smoothed_CNR_QSM, '1mm_smoothed_', sprintf( '%03d', subject ),  '_deaveraged.nii' );
    QSM_vol = niftiread( file_name_QSM );

    %% Just for test purposes
    %     SN_masked_QSM = QSM.vol( coords_SN_mask);
    %     VTA_masked_QSM = QSM.vol( coords_VTA_mask);
    %%

    cerebellum_masked_QSM = QSM_vol( coords_cerebellum_mask);
    putamen_masked_QSM = QSM_vol( coords_putamen_mask);
    premotor_masked_QSM = QSM_vol( coords_premotor_mask);
    reference_masked_QSM = QSM_vol( coords_reference_mask);
    occipital_WM_reference_masked_QSM = QSM_vol( coords_occipital_WM_reference_mask);
    CSF_reference_masked_QSM = QSM_vol( coords_CSF_reference_mask);


    data_all_subjects{ isub, 1} = cerebellum_masked_QSM;
    data_all_subjects{ isub, 2} = putamen_masked_QSM;
    data_all_subjects{ isub, 3} = premotor_masked_QSM;
    data_all_subjects{ isub, 4} = reference_masked_QSM;
    data_all_subjects{ isub, 5} = occipital_WM_reference_masked_QSM;
    data_all_subjects{ isub, 6} = CSF_reference_masked_QSM;
    data_all_subjects{ isub, 7} = mean( cerebellum_masked_QSM );
    data_all_subjects{ isub, 8} = mean( putamen_masked_QSM );
    data_all_subjects{ isub, 9} = mean( premotor_masked_QSM );
    data_all_subjects{ isub, 10} = mean( reference_masked_QSM );
    data_all_subjects{ isub, 11} = mean( occipital_WM_reference_masked_QSM );
    data_all_subjects{ isub, 12} = mean( CSF_reference_masked_QSM );

end

% Test cerebellum vs reference region
[h_cerebellum,p_cerebellum,ci_cerebellum,stats_cerebellum] = ttest2( cell2mat( data_all_subjects( : , 7 ) ), cell2mat( data_all_subjects( : , 10 ) ) );
% Test putamen vs reference region
[h_putamen,p_putamen,ci_putamen,stats_putamen] = ttest2( cell2mat( data_all_subjects( : , 8 ) ), cell2mat( data_all_subjects( : , 10 ) ) );
% Test premotor vs reference region
[h_premotor,p_premotor,ci_premotor,stats_premotor] = ttest2( cell2mat( data_all_subjects( : , 9 ) ), cell2mat( data_all_subjects( : , 10 ) ) );
% Test occipital WM reference vs reference region
[h_occ_WM,p_occ_WM,ci_occ_WM,stats_occ_WM] = ttest2( cell2mat( data_all_subjects( : , 11 ) ), cell2mat( data_all_subjects( : , 10 ) ) );
% Test CSF reference vs reference region
[h_CSF,p_CSF,ci_CSF,stats_CSF] = ttest2( cell2mat( data_all_subjects( : , 12 ) ), cell2mat( data_all_subjects( : , 10 ) ) );