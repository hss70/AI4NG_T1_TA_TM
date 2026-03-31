clear;
% This script compiles the MATLAB code for the FBCSP training script
cd Code
disp('Compiling FBCSP_Training.m for Linux...')
profileFile = fullfile('..', 'Deployment', 'deployLocal.mlsettings');
% Clean previous build artifacts
if exist('../../ContainerCode/ClassifierTraining/output', 'dir')
    delete('../../ContainerCode/ClassifierTraining/output/*');
end
disp('Deleted previous build artifacts.')
% Compile the MATLAB code for the FBCSP training script
% Include Simulink models as additional files
if exist(profileFile, 'file')
    disp(['Including deployed parallel profile: ', profileFile])
    mcc -m FBCSP_Training.m -a ./Standard-10-20-Cap81.locs -a profileFile -d ../../ContainerCode/ClassifierTraining/output
else
    disp('No deployLocal.mlsettings file found. Building without bundled parallel profile.')
    mcc -m FBCSP_Training.m -a ./Standard-10-20-Cap81.locs -d ../../ContainerCode/ClassifierTraining/output
end

cd ..
disp('Complete')
