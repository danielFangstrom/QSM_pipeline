% This script takes the files that will be used for QSM analysis and runs
% all three steps (phase unwrapping. background field
% removal, and the QSM field-to-source inversion) via the sepia toolbox.

% Clear workspace variables
clear all;

% Initiate variables
QSM_dir =  '/data/pt_01923/TmpOut/QSM/QSM_pipeline/';
data_dir = '/data/pt_01923/TmpOut/final_script/Nifti/';
output_main_dir = '/data/pt_01923/TmpOut/QSM/QSM_pipeline/output/';
sepia_dir = '/data/hu_faengstroem/Scripts/QSM_analysis/sepia/';
script_dir = '/data/hu_faengstroem/Scripts/QSM_analysis/QSM_pipeline/';

cd( QSM_dir )

subject_list = [1:5, 6:8, 11:23, 25:34, 36, 38, 39, 42:46, 48:50, 101, 103:109, ...
       111:113, 115:116, 118:122, 124, 127, 129:133, 135:139, 141:146, 148, 149];

% Specify the QSM method and the parameters (an array can be used, which
% causes the process to be run once with each value/value combination)

lambda_values = [0.08]; %[0.008, 0.03, 0.05, 0.06, 0.1, 0.12, 0.15];

tolerance_values = [0.0001]; %[0.001, 0.0001, 0.0005, 0.01];

QSM_method = 'ilsqr';

% Loads the preset parameters of the selected variable into the workspace
% (as the variable 'qsm_params')
load( strcat( script_dir, '/Preset_QSM_method_parameters/', QSM_method, '.mat' ) );

% Here one can change the value of the freshly loaded parameters, if one
% wishes to. E.g.:
% qsm_params.optimise = 1;
% 
% Alternatively, one can loop over a range of values. The only thing needed
% is supplying a list of values, creating a for-loop and setting the 
% name of that parameter to the exact name of the parameter in the
% qsm_params struct, and setting that created variable to be the current
% value of the incremental one. The mechanism below finds the variable and
% sets it in the qsm_params struct automatically.

for isub = 1:length( subject_list )

    % Select certain files from the directory
    subject = subject_list( isub );
    fprintf( 'Processing subject %i\n', subject);
    % The output directory can be changed according to whatever format one
    % wishes to use
    output_dir = strcat( output_main_dir, sprintf( '%03d', subject ), '_INV2_mag_preproc_brain_phase_05/' );

    sub_dir = sprintf([data_dir, 'sub-%s', '/ses-1/other/'], sprintf( '%03d', subject ));
    sub_anat_dir = sprintf([data_dir, 'sub-%s', '/ses-1/anat/'], sprintf( '%03d', subject ));
    sub_phase_file = dir( fullfile( sub_dir, ['memp2rage_wip900D_INV2_PHS*', '_00005*', 'nii'] ) );
    sub_magn_file = dir( fullfile( strcat( output_main_dir, 'Masks/Masks_from_INV2_mag/' ) , ...
        [ sprintf( '%03d', subject ), '_INV2.nii' ] ) ); 

    % Select the sepia header
    sepia_header = fullfile( QSM_dir, 'sepia_header.mat' );  
    
    % Create the brain mask by using BET
    % Easy way: use BET with f = 0.55 and g = -0.35
    % mask = BET(magn(:,:,:,1),matrixSize,voxelSize);
    % If/When that doesn't work, note down all subjects that
    % produce funky results and go through them manually.
    % If there are too many funky ones, consider creating a mask for each
    % participant. Dynamically creating a good mask for each participant is
    % most likely too much work.
    sub_mask_file = dir( fullfile( strcat( output_main_dir, 'Masks/Masks_from_preproc/' ) , ...
        [ sprintf( '%03d', subject ), '*mask.nii.gz' ] ) );
    
    mask = strcat( sub_mask_file.folder, '/', sub_mask_file.name);
    
    for ival = 1:length( lambda_values )
        
        lambda = lambda_values( ival );
        
        for itol = 1:length( tolerance_values )
            
            tol = tolerance_values( itol ); 
            
            % @todo find all variables that relate to a changed parameter
            % value and use the names and values of those (in each loop) to
            % dynamically create a descriptive folder name.

            % Creates an output directory based on the methods for
            % background field removal and QSM, as well as the parameters
            % used (the unwrapping is not included as it is usually fairly
            % simple and rarely a reason to use anything other than
            % the Laplacian).
            % The names of the background field removal method and the
            % parameters are hardcoded but can easily be changed to a
            % dynamic version.
            sublevel_output_dir = strcat( output_dir, 'resharp_alpha_021_radius_4_', QSM_method, '__lambda', ...
                sprintf( '%03d', lambda ), '_tol_', sprintf( '%05d', tol ), '/' );

            %% Initialize the algorithm parameters
            % The general parameters set whether or not to use BET to
            % create a mask, whether the main magnetic field is inverted,
            % or whether to use GPU for the the processing. More info in the
            % sepia documentation (regarding general parameters and step
            % specific parameters).
            general_params = struct(...
                'isBET', 0,...
                'isInvert', 0,...
                'isGPU', 0 ...
                );
            % The parameters for the phase unwrapping step. We use
            % laplacian.
            unwrap_params = struct(...
                'echoCombMethod', 'Optimum weights',...
                'unwrapMethod', 'laplacian',...
                'isEddyCorrect', 0,...
                'excludeMaskThreshold', Inf...
                );
            % The parameters for the background field removal step
            background_field_removal_params = struct(...
                'refine', 1,...
                'erode_radius', 0,...
                'method', 'resharp',...
                'radius', 4,...
                'alpha', 0.21 ...
                );
            % In this block, 'lambda' and 'tolerance' changes values for
            % each loop and are thus replacing the default values, but one
            % can change it as needed.
            %qsm_params.lambda = lambda;
            %qsm_params.tol = tolerance;
            
            % This finds variables in the workspace that have the same name
            % as the ones that are set as the qsm parameters, and sets the
            % qsm_params field with that value. This means, any variable
            % that is changed and looped over will dynamically be set
            % without explicitly having to write that down.
            qsm_fieldnames = fieldnames( qsm_params );
            changed_qsm_parameters = who (qsm_fieldnames{:});
            
            for iparam = 1:length( changed_qsm_parameters )
                param_field = changed_qsm_parameters{iparam};
                param_value = evalin( 'base', param_field );
                qsm_params.( param_field ) = param_value;
            end

            % Create the overall structure that contains the parameters for
            % each step
            algorParams = struct(...
                'general', general_params,...
                'unwrap', unwrap_params,...
                'bfr', background_field_removal_params,...
                'qsm', qsm_params ...
                );

            % Load sepia path and necessary scripts
            addpath( genpath( sepia_dir ) );
            sepia_addpath

            % Create the structure containing the main parameters for sepia
            % (the phase file, the magnitude file, and the sepia header)
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
    
end

% @ToDo: Implement A popup dialog box for inputting the method parameters