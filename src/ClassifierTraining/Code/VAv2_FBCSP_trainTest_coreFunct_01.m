% FilterBankCSP Multi-class Classification, offline EEG trainTest: parfor function

% Input structures

% Output structures

% REQUIRESTMENT: Matlab
% Copyright(c)2020 Attila Korik, http://isrc.ulster.ac.uk/akorik/contact.html


%% Info

% p = param
% tt = trainTest
% cf = classifier


%% Code

function w0 = VAv2_FBCSP_trainTest_coreFunct_01(TRANS, autorun_subjID2, autorun_sessionID2, autorun_outerFoldID, perm_ID)
  
  SW = TRANS.SW;
  c = TRANS.c;
  autorun = TRANS.autorun;
  EEG_validation = TRANS.EEG_validation;
  
  wm_subjID2 = autorun_subjID2;
  wm_sessionID2 = autorun_sessionID2;
  wm_outerFoldID = autorun_outerFoldID;
  
  if SW.print_trainTest_details == 1 
    fprintf(['SubjID2: ',num2str(wm_subjID2),'/',num2str(size(TRANS.autorun.tt.used.subjects,2)), ...
             ', SessionID2: ',num2str(wm_sessionID2),'/',num2str(size(TRANS.autorun.tt.used.sessions,2)), ...
             ', OuterFold: ',num2str(wm_outerFoldID),'/',num2str(TRANS.c.tt.folds.outerFoldNumber),' ...\n'])
  end


%% Parameter setup

  wm_CSP_filterPairNumberID = 1;
  wm_MI_quant_levelID = 1;
  wm_outFeatureNumberPerClassID = 1;
  
  wm_CSP_filterPairNumber = c.tt.cf.p_options.CSP.selectedFilterPairNumber(1,wm_CSP_filterPairNumberID);
  wm_MI_quant_level = c.tt.cf.p_options.MI.quantization_level(1,wm_MI_quant_levelID);
  wm_outFeatureNumberPerClass = c.tt.cf.p_options.MI.out_featureNumberPerClass(1,wm_outFeatureNumberPerClassID);


%% Loading dataset

  % _______________
  %
  % Loading Dataset
  % _______________

    if c.tt.session.use_allSessionsTogether == 0    % =1: combine classTrial datasets together from all sessions, =0:handle separately 
        w.file.load.name = [autorun.tt.file.load.nameBasis1.offlineClass_classSetup_classTrials,'{',num2str(wm_subjID2),',',num2str(wm_sessionID2),'}.mat'];
        TMP = load([autorun.tt.file.load.path.offlineClass_classSetup,w.file.load.name]);
        classTrials{wm_subjID2,wm_sessionID2} = TMP.copy_of_classTrials{wm_subjID2,wm_sessionID2};
        clear TMP
    else
      for wm_sessionID_X = TRANS.autorun.tt.used.sessions
        w.file.load.name = [autorun.tt.file.load.nameBasis1.offlineClass_classSetup_classTrials,'{',num2str(wm_subjID2),',',num2str(wm_sessionID_X),'}.mat'];
        TMP = load([autorun.tt.file.load.path.offlineClass_classSetup,w.file.load.name]);
        for wm_classID = 1 : size(c.classSetup.class.targetIDs_linkedTo_classID,1)
          for wm_bandID = c.classSetup.band.usedIDs
            wm = size(TMP.copy_of_classTrials{wm_subjID2,wm_sessionID_X}{wm_classID, wm_bandID},1);
            classTrials{wm_subjID2,1}{wm_classID, wm_bandID}(((wm_sessionID_X-1)*wm)+1:wm_sessionID_X*wm,:,:) = ...
                TMP.copy_of_classTrials{wm_subjID2,wm_sessionID_X}{wm_classID, wm_bandID}(:,:,:);
          end
        end
        clear TMP
      end
    end
  clearvars TRANS
  
  
%% Random Permutation setup
  
  % Random permutation of trials from all classes
  
  % Input:
  % perm_ID     : if perm_ID>0 -> random permutation of trials
  % classTrials{wm_subjID2,wm_sessionID2}{wm_classID, wm_bandID}(wm_trialID, wk, wt)
  % 
  % Output:
  % classTrials{wm_subjID2,wm_sessionID2}{wm_classID, wm_bandID}(wm_trialID, wk, wt)
  
  if perm_ID > 0
    
    % wm_bandID = 1;    % only for trial number definition
    wm_bandID = c.classSetup.band.usedIDs(1,1);    % only for trial number definition
    wm_allClassTrial_number = 0;
    for wm_classID = 1 : size(c.classSetup.class.targetIDs_linkedTo_classID,1)
        wm_allClassTrial_number = wm_allClassTrial_number + size(classTrials{wm_subjID2,wm_sessionID2}{wm_classID, wm_bandID},1);
    end
    wm_permIDs = randperm(wm_allClassTrial_number);
    
    for wm_bandID = c.classSetup.band.usedIDs
      wm = 0;
      for wm_classID = 1 : size(c.classSetup.class.targetIDs_linkedTo_classID,1)
          TMP(wm +1 : wm + size(classTrials{wm_subjID2,wm_sessionID2}{wm_classID, wm_bandID},1), :, :) = classTrials{wm_subjID2,wm_sessionID2}{wm_classID, wm_bandID}(:,:,:);
          wm = wm + size(classTrials{wm_subjID2,wm_sessionID2}{wm_classID, wm_bandID},1);
      end
      
      TMP2 = TMP(wm_permIDs, :,:);
      clearvars TMP
      
      wm = 0;
      for wm_classID = 1 : size(c.classSetup.class.targetIDs_linkedTo_classID,1)
          TMP_classTrials{wm_subjID2,wm_sessionID2}{wm_classID, wm_bandID}(:,:,:) = TMP2(wm +1 : wm + size(classTrials{wm_subjID2,wm_sessionID2}{wm_classID, wm_bandID},1), :, :);
          wm = wm + size(classTrials{wm_subjID2,wm_sessionID2}{wm_classID, wm_bandID},1);
      end
      clearvars TMP2
    end
    classTrials = TMP_classTrials;
    clearvars TMP_classTrials
      
  end
  
  
%% Outer fold setup

  % ____________________________________________
  %
  % Outer fold (training and test) trialID setup
  % ____________________________________________
  
  % Input:
  % classTrials{wm_subjID2,wm_sessionID2}{wm_classID, wm_bandID}(wm_trialID, wk, wt)
  % Output:
  % w.tt.outer.validCh_trials.all{wm_classID, wm_bandID}(wt, wk, wm_trialID)
  % ....
  
  % wm_bandID = 1;    % only for trial number definition
  wm_bandID = c.classSetup.band.usedIDs(1,1);    % only for trial number definition
  
  for wm_classID = 1 : size(c.classSetup.class.targetIDs_linkedTo_classID,1)
    wm = size(classTrials{wm_subjID2,wm_sessionID2}{wm_classID, wm_bandID},1);    % trials/class 
    w.tt.outer.trialIDs.all{wm_classID, 1} = 1:wm;
    w.tt.outer.trialIDs.train{wm_classID, 1} = w.tt.outer.trialIDs.all{wm_classID, 1}(~ismember(1:wm, round((wm_outerFoldID-1)*(wm/c.tt.folds.outerFoldNumber))+1 : round(wm_outerFoldID*(wm/c.tt.folds.outerFoldNumber))));
    w.tt.outer.trialIDs.test{wm_classID, 1} = w.tt.outer.trialIDs.all{wm_classID, 1}(ismember(1:wm, round((wm_outerFoldID-1)*(wm/c.tt.folds.outerFoldNumber))+1 : round(wm_outerFoldID*(wm/c.tt.folds.outerFoldNumber))));
    for wm_bandID = c.classSetup.band.usedIDs
        
              
     w.tt.outer.validCh_trials.all{wm_classID, wm_bandID}(:, 1:size(EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID,2), 1:size(w.tt.outer.trialIDs.all{wm_classID, 1},2)) = ...
       permute(classTrials{wm_subjID2,wm_sessionID2}{wm_classID, wm_bandID} ...
            ( w.tt.outer.trialIDs.all{wm_classID, 1}, EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID, :), [3,2,1]);   % train.EEG.x(wt, wk, wm_trialID)
        
