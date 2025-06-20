function reorganiseFiles(sourceBase, destBase)
% REORGANISEFILES Moves all files from source directory to destination while preserving structure
%
%   reorganiseFiles(sourceBase, destBase)
%
%   Inputs:
%       sourceBase - Base directory containing source files
%       destBase   - Base directory for output structure
%
%   Example:
%       reorganiseFiles('C:\Dev\AI4NG\TestData\Work\T1', ...
%                      'C:\Dev\AI4NG\TestData\Work\Output')

    % Validate inputs
    if nargin < 2
        error('Not enough input arguments. Usage: reorganiseFiles(sourceBase, destBase)');
    end
    
    if ~isfolder(sourceBase)
        error('Source directory does not exist: %s', sourceBase);
    end
    
    if ~isfolder(destBase)
        mkdir(destBase);
    end
    
    % Get list of all files in sourceBase recursively
    allFiles = dir(fullfile(sourceBase, '**', '*.*'));
    allFiles = allFiles(~[allFiles.isdir]); % Remove directories
    
    if isempty(allFiles)
        warning('No files found in source directory: %s', sourceBase);
        return;
    end
    
    filesProcessed = 0;
    filesSkipped = 0;
    filesConverted = 0;
    
    % Loop through all files
    for k = 1:length(allFiles)
        % Full path of the file
        fullPath = fullfile(allFiles(k).folder, allFiles(k).name);
        
        % Relative path from sourceBase
        relPath = erase(fullPath, [sourceBase, filesep]);
        
        try
            % Build the destination path
            destPath = fullfile(destBase, relPath);
            destFolder = fileparts(destPath);
            
            % Create destination folder if it doesn't exist
            if ~exist(destFolder, 'dir')
                mkdir(destFolder);
            end
            
            % Move the file
            movefile(fullPath, destPath);
            filesProcessed = filesProcessed + 1;
            
            % Convert .mat to .json if needed
            [~, ~, ext] = fileparts(allFiles(k).name);
            if strcmpi(ext, '.mat')
                jsonFile = fullfile(destFolder, [allFiles(k).name(1:end-4), '.json']);
                convertMatToJson(destPath, jsonFile);
                filesConverted = filesConverted + 1;
            end
            
        catch ME
            warning('Failed to process file %s: %s', fullPath, ME.message);
            filesSkipped = filesSkipped + 1;
            continue;
        end
    end
    
    fprintf('File reorganization complete!\n');
    fprintf('  Files processed: %d\n', filesProcessed);
    fprintf('  Files converted to JSON: %d\n', filesConverted);
    fprintf('  Files skipped: %d\n', filesSkipped);
end

function convertMatToJson(matFile, jsonFile)
    try
        data = load(matFile);
        jsonStr = jsonencode(data, 'PrettyPrint', true);
        fid = fopen(jsonFile, 'w');
        if fid == -1
            error('Could not open file for writing: %s', jsonFile);
        end
        fprintf(fid, '%s', jsonStr);
        fclose(fid);
    catch ME
        warning('Failed to convert %s to JSON: %s', matFile, ME.message);
        % Delete partially written JSON file if it exists
        if exist(jsonFile, 'file')
            delete(jsonFile);
        end
        rethrow(ME);
    end
end