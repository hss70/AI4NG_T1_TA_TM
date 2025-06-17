% Multi-class Classification, task manager 

% Input structures

% Output structures

% REQUIRESTMENT: Matlab
% Copyright(c)2020 Attila Korik, http://isrc.ulster.ac.uk/akorik/contact.html


% % % % %% Stacking all variables (for the case if this code called from other code)
% % % % 
% % % % % ____________________________________
% % % % % 
% % % % % Stacking all variables into STACK(1)
% % % % % ____________________________________
% % % % 
% % % % STACK_allVariables_01
% % % % % clearvars -except STACK 
% % % %     clearvars VA_TRANS
% % % %     VA_TRANS.subjID_text = V1_TRANS.tr_subDir_list{1,wm_taskID}(find(V1_TRANS.tr_subDir_list{1,wm_taskID}=='\')+1:end);
% % % %     clearvars -except STACK VA_TRANS attempt
% % % % 
% % % % 
%% VA Setup (A1 prep)

% V_C2019_dataConverter_01

% clear; clc;
% clearvars -except STACK
% clc;

cf_TAv2_TrainTest_A1_prep


%% TaskManager code

  % Delete TrainTest dir with subdirs if exists
  if isdir(VA_TRANS.f.baseDir)
    rmdir(VA_TRANS.f.baseDir,'s');
  end
  
% __________________
% 
% A09_EEG_validation
% __________________

for wm_subDirID = 1 : size(VA_TRANS.f.classSubDir,2)
    VA = VA_TRANS;
    fprintf([VA_TRANS.f.A09_EEG_validation.subDir,' (',VA_TRANS.f.classSubDir{wm_subDirID},'):\n']);
    
    % allChValid or not
    VA.set.w.switch.ch.allValid = 1;    % =1: all EEG ch valid, =0: EEG ch validation will be called 
    
    % VA.set.autorun.f.load.path = [VA_TRANS.f.dataDir,'\',VA_TRANS.f.classSubDir{wm_subDirID},'\'];
    VA.set.autorun.f.load.path = [VA_TRANS.f.dataDir,'\']; VA.w.wm_subDirID = wm_subDirID;
    VA.set.autorun.f.save.path = [VA_TRANS.f.baseDir,'\',VA_TRANS.f.A09_EEG_validation.subDir,'\',VA_TRANS.f.classSubDir{wm_subDirID},'\'];
    if ~isdir(VA.set.autorun.f.save.path)
      mkdir(VA.set.autorun.f.save.path)
    end

    % VA_A09_EEG_validation_01(VA)
    VA_A09_EEG_validation_01
    clearvars -except STACK VA_TRANS attempt
end

% _____________________
% 
% A10_offlineClass_prep
% _____________________

for wm_subDirID = 1 : size(VA_TRANS.f.classSubDir,2)
    VA = VA_TRANS;
    fprintf([VA_TRANS.f.A10_offlineClass_prep.subDir,' (',VA_TRANS.f.classSubDir{wm_subDirID},'):\n\n']);
    
    % VA.set.autorun.f.load.path.EEG_rec = [VA_TRANS.f.dataDir,'\',VA_TRANS.f.classSubDir{wm_subDirID},'\'];
    VA.set.autorun.f.load.path.EEG_rec = [VA_TRANS.f.dataDir,'\']; VA.w.wm_subDirID = wm_subDirID;
    VA.set.autorun.f.load.path.validation = [VA_TRANS.f.baseDir,'\',VA_TRANS.f.A09_EEG_validation.subDir,'\',VA_TRANS.f.classSubDir{wm_subDirID},'\'];
    VA.set.autorun.f.save.path = [VA_TRANS.f.baseDir,'\',VA_TRANS.f.A10_offlineClass_prep.subDir,'\',VA_TRANS.f.classSubDir{wm_subDirID},'\'];
    if ~isdir(VA.set.autorun.f.save.path)
      mkdir(VA.set.autorun.f.save.path)
    end
    
    % VA_A10_offlineClass_prep_01(VA)
    VA_A10_offlineClass_prep_01
    clearvars -except STACK VA_TRANS attempt
end

% ____________________________
% 
% A10B_offlineTrial_validation
% ____________________________

for wm_subDirID = 1 : size(VA_TRANS.f.classSubDir,2)
    VA = VA_TRANS;
    fprintf([VA_TRANS.f.A10B_offlineTrial_validation.subDir,' (',VA_TRANS.f.classSubDir{wm_subDirID},'):\n\n']);
    
    % VA.set.autorun.f.load.path.EEG_rec = [VA_TRANS.f.dataDir,'\',VA_TRANS.f.classSubDir{wm_subDirID},'\'];
    VA.set.autorun.f.load.path.EEG_rec = [VA_TRANS.f.dataDir,'\']; VA.w.wm_subDirID = wm_subDirID;
    VA.set.autorun.f.load.path.EEG_validation = [VA_TRANS.f.baseDir,'\',VA_TRANS.f.A09_EEG_validation.subDir,'\',VA_TRANS.f.classSubDir{wm_subDirID},'\'];
    VA.set.autorun.f.load.path.offlineClass_prep = [VA_TRANS.f.baseDir,'\',VA_TRANS.f.A10_offlineClass_prep.subDir,'\',VA_TRANS.f.classSubDir{wm_subDirID},'\'];
    VA.set.autorun.f.save.path = [VA_TRANS.f.baseDir,'\',VA_TRANS.f.A10B_offlineTrial_validation.subDir,'\',VA_TRANS.f.classSubDir{wm_subDirID},'\'];
    if ~isdir(VA.set.autorun.f.save.path)
      mkdir(VA.set.autorun.f.save.path)
    end
    
    % VA_A10B_offlineTrial_validation_01(VA)
    VA_A10B_offlineTrial_validation_01
    clearvars -except STACK VA_TRANS attempt
end

% ___________________________
% 
% A11_offlineClass_classSetup
% ___________________________

for wm_subDirID = 1 : size(VA_TRANS.f.classSubDir,2)
    VA = VA_TRANS;
    fprintf([VA_TRANS.f.A11_offlineClass_classSetup.subDir,' (',VA_TRANS.f.classSubDir{wm_subDirID},'):\n\n']);
    
    VA.set.autorun.f.load.path.offlineClass_prep = [VA_TRANS.f.baseDir,'\',VA_TRANS.f.A10_offlineClass_prep.subDir,'\',VA_TRANS.f.classSubDir{wm_subDirID},'\'];
    VA.set.autorun.f.load.path.tr_validMask = [VA_TRANS.f.baseDir,'\',VA_TRANS.f.A10B_offlineTrial_validation.subDir,'\',VA_TRANS.f.classSubDir{wm_subDirID},'\'];
    VA.set.autorun.f.save.path = [VA_TRANS.f.baseDir,'\',VA_TRANS.f.A11_offlineClass_classSetup.subDir,'\',VA_TRANS.f.classSubDir{wm_subDirID},'\'];
    if ~isdir(VA.set.autorun.f.save.path)
      mkdir(VA.set.autorun.f.save.path)
    end
    
    % VA_A11_offlineClass_classSetup_01(VA)
    VA_A11_offlineClass_classSetup_01
    clearvars -except STACK VA_TRANS attempt
end


% ___________________________________
% 
% FBCSP_offline_trainTest_taskManager
% ___________________________________

    % Parfor Core Initialization
    % __________________________
    
    cf_TAv2_TrainTest_A2_FBCSP
    w.parCore = TM.parfor.perm;
    
    if w.parCore.parforUsed == 1        % =0:parfor NOT used, =1:parfor (will initialized and used during code execution)
    % if w.parCore.number_basis ~= 0      % =0:not used parfor, >0:number of parfor cores, =-1:number of used cores will equal:(size(autorun.tt.used.subjects,2) * size(autorun.tt.used.sessions,2) * c.tt.folds.outerFoldNumber) 
      if w.parCore.number_basis == -1   % =0:not used parfor, >0:number of parfor cores, =-1:number of used cores will equal:(size(autorun.tt.used.subjects,2) * size(autorun.tt.used.sessions,2) * c.tt.folds.outerFoldNumber) 
        w.parCore.number = size(autorun.tt.used.subjects,2) * size(autorun.tt.used.sessions,2) * c.tt.folds.outerFoldNumber;
      else
        w.parCore.number = w.parCore.number_basis;
      end
      if isempty(gcp('nocreate')) || (w.parCore.reOpenIfOpen == 1)
        delete(gcp('nocreate'))     % parpool close
        parpool (w.parCore.location, w.parCore.number)       % open cores
      end
    end
    autorun.tt.parCore = w.parCore;
    
    % FBCSP TM
    % ________
    
    % % if w.parCore.parforUsed == 0
    % %   for par_ID = 0 : VA_TRANS.c.eval.permut_number
    % %    
    % %     parTMP_eval{par_ID+1} = VAv2_FBCSP_offline_trainTest_taskManager_func_01(VA_TRANS, par_ID);
    % %     
    % %   end
    % % else
    % %   parfor par_ID = 0 : VA_TRANS.c.eval.permut_number
    % %     
    % %     parTMP_eval{par_ID+1} = VAv2_FBCSP_offline_trainTest_taskManager_func_01(VA_TRANS, par_ID);
    % %     
    % %   end
    % % end
    % % for par_ID = 0 : VA_TRANS.c.eval.permut_number
    % %   if par_ID == 0
    % %     if size(VA_TRANS.f.classSubDir,2) == 1
    % %         % result.orig...
    % %         result.orig = parTMP_eval{par_ID+1}{1,1};
    % %     else
    % %         % result.orig{classSubDirID}...
    % %         result.orig = parTMP_eval{par_ID+1};
    % %     end
    % %   else
    % %     if size(VA_TRANS.f.classSubDir,2) == 1
    % %         % result.perm{par_ID}...
    % %         result.perm{par_ID} = parTMP_eval{par_ID+1}{1,1};
    % %     else
    % %         % result.perm{par_ID}{classSubDirID}...
    % %         result.perm{par_ID} = parTMP_eval{par_ID+1};
    % %     end
    % %   end
    % % end
    % % clearvars parTMP_eval
    if w.parCore.parforUsed == 0
     for par_ID = 0 : VA_TRANS.c.eval.permut_number
       
%        try 
        parTMP_eval{par_ID+1} = VAv2_FBCSP_offline_trainTest_taskManager_func_01(VA_TRANS, par_ID, 0);
%        catch
        % fprintf(['TM(',num2str(perm_ID),') trainTest: ',num2str(wm_taskID),'/',num2str(size(TM.taskParam,1)),'\n'])
%         fprintf(['TM(',num2str(par_ID),'): catched\n'])
%         parTMP_eval{par_ID+1} = '';
%        end
        
     end
    elseif w.parCore.parforUsed == 1
     % parfor par_ID = 0 : VA_TRANS.c.eval.permut_number
     %   
     %  try
     %   parTMP_eval{par_ID+1} = VAv2_FBCSP_offline_trainTest_taskManager_func_01(VA_TRANS, par_ID);
     %  catch
     %   % fprintf(['TM(',num2str(perm_ID),') trainTest: ',num2str(wm_taskID),'/',num2str(size(TM.taskParam,1)),'\n'])
     %   fprintf(['TM(',num2str(par_ID),'): catched\n'])
     %   parTMP_eval{par_ID+1} = '';
     %  end
     %   
     % end
     if VA_TRANS.T1_tryCounter == 1
      parfor par_ID = 0 : VA_TRANS.c.eval.permut_number
        
       try
        parTMP_eval{par_ID+1} = VAv2_FBCSP_offline_trainTest_taskManager_func_01(VA_TRANS, par_ID, 0);
       catch
        % fprintf(['TM(',num2str(perm_ID),') trainTest: ',num2str(wm_taskID),'/',num2str(size(TM.taskParam,1)),'\n'])
        fprintf(['TM(',num2str(par_ID),'): catched\n'])
        parTMP_eval{par_ID+1} = '';
       end
        
      end
     else
      parfor par_ID = 0 : VA_TRANS.c.eval.permut_number
        
        parTMP_eval{par_ID+1} = VAv2_FBCSP_offline_trainTest_taskManager_func_01(VA_TRANS, par_ID, 0);
        
      end
     end
    elseif w.parCore.parforUsed == 2
%      spmd
%        mkdir(['myfolder' num2str(labindex)]) 
%      end
%      spmd
%        back=cd;
%        cd(['myfolder' num2str(labindex)]);
%        %do stuff...
%        cd(back)
%      end
     % spmd
     %   perm_ID = labindex-1;
     for perm_ID = 0 : VA_TRANS.c.eval.permut_number
       if isdir([VA_TRANS.f.baseDir,'\',VA_TRANS.f.A09_EEG_validation.subDir,num2str(perm_ID)])
         rmdir([VA_TRANS.f.baseDir,'\',VA_TRANS.f.A09_EEG_validation.subDir,num2str(perm_ID)],'s');
       end
       if isdir([VA_TRANS.f.baseDir,'\',VA_TRANS.f.A11_offlineClass_classSetup.subDir,num2str(perm_ID)])
         rmdir([VA_TRANS.f.baseDir,'\',VA_TRANS.f.A11_offlineClass_classSetup.subDir,num2str(perm_ID)],'s');
       end
       mkdir([VA_TRANS.f.baseDir,'\',VA_TRANS.f.A09_EEG_validation.subDir,num2str(perm_ID),'\',VA_TRANS.f.classSubDir{1}])
       copyfile([VA_TRANS.f.baseDir,'\',VA_TRANS.f.A09_EEG_validation.subDir,'\',VA_TRANS.f.classSubDir{1},'\A09_EEG_validation_01 [EEG_validation].mat'], ...
                [VA_TRANS.f.baseDir,'\',VA_TRANS.f.A09_EEG_validation.subDir,num2str(perm_ID),'\',VA_TRANS.f.classSubDir{1},'\A09_EEG_validation_01 [EEG_validation].mat']);
       if ~isdir([VA_TRANS.f.baseDir,'\',VA_TRANS.f.A11_offlineClass_classSetup.subDir,num2str(perm_ID)])
         mkdir([VA_TRANS.f.baseDir,'\',VA_TRANS.f.A11_offlineClass_classSetup.subDir,num2str(perm_ID),'\',VA_TRANS.f.classSubDir{1}])
       end
       copyfile([VA_TRANS.f.baseDir,'\',VA_TRANS.f.A11_offlineClass_classSetup.subDir,'\',VA_TRANS.f.classSubDir{1},'\A11_offlineClass_classSetup_01 [autorun].mat'], ...
                [VA_TRANS.f.baseDir,'\',VA_TRANS.f.A11_offlineClass_classSetup.subDir,num2str(perm_ID),'\',VA_TRANS.f.classSubDir{1},'\A11_offlineClass_classSetup_01 [autorun].mat']);
       copyfile([VA_TRANS.f.baseDir,'\',VA_TRANS.f.A11_offlineClass_classSetup.subDir,'\',VA_TRANS.f.classSubDir{1},'\A11_offlineClass_classSetup_01 [config].mat'], ...
                [VA_TRANS.f.baseDir,'\',VA_TRANS.f.A11_offlineClass_classSetup.subDir,num2str(perm_ID),'\',VA_TRANS.f.classSubDir{1},'\A11_offlineClass_classSetup_01 [config].mat']);
       copyfile([VA_TRANS.f.baseDir,'\',VA_TRANS.f.A11_offlineClass_classSetup.subDir,'\',VA_TRANS.f.classSubDir{1},'\classTrials{1,1}.mat'], ...
                [VA_TRANS.f.baseDir,'\',VA_TRANS.f.A11_offlineClass_classSetup.subDir,num2str(perm_ID),'\',VA_TRANS.f.classSubDir{1},'\classTrials{1,1}.mat']);
     end
     % spmd
     %   perm_ID = labindex-1;
     %   parTMP_eval{perm_ID+1} = VAv2_FBCSP_offline_trainTest_taskManager_func_01(VA_TRANS, perm_ID, 1);
     % end
     if VA_TRANS.T1_tryCounter == 1
      parfor par_ID = 0 : VA_TRANS.c.eval.permut_number
        
       try
        parTMP_eval{par_ID+1} = VAv2_FBCSP_offline_trainTest_taskManager_func_01(VA_TRANS, par_ID, 1);
       catch
        % fprintf(['TM(',num2str(perm_ID),') trainTest: ',num2str(wm_taskID),'/',num2str(size(TM.taskParam,1)),'\n'])
        fprintf(['TM(',num2str(par_ID),'): catched\n'])
        parTMP_eval{par_ID+1} = '';
       end
        
      end
     else
      parfor par_ID = 0 : VA_TRANS.c.eval.permut_number
        
        parTMP_eval{par_ID+1} = VAv2_FBCSP_offline_trainTest_taskManager_func_01(VA_TRANS, par_ID, 1);
        
      end
     end
     % spmd
     %   perm_ID = labindex-1;
     for perm_ID = 0 : VA_TRANS.c.eval.permut_number
       rmdir([VA_TRANS.f.baseDir,'\',VA_TRANS.f.A09_EEG_validation.subDir,num2str(perm_ID)],'s');
       if isdir([VA_TRANS.f.baseDir,'\',VA_TRANS.f.A11_offlineClass_classSetup.subDir,num2str(perm_ID)])
         rmdir([VA_TRANS.f.baseDir,'\',VA_TRANS.f.A11_offlineClass_classSetup.subDir,num2str(perm_ID)],'s');
       end
     end
    end
    for par_ID = 0
        if size(VA_TRANS.f.classSubDir,2) == 1
            % result.orig...
            result.orig = parTMP_eval{par_ID+1}{1,1};
        else
            % result.orig{classSubDirID}...
            result.orig = parTMP_eval{par_ID+1};
        end
    end
    if VA_TRANS.c.eval.permut_number > 0
     wm_ok = 0;
     for par_ID = 1 : VA_TRANS.c.eval.permut_number
      if ~isempty(parTMP_eval{par_ID+1})
        wm_ok = wm_ok +1;
        parTMP2_eval{wm_ok} = parTMP_eval{par_ID+1};
      end
     end
     clearvars parTMP_eval
     if wm_ok < VA_TRANS.c.eval.permut_number_min
      fprintf('wm_ok < VA_TRANS.c.eval.permut_number_min\n');
      BREAK_WITH_ERROR__NOT_ENOUGH_PERM_RESULT_OK
     end
     for wm_ok = 1 : size(parTMP2_eval,2)
        if size(VA_TRANS.f.classSubDir,2) == 1
            % result.perm{par_ID}...
            result.perm{wm_ok} = parTMP2_eval{wm_ok}{1,1};
        else
            % result.perm{par_ID}{classSubDirID}...
            result.perm{wm_ok} = parTMP2_eval{wm_ok};
        end
     end
     clearvars parTMP2_eval
    end
    
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
    % !!!!!!!!!!!!!! THE CODE FROM HERE NOT SUPPORTS SETUP WITH MORE THAN ONE classSubDirID !!!!!!!!!!!!!! 
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
    
    
    
    
    
  % ______________________
  % 
  % base info (for result)
  % ______________________
  
for wm_subDirID = 1 : size(VA_TRANS.f.classSubDir,2)
  result.orig.basis.ssr_text = VA_TRANS.subjID_text;
  
  wm_folds = size(result.orig.DA.opt.testFold_DA_Plots,1);
  result.orig.basis.testFoldNumber = wm_folds;
  wm_subjID2 = 1;
  wm_sessionID2 = 1;
  w.f.load.path = [VA_TRANS.f.baseDir,'\',VA_TRANS.f.A10_offlineClass_prep.subDir,'\',VA_TRANS.f.classSubDir{wm_subDirID},'\'];
  w.f.load.name = ['tr{',num2str(wm_subjID2),',',num2str(wm_sessionID2),'}.mat'];
  fprintf(['Loading ',w.f.load.name,' ...\n']);
  load([w.f.load.path,w.f.load.name]);
  tr{wm_subjID2,wm_sessionID2} = copy_of_tr{wm_subjID2,wm_sessionID2};
  clear copy_of_tr
  for wm_classID = 1 : size(tr{wm_subjID2,wm_sessionID2},2)
    result.orig.basis.allTrials_per_class(1,wm_classID) = size(tr{wm_subjID2,wm_sessionID2}{end,wm_classID},3);
  end
  result.orig.basis.trainTrials_per_class = result.orig.basis.allTrials_per_class * ((wm_folds-1)/wm_folds);
  result.orig.basis.testTrials_per_class = result.orig.basis.allTrials_per_class / wm_folds;
  
  result.orig.basis.allTrials = sum(result.orig.basis.allTrials_per_class);
  result.orig.basis.trainTrials = sum(result.orig.basis.trainTrials_per_class);
  result.orig.basis.testTrials = sum(result.orig.basis.testTrials_per_class);
end
  
    % __________________________________________________________
    % 
    % Copy optimal Axx directory (including optimal wo_matrix +)
    % __________________________________________________________
    
    % wm1 = [VA_TRANS.f.baseDir,'\+ FBCSP0\',VA_TRANS.f.classSubDir{1},'\A',subFunc_num2str_2digit(result.orig{1, 1}.opt_tt.optionID),'\'];
    wm1 = [VA_TRANS.f.baseDir,'\+ FBCSP0\',VA_TRANS.f.classSubDir{1},'\A',subFunc_num2str_2digit(result.orig.opt_tt.optionID),'\'];

    wm_save_subDir = '- opt FBCSP';
    mkdir(VA_TRANS.f.baseDir, wm_save_subDir);
    wm2 = [VA_TRANS.f.baseDir,'\',wm_save_subDir,'\'];
    
    copyfile([wm1,'*.*'],wm2);
    
    % ___________________
    % 
    % Combined Perms
    % ______________
    
if isfield(result,'perm')
    
    % Perm DA
    % _______
    
    wm2 = 0;
    for wm1 = 1 : size(result.perm,2)
      wm = size(result.perm{1, wm1}.DA.opt.foldValues_at_refPeakPoint,1);
      w.perm_DA_opt_refPeak(1, wm2+1:wm2+wm) = result.perm{1, wm1}.DA.opt.foldValues_at_refPeakPoint(:,1)';
      w.perm_DA_opt_taskPeak(1, wm2+1:wm2+wm) = result.perm{1, wm1}.DA.opt.foldValues_at_taskPeakPoint(:,1)';
      w.perm_DA_smooth_refPeak(1, wm2+1:wm2+wm) = result.perm{1, wm1}.DA.smooth.foldValues_at_refPeakPoint(:,1)';
      w.perm_DA_smooth_taskPeak(1, wm2+1:wm2+wm) = result.perm{1, wm1}.DA.smooth.foldValues_at_taskPeakPoint(:,1)';
      
      w.perm_DA_opt_atOrigRefPeak(1, wm2+1:wm2+wm) = result.perm{1, wm1}.DA.opt.testFold_DA_Plots(:, result.orig.opt_tt.ref_wtID)';
      w.perm_DA_opt_atOrigTaskPeak(1, wm2+1:wm2+wm) = result.perm{1, wm1}.DA.opt.testFold_DA_Plots(:, result.orig.opt_tt.task_wtID)';
      
      w.perm_DA_smooth_atOrigSmoothRefPeak(1, wm2+1:wm2+wm) = result.perm{1, wm1}.DA.smooth.testFold_DA_Plots(:, result.orig.opt_tt.smooth_ref_wtID)';
      w.perm_DA_smooth_atOrigSmoothTaskPeak(1, wm2+1:wm2+wm) = result.perm{1, wm1}.DA.smooth.testFold_DA_Plots(:, result.orig.opt_tt.smooth_task_wtID)';
      wm2 = wm2 + wm;
    end
    result.all_perms.DA.opt.permSpecific__refPeakDA_mean = mean(w.perm_DA_opt_refPeak);
    result.all_perms.DA.opt.permSpecific__refPeakDA_std = std(w.perm_DA_opt_refPeak);
    result.all_perms.DA.opt.permSpecific__taskPeakDA_mean = mean(w.perm_DA_opt_taskPeak);
    result.all_perms.DA.opt.permSpecific__taskPeakDA_std = std(w.perm_DA_opt_taskPeak);
    result.all_perms.DA.smooth.permSpecific__refPeakDA_mean = mean(w.perm_DA_smooth_refPeak);
    result.all_perms.DA.smooth.permSpecific__refPeakDA_std = std(w.perm_DA_smooth_refPeak);
    result.all_perms.DA.smooth.permSpecific__taskPeakDA_mean = mean(w.perm_DA_smooth_taskPeak);
    result.all_perms.DA.smooth.permSpecific__taskPeakDA_std = std(w.perm_DA_smooth_taskPeak);
    
    result.all_perms.DA.opt.perm_DA_mean__atOrigRefPeak = mean(w.perm_DA_opt_atOrigRefPeak);
    result.all_perms.DA.opt.perm_DA_std__atOrigRefPeak = std(w.perm_DA_opt_atOrigRefPeak);
    result.all_perms.DA.opt.perm_DA_mean__atOrigTaskPeak = mean(w.perm_DA_opt_atOrigTaskPeak);
    result.all_perms.DA.opt.perm_DA_std__atOrigTaskPeak = std(w.perm_DA_opt_atOrigTaskPeak);
    result.all_perms.DA.smooth.perm_DA_mean__atOrigSmoothRefPeak = mean(w.perm_DA_smooth_atOrigSmoothRefPeak);
    result.all_perms.DA.smooth.perm_DA_std__atOrigSmoothRefPeak = std(w.perm_DA_smooth_atOrigSmoothRefPeak);
    result.all_perms.DA.smooth.perm_DA_mean__atOrigSmoothTaskPeak = mean(w.perm_DA_smooth_atOrigSmoothTaskPeak);
    result.all_perms.DA.smooth.perm_DA_std__atOrigSmoothTaskPeak = std(w.perm_DA_smooth_atOrigSmoothTaskPeak);
    
    % MonteCarlo perm test p-value calc
    % _________________________________
    
    %  MonteCarlo permotation test p-value = n/N | n: at how many premuation tests where permTest-DA (foldMean) at original peak >= original DA peak (foldMean) | N: number of permutation tests 

    wm2 = 0;
    for wm1 = 1 : size(result.perm,2)
      wm2 = wm2 +1;
      w.perm_DA_opt_mean_permSpec_refPeak(1, wm2) = mean(result.perm{1, wm1}.DA.opt.foldValues_at_refPeakPoint(:,1));
      w.perm_DA_opt_mean_permSpec_taskPeak(1, wm2) = mean(result.perm{1, wm1}.DA.opt.foldValues_at_taskPeakPoint(:,1));
      w.perm_DA_smooth_mean_permSpec_refPeak(1, wm2) = mean(result.perm{1, wm1}.DA.smooth.foldValues_at_refPeakPoint(:,1));
      w.perm_DA_smooth_mean_permSpec_taskPeak(1, wm2) = mean(result.perm{1, wm1}.DA.smooth.foldValues_at_taskPeakPoint(:,1));
      
      w.perm_DA_opt_mean_atOrigRefPeak(1, wm2) = mean(result.perm{1, wm1}.DA.opt.testFold_DA_Plots(:, result.orig.opt_tt.ref_wtID));
      w.perm_DA_opt_mean_atOrigTaskPeak(1, wm2) = mean(result.perm{1, wm1}.DA.opt.testFold_DA_Plots(:, result.orig.opt_tt.task_wtID));
      w.perm_DA_smooth_mean_atOrigSmoothRefPeak(1, wm2) = mean(result.perm{1, wm1}.DA.smooth.testFold_DA_Plots(:, result.orig.opt_tt.smooth_ref_wtID));
      w.perm_DA_smooth_mean_atOrigSmoothTaskPeak(1, wm2) = mean(result.perm{1, wm1}.DA.smooth.testFold_DA_Plots(:, result.orig.opt_tt.smooth_task_wtID));
    end
    
    result.all_perms.mc_p.opt.permSpec_refPeakDA_VS_origRefPeakDA = ...
        size(find(w.perm_DA_opt_mean_permSpec_refPeak(1,:) >= result.orig.DA.opt.refPeakDA_mean),2) / size(result.perm,2);
    result.all_perms.mc_p.opt.permSpec_taskPeakDA_VS_origTaskPeakDA = ...
        size(find(w.perm_DA_opt_mean_permSpec_taskPeak(1,:) >= result.orig.DA.opt.taskPeakDA_mean),2) / size(result.perm,2);
    result.all_perms.mc_p.smooth.permSpec_smoothRefPeakDA_VS_origSmoothRefPeakDA = ...
        size(find(w.perm_DA_smooth_mean_permSpec_refPeak(1,:) >= result.orig.DA.smooth.refPeakDA_mean),2) / size(result.perm,2);
    result.all_perms.mc_p.smooth.permSpec_smoothTaskPeakDA_VS_origSmoothTaskPeakDA = ...
        size(find(w.perm_DA_smooth_mean_permSpec_taskPeak(1,:) >= result.orig.DA.smooth.taskPeakDA_mean),2) / size(result.perm,2);
    
    result.all_perms.mc_p.opt.permDA_atOrigRefPeak_VS_origRefPeakDA = ...
        size(find(w.perm_DA_opt_mean_atOrigRefPeak(1,:) >= result.orig.DA.opt.refPeakDA_mean),2) / size(result.perm,2);
    result.all_perms.mc_p.opt.permDA_atOrigTaskPeak_VS_origTaskPeakDA = ...
        size(find(w.perm_DA_opt_mean_atOrigTaskPeak(1,:) >= result.orig.DA.opt.taskPeakDA_mean),2) / size(result.perm,2);
    result.all_perms.mc_p.smooth.permDA_atOrigSmoothRefPeak_VS_origSmoothRefPeakDA = ...
        size(find(w.perm_DA_smooth_mean_atOrigSmoothRefPeak(1,:) >= result.orig.DA.smooth.refPeakDA_mean),2) / size(result.perm,2);
    result.all_perms.mc_p.smooth.permDA_atOrigSmoothTaskPeak_VS_origSmoothTaskPeakDA = ...
        size(find(w.perm_DA_smooth_mean_atOrigSmoothTaskPeak(1,:) >= result.orig.DA.smooth.taskPeakDA_mean),2) / size(result.perm,2);
end
    
    
    
    
    % ___________________________________________________
    % 
    % DA plot (opt original and opt permuted in one plot)
    % ___________________________________________________
    
    SW.annotation.refDA = 1;
    SW.annotation.permDA_ifExist = 1;
    
    SW.smoothed_plot = 0;
    VAv2_Spec_shaded_DA_plot
    
    SW.smoothed_plot = 1;
    VAv2_Spec_shaded_DA_plot
    
    
    
    % ________________________________________
    % 
    % Freq and Topoplot based on peak DA setup
    % ________________________________________
    
    fprintf(['Preparing Freq and Topoplots\n'])
    FUNC_IN = TM.taskParam{wm_taskID,1}.c.eval;
    
      % Evaluation Setup (for Hacked Freq & Topoplot)
      % _____________________________________________
      
      FUNC_IN.SW.eval_used = 1;                  % =1: evaluation run by taskManager after trainTest
      FUNC_IN.SW.figures_visible = 'on';         % 'on':figures displayed, 'off': not displayed (only saved)
      % FUNC_IN.SW.figures_visible = 'off';        % 'on':figures displayed, 'off': not displayed (only saved)
      
      % FUNC_IN.SW.plot_shaded_DA = 0;
      % FUNC_IN.SW.plot_paramEval = 0;
      % FUNC_IN.SW.plot_freqEval_v1 = 0;
      % FUNC_IN.SW.plot_freqEval_v2 = 0;
      % FUNC_IN.SW.plot_freqEval_v3 = 0;
      FUNC_IN.SW.plot_topoplot_CSPMI = 1;
      FUNC_IN.SW.plot_freqEval_v4 = 1;
      % FUNC_IN.SW.plot_topoplot_ERDS = 0;
      
      % File Setup (for Hacked Freq & Topoplot)
      % _______________________________________
      
      % TM.taskParam{wm_taskID,1}.c.eval.w.file.load.autoload = TM.taskParam{wm_taskID,1}.autorun.tt.file.save.autosave;
      % TM.taskParam{wm_taskID,1}.c.eval.w.file.load.path = TM.taskParam{wm_taskID,1}.autorun.tt.file.save.path.offlineClass_trainTest;
      % TM.taskParam{wm_taskID,1}.c.eval.w.file.load.nameBasis1 = TM.taskParam{wm_taskID,1}.autorun.tt.file.save.nameBasis.offlineClass_trainTest;
      % TM.taskParam{wm_taskID,1}.c.eval.w.file.load_chanlocs.path = TM.taskParam{wm_taskID,1}.autorun.tt.file.save.path.offlineClass_trainTest;
      FUNC_IN.w.file.load.autoload = 1;
      FUNC_IN.w.file.load.path = ...
          [VA_TRANS.f.baseDir,'\+ FBCSP0\',VA_TRANS.f.classSubDir{1},'\A',subFunc_num2str_2digit(result.orig.opt_tt.optionID),'\'];
      FUNC_IN.w.file.load.nameBasis1 = 'FBCSP_offline_trainTest_01';
      FUNC_IN.w.file.load_chanlocs.path = [VA_TRANS.f.baseDir,'\'];
      FUNC_IN.w.file.load_chanlocs.name = VA_TRANS.f.chanlocs_filename;    % 'Standard-10-20-Cap81.locs'  
      
      FUNC_IN.w.file.save.autosave = 1;
      FUNC_IN.w.file.save.path = PLOT.file.save.path;
      
%     % PLOT setup: setup for shaded_DA:
%     % ________________________________
%     
%     c.eval.PLOT.w.ylim = [0,100];
%     % c.eval.PLOT.w.ylim = [10,100];
%     
%     c.eval.PLOT.w.averagedSubjSession_ylim = [0,100];
%     % c.eval.PLOT.w.averagedSubjSession_ylim = [10,100];
%     
%     c.eval.PLOT.w.DA.averagePlotStd_crossFoldOnly = [1,0];    % =1:crossOuterFold STD, =0:crossSubj,Session,OuterFold STD
      
      % PLOT setup: setup for freq map:
      % _______________________________
      
      FUNC_IN.PLOT.w.freqMap.common.colorLimitMax_fix1_auto2 = 2;
      if FUNC_IN.PLOT.w.freqMap.common.colorLimitMax_fix1_auto2 == 1
        FUNC_IN.PLOT.w.freqMap.common.colorLimitMax_fixValue = 1.0;
        % FUNC_IN.PLOT.w.freqMap.common.colorLimitMin_fixValue = 0;
      end
      
      % PLOT setup: common topoplots setup:
      % ___________________________________
      
      FUNC_IN.PLOT.w.topoplot.common.colorLimitMax_fix1_auto2 = 2;
      if FUNC_IN.PLOT.w.topoplot.common.colorLimitMax_fix1_auto2 == 1
        FUNC_IN.PLOT.w.topoplot.common.colorLimitMax_fixValue = 0.45;
      else
        FUNC_IN.PLOT.w.topoplot.common.colorLimitMax_sameAutoForRestAndTask = 1;
      end
      
      % FUNC_IN.PLOT.w.topoplot.common.SW.conv = 'off';
      FUNC_IN.PLOT.w.topoplot.common.SW.conv = 'on';
      
      FUNC_IN.PLOT.w.topoplot.common.wtIDs_restTaskSetup_fix1_auto2 = 2;
      if FUNC_IN.PLOT.w.topoplot.common.wtIDs_restTaskSetup_fix1_auto2 == 1
          % FUNC_IN.PLOT.w.topoplot.common.wtIDs_rest = 1;       % !!!!!!!!!!!! HAVE TO SET BASED ON THE USED DATASET !!!!!!!!!!!! 
          FUNC_IN.PLOT.w.topoplot.common.wtIDs_task = 2:4;     % !!!!!!!!!!!! HAVE TO SET BASED ON THE USED DATASET !!!!!!!!!!!! 
      end
      % % FUNC_IN.PLOT.w.topoplot.common.endOfRestWindow_ms = -1000;    % !!!!!!!!!!!! NO NEED FOR HACKED VERSION !!!!!!!!!!!! 
      
      FUNC_IN.PLOT.w.topoplot.common.minTaskDA_usedTopoplotCalc_subj_session = 0.0;      % only those subjects/session combinations used for calculating topoplots where maxtTaskDA >= this value
      
      % PLOT setup: CSP-MI topoplot setup:
      % __________________________________
      
      FUNC_IN.PLOT.w.topoplot.CSP_MI.used_CSPFilterPairPart = 0;         % =0:all, =1:upper part, =2:lower part
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      % FUNC_IN.PLOT.w.topoplot.CSP_MI.plotted_rest1_task2 = [1,2,0];      % 0: difference of task and rest : abs(task-rest) 
      % FUNC_IN.PLOT.w.topoplot.CSP_MI.plotted_rest1_task2 = 2;       % 0: difference of task and rest : abs(task-rest)
      FUNC_IN.PLOT.w.topoplot.CSP_MI.plotted_rest1_task2 = TM.commonParam.c.eval.SW.topoplot.CSP_MI.plotted_rest1_task2;    % 0: difference of task and rest : abs(task-rest)
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      
      % %   c.eval.PLOT.w.topoplot.CSP_MI.restIntervalWidth_for_collectCSPMIWeights_ms = -1000; 
      
%     % PLOT setup: ERDS topoplot setup:
%     % ________________________________
%     
%     % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%     % .............. MISSING !!!!!!!!!!!!!!!!!!!!
%     % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
% % % % % % % %     % _________
% % % % % % % %     % 
% % % % % % % %     % HDD Setup
% % % % % % % %     % _________
% % % % % % % %     
% % % % % % % %     % w.m = questdlg('Do you want load and save using local or network drive ?','Setup','Load/save to local drive','Load network / save local','Load/save to network','Load/save to local drive');
% % % % % % % %     % if strcmp(w.m,'Load/save to local drive')
% % % % % % % %         autorun.tt.file.load_localDrive1_NetworkDrive2 = 1;
% % % % % % % %         autorun.tt.file.save_localDrive1_NetworkDrive2 = 1;
% % % % % % % %     % elseif strcmp(w.m,'Load network / save local')
% % % % % % % %     %     autorun.tt.file.load_localDrive1_NetworkDrive2 = 2;
% % % % % % % %     %     autorun.tt.file.save_localDrive1_NetworkDrive2 = 1;
% % % % % % % %     % elseif strcmp(w.m,'Load/save to network')
% % % % % % % %     %     autorun.tt.file.load_localDrive1_NetworkDrive2 = 2;
% % % % % % % %     %     autorun.tt.file.save_localDrive1_NetworkDrive2 = 2;
% % % % % % % %     % end
% % % % % % % % 
% % % % % % % % 	% _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
% % % % % % % %     %
% % % % % % % %     % Code 2. taskManager parameter setup: store common parameters + setup for load and save
% % % % % % % % 	% _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
% % % % % % % %     
% % % % % % % %     % Setup for load
% % % % % % % %     % ______________
% % % % % % % %     
% % % % % % % %     autorun.tt.file.load.autoload = 1;
% % % % % % % %     
% % % % % % % %     % A09_EEG_validation_01
% % % % % % % %     autorun.tt.file.load.path.EEG_validation = VA.set.autorun.f.load.path.EEG_validation;
% % % % % % % %     autorun.tt.file.load.nameBasis1.EEG_validation = 'A09_EEG_validation_01';
% % % % % % % %     
% % % % % % % %     % A11_offlineClass_classSetup_01
% % % % % % % %     autorun.tt.file.load.path.offlineClass_classSetup = VA.set.autorun.f.load.path.offlineClass_classSetup;
% % % % % % % %     autorun.tt.file.load.nameBasis1.offlineClass_classSetup = 'A11_offlineClass_classSetup_01';
% % % % % % % %     autorun.tt.file.load.nameBasis1.offlineClass_classSetup_classTrials = 'classTrials';
% % % % % % % %     
% % % % % % % %     % Setup for save (common)
% % % % % % % %     % _______________________
% % % % % % % %     
% % % % % % % %     autorun.tt.file.save.autosave = 1;
% % % % % % % %     autorun.tt.file.save.autosave_w0 = 0;       % =0:NOT save w0 (but this content still saved the w0_matrix)
% % % % % % % %     
% % % % % % % %     autorun.tt.file.save.nameBasis.offlineClass_trainTest = 'FBCSP_offline_trainTest_01';
% % % % % % % %     autorun.tt.file.save.nameBasis.offlineClass_trainTest__w0 = 'w0';    % !!!!!!!!!!! STRUCTURE TO BE SAVED IN AUTORUN LOOP !!!!!!!!!!!! 
% % % % % % % %     
% % % % % % % %     % Option setup for save + store trainTest options
% % % % % % % %     % _______________________________________________
% % % % % % % %     
% % % % % % % %     for wm_taskID = 1 : VA.set.FBCSP.tt_option_number
% % % % % % % %       autorun.tt.file.save.path.offlineClass_trainTest = [VA.f.baseDir,'\',VA.f.FBCSP_offline_trainTest_taskManager.subDir,'\',VA.f.classSubDir{wm_subDirID},'\A',num2str(subFunc_num2str_2digit(wm_taskID)),'\'];
% % % % % % % %       if ~isdir(autorun.tt.file.save.path.offlineClass_trainTest)
% % % % % % % %         mkdir(autorun.tt.file.save.path.offlineClass_trainTest);
% % % % % % % %       end
% % % % % % % %       
% % % % % % % %       TM.taskParam{wm_taskID,1}.autorun = autorun;
% % % % % % % %       
% % % % % % % %       TM.taskParam{wm_taskID,1}.w = w;
% % % % % % % %       TM.taskParam{wm_taskID,1}.SW = SW;
% % % % % % % %       TM.taskParam{wm_taskID,1}.c = c;
% % % % % % % %     end
      
      % HACK setup
      % __________
      
      FUNC_IN.SW.HACKED.used = 1;
      % FUNC_IN.SW.HACKED.freqWval_v4_colormap_change = 2;    % non-default colormap for freqEval_v4 -> =1:(jellow-red), =2:(blue-red)
      
      % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      % !!! HACKED wtID for rest and task !!!
      % _____________________________________
      
      FUNC_IN.SW.HACKED.selected_wtID_forRest = result.orig.timeInfo.wtID_in_DA_plot.opt_peakDAPoint_ref;
      FUNC_IN.SW.HACKED.selected_wtID_forTask = result.orig.timeInfo.wtID_in_DA_plot.opt_peakDAPoint_task;
      
      % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      % !!! HACKED figure close option !!!
      % __________________________________
      
      FUNC_IN.SW.HACKED.close_figures = VA_TRANS.SW_close_figures;

      % _____________
      % 
      % Function call
      % _____________
      
      VAv2_Hacked_VB_FBCSP_eval_figures_func_01(FUNC_IN);
    
    % _________
    % 
    % AUTO SAVE
    % _________

    % Save result structure
    
        % fprintf('Saving VA_TRANS structure ...\n');
        % copy_of_VA_TRANS = VA_TRANS;
        % w.f.save.path = [VA_TRANS.f.baseDir,'\'];
        % w.f.save.name = ['TAv2_TrainTest [VA_TRANS].mat'];
        % save([w.f.save.path,w.f.save.name],'copy_of_VA_TRANS','-v7.3');
        % clear copy_of_VA_TRANS
        fprintf('Saving VA_TRANS structure ...\n');
        w.f.save.path = [VA_TRANS.f.baseDir,'\'];
        w.f.save.name = ['TAv2_TrainTest [VA_TRANS].mat'];
        save([w.f.save.path,w.f.save.name],'VA_TRANS','-v7.3');
    
        % fprintf('Saving result structure ...\n');
        % copy_of_result = result;
        % w.f.save.path = [VA_TRANS.f.baseDir,'\'];
        % w.f.save.name = ['TAv2_TrainTest [result].mat'];
        % save([w.f.save.path,w.f.save.name],'copy_of_result','-v7.3');
        % clear copy_of_result
        fprintf('Saving result structure ...\n');
        w.f.save.path = [VA_TRANS.f.baseDir,'\'];
        w.f.save.name = ['TAv2_TrainTest [result].mat'];
        save([w.f.save.path,w.f.save.name],'result','-v7.3');
    
    
    
    
    
% % % %     % clearvars -except STACK VA_TRANS attempt result
% % % %     % clearvars -except STACK VA_TRANS attempt
% % % %     clearvars -except STACK
% % % % 
% % % % 
% % % % %% Restore Stacked variables (for the case if this code called from other code)
% % % % 
% % % % % ____________________________
% % % % % 
% % % % % Restore variables from STACK
% % % % % ____________________________
% % % % 
% % % % STACK_restore_01


%% Comments

    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
    % !!!!!!!!!!!!! HAVE TO REWRITE FROM HERE !!!!!!!!!!!!! 
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
    
    
%{
figure;
plot(result.orig{1, 1}.DA.testFold_DA_Plots')

figure;
plot(result.perm{1, 1}.eval{1, 1}.DA.testFold_DA_Plots')

figure;
shadedErrorBar([],mean(result.orig{1, 1}.DA.testFold_DA_Plots',2)*100, std(result.orig{1, 1}.DA.testFold_DA_Plots',0,2)*100, 'lineprops','b')
shadedErrorBar([],mean(result.perm{1, 1}.eval{1, 1}.DA.testFold_DA_Plots',2)*100, std(result.perm{1, 1}.eval{1, 1}.DA.testFold_DA_Plots',0,2)*100, 'lineprops','k')
%}


%{

clearvars plotData
plotData = result.orig{1, 1}.DA.testFold_DA_Plots(:,:);

wm1=0;
clearvars plotData2
for wm2 = 1 : size(result.perm,2)
    wm = size(result.perm{1, wm2}.eval{1, 1}.DA.testFold_DA_Plots,1);
    plotData2(wm1+1 : wm1+wm, :) = result.perm{1, wm2}.eval{1, 1}.DA.testFold_DA_Plots(:,:);
    wm1 = wm1+wm;
end

figure;
shadedErrorBar([], mean(plotData,1)*100, std(plotData,1)*100, 'lineprops','b');
shadedErrorBar([], mean(plotData2,1)*100, std(plotData2,1)*100, 'lineprops','k');


figure;
plot(result.orig{1, 1}.DA.testFold_DA_Plots')

figure;
plot(plotData2')


%}






