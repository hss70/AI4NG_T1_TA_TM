%workDir = getenv('WORK_DIR');
%Converts Csvs into .mat files and ensures they're in the right palce
batchConvertCsvToMat;

clear; clc;


%Looks like script requires a structure like:
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

%inputDir = getenv('INPUT_DIR');   % <-- The directory containing the EEG source data
%outputDir = getenv('OUTPUT_DIR');
%if isempty(inputCsv) || isempty(outputDir)
%    error('INPUT_CSV and OUTPUT_DIR environment variables must be set.');
%end

%Get channel number from environment variable
channelNum = 8;

%Get sample rate from environment variable
sampleRate = 125;
downSampleRate = 125;

% Get the WORK_DIR from environment variable
workDir = 'C:\Dev\AI4NG\AI4NG_T1_TA_TM\TestData\';
%workDir = getenv('WORK_DIR');
if isempty(workDir)
    error('WORK_DIR environment variable must be set.');
end
% Set Data and Results directories
dataDir = fullfile(workDir,'Work','SourceData (EEG_rec)');

% Check that Data directory exists
if ~isfolder(dataDir)
    error('The Data directory does not exist: %s', dataDir);
end

chanlocDir = fullfile(workDir,'Work','Dependents');
T1_proper;

%T1ResultsDir = GetEnv()
%outputDir = GetEnv
%reorganiseFiles(T1ResultsDir, outputDir);
reorganiseFiles('C:\Dev\AI4NG\AI4NG_T1_TA_TM\TestData\Work\T1', ...
                 'C:\Dev\AI4NG\AI4NG_T1_TA_TM\TestData\Work\Output');