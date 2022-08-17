clear all;
QSM_template_dir = '/data/pt_01923/TmpOut/QSM/for_debugging_pipeline/QSM_template/no_template_zero_rescaled_only_transform/';
name_prefix_template_files = ''; %'zero_rescaled_SY_FINAL_';
subject_list = [3];
% [1:4, 6:8, 11:23, 25:34, 36, 38:40, 42:46, 48:50, 101, 103:106, ...
%       108:109, 111, 113, 115:122, 124, 127, 130:133, 135:146, 148, 149];
cd( QSM_template_dir );
create_affine = true;
param_file_ext = '.mat'; %The options for the file extension are .txt and .mat
similarity_subjects_template = cell( length( subject_list ), 2 );

% Load the template (for similarity metric calculations)
template_name = strcat( name_prefix_template_files, '001_masked_rescaled_QSM.nii.gz' );
final_template = load_nifti( template_name );

for isub = 1:length( subject_list )
    subject = subject_list( isub );
    QSM_file_path = strcat( sprintf( '%03d', subject ), '_QSM_transformed.nii.gz' );
    output_name = strcat( 'affine_transformed_with_header_', sprintf( '%03d', subject ), '_QSM' );
    
    QSM = load_nifti( QSM_file_path );
    % Since Matlab is so poor at using wildcard characters to select files,
    % we first have to use 'dir' (which does use wildcards) to find the file,
    % and only after that open the file.
    found_affine_file = dir( strcat( name_prefix_template_files, 'affine_transform_', ...
        sprintf( '%03d', subject ), param_file_ext ) );
%     dir( strcat( name_prefix_template_files, sprintf( '%03d', subject ), ...
%         '_*Affine.txt' ) );
    
    squeezed_QSM = squeeze( QSM.vol );

    info_QSM = niftiinfo( QSM_file_path );
    
    if strcmp( param_file_ext, '.txt' )
        % Load the affine parameter file, with space as a separator and by
        % returning the numeric data 3 lines in.
        param_file = importdata( found_affine_file.name, ' ', 3 );
        save( strcat( 'affine_transform_', sprintf( '%03d', subject ), '.mat' ), 'param_file' );
        % Reshape the parameter matrix to have the right dimensions
        affine_params = [ reshape( param_file.data( 1, : ), 3, 4)', [0 0 0 1]' ];
    else
        param_file = load( found_affine_file.name, '-ascii' );
        template_fixed_coords = final_template.qform( 1:3, 4 );
        param_file( 1:3, 4 ) = template_fixed_coords;
        affine_params = param_file';
    end
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
    written_file = load_nifti( strcat( output_name, '.nii' ) );
    written_file.qform_code = 2;
    written_file.sform_code = 2;
    written_file.extents = 0;
    written_file.sform = written_file.qform;
    info_QSM.raw = written_file;
    niftiwrite( written_file.vol, 'rewritten_transformed_003_QSM', info_QSM );
    
    % Check how well the volumes overlap with the template
    similarity_subjects_template{ isub, 1 } = sprintf( '%03d', subject );
    similarity_subjects_template{ isub, 2 } = ssim( mri_warped, final_template.vol );
    
end