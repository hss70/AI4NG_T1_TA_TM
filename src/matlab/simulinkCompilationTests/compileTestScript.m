disp('Compiling the validate_compiled_output')
mcc -m validate_compiled_output.m -a ../sim_bandpass_singleBand.slx -a reference_output.mat -d output_dir
disp('Compilation done')