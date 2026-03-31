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
clear;

% Get environment variables
homeDir = getenv('HOME_DIR'); %Work folder
%homeDir = '/home/hardeep/Dev/AI4NG/AI4NG_T1_TA_TM/TestData'

channelNum = str2double(getenv('channelNum'));
%channelNum = 8
sampleRate = str2double(getenv('sampleRate'));
%sampleRate = 125
downSampleRate = str2double(getenv('downSampleRate'));
%downSampleRate = sampleRate
%resultsDir = fullfile(homeDir,'Results')
% Validate environment variables
if isempty(homeDir) || isnan(channelNum) || ...
        isnan(sampleRate) || isnan(downSampleRate)
    error('Required environment variables not set properly');
end

parallelRuntimeDiagnostics('startup-preflight');

T1_proper;
%clear gets called in T1 so might as well clear here for clarity
clear;

%T1ResultsDir = GetEnv()
%outputDir = GetEnv()

homeDir = getenv('HOME_DIR');
%homeDir = '/home/hardeep/Dev/AI4NG/AI4NG_T1_TA_TM/TestData'
% resultsDir = app/work/Work/T1 in container
resultsDir = fullfile(homeDir, 'Work', 'T1'); 
%outputDir = app/work/Results in container
outputDir = getenv('OUTPUT_DIR');
reorganiseFiles(resultsDir, outputDir);
%reorganiseFiles('C:\Dev\AI4NG\AI4NG_T1_TA_TM\TestData\Work\T1','C:\Dev\AI4NG\AI4NG_T1_TA_TM\TestData\Work\Output');
