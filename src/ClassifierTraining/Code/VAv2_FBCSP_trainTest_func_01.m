% FilterBankCSP Multi-class Classification, offline EEG trainTest

% Input structures

% Output structures

% REQUIRESTMENT: Matlab
% Copyright(c)2020 Attila Korik, http://isrc.ulster.ac.uk/akorik/contact.html


%% INFO

% p = param
% tt = trainTest
% cf = classifier


function VAv2_FBCSP_trainTest_func_01(FUNC_IN, perm_ID)

w = FUNC_IN.w;
SW = FUNC_IN.SW;
autorun = FUNC_IN.autorun;
c = FUNC_IN.c;

clearvars FUNC_IN


%% Code 1. Data Loading

% clear; close all;

% _________________
%
% Parfor Core Setup
% _________________

% % % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% % % !!!!!!!!!!!!! MOVED to taskManager !!!!!!!!!!!!!
% % % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


% _______________
%
% Loading Dataset
% _______________

if autorun.tt.file.load.autoload == 1
    if SW.print_trainTest_details == 1 
      fprintf('\n');
    end
    
    % offlineClass_classSetup: autorun
    % fprintf('Loading Shape5B_SC10_offlineClass_classSetup_01 [autorun].mat ...\n');
    w.file.load.name = [autorun.tt.file.load.nameBasis1.offlineClass_classSetup, ' [autorun].mat'];
    if SW.print_trainTest_details == 1 
      fprintf(['Loading ',w.file.load.name,' ...\n']);
    end
    load([autorun.tt.file.load.path.offlineClass_classSetup,w.file.load.name]);
    autorun.classSetup = copy_of_autorun.classSetup;
    if isfield(copy_of_autorun.prep,'prep')
        autorun.prep = copy_of_autorun.prep.prep;	% !!!!!!!!!! from mistake was saved as: "copy_of_autorun.prep.prep" instead of "copy_of_autorun.prep" !!!!!!!!!! 
    else
        autorun.prep = copy_of_autorun.prep; 
    end
    clear copy_of_autorun
    
    if SW.loadFrom_classSetup_file.autorun_tt_used_subjects == 1
        autorun.tt.used.subjects = autorun.classSetup.used.subjects;
        autorun.tt.used.sessions = autorun.classSetup.used.sessions;
    end

    % offlineClass_classSetup: EEG Config
    w.file.load.name = [autorun.tt.file.load.nameBasis1.offlineClass_classSetup, ' [config].mat'];
    TMP = load([autorun.tt.file.load.path.offlineClass_classSetup,w.file.load.name]);
    c.classSetup = TMP.copy_of_c.classSetup;
    c.prep = TMP.copy_of_c.prep;
    clear TMP
    
    % EEG validation
    w.file.load.name = [autorun.tt.file.load.nameBasis1.EEG_validation, ' [EEG_validation].mat'];
    if SW.print_trainTest_details == 1 
      fprintf(['Loading',w.file.load.name,' ...\n']);
    end
    load([autorun.tt.file.load.path.EEG_validation,w.file.load.name]);
    if c.tt.session.use_allSessionsTogether == 0    % =1: combine classTrial datasets together from all sessions, =0:handle separately 
      EEG_validation = copy_of_EEG_validation;
      clear copy_of_EEG_validation
    else
      for wm_subjID2 = autorun.tt.used.subjects
        wm_sessionID2 = 1;
        EEG_validation{wm_subjID2,wm_sessionID2}.ch.invalid_ID = [];
        for wm_sessionID_X = autorun.tt.used.sessions
          if ~isempty(copy_of_EEG_validation{wm_subjID2,wm_sessionID_X}.ch.invalid_ID)
            EEG_validation{wm_subjID2,1}.ch.invalid_ID = sort([EEG_validation{wm_subjID2,1}.ch.invalid_ID, ...
              copy_of_EEG_validation{wm_subjID2,wm_sessionID_X}.ch.invalid_ID(1,~ismember(copy_of_EEG_validation{wm_subjID2,wm_sessionID_X}.ch.invalid_ID, EEG_validation{wm_subjID2,1}.ch.invalid_ID))]);
          end
        end
        wm = 1:size(copy_of_EEG_validation{wm_subjID2,wm_sessionID_X}.ch.valid_mask,2);
        EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID = wm(1,~ismember(wm,EEG_validation{wm_subjID2,1}.ch.invalid_ID));
        EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_mask = ones(1, size(copy_of_EEG_validation{wm_subjID2,wm_sessionID_X}.ch.valid_mask,2));
        EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_mask(1,EEG_validation{wm_subjID2,1}.ch.invalid_ID) = 0;
        for wm = 1:size(copy_of_EEG_validation{wm_subjID2,wm_sessionID_X}.ch.valid_mask,2)
          if find(copy_of_EEG_validation{wm_subjID2,wm_sessionID_X}.ch.valid_ID==wm)
            c_EEG_rec_ch_name{wm,1} = copy_of_EEG_validation{wm_subjID2,wm_sessionID_X}.ch.valid_name{1,find(copy_of_EEG_validation{wm_subjID2,wm_sessionID_X}.ch.valid_ID==wm)};
          else
            c_EEG_rec_ch_name{wm,1} = copy_of_EEG_validation{wm_subjID2,wm_sessionID_X}.ch.invalid_name{1,find(copy_of_EEG_validation{wm_subjID2,wm_sessionID_X}.ch.invalid_ID==wm)};
          end
        end
        
        
        if ~isempty(EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID)
          for wk2ID = 1 : size(EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID,2)
            EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_name{1,wk2ID} = c_EEG_rec_ch_name{EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID(wk2ID),1};
          end
        end
        if ~isempty(EEG_validation{wm_subjID2,wm_sessionID2}.ch.invalid_ID)
          for wk2ID = 1 : size(EEG_validation{wm_subjID2,wm_sessionID2}.ch.invalid_ID,2)
            EEG_validation{wm_subjID2,wm_sessionID2}.ch.invalid_name{1,wk2ID} = c_EEG_rec_ch_name{EEG_validation{wm_subjID2,wm_sessionID2}.ch.invalid_ID(wk2ID),1};
          end
        end
        clearvars wk2ID
        clearvars c_EEG_rec_ch_name
      end
      clear copy_of_EEG_validation
    end
    
    if SW.print_trainTest_details == 1 
      fprintf('Dataset loading: DONE\n');
      fprintf('\n');
    end
