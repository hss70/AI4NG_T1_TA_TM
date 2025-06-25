% This script compiles the MATLAB code for the FBCSP training script
cd Code
% Compile the MATLAB code for the FBCSP training script
mcc -m FBCSP_Training.m -a ./Standard-10-20-Cap81.locs -d ../../ContainerCode/ClassifierTraining/output