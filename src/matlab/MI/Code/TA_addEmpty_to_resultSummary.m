%% Stacking all variables (for the case if this code called from other code)

% ____________________________________
%
% Stacking all variables into STACK(1)
% ____________________________________

STACK_allVariables_01
% clearvars -except STACK
clearvars VA_TRANS

sep_pos = find(V1_TRANS.tr_subDir_list{wm_taskID} == filesep);
VA_TRANS.subjID_text = V1_TRANS.tr_subDir_list{wm_taskID}(sep_pos(end)+1:end);
clearvars -except STACK VA_TRANS V1_TRANS

%% VA Setup (A1 prep)

% V_C2019_dataConverter_01

% clear; clc;
% clearvars -except STACK
clc;

cf_TAv2_TrainTest_A1_prep

%% TaskManager code

% Delete TrainTest dir with subdirs if exists
if isfolder(VA_TRANS.f.baseDir)
    rmdir(VA_TRANS.f.baseDir, 's');
end

% clearvars -except STACK VA_TRANS result
% clearvars -except STACK VA_TRANS
clearvars -except STACK

%% Restore Stacked variables (for the case if this code called from other code)

% ____________________________________
%
% Stacking all variables into STACK(1)
% ____________________________________

STACK_restore_01

%% Code 01

% TA_addEmpty_to_resultSummary

w.T1_results_fileName = 'T1 [results].mat';
w.T1_result_table_fileName = 'T1 [resultTable].mat';

% % % %     % Actual T1 results
% % % %     % _________________
% % % %
% % % %       % w.file.load.path = [V1_TRANS.f.BaseDir,'\TrainTest\'];
% % % %       w.file.load.path = [V1_TRANS.f.BaseDir_for_trainTest,'\TrainTest\'];
% % % %       w.file.load.name = 'TAv2_TrainTest [result].mat';
% % % %       % fprintf(['Loading ',w.file.load.name,' ...\n']);
% % % %       % tmp = load([w.file.load.path, w.file.load.name]);
% % % %       load([w.file.load.path, w.file.load.name]);

% Set actual row number in result_table
% _____________________________________

% % % % % % % %     if exist('T1_result_table')==0
% % % % % % % %       wm1 = 1;
% % % % % % % %     else
% % % % % % % %       wm1 = size(T1_result_table,1)+1;
% % % % % % % %     end
wm1 = wm_taskID;

% Add new line to result summary
% ______________________________

w.wm = find(ismember(V1_TRANS.tr_subDir_list{wm_taskID}, filesep) == 1);

w.ssr_code = '';


T1_result_table(wm1, 1).ssr_code = w.ssr_code;

% AUTO SAVE
% _________

% Creat T1 dir if not exists
% __________________________

w.f.save.dir = fullfile(V1_TRANS.f.BaseDir, V1_TRANS.f.T1_subDir);

if ~isfolder(w.f.save.dir)
    mkdir(w.f.save.dir)
end

%w.f.save.path = [w.f.save.dir, filesep];

% Save files
% ________________________

fprintf('Saving T1_result_table ...\n');
w.f.save.name = w.T1_result_table_fileName;
save(fullfile(w.f.save.dir, w.f.save.name), 'T1_result_table', '-v7.3');

%% Comments
% Edited by Hardeep on 2025-06-27 to make crossplatform compatible