end

% ________________________________________
% 
% Actions based on config and loaded files
% ________________________________________

if isfield(c.prep.EEG,'feature')        % in older prep code "c.prep.EEG.feature.sr" not prepared but same content stored in "c.prep.EEG.downsamp.sr" 
    c.tt.sr = c.prep.EEG.feature.sr;
else
    c.tt.sr = c.prep.EEG.downsamp.sr;
end
c.tt.cf.p.winSize.samp = round((c.tt.cf.p.winSize.ms/1000)*c.tt.sr);    % classifier window size in samples (e.g., (2000[ms]/1000[ms/s])*120[samp/s] = 240)
c.tt.cf.p.winStep.samp = round((c.tt.cf.p.winStep.ms/1000)*c.tt.sr);    % classification steps in samples (e.g., (200[ms]/1000[ms/s])*120[samp/s] = 24)

if SW.loadFrom_classSetup_file.c_tt_usedBandIDs == 0
    c.tt.usedBandIDs = c.classSetup.usedBandIDs;        % from preprocessed EEG data with these bandIDs will be used for trainTest
end

% __________________________
% 
% Parfor Core Initialization
% __________________________

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

% _________
% 
% AUTO SAVE
% _________

% c = TRANS.c;                % save this
% autorun = TRANS.autorun;    % save this
if autorun.tt.file.save.autosave == 1
    if SW.print_trainTest_details == 1 
      fprintf('Saving config structure ...\n');
    end
    copy_of_c = c;
    w.file.save.name = [autorun.tt.file.save.nameBasis.offlineClass_trainTest, ' [config].mat'];
    save([autorun.tt.file.save.path.offlineClass_trainTest,w.file.save.name],'copy_of_c','-v7.3');
    clear copy_of_c
    
    if SW.print_trainTest_details == 1 
      fprintf('Saving autorun structure ...\n');
    end
    copy_of_autorun = autorun;
    w.file.save.name = [autorun.tt.file.save.nameBasis.offlineClass_trainTest, ' [autorun].mat'];
    save([autorun.tt.file.save.path.offlineClass_trainTest,w.file.save.name],'copy_of_autorun','-v7.3');
    clear copy_of_autorun
    
    if SW.print_trainTest_details == 1 
      fprintf('Saving EEG_validation structure ...\n');
    end
    copy_of_EEG_validation = EEG_validation;
    w.file.save.name = [autorun.tt.file.save.nameBasis.offlineClass_trainTest, ' [EEG_validation].mat'];
    save([autorun.tt.file.save.path.offlineClass_trainTest,w.file.save.name],'copy_of_EEG_validation','-v7.3');
    clear copy_of_EEG_validation
