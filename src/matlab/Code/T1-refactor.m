
%% Simplified EEG Classifier Pipeline
clear; clc;

%Looks like script requires a structure like:
% -Home
%   -Code
%   -Work
%       -SourceData (EEG_rec)
%           -SubjectName
%               -SessionName

%inputDir = getenv('INPUT_DIR');   % <-- The directory containing the EEG source data
%outputDir = getenv('OUTPUT_DIR');
%if isempty(inputCsv) || isempty(outputDir)
%    error('INPUT_CSV and OUTPUT_DIR environment variables must be set.');
%end

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

chanlocDir = fullfile(workDir,'Work','ChanLoc');
% Check that Data directory exists
if ~isfolder(chanlocDir)
    error('The Channel Loc directory does not exist: %s', dataDir);
end

% Set Data and Results directories
resultsDir = fullfile(workDir, 'Work','Results');
% Create Results directory if it does not exist
if ~isfolder(resultsDir)
    mkdir(resultsDir);
end

V1_TRANS = getV1_TRANSConfig(workDir, chanlocDir);

V1_TRANS = findSourceDataFiles(V1_TRANS);

if ~isempty(V1_TRANS.f.PreviousResultDir)
    V1_TRANS = removeProcessedFiles(V1_TRANS);
end

tr_file_list = V1_TRANS.tr_file_list;
tr_subDir_list = V1_TRANS.tr_subDir_list;
for wm_taskID = 1:numel(V1_TRANS.tr_file_list)
    V1_TRANS.wm_taskID = wm_taskID;
    processSingleTask(V1_TRANS, wm_taskID);
end

fprintf('All tasks complete.\n');
