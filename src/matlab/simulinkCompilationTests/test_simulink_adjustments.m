cd ..

% Clear
clear; clc; close all;

%% Parameters
Fs = 125;                     % Sampling rate
T = 1/Fs;                     % Sampling period
L = 1000;                     % Length of signal (samples)
t = (0:L-1)' * T;             % Time vector

% Define test frequencies and amplitudes
testFreqs = [2, 5, 10, 15, 20, 30, 40];  % Hz
testAmps  = [0.5, 1, 2];

% Preload models to avoid warnings
load_system('original_sim_bandpass_singleBand');
load_system('sim_bandpass_singleBand');

fprintf('\n📊 Starting frequency/amplitude sweep comparison test...\n');

for f = testFreqs
    for A = testAmps
        %% Generate noisy sine wave
        signal = A * sin(2*pi*f*t) + 0.3*randn(size(t));

        %% Build the sm structure with valid band edges
        sm.p.EEG.sr = Fs;
        sm.p.EEG.FFT.wSize = 32;

        % ✅ Ensure valid increasing frequency specs
        low1  = max(f - 2, 0.1);              % Fstop1
        low2  = max(f - 1, low1 + 0.1);       % Fpass1
        high1 = min(f + 1, Fs/2 - 2);         % Fpass2
        high2 = max(min(f + 2, Fs/2 - 0.1), high1 + 0.1); % Fstop2

        sm.p.EEG.band(1).low1  = low1;
        sm.p.EEG.band(1).low2  = low2;
        sm.p.EEG.band(1).high1 = high1;
        sm.p.EEG.band(1).high2 = high2;
        sm.p.EEG.band_pass_dB = 1;
        sm.p.EEG.band_stop_dB = 60;

        %% --------- Method 1: From Workspace ---------
        assignin('base', 'sm', sm);
        assignin('base', 'sm_EEG_data', signal);
        simOut1 = sim('original_sim_bandpass_singleBand', 'ReturnWorkspaceOutputs', 'on');
        out1 = simOut1.get('Bandpass_singleBand');

        %% --------- Method 2: Inport + SimulationInput ---------
        evalin('base', 'clear sm_EEG_data');  % 🚫 Ensure this var isn't available
        ts = timeseries(signal, t);
        stopTime = t(end);  % ⏱ Match last time point of the input

        in = Simulink.SimulationInput('sim_bandpass_singleBand');
        in = in.setExternalInput(ts);
        in = in.setVariable('sm', sm);
        in = in.setModelParameter('SimulationMode', 'normal');
        in = in.setModelParameter('StopTime', num2str(stopTime));
        
        simOut2 = sim(in);
        out2 = simOut2.get('yout');

        %% --------- Compare Outputs ---------
        diffSignal = out1 - out2;
        rmse = sqrt(mean(diffSignal.^2));
        max_error = max(abs(diffSignal));
        pass = rmse < 1e-10 && max_error < 1e-10;

        fprintf("Freq: %2d Hz | Amp: %.1f | RMSE: %.2e | MaxErr: %.2e | %s\n", ...
            f, A, rmse, max_error, ternary(pass, "✅ PASS", "❌ FAIL"));

        %% --------- Optional: Plot for failures ---------
        if ~pass
            figure('Name', sprintf('FAILURE at %dHz, A=%.1f', f, A));
            subplot(3,1,1);
            plot(out1); title('Output: From Workspace'); ylabel('Amplitude'); grid on;
            subplot(3,1,2);
            plot(out2); title('Output: Inport + SimulationInput'); ylabel('Amplitude'); grid on;
            subplot(3,1,3);
            plot(abs(diffSignal)); title('|Difference|'); xlabel('Samples'); ylabel('Error'); grid on;
        end

        %% --------- FFT Comparison ---------
        NFFT = 2^nextpow2(L);
        fAxis = Fs/2*linspace(0,1,NFFT/2+1);
        fft1 = abs(fft(out1, NFFT)/L);
        fft2 = abs(fft(out2, NFFT)/L);

        figure('Name', sprintf('FFT Comparison %dHz, A=%.1f', f, A));
        plot(fAxis, 2*fft1(1:NFFT/2+1), 'b', 'DisplayName','From Workspace'); hold on;
        plot(fAxis, 2*fft2(1:NFFT/2+1), 'r--', 'DisplayName','SimulationInput');
        title(sprintf('FFT of Outputs (%dHz, A=%.1f)', f, A));
        xlabel('Frequency (Hz)');
        ylabel('Amplitude Spectrum');
        legend(); grid on;
    end
end

fprintf('\n📈 Sweep complete.\n');
cd simulinkCompilationTests

%% Inline ternary helper
function out = ternary(cond, a, b)
    if cond, out = a; else, out = b; end
end
