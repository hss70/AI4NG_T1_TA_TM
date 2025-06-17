
%% Stacking all variables (for the case if this code called from other code)

% ____________________________________
% 
% Stacking all variables into STACK(1)
% ____________________________________

STACK_allVariables_01
% clearvars -except STACK 
    clearvars VA_TRANS
    VA_TRANS.subjID_text = V1_TRANS.tr_subDir_list{wm_taskID}(find(V1_TRANS.tr_subDir_list{wm_taskID}=='\')+1:end);
    clearvars -except STACK VA_TRANS V1_TRANS


%% VA Setup (A1 prep)

% V_C2019_dataConverter_01

% clear; clc;
% clearvars -except STACK
clc;

cf_TAv2_TrainTest_A1_prep


%% TaskManager code

  % Delete TrainTest dir with subdirs if exists
  if isdir(VA_TRANS.f.baseDir)
    rmdir(VA_TRANS.f.baseDir,'s');
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
    
    w.wm = find(ismember(V1_TRANS.tr_subDir_list{wm_taskID},'\')==1);
    % w.subjID = tr_subDir_list{1,wm_taskID}(1,1:w.wm-1);
    % w.subjID = tr_subDir_list{1,wm_taskID}(w.wm+1:end);
    % w.ssr_code = V1_TRANS.tr_subDir_list{1,wm_taskID}(w.wm+1:end);
    w.ssr_code = '';
    
% % % %     T1_results(wm1,1) = result;
    
    % T1_result_table(wm1,1).SubjID = w.subjID;
    T1_result_table(wm1,1).ssr_code = w.ssr_code;
% % % %     T1_result_table(wm1,1).CVfolds = size(result.summary.trialNumber.allTrials_per_class,2);
% % % %     T1_result_table(wm1,1).allTrials = result.summary.trialNumber.allTrials;
% % % %     T1_result_table(wm1,1).trPerClass = result.summary.trialNumber.allTrials_per_class;
% % % %     T1_result_table(wm1,1).tetsTrials = result.summary.trialNumber.testTrials;
% % % %     T1_result_table(wm1,1).tetsTrPerClass = result.summary.trialNumber.testTrials_per_class;
% % % %     T1_result_table(wm1,1).refPoint_sec = result.summary.timeInfo.DA_refPoint_shiftFrom_PRE_point_ms/1000;
% % % %     T1_result_table(wm1,1).taskStart_sec = (result.summary.timeInfo.DA_peakPoint_shiftFrom_PRE_point_ms - result.summary.timeInfo.DA_peakPoint_shiftFrom_Trig_ms)/1000;
% % % %     T1_result_table(wm1,1).DA_peak_sec = result.summary.timeInfo.DA_peakPoint_shiftFrom_PRE_point_ms/1000;
% % % %     T1_result_table(wm1,1).ORIG_refPeak_DA_mean = result.summary.orig_ref_DA_mean;
% % % %     T1_result_table(wm1,1).ORIG_refPeak_DA_std = result.summary.orig_ref_DA_std;
% % % %     T1_result_table(wm1,1).ORIG_peak_DA_mean = result.summary.orig_peak_DA_mean;
% % % %     T1_result_table(wm1,1).ORIG_peak_DA_std = result.summary.orig_peak_DA_std;
% % % % if isfield(result,'perm')
% % % %     T1_result_table(wm1,1).PERM_refPeak_DA_mean = result.summary.perm_ref_DA_mean;
% % % %     T1_result_table(wm1,1).PERM_refPeak_DA_std = result.summary.perm_ref_DA_std;
% % % %     T1_result_table(wm1,1).PERM_peak_DA_mean = result.summary.perm_peak_DA_mean;
% % % %     T1_result_table(wm1,1).PERM_peak_DA_std = result.summary.perm_peak_DA_std;
% % % %     T1_result_table(wm1,1).PERM_DA_atOrigPeak_mean = result.summary.perm_DA_mean_atOrigPeak;
% % % %     T1_result_table(wm1,1).PERM_DA_atOrigPeak_std = result.summary.perm_DA_std_atOrigPeak;
% % % % end
% % % %     T1_result_table(wm1,1).refDA_vs_peakDA_ttest_p = result.summary.refDA_lowerThan_peakDA_ttest_p;
% % % %     T1_result_table(wm1,1).refDA_vs_peakDA_ttest2_p = result.summary.refDA_lowerThan_peakDA_ttest2_p;
% % % %     T1_result_table(wm1,1).refDA_vs_peakDA_wilc_p = result.summary.refDA_lowerThan_peakDA_wilc_p;
% % % %     T1_result_table(wm1,1).refDAArea_vs_peakDA_ttest_p = result.summary.refDAInterval_lowerThan_peakDA_ttest_p;
% % % %     T1_result_table(wm1,1).refDAArea_vs_peakDA_ttest2_p = result.summary.refDAInterval_lowerThan_peakDA_ttest2_p;
% % % %     T1_result_table(wm1,1).refDAArea_vs_peakDA_wilc_p = result.summary.refDAInterval_lowerThan_peakDA_wilc_p;
% % % % if isfield(result,'perm')
% % % %     T1_result_table(wm1,1).p_of_ORIG_vs_PERM_DA_atOrig_peak = result.summary.mc_p_OF_orig_vs_perm_peak_DA;
% % % % end

    % AUTO SAVE
    % _________

        % Creat T1 dir if not exists
        % __________________________
        
        w.f.save.dir = [V1_TRANS.f.BaseDir,'\',V1_TRANS.f.T1_subDir];
        if ~isdir(w.f.save.dir)
          mkdir(w.f.save.dir)
        end
        w.f.save.path = [w.f.save.dir,'\'];
        
        % Save files
        % __________
        
        % fprintf('Saving VA_TRANS structure ...\n');
        % copy_of_VA_TRANS = VA_TRANS;
        % w.f.save.path = [VA_TRANS.f.baseDir,'\'];
        % w.f.save.name = ['TAv2_TrainTest [VA_TRANS].mat'];
        % save([w.f.save.path,w.f.save.name],'copy_of_VA_TRANS','-v7.3');
        % clear copy_of_VA_TRANS
        
% % % %         fprintf('Saving T1_results ...\n');
% % % %         % w.f.save.path = [V1_TRANS.f.BaseDir,'\',V1_TRANS.f.T1_subDir];
% % % %         w.f.save.name = w.T1_results_fileName;
% % % %         save([w.f.save.path,w.f.save.name],'T1_results','-v7.3');
    
        fprintf('Saving T1_result_table ...\n');
        % w.f.save.path = [V1_TRANS.f.BaseDir,'\',V1_TRANS.f.T1_subDir];
        w.f.save.name = w.T1_result_table_fileName;
        save([w.f.save.path,w.f.save.name],'T1_result_table','-v7.3');







%% Comments



