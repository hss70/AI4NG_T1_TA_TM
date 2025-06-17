% FilterBankCSP Multi-class Classification, offline EEG trainTest taskManager function 

% Input structures
% VA_TRANS

% Output structures

% REQUIRESTMENT: Matlab
% Copyright(c)2020 Attila Korik, http://isrc.ulster.ac.uk/akorik/contact.html


%% code

% function VA_TRANS = VAv2_FBCSP_offline_trainTest_taskManager_func_01(VA_TRANS)
function VA_TRANS__eval = VAv2_FBCSP_offline_trainTest_taskManager_func_01(VA_TRANS, perm_ID, parDir_used1)
% % % function VA_FBCSP_offline_trainTest_taskManager_func_01(FUNC_IN)
% % % 
% % VA_TRANS = FUNC_IN;
% % clearvars FUNC_IN

% !!!!!!!!!!!!!!!!!!!!!
    VA_TRANS.f.FBCSP_offline_trainTest_taskManager.subDir = [VA_TRANS.f.FBCSP_offline_trainTest_taskManager.subDir, num2str(perm_ID)];
% !!!!!!!!!!!!!!!!!!!!!



for wm_subDirID = 1 : size(VA_TRANS.f.classSubDir,2)
% for wm_subDirID = [1,3,4]
    VA = VA_TRANS;
    % fprintf([VA_TRANS.f.FBCSP_offline_trainTest_taskManager.subDir,' (',VA_TRANS.f.classSubDir{wm_subDirID},'):\n']);
    
    % % % Parfor drive setup
    % % % ___________________
    % % 
    % % % VA.set.w.parCore.parforUsed = 0;       % =0:parfor NOT used, =1:parfor (will initialized and used during code execution)
    % % w.parCore.parforUsed = 1;       % =0:parfor NOT used, =1:parfor (will initialized and used during code execution)
    % % if w.parCore.parforUsed == 1
    % %     % w.parCore.location = 'HPCServerProfile1';
    % %     % w.parCore.number_basis = -1;    % >0:number of parfor cores, =-1:number of used cores will equal:(size(autorun.tt.used.subjects,2) * size(autorun.tt.used.sessions,2) * c.tt.folds.outerFoldNumber) 
    % %     % % w.parCore.number_basis = 60;    % >0:number of parfor cores, =-1:number of used cores will equal:(size(autorun.tt.used.subjects,2) * size(autorun.tt.used.sessions,2) * c.tt.folds.outerFoldNumber) 
    % %     % w.parCore.reOpenIfOpen = 0;     % =1:close and open with w.parCore.number at start, =0:keep open with the same workers if open 
    % %     % w.parCore.closeAtEnd = 0;       % =1:close parpool after run, =0:keep open parpool after run 
    % % 
    % %     %  !!! THIS IS FOR 4-core RUN !!!
    % %     w.parCore.location = 'local';
    % %     w.parCore.number_basis = 4;    % >0:number of parfor cores, =-1:number of used cores will equal:(size(autorun.tt.used.subjects,2) * size(autorun.tt.used.sessions,2) * c.tt.folds.outerFoldNumber) 
    % %     w.parCore.reOpenIfOpen = 0;     % =1:close and open with w.parCore.number at start, =0:keep open with the same workers if open 
    % %     w.parCore.closeAtEnd = 0;       % =1:close parpool after run, =0:keep open parpool after run 
    % % 
    % %     % %  !!! THIS IS FOR 6-core RUN !!!
    % %     % w.parCore.location = 'local';
    % %     % w.parCore.number_basis = 6;    % >0:number of parfor cores, =-1:number of used cores will equal:(size(autorun.tt.used.subjects,2) * size(autorun.tt.used.sessions,2) * c.tt.folds.outerFoldNumber) 
    % %     % w.parCore.reOpenIfOpen = 0;     % =1:close and open with w.parCore.number at start, =0:keep open with the same workers if open 
    % %     % w.parCore.closeAtEnd = 0;       % =1:close parpool after run, =0:keep open parpool after run 
    % % end
    
    % Check how many options has been setted up for tt in "func_FBCSP_tt_option_setup" 
    % ________________________________________________________________________________
    
    % % VA_TRANS.set.FBCSP.tt_option_number = 8;    % !!!!!!!!!! HAVE TO SET THIS BASED ON OPTIONS IN "func_FBCSP_tt_option_setup" !!!!!!!!!!!!
    
    TM.NA='';
    TM = func_FBCSP_tt_option_setup(VA_TRANS, TM);