end


%% Autorun

% _______
% 
% Autorun
% _______

TRANS.SW = SW;
TRANS.c = c;
TRANS.autorun = autorun;
TRANS.EEG_validation = EEG_validation;
clearvars c autorun EEG_validation;

tic

% ______________________________________________________________________
% 
% Preparation for Combine classTrial datasets together from all sessions
% ______________________________________________________________________

if TRANS.c.tt.session.use_allSessionsTogether == 1    % =1: combine classTrial datasets together from all sessions, =0:handle separately 
    w.autorun_sessionGroups = 1;
else
    w.autorun_sessionGroups = TRANS.autorun.tt.used.sessions;
end


if TRANS.autorun.tt.parCore.parforUsed == 0
    
  % ___________________
  % 
  % autorun (for cycle)
  % ___________________
  w0 = cell(size(TRANS.autorun.tt.used.subjects,2),size(w.autorun_sessionGroups,2),TRANS.c.tt.folds.outerFoldNumber);
  for autorun_subjID2 = TRANS.autorun.tt.used.subjects
   for autorun_sessionID2 = w.autorun_sessionGroups
    for autorun_outerFoldID = 1 : TRANS.c.tt.folds.outerFoldNumber
%{
% TEST: 
autorun_subjID2 = size(TRANS.autorun.tt.used.subjects,2);
autorun_sessionID2 = size(w.autorun_sessionGroups,2);
autorun_outerFoldID = TRANS.c.tt.folds.outerFoldNumber;
%}
      
      w0{autorun_subjID2,autorun_sessionID2,autorun_outerFoldID} = VAv2_FBCSP_trainTest_coreFunct_01(TRANS, autorun_subjID2, autorun_sessionID2, autorun_outerFoldID, perm_ID);
      
    end
   end
  end
  
else
  
  % ________________
  % 
  % parfor converter
  % ________________
  wm = 0;
  clearvars par_convBack
  for autorun_subjID2 = TRANS.autorun.tt.used.subjects
   for autorun_sessionID2 = w.autorun_sessionGroups
    for autorun_outerFoldID = 1 : TRANS.c.tt.folds.outerFoldNumber
      wm = wm +1;
      wm1 = autorun_subjID2;
      wm2 = autorun_sessionID2;
      wm3 = autorun_outerFoldID;

      % par_v(wm,1) = a3(wm1, wm2, wm3);      % original indexed variable -> convert to parfor indexed variable 
      % par_conv{wm1, wm2, wm3} = wm;         % dimX index - > parfor 1D index 

      par_convBack{wm,1} = [wm1, wm2, wm3];     % parfor 1D index - > dimX index 
    end
   end
  end
  % ______________________
  % 
  % autorun (parfor cycle)
  % ______________________
  % parfor par_ID = 1 : ( size(TRANS.autorun.tt.used.subjects,2) * size(w.autorun_sessionGroups,2) * TRANS.c.tt.folds.outerFoldNumber)
  par_w0 = cell(size(par_convBack,1),1);
  % for par_ID = 1 : size(par_convBack,1)
  if w.parCore.parforUsed == 0
   for par_ID = 1 : size(par_convBack,1)
  
    % wm = par_convBack{par_ID,1};    % p_id=[index1, ... indexN] : dimX indices from wm_par index 
    % autorun_subjID2 = wm(1,1);
    % autorun_sessionID2 = wm(1,2);
    % autorun_outerFoldID = wm(1,3);
    % VAv2_FBCSP_trainTest_coreFunct_01(TRANS, autorun_subjID2, autorun_sessionID2, autorun_outerFoldID, perm_ID)
    
    autorun_subjID2 = par_convBack{par_ID,1}(1,1);
    autorun_sessionID2 = par_convBack{par_ID,1}(1,2);
    autorun_outerFoldID = par_convBack{par_ID,1}(1,3);
    par_w0{par_ID,1} = VAv2_FBCSP_trainTest_coreFunct_01(TRANS, autorun_subjID2, autorun_sessionID2, autorun_outerFoldID, perm_ID);
    
    % VAv2_FBCSP_trainTest_coreFunct_01(TRANS, par_convBack{par_ID,1}(1,1), par_convBack{par_ID,1}(1,2), par_convBack{par_ID,1}(1,3), perm_ID)
   end
  else
   parfor par_ID = 1 : size(par_convBack,1)
  
    % wm = par_convBack{par_ID,1};    % p_id=[index1, ... indexN] : dimX indices from wm_par index 
    % autorun_subjID2 = wm(1,1);
    % autorun_sessionID2 = wm(1,2);
    % autorun_outerFoldID = wm(1,3);
    % VAv2_FBCSP_trainTest_coreFunct_01(TRANS, autorun_subjID2, autorun_sessionID2, autorun_outerFoldID, perm_ID)
    
    autorun_subjID2 = par_convBack{par_ID,1}(1,1);
    autorun_sessionID2 = par_convBack{par_ID,1}(1,2);
    autorun_outerFoldID = par_convBack{par_ID,1}(1,3);
    par_w0{par_ID,1} = VAv2_FBCSP_trainTest_coreFunct_01(TRANS, autorun_subjID2, autorun_sessionID2, autorun_outerFoldID, perm_ID);
    
    % VAv2_FBCSP_trainTest_coreFunct_01(TRANS, par_convBack{par_ID,1}(1,1), par_convBack{par_ID,1}(1,2), par_convBack{par_ID,1}(1,3), perm_ID)
   end
  end
  
  w0 = cell(par_convBack{size(par_convBack,1),1});
  for par_ID = 1 : size(par_convBack,1)
    autorun_subjID2 = par_convBack{par_ID,1}(1,1);
    autorun_sessionID2 = par_convBack{par_ID,1}(1,2);
    autorun_outerFoldID = par_convBack{par_ID,1}(1,3);
    w0{autorun_subjID2,autorun_sessionID2,autorun_outerFoldID} = par_w0{par_ID,1};
  end
  
