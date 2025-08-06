% Refactored Parallel Bandpass Filter Test Suite
% ======================================================
% This script tests a Simulink-based and MATLAB-based
% bandpass filter across multiple conditions in parallel:
% - Frequency/amplitude sweep
% - Edge cases (on 125 Hz only)
% - Different sample rates
% ======================================================

clear; clc; close all;

%% Configuration
sampleRates = [50, 75, 125, 250];
signalLength = 1000;                   % Samples
tolerance = 1e-14;                      % Error threshold

% Frequencies & amplitudes to test
allFreqs = [2, 5, 10, 15, 20, 30, 40, 50, 60, 80, 100];
testAmps  = [0.5, 1, 2];

% Ensure 125 Hz is included for edge cases
if ~ismember(125, sampleRates)
    error('125 Hz must be included in sampleRates for edge case testing.');
end

% Preload Simulink model
load_system('original_sim_bandpass_singleBand');

%% === Build All Test Cases ===
testCases = {};

for Fs = sampleRates
    T = 1/Fs;
    t = (0:signalLength-1)' * T;
    nyquistLimit = Fs / 2;
    validFreqs = allFreqs(allFreqs < nyquistLimit);

    % Frequency / Amplitude Sweep
    for f = validFreqs
        for A = testAmps
            signal = A * sin(2*pi*f*t) + 0.3*randn(size(t));
            label = sprintf('SR: %3d | Freq: %3d | Amp: %.1f', Fs, f, A);
            sm = buildSM(Fs, f);
            testCases{end+1} = struct('label', label, 'signal', signal, 't', t, 'sm', sm); %#ok<SAGROW>
        end
    end

    % Chirp test (for all Fs)
    chirpSignal = chirp(t, 1, t(end), Fs/2);
    label = sprintf('SR: %3d | Chirp Test', Fs);
    sm = buildSM(Fs, 10);
    testCases{end+1} = struct('label', label, 'signal', chirpSignal, 't', t, 'sm', sm);

    % Edge cases (only for 125 Hz)
    if Fs == 125
        edgeCases = {
            struct('name', 'Impulse Test',     'signal', [1; zeros(signalLength-1,1)])
            struct('name', 'Step Test',        'signal', ones(signalLength,1))
            struct('name', 'Zeros Test',       'signal', zeros(signalLength,1))
            struct('name', 'NaNs Test',        'signal', [nan; randn(signalLength-1,1)])
            struct('name', 'Flat High Test',   'signal', ones(signalLength,1)*1000)
            struct('name', 'Flat Low Test',    'signal', ones(signalLength,1)*-1000)
        };

        for k = 1:numel(edgeCases)
            sm = buildSM(Fs, 10);
            label = sprintf('SR: %      \x2192 3d | %s', Fs, edgeCases{k}.name);
            testCases{end+1} = struct('label', label, 'signal', edgeCases{k}.signal, 't', t, 'sm', sm);
        end
    end
end

%% === Execute in Parallel ===
fprintf('\n Run Tests...\n');
nTests = numel(testCases);
results = repmat(struct('label','', 'pass', false, 'rmse', NaN, 'maxErr', NaN), nTests, 1);

for i = 1:nTests
    tc = testCases{i};
    [pass, rmse, maxErr] = runTestPar(tc.signal, tc.t, tc.sm, tc.label, tolerance);
    results(i).label = tc.label;
    results(i).pass = pass;
    results(i).rmse = rmse;
    results(i).maxErr = maxErr;
end

%% === Summary ===
totalTests = nTests;
passedTests = sum([results.pass]);
failedTests = totalTests - passedTests;

fprintf('\nAll tests complete.\n');
fprintf('\nSummary of all tests:\n');
fprintf(' ----------------------\n');
fprintf(' Passed: %d\n', passedTests);
fprintf(' Failed: %d\n', failedTests);
fprintf(' Total:  %d\n\n', totalTests);

%% === Helper Functions ===
function sm = buildSM(Fs, centerFreq)
    low1  = max(centerFreq - 2, 0.1);
    low2  = max(centerFreq - 1, low1 + 0.1);
    high1 = min(centerFreq + 1, Fs/2 - 2);
    high2 = max(min(centerFreq + 2, Fs/2 - 0.1), high1 + 0.1);

    sm.p.EEG.sr = Fs;
    sm.p.EEG.FFT.wSize = 32;
    sm.p.EEG.band(1).low1  = low1;
    sm.p.EEG.band(1).low2  = low2;
    sm.p.EEG.band(1).high1 = high1;
    sm.p.EEG.band(1).high2 = high2;
    sm.p.EEG.band_pass_dB = 1;
    sm.p.EEG.band_stop_dB = 60;
end

function [pass, rmse, maxErr] = runTestPar(signal, t, sm, label, tol)
    try
        assignin('base', 'sm', sm);
        assignin('base', 'sm_EEG_data', signal);
        simOut = sim('original_sim_bandpass_singleBand', 'ReturnWorkspaceOutputs', 'on');
        outSimulink = simOut.get('Bandpass_singleBand');
        simFailed = false;
    catch
        outSimulink = [];
        simFailed = true;
    end

    try
        outMatlab = bandpass_singleBand(signal, sm);
        matlabFailed = false;
    catch
        outMatlab = [];
        matlabFailed = true;
    end

    if simFailed && matlabFailed
        pass = true; rmse = NaN; maxErr = NaN;
    elseif simFailed || matlabFailed
        pass = false; rmse = NaN; maxErr = NaN;
    else
        diff = outSimulink - outMatlab;
        rmse = sqrt(mean(diff.^2));
        maxErr = max(abs(diff));
        pass = rmse < tol && maxErr < tol;
    end

    fprintf('%s\n RMSE: %.2e | MaxErr: %.2e | %s\n', label, rmse, maxErr, ternary(pass, 'PASS', 'FAIL'));
end

function out = ternary(cond, a, b)
    if cond, out = a; else, out = b; end
end
