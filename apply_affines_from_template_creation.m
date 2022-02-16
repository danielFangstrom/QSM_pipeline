clear all;
QSM_template_dir = '/data/pt_01923/TmpOut/QSM/for_debugging_pipeline/QSM_template/zero_rescaled_improved_masks_SY/';
name_prefix_template_files = 'zero_rescaled_SY_FINAL_';
subject_list = [1:4, 6:8, 11:23, 25:34, 36, 38, 39, 42:46, 48:50, 101, 103:106, ...
      108:109, 111, 113, 115:122, 124, 127, 130:133, 135:146, 148, 149];
cd( QSM_template_dir );
create_affine = true;
similarity_subjects_template = cell( length( subject_list ), 2 );

% Load the template (for similarity metric calculations)
template_name = strcat( name_prefix_template_files, 'template0.nii.gz' );
final_template = load_nifti( template_name );

for isub = 1:length( subject_list )
    subject = subject_list( isub );
    QSM_file_path = strcat( '../', sprintf( '%03d', subject ), '_QSM.nii.gz' );
    output_name = strcat( 'affine_transformed_with_header_', sprintf( '%03d', subject ), '_QSM' );
    
    QSM = load_nifti( QSM_file_path );
    % Since Matlab is so poor at using wildcard characters to select files,
    % we first have to use 'dir' (which does use wildcards) to find the file,
    % and only after that open the file.
    found_affine_file = dir( strcat( name_prefix_template_files, sprintf( '%03d', subject ), ...
        '_*Affine.txt' ) );
    
    squeezed_QSM = squeeze( QSM.vol );

    info_QSM = niftiinfo( QSM_file_path );
    % Load the affine parameter file, with space as a separator and by
    % returning the numeric data 3 lines in.
    param_file = importdata( found_affine_file.name, ' ', 3 );
    save( strcat( 'affine_transform_', sprintf( '%03d', subject ), '.mat' ), 'param_file' );
    % Reshape the parameter matrix to have the right dimensions
    affine_params = [ reshape( param_file.data( 1, : ), 3, 4)', [0 0 0 1]' ];
    % Create the affine transform object
    tform = affine3d( affine_params );

    % Create the transformed MRI (use the size of the original volume to
    % get the right dimensions on the output).
    [mri_warped, s_left_over] = imwarp( squeezed_QSM, tform, 'OutputView', imref3d( size( QSM.vol ) ) );

    % Save the info on the original QSM file and change the type to
    % 'double'
    info_QSM.Datatype = 'double';
    info_QSM.Transform = tform;
    info_QSM.TransformName = 'Qform';

    niftiwrite( mri_warped, output_name, info_QSM );
    
    % Check how well the volumes overlap with the template
    similarity_subjects_template{ isub, 1 } = sprintf( '%03d', subject );
    similarity_subjects_template{ isub, 2 } = ssim( mri_warped, final_template.vol );
    
end