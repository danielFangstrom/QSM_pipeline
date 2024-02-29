subject_list = [1:4, 6:8, 11:23, 25:34, 36, 38:40, 42:46, 48:50, 101, 103:107, ...
        111:113, 115:117, 118:122, 124, 127, 130, 132:133, 135:146, 148, 149];
% subject_list = [1];
dir_smoothed_CNR_QSM = '/data/pt_01923/TmpOut/QSM/QSM_pipeline/group_analysis/Deaveraged_images/Current_7th_bspline_deformation/';
%dir_smoothed_CNR_QSM = '/data/pt_01923/TmpOut/QSM/QSM_pipeline/group_analysis/Deaveraged_images/Current/No_nans_not_deaveraged/';
cd( dir_smoothed_CNR_QSM );
mask_dir = '/data/pt_01923/TmpOut/QSM/QSM_pipeline/group_analysis/Reinforcement_learning_atlas/created_atlas_masks/';
left_SN_mask_name = 'modified_left_SN_manual_40.nii'; %'new_LEFT_SN_40.nii.gz'; %'left_SN_manual_40.nii';
right_SN_mask_name = 'modified_right_SN_manual_40.nii'; %'new_LEFT_SN_40.nii.gz'; %'right_SN_manual_40.nii';
left_VTA_mask_name = 'modified_left_VTA_25_manual.nii'; %'new_LEFT_VTA_25.nii.gz'; %'left_VTA_25_manual.nii';
right_VTA_mask_name = 'modified_right_VTA_25_manual.nii'; %'new_LEFT_VTA_25.nii.gz'; %'right_VTA_25_manual.nii';
left_LC_mask_name = 'modified_left_LC_manual.nii'; %'left_LC_manual.nii';
right_LC_mask_name = 'modified_right_LC_manual.nii'; %'right_LC_manual.nii';

delimiterIn = ',';
headerlinesIn = 0;
BMI_file = importdata( '/data/pt_01923/TmpOut/QSM/QSM_pipeline/group_analysis/subs_bmi.txt', delimiterIn, headerlinesIn );
age_file = importdata( '/data/pt_01923/TmpOut/QSM/QSM_pipeline/group_analysis/subs_age.txt', delimiterIn, headerlinesIn );

pad_mask = 0;
write_mask_file = 0;

