% validate_compiled_output.m
% 🚀 Validates Simulink model output vs reference data, with logging

clear; clc;

%% Setup log
timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
logDir = fullfile(pwd, 'logs');
if ~exist(logDir, 'dir')
    mkdir(logDir);
end
logFile = fullfile(logDir, ['validate_compiled_output_' timestamp '.log']);
diary(logFile);
disp('📦 Starting validate_compiled_output.m');
disp(['🕒 Time: ' datestr(now)]);
disp(['📂 Working Dir: ' pwd]);
disp(['📝 Log File: ' logFile]);

%% Load reference data
try
    disp('📥 Loading reference_output.mat...');
    ref = load('reference_output.mat');
    ref_filtered = ref.filtered;
    ref_signal   = ref.signal;
    ref_t        = ref.t;
    sm           = ref.sm;
    disp('✅ Reference data loaded.');
catch ME
    disp('❌ Failed to load reference_output.mat');
    disp(getReport(ME));
    diary off;
    error('Reference .mat file missing or invalid.');
end

%% Step 1: Validate input signal
disp('🔍 Validating input signal...');
input_rmse = sqrt(mean((ref_signal - ref_signal).^2));  % Expect zero
time_rmse  = sqrt(mean((ref_t - ref_t).^2));            % Expect zero

fprintf('   Signal RMSE: %.6e\n', input_rmse);
fprintf('   Time   RMSE: %.6e\n', time_rmse);

if input_rmse > 1e-12 || time_rmse > 1e-12
    disp('❌ Input mismatch! Aborting test.');
    diary off;
    error('Input mismatch with reference.');
else
    disp('✅ Input signal and time match reference.');
end

%% Step 2: Run Simulink model
try
    disp('🧠 Preparing Simulink model...');
    ts = timeseries(ref_signal, ref_t);
    
    in = Simulink.SimulationInput('sim_bandpass_singleBand');
    in = in.setExternalInput(ts);
    in = in.setVariable('sm', sm);
    in = in.setModelParameter('SimulationMode', 'normal');
    in = in.setModelParameter('StopTime', num2str(ref_t(end)));

    % 👇 This is essential for compiled/deployment use:
    in = simulink.compiler.configureForDeployment(in);
    disp('🚀 Simulating...');


    simOut = sim(in);
    
    filtered = simOut.get('yout');
    disp('✅ Simulation completed.');
catch ME
    disp('❌ Simulink simulation failed.');
    disp(getReport(ME));
    diary off;
    error('Simulation failure.');
end

%% Step 3: Compare filtered output
disp('📊 Comparing filtered output...');
diffSignal = ref_filtered - filtered;
rmse = sqrt(mean(diffSignal.^2));
max_err = max(abs(diffSignal));

fprintf('   Filter RMSE: %.6e\n', rmse);
fprintf('   Max Abs Error: %.6e\n', max_err);

if rmse < 1e-10 && max_err < 1e-10
    disp('🎉 PASS: Filtered output matches reference within tolerance.');
else
    disp('❌ FAIL: Filtered output differs from reference.');
end

disp('✅ Validation script complete.');
diary off;
