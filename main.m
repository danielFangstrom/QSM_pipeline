% ToDo: Implement A popup dialog box for inputting the method parameters

% Clear workspace variables
clear all;

% Initiate variables
QSM_dir =  '/data/pt_01923/TmpOut/QSM/for_debugging_pipeline/';%'/data/pt_01923/TmpOut/QSM/';
data_dir = '/data/pt_01923/TmpOut/final_script/Nifti/';
output_main_dir = '/data/pt_01923/TmpOut/QSM/for_debugging_pipeline/output/';
sepia_dir = '/data/hu_faengstroem/Scripts/QSM_analysis/sepia/';

cd( QSM_dir )

% sepia_addpath('bet');
% call_fsl_dir = '/afs/cbs.mpg.de/software/fsl/6.0.3/ubuntu-bionic-amd64/etc/matlab/';

subject_list = [26:30, 33:34, 36, 38:40];

% iterations_of_parameters = 5;

lambda_values = [0.06]; %[0.03, 0.04, 0.06, 0.07 ];

for isub = 1:length( subject_list )

    % Select certain files from the directory
    subject = subject_list( isub );
    output_dir = strcat( output_main_dir, sprintf( '%03d', subject ), '/' );

    sub_dir = sprintf([data_dir, 'sub-%s', '/ses-1/other/'], sprintf( '%03d', subject ));
    sub_phase_file = dir( fullfile( sub_dir, ['memp2rage_wip900D_INV2_PHS*', '00005*', 'nii'] ) );
    sub_magn_file = dir( fullfile( sub_dir, ['memp2rage_wip900D_UNI_DEN*', '00005*', 'nii'] ) );

    % Select the sepia header
    sepia_header = fullfile( QSM_dir, 'sepia_header.mat' );  %'sub_050_INV2_5_BET_mask/sepia_header.mat');
    
    % Create the brain mask by using BET
    % Easy way: use BET with f = 0.55 and g = -0.35
    % mask = BET(magn(:,:,:,1),matrixSize,voxelSize);
    % If/When that doesn't work, note down all subjects that
    % produce funky results and go through them manually.
    % If there are too many funky ones, consider creating a mask for each
    % participant. Dynamically creating a good mask for each participant is
    % most likely too much work.
    sub_mask_file = dir( fullfile( strcat( output_main_dir, 'Masks/' ) , ...
        ['*', sprintf( '%03d', subject ), '*mask.nii.gz'] ) );
    
    mask = strcat( sub_mask_file.folder, '/', sub_mask_file.name);
    
    for ival = 1:length( lambda_values )
        
        lambda = lambda_values( ival );
        sublevel_output_dir = strcat( output_dir, 'ilsqr_lambda_', sprintf( '%03d', lambda ), '/' );

        % Initialize the algorithm parameters
        general_params = struct(...
            'isBET', 0,...
            'isInvert', 0,...
            'isGPU', 0 ...
            );
        unwrap_params = struct(...
            'echoCombMethod', 'Optimum weights',...
            'unwrapMethod', 'laplacian',...
            'isEddyCorrect', 0,...
            'excludeMaskThreshold', Inf...
            );
        background_field_removal_params = struct(...
            'refine', 1,...
            'erode_radius', 0,...
            'method', 'resharp',...
            'radius', 4,...
            'alpha', 0.01 ...
            );
        qsm_params = struct(...
            'method', 'ilsqr',...
            'tol', 0.001,...
            'maxiter', 100,...
            'lambda', lambda,...
            'optimise', 0 ... %'treshold', 0.1500 ...
            );
        algorParams = struct(...
            'general', general_params,...
            'unwrap', unwrap_params,...
            'bfr', background_field_removal_params,...
            'qsm', qsm_params ...
            );

        % Load sepia path and necessary scripts
        addpath( genpath( sepia_dir ) );
        sepia_addpath

        input_struct = struct(...
            'name', {...
            strcat( sub_phase_file.folder, '/', sub_phase_file.name),...
            strcat( sub_magn_file.folder, '/', sub_magn_file.name),...
            '', ...
            sepia_header ...
            } );

        try
            SepiaIOWrapper( input_struct, sublevel_output_dir, mask, algorParams );
        
            % Create log-file
            log_file = WriteLogFileQSM( input_struct, sublevel_output_dir, mask, algorParams );
            
        catch SepiaException
            algorParams.error = SepiaException;
            % Create log-file with the error
            log_file = WriteLogFileQSM( input_struct, sublevel_output_dir, mask, algorParams );
        end
    end
    
end


% Comment