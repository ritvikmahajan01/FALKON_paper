% Script to permanently add MSYS64 and FALKON paths to MATLAB
% This only needs to be run once

% Get the current directory
current_dir = pwd;

% Add FALKON directory to MATLAB path permanently
addpath(genpath(fullfile(current_dir, '..', 'FALKON')));
savepath;  % Save the path for future MATLAB sessions

% Add MSYS64 to system path
msys64_path = 'C:\msys64\mingw64\bin';
if ~contains(getenv('PATH'), msys64_path)
    setenv('PATH', [getenv('PATH') ';' msys64_path]);
    disp('Added MSYS64 to system path. You may need to restart MATLAB for changes to take effect.');
end

% Configure MEX to use MinGW-w64
mex -setup C++

% Compile the required C++ files
cd('../FALKON');
mex -largeArrayDims tri_solve_d.cpp
mex -largeArrayDims inplace_chol.cpp

% Return to original directory
cd('../Experiments');

disp('Setup complete! You can now run function_estimation_test.m directly.'); 