%% Load the mask files.
% We need to pad the mask image with zeroes to equal that of the QSM image (otherwise
% they won't line up when we use these methods). 
% First we load one QSM image to get its dimensions
%file_name_QSM = strcat( dir_smoothed_CNR_QSM, '1mm_smoothed_001_QSM_no_nans.nii' );
file_name_QSM = strcat( dir_smoothed_CNR_QSM, '1mm_smoothed_001_deaveraged.nii' );
QSM_vol = niftiread( file_name_QSM );
QSM_info = niftiinfo( file_name_QSM );

mask_left_SN_vol = niftiread( strcat( mask_dir, left_SN_mask_name ) );
mask_left_SN_info = niftiinfo( strcat( mask_dir, left_SN_mask_name ) );
if pad_mask == 1
    % We use floor to keep it to integers, and we divide it by 2 since we are
    % adding it to both ends of the matrix.
    % Additional zeros needed to reach an odd dimension size can be added at the end
    zeros_to_add = floor( (QSM_info.ImageSize-mask_left_SN_info.ImageSize)/2);
    % Although this is how many zeroes that are needed, we need to account
    % for the offfset, otherwise the mask will be misaligned. These are
    % added instead of those calculated above, but only in one direction
    % (and in the rigth dimension)
    adjustment_zeroes = CalculateOffsetAdjustment(mask_dir, left_SN_mask_name, file_name_QSM, zeros_to_add);
    %mask_left_SN_vol = padarray( mask_left_SN_vol, zeros_to_add, 0, 'both');
    % Hardcoded for now
    mask_left_SN_vol = padarray( mask_left_SN_vol, [12 14 2], 0, 'both');
    mask_left_SN_vol = padarray( mask_left_SN_vol, [0 0 10], 0, 'post');
    % It is hardcoded for now but will be done dynamically later on
    mask_left_SN_vol(end, end, end+1) = 0;
end
% Find the coordinates of the mask in the QSM image
coords_left_SN_mask = find( mask_left_SN_vol);

mask_right_SN_vol = niftiread( strcat( mask_dir, right_SN_mask_name ) );
mask_right_SN_info = niftiinfo( strcat( mask_dir, right_SN_mask_name ) );
if pad_mask ==1
    % We will apply the same operation to all other masks as well
    zeros_to_add = floor( (QSM_info.ImageSize-mask_right_SN_info.ImageSize)/2);
    %mask_right_SN_vol = padarray( mask_right_SN_vol, zeros_to_add, 0, 'both');
    mask_right_SN_vol = padarray( mask_right_SN_vol, [12 14 2], 0, 'both');
    mask_right_SN_vol = padarray( mask_right_SN_vol, [0 0 10], 0, 'post');
    mask_right_SN_vol(end, end, end+1) = 0;
end
coords_right_SN_mask = find( mask_right_SN_vol);

mask_left_VTA_vol = niftiread( strcat( mask_dir, left_VTA_mask_name ) );
mask_left_VTA_info = niftiinfo( strcat( mask_dir, left_VTA_mask_name ) );
if pad_mask == 1
    origin_mask_left_VTA_vol = mask_left_VTA_vol;
    zeros_to_add = floor( (QSM_info.ImageSize-mask_left_VTA_info.ImageSize)/2);
    %mask_left_VTA_vol = padarray( mask_left_VTA_vol, zeros_to_add, 0, 'both');
    mask_left_VTA_vol = padarray( mask_left_VTA_vol, [12 14 2], 0, 'both');
    mask_left_VTA_vol = padarray( mask_left_VTA_vol, [0 0 10], 0, 'post');
    mask_left_VTA_vol(end, end, end+1) = 0;
end
coords_left_VTA_mask = find( mask_left_VTA_vol);
%if write_mask_file == 1
    % In order to save the file with the correct information, we copy info
    % stored in the header of the QSM file
    %WriteUpdatedMasks( mask_left_VTA_vol, mask_dir, left_VTA_mask_name, file_name_QSM );
%     info_QSM = niftiinfo( file_name_QSM );
%     info_left_VTA_mask = niftiinfo( strcat( mask_dir, left_VTA_mask_name )  );
%     info_left_VTA_mask.ImageSize = size( mask_left_VTA_vol );
%     info_left_VTA_mask.Description = 'Image size increased via zero padding to match that of the QSM file';
%     info_left_VTA_mask.raw_info.ImageSize = [3,181,217,181,1,1,1,1];
%     info_left_VTA_mask.Datatype = 'double';
%     info_left_VTA_mask.raw.qform_code = info_QSM.raw.qform_code;
%     info_left_VTA_mask.raw.sform_code = info_QSM.raw.sform_code;
%     info_left_VTA_mask.raw.qoffset_x = info_QSM.raw.qoffset_x;
%     info_left_VTA_mask.raw.qoffset_y = info_QSM.raw.qoffset_y;
%     info_left_VTA_mask.raw.qoffset_z = info_QSM.raw.qoffset_z;
%     info_left_VTA_mask.raw.srow_x = info_QSM.raw.srow_x;
%     info_left_VTA_mask.raw.srow_y = info_QSM.raw.srow_y;
%     info_left_VTA_mask.raw.srow_z = info_QSM.raw.srow_z;
%     info_left_VTA_mask.TransformName = info_QSM.TransformName;
%     info_left_VTA_mask.Transform = info_QSM.Transform;
%     niftiwrite( mask_left_VTA_vol, 'modified_left_VTA_25_manual.nii', info_left_VTA_mask )
%end

mask_right_VTA_vol = niftiread( strcat( mask_dir, right_VTA_mask_name ) );
mask_right_VTA_info = niftiinfo( strcat( mask_dir, right_VTA_mask_name ) );
if pad_mask == 1
    zeros_to_add = floor( (QSM_info.ImageSize-mask_right_VTA_info.ImageSize)/2);
    %mask_right_VTA_vol = padarray( mask_right_VTA_vol, zeros_to_add, 0, 'both');
    mask_right_VTA_vol = padarray( mask_right_VTA_vol, [12 14 2], 0, 'both');
    mask_right_VTA_vol = padarray( mask_right_VTA_vol, [0 0 10], 0, 'post');
    mask_right_VTA_vol(end, end, end+1) = 0;
end
coords_right_VTA_mask = find( mask_right_VTA_vol);

mask_left_LC_vol = niftiread( strcat( mask_dir, left_LC_mask_name ) );
mask_left_LC_info = niftiinfo( strcat( mask_dir, left_LC_mask_name ) );
if pad_mask == 1
    zeros_to_add = floor( (QSM_info.ImageSize-mask_left_LC_info.ImageSize)/2);
    %mask_left_LC_vol = padarray( mask_left_LC_vol, zeros_to_add, 0, 'both');
    mask_left_LC_vol = padarray( mask_left_LC_vol, [12 14 2], 0, 'both');
    mask_left_LC_vol = padarray( mask_left_LC_vol, [0 0 10], 0, 'post');
    mask_left_LC_vol(end, end, end+1) = 0;
end
coords_left_LC_mask = find( mask_left_LC_vol);

mask_right_LC_vol = niftiread( strcat( mask_dir, right_LC_mask_name ) );
mask_right_LC_info = niftiinfo( strcat( mask_dir, right_LC_mask_name ) );
if pad_mask == 1
    zeros_to_add = floor( (QSM_info.ImageSize-mask_right_LC_info.ImageSize)/2);
    %mask_right_LC_vol = padarray( mask_right_LC_vol, zeros_to_add, 0, 'both');
    mask_right_LC_vol = padarray( mask_right_LC_vol, [12 14 2], 0, 'both');
    mask_right_LC_vol = padarray( mask_right_LC_vol, [0 0 10], 0, 'both');
    mask_right_LC_vol(end, end, end+1) = 0;
end
coords_right_LC_mask = find( mask_right_LC_vol);


if write_mask_file == 1
    % In order to save the file with the correct information, we copy info
    % stored in the header of the QSM file
    WriteUpdatedMasks( mask_left_VTA_vol, mask_dir, left_VTA_mask_name, file_name_QSM );
    WriteUpdatedMasks( mask_right_VTA_vol, mask_dir, right_VTA_mask_name, file_name_QSM );
    WriteUpdatedMasks( mask_left_SN_vol, mask_dir, left_SN_mask_name, file_name_QSM );
    WriteUpdatedMasks( mask_right_SN_vol, mask_dir, right_SN_mask_name, file_name_QSM );
    WriteUpdatedMasks( mask_left_LC_vol, mask_dir, left_LC_mask_name, file_name_QSM );
    WriteUpdatedMasks( mask_right_LC_vol, mask_dir, right_LC_mask_name, file_name_QSM );
end

% All VTA masked data goes into the 1st (left) and 2nd (right) columns, all SN masked data goes
% into the 3rd (left) and 4th(right) columns, and the all the LC masked data
% goes into the 5th (left) and 6th (right) columns.
data_all_subjects = cell( length( subject_list), 15);


%% Loop over the subjects and extract the values in each region
for isub = 1:length( subject_list )
    subject = subject_list( isub );
    file_name_QSM = strcat( dir_smoothed_CNR_QSM, '1mm_smoothed_', sprintf( '%03d', subject ),  '_deaveraged.nii' );
    %file_name_QSM = strcat( dir_smoothed_CNR_QSM, '1mm_smoothed_', sprintf( '%03d', subject ),  '_deaveraged_positive.nii' );
    %file_name_QSM = strcat( dir_smoothed_CNR_QSM, '1mm_smoothed_', sprintf( '%03d', subject ),  '_QSM_no_nans.nii' );
    QSM_vol = niftiread( file_name_QSM );
    left_SN_masked_QSM = QSM_vol( coords_left_SN_mask);
    right_SN_masked_QSM = QSM_vol( coords_right_SN_mask);

    left_VTA_masked_QSM = QSM_vol( coords_left_VTA_mask);
    right_VTA_masked_QSM = QSM_vol( coords_right_VTA_mask);

    left_LC_masked_QSM = QSM_vol( coords_left_LC_mask);
    right_LC_masked_QSM = QSM_vol( coords_right_LC_mask);

    data_all_subjects{ isub, 1} = mean( left_VTA_masked_QSM );
    data_all_subjects{ isub, 2} = mean( right_VTA_masked_QSM );
    data_all_subjects{ isub, 3} = mean( left_SN_masked_QSM );
    data_all_subjects{ isub, 4} = mean( right_SN_masked_QSM );
    data_all_subjects{ isub, 5} = mean( left_LC_masked_QSM );
    data_all_subjects{ isub, 6} = mean( right_LC_masked_QSM );
    data_all_subjects{ isub, 7} = BMI_file.data(isub);
    data_all_subjects{ isub, 8} = age_file.data(isub);
    data_all_subjects{ isub, 9} = left_VTA_masked_QSM;
    data_all_subjects{ isub, 10} = right_VTA_masked_QSM;
    data_all_subjects{ isub, 11} = left_SN_masked_QSM;
    data_all_subjects{ isub, 12} = right_SN_masked_QSM;
    data_all_subjects{ isub, 13} = left_LC_masked_QSM;
    data_all_subjects{ isub, 14} = right_LC_masked_QSM;

end

%% Create asymmetry indices and correlate them (and the raw values) to different metrics
asymmetry_index_left_VTA = cell2mat( data_all_subjects( : , 1 ) ) ./ ( cell2mat( data_all_subjects( : , 1 ) ) + cell2mat( data_all_subjects( : , 2 ) ) );
asymmetry_index_right_VTA = cell2mat( data_all_subjects( : , 2 ) ) ./ ( cell2mat( data_all_subjects( : , 1 ) ) + cell2mat( data_all_subjects( : , 2 ) ) );
asymmetry_index_left_SN = cell2mat( data_all_subjects( : , 3 ) ) ./ ( cell2mat( data_all_subjects( : , 3 ) ) + cell2mat( data_all_subjects( : , 4 ) ) );
asymmetry_index_right_SN = cell2mat( data_all_subjects( : , 4 ) ) ./ ( cell2mat( data_all_subjects( : , 3 ) ) + cell2mat( data_all_subjects( : , 4 ) ) );
asymmetry_index_left_LC = cell2mat( data_all_subjects( : , 5 ) ) ./ ( cell2mat( data_all_subjects( : , 5 ) ) + cell2mat( data_all_subjects( : , 6 ) ) );
asymmetry_index_right_LC = cell2mat( data_all_subjects( : , 6 ) ) ./ ( cell2mat( data_all_subjects( : , 5 ) ) + cell2mat( data_all_subjects( : , 6 ) ) );

% Test if there are any difference between hemispheres in specific regions
[h_VTA,p_VTA,ci_VTA,stats_VTA] = ttest( cell2mat( data_all_subjects( : , 1 ) ), cell2mat( data_all_subjects( : , 2 ) ), Alpha=0.001 );
[h_SN,p_SN,ci_SN,stats_SN] = ttest( cell2mat( data_all_subjects( : , 3 ) ), cell2mat( data_all_subjects( : , 4 ) ), Alpha=0.001 );
[h_LC,p_LC,ci_LC,stats_LC] = ttest( cell2mat( data_all_subjects( : , 5 ) ), cell2mat( data_all_subjects( : ,6 ) ), Alpha=0.001 );

% Test if there are any regional hemispheric differences using asymmetry indices
[h_VTA_ai,p_VTA_ai,ci_VTA_ai,stats_VTA_ai] = ttest( asymmetry_index_left_VTA, asymmetry_index_right_VTA, Alpha=0.001 );
[h_SN_ai,p_SN_ai,ci_SN_ai,stats_SN_ai] = ttest( asymmetry_index_left_SN, asymmetry_index_right_SN, Alpha=0.001 );
[h_LC_ai,p_LC_ai,ci_LC_ai,stats_LC_ai] = ttest( asymmetry_index_left_LC, asymmetry_index_right_LC, Alpha=0.001 );

% Test if there are any regional hemispheric differences using all values
[h_all_VTA,p_all_VTA,ci_all_VTA,stats_all_VTA] = ttest2( cell2mat( data_all_subjects( : , 9 ) ), cell2mat( data_all_subjects( : , 10 ) ), Alpha=0.001 );
[h_all_SN,p_all_SN,ci_all_SN,stats_all_SN] = ttest2( cell2mat( data_all_subjects( : , 11 ) ), cell2mat( data_all_subjects( : , 12 ) ), Alpha=0.001 );
[h_all_LC,p_all_LC,ci_all_LC,stats_all_LC] = ttest( cell2mat( data_all_subjects( : , 13 ) ), cell2mat( data_all_subjects( : , 14 ) ), Alpha=0.001 );

% Test if there are any correlations between regional hemispheric
% differences and BMI
[R_VTA_BMI,P_VTA_BMI,RL_VTA_BMI,RU_VTA_BMI] = corrcoef( [ ( cell2mat( data_all_subjects( : , 1 ) ) - cell2mat( data_all_subjects( : , 2 ) ) ), cell2mat( data_all_subjects( : , 7) ) ] );
[R_SN_BMI,P_SN_BMI,RL_SN_BMI,RU_SN_BMI] =  corrcoef( [ ( cell2mat( data_all_subjects( : , 3 ) ) - cell2mat( data_all_subjects( : , 4) ) ), cell2mat( data_all_subjects( : , 7) ) ] );
[R_LC_BMI,P_LC_BMI,RL_LC_BMI,RU_LC_BMI] = corrcoef( [ ( cell2mat( data_all_subjects( : , 5 ) ) - cell2mat( data_all_subjects( : , 6) ) ), cell2mat( data_all_subjects( : , 7) ) ] );

% Test if there are any correlations between regional hemispheric
% differences and age
[R_VTA_age,P_VTA_age,RL_VTA_age,RU_VTA_age] = corrcoef( [ ( cell2mat( data_all_subjects( : , 1 ) ) - cell2mat( data_all_subjects( : , 2 ) ) ), cell2mat( data_all_subjects( : , 8) ) ] );
[R_SN_age,P_SN_age,RL_SN_age,RU_SN_age] =  corrcoef( [ ( cell2mat( data_all_subjects( : , 3 ) ) - cell2mat( data_all_subjects( : , 4) ) ), cell2mat( data_all_subjects( : , 8) ) ] );
[R_LC_age,P_LC_age,RL_LC_age,RU_LC_age] = corrcoef( [ ( cell2mat( data_all_subjects( : , 5 ) ) - cell2mat( data_all_subjects( : , 6) ) ), cell2mat( data_all_subjects( : , 8) ) ] );

%% In case the masks needed padding to increase their dimensions, we need to save them.
% In order to save the file with the correct information, we copy info stored in the header of the QSM file
function WriteUpdatedMasks(mask_volume, mask_dir, mask_name, QSM_name)
    info_QSM = niftiinfo( QSM_name );
    info_mask = niftiinfo( strcat( mask_dir, mask_name ) );
    info_mask.ImageSize = size( mask_volume );
    info_mask.Description = 'Image size increased via zero padding to match that of the QSM file';
    %info_mask.raw_info.ImageSize = info_QSM.raw_info.ImageSize; % [3,181,217,181,1,1,1,1];
    info_mask.Datatype = 'double';
    info_mask.raw.qform_code = info_QSM.raw.qform_code;
    info_mask.raw.sform_code = info_QSM.raw.sform_code;
    info_mask.raw.qoffset_x = info_QSM.raw.qoffset_x;
    info_mask.raw.qoffset_y = info_QSM.raw.qoffset_y;
    info_mask.raw.qoffset_z = info_QSM.raw.qoffset_z;
    info_mask.raw.srow_x = info_QSM.raw.srow_x;
    info_mask.raw.srow_y = info_QSM.raw.srow_y;
    info_mask.raw.srow_z = info_QSM.raw.srow_z;
    info_mask.TransformName = info_QSM.TransformName;
    info_mask.Transform = info_QSM.Transform;
    niftiwrite( mask_volume, strcat(mask_dir,  'modified_', mask_name), info_mask );
end

%% When we're adjusting the images, we need to account for the origin of the mask
% WIP
function adjustments = CalculateOffsetAdjustment(mask_dir, mask_name, QSM_name, padding_amount)
    info_QSM = niftiinfo( QSM_name );
    info_mask = niftiinfo( strcat( mask_dir, mask_name ) );
    difference_X = abs(info_QSM.raw.qoffset_x - info_mask.raw.qoffset_x);
    difference_Y = abs(info_QSM.raw.qoffset_y - info_mask.raw.qoffset_y);
    difference_Z = abs(info_QSM.raw.qoffset_z - info_mask.raw.qoffset_z);
    adjustment_X = difference_X - padding_amount(1);
    adjustment_Y = difference_Y - padding_amount(2);
    adjustment_Z = difference_Z - padding_amount(3);
    adjustments = [adjustment_X, adjustment_Y, adjustment_Z];
end