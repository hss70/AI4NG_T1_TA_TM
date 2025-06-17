% Task manager for: 
% Online Setup Preparation (with func) using Offline Results from FilterBankCSP Multi-class Classification
% (this code call: VC_FBCSP_online_setup_prep_01)

% Input structures

% Output structures
% c.online. ...

% REQUIRESTMENT: Matlab
% Copyright(c)2022 Attila Korik, http://isrc.ulster.ac.uk/akorik/contact.html


function TC_Online_prep_func(V1_TRANS)
 %% VA Setup
 
 % clear; clc;
 
 % Modified CrossRun_cf_TC_Online_prep.m
 % _____________________________________
 
 VA_TRANS.c.eval.FBCSP_option_Axx_used = [1];   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
 % % % % VA_TRANS.c.eval.FBCSP_option_wt_taskOnset_cfWinOffset_ms = [6300];   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
 
 % VA_TRANS.f.baseDir = 'Q:\BCI\DCR\Cybathlon 2019\Results\- work';   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! % =1: task VS relax classification pair used      
 % VA_TRANS.f.baseDir = 'Q:\BCI\DCR\FBCSP 2019\Work';   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! % =1: task VS relax classification pair used      
 VA_TRANS.f.baseDir = [V1_TRANS.f.BaseDir];   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! % =1: task VS relax classification pair used      
%  VA_TRANS.f.load.baseDir_FBCSP = [V1_TRANS.f.BaseDir,'\TrainTest\+ FBCSP']; 
 VA_TRANS.f.load.baseDir_FBCSP = [V1_TRANS.f.BaseDir,'\TrainTest\+ FBCSP0'];
 % % % % VA_TRANS.f.classSubDir{1} = '01 LR';
 % % % % VA_TRANS.f.classSubDir{2} = '02 FR';
 % % % % VA_TRANS.f.classSubDir{3} = '03 LF';
 VA_TRANS.f.classSubDir{1} = 'EEG';
 VA_TRANS.f.SW.task_vs_relax_CP_used = 0;   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! % =1: task VS relax classification pair used      
 % % % % VA_TRANS.f.SW.task_vs_relax_CP_used = 1;   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! % =1: task VS relax classification pair used      
 % % % % if VA_TRANS.f.SW.task_vs_relax_CP_used
 % % % %     VA_TRANS.f.classSubDir{4} = '04 TX';
 % % % % end
 VA_TRANS.f.load.nameBasis1_FBCSP = 'FBCSP_offline_trainTest_01'; 
 
 VA_TRANS.f.save.baseDir = [VA_TRANS.f.baseDir,'\Online'];
 VA_TRANS.f.save.nameBasis1 = 'FBCSP_online_setup_prep_01';
 
 VA_TRANS.c.SW.CFx = 1;      % =1:Classification use 1 CF lane (target vs others),  =2:Classification use difference of 2 CF lanes (target vs others - others vs target) 
 
 % PLUS
 % ____
 
 % % % %   % Load T1 [resultTable].mat and denote VA_TRANS.c.eval.FBCSP_option_wt_taskOnset_cfWinOffset_ms
 % % % %   % _____________________________________________________________________________________________
 % % % %   
 % % % %   load([V1_TRANS.f.Input_T1_BaseDir,'\T1\T1 [resultTable].mat']);
 % % % %   VA_TRANS.c.eval.FBCSP_option_wt_taskOnset_cfWinOffset_ms = T1_result_table(V1_TRANS.wm_taskID,1).taskPeak_ms;
 
   % Load TAv2_TrainTest [result].mat and denote FUNC_IN.wtID(wm_subDirID)
   % _____________________________________________________________________
   
   % VA_TRANS.c.eval.FBCSP_option_wt_taskOnset_cfWinOffset_ms = T1_result_table(V1_TRANS.wm_taskID,1).taskPeak_ms;
% % % %    tmp = load([V1_TRANS.f.Input_T1_BaseDir,'\T1\Param\',V1_TRANS.tr_subDir_list{V1_TRANS.wm_taskID},'\TAv2_TrainTest [result].mat']);
   V1_TRANS.f.Input_T1_BaseDir = V1_TRANS.f.BaseDir;
   tmp = load([V1_TRANS.f.Input_T1_BaseDir,'\T1\Param\',V1_TRANS.tr_subDir_list{V1_TRANS.wm_taskID},'\TAv2_TrainTest [result].mat']);
   % VA_TRANS.c.eval.FBCSP_option_wt_taskOnset_cfWinOffset_ms = tmp.result.orig.timeInfo.ms_from_PRE_point.opt_peakDAPoint_task - tmp.result.orig.timeInfo.ms_from_PRE_point.trig;
   VA_TRANS.c.eval.FBCSP_option_wt_taskOnset_cfWinOffset_ms = tmp.result.orig.timeInfo.ms_fromTrig.opt_peakDAPoint_task;
   clearvars tmp
 
 
 %% TaskManager code
 
 VA = VA_TRANS;
 CrossRun_VC_FBCSP_online_setup_prep_01
 
 
 
 
 
 
 
end


%% Comments





