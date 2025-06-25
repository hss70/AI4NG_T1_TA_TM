
function V1_TRANS = findSourceDataFiles(V1_TRANS)
    fprintf('Searching for source data...\n');
    files = dir(fullfile(V1_TRANS.f.SourceDataDir, '**', V1_TRANS.f.SourceDataName));
    V1_TRANS.tr_file_list = arrayfun(@(f) fullfile(f.folder, f.name), files, 'UniformOutput', false);
    V1_TRANS.tr_subDir_list = arrayfun(@(f) erase(f.folder, V1_TRANS.f.SourceDataDir), files, 'UniformOutput', false);
end