w.parCore = TM.parfor.core;
    % TM = TA_TrainTest__func_FBCSP_tt_option_setup(VA_TRANS, TM);
    VA.set.FBCSP.tt_option_number = size(TM.taskParam,1);
    clearvars TM
    
    % TM setup for FBCSP trainTest
    % ____________________________
    
    % VA.set.autorun.f.load.path.EEG_validation = [VA_TRANS.f.baseDir,'\',VA_TRANS.f.A09_EEG_validation.subDir,'\',VA_TRANS.f.classSubDir{wm_subDirID},'\'];
    % VA.set.autorun.f.load.path.offlineClass_classSetup = [VA_TRANS.f.baseDir,'\',VA_TRANS.f.A11_offlineClass_classSetup.subDir,'\',VA_TRANS.f.classSubDir{wm_subDirID},'\'];
    if parDir_used1 == 1
      wm_parDir_txt = num2str(perm_ID);
    else
      wm_parDir_txt = '';
    end
    VA.set.autorun.f.load.path.EEG_validation = [VA_TRANS.f.baseDir,'\',VA_TRANS.f.A09_EEG_validation.subDir,wm_parDir_txt,'\',VA_TRANS.f.classSubDir{wm_subDirID},'\'];
    VA.set.autorun.f.load.path.offlineClass_classSetup = [VA_TRANS.f.baseDir,'\',VA_TRANS.f.A11_offlineClass_classSetup.subDir,wm_parDir_txt,'\',VA_TRANS.f.classSubDir{wm_subDirID},'\'];
    
    TM = func_FBCSP_tt_basis_setup(VA, wm_subDirID, w);
    TM = func_FBCSP_tt_option_setup(VA_TRANS, TM);
    
    % FBCSP trainTest call
    % ____________________
    func_FBCSP_tt_call(TM, perm_ID);
    
    % Collect DA plots from resulted TrainTest directories
    % ____________________________________________________
    if TM.commonParam.c.eval.SW.taskFigPrep_used == 1      % =1: taskFigure preparation run by taskManager after trainTest 
        VPlus_FBCSP_collectDAPlots_from_trainTest_01;
    end
    
    % FBCSP DA eval
    % _____________
    if TM.commonParam.c.eval.SW.DA_eval_used == 1      % =1: DA_eval run by taskManager after trainTest done for all tasks
        
      % eval.opt_tt...
      % eval.DA....
      % eval.RT_stat....
      % eval.timeInfo....
      
% %         func_in1.ssr_text = VA.subjID_text;
% %         func_in1.f = VA.f;
% %         func_in1.wm_subDirID = wm_subDirID;
% %         [eval.basis, eval.opt_tt, eval.timeInfo, eval.DA, eval.RT_stat] = func_FBCSP_eval(func_in1, TM, perm_ID);
        [eval.opt_tt, eval.timeInfo, eval.DA, eval.RT_stat] = func_FBCSP_eval(TM, perm_ID);
        
%         [xxx1, xxx2] = func_FBCSP_permutTest(TM);
        
% If not permTest -> add w0_matrix (for parameters)
        
        
        
    end
    
    % Copy Standard-10-20-Cap81.locs file to TrainTest directory
    % __________________________________________________________
    
    if perm_ID == 0
      fprintf(['Copy: ',VA_TRANS.f.chanlocs_filename,' ...\n'])
      % copyfile([VA_TRANS.f.chanlocs_path,'\',VA_TRANS.f.chanlocs_filename], [VA_TRANS.f.baseDir,'\',VA_TRANS.f.chanlocs_filename]);
      copyfile([VA_TRANS.f.workDir,'\',VA_TRANS.f.chanlocs_filename], [VA_TRANS.f.baseDir,'\',VA_TRANS.f.chanlocs_filename]);
      fprintf('DONE.\n')
    end
    
    
    
    VA_TRANS.eval{wm_subDirID} = eval;
    
    clearvars -except STACK VA_TRANS
end

VA_TRANS__eval = VA_TRANS.eval;
end






%% Functions

function wf_out_str = subFunc_num2str_2digit(wf_in_num)
    % function call test:
    % fprintf([subFunc_num2str_2digit(2),'...\n']);
    if wf_in_num < 10
        wf_out_str = ['0',num2str(wf_in_num)];
    else
        wf_out_str = num2str(wf_in_num);
    end
end


%% Function: FBCSP trainTest basis setup

function TM = func_FBCSP_tt_basis_setup(VA, wm_subDirID, w)

    % INFO
    % ____

    % TM = task manager

    % p = param
    % tt = trainTest
    % cf = classifier
    
    % ___________________
    % 
    % Code printing setup
    % ___________________
    
    SW.print_trainTest_details = VA.SW_print_trainTest_details;
    
    % ___________________
    % 
    % Network drive setup
    % ___________________
    
    autorun.tt.file.network.networkLabel = '\\isrchn1\userdata\sb00647025';

    % _____________________
    % 
    % Config: autorun setup
    % _____________________
    
    SW.loadFrom_classSetup_file.autorun_tt_used_subjects = 1;       % =1:same as was for classSetup (will be loaded from classSetup autorun file)
    if SW.loadFrom_classSetup_file.autorun_tt_used_subjects == 0
        % autorun.tt.used.subjects = 1:10;
        % autorun.tt.used.sessions = 1:1;
    end
    
    % _____________________
    % 
    % Config: session setup
    % _____________________
    
    c.tt.session.use_allSessionsTogether = 0;    % =1: combine classTrial datasets together from all sessions, =0:handle separately 
    
    % ____________________________
    % 
    % Config: classification setup
    % ____________________________
    
    SW.loadFrom_classSetup_file.c_tt_usedBandIDs = 1;       % =1:same as was for classSetup (will be loaded from classSetup autorun file)
    if SW.loadFrom_classSetup_file.c_tt_usedBandIDs == 0
        % c.tt.usedBandIDs = 1:6;    % from preprocessed EEG data with these bandIDs will be used for trainTest
    end
    
    c.tt.cf.p.winSize.ms = 2000;    % classifier window size in ms
    % c.tt.cf.p.winSize.samp = round((c.tt.cf.p.winSize.ms/1000)*c.tt.sr);    % classifier window size in samples (e.g., (2000[ms]/1000[ms/s])*120[samp/s] = 240)
    c.tt.cf.p.winStep.ms = 200;     % classification steps in ms (steps of classifier window in looped calculation across the used trial interval)
    % c.tt.cf.p.winStep.samp = round((c.tt.cf.p.winStep.ms/1000)*c.tt.sr);    % classification steps in samples (e.g., (200[ms]/1000[ms/s])*120[samp/s] = 24)
    
    c.tt.cf.p.use_multiClass_cf_onlyIf_numberOfClassesMoreThanTwo = 1;   % =1:use multi-class classification only if number of classes more than 2, =0:use multi-class method for any number of classes (if number of classes 2 than 2-class classification runs 2 times and use multi-class selection method using both results)
%     c.tt.cf.p.use_multiClass_cf_onlyIf_numberOfClassesMoreThanTwo = 0;   % =1:use multi-class classification only if number of classes more than 2, =0:use multi-class method for any number of classes (if number of classes 2 than 2-class classification runs 2 times and use multi-class selection method using both results)
    
    c.tt.cf.p.CSP.method_CSP1_TRCSP2 = 1;       % used CSP method (=1:CSP, =2:TR_CSP)
    if c.tt.cf.p.CSP.method_CSP1_TRCSP2 == 2
        c.tt.cf.p.CSP.TR_CSP.alphaList = [10^-10, 10^-9, 10^-8, 10^-7, 10^-6, 10^-5, 10^-4, 10^-3, 10^-2, 10^-1];
        c.tt.cf.p.CSP.TR_CSP.CV_folds = 6;
    end
    
    c.tt.cf.p_options.CSP.selectedFilterPairNumber = [2,3,4];   % parameter options: number of selected spatial filter pairs (e.g., 2pairs/class)
    c.tt.cf.p_options.MI.quantization_level = [2,3,6];          % parameter options: number of the quantization levels used for mutual info code
    % c.tt.cf.p_options.MI.out_featureNumberPerClass = [6,10,14];        % parameter options: output feature number of the MI (mutual info) code
    c.tt.cf.p_options.MI.out_featureNumberPerClass = [10,14,18];       % parameter options: output feature number of the MI (mutual info) code
    
% % % %     c.tt.cf.p.CF.method.toolbox = 'RCSPToolbox';    % info: LDA_train
% % % %     switch c.tt.cf.p.CF.method.toolbox
% % % %         case 'RCSPToolbox'
            % c.tt.cf.p.CF.method.trainMethod = 'LDA';    % LDA training method setup (LDA, RLDA)
            c.tt.cf.p.CF.method.trainMethod = 'RLDA';   % LDA training method setup (LDA, RLDA)
% % % %     end
    
    % ________________
    % 
    % Config: CV setup
    % ________________
    
    c.tt.folds.outerFoldNumber = 6;      % number of final test folds
    c.tt.folds.innerFoldNumber = 5;      % number of training validation folds in each training fold
    % [!!! outerTrialOrder=2 OPTION NOT CODED YET !!!] c.tt.folds.outerTrialOrder_original1_random2 = 1;    % =2:order of the trials randomized in the outer fold level before separating outer folds
    c.tt.folds.innerTrialOrder_original1_random2 = 2;    % =2:order of the trials randomized in the inner fold level before separating training and trainValidation (inner) folds
    c.tt.folds.inner_merged_testFoldNumber = 1;     % =0:for mergedInnerTest use separated test folds, =1:for mergedInnerTest use all inner folds in same test fold (together)

    % _______________________
    % 
    % Config: smoothing setup
    % _______________________
    
    % prefered smoothDistance if used = 2
    % c.tt.smoothDistance.multiClass_innerFold_test_DA = 0;           % =0:notUsed, >0(=1 or larger):smoothDistance (prefered if used = 2)
    % c.tt.smoothDistance.multiClass_innerFold_test_DA_average = 0;   % =0:notUsed, >0(=1 or larger):smoothDistance (prefered if used = 2)
    c.tt.smoothDistance.multiClass_innerFold_test_DA = 0;           % =0:notUsed, >0(=1 or larger):smoothDistance (prefered if used = 2)
    c.tt.smoothDistance.multiClass_innerFold_test_DA_average = 2;   % =0:notUsed, >0(=1 or larger):smoothDistance (prefered if used = 2)
    c.tt.smoothDistance.multiClass_outerFold_test_DA = 0;           % =0:notUsed, >0(=1 or larger):smoothDistance (prefered if used = 2)
    c.tt.smoothDistance.multiClass_outerFold_test_DA_average = 2;   % =0:notUsed, >0(=1 or larger):smoothDistance (prefered if used = 2)
    
    % ___________________________
    % 
    % Eval Config: setup for plot
    % ___________________________

    % c.eval.SW
    % c.eval.PLOT
    % c.eval.w

    c.eval.SW.eval_used = 1;                % =1: evaluation run by taskManager after trainTest
    % c.eval.SW.figures_visible = 'on';   % 'on':figures displayed, 'off': not displayed (only saved)
    c.eval.SW.figures_visible = 'off';   % 'on':figures displayed, 'off': not displayed (only saved)
    c.eval.w.file.save.subDirName = 'Fig';      % sub-directory name for evaluation plots 

    c.eval.SW.plot_shaded_DA = 1;
    c.eval.SW.plot_paramEval = 1;
    c.eval.SW.plot_freqEval_v1 = 1;
    c.eval.SW.plot_freqEval_v2 = 1;
    c.eval.SW.plot_freqEval_v3 = 1;
    c.eval.SW.plot_topoplot_CSPMI = 1;
    c.eval.SW.plot_freqEval_v4 = 1;
    % % c.eval.SW.plot_topoplot_ERP = 0;
    c.eval.SW.plot_topoplot_ERDS = 0;

    c.eval.w.file.load_chanlocs.name = 'Standard-10-20-Cap81.locs';     % !!!!!!!! IF eval-> topoplot used this file must be copied into root result directory (for each task separately) !!!!!!!! 
    
    % PLOT setup: setup for shaded_DA:
    % ________________________________
    
    c.eval.PLOT.w.ylim = [0,100];
    % c.eval.PLOT.w.ylim = [20,100];
    % c.eval.PLOT.w.ylim = [0,50];
    % c.eval.PLOT.w.ylim = [10,40];
    
    c.eval.PLOT.w.averagedSubjSession_ylim = [0,100];
    % c.eval.PLOT.w.averagedSubjSession_ylim = [20,100];
    % c.eval.PLOT.w.averagedSubjSession_ylim = [0,50];
    % c.eval.PLOT.w.averagedSubjSession_ylim = [10,40];
    
    c.eval.PLOT.w.DA.averagePlotStd_crossFoldOnly = [1,0];    % =1:crossOuterFold STD, =0:crossSubj,Session,OuterFold STD
    
    % PLOT setup: setup for freq map:
    % _______________________________
    
    c.eval.PLOT.w.freqMap.common.colorLimitMax_fix1_auto2 = 2;
    if c.eval.PLOT.w.freqMap.common.colorLimitMax_fix1_auto2 == 1
      c.eval.PLOT.w.freqMap.common.colorLimitMax_fixValue = 1.0;
      % c.eval.PLOT.w.freqMap.common.colorLimitMin_fixValue = 0;
    end
    
    % PLOT setup: common topoplots setup:
    % ___________________________________
    
    c.eval.PLOT.w.topoplot.common.colorLimitMax_fix1_auto2 = 2;
    if c.eval.PLOT.w.topoplot.common.colorLimitMax_fix1_auto2 == 1
      c.eval.PLOT.w.topoplot.common.colorLimitMax_fixValue = 0.45;
    else
      c.eval.PLOT.w.topoplot.common.colorLimitMax_sameAutoForRestAndTask = 1;
    end
    
    % c.eval.PLOT.w.topoplot.common.SW.conv = 'off';
    c.eval.PLOT.w.topoplot.common.SW.conv = 'on';
    
    c.eval.PLOT.w.topoplot.common.wtIDs_restTaskSetup_fix1_auto2 = 2;
    if c.eval.PLOT.w.topoplot.common.wtIDs_restTaskSetup_fix1_auto2 == 1
        % c.eval.PLOT.w.topoplot.common.wtIDs_rest = 1;       % !!!!!!!!!!!! HAVE TO SET BADED ON THE USED DATASET !!!!!!!!!!!! 
        c.eval.PLOT.w.topoplot.common.wtIDs_task = 2:4;     % !!!!!!!!!!!! HAVE TO SET BADED ON THE USED DATASET !!!!!!!!!!!! 
    end
    c.eval.PLOT.w.topoplot.common.endOfRestWindow_ms = -1000; 
    
    c.eval.PLOT.w.topoplot.common.minTaskDA_usedTopoplotCalc_subj_session = 0.0;      % only those subjects/session combinations used for calculating topoplots where maxtTaskDA >= this value
    
    % PLOT setup: CSP-MI topoplot setup:
    % __________________________________
    
    c.eval.PLOT.w.topoplot.CSP_MI.used_CSPFilterPairPart = 0;         % =0:all, =1:upper part, =2:lower part
    c.eval.PLOT.w.topoplot.CSP_MI.plotted_rest1_task2 = [1,2,0];      % 0: difference of task and rest : abs(task-rest)
    % c.eval.PLOT.w.topoplot.CSP_MI.plotted_rest1_task2 = 2;       % 0: difference of task and rest : abs(task-rest)
    
    % %   c.eval.PLOT.w.topoplot.CSP_MI.restIntervalWidth_for_collectCSPMIWeights_ms = -1000; 
    
    % PLOT setup: ERDS topoplot setup:
    % ________________________________
    
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    % .............. MISSING !!!!!!!!!!!!!!!!!!!!
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    % _________
    % 
    % HDD Setup
    % _________
    
    % w.m = questdlg('Do you want load and save using local or network drive ?','Setup','Load/save to local drive','Load network / save local','Load/save to network','Load/save to local drive');
    % if strcmp(w.m,'Load/save to local drive')
        autorun.tt.file.load_localDrive1_NetworkDrive2 = 1;
        autorun.tt.file.save_localDrive1_NetworkDrive2 = 1;
    % elseif strcmp(w.m,'Load network / save local')
    %     autorun.tt.file.load_localDrive1_NetworkDrive2 = 2;
    %     autorun.tt.file.save_localDrive1_NetworkDrive2 = 1;
    % elseif strcmp(w.m,'Load/save to network')
    %     autorun.tt.file.load_localDrive1_NetworkDrive2 = 2;
    %     autorun.tt.file.save_localDrive1_NetworkDrive2 = 2;
    % end

	% _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
    %
    % Code 2. taskManager parameter setup: store common parameters + setup for load and save
	% _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
    
    % Setup for load
    % ______________
    
    autorun.tt.file.load.autoload = 1;
    
    % A09_EEG_validation_01
    autorun.tt.file.load.path.EEG_validation = VA.set.autorun.f.load.path.EEG_validation;
    autorun.tt.file.load.nameBasis1.EEG_validation = 'A09_EEG_validation_01';
    
    % A11_offlineClass_classSetup_01
    autorun.tt.file.load.path.offlineClass_classSetup = VA.set.autorun.f.load.path.offlineClass_classSetup;
    autorun.tt.file.load.nameBasis1.offlineClass_classSetup = 'A11_offlineClass_classSetup_01';
    autorun.tt.file.load.nameBasis1.offlineClass_classSetup_classTrials = 'classTrials';
    
    % Setup for save (common)
    % _______________________
    
    autorun.tt.file.save.autosave = 1;
    autorun.tt.file.save.autosave_w0 = 0;       % =0:NOT save w0 (but this content still saved the w0_matrix)
    
    autorun.tt.file.save.nameBasis.offlineClass_trainTest = 'FBCSP_offline_trainTest_01';
    autorun.tt.file.save.nameBasis.offlineClass_trainTest__w0 = 'w0';    % !!!!!!!!!!! STRUCTURE TO BE SAVED IN AUTORUN LOOP !!!!!!!!!!!! 
    
    % Option setup for save + store trainTest options
    % _______________________________________________
    
    for wm_taskID = 1 : VA.set.FBCSP.tt_option_number
      autorun.tt.file.save.path.offlineClass_trainTest = [VA.f.baseDir,'\',VA.f.FBCSP_offline_trainTest_taskManager.subDir,'\',VA.f.classSubDir{wm_subDirID},'\A',num2str(subFunc_num2str_2digit(wm_taskID)),'\'];
      if ~isdir(autorun.tt.file.save.path.offlineClass_trainTest)
        mkdir(autorun.tt.file.save.path.offlineClass_trainTest);
      end
      
      TM.taskParam{wm_taskID,1}.autorun = autorun;
      
      TM.taskParam{wm_taskID,1}.w = w;
      TM.taskParam{wm_taskID,1}.SW = SW;
      TM.taskParam{wm_taskID,1}.c = c;
    end
end


%% Function: FBCSP trainTest call

function func_FBCSP_tt_call(TM, perm_ID)

% % for wm_taskID = 1 : size(TM.taskParam,1)
% %     fprintf(['taskManager run: ',num2str(wm_taskID),'/',num2str(size(TM.taskParam,1)),'\n'])
% %     VAv2_FBCSP_trainTest_func_01(TM.taskParam{wm_taskID,1, perm_ID});
% % end
for wm_taskID = 1 : size(TM.taskParam,1)
    
    % trainTest:
    % fprintf(['taskManager trainTest: ',num2str(wm_taskID),'/',num2str(size(TM.taskParam,1)),'\n'])
    fprintf(['TM(',num2str(perm_ID),') trainTest: ',num2str(wm_taskID),'/',num2str(size(TM.taskParam,1)),'\n'])
    VAv2_FBCSP_trainTest_func_01(TM.taskParam{wm_taskID,1}, perm_ID);
    
    % evaluation:
    % if TM.taskParam{wm_taskID,1}.c.eval.SW.eval_used == 1
    if TM.commonParam.c.eval.SW.taskFigPrep_used == 1
      TM.taskParam{wm_taskID,1}.c.eval.w.file.load.autoload = TM.taskParam{wm_taskID,1}.autorun.tt.file.save.autosave;
      TM.taskParam{wm_taskID,1}.c.eval.w.file.load.path = TM.taskParam{wm_taskID,1}.autorun.tt.file.save.path.offlineClass_trainTest;
      TM.taskParam{wm_taskID,1}.c.eval.w.file.load.nameBasis1 = TM.taskParam{wm_taskID,1}.autorun.tt.file.save.nameBasis.offlineClass_trainTest;
      TM.taskParam{wm_taskID,1}.c.eval.w.file.load_chanlocs.path = TM.taskParam{wm_taskID,1}.autorun.tt.file.save.path.offlineClass_trainTest;
      % TM.taskParam{wm_taskID,1}.c.eval.w.file.load_chanlocs.name = TM.taskParam{wm_taskID,1}.c.eval.w.file.load_chanlocs.name;    % 'Standard-10-20-Cap81.locs'  
      
      TM.taskParam{wm_taskID,1}.c.eval.w.file.save.autosave = TM.taskParam{wm_taskID,1}.autorun.tt.file.save.autosave;
      w.file_path = TM.taskParam{wm_taskID,1}.autorun.tt.file.save.path.offlineClass_trainTest;
      w.file_path2 = [TM.taskParam{wm_taskID,1}.c.eval.w.file.save.subDirName,'\'];
      if isdir([w.file_path,w.file_path2])
          TM.taskParam{wm_taskID,1}.c.eval.w.file.save.path = [w.file_path,w.file_path2];
      else
          mkdir([w.file_path,w.file_path2]);
          TM.taskParam{wm_taskID,1}.c.eval.w.file.save.path = [w.file_path,w.file_path2];
      end
      
      fprintf(['taskManager evaluation: ',num2str(wm_taskID),'/',num2str(size(TM.taskParam,1)),'\n'])
      % MCC_FBCSP_eval_figures_func_17(TM.taskParam{wm_taskID,1}.c.eval);
      if ~exist('vHand_cPrep_indicator','var')
        % % MCC_FBCSP_eval_figures_func_17(TM.taskParam{wm_taskID,1}.c.eval);
        VB_FBCSP_eval_figures_func_01(TM.taskParam{wm_taskID,1}.c.eval);
      else
        % % MCC_FBCSP_eval_figures_func_17(TM.taskParam{wm_taskID,1}.c.eval, TM.taskParam{wm_taskID,1}.c.prep);
        VB_FBCSP_eval_figures_func_01(TM.taskParam{wm_taskID,1}.c.eval, TM.taskParam{wm_taskID,1}.c.prep);
      end
      
    end
    
end

end


%% Function: FBCSP evaluation based on results from trainTest options

% % function [basis, opt_tt, timeInfo, DA, RT_stat] = func_FBCSP_eval(func_in1, TM, perm_ID)
function [opt_tt, timeInfo, DA, RT_stat] = func_FBCSP_eval(TM, perm_ID)

  % out:
  % ....
  
  fprintf(['TM(',num2str(perm_ID),') DA eval ...\n'])

  % __________________________
  %
  % Optimal trainOption and wk
  % __________________________
  
  for wm_taskID = 1 : size(TM.taskParam,1)

    w.file.load.path = TM.taskParam{wm_taskID,1}.autorun.tt.file.save.path.offlineClass_trainTest;
    w.file.load.nameBasis1 = TM.taskParam{wm_taskID,1}.autorun.tt.file.save.nameBasis.offlineClass_trainTest;
    
    % Loading Datasets
    %_________________

    w.file.load.name = strcat(w.file.load.nameBasis1,' [autorun].mat');
    load([w.file.load.path,w.file.load.name]);
    autorun = copy_of_autorun;
    clear copy_of_autorun

    w.file.load.name = strcat(w.file.load.nameBasis1,' [config].mat');
    load([w.file.load.path,w.file.load.name]);
    c = copy_of_c;
    clear copy_of_c
    
    w.file.load.name = strcat(w.file.load.nameBasis1,' [w0_matrix].mat');
    load([w.file.load.path,w.file.load.name]);
    w0_matrix = copy_of_w0_matrix;
    clear copy_of_w0_matrix

    % preparing plotData
    %___________________

%     clearvars plotData
    % plotData(:,:) = w0_matrix.outer.DA.multiClass_test_DA(wm_subjID,wm_sessionID,:,:);
    plotData{wm_taskID}(:,:) = w0_matrix.outer.DA.multiClass_test_DA(1,1,:,:);
    
    % DA_mean(wm_taskID,:) = mean(plotData{wm_taskID},1)*100;
    % DA_std(wm_taskID,:) = std(plotData{wm_taskID},1)*100;
    DA_mean(wm_taskID,:) = round(mean(plotData{wm_taskID},1)*100, 4);   % round(xxx,4) -> 4-tizedes kerekites
    DA_std(wm_taskID,:) = round(std(plotData{wm_taskID},1)*100, 4);     % round(xxx,4) -> 4-tizedes kerekites
    % DA_mean(wm_taskID, 1:size(plotData{wm_taskID},2)) = mean(plotData{wm_taskID},1)*100;
    % DA_std(wm_taskID, 1:size(plotData{wm_taskID},2)) = std(plotData{wm_taskID},1)*100;
    
    % preparing smoothed-plotData
    %____________________________
    
    wm = fix(c.prep.trial.eval.smoothDistance_ms/c.tt.cf.p.winStep.ms);
    plotDataSmooth{wm_taskID} = NaN(size(plotData{wm_taskID}));
    for wm1 = 1 : wm
      plotDataSmooth{wm_taskID}(:,wm1) = nanmean(plotData{wm_taskID}(:, 1:(wm1+wm)),2);
    end
    for wm1 = wm+1 : size(plotData{wm_taskID},2)-wm
      plotDataSmooth{wm_taskID}(:,wm1) = nanmean(plotData{wm_taskID}(:, (wm1-wm):(wm1+wm)),2);
    end
    for wm1 = size(plotData{wm_taskID},2)-wm+1 : size(plotData{wm_taskID},2)
      plotDataSmooth{wm_taskID}(:,wm1) = nanmean(plotData{wm_taskID}(:, (wm1-wm):size(plotData{wm_taskID},2)),2);
    end
    
    DASmooth_mean(wm_taskID,:) = round(mean(plotDataSmooth{wm_taskID},1)*100, 4);   % round(xxx,4) -> 4-tizedes kerekites
    DASmooth_std(wm_taskID,:) = round(std(plotDataSmooth{wm_taskID},1)*100, 4);     % round(xxx,4) -> 4-tizedes kerekites
%{
figure;
subplot(2,2,1); plot(plotData{wm_taskID}'); title('plot: test DA folds')
subplot(2,2,2); shadedErrorBar([], mean(plotData{wm_taskID},1)*100, std(plotData{wm_taskID},1)*100, 'lineprops','bp-'); title('shadedErrorBar: test DA folds') 
subplot(2,2,3); plot(plotDataSmooth{wm_taskID}'); title('plot: smoothed test DA folds')
subplot(2,2,4); shadedErrorBar([], mean(plotDataSmooth{wm_taskID},1)*100, std(plotDataSmooth{wm_taskID},1)*100, 'lineprops','b'); title('shadedErrorBar: smoothed test DA folds') 
%}
    
  end
  
% %   % base info
% %   % _________
% %   
% %   basis.ssr_text = func_in1.ssr_text;
% %   
% %   wm_folds = size(w0_matrix.outer.trials.trialIDs.test,3);
% %   basis.testFoldNumber = wm_folds;
% %   wm_subjID2 = 1;
% %   wm_sessionID2 = 1;
% %   w.f.load.path = [func_in1.f.baseDir,'\',func_in1.f.A10_offlineClass_prep.subDir,'\',func_in1.f.classSubDir{func_in1.wm_subDirID},'\'];
% %   w.f.load.name = ['tr{',num2str(wm_subjID2),',',num2str(wm_sessionID2),'}.mat'];
% %   fprintf(['Loading ',w.f.load.name,' ...\n']);
% %   load([w.f.load.path,w.f.load.name]);
% %   tr{wm_subjID2,wm_sessionID2} = copy_of_tr{wm_subjID2,wm_sessionID2};
% %   clear copy_of_tr
% %   for wm_classID = 1 : size(tr{wm_subjID2,wm_sessionID2},2)
% %     basis.allTrials_per_class(1,wm_classID) = size(tr{wm_subjID2,wm_sessionID2}{end,wm_classID},3);
% %   end
% %   basis.trainTrials_per_class = basis.allTrials_per_class * ((wm_folds-1)/wm_folds);
% %   basis.testTrials_per_class = basis.allTrials_per_class / wm_folds;
% %   
% %   basis.allTrials = sum(basis.allTrials_per_class);
% %   basis.trainTrials = sum(basis.trainTrials_per_class);
% %   basis.testTrials = sum(basis.testTrials_per_class);
  
  % wtIDs and ms
  % ____________
  
  PLOT.w.PRE_ms = c.prep.trial.trig_PRE_ms;
  PLOT.w.PST_ms = c.prep.trial.trig_PST_ms;
  PLOT.w.wtID_trig = (((-1*c.prep.trial.trig_PRE_ms)-c.tt.cf.p.winSize.ms)/c.tt.cf.p.winStep.ms)+1;     % trigID in plotData
  PLOT.w.wtID_ref1 = fix( PLOT.w.wtID_trig + (c.prep.trial.eval.ref_interval_ms(1,1)/c.tt.cf.p.winStep.ms) );     % first ID of the interval in plotData
  PLOT.w.wtID_ref2 = fix( PLOT.w.wtID_trig + (c.prep.trial.eval.ref_interval_ms(1,2)/c.tt.cf.p.winStep.ms) );     % last ID of the interval in plotData
  PLOT.w.wtIDs_ref = PLOT.w.wtID_ref1 : PLOT.w.wtID_ref2;
  PLOT.w.wtID_task1 = fix( PLOT.w.wtID_trig + (c.prep.trial.eval.task_interval_ms(1,1)/c.tt.cf.p.winStep.ms) );     % first ID of the interval in plotData
  PLOT.w.wtID_task2 = fix( PLOT.w.wtID_trig + (c.prep.trial.eval.task_interval_ms(1,2)/c.tt.cf.p.winStep.ms) );     % last ID of the interval in plotData
  PLOT.w.wtIDs_task = PLOT.w.wtID_task1 : PLOT.w.wtID_task2;
  
  % task DA Evaluatuon
  % __________________
  
  wm1s = PLOT.w.wtIDs_task;
  wm2s = max(round(DASmooth_mean(:,wm1s),4),[],2);   % round(xxx,4): 4-tizedes round 
  wm3s_chk = 0;
  for wm4s = find(wm2s==max(wm2s))'     % taskID
      wm6s_tmp = (wm1s(1,1)-1) + find(DASmooth_mean(wm4s,wm1s)==wm2s(wm4s,1));    % wtID
      wm5s = find( DASmooth_std(wm4s,:)==min(DASmooth_std(wm4s,wm6s_tmp)) );
      wm6s = min(wm5s(1,find(ismember(wm5s, wm6s_tmp))));
      if wm3s_chk == 0
          opt_tt.optionID = wm4s;    % taskID_ok
          opt_tt.smooth_task_wtID = wm6s;   % wtID_for smooth_task_ok
          wm3s_chk = 1;
      else
        if DASmooth_std(wm4s,wm6s)<DASmooth_std(opt_tt.optionID,opt_tt.smooth_task_wtID)
            opt_tt.optionID = wm4s;
            opt_tt.smooth_task_wtID = wm6s;
        end
      end
  end
%{
figure;
subplot(2,2,1); plot(plotData{opt_tt.optionID}'); title('plot: test DA folds')
subplot(2,2,2); shadedErrorBar([], mean(plotData{opt_tt.optionID},1)*100, std(plotData{opt_tt.optionID},1)*100, 'lineprops','bp-'); title('shadedErrorBar: test DA folds') 
subplot(2,2,3); plot(plotDataSmooth{opt_tt.optionID}'); title('plot: smoothed test DA folds')
subplot(2,2,4); shadedErrorBar([], mean(plotDataSmooth{opt_tt.optionID},1)*100, std(plotDataSmooth{opt_tt.optionID},1)*100, 'lineprops','b'); title('shadedErrorBar: smoothed test DA folds') 
%}
  
  wm = fix(c.prep.trial.eval.smoothDistance_ms/c.tt.cf.p.winStep.ms);	% smooth distance in plotData samles 
  % wm1 = (opt_tt.smooth_task_wtID-wm):(opt_tt.smooth_task_wtID+wm);            % wtIDs within smoothDistance range of smoothPeakDA wtID
  if opt_tt.smooth_task_wtID-wm < 1
    wm1 = 1:(opt_tt.smooth_task_wtID+wm);            % wtIDs within smoothDistance range of smoothPeakDA wtID
  elseif opt_tt.smooth_task_wtID+wm > size(plotData{opt_tt.optionID},2)
    wm1 = (opt_tt.smooth_task_wtID-wm):size(plotData{opt_tt.optionID},2);            % wtIDs within smoothDistance range of smoothPeakDA wtID
  else
    wm1 = (opt_tt.smooth_task_wtID-wm):(opt_tt.smooth_task_wtID+wm);            % wtIDs within smoothDistance range of smoothPeakDA wtID
  end
  wm2 = round(DA_mean(opt_tt.optionID, wm1),4);         % rounded-DA value within smoothDistance range of smoothPeakDA wtID <- round(xxx,4): 4-tizedes round 
  wm3 = max(wm2,[],2);                                  % max rounded-DA value within smoothDistance range of smoothPeakDA wtID
  wm4 = wm1(1, find(ismember(wm2,wm3)));                % wtID(s) of max rounded-DA value within smoothDistance range of smoothPeakDA wtID
  wm5 = find( DA_std(opt_tt.optionID,:)==min(DA_std(opt_tt.optionID,wm4)) );
  opt_tt.task_wtID = min(wm5(1,find(ismember(wm5, wm4))));    % wtID_ok
  
  % ref DA Evaluatuon
  % _________________
  
  wm1s = PLOT.w.wtIDs_ref;
  wm2s = max(round(DASmooth_mean(opt_tt.optionID,wm1s),4),[],2);   % round(xxx,4): 4-tizedes round 
  wm4s = opt_tt.optionID;     % taskID
      wm6s_tmp = (wm1s(1,1)-1) + find(DASmooth_mean(wm4s,wm1s)==wm2s);    % wtID
      wm5s = find( DASmooth_std(wm4s,:)==min(DASmooth_std(wm4s,wm6s_tmp)) );
      opt_tt.smooth_ref_wtID = min(wm5s(1,find(ismember(wm5s, wm6s_tmp))));
  
  wm = fix(c.prep.trial.eval.smoothDistance_ms/c.tt.cf.p.winStep.ms);	% smooth distance in plotData samles 
  % wm1 = (opt_tt.smooth_ref_wtID-wm):(opt_tt.smooth_ref_wtID+wm);            % wtIDs within smoothDistance range of smoothPeakDA wtID
  if opt_tt.smooth_ref_wtID-wm < 1
    wm1 = 1:(opt_tt.smooth_ref_wtID+wm);            % wtIDs within smoothDistance range of smoothPeakDA wtID
  elseif opt_tt.smooth_ref_wtID+wm > size(plotData{opt_tt.optionID},2)
    wm1 = (opt_tt.smooth_ref_wtID-wm):size(plotData{opt_tt.optionID},2);            % wtIDs within smoothDistance range of smoothPeakDA wtID
  else
    wm1 = (opt_tt.smooth_ref_wtID-wm):(opt_tt.smooth_ref_wtID+wm);            % wtIDs within smoothDistance range of smoothPeakDA wtID
  end
  wm2 = round(DA_mean(opt_tt.optionID, wm1),4);         % rounded-DA value within smoothDistance range of smoothPeakDA wtID <- round(xxx,4): 4-tizedes round 
  wm3 = max(wm2,[],2);                                  % max rounded-DA value within smoothDistance range of smoothPeakDA wtID
  wm4 = wm1(1, find(ismember(wm2,wm3)));                % wtID(s) of max rounded-DA value within smoothDistance range of smoothPeakDA wtID
  wm5 = find( DA_std(opt_tt.optionID,:)==min(DA_std(opt_tt.optionID,wm4)) );
  opt_tt.ref_wtID = min(wm5(1,find(ismember(wm5, wm4))));    % wtID_ok
  
  % ___________________________
  %
  % Collect DA plot testFold values
  % ______________________
  
  DA.opt.testFold_DA_Plots = plotData{opt_tt.optionID};
  DA.smooth.testFold_DA_Plots = plotDataSmooth{opt_tt.optionID};
  
  % ______________________________________________________________
  %
  % Student ttest and wilcoxon non-parametric test (task VS relax)
  % + DA mean and DA std
  % ______________________________________________________________
  
% figure; plot(plotData{opt_tt.optionID}(:, opt_tt.ref_wtID)); hold all;  plot(plotData{opt_tt.optionID}(:, opt_tt.task_wtID))
  % [h,p_tt] = ttest(plotData{opt_tt.optionID}(:, opt_tt.ref_wtID), plotData{opt_tt.optionID}(:, opt_tt.task_wtID));
  % [p_wilc,h] = signrank(plotData{opt_tt.optionID}(:, opt_tt.ref_wtID), plotData{opt_tt.optionID}(:, opt_tt.task_wtID));
% figure; plot(plotData{opt_tt.optionID}(:, opt_tt.smooth_ref_wtID)); hold all;  plot(plotData{opt_tt.optionID}(:, opt_tt.smooth_task_wtID))
  % [h,p_tt] = ttest(plotData{opt_tt.optionID}(:, opt_tt.smooth_ref_wtID), plotData{opt_tt.optionID}(:, opt_tt.smooth_task_wtID));
  % [p_wilc,h] = signrank(plotData{opt_tt.optionID}(:, opt_tt.smooth_ref_wtID), plotData{opt_tt.optionID}(:, opt_tt.smooth_task_wtID));
  
  % If your hypothesis is ‘greater than’ or ‘less than’, use a one-tailed test. If your hypothesis is ‘different than’, use a two-tailed test.
  % The way to code it (for ttest2), is for example to test that the mean of ‘x’ is less than the mean of ‘y’:
  % [h,p,ci,stats] = ttest2(x, y, 'Tail','left');
  
 
  % time info
  % _________
  
  timeInfo.cf.winSize_ms = c.tt.cf.p.winSize.ms;    % classifier window size in ms
  timeInfo.cf.winStep_ms = c.tt.cf.p.winStep.ms;    % classifier window step in ms
  timeInfo.smooth.distance_ms = c.prep.trial.eval.smoothDistance_ms;
  timeInfo.smooth.distance_wtID = fix(c.prep.trial.eval.smoothDistance_ms/c.tt.cf.p.winStep.ms);
  timeInfo.smooth.winWidth_ms = c.prep.trial.eval.smoothDistance_ms*2;
  timeInfo.smooth.winWidth_wtID = (fix(c.prep.trial.eval.smoothDistance_ms/c.tt.cf.p.winStep.ms)*2)+1;
  timeInfo.wtID_in_DA_plot.trig = PLOT.w.wtID_trig;
  timeInfo.wtID_in_DA_plot.ref_interval = [PLOT.w.wtID_ref1, PLOT.w.wtID_ref2];
  timeInfo.wtID_in_DA_plot.task_interval = [PLOT.w.wtID_task1, PLOT.w.wtID_task2];
  timeInfo.wtID_in_DA_plot.opt_peakDAPoint_ref = opt_tt.ref_wtID;
  timeInfo.wtID_in_DA_plot.opt_peakDAPoint_task = opt_tt.task_wtID;
  timeInfo.wtID_in_DA_plot.smooth_peakDAPoint_ref = opt_tt.smooth_ref_wtID;
  timeInfo.wtID_in_DA_plot.smooth_peakDAPoint_task = opt_tt.smooth_task_wtID;
  timeInfo.ms_fromTrig.trig = 0;
  timeInfo.ms_fromTrig.ref_interval = c.prep.trial.eval.ref_interval_ms;
  timeInfo.ms_fromTrig.task_interval = c.prep.trial.eval.task_interval_ms;
  timeInfo.ms_fromTrig.opt_peakDAPoint_ref = ((opt_tt.ref_wtID -1) * c.tt.cf.p.winStep.ms) - (-c.prep.trial.trig_PRE_ms - c.tt.cf.p.winSize.ms);
  timeInfo.ms_fromTrig.opt_peakDAPoint_task = ((opt_tt.task_wtID -1) * c.tt.cf.p.winStep.ms) - (-c.prep.trial.trig_PRE_ms - c.tt.cf.p.winSize.ms);
  timeInfo.ms_fromTrig.smooth_peakDAPoint_ref = ((opt_tt.smooth_ref_wtID -1) * c.tt.cf.p.winStep.ms) - (-c.prep.trial.trig_PRE_ms - c.tt.cf.p.winSize.ms);
  timeInfo.ms_fromTrig.smooth_peakDAPoint_task = ((opt_tt.smooth_task_wtID -1) * c.tt.cf.p.winStep.ms) - (-c.prep.trial.trig_PRE_ms - c.tt.cf.p.winSize.ms);
  timeInfo.ms_from_PRE_point.trig = -c.prep.trial.trig_PRE_ms;
    timeInfo.ms_from_PRE_point.ref_interval = -c.prep.trial.trig_PRE_ms + timeInfo.ms_fromTrig.ref_interval;
    timeInfo.ms_from_PRE_point.task_interval = -c.prep.trial.trig_PRE_ms + timeInfo.ms_fromTrig.task_interval;
    timeInfo.ms_from_PRE_point.opt_peakDAPoint_ref = -c.prep.trial.trig_PRE_ms + timeInfo.ms_fromTrig.opt_peakDAPoint_ref;
    timeInfo.ms_from_PRE_point.opt_peakDAPoint_task = -c.prep.trial.trig_PRE_ms + timeInfo.ms_fromTrig.opt_peakDAPoint_task;
    timeInfo.ms_from_PRE_point.smooth_peakDAPoint_ref = -c.prep.trial.trig_PRE_ms + timeInfo.ms_fromTrig.smooth_peakDAPoint_ref;
    timeInfo.ms_from_PRE_point.smooth_peakDAPoint_task = -c.prep.trial.trig_PRE_ms + timeInfo.ms_fromTrig.smooth_peakDAPoint_task;
  
  % DA foldValues
  % _____________
  
  DA.opt.foldValues_at_refPeakPoint = plotData{opt_tt.optionID}(:, opt_tt.ref_wtID);
  DA.opt.foldValues_at_taskPeakPoint = plotData{opt_tt.optionID}(:, opt_tt.task_wtID);
  DA.smooth.foldValues_at_refPeakPoint = plotDataSmooth{opt_tt.optionID}(:, opt_tt.smooth_ref_wtID);
  DA.smooth.foldValues_at_taskPeakPoint = plotDataSmooth{opt_tt.optionID}(:, opt_tt.smooth_task_wtID);
  
  % Student ttest and wilcoxon non-parametric test (task VS relax)
  % ______________________________________________________________
  
  % Test the alternative hypothesis that the population mean of x is less than the population mean of y :
  
  wm1 = plotData{opt_tt.optionID}(:, opt_tt.ref_wtID);
  wm2 = plotData{opt_tt.optionID}(:, opt_tt.task_wtID);
  [h,RT_stat.opt.refPeakDA_lowerThan_taskPeakDA.p_tt] = ttest(wm1, wm2, 'Tail','left');
  [h,RT_stat.opt.refPeakDA_lowerThan_taskPeakDA.p_tt2] = ttest2(wm1, wm2, 'Tail','left');
  [RT_stat.opt.refPeakDA_lowerThan_taskPeakDA.p_wilc,h] = signrank(wm1, wm2);

  wm1 = plotDataSmooth{opt_tt.optionID}(:, opt_tt.smooth_ref_wtID);
  wm2 = plotDataSmooth{opt_tt.optionID}(:, opt_tt.smooth_task_wtID);
  [h,RT_stat.smooth.refPeakDA_lowerThan_taskPeakDA.p_tt] = ttest(wm1, wm2, 'Tail','left');
  [h,RT_stat.smooth.refPeakDA_lowerThan_taskPeakDA.p_tt2] = ttest2(wm1, wm2, 'Tail','left');
  [RT_stat.smooth.refPeakDA_lowerThan_taskPeakDA.p_wilc,h] = signrank(wm1, wm2);

  % Mean and STD at relax interval and DA_Peak
  % __________________________________________
  
  wm1 = plotData{opt_tt.optionID}(:, opt_tt.ref_wtID);
  wm2 = plotData{opt_tt.optionID}(:, opt_tt.task_wtID);
  DA.opt.refPeakDA_mean = mean(wm1);
  DA.opt.refPeakDA_std = std(wm1);
  DA.opt.taskPeakDA_mean = mean(wm2);
  DA.opt.taskPeakDA_std = std(wm2);
  
  wm1 = plotDataSmooth{opt_tt.optionID}(:, opt_tt.smooth_ref_wtID);
  wm2 = plotDataSmooth{opt_tt.optionID}(:, opt_tt.smooth_task_wtID);
  DA.smooth.refPeakDA_mean = mean(wm1);
  DA.smooth.refPeakDA_std = std(wm1);
  DA.smooth.taskPeakDA_mean = mean(wm2);
  DA.smooth.taskPeakDA_std = std(wm2);
  
% %   % ______________________________________________________________________________________
% %   % 
% %   % Detailed test DA and Permutation test calc - based on the Optimal trainOption (and wk)
% %   % ______________________________________________________________________________________
% %     
% % % % % % % % % % % % % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
% % % % % % % % % % % % % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
% % % % % % % % % % % % % !!!!!!!!!!! VARIABLE CONFIG in cf file + RELATED PARTS IN PREVIOUS CODE - CHANGE TO CHANGE DUE TO THE FOLLOWING !!!!!!!!!!! 
% % % % % % % % % % % % % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
% % % % % % % % % % % % % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
% % % % % % % % % % % % VA_TRANS.c.prep.trial.eval.refPointA_fromTaskStart_ms = -1200-0;    % -priorSec_of_intervalSide1 -instructionLenght_if_have_taskInfo_in_that 
% % % % % % % % % % % % VA_TRANS.c.prep.trial.eval.refPoint0_fromTaskStart_ms = -1000-0;    % -priorSec_of_intervalSide1 -instructionLenght_if_have_taskInfo_in_that 
% % % % % % % % % % % % VA_TRANS.c.prep.trial.eval.refPointB_fromTaskStart_ms =  -800-0;    % -priorSec_of_intervalSide1 -instructionLenght_if_have_taskInfo_in_that 
% %     
% %     % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% %     % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% %     % !!!!!!!!!!!!!!!!!!! HAVE TO REWRITE HERE !!!!!!!!!!!!!!!!!!!
% %     % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% %     % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% %     
% %     % Detailed test DA - based on the Optimal trainOption
% %     % ___________________________________________________
% %     
% %     
% %     
% %     
% %     
% %     
% %     
% %     
% %     % Permutation test - based on the Optimal trainOption
% %     % ___________________________________________________
% %     
% %     
% %     
% %     
% %     
% %     
% %     
% %     
% %     % ________________________________________________________________________
% %     %
% %     % Detailed DA / Permut DA plot - based on the Optimal trainOption (and wk)
% %     % ________________________________________________________________________
% %     
% %     
% %     
% %     
% %     
% %     
% %     
% %     
% %     % _____________________________________________________________
% %     %
% %     % Freq and Topoplot - based on the Optimal trainOption (and wk)
% %     % _____________________________________________________________
    
    
    
    
    
    
    
    
  
  
  
end




%% Function: FBCSP trainTest option setup

function TM = func_FBCSP_tt_option_setup(VA_TRANS, TM)

    cf_TAv2_TrainTest_A2_FBCSP

end