end


% _________________________
% 
% w0 structure modification
% _________________________

for autorun_subjID2 = TRANS.autorun.tt.used.subjects
 for autorun_sessionID2 = w.autorun_sessionGroups
  for autorun_outerFoldID = 1 : TRANS.c.tt.folds.outerFoldNumber
% for autorun_subjID2 = 10
%  for autorun_sessionID2 = w.autorun_sessionGroups
%   for autorun_outerFoldID = [2,6]

      % _____
      % 
      % trialIDs
      % _____
      
      w0_matrix.outer.trials.trialIDs.all(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID,:) = ...
          w0{autorun_subjID2,autorun_sessionID2,autorun_outerFoldID}.outer.trials.trialIDs.all(1,:);            % (1,trialID_ID)
      w0_matrix.outer.trials.trialIDs.train(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID,:) = ...
          w0{autorun_subjID2,autorun_sessionID2,autorun_outerFoldID}.outer.trials.trialIDs.train(1,:);          % (1,trialID_ID)
      w0_matrix.outer.trials.trialIDs.test(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID,:) = ...
          w0{autorun_subjID2,autorun_sessionID2,autorun_outerFoldID}.outer.trials.trialIDs.test(1,:);           % (1,trialID_ID)
      
      w0_matrix.outer.trials.trialID2s.all(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID,:) = ...
          w0{autorun_subjID2,autorun_sessionID2,autorun_outerFoldID}.outer.trials.trialID2s.all(1,:);           % (1,trialID2_ID)
      w0_matrix.outer.trials.trialID2s.train(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID,:) = ...
          w0{autorun_subjID2,autorun_sessionID2,autorun_outerFoldID}.outer.trials.trialID2s.train(1,:);         % (1,trialID2_ID)
      w0_matrix.outer.trials.trialID2s.test(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID,:) = ...
          w0{autorun_subjID2,autorun_sessionID2,autorun_outerFoldID}.outer.trials.trialID2s.test(1,:);          % (1,trialID2_ID)
      
      % _____
      % 
      % outer
      % _____
      
      w0_matrix.outer.DA.multiClass_test_DA(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID,:) = ...
          w0{autorun_subjID2,autorun_sessionID2,autorun_outerFoldID}.outer.DA.multiClass_test_DA(1,:); % (1,wtID)
      w0_matrix.outer.DA.multiClass_test_DA_smooth(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID,:) = ...
          w0{autorun_subjID2,autorun_sessionID2,autorun_outerFoldID}.outer.DA.multiClass_test_DA_smooth(1,:); % (1,wtID)
      
      w0_matrix.outer.DA_best.multiClass_best_DA_average_firstWinEndAtTrig(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID) = ...
          w0{autorun_subjID2,autorun_sessionID2,autorun_outerFoldID}.outer.DA_best.multiClass_best_DA_average_firstWinEndAtTrig;
      w0_matrix.outer.DA_best.multiClass_best_DA_average_smooth_firstWinEndAtTrig(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID) = ...
          w0{autorun_subjID2,autorun_sessionID2,autorun_outerFoldID}.outer.DA_best.multiClass_best_DA_average_smooth_firstWinEndAtTrig;
      
      % Description:
      % w0_matrix.outer.tt_param(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID) -> included:
      %     w0_matrix.outer.tt_param(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID,wm_targetClassID,wtID).CSP.CSPMatrix
      %     w0_matrix.outer.tt_param(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID,wm_targetClassID,wtID).MI.featureIDs
      %     w0_matrix.outer.tt_param(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID,wm_targetClassID,wtID).MI.weights
      %     w0_matrix.outer.tt_param(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID,wm_targetClassID,wtID).LDA.ldaParams
      w0_matrix.outer.tt_param(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID,:,:) = ...
          w0{autorun_subjID2,autorun_sessionID2,autorun_outerFoldID}.outer.tt_param; % where:
      %   w0{autorun_subjID2,autorun_sessionID2,autorun_outerFoldID}.outer.tt_param (included):
      %       w0.outer.tt_param(wm_targetClassID,wtID).CSP.CSPMatrix
      %       w0.outer.tt_param(wm_targetClassID,wtID).MI.featureIDs
      %       w0.outer.tt_param(wm_targetClassID,wtID).MI.weights
      %       w0.outer.tt_param(wm_targetClassID,wtID).LDA.ldaParams
      
      % ____________
      % 
      % outer merged
      % ____________
      
      if autorun_outerFoldID == 1  	% outer merged trainTest have to do only once (as same for all outer folds)
          
      w0_matrix.outer_merged.DA.multiClass_test_DA(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID,:,:) = ...
          w0{autorun_subjID2,autorun_sessionID2,autorun_outerFoldID}.outer_merged.DA.multiClass_test_DA(:,:); % (wm_foldID,wtID)
      w0_matrix.outer_merged.DA.multiClass_test_DA_average(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID,:) = ...
          w0{autorun_subjID2,autorun_sessionID2,autorun_outerFoldID}.outer_merged.DA.multiClass_test_DA_average(1,:); % (1,wtID)
      w0_matrix.outer_merged.DA.multiClass_test_DA_average_smooth(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID,:) = ...
          w0{autorun_subjID2,autorun_sessionID2,autorun_outerFoldID}.outer_merged.DA.multiClass_test_DA_average_smooth(1,:); % (1,wtID)
      
      w0_matrix.outer_merged.DA_best.multiClass_best_DA_average_firstWinEndAtTrig(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID) = ...
          w0{autorun_subjID2,autorun_sessionID2,autorun_outerFoldID}.outer_merged.DA_best.multiClass_best_DA_average_firstWinEndAtTrig;
      w0_matrix.outer_merged.DA_best.multiClass_best_DA_average_smooth_firstWinEndAtTrig(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID) = ...
          w0{autorun_subjID2,autorun_sessionID2,autorun_outerFoldID}.outer_merged.DA_best.multiClass_best_DA_average_smooth_firstWinEndAtTrig;
      
      % Description:
      % w0_matrix.outer_merged.tt_param(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID) -> included:
      %     w0_matrix.outer_merged.tt_param(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID,wm_targetClassID,wtIDID).CSP.CSPMatrix
      %     w0_matrix.outer_merged.tt_param(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID,wm_targetClassID,wtIDID).MI.featureIDs
      %     w0_matrix.outer_merged.tt_param(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID,wm_targetClassID,wtIDID).MI.weights
      %     w0_matrix.outer_merged.tt_param(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID,wm_targetClassID,wtIDID).LDA.ldaParams
      w0_matrix.outer_merged.tt_param(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID,:,:) = ...
          w0{autorun_subjID2,autorun_sessionID2,autorun_outerFoldID}.outer_merged.tt_param; % where:
      %   w0{autorun_subjID2,autorun_sessionID2,autorun_outerFoldID}.outer_merged.tt_param (included):
      %       w0.outer_merged.tt_param(wm_targetClassID,wtIDID).CSP.CSPMatrix
      %       w0.outer_merged.tt_param(wm_targetClassID,wtIDID).MI.featureIDs
      %       w0.outer_merged.tt_param(wm_targetClassID,wtIDID).MI.weights
      %       w0.outer_merged.tt_param(wm_targetClassID,wtIDID).LDA.ldaParams
      
      end
      
  end
 end