%         w.tt.outer.validCh_trials.all{wm_classID, wm_bandID} = ...
%        permute(classTrials{wm_subjID2,wm_sessionID2}{wm_classID, wm_bandID} ...
%             ( w.tt.outer.trialIDs.all{wm_classID, 1}, EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID, :), [3,2,1]);   % train.EEG.x(wt, wk, wm_trialID)
        
    end
    w.tt.outer.trialID2s.all{wm_classID, 1} = 1 : size(w.tt.outer.trialIDs.all{wm_classID, 1},2);
    w.tt.outer.trialID2s.train{wm_classID, 1} = 1 : size(w.tt.outer.trialIDs.train{wm_classID, 1},2);
    w.tt.outer.trialID2s.test{wm_classID, 1} = 1 : size(w.tt.outer.trialIDs.test{wm_classID, 1},2);
  end
  
  % ___________________
  % 
  % Storing trialID set
  % ___________________
  
  w0.outer.trials.trialIDs = w.tt.outer.trialIDs;       % w.tt.outer.trialIDs (include): .all(1,trialID_ID), .train(1,trialID_ID), .test(1,trialID_ID) 
  w0.outer.trials.trialID2s = w.tt.outer.trialID2s;     % w.tt.outer.trialID2s (include): .all(1,trialID2_ID), .train(1,trialID2_ID), .test(1,trialID2_ID) 
  
  % ______________________________
  % 
  % Outer fold allClass trial prep
  % ______________________________
  
  % Input:
  % w.tt.outer.validCh_trials{wm_classID, wm_bandID}(wt, wk, wm_trialID)
  % w.tt.outer.trialID2s.train{wm_classID, 1}(1,wm_trialID)
  % w.tt.outer.trialID2s.test{wm_classID, 1}(1,wm_trialID)
  % Output:
  % w.tt.outer.allClass.validCh_trials.train{1, wm_bandID}(wt, wk, wm_trialID)
  % w.tt.outer.allClass.validCh_trials.test{1, wm_bandID}(wt, wk, wm_trialID)
  % w.tt.outer.allClass.trialClassLabels.train(1, wm_trialID)
  % w.tt.outer.allClass.trialClassLabels.test(1, wm_trialID)
  
  wm_test = 0;
  wm_train = 0;
  for wm_classID = 1 : size(c.classSetup.class.targetIDs_linkedTo_classID,1)
    for wm_bandID = c.classSetup.band.usedIDs
       wm = size(w.tt.outer.trialID2s.train{wm_classID, 1},2);
       w.tt.outer.allClass.validCh_trials.train{1, wm_bandID}(:,:,wm_train+1:wm_train+wm) = ...
           w.tt.outer.validCh_trials.all{wm_classID, wm_bandID}(:,:,w.tt.outer.trialIDs.train{wm_classID, 1}(w.tt.outer.trialID2s.train{wm_classID, 1}(1,:)));
       wm = size(w.tt.outer.trialID2s.test{wm_classID, 1},2);
       w.tt.outer.allClass.validCh_trials.test{1, wm_bandID}(:,:,wm_test+1:wm_test+wm) = ...
           w.tt.outer.validCh_trials.all{wm_classID, wm_bandID}(:,:,w.tt.outer.trialIDs.test{wm_classID, 1}(w.tt.outer.trialID2s.test{wm_classID, 1}(1,:)));
    end
    wm = size(w.tt.outer.trialID2s.train{wm_classID, 1},2);
    w.tt.outer.allClass.trialClassLabels.train(1,wm_train+1:wm_train+wm) = wm_classID;
    wm_train = wm_train + wm;
    wm = size(w.tt.outer.trialID2s.test{wm_classID, 1},2);
    w.tt.outer.allClass.trialClassLabels.test(1,wm_test+1:wm_test+wm) = wm_classID;
    wm_test = wm_test + wm;
  end
  
  

%% Outer fold trainTest


  % ________________________________________________________
  %
  % Parameter set setup for Outer fold trainTest (only test)
  % ________________________________________________________
   
% % % % % % % %   clearvars w1;
% % % % % % % %   w1='';
  
   % _____________________________________________
   %
   % Outer fold trainTests (only test): multiClass
   % _____________________________________________
   
   % subFunc Input:
   clearvars TRANS_func
%    TRANS_func.func_out_include.CF_testResults = 1;     % =1:func_out include that field, =0:that field does NOT included 
   % TRANS_func.func_out_include.DA.twoClass_test_DA = 0;         % =1:func_out include that field, =0:that field does NOT included 
   TRANS_func.func_out_include.DA.twoClass_test_DA = 1;         % (used only for multipleTwoClassCf) =1:func_out include that field, =0:that field does NOT included 
   TRANS_func.func_out_include.DA.multiClass_test_resultStruct = 1;  % (used only for multiClassBasedCf) =1:func_out include that field, =0:that field does NOT included 
   TRANS_func.func_out_include.DA.multiClass_test_DA = 1;       % =1:func_out include that field, =0:that field does NOT included 
   % TRANS_func.func_out_include.trainTest = 0;           % =1:func_out include that field, =0:that field does NOT included 
   TRANS_func.func_out_include.tt_param.CSP.CSPMatrix = 1;     % =1:func_out include that field, =0:that field does NOT included 
   TRANS_func.func_out_include.tt_param.MI.featureIDs = 1;     % =1:func_out include that field, =0:that field does NOT included 
   % TRANS_func.func_out_include.tt_param.MI.weights = 0;        % =1:func_out include that field, =0:that field does NOT included (comment: MI.weights may will never used: depend on how will write the code) 
   TRANS_func.func_out_include.tt_param.MI.weights = 1;        % =1:func_out include that field, =0:that field does NOT included (comment: MI.weights may will never used: depend on how will write the code) 
   TRANS_func.func_out_include.tt_param.CF.param = 1;     % =1:func_out include that field, =0:that field does NOT included 
