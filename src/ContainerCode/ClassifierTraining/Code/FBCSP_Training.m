%Converts Csvs into .mat files and ensures they're in the right palce

workDir = getenv('WORK_DIR');
batchConvertCsvToMat;
clear; clc;

% Get environment variables
workDir = getenv('WORK_DIR');
workPath = getenv('WORK_PATH');
channelNum = str2double(getenv('channelNum'));
sampleRate = str2double(getenv('sampleRate'));
downSampleRate = str2double(getenv('downSampleRate'));
resultsDir = genenv('RESULTS_PATH');

% Validate environment variables
if isempty(workDir) || isempty(workPath) || isnan(channelNum) || ...
   isnan(sampleRate) || isnan(downSampleRate)
    error('Required environment variables not set properly');
end

T1_proper;

%T1ResultsDir = GetEnv()
%outputDir = GetEnv
%reorganiseFiles(T1ResultsDir, outputDir);
reorganiseFiles('C:\Dev\AI4NG\AI4NG_T1_TA_TM\TestData\Work\T1', ...
                 'C:\Dev\AI4NG\AI4NG_T1_TA_TM\TestData\Work\Output');