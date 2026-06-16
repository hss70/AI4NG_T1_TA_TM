% Clear
clear; clc; close all;

%% Parameters
Fs = 125;                     % Sampling rate
T = 1/Fs;                     % Sampling period
L = 1000;                     % Length of signal (samples)
t = (0:L-1)' * T;             % Time vector

%% Create EEG-like signal
signal = sin(2*pi*10*t);      % 10 Hz sine wave (alpha band)
signal = signal + 0.5*randn(size(signal));  % Add noise

%% Build the sm structure
sm.p.EEG.sr = Fs;
sm.p.EEG.FFT.wSize = 32;  % Example window size
sm.p.EEG.band(1).low1 = 8;
sm.p.EEG.band(1).low2 = 9;
sm.p.EEG.band(1).high1 = 11;
sm.p.EEG.band(1).high2 = 12;
sm.p.EEG.band_pass_dB = 1;
sm.p.EEG.band_stop_dB = 60;

%% ------------------------
%% Method 1: From Workspace
%% ------------------------
assignin('base', 'sm', sm);
assignin('base', 'sm_EEG_data', signal);  % signal variable must be in base workspace

disp("Running model_from_workspace...");
load_system('original_sim_bandpass_singleBand');
simOut1 = sim('original_sim_bandpass_singleBand','ReturnWorkspaceOutputs', 'on');
out1 = simOut1.get('Bandpass_singleBand');

%% ------------------------
%% Method 2: Inport + SimulationInput
%% ------------------------

% Convert signal to timeseries for external input
ts = timeseries(signal, t);

% Set up SimulationInput
modelName = 'sim_bandpass_singleBand';
load_system('sim_bandpass_singleBand');
in = Simulink.SimulationInput(modelName);
in = in.setExternalInput(ts);    % Signal
in = in.setVariable('sm', sm);   % Parameters

disp("Running model_inport...");
disp('Running sim_bandpass_singleBand.slx...');
simOut2 = sim(in);
out2 = simOut2.get('Bandpass_singleBand');

%% ------------------------
%% Plot Comparison
%% ------------------------

figure;
subplot(2,1,1);
plot(out1); title('Output: From Workspace');
xlabel('Time (samples)'); ylabel('Amplitude'); grid on;

subplot(2,1,2);
plot(out2); title('Output: Inport + SimulationInput');
xlabel('Time (samples)'); ylabel('Amplitude'); grid on;

sgtitle('Comparison of Input Methods');

%% Difference Plot
figure;
diffSignal = out1 - out2;

subplot(2,1,1);
plot(diffSignal);
title('Difference Between Outputs (out1 - out2)');
xlabel('Time (samples)'); ylabel('Amplitude Difference');
grid on;

subplot(2,1,2);
plot(abs(diffSignal));
title('Absolute Error Between Outputs');
xlabel('Time (samples)'); ylabel('|Difference|');
grid on;

sgtitle('Error Analysis Between Input Methods');

%% Compute Error Metrics
rmse = sqrt(mean(diffSignal.^2));
max_error = max(abs(diffSignal));

fprintf('\n✅ RMSE: %.6f\n', rmse);
fprintf('✅ Max Absolute Error: %.6f\n', max_error);