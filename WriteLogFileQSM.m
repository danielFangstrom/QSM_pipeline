function log_file_name = WriteLogFileQSM( input_struct, subject_output_dir, mask_name, algorParams )
log_file_name = [subject_output_dir filesep 'QSM_pipeline_log.m'];
if exist( subject_output_dir, 'dir' ) ~= 7
    mkdir( subject_output_dir )
end
if exist(log_file_name,'file') == 2
    counter = 1;
    while exist(log_file_name,'file') == 2
        suffix = ['_' num2str(counter)];
        log_file_name = [subject_output_dir filesep 'QSM_pipeline_log' suffix '.m'];
        counter = counter + 1;
    end
end
fid = fopen(log_file_name,'w');

if isfield( algorParams, 'error' )
    fprintf( fid, 'The script encountered an error: ''%s'' in %s line %d;\n\n\n', ...
        algorParams.error.message, algorParams.error.stack(1,1).name, algorParams.error.stack(1,1).line);
    % fprintf(fid,'Cause: ''%s'' ;\n', algorParams.error.cause);
    for i = 1:length( algorParams.error.stack )
        fprintf(fid,'Error in ''%s'' ;\n', algorParams.error.stack(i).file );
        fprintf(fid,'In line ''%i'' ;\n', algorParams.error.stack(i).line );
    end
    fprintf(fid,'\n\n\n');
end

% Input data
if isstruct(input_struct)
    fprintf(fid,'Phase image: ''%s'' ;\n',input_struct(1).name);
    fprintf(fid,'Magnitude image: ''%s'' ;\n',input_struct(2).name);
    fprintf(fid,'Weights file: ''%s'' ;\n',input_struct(3).name);
    fprintf(fid,'Sepia header: ''%s'' ;\n',input_struct(4).name);
else
    fprintf(fid,'subject_output_dir = ''%s'' ;\n',subject_output_dir);
end

% Output name
fprintf(fid,'mask_filename = [''%s''] ;\n\n',mask_name);

% Mask
fprintf(fid,'subject_output_dir = [''%s''] ;\n\n',subject_output_dir);

% Phase unwrapping parameters

fprintf(fid,'algorParam.unwrap.unwrapMethod = ''%s'' ;\n', ...
    algorParams.unwrap.unwrapMethod );
fprintf(fid,'algorParam.unwrap.echoCombMethod = ''%s'' ;\n', ...
    algorParams.unwrap.echoCombMethod );
fprintf(fid,'algorParam.unwrap.isEddyCorrect = ''%i'' ;\n', ...
    algorParams.unwrap.isEddyCorrect );
fprintf(fid,'algorParam.unwrap.excludeMaskThreshold = ''%s'' ;\n', ...
    algorParams.unwrap.excludeMaskThreshold );

% Background field removal parameters
fprintf(fid,'%% Background field removal algorithm parameters\n');
fprintf(fid,'algorParam.bfr.method = ''%s'' ;\n', ...
    algorParams.bfr.method);
fprintf(fid,'algorParam.bfr.refine = %i ;\n', ...
    algorParams.bfr.refine);
% Erode local field
fprintf(fid,'algorParam.bfr.erode_radius = %i ;\n', ...
    algorParams.bfr.erode_radius);

fprintf(fid,'algorParam.bfr.radius = %i ;\n', ...
    algorParams.bfr.radius);
fprintf(fid,'algorParam.bfr.lambda = %i ;\n', ...
    algorParams.bfr.alpha);

% QSM parameters
fprintf(fid,'%% QSM algorithm parameters\n');

QSM_fieldnames = fieldnames( algorParams.qsm );
for i = 1:size( struct2table( algorParams.qsm  ), 2 )
    current_value = algorParams.qsm.( QSM_fieldnames{ i } );
    if isnumeric( current_value )
        fprintf( fid, '%s = %d', QSM_fieldnames{ i }, current_value );
    else
        fprintf( fid, '%s = %s', QSM_fieldnames{ i }, current_value );
    end
end

fclose(fid);

% run(log_file_name);
        
end