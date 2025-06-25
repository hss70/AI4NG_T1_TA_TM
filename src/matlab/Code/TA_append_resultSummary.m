% TA_append_resultSummary

    w.T1_results_fileName = 'T1 [results].mat';
    w.T1_result_table_fileName = 'T1 [resultTable].mat';
    
    % Actual T1 results
    % _________________
    
      % w.file.load.path = [V1_TRANS.f.BaseDir_for_trainTest,'\TrainTest\'];
      w.file.load.path = [V1_TRANS.f.BaseDir,'\TrainTest\'];
      w.file.load.name = 'TAv2_TrainTest [result].mat';
      % fprintf(['Loading ',w.file.load.name,' ...\n']);
      % tmp = load([w.file.load.path, w.file.load.name]);
      load([w.file.load.path, w.file.load.name]);
    
% %     % Load T1 results and result_summary files (if stored yet)
% %     % ________________________________________________________
% %     
% %     w.file.load.path = [V1_TRANS.f.BaseDir,'\',V1_TRANS.f.T1_subDir,'\'];
% %     w.file.load.name =w.T1_results_fileName;
% %     w_dirStruct = dir(w.file.load.path);
% %     wm2 = 0;
% %     for wm1 = 1 : size(w_dirStruct,1)
% %       if strcmp(w_dirStruct(wm1,1).name, w.file.load.name)
% %           wm2 = 1;
% %       end
% %     end
% %     if wm2 == 1
% %         
% %       % Load T1 result and resultTable files
% %       
% %       w.file.load.path = [V1_TRANS.f.BaseDir,'\',V1_TRANS.f.T1_subDir,'\'];
% %       w.file.load.name =w.T1_results_fileName;
% %       load([w.file.load.path, w.file.load.name]);
% %       
% %       w.file.load.path = [V1_TRANS.f.BaseDir,'\',V1_TRANS.f.T1_subDir,'\'];
% %       w.file.load.name =w.T1_result_table_fileName;
% %       load([w.file.load.path, w.file.load.name]);
% %       
% %     end
    
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
    
    T1_results(wm1,1) = result;
    
    % w.wm = find(ismember(tr_subDir_list{1,wm_taskID},'\')==1);
    % % w.subjID = tr_subDir_list{1,wm_taskID}(1,1:w.wm-1);
    % w.subjID = tr_subDir_list{1,wm_taskID}(w.wm+1:end);
    % T1_result_table(wm1,1).ssr_code = w.subjID;
    
    T1_result_table(wm1,1).ssr_code = result.orig.basis.ssr_text;
if isfield(result,'perm')
    T1_result_table(wm1,1).perms = size(result.perm,2);
end
    T1_result_table(wm1,1).classes = size(result.orig.basis.allTrials_per_class,2);
    T1_result_table(wm1,1).CVfolds = result.orig.basis.testFoldNumber;
    T1_result_table(wm1,1).allTrials = result.orig.basis.allTrials;
    T1_result_table(wm1,1).trPerClass = result.orig.basis.allTrials_per_class;
    T1_result_table(wm1,1).testTrials = result.orig.basis.testTrials;
    T1_result_table(wm1,1).testTrPerClass = result.orig.basis.testTrials_per_class;
    T1_result_table(wm1,1).trainTrials = result.orig.basis.trainTrials;
    T1_result_table(wm1,1).trainTrPerClass = result.orig.basis.trainTrials_per_class;
    
    T1_result_table(wm1,1).cfWin_ms = result.orig.timeInfo.cf.winSize_ms;
    T1_result_table(wm1,1).cfStep_ms = result.orig.timeInfo.cf.winStep_ms;
    
    T1_result_table(wm1,1).smoothWidth_ms = result.orig.timeInfo.smooth.winWidth_ms;
    
    T1_result_table(wm1,1).opt_tt_ID = result.orig.opt_tt.optionID;
    
    T1_result_table(wm1,1).trigPoint_ms = result.orig.timeInfo.ms_from_PRE_point.trig;
    T1_result_table(wm1,1).refInterval_ms = result.orig.timeInfo.ms_from_PRE_point.ref_interval;
    T1_result_table(wm1,1).taskInterval_ms = result.orig.timeInfo.ms_from_PRE_point.task_interval;
    T1_result_table(wm1,1).refPeak_ms = result.orig.timeInfo.ms_from_PRE_point.opt_peakDAPoint_ref;
    T1_result_table(wm1,1).taskPeak_ms = result.orig.timeInfo.ms_from_PRE_point.opt_peakDAPoint_task;
    T1_result_table(wm1,1).smooth_refPeak_ms = result.orig.timeInfo.ms_from_PRE_point.smooth_peakDAPoint_ref;
    T1_result_table(wm1,1).smooth_taskPeak_ms = result.orig.timeInfo.ms_from_PRE_point.smooth_peakDAPoint_task;
    
    T1_result_table(wm1,1).refPeakDA_mean = result.orig.DA.opt.refPeakDA_mean *100;
    T1_result_table(wm1,1).refPeakDA_std = result.orig.DA.opt.refPeakDA_std *100;
    T1_result_table(wm1,1).taskPeakDA_mean = result.orig.DA.opt.taskPeakDA_mean *100;
    T1_result_table(wm1,1).taskPeakDA_std = result.orig.DA.opt.taskPeakDA_std *100;
    T1_result_table(wm1,1).smooth_refPeakDA_mean = result.orig.DA.smooth.refPeakDA_mean *100;
    T1_result_table(wm1,1).smooth_refPeakDA_std = result.orig.DA.smooth.refPeakDA_std *100;
    T1_result_table(wm1,1).smooth_taskPeakDA_mean = result.orig.DA.smooth.taskPeakDA_mean *100;
    T1_result_table(wm1,1).smooth_taskPeakDA_std = result.orig.DA.smooth.taskPeakDA_std *100;
    
if isfield(result,'perm')
    T1_result_table(wm1,1).permSpec_refPeakDA_mean = result.all_perms.DA.opt.permSpecific__refPeakDA_mean *100;
    T1_result_table(wm1,1).permSpec_refPeakDA_std = result.all_perms.DA.opt.permSpecific__refPeakDA_std *100;
    T1_result_table(wm1,1).permSpec_taskPeakDA_mean = result.all_perms.DA.opt.permSpecific__taskPeakDA_mean *100;
    T1_result_table(wm1,1).permSpec_taskPeakDA_std = result.all_perms.DA.opt.permSpecific__taskPeakDA_std *100;
    T1_result_table(wm1,1).smooth_permSpec_refPeakDA_mean = result.all_perms.DA.smooth.permSpecific__refPeakDA_mean *100;
    T1_result_table(wm1,1).smooth_permSpec_refPeakDA_std = result.all_perms.DA.smooth.permSpecific__refPeakDA_std *100;
    T1_result_table(wm1,1).smooth_permSpec_taskPeakDA_mean = result.all_perms.DA.smooth.permSpecific__taskPeakDA_mean *100;
    T1_result_table(wm1,1).smooth_permSpec_taskPeakDA_std = result.all_perms.DA.smooth.permSpecific__taskPeakDA_std *100;
    
    T1_result_table(wm1,1).permDA_atOrigRefPeak_mean = result.all_perms.DA.opt.perm_DA_mean__atOrigRefPeak *100;
    T1_result_table(wm1,1).permDA_atOrigRefPeak_std = result.all_perms.DA.opt.perm_DA_std__atOrigRefPeak *100;
    T1_result_table(wm1,1).permDA_atOrigTaskPeak_mean = result.all_perms.DA.opt.perm_DA_mean__atOrigTaskPeak *100;
    T1_result_table(wm1,1).permDA_atOrigTaskPeak_std = result.all_perms.DA.opt.perm_DA_std__atOrigTaskPeak *100;
    T1_result_table(wm1,1).smooth_permDA_atOrigRefPeak_mean = result.all_perms.DA.smooth.perm_DA_mean__atOrigSmoothRefPeak *100;
    T1_result_table(wm1,1).smooth_permDA_atOrigRefPeak_std = result.all_perms.DA.smooth.perm_DA_std__atOrigSmoothRefPeak *100;
    T1_result_table(wm1,1).smooth_permDA_atOrigTaskPeak_mean = result.all_perms.DA.smooth.perm_DA_mean__atOrigSmoothTaskPeak *100;
    T1_result_table(wm1,1).smooth_permDA_atOrigTaskPeak_std = result.all_perms.DA.smooth.perm_DA_std__atOrigSmoothTaskPeak *100;
end
    
    T1_result_table(wm1,1).refPeakDA_lower_taskPeakDA_ttest_p = result.orig.RT_stat.opt.refPeakDA_lowerThan_taskPeakDA.p_tt;
    % T1_result_table(wm1,1).refPeakDA_lower_taskPeakDA_ttest2_p = result.orig.RT_stat.opt.refPeakDA_lowerThan_taskPeakDA.p_tt2;
    T1_result_table(wm1,1).refPeakDA_lower_taskPeakDA_wilc_p = result.orig.RT_stat.opt.refPeakDA_lowerThan_taskPeakDA.p_wilc;
    T1_result_table(wm1,1).smooth_refPeakDA_lower_taskPeakDA_ttest_p = result.orig.RT_stat.smooth.refPeakDA_lowerThan_taskPeakDA.p_tt;
    % T1_result_table(wm1,1).smooth_refPeakDA_lower_taskPeakDA_ttest2_p = result.orig.RT_stat.smooth.refPeakDA_lowerThan_taskPeakDA.p_tt2;
    T1_result_table(wm1,1).smooth_refPeakDA_lower_taskPeakDA_wilc_p = result.orig.RT_stat.smooth.refPeakDA_lowerThan_taskPeakDA.p_wilc;
    
if isfield(result,'perm')
    T1_result_table(wm1,1).permSpec_permRefPeakDA_lower_origRefPeakDA_mc_p = result.all_perms.mc_p.opt.permSpec_refPeakDA_VS_origRefPeakDA;
    T1_result_table(wm1,1).permSpec_permTaskPeakDA_lower_origTaskPeakDA_mc_p = result.all_perms.mc_p.opt.permSpec_taskPeakDA_VS_origTaskPeakDA;
    T1_result_table(wm1,1).smooth_permSpec_permRefPeakDA_lower_origRefPeakDA_mc_p = result.all_perms.mc_p.smooth.permSpec_smoothRefPeakDA_VS_origSmoothRefPeakDA;
    T1_result_table(wm1,1).smooth_permSpec_permTaskPeakDA_lower_origTaskPeakDA_mc_p = result.all_perms.mc_p.smooth.permSpec_smoothTaskPeakDA_VS_origSmoothTaskPeakDA;
    
    T1_result_table(wm1,1).permDA_atOrigRefPeak_lower_origRefPeakDA_mc_p = result.all_perms.mc_p.opt.permDA_atOrigRefPeak_VS_origRefPeakDA;
    T1_result_table(wm1,1).permDA_atOrigTaskPeak_lower_origTaskPeakDA_mc_p = result.all_perms.mc_p.opt.permDA_atOrigTaskPeak_VS_origTaskPeakDA;
    T1_result_table(wm1,1).smooth_permDA_atOrigRefPeak_lower_origRefPeakDA_mc_p = result.all_perms.mc_p.smooth.permDA_atOrigSmoothRefPeak_VS_origSmoothRefPeakDA;
    T1_result_table(wm1,1).smooth_permDA_atOrigTaskPeak_lower_origTaskPeakDA_mc_p = result.all_perms.mc_p.smooth.permDA_atOrigSmoothTaskPeak_VS_origSmoothTaskPeakDA;
end

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
        
        clearvars tmp
        if isfield(V1_TRANS.f,'save__T1_results')
         if V1_TRANS.f.save__T1_results == 1
          tmp.wm = 1;
         else
          tmp.wm = 0;
         end
        else
         tmp.wm = 1;
        end
        if tmp.wm == 1
          fprintf('Saving T1_results ...\n');
          % w.f.save.path = [V1_TRANS.f.BaseDir,'\',V1_TRANS.f.T1_subDir];
          w.f.save.name = w.T1_results_fileName;
          save([w.f.save.path,w.f.save.name],'T1_results','-v7.3');
        end
        clearvars tmp
    
        fprintf('Saving T1_result_table ...\n');
        % w.f.save.path = [V1_TRANS.f.BaseDir,'\',V1_TRANS.f.T1_subDir];
        w.f.save.name = w.T1_result_table_fileName;
        save([w.f.save.path,w.f.save.name],'T1_result_table','-v7.3');





%% Comments