end

  % ________________________________________________
  % 
  % Averaged outer fold classification test accuracy
  % ________________________________________________
   
  % Input:
  % w0_matrix.outer.DA.multiClass_test_DA(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID,wtID)
  % Output:
  % w0_matrix.outer.DA.multiClass_test_DA_average(autorun_subjID2,autorun_sessionID2,wtID)
  
  for autorun_subjID2 = TRANS.autorun.tt.used.subjects
   for autorun_sessionID2 = w.autorun_sessionGroups
    % for autorun_outerFoldID = 1 : TRANS.c.tt.folds.outerFoldNumber

        clearvars wm
        wm(:,:) = w0_matrix.outer.DA.multiClass_test_DA(autorun_subjID2,autorun_sessionID2,:,:);
% wm(:,:) = w0_matrix.outer.DA.multiClass_test_DA(autorun_subjID2,autorun_sessionID2,[2,6],:);
        w0_matrix.outer.DA.multiClass_test_DA_average(autorun_subjID2,autorun_sessionID2,:) = mean(wm,1);
  
    % end
   end
  end
  
  % ___________________________________________________
  % 
  % Smoothing if option for: multiClass_test_DA_average
  % ___________________________________________________
  
  % Input:
  % w0_matrix.outer.DA.multiClass_test_DA_average(autorun_subjID2,autorun_sessionID2,wtID)
  % c.tt.smoothDistance.multiClass_outerFold_test_DA_average            % =0:notUsed, >0(=1 or larger):smoothDistance
  % Output:
  % w0_matrix.outer.DA.multiClass_test_DA_average_smooth(autorun_subjID2,autorun_sessionID2,wtID)   % smoothed index wtID: (autorun_subjID2,autorun_sessionID2,:) 
  
  for autorun_subjID2 = TRANS.autorun.tt.used.subjects
   for autorun_sessionID2 = w.autorun_sessionGroups
    % for autorun_outerFoldID = 1 : TRANS.c.tt.folds.outerFoldNumber
        
        % w0_matrix.outer.DA.multiClass_test_DA_average_smooth(autorun_subjID2,autorun_sessionID2,:) = ...
        %     subFunc_smoother_oneDim(w0_matrix.outer.DA.multiClass_test_DA_average(autorun_subjID2,autorun_sessionID2,:), TRANS.c.tt.smoothDistance.multiClass_outerFold_test_DA_average);
        clearvars wm
        wm(1,:) = w0_matrix.outer.DA.multiClass_test_DA_average(autorun_subjID2,autorun_sessionID2,:);
        w0_matrix.outer.DA.multiClass_test_DA_average_smooth(autorun_subjID2,autorun_sessionID2,:) = ...
            subFunc_smoother_oneDim(wm(1,:), TRANS.c.tt.smoothDistance.multiClass_outerFold_test_DA_average);
  
    % end
   end
  end
  

% _________
% 
% AUTO SAVE
% _________

% autorun = TRANS.autorun;    % save this
if TRANS.autorun.tt.file.save.autosave == 1
    if SW.print_trainTest_details
      fprintf('Saving config structure ...\n');
    end
    copy_of_w0_matrix = w0_matrix;
    w.file.save.name = [TRANS.autorun.tt.file.save.nameBasis.offlineClass_trainTest, ' [w0_matrix].mat'];
    save([TRANS.autorun.tt.file.save.path.offlineClass_trainTest,w.file.save.name],'copy_of_w0_matrix','-v7.3');
    clear copy_of_w0_matrix
end

% _____________
% 
% Parfor: close
% _____________

if w.parCore.parforUsed == 1
  if TRANS.autorun.tt.parCore.closeAtEnd == 1
    delete(gcp('nocreate'))     % parpool close
  end
end

% _____________
% 
% Code Finished
% _____________

if SW.print_trainTest_details
  fprintf('\n');
  fprintf('Running: Finished\n\n');

  toc
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


%% Comments






end