% % % % % % % %      w1 = subFunc_tt_2ClassCSP_2ClassMI_2ClassCF(TRANS_func, w0.inner_merged.tt_param, c,w1,w2, wm_CSP_filterPairNumber,wm_MI_quant_level,wm_outFeatureNumberPerClass);     % using global variables: w
   w1 = subFunc_tt_2ClassCSP_2ClassMI_2ClassCF(TRANS_func, c, w.tt.outer.allClass, wm_CSP_filterPairNumber, wm_MI_quant_level, wm_outFeatureNumberPerClass);     % using global variables: w
  
  % ___________________________________________
  % 
  % Smoothing if option for: multiClass_test_DA
  % ___________________________________________
  
  % Input:
  % w1.DA.multiClass_test_DA(1,wt)  % smoothed index wt: (1,:) 
  % c.tt.smoothDistance.multiClass_outerFold_test_DA            % =0:notUsed, >0(=1 or larger):smoothDistance
  % Output:
  % w1.DA.multiClass_test_DA(1,wt)  % smoothed index wt: (1,:) 
  
    w1.DA.multiClass_test_DA(1,:) =  ...
      subFunc_smoother_oneDim(w1.DA.multiClass_test_DA(1,:), c.tt.smoothDistance.multiClass_outerFold_test_DA);
  
  % ________________________________________________
  % 
  % Averaged outer fold classification test accuracy
  % ________________________________________________
   
  % Input:
  % w1.DA.multiClass_test_DA(1,wtID)
  % Output:
  % w1.DA.multiClass_test_DA_average(1,wtID)
  w1.DA.multiClass_test_DA_average = mean(w1.DA.multiClass_test_DA,1);
  
  % ___________________________________________________
  % 
  % Smoothing if option for: multiClass_test_DA_average
  % ___________________________________________________
  
  % Input:
  % w1.DA.multiClass_test_DA_average(1,wt)  % smoothed index wt: (1,:) 
  % c.tt.smoothDistance.multiClass_outerFold_test_DA_average            % =0:notUsed, >0(=1 or larger):smoothDistance
  % Output:
  % w1.DA.multiClass_test_DA_average_smooth(1,wt)  % smoothed index wt: (1,:) 
  w1.DA.multiClass_test_DA_average_smooth(1,:) =  ...
      subFunc_smoother_oneDim(w1.DA.multiClass_test_DA_average(1,:), c.tt.smoothDistance.multiClass_outerFold_test_DA_average);
  
  % __________________________________________________________________________________________
  % 
  % Find and Store: best averaged outer fold classification test accuracy (during task period)
  % __________________________________________________________________________________________
  
  % Input:
  % ...
  % Output:
  % w0.outer.DA.multiClass_test_DA(1, wtID)             : !!!! THIS MAYBE NOT NEED TO SAVE (THAN DELET THIS LINE) !!!! 
  % w0.outer.DA.multiClass_test_DA_average(1, wtID)     : !!!! THIS MAYBE NOT NEED TO SAVE (THAN DELET THIS LINE) !!!! 
  % w0.outer.DA.multiClass_test_DA_average_smooth(1, wtID)     : !!!! THIS MAYBE NOT NEED TO SAVE (THAN DELET THIS LINE) !!!! 
  % w0.outer.DA_best.multiClass_best_DA_average_firstWinEndAtTrig
  % w0.outer.DA_best.multiClass_best_DA_average_smooth_firstWinEndAtTrig
  % w0.outer.tt_param (included):
  %     w0.outer.tt_param(wm_targetClassID,wtID).CSP.CSPMatrix
  %     w0.outer.tt_param(wm_targetClassID,wtID).MI.featureIDs
  %     w0.outer.tt_param(wm_targetClassID,wtID).MI.weights
  %     w0.outer.tt_param(wm_targetClassID,wtID).CF.param
  w0.outer.DA.multiClass_test_DA(1, :) = w1.DA.multiClass_test_DA(1,:);                 % !!!! THIS MAYBE NOT NEED TO SAVE (THAN DELET THIS LINE) !!!! 
  % w0.outer.DA.multiClass_test_DA_average(1, :) = w1.DA.multiClass_test_DA_average(1,:); % !!!! THIS MAYBE NOT NEED TO SAVE (THAN DELET THIS LINE) !!!! 
  % w0.outer.DA.multiClass_test_DA_average_smooth(1, :) = w1.DA.multiClass_test_DA_average_smooth(1,:); % !!!! THIS MAYBE NOT NEED TO SAVE (THAN DELET THIS LINE) !!!! 

  % !!!!!! AS ONLY ONE OUTER FOLD TETED IN THIS FUNCTION !!!!!!: 
  w0.outer.DA.multiClass_test_DA_smooth(1, :) = w1.DA.multiClass_test_DA_average_smooth(1,:); % !!!! THIS MAYBE NOT NEED TO SAVE (THAN DELET THIS LINE) !!!! 
  
  w0.outer.DA_best.multiClass_best_DA_average_firstWinEndAtTrig = ... 
    max(w1.DA.multiClass_test_DA_average(1,...
        (abs(c.prep.trial.trig_PRE_ms)-c.tt.cf.p.winSize.ms)/c.tt.cf.p.winStep.ms+1 : size(w1.DA.multiClass_test_DA_average,2)));    % DA values from that point when when the end of the DA calc window was at the trigger (which just begun to cover the task period)  
  w0.outer.DA_best.multiClass_best_DA_average_smooth_firstWinEndAtTrig = ... 
    max(w1.DA.multiClass_test_DA_average_smooth(1,...
        (abs(c.prep.trial.trig_PRE_ms)-c.tt.cf.p.winSize.ms)/c.tt.cf.p.winStep.ms+1 : size(w1.DA.multiClass_test_DA_average_smooth,2)));    % DA values from that point when when the end of the DA calc window was at the trigger (which just begun to cover the task period)  
  
  w0.outer.tt_param = w1.tt_param;
  
    
  clearvars w1;
  
  
  
  
%% mergedOuter fold setup [using all outer folds (training data all outerFold together), test: all outer fold together (test using training data) ]

  if wm_outerFoldID == 1  	% outer merged trainTest have to do only once (as same for all outer folds)
   
   % ___________________________________________________
   %
   % Merged Outer fold (training and test) trialID setup
   % ___________________________________________________

   % Input:
   % % % w.tt.inner.trialID2s.all_inRandpermOrder{wm_classID, 1}(1,wm_trialID)
   % w.tt.outer.trialID2s.train{wm_classID, 1}(1,wm_trialID)
   % Output:
   % w.tt.mergedOuter.trialID2s.train{wm_classID, 1}(1,wm_trialID)
   % w.tt.mergedOuter.trialID2s.test{wm_classID, 1}(1,wm_trialID)
  
   for wm_classID = 1 : size(c.classSetup.class.targetIDs_linkedTo_classID,1)
      w.tt.mergedOuter.trialID2s.train{wm_classID, 1}(1,:) = w.tt.outer.trialID2s.all{wm_classID, 1}(1,:);
      w.tt.mergedOuter.trialID2s.test{wm_classID, 1}(1,:) = w.tt.outer.trialID2s.all{wm_classID, 1}(1,:);
   end

   % _____________________________________
   % 
   % Merged Outer fold allClass trial prep
   % _____________________________________

   % Input:
   % w.tt.outer.validCh_trials.all{wm_classID, wm_bandID}(wt, wk, wm_trialID)
   % w.tt.mergedOuter.trialID2s.train{wm_classID, 1}(1,wm_trialID)
   % w.tt.mergedOuter.trialID2s.test{wm_classID, 1}(1,wm_trialID)
   % Output:
   % w.tt.mergedOuter.allClass.validCh_trials.train{1, wm_bandID}(wt, wk, wm_trialID)
   % w.tt.mergedOuter.allClass.validCh_trials.test{1, wm_bandID}(wt, wk, wm_trialID)
   % w.tt.mergedOuter.allClass.trialClassLabels.train(1, wm_trialID)
   % w.tt.mergedOuter.allClass.trialClassLabels.test(1, wm_trialID)
   wm_train = 0;
   wm_test = 0;
   for wm_classID = 1 : size(c.classSetup.class.targetIDs_linkedTo_classID,1)
     for wm_bandID = c.classSetup.band.usedIDs
        wm = size(w.tt.mergedOuter.trialID2s.train{wm_classID, 1},2);
        w.tt.mergedOuter.allClass.validCh_trials.train{1, wm_bandID}(:,:,wm_train+1:wm_train+wm) = ...
            w.tt.outer.validCh_trials.all{wm_classID, wm_bandID}(:,:,w.tt.outer.trialIDs.all{wm_classID, 1}(1, w.tt.mergedOuter.trialID2s.train{wm_classID, 1}(1,:)));
        wm = size(w.tt.mergedOuter.trialID2s.test{wm_classID, 1},2);
        w.tt.mergedOuter.allClass.validCh_trials.test{1, wm_bandID}(:,:,wm_test+1:wm_test+wm) = ...
            w.tt.outer.validCh_trials.all{wm_classID, wm_bandID}(:,:,w.tt.outer.trialIDs.all{wm_classID, 1}(1, w.tt.mergedOuter.trialID2s.test{wm_classID, 1}(1,:)));
     end
     wm = size(w.tt.mergedOuter.trialID2s.train{wm_classID, 1},2);
     w.tt.mergedOuter.allClass.trialClassLabels.train(1,wm_train+1:wm_train+wm) = wm_classID;
     wm_train = wm_train + wm;
     wm = size(w.tt.mergedOuter.trialID2s.test{wm_classID, 1},2);
     w.tt.mergedOuter.allClass.trialClassLabels.test(1,wm_test+1:wm_test+wm) = wm_classID;
     wm_test = wm_test + wm;
   end
   
  end
  
  

%% mergedOuter trainTest [using all outer folds (training data all outerFold together), test: all outer fold together (test using training data)] 

  if wm_outerFoldID == 1  	% outer merged trainTest have to do only once (as same for all outer folds)
  
  % ___________________________________________________
  %
  % Parameter set setup for Merged inner fold trainTest
  % ___________________________________________________
  
   
   % ________________________________________
   %
   % Merged Outer fold trainTests: multiClass
   % ________________________________________
   
   % subFunc Input:
   clearvars TRANS_func
