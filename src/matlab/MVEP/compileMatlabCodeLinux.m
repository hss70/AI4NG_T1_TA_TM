
clear;
% This script compiles the MATLAB code for the FBCSP training script
cd Code
disp('Compiling mVEP_optimise_nosplit_flexEEG_2026v_basic.m for Linux...')
% Clean previous build artifacts
if exist('../../../ContainerCode/MVEPClassifierTraining/output', 'dir')
    delete('../../../ContainerCode/MVEPClassifierTraining/output/*');
end
disp('Deleted previous build artifacts.')
% Compile the MATLAB code for the FBCSP training script
% Include Simulink models as additional files
mcc -m mVEP_optimise_nosplit_flexEEG_2026v_basic.m -d ../../../ContainerCode/MVEPClassifierTraining/output

cd ..
disp('Complete')