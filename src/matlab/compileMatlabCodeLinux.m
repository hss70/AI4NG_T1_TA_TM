% This script compiles the MATLAB code for the FBCSP training script
cd Code
% Clean previous build artifacts
delete('../../ContainerCode/ClassifierTraining/output/*');
% Compile the MATLAB code for the FBCSP training script
mcc -m FBCSP_Training.m -a ./Standard-10-20-Cap81.locs -d ../../ContainerCode/ClassifierTraining/outputCode