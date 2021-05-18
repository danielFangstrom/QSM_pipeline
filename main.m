% Initiate variables
QSM_dir = '/data/pt_01923/TmpOut/QSM/';
data_dir = '/data/p_01923/';
output_dir = '/data/pt_01923/TmpOut/QSM/for_debugging_pipeline/';
sepia_dir = '/data/hu_faengstroem/Scripts/QSM_analysis/sepia/';

cd( QSM_dir )

subject_list = [50];

% Select certain files from the directory

sub_dir = sprintf([QSM_dir, 'sub-%s', '/other/'], sprintf('050'));
sub_magn_file = dir( fullfile( sub_dir, ['memp2rage_wip900D_INV1_PHS*', '00005*', 'nii'] ) );
sub_phase_file = dir( fullfile( sub_dir, ['memp2rage_wip900D_UNI_DEN*', '00005*', 'nii'] ) );

% Load sepia path and necessary scripts
addpath( genpath( sepia_dir ) );
sepia_addpath

% Get the magnitude file
inputMagnNifti = load_untouch_nii( fullfile( sub_dir, sub_magn_file ) );
magn = load_nii_img_only( fullfile( sub_dir, sub_magn_file ) );
isMagnLoad = true;
disp('Magnitude data is loaded.');

% Get the phase file
inputPhaseNifti = load_untouch_nii( fullfile( sub_dir, sub_phase_file) );
fieldMap = load_nii_img_only( fullfile( sub_dir, sub_phase_file) );

if max(fieldMap(:))>4 || min(fieldMap(:))<-4
	disp('Converting phase data from DICOM image value to radian unit...')
	fieldMap = DICOM2Phase(inputPhaseNifti);

    disp('Saving phase images in unit of radian...');
    save_nii_quick(inputPhaseNifti,fieldMap, [outputDir filesep prefix 'phase.nii.gz']);

end
isPhaseLoad = true;
disp('Phase data is loaded.')

% Load the sepia header
load([inputNiftiList(4).name]);
disp('Header data is loaded.');