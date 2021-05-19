% Clear workspace variables
clear all;

% Initiate variables
QSM_dir =  '/data/pt_01923/TmpOut/QSM/for_debugging_pipeline/';%'/data/pt_01923/TmpOut/QSM/';
data_dir = '/data/p_01923/';
output_dir = '/data/pt_01923/TmpOut/QSM/for_debugging_pipeline/';
sepia_dir = '/data/hu_faengstroem/Scripts/QSM_analysis/sepia/';

cd( QSM_dir )

subject_list = [50];

% Select certain files from the directory

sub_dir = sprintf([QSM_dir, 'sub-%s', '/other/'], sprintf('050'));
sub_magn_file = dir( fullfile( sub_dir, ['memp2rage_wip900D_INV1_PHS*', '00005*', 'nii'] ) );
sub_phase_file = dir( fullfile( sub_dir, ['memp2rage_wip900D_UNI_DEN*', '00005*', 'nii'] ) );

% Select the sepia header
sepia_header = fullfile( QSM_dir, 'sepia_header.mat' );  %'sub_050_INV2_5_BET_mask/sepia_header.mat');

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
    'method', 'lbv',...
    'tol', 0.0100,...
    'depth', 5,...
    'peel', 2 ...
    );
qsm_params = struct(...
    'method', 'tkd',...
    'treshold', 0.1500 ...
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
    '',...
    sepia_header ...
    } );

SepiaIOWrapper( input_struct, output_dir, '', algorParams );

%%
%{
% Get the magnitude file
inputMagnNifti = load_untouch_nii( fullfile( sub_dir, sub_magn_file.name ) );
magn = load_nii_img_only( fullfile( sub_dir, sub_magn_file.name ) );
isMagnLoad = true;
disp('Magnitude data is loaded.');

% Get the phase file
inputPhaseNifti = load_untouch_nii( fullfile( sub_dir, sub_phase_file.name ) );
fieldMap = load_nii_img_only( fullfile( sub_dir, sub_phase_file.name ) );

if max(fieldMap(:))>4 || min(fieldMap(:))<-4
	disp('Converting phase data from DICOM image value to radian unit...')
	fieldMap = DICOM2Phase(inputPhaseNifti);

    disp('Saving phase images in unit of radian...');
    save_nii_quick(inputPhaseNifti,fieldMap, [output_dir 'phase.nii.gz']);

end
isPhaseLoad = true;
disp('Phase data is loaded.')

% Load the sepia header
sepia_header = fullfile( QSM_dir, 'sepia_header.mat' );  %'sub_050_INV2_5_BET_mask/sepia_header.mat');
load( sepia_header );
disp('Header data is loaded.');

% store the header of the NIfTI files, all following results will have
% the same header
outputNiftiTemplate = inputMagnNifti;

% Validate the loaded input
CheckInputDimension(magn,fieldMap,matrixSize,TE);
%}
