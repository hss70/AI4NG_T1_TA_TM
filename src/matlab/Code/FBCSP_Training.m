% -Home
%   -Code
%   -Dependents
%       -Standard-10-20-Cap81.locs
%   -Work
%       -CSV
%           -SubjectName
%               -SessionName
%       -T1
%       -SourceData (EEG_rec)
%           -SubjectName
%               -SessionName
%Converts Csvs into .mat files and ensures they're in the right palce
homeDir = getenv('HOME_DIR');
%homeDir = '/home/hardeep/Dev/AI4NG/AI4NG_T1_TA_TM/TestData'
workDir = fullfile(homeDir, 'Work');
batchConvertCsvToMat;
clear; clc;

% Get environment variables
homeDir = getenv('HOME_DIR'); %Work folder
channelNum = str2double(getenv('channelNum'));
sampleRate = str2double(getenv('sampleRate'));
downSampleRate = str2double(getenv('downSampleRate'));
resultsDir = getenv('RESULTS_PATH');

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