%    TRANS_func.func_out_include.CF_testResults = 1;     % =1:func_out include that field, =0:that field does NOT included 
   TRANS_func.func_out_include.DA.twoClass_test_DA = 0;         % (used only for multipleTwoClassCf) =1:func_out include that field, =0:that field does NOT included 
   TRANS_func.func_out_include.DA.multiClass_test_resultStruct = 0;  % (used only for multiClassBasedCf) =1:func_out include that field, =0:that field does NOT included 
   TRANS_func.func_out_include.DA.multiClass_test_DA = 1;       % =1:func_out include that field, =0:that field does NOT included 
   % TRANS_func.func_out_include.trainTest = 0;           % =1:func_out include that field, =0:that field does NOT included 
   TRANS_func.func_out_include.tt_param.CSP.CSPMatrix = 1;     % =1:func_out include that field, =0:that field does NOT included 
   TRANS_func.func_out_include.tt_param.MI.featureIDs = 1;     % =1:func_out include that field, =0:that field does NOT included 
   % TRANS_func.func_out_include.tt_param.MI.weights = 0;        % =1:func_out include that field, =0:that field does NOT included (comment: MI.weights may will never used: depend on how will write the code) 
   TRANS_func.func_out_include.tt_param.MI.weights = 1;        % =1:func_out include that field, =0:that field does NOT included (comment: MI.weights may will never used: depend on how will write the code) 
   TRANS_func.func_out_include.tt_param.CF.param = 1;     % =1:func_out include that field, =0:that field does NOT included 
   w1 = subFunc_tt_2ClassCSP_2ClassMI_2ClassCF(TRANS_func, c, w.tt.mergedOuter.allClass, wm_CSP_filterPairNumber, wm_MI_quant_level, wm_outFeatureNumberPerClass);     % using global variables: w
   
  % ___________________________________________
  % 
  % Smoothing if option for: multiClass_test_DA
  % ___________________________________________
  
  % Input:
  % w1.DA.multiClass_test_DA(1,wt)  % smoothed index wt: (1,:) 
  % c.tt.smoothDistance.multiClass_outerFold_test_DA            % =0:notUsed, >0(=1 or larger):smoothDistance
  % Output:
  % w1.DA.multiClass_test_DA(1,wt)  % smoothed index wt: (1,:) 
  w1.DA.multiClass_test_DA(1,:) =  ...
      subFunc_smoother_oneDim(w1.DA.multiClass_test_DA(1,:), c.tt.smoothDistance.multiClass_outerFold_test_DA);
  
  % ________________________________________________
  % 
  % Averaged all fold classification test accuracy
  % ________________________________________________
   
  % Input:
  % w1.DA.multiClass_test_DA(1,wtID)
  % Output:
  % w1.DA.multiClass_test_DA_average(1,wtID)
  w1.DA.multiClass_test_DA_average = mean(w1.DA.multiClass_test_DA,1);
  
  % ___________________________________________________
  % 
  % Smoothing if option for: multiClass_test_DA_average
  % ___________________________________________________
  
  % Input:
  % w1.DA.multiClass_test_DA_average(1,wt)  % smoothed index wt: (1,:) 
  % c.tt.smoothDistance.multiClass_outerFold_test_DA_average            % =0:notUsed, >0(=1 or larger):smoothDistance
  % Output:
  % w1.DA.multiClass_test_DA_average_smooth(1,wt)  % smoothed index wt: (1,:) 
  w1.DA.multiClass_test_DA_average_smooth(1,:) =  ...
      subFunc_smoother_oneDim(w1.DA.multiClass_test_DA_average(1,:), c.tt.smoothDistance.multiClass_outerFold_test_DA_average);
  
  % __________________________________________________________________________________________
  % 
  % Find and Store: best averaged all fold classification test accuracy (during task period)
  % __________________________________________________________________________________________
  
  % Input:
  % ...
  % Output:
  % w0.outer_merged.DA.multiClass_test_DA(1, wtID)             : !!!! THIS MAYBE NOT NEED TO SAVE (THAN DELET THIS LINE) !!!! 
  % w0.outer_merged.DA.multiClass_test_DA_average(1, wtID)     : !!!! THIS MAYBE NOT NEED TO SAVE (THAN DELET THIS LINE) !!!! 
  % w0.outer_merged.DA.multiClass_test_DA_average_smooth(1, wtID)     : !!!! THIS MAYBE NOT NEED TO SAVE (THAN DELET THIS LINE) !!!! 
  % w0.outer_merged.DA_best.multiClass_best_DA_average_firstWinEndAtTrig
  % w0.outer_merged.DA_best.multiClass_best_DA_average_smooth_firstWinEndAtTrig
  % w0.outer_merged.tt_param (included):
  %     w0.outer_merged.tt_param(wm_targetClassID,wtID).CSP.CSPMatrix
  %     w0.outer_merged.tt_param(wm_targetClassID,wtID).MI.featureIDs
  %     w0.outer_merged.tt_param(wm_targetClassID,wtID).MI.weights
  %     w0.outer_merged.tt_param(wm_targetClassID,wtID).CF.param
  w0.outer_merged.DA.multiClass_test_DA(:, :) = w1.DA.multiClass_test_DA(:,:);                 % !!!! THIS MAYBE NOT NEED TO SAVE (THAN DELET THIS LINE) !!!! 
  w0.outer_merged.DA.multiClass_test_DA_average(1, :) = w1.DA.multiClass_test_DA_average(1,:); % !!!! THIS MAYBE NOT NEED TO SAVE (THAN DELET THIS LINE) !!!! 
  w0.outer_merged.DA.multiClass_test_DA_average_smooth(1, :) = w1.DA.multiClass_test_DA_average_smooth(1,:); % !!!! THIS MAYBE NOT NEED TO SAVE (THAN DELET THIS LINE) !!!! 
  
  w0.outer_merged.DA_best.multiClass_best_DA_average_firstWinEndAtTrig = ... 
    max(w1.DA.multiClass_test_DA_average(1,...
        (abs(c.prep.trial.trig_PRE_ms)-c.tt.cf.p.winSize.ms)/c.tt.cf.p.winStep.ms+1 : size(w1.DA.multiClass_test_DA_average,2)));    % DA values from that point when when the end of the DA calc window was at the trigger (which just begun to cover the task period)  
  w0.outer_merged.DA_best.multiClass_best_DA_average_smooth_firstWinEndAtTrig = ... 
    max(w1.DA.multiClass_test_DA_average_smooth(1,...
        (abs(c.prep.trial.trig_PRE_ms)-c.tt.cf.p.winSize.ms)/c.tt.cf.p.winStep.ms+1 : size(w1.DA.multiClass_test_DA_average_smooth,2)));    % DA values from that point when when the end of the DA calc window was at the trigger (which just begun to cover the task period)  
  
  w0.outer_merged.tt_param = w1.tt_param;
  
  
  end
  
  
  
  
  
  
  
%% Autosave
  
  % _________
  % 
  % AUTO SAVE
  % _________
  
  % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  % !!!!!!!!!!! STRUCTURE TO BE SAVED IN AUTORUN LOOP !!!!!!!!!!!! 
  % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  
  % storing inner and outer fold tt_parameters and DA results (collected in w0)
  % ___________________________________________________________________________
  
  if autorun.tt.file.save.autosave_w0 == 1
    
    w.file.save.name = [autorun.tt.file.save.nameBasis.offlineClass_trainTest__w0,'{',num2str(wm_subjID2),',',num2str(wm_sessionID2),',',num2str(wm_outerFoldID),'}.mat'];
    if autorun.tt.parCore.parforUsed == 0
        save([autorun.tt.file.save.path.offlineClass_trainTest,w.file.save.name],'w0','-v7.3');
    else
        csc_parsave([autorun.tt.file.save.path.offlineClass_trainTest,w.file.save.name], w0);
    end

  end

  
  
  
