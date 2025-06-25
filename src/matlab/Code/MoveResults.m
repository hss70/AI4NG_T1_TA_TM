function reorganiseFiles(sourceBase, destBase)
% reorganiseFiles Reorganises files from sourceBase to destBase
% maintaining participant/session folder structure.
%
% Usage:
%   reorganiseFiles('C:\path\to\source', 'C:\path\to\output')

    % Get list of all files in sourceBase recursively
    allFiles = dir(fullfile(sourceBase, '**', '*.*'));
    
    % Loop through all files
    for k = 1:length(allFiles)
        % Skip directories
        if allFiles(k).isdir
            continue;
        end
        
        % Full path of the file
        fullPath = fullfile(allFiles(k).folder, allFiles(k).name);
        
        % Relative path from sourceBase
        relPath = erase(fullPath, [sourceBase, filesep]);
        
        % Use file parts to extract participant and session
        parts = strsplit(relPath, filesep);
        
        % Dynamically find participant/session names in the path
        % Looks for pattern \Participant\Session\ in path
        % Adjust this if participant/session names are in different positions!
        idx = find(contains(parts, 'Owen', 'IgnoreCase', true), 1);
        
        if isempty(idx) || length(parts) < idx + 1
            % Skip if participant/session info not found
            continue;
        end
        
        participant = parts{idx};
        session = parts{idx + 1};
        
        % Build the destination folder
        destFolder = fullfile(destBase, participant, session);
        
        % Create destination folder if it doesn't exist
        if ~exist(destFolder, 'dir')
            mkdir(destFolder);
        end
        
        % Build destination file path
        destFile = fullfile(destFolder, allFiles(k).name);
        
        % Move the file
        movefile(fullPath, destFile);
        
        % OPTIONAL: Convert .mat to .json (add your logic here!)
        % if endsWith(allFiles(k).name, '.mat')
        %     data = load(destFile);
        %     jsonFile = fullfile(destFolder, [erase(allFiles(k).name, '.mat'), '.json']);
        %     jsonStr = jsonencode(data);
        %     fid = fopen(jsonFile, 'w');
        %     fwrite(fid, jsonStr, 'char');
        %     fclose(fid);
        % end
    end
    
    disp('Files reorganised into Output\Participant\Session folders!');
end
