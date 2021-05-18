function CheckInputDimension(magn,phase,matrixSize,TE)
% check spatial dimension
for ndim = 1:3
    if size(magn,ndim) ~= matrixSize(ndim)
        error(['The ' num2str(ndim) 'st/nd/rd dimension of the magnitude data does not match with the header information']);
    end
    if size(phase,ndim) ~= matrixSize(ndim)
        error(['The ' num2str(ndim) 'st/nd/rd dimension of the phase data does not match with the header information']);
    end
end

% check echo time
if size(magn,4) ~= length(TE)
    error('The no. of echo in the magnitude data does not match with the header infomation');
end
if size(phase,4) ~= length(TE)
    error('The no. of echo in the phase data does not match with the header infomation');
end
if size(phase,4) ~= size(magn,4)
    error('The no. of echo in the magnitude data does not match with that of the phase data');
end

end