%% subFunction

  % __________________________
  % 
  % Function: 2Class train CSP
  % __________________________
  
  function wf = subFunc_train_2ClassCSP_subFunc_featureExtract(c, wm_CSP_filterPairNumber, allClass, wt)
   
   % Info:
   % wf_wm_CSP_filterPairNumber = wm_CSP_filterPairNumber;
   % c.tt.cf = TRANS_func.c.tt.cf;
   
    % ___________________________
    % 
    % Training: FeatureExtraction
    % ___________________________
      
    for wf_wm_bandID = c.classSetup.band.usedIDs
      
      % _____________
      % 
      % Training: CSP
      % _____________
      
      % Input:
      % allClass.validCh_trials.train{1, wf_wm_bandID}(wt, wk, wf_trialID)
      % allClass.trialClassLabels_2Class.train(1, wf_trialID)
      % Output:
      % wf.train.EEG.x(wt, wk, wf_trialID)
      % wf.train.EEG.y(1, wf_trialID)
      % wf.train.EEG.s = sr
      wf.train.EEG.x = allClass.validCh_trials.train{1, wf_wm_bandID}(wt-c.tt.cf.p.winSize.samp+1:wt, :, :);    % wf.train.EEG.x(wt, wk, wf_trialID)
      wf.train.EEG.y = allClass.trialClassLabels_2Class.train;          % wf.train.EEG.y(1, wf_trialID)
      wf.train.EEG.s = c.tt.sr;                                                     % wf.train.EEG.s = sr
      
      if c.tt.cf.p.CSP.method_CSP1_TRCSP2 == 1

        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        % !!! possible error correction in dataset !!!
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        wf.train.EEG.x(find(isnan( wf.train.EEG.x ))) = 0;
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        
        wf.trainTest.CSP.CSPMatrix{wf_wm_bandID,1} = learnCSP(wf.train.EEG);
      elseif c.tt.cf.p.CSP.method_CSP1_TRCSP2 == 2
        wf.train.EEG.c = NaN;  % Not used but need this field
        [wf.train.TR_CSP.bestAlpha, wf.train.TR_CSP.bestScore] = csc_TR_CSPWithBestParams(wf.train.EEG, c.tt.cf.p.CSP.TR_CSP.alphaList, c.tt.cf.p.CSP.TR_CSP.CV_folds, wm_CSP_filterPairNumber);
        wf.trainTest.CSP.CSPMatrix{wf_wm_bandID,1} = learn_TR_CSP(wf.train.EEG, wf.train.TR_CSP.bestAlpha);
      end
      
      % ___________________________
      % 
      % Training: FeatureExtraction
      % ___________________________
      
      % Input:
      % wf.train.EEG.x(wt, wk, wf_trialID)
      % wf.train.EEG.y(1, wf_trialID)
      % wf.train.EEG.s = sr
      % wf.trainTest.CSP.CSPMatrix{wf_wm_bandID,1}: the CSP projection matrix, learnt previously (see function learnCSP)
      % wm_CSP_filterPairNumber: number of pairs of CSP filters to be used. The number of features extracted will be twice the value of this parameter.
      %                          The filters selected are the one corresponding to the lowest and highest eigenvalues
      % Output:
      % wf.train.features.band{wf_wm_bandID,1}(wm_trialID, wm_CSP_filterPairNumber*2 + classLabel)
      wf.train.features.band{wf_wm_bandID,1} = extractCSPFeatures(wf.train.EEG, wf.trainTest.CSP.CSPMatrix{wf_wm_bandID,1}, wm_CSP_filterPairNumber);
    
      % !!! ERROR CORRECTION : this need because maybe sometimes (rarely) contains complex (xx + 3.1415i, i.e.: xx + pi(i)) but the real part ok
      % ________________________________________________________________________________________________________________________________________
      % imag(wf.wm.train.features.allUsedBands)
      % isreal(wf.wm.train.features.allUsedBands)
      wf.train.features.band{wf_wm_bandID,1} = real(wf.train.features.band{wf_wm_bandID,1});   % this need because maybe sometimes contains complex (xx + 3.1415i, i.e.: xx + pi(i)) but the real part ok
      
    end
    
  end
  
  
%% subFunction

  % _____________________
  % 
  % Function: 2Class test
  % _____________________
  
  function wf = subFunc_test_2ClassCSP_subFunc_featureExtract(c, wm_CSP_filterPairNumber, allClass, wf, wt)
   
   % Info:
   % wf_wm_CSP_filterPairNumber = wm_CSP_filterPairNumber;
   % c.tt.cf = TRANS_func.c.tt.cf;
   
    % _______________________________
    % 
    % Test: CSP and FeatureExtraction
    % _______________________________

    for wf_wm_bandID = c.classSetup.band.usedIDs
        
      % Input:
      % allClass.validCh_trials.test{1, wf_wm_bandID}(wt, wk, wf_trialID)
      % allClass.trialClassLabels_2Class.test(1, wf_trialID)
      % Output:
      % wf.test.EEG.x(wt, wk, wf_trialID)
      % wf.test.EEG.y(1, wf_trialID)
      % wf.test.EEG.s = sr
      wf.test.EEG.x = allClass.validCh_trials.test{1, wf_wm_bandID}(wt-c.tt.cf.p.winSize.samp+1:wt, :, :);      % wf.test.EEG.x(wt, wk, wf_trialID)
      wf.test.EEG.y = allClass.trialClassLabels_2Class.test;            % wf.test.EEG.y(1, wf_trialID)
      wf.test.EEG.s = c.tt.sr;                                                      % wf.train.EEG.s = sr
      
      % _______________________
      % 
      % Test: FeatureExtraction
      % _______________________
      
      % Input:
      % wf.test.EEG.x(wt, wk, wf_trialID)
      % wf.test.EEG.y(1, wf_trialID)
      % wf.test.EEG.s = sr
      % wf.trainTest.CSP.CSPMatrix{wf_wm_bandID,1}: the CSP projection matrix, learnt previously (see function learnCSP)
      % wm_CSP_filterPairNumber: number of pairs of CSP filters to be used. The number of features extracted will be twice the value of this parameter.
      %                          The filters selected are the one corresponding to the lowest and highest eigenvalues
      % Output:
      % wf.test.features.band{wf_wm_bandID,1}(wm_trialID, wm_CSP_filterPairNumber*2 + classLabel)
      wf.test.features.band{wf_wm_bandID,1} = extractCSPFeatures(wf.test.EEG, wf.trainTest.CSP.CSPMatrix{wf_wm_bandID,1}, wm_CSP_filterPairNumber);
      
      % !!! ERROR CORRECTION : this need because maybe sometimes (rarely) contains complex (xx + 3.1415i, i.e.: xx + pi(i)) but the real part ok
      % ________________________________________________________________________________________________________________________________________
      % imag(wf.wm.test.features.allUsedBands)
      % isreal(wf.wm.test.features.allUsedBands)
      wf.test.features.band{wf_wm_bandID,1} = real(wf.test.features.band{wf_wm_bandID,1});  % this need because maybe sometimes contains complex (xx + 3.1415i, i.e.: xx + pi(i)) but the real part ok
      
    end
    
  end
  
  
