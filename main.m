% Initiate variables
QSM_dir = '/data/pt_01923/TmpOut/QSM/';
data_dir = '/data/p_01923/';
output_dir = '/data/pt_01923/TmpOut/QSM/for_debugging_pipeline/';
sepia_dir = '/data/hu_faengstroem/Scripts/QSM_analysis/sepia/';

cd( QSM_dir )

subject_list =[109];

% Select certain files from the directory
% Load them into a variable

% Get the magnitude file
inputMagnNifti = load_untouch_nii();
magn = load_nii_img_only();
isMagnLoad = true;
disp('Magnitude data is loaded.');

% Get the phase file
inputPhaseNifti = load_untouch_nii();
fieldMap = load_nii_img_only();

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