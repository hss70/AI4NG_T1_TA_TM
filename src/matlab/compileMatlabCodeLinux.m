% This script compiles the MATLAB code for the FBCSP training script
cd Code
disp('Compiling FBCSP_Training.m for Linux...')
% Clean previous build artifacts
if exist('../../ContainerCode/ClassifierTraining/output', 'dir')
    delete('../../ContainerCode/ClassifierTraining/output/*');
end
disp('Deleted previous build artifacts.')
% Compile the MATLAB code for the FBCSP training script
% Include Simulink models as additional files
mcc -m FBCSP_Training.m -a ./Standard-10-20-Cap81.locs -a sim_bandpass_singleBand.slx -d ../../ContainerCode/ClassifierTraining/output
%copyfile('sim_bandpass_singleBand.slx', '../../ContainerCode/ClassifierTraining/output/sim_bandpass_singleBand.slx');
cd ..
disp('Complete')