%% subFunction

  % _________________________________________________
  % 
  % Function: 2ClassCSP_2ClassMI_2ClassCF based train
  % _________________________________________________
  
  function func_out = subFunc_train_2ClassCSP_2ClassMI_2ClassCF(c, wm_CSP_filterPairNumber,wm_MI_quant_level,wm_outFeatureNumberPerClass, allClass)
   
   % Info:
   % wf_wm_CSP_filterPairNumber = wm_CSP_filterPairNumber;
   % wf_wm_MI_quant_level = wm_MI_quant_level;
   % wf_wm_outFeatureNumberPerClass = wm_outFeatureNumberPerClass;
   % c.tt.cf = TRANS_func.c.tt.cf;
   
   for wt = c.tt.cf.p.winSize.samp : c.tt.cf.p.winStep.samp : size(allClass.validCh_trials.train{1, c.classSetup.band.usedIDs(1,1)},1)
    wtID = ((wt-c.tt.cf.p.winSize.samp)/c.tt.cf.p.winStep.samp)+1;
    
    clearvars wf
    wf = subFunc_train_2ClassCSP_subFunc_featureExtract(c, wm_CSP_filterPairNumber, allClass, wt);
    
    % _____________________
    % 
    % Training: Mutual info
    % _____________________
    
    % Input:
    % ...
    % Output:
    % wf.wm.train.features.final(wm_trialID, wm_MI_out_featureID + classLabel)
    for wf_wm_band2ID = 1 : size(c.classSetup.band.usedIDs,2)
      wf_wm_bandID = c.classSetup.band.usedIDs(1,wf_wm_band2ID);
      wf.wm.train.features.allUsedBands(1:size(wf.train.features.band{wf_wm_bandID,1},1),((wf_wm_band2ID-1)*wm_CSP_filterPairNumber*2)+1:(wf_wm_band2ID*wm_CSP_filterPairNumber*2)) = ...
        wf.train.features.band{wf_wm_bandID,1}(:,1:wm_CSP_filterPairNumber*2);
    end
    wf.wm.train.features.allUsedBands(1:size(wf.train.features.band{wf_wm_bandID,1},1),(wf_wm_band2ID*wm_CSP_filterPairNumber*2)+1) = wf.train.features.band{wf_wm_bandID,1}(:,(wm_CSP_filterPairNumber*2)+1);
    
    % [wf.trainTest.MI.featureIDs,wf.trainTest.MI.weights] = MI(wf.wm.train.features.allUsedBands(:,1:end-1), allClass.trialClassLabels_2Class.train, wm_MI_quant_level);    % Mutual info
    [wf.trainTest.MI.featureIDs,wf.trainTest.MI.weights] = MI(wf.wm.train.features.allUsedBands(:,1:size(wf.wm.train.features.allUsedBands,2)-1), allClass.trialClassLabels_2Class.train, wm_MI_quant_level);    % Mutual info
%!!!! wf.trainTest.MI.featureIDs = 1:4;
    wf.wm.train.features.final(:,1:wm_outFeatureNumberPerClass) = wf.wm.train.features.allUsedBands(:,wf.trainTest.MI.featureIDs(1:wm_outFeatureNumberPerClass));
    wf.wm.train.features.final(:,wm_outFeatureNumberPerClass+1) = wf.wm.train.features.allUsedBands(:,size(wf.wm.train.features.allUsedBands,2));
% !!! wf.wm.train.features.final = wf.wm.train.features.allUsedBands;
    
    % _________________________
    % 
    % Training: CF (classifier)
    % _________________________
    
    % Input:
    % wf.wm.train.features.final(wm_trialID, wm_MI_out_featureID + classLabel)
    % Output:
    % wf.trainTest.CF.param: structure
    %     the parameters of the LDA discriminant hyperplane with
    %       ldaParams.a0: bias of the discriminant hyperplane    
    %       ldaParams.a1N: slope of the discriminant hyperplane
    %       ldaParams.classLabels: class labels for this data set
    %     the decision function is then a0 + a1N' * v where v is the input feature vector
% % % %     switch c.tt.cf.p.CF.method.toolbox
% % % %       case 'RCSPToolbox'
          if strcmp(c.tt.cf.p.CF.method.trainMethod,'LDA')      % LDA training method setup (LDA, RLDA)
            [wf.trainTest.CF.param] = LDA_Train(wf.wm.train.features.final);
          elseif strcmp(c.tt.cf.p.CF.method.trainMethod,'RLDA')     % LDA training method setup (LDA, RLDA)
            [wf.trainTest.CF.param] = RLDA_Train(wf.wm.train.features.final);
          end
% % % %     end
  
    % ______________________________________
    % 
    % Collecting: Function output parameters
    % ______________________________________
    
    func_out(1, wtID).tt_param.CSP.CSPMatrix = wf.trainTest.CSP.CSPMatrix;
    func_out(1, wtID).tt_param.MI.featureIDs = wf.trainTest.MI.featureIDs;
    func_out(1, wtID).tt_param.MI.weights = wf.trainTest.MI.weights;           %  (comment: MI.weights may will never used: depend on how will write the code) 
    func_out(1, wtID).tt_param.CF.param = wf.trainTest.CF.param;
    
   end
  end
  
  
%% subFunction

  % ________________________________________________
  % 
  % Function: 2ClassCSP_2ClassMI_2ClassCF based test
  % ________________________________________________
  
  function func_out = subFunc_test_2ClassCSP_2ClassMI_2ClassCF(c,w3, wm_CSP_filterPairNumber, wm_outFeatureNumberPerClass, allClass)
   
   % Info:
   % wf_wm_CSP_filterPairNumber = wm_CSP_filterPairNumber;
   % wf_wm_MI_quant_level = wm_MI_quant_level;
   % wf_wm_outFeatureNumberPerClass = wm_outFeatureNumberPerClass;
   % c.tt.cf = TRANS_func.c.tt.cf;
   
   % for wt = c.tt.cf.p.winSize.samp : c.tt.cf.p.winStep.samp : size(w.tt.outer.allClass.validCh_trials.train{1, c.classSetup.band.usedIDs(1,1)},1)
   for wt = c.tt.cf.p.winSize.samp : c.tt.cf.p.winStep.samp : size(allClass.validCh_trials.test{1, c.classSetup.band.usedIDs(1,1)},1)
    wtID = ((wt-c.tt.cf.p.winSize.samp)/c.tt.cf.p.winStep.samp)+1;
    
    clearvars wf
    
    % _____________________
    % 
    % Collecting train info
    % _____________________
    
    wf.trainTest.CSP.CSPMatrix = w3.train_2ClassCSP_2ClassMI_2ClassCF_funcOut(1,wtID).tt_param.CSP.CSPMatrix;
    wf.trainTest.MI.featureIDs = w3.train_2ClassCSP_2ClassMI_2ClassCF_funcOut(1,wtID).tt_param.MI.featureIDs;
    % wf.trainTest.MI.weights = w3.train_2ClassCSP_2ClassMI_2ClassCF_funcOut(1,wtID).tt_param.MI.weights; % (comment: MI.weights may will never used: depend on how will write the code) 
    wf.trainTest.CF.param = w3.train_2ClassCSP_2ClassMI_2ClassCF_funcOut(1,wtID).tt_param.CF.param;
    
    wf = subFunc_test_2ClassCSP_subFunc_featureExtract(c, wm_CSP_filterPairNumber, allClass, wf, wt);
    
    % _________________
    % 
    % Test: Mutual info
    % _________________
    
    % Input:
    % ...
    % Output:
    % wf.wm.test.features.final(wm_trialID, wm_MI_out_featureID + classLabel)
    for wf_wm_band2ID = 1 : size(c.classSetup.band.usedIDs,2)
      wf_wm_bandID = c.classSetup.band.usedIDs(1,wf_wm_band2ID);
      wf.wm.test.features.allUsedBands(1:size(wf.test.features.band{wf_wm_bandID,1},1),((wf_wm_band2ID-1)*wm_CSP_filterPairNumber*2)+1:(wf_wm_band2ID*wm_CSP_filterPairNumber*2)) = ...
        wf.test.features.band{wf_wm_bandID,1}(:,1:wm_CSP_filterPairNumber*2);
    end
    wf.wm.test.features.allUsedBands(1:size(wf.test.features.band{wf_wm_bandID,1},1),(wf_wm_band2ID*wm_CSP_filterPairNumber*2)+1) = wf.test.features.band{wf_wm_bandID,1}(:,(wm_CSP_filterPairNumber*2)+1);
    
    wf.wm.test.features.final(:,1:wm_outFeatureNumberPerClass) = wf.wm.test.features.allUsedBands(:,wf.trainTest.MI.featureIDs(1:wm_outFeatureNumberPerClass));
    wf.wm.test.features.final(:,wm_outFeatureNumberPerClass+1) = wf.wm.test.features.allUsedBands(:,size(wf.wm.test.features.allUsedBands,2));
% !!! wf.wm.test.features.final = wf.wm.test.features.allUsedBands;
    
    % _________
    % 
    % Test: LDA
    % _________
    
    % Input:
    % wf.wm.test.features.final(wm_trialID, wm_MI_out_featureID + classLabel)
    % wf.trainTest.CF.param: structure
    %     the parameters of the LDA discriminant hyperplane with
    %       ldaParams.a0: bias of the discriminant hyperplane    
    %       ldaParams.a1N: slope of the discriminant hyperplane
    %       ldaParams.classLabels: class labels for this data set
    %     the decision function is then a0 + a1N' * v where v is the input feature vector
    % Output:
    %  result: the classification results where:
    %     result.output: the predicted classification output for each feature vector
    %     result.classes: the predicted class label for each feature vector
    %     result.accuracy: the accuracy obtained (%)
