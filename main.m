% ToDo: Implement A popup dialog box for inputting the method parameters

% Clear workspace variables
clear all;

% Initiate variables
QSM_dir =  '/data/pt_01923/TmpOut/QSM/for_debugging_pipeline/';%'/data/pt_01923/TmpOut/QSM/';
data_dir = '/data/pt_01923/TmpOut/final_script/Nifti/';
output_main_dir = '/data/pt_01923/TmpOut/QSM/for_debugging_pipeline/output/';
sepia_dir = '/data/hu_faengstroem/Scripts/QSM_analysis/sepia/';
script_dir = '/data/hu_faengstroem/Scripts/QSM_analysis/QSM_pipeline/';

cd( QSM_dir )

% sepia_addpath('bet');
% call_fsl_dir = '/afs/cbs.mpg.de/software/fsl/6.0.3/ubuntu-bionic-amd64/etc/matlab/';

subject_list = [40];

% iterations_of_parameters = 5;

lambda_values = [0.08];

tolerance_values = [0.00000000001]; %[0.001, 0.0001, 0.0005, 0.01];

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
    output_dir = strcat( output_main_dir, sprintf( '%03d', subject ), '_UNI_DEN_05/' );

    sub_dir = sprintf([data_dir, 'sub-%s', '/ses-1/other/'], sprintf( '%03d', subject ));
    sub_anat_dir = sprintf([data_dir, 'sub-%s', '/ses-1/anat/'], sprintf( '%03d', subject ));
    sub_phase_file = dir( fullfile( sub_dir, ['memp2rage_wip900D_INV2_PHS*', '00005*', 'nii'] ) );
    sub_magn_file = dir( fullfile( sub_dir, ['memp2rage_wip900D_UNI_DEN*', '00005*', 'nii'] ) ); %dir( fullfile( sub_anat_dir, ['*T1w*', 'nii'] ) ); %

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
        
        for itol = 1:length( tolerance_values )
            
            tol = tolerance_values( itol ); 
            
            % @todo find all variables that relate to a changed parameter
            % value and use the names and values of those (in each loop) to
            % dynamically create a descriptive folder name.
            sublevel_output_dir = strcat( output_dir, QSM_method, '_lambda', ...
                sprintf( '%03d', lambda ), '_tol_', sprintf( '%05d', tol ), '/' );

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
%             
%             qsm_params = struct(...
%                'method', 'ilsqr',...
%                'tol', tolerance,...
%                'maxiter', 100,...
%                'lambda', lambda,...
%                'optimise', 0 ... %'treshold', 0.1500 ...
%                );
%             qsm_params = struct(...
%                 'method', 'medi_l1',...
%                 'lambda', lambda,...
%                 'isLambdaCSF', 0, ...
%                 'lambda_CSF', 100, ...
%                 'smv', 0, ...
%                 'radius', 5, ...
%                 'zeropad', 0, ...
%                 'wData', 1, ...
%                 'merit', 0, ...
%                 'gradient_weighting', 1 ...
%                 );
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
    
end


% Comment