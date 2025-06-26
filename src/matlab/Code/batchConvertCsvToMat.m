% File: batchConvertCsvToMat.m
% Purpose: Recursively convert CSVs to MAT files, preserving
% subject/session structure. Also converts the config.json to a .mat file
% for passing on EEG config
% expects the following file structure:
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
% We provide the work directory via docker environment variables
%workDir = getenv('WORKDIR');
%workDir = "C:\Dev\AI4NG\AI4NG_T1_TA_TM\TestData\Work";

csvRootDir = fullfile(workDir, 'CSV');

% Root directory for the output MAT files
fprintf('Converting CSV files in: %s\n', csvRootDir);
if ~isfolder(csvRootDir)
    error('CSV root directory does not exist: %s', csvRootDir);
end

matRoot = fullfile(workDir, 'SourceData (EEG_rec)');
fprintf('Output MAT files will be saved in: %s\n', matRoot);

% Get list of subjects
subjects = dir(csvRootDir);
subjects = subjects([subjects.isdir] & ~ismember({subjects.name}, {'.', '..'}));

for i = 1:length(subjects)
    subjectName = subjects(i).name;
    subjectPath = fullfile(csvRootDir, subjectName);
    
    % Find all sessions for the current subject
    sessions = dir(subjectPath);
    sessions = sessions([sessions.isdir] & ~ismember({sessions.name}, {'.', '..'}));
    
    for j = 1:length(sessions)
        %Get name and path for current session
        sessionName = sessions(j).name;
        sessionPath = fullfile(subjectPath, sessionName);
        
        % Prepare output path
        outputSessionPath = fullfile(matRoot, subjectName, sessionName);
        if ~exist(outputSessionPath, 'dir')
            mkdir(outputSessionPath);
        end
        
        %% EEG CONFIG
        jsonFiles = dir(fullfile(sessionPath, '*.json'));
        if isempty(jsonFiles)
            fprintf('No Config file found in %s\n', sessionPath);
            continue;
        end
        configPath = fullfile(sessionPath, jsonFiles(1).name);
        
        % Validate json
        % Currently need frequency and EEG
        % Channels. Will update with more as we need more
        % Read and parse JSON
        jsonData = fileread(configPath);
        EEGConfig = jsondecode(jsonData);
        
        % Validate fields
        if isfield(EEGConfig, 'Frequency') && isfield(EEGConfig, 'EEGChannels')
            %set output filePath
            configFilePath = fullfile(outputSessionPath, 'EEG_config.mat');
            
            % Skip if .mat file already exists
            if exist(configFilePath, 'file')
                fprintf('Config file already exists: %s\n', configFilePath);
            else
                % Save as a .mat file
                save(configFilePath, 'EEGConfig', '-v7.3');
                fprintf('JSON converted to MATLAB struct and saved.\n');
            end
            
        else
            fprintf('Config JSON is missing Frequency or EEGChannels in %s \n', configPath);
            continue;
        end
        
        %% EEG DATA
        % Get the first CSV file in this session
        csvFiles = dir(fullfile(sessionPath, '*.csv'));
        if isempty(csvFiles)
            fprintf('No CSV file found in %s\n', sessionPath);
            continue;
        end
        
        csvFile = csvFiles(1).name;  % Only one CSV file per folder
        csvFilePath = fullfile(sessionPath, csvFile);
        
        matFilePath = fullfile(outputSessionPath, 'EEG_rec.mat');
        
        % Skip if .mat file already exists
        if exist(matFilePath, 'file')
            fprintf('MAT file already exists: %s\n', matFilePath);
            continue;
        end
        
        % Load CSV data
        csvData = readmatrix(csvFilePath);
        fprintf('Converting: %s\n', csvFilePath);
        
        %Need to transform data. mobile app saves the data as [channels,
        %classifier, trigger] x time whereas the training is expecting
        %time * [Channels, trigger, classifier] so need to swap last two
        %columns and transpose
        
        %Column swap
        nCols = size(csvData, 2);
        if nCols >= 2
            csvData(:, [nCols-1, nCols]) = csvData(:, [nCols, nCols-1]);
        end
        
        % Transpose: columns (in CSV) → rows (in MAT)
        EEG_rec = csvData';
        
        % Save as .mat file
        save(matFilePath, 'EEG_rec', '-v7.3');
        fprintf('Saved: %s\n', matFilePath);
    end
end

fprintf('Batch CSV-to-MAT conversion complete.\n');
clear;