% % % %     switch c.tt.cf.p.CF.method.toolbox
% % % %       case 'RCSPToolbox'
        wf.CF_testResults = LDA_Test(wf.wm.test.features.final, wf.trainTest.CF.param);
% % % %     end
    
    % ______________________________________
    % 
    % Collecting: Function output parameters
    % ______________________________________
    
    func_out(1, wtID).CF_testResults = wf.CF_testResults;
    
   end
  end
  
  
%% subFunction

  % ____________________________________________________________________________
  % 
  % Function: multiClass trainTest (2-class CSP, 2-class MI, 2-class classifier)
  % ____________________________________________________________________________
  
  function w1 = subFunc_tt_2ClassCSP_2ClassMI_2ClassCF(func_in, c, allClass, wm_CSP_filterPairNumber, wm_MI_quant_level, wm_outFeatureNumberPerClass)
   
   % Input:
   % % % % USED ONLY IN PREVIOUS CODE: func_in.func_out_include.CF_testResults     % =1:func_out include that field, =0:that field does NOT included 
   % func_in.func_out_include.DA.twoClass_test_DA         % =1:func_out include that field, =0:that field does NOT included 
   % func_in.func_out_include.DA.multiClass_test_DA       % =1:func_out include that field, =0:that field does NOT included 
   % func_in.func_out_include.tt_param.CSP.CSPMatrix     % =1:func_out include that field, =0:that field does NOT included 
   % func_in.func_out_include.tt_param.MI.featureIDs     % =1:func_out include that field, =0:that field does NOT included 
   % func_in.func_out_include.tt_param.MI.weights        % =1:func_out include that field, =0:that field does NOT included (comment: MI.weights may will never used: depend on how will write the code) 
   % func_in.func_out_include.tt_param.CF.param     % =1:func_out include that field, =0:that field does NOT included 
   
   % Output (optional: depend on input settings):
   % w1.DA.twoClass_test_DA(wm_targetClassID, wtID)
   % w1.DA.multiClass_test_DA(wm_targetClassID, wtID)
   % w1.tt_param(wm_targetClassID,wtID).CSP.CSPMatrix
   % w1.tt_param(wm_targetClassID,wtID).MI.featureIDs
   % w1.tt_param(wm_targetClassID,wtID).MI.weights
   % w1.tt_param(wm_targetClassID,wtID).CF.param
   
   
   % __________________
   %
   % trainTest: 2-class
   % __________________
   
   if (c.tt.cf.p.use_multiClass_cf_onlyIf_numberOfClassesMoreThanTwo==1) && (size(c.classSetup.class.targetIDs_linkedTo_classID,1)==2)
       w2.targetClassIDs_usedFor_2Class_tt = 1;
   else
       w2.targetClassIDs_usedFor_2Class_tt = 1 : size(c.classSetup.class.targetIDs_linkedTo_classID,1);
   end
   for wm_targetClassID = w2.targetClassIDs_usedFor_2Class_tt
       
       clearvars w3 
       
           allClass.trialClassLabels_2Class.train(1, find(allClass.trialClassLabels.train == wm_targetClassID)) = 1;    % 2-class target labels
           allClass.trialClassLabels_2Class.train(1, find(allClass.trialClassLabels.train ~= wm_targetClassID)) = 2;    % 2-class non-target labels
           
           allClass.trialClassLabels_2Class.test(1, find(allClass.trialClassLabels.test == wm_targetClassID)) = 1;    % 2-class target labels
           allClass.trialClassLabels_2Class.test(1, find(allClass.trialClassLabels.test ~= wm_targetClassID)) = 2;    % 2-class non-target labels
       
           % train: 2-class
           % ______________

           % subFunc Input:
           % func_in + :
           % % % USED ONLY IN PREVIOUS CODE: func_in.func_out_include.CF_testResults = 1;     % =1:func_out include that field, =0:that field does NOT included 
           % subFunc Output:
           % w3.train_2ClassCSP_2ClassMI_2ClassCF_funcOut(1,wt) <- structure
           w3.train_2ClassCSP_2ClassMI_2ClassCF_funcOut(1,:) = subFunc_train_2ClassCSP_2ClassMI_2ClassCF(c, wm_CSP_filterPairNumber,wm_MI_quant_level,wm_outFeatureNumberPerClass, allClass);
       
       % test: 2-class
       % _____________
       
       % subFunc Input:
       % func_in + :
       % w3.train_2ClassCSP_2ClassMI_2ClassCF_funcOut(1,wt) <- structure
       % subFunc Output:
       % w2.test_twoClass_funcOut(wm_classID,wt) <- structure
       w2.test_twoClass_funcOut(wm_targetClassID,:) = subFunc_test_2ClassCSP_2ClassMI_2ClassCF(c,w3, wm_CSP_filterPairNumber, wm_outFeatureNumberPerClass, allClass);
       
       % Collecting: function output: 
       % ____________________________
       
       % Train parameters:
       for wtID = 1 : size(w3.train_2ClassCSP_2ClassMI_2ClassCF_funcOut,2)
         if func_in.func_out_include.tt_param.CSP.CSPMatrix == 1     % =1:func_out include that field, =0:that field does NOT included 
            w1.tt_param(wm_targetClassID,wtID).CSP.CSPMatrix = w3.train_2ClassCSP_2ClassMI_2ClassCF_funcOut(1,wtID).tt_param.CSP.CSPMatrix;
         end
         if func_in.func_out_include.tt_param.MI.featureIDs == 1     % =1:func_out include that field, =0:that field does NOT included 
            w1.tt_param(wm_targetClassID,wtID).MI.featureIDs = w3.train_2ClassCSP_2ClassMI_2ClassCF_funcOut(1,wtID).tt_param.MI.featureIDs;
         end
         if func_in.func_out_include.tt_param.MI.weights ==1        % =1:func_out include that field, =0:that field does NOT included 
            w1.tt_param(wm_targetClassID,wtID).MI.weights = w3.train_2ClassCSP_2ClassMI_2ClassCF_funcOut(1,wtID).tt_param.MI.weights;  % (comment: MI.weights may will never used: depend on how will write the code) 
         end
         if func_in.func_out_include.tt_param.CF.param == 1     % =1:func_out include that field, =0:that field does NOT included 
            w1.tt_param(wm_targetClassID,wtID).CF.param = w3.train_2ClassCSP_2ClassMI_2ClassCF_funcOut(1,wtID).tt_param.CF.param;
         end
       end 
       
       % Test results:
       for wtID = 1 : size(w2.test_twoClass_funcOut,2)
         if func_in.func_out_include.DA.twoClass_test_DA == 1     % =1:func_out include that field, =0:that field does NOT included 
            w1.DA.twoClass_test_DA(wm_targetClassID, wtID) = w2.test_twoClass_funcOut(wm_targetClassID,wtID).CF_testResults.accuracy;
         end
       end
       
   end
  
   % _______________________________________________________________
   %
   % multi-class classification using 2-class (target vs non-target)
   % _______________________________________________________________
   
   if func_in.func_out_include.DA.multiClass_test_DA == 1     % =1:func_out include that field, =0:that field does NOT included 
   if (c.tt.cf.p.use_multiClass_cf_onlyIf_numberOfClassesMoreThanTwo==1) && (size(c.classSetup.class.targetIDs_linkedTo_classID,1)==2)
    % ___________________________________________________________________________
    %
    % if number of classes = 2: multi-class DA = 2-class DA(target vs non-target)
    % ___________________________________________________________________________
    
     for wtID = 1 : size(w2.test_twoClass_funcOut,2)
       % Collecting: function output: 
        w1.DA.multiClass_test_DA(1,wtID) = w2.test_twoClass_funcOut(wm_targetClassID,wtID).CF_testResults.accuracy / 100;    % where: wm_targetClassID=1
     end
     
   else
    % ___________________________________________________________________________________________________________________
    %
    % if number of classes > 2: multi-class DA have to calculated from multiple 2-class DA (target vs non-target) results 
    % ___________________________________________________________________________________________________________________
    
    
    % resulted class from multiple 2-class (target vs non-target) classification test results 
    % _______________________________________________________________________________________ 
    
    for wtID = 1 : size(w2.test_twoClass_funcOut,2)
     for wm_trialID = 1 : size(allClass.trialClassLabels.test,2)
        wm1 = 1;
        wm2 = w2.test_twoClass_funcOut(wm1, wtID).CF_testResults.output(wm_trialID,1);
        for wm_targetClassID = w2.targetClassIDs_usedFor_2Class_tt
            if w2.test_twoClass_funcOut(wm_targetClassID, wtID).CF_testResults.output(wm_trialID,1) > wm2
              wm1 = wm_targetClassID;
              wm2 = w2.test_twoClass_funcOut(wm_targetClassID, wtID).CF_testResults.output(wm_trialID,1);
            end  
            w2.tt_multiClass_resultedClass(wtID, wm_trialID) = wm1;      % = resultedClassID
        end
     end
    end
    
    % correctly / non-correctly classified multiclass test results 
    % ____________________________________________________________ 
    
    for wtID = 1 : size(w2.test_twoClass_funcOut,2)
     for wm_trialID = 1 : size(allClass.trialClassLabels.test,2)
        % if w2.tt_multiClass_resultedClass(wtID, wm_trialID) == allClass.trialClassLabels.test(1,wm_trialID)
        %     w2.tt_multiClass_resultedClass_correct(wtID, wm_trialID) = 1;
        % else
        %     w2.tt_multiClass_resultedClass_correct(wtID, wm_trialID) = 0;
        % end
        w2.tt_multiClass_resultedClass_correct(wtID, wm_trialID) = ...
            w2.tt_multiClass_resultedClass(wtID, wm_trialID) == allClass.trialClassLabels.test(1,wm_trialID);
     end
    end
    
    % Calculating multiclass test accuracy
    % ____________________________________ 
    
    % Output:
    % Collecting: function output: 
    % w1.DA.multiClass_test_DA(1,wtID)  = [0..1] multiclass decoding accuracy 
    w1.DA.multiClass_test_DA(1,:) = mean(w2.tt_multiClass_resultedClass_correct,2); 
    
   end
   end
  
  end


%% subFunction

  % _______________________________
  % 
  % Function: Data Smoothing (1,wt)
  % _______________________________
  
  function wf_out_data =  subFunc_smoother_oneDim(wf_in_data, wf_in_smoothDistance)
    % Input:
    % wf_in_data(1,wt)
    % wf_in_smoothDistance      % =0:notUsed, >0(=1 or larger):smoothDistance
    % Output:
    % wf_out_data(1,wt)
    if wf_in_smoothDistance == 0
        wf_out_data = wf_in_data;
    else
        % Smoothing
        wf.m2 = wf_in_smoothDistance;
        wf.m = NaN(2*wf.m2 +1, size(wf_in_data,2) +(2*wf.m2) );
        for ws = - wf.m2 : wf.m2
            wf.m(ws + wf.m2 +1, ...
                wf.m2 + ws +1 : wf.m2 + ws + size(wf_in_data,2)) = ...
                    wf_in_data(1,:);
        end
        wf_out_data(1, 1:size(wf_in_data,2)) = ...
            nanmean( wf.m(:, wf.m2+1 : wf.m2+size(wf_in_data,2)),1 );
    end
  end

%% 

end



%% Comments

% datetime('now')

% csc_parsave([w.file.save.path,saveName], parfor_variablesToSave);

   
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
% !!!!!!!!!!!!!! HAVE TO REWRITE FROM HERE !!!!!!!!!!!!!!! 
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 

  % xxx_bestInnerParam_xxx{wm_subjID2,wm_sessionID2,wm_outerFoldID}.wm_CSP_filterPairNumber = xxx 
  % xxx_bestInnerParam_xxx{wm_subjID2,wm_sessionID2,wm_outerFoldID}.wm_MI_quant_level = xxx 
  % xxx_bestInnerParam_xxx{wm_subjID2,wm_sessionID2,wm_outerFoldID}.wm_outFeatureNumberPerClass = xxx 
  
  % xxx_twoClassAccuracy_withBestInnerParam_xxx{wm_subjID2,wm_sessionID2}{wm_classID,1}(wm_outerFoldID,wt) = xxx 
  % xxx_multiClassAccuracy_withBestInnerParam_xxx{wm_subjID2,wm_sessionID2}(wm_outerFoldID,wt) = xxx 


% figure; w.aInner(1,:)=w0.inner.DA.multiClass_test_DA_average(2,1,3,:); plot(w.aInner)
% figure; plot(w1.DA.multiClass_test_DA_average)
% figure; w.aMergedInner(1,:)=subFunc_smoother_oneDim(w1.DA.multiClass_test_DA_average(1,:), c.tt.smoothDistance.multiClass_innerFold_test_DA_average); plot(w.aMergedInner) 



% CHECK:
% - innerfold results: if 2-class only then not use multi-class code section 
% - continue code from pick accuracy selection during task period
% - use average accuracy only for inner fold parameter selection
% -
% - missing yet: tt once again using all data for training data in inner fold and x-fold inner test data (OR ALL INNER DATA) for find best wt in inner fold for probably ok in outer test 


% Saved variables maybe (!!! VARIABLES CHANGED, THIS IS NOT CORRECT YET !!!!):
% w0 (included):
%     w0.outer.trials.trialIDs (include): .all(1,trialID_ID), .train(1,trialID_ID), .test(1,trialID_ID) 
%     w0.outer.trials.trialID2s (include): .all(1,trialID2_ID), .train(1,trialID2_ID), .test(1,trialID2_ID) 
% 
%     w0.inner_merged.DA.multiClass_test_DA(wm_foldID, wtID)
%     w0.inner_merged.DA.multiClass_test_DA_average(1, wtID)
%     w0.inner_merged.DA.multiClass_test_DA_average_smooth(1, wtID)
%     w0.inner_merged.DA_best.multiClass_best_DA_average_firstWinEndAtTrig(wm_CSP_filterPairNumberID, wm_MI_quant_levelID, wm_outFeatureNumberPerClassID)
%     w0.inner_merged.DA_best.multiClass_best_DA_average_smooth_firstWinEndAtTrig(wm_CSP_filterPairNumberID, wm_MI_quant_levelID, wm_outFeatureNumberPerClassID)
%     w0.inner_merged.tt_param (included):
%         w0.inner_merged.tt_param(wm_targetClassID,wtID).CSP.CSPMatrix
%         w0.inner_merged.tt_param(wm_targetClassID,wtID).MI.featureIDs
%         w0.inner_merged.tt_param(wm_targetClassID,wtID).MI.weights
%         w0.inner_merged.tt_param(wm_targetClassID,wtID).CF.param
% 
%     w0.outer.DA.multiClass_test_DA(1, wtID)
%     w0.outer.DA.multiClass_test_DA_smooth(1, wtID)
%     w0.outer.DA_best.multiClass_best_DA_average_firstWinEndAtTrig(wm_CSP_filterPairNumberID, wm_MI_quant_levelID, wm_outFeatureNumberPerClassID)
%     w0.outer.DA_best.multiClass_best_DA_average_smooth_firstWinEndAtTrig(wm_CSP_filterPairNumberID, wm_MI_quant_levelID, wm_outFeatureNumberPerClassID)
%     w0.outer.tt_param (included):
%         w0.outer.tt_param(wm_targetClassID,wtID).CSP.CSPMatrix
%         w0.outer.tt_param(wm_targetClassID,wtID).MI.featureIDs
%         w0.outer.tt_param(wm_targetClassID,wtID).MI.weights
%         w0.outer.tt_param(wm_targetClassID,wtID).CF.param

%  !!!!!!!!!!!! BEST wt and wtID MISSING YET (MAYBE: selecting sub-interval with high averaged inner test DA of that interval which used for DA calc during task performance) for selecting w0.inner_merged.tt_param !!!!!!!!!!!!!!!!!!



% % !!!!!!!!!!!!!!
% if isnan(covTotal)
%     a=1;
% end
% if isinf(covTotal)
%     a=1;
% end








