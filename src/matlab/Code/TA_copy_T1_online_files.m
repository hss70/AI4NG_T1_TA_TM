% _____________________________________________________________________
%
% Copy important param and result files to the final T1 sub-directories
% _____________________________________________________________________

% Create/re-create actual T1 sub-directories
% __________________________________________

% X: Prepare actual T1-online directory
% _____________________________________

if ~isempty(V1_TRANS.f.T1_online_subSubDir)
    % Delete actually processed subDir within T1-online dir if exists
    wm_out_subDir = fullfile(V1_TRANS.f.T1_subDir, V1_TRANS.f.T1_online_subSubDir, tr_subDir_list{wm_taskID});
    tmp = fullfile(V1_TRANS.f.BaseDir, wm_out_subDir);

    if isdir(tmp)
        rmdir(tmp, 's');
    end

    % Prep subfold
    mkdir(V1_TRANS.f.BaseDir, wm_out_subDir);
    wm_out_baseDir_online = fullfile(V1_TRANS.f.BaseDir, wm_out_subDir);
end

% Copy final param and result files to T1 sub-directories
% _______________________________________________________

% X: Copy files from Online dir to -> the final T1-online dir
% ___________________________________________________________

if ~isempty(V1_TRANS.f.T1_online_subSubDir)

    w.f.in_baseDir = fullfile(V1_TRANS.f.BaseDir, 'Online');
    % w.f.in_baseDir = [V1_TRANS.f.BaseDir_for_trainTest,'\TrainTest'];
    w.f.out_baseDir = wm_out_baseDir_online;

    % Copy files from Online dir to -> the final T1-online dir
    wm1 = [w.f.in_baseDir];
    wm2 = [w.f.out_baseDir];
    w_dirStruct = dir(wm1);

    for wm_dirID = 1:size(w_dirStruct, 1)

        if w_dirStruct(wm_dirID).name(1, 1) == 'F'
            copyfile(fullfile(wm1, w_dirStruct(wm_dirID).name), fullfile(wm2, w_dirStruct(wm_dirID).name));
        end

    end

end

%% Comments

