
function V1_TRANS = removeProcessedFiles(V1_TRANS)
    fprintf('Removing already processed files...\n');
    processedDirs = dir(fullfile(V1_TRANS.f.PreviousResultDir, '**', ''));
    processedPaths = {processedDirs([processedDirs.isdir] & ~ismember({processedDirs.name}, {'.', '..'})).folder};
    keepIdx = ~ismember(V1_TRANS.tr_subDir_list, processedPaths);
    V1_TRANS.tr_file_list = V1_TRANS.tr_file_list(keepIdx);
    V1_TRANS.tr_subDir_list = V1_TRANS.tr_subDir_list(keepIdx);
end
