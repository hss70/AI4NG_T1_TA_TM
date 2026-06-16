
function cleanupTempDirs(V1_TRANS)
    dirsToDelete = {
        fullfile(V1_TRANS.f.BaseDir, V1_TRANS.f.T1_online_subSubDir),
        fullfile(V1_TRANS.f.BaseDir, V1_TRANS.f.DataSubDir),
        fullfile(V1_TRANS.f.BaseDir, V1_TRANS.f.TrainTestSubDir)
    };
    for i = 1:numel(dirsToDelete)
        if isfolder(dirsToDelete{i})
            rmdir(dirsToDelete{i}, 's');
        end
    end

    pathsToCheck = [dirsToDelete, {fullfile(V1_TRANS.f.BaseDir, V1_TRANS.f.chanlocs_filename)}];
    for i = 1:numel(pathsToCheck)
        if not (exist(pathsToCheck{i}, 'file') || isfolder(pathsToCheck{i}))
            fprintf('Temp folder doesnt exist: %s\n', pathsToCheck{i});
        end
    end

    delete(fullfile(V1_TRANS.f.BaseDir, V1_TRANS.f.chanlocs_filename));
end
