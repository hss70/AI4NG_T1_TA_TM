% compile_reference_signal.m
% Reference test for bandpass Simulink model using SimulationInput
cd ..
clear; clc;

disp("📦 Generating reference output from sim_bandpass_singleBand using SimulationInput...");

%% Parameters
Fs = 125;
T = 1/Fs;
L = 1000;
t = (0:L-1)' * T;

% 10Hz test signal (within alpha band)
signal = sin(2*pi*10*t) + 0.3*randn(size(t));
ts = timeseries(signal, t);
stopTime = t(end);  % ⏱ Match last time point of the input

%% Parameter structure
sm.p.EEG.sr = Fs;
sm.p.EEG.FFT.wSize = 32;
sm.p.EEG.band(1).low1 = 8;
sm.p.EEG.band(1).low2 = 9;
sm.p.EEG.band(1).high1 = 11;
sm.p.EEG.band(1).high2 = 12;
sm.p.EEG.band_pass_dB = 1;
sm.p.EEG.band_stop_dB = 60;

%% Simulink setup
modelName = 'sim_bandpass_singleBand';
load_system(modelName);

in = Simulink.SimulationInput(modelName);
in = in.setExternalInput(ts);
in = in.setVariable('sm', sm);
in = in.setModelParameter('SimulationMode', 'normal');
in = in.setModelParameter('StopTime', num2str(stopTime));

% Run simulation
disp("🚀 Running simulation...");
simOut = sim(in);
filtered = simOut.get('yout');

cd simulinkCompilationTests/

% Save input, output, and struct to .mat file for later comparison
referenceFile = fullfile(pwd, 'reference_output.mat');
save(referenceFile, 'filtered', 'signal', 't', 'sm');

disp("✅ Reference output saved to:");
disp(referenceFile);
