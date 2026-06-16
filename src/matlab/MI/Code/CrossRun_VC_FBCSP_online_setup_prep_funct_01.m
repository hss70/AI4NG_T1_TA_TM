% Function for Online Setup Preparation using Offline Results from FilterBankCSP Multi-class Classification

% Input structures

% FUNC_IN.w0_matrix.outer.tt_param   OR   FUNC_IN.w0_matrix.outer_merged.tt_param
% c ....

% Output structures

% REQUIRESTMENT: Matlab
% Copyright(c)2018 Attila Korik, http://isrc.ulster.ac.uk/akorik/contact.html


%% Code

function online = CrossRun_VC_FBCSP_online_setup_prep_funct_01(FUNC_IN)
  
  % SW.CFx = 1;   % =1:Classification use 1 CF lane (target vs others),  =2:Classification use difference of 2 CF lanes (target vs others - others vs target) 
  SW.CFx = FUNC_IN.VA.c.SW.CFx;   % =1:Classification use 1 CF lane (target vs others),  =2:Classification use difference of 2 CF lanes (target vs others - others vs target) 
  
  VA = FUNC_IN.VA;
  c = FUNC_IN.c;
  c_CP = FUNC_IN.c_CP;
  EEG_validation = FUNC_IN.EEG_validation;
  wm_subjID2 = FUNC_IN.wm_subjID2;          % !!! this function handle only for one subject !!!
  wm_sessionID2 = FUNC_IN.wm_sessionID2;    % !!! this function handle only for one session !!!
  c_outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0 = FUNC_IN.c_outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0;
% %   w0_matrix.outer_OR_outer_merged = FUNC_IN.w0_matrix.outer_OR_outer_merged;
% % % %   w0_matrix(1).outer_OR_outer_merged = FUNC_IN.w0_matrix(1).outer_OR_outer_merged;
% % % %   w0_matrix(2).outer_OR_outer_merged = FUNC_IN.w0_matrix(2).outer_OR_outer_merged;
% % % %   w0_matrix(3).outer_OR_outer_merged = FUNC_IN.w0_matrix(3).outer_OR_outer_merged;
% % % %   if VA.f.SW.task_vs_relax_CP_used
% % % %       w0_matrix(4).outer_OR_outer_merged = FUNC_IN.w0_matrix(4).outer_OR_outer_merged;
% % % %   end
  for wm_subDirID = 1 : size(FUNC_IN.w0_matrix,2)
      w0_matrix(wm_subDirID).outer_OR_outer_merged = FUNC_IN.w0_matrix(wm_subDirID).outer_OR_outer_merged;
  end
  autorun_outerFoldID = FUNC_IN.autorun_outerFoldID;
  c_wt_taskOnset_cfWinOffset_ms = FUNC_IN.c_wt_taskOnset_cfWinOffset_ms;
  wtID = FUNC_IN.wtID;
  
  clearvars FUNC_IN
  

% % % % % ___________
% % % % %
% % % % % Basis setup
% % % % % ___________
% % % % 
% % % % if ~isnan(str2double('1;2;3'))
% % % %     w.str2double = 1;
% % % % else
% % % %     w.str2double = 0;
% % % % end
% % % % 
% % % % % % c.online.subjectID = size(autorun.tt.used.subjects,2);
% % % % % % c.online.subject = autorun.tt.used.subjects(1,c.online.subjectID);
% % % % % % c.online.sessionID = size(autorun.tt.used.sessions,2);
% % % % % % c.online.session = autorun.tt.used.sessions(1,c.online.sessionID);
% % % % 
% % % % % % c.online.subjectID = 1 : size(autorun.tt.used.subjects,2);
% % % % c.online.subject(1,:) = autorun.tt.used.subjects(1,:);
% % % % % % c.online.sessionID = 1 : size(autorun.tt.used.sessions,2);
% % % % c.online.session(1,:) = autorun.tt.used.sessions(1,:);
% % % % c.online.outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0 = 0;
% % % % c.online.wt_taskOnset_cfWinOffset_ms = 1200;
% % % % 
% % % %     % Dialog
% % % %     
% % % %     numLines=1;
% % % %     cellNames = {'Subjects (used for online setup):' ...
% % % %                  'Session (used for online setup):' ...
% % % %                  'Selected BCI setup (type outerFoldID OR 999:lastOuterFold OR 0:allMergedOuterFolds:' ...
% % % %                  'Time between task onset and classification window offset [ms]:' };
% % % %     default = { num2str(c.online.subject), ...
% % % %                 num2str(c.online.session), ...
% % % %                 num2str(c.online.outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0), ...
% % % %                 num2str(c.online.wt_taskOnset_cfWinOffset_ms) };
% % % %     w.m = inputdlg(cellNames,'Setup', numLines, default);
% % % %     if w.str2double == 1
% % % %       if ~isempty(w.m)         % Ha nem Cancel
% % % %         c.online.subject = str2double(cell2mat(w.m(1)));
% % % %         c.online.session = str2double(cell2mat(w.m(2)));
% % % %         c.online.outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0 = str2double(cell2mat(w.m(3)));
% % % %         c.online.wt_taskOnset_cfWinOffset_ms = str2double(cell2mat(w.m(4)));
% % % %       end
% % % %     else
% % % %       if ~isempty(w.m)         % Ha nem Cancel
% % % %         c.online.subject = str2num(cell2mat(w.m(1)));
% % % %         c.online.session = str2num(cell2mat(w.m(2)));
% % % %         c.online.outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0 = str2num(cell2mat(w.m(3)));
% % % %         c.online.wt_taskOnset_cfWinOffset_ms = str2num(cell2mat(w.m(4)));
% % % %       end
% % % %     end
% % % % 
% % % % 
% % % % % __________________________
% % % % % 
% % % % % Setup using previous setup
% % % % % __________________________
% % % % 
% % % % % c.prep.trial.trig_PRE_ms
% % % % % c.prep.trial.trig_PST_ms
% % % % % c.prep.EEG.downsamp.sr
% % % % % c.tt.cf.p.winSize.samp
% % % % % c.tt.cf.p.winSize.ms
% % % % % c.tt.cf.p.winStep.samp
% % % % % c.tt.cf.p.winStep.ms
% % % % % % c_wt_taskOnset_cfWinOffset_ms = c.online.wt_taskOnset_cfWinOffset_ms; 
% % % % % % w.wt0ID = ((-c.prep.trial.trig_PRE_ms-c.tt.cf.p.winSize.ms)/c.tt.cf.p.winStep.ms) +1;
% % % % % % w.wtID_used = w.wt0ID + fix(c_wt_taskOnset_cfWinOffset_ms/c.tt.cf.p.winStep.ms);


%% Code 2. Online setup preparation


% online.

% % % % wm_subjID2 = c.online.subject;
% % % % wm_sessionID2 = c.online.session;
% % % % % for autorun_outerFoldID = 1 : size(w0_matrix.outer.tt_param,3);
% % % % if c.online.outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0 == 0
% % % %     autorun_outerFoldID = 1;
% % % % elseif c.online.outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0 == 999
% % % %     autorun_outerFoldID = size(w0_matrix.outer.tt_param,3);
% % % % else
% % % %     autorun_outerFoldID = c.online.outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0;
% % % % end
% % % % 
% % % % if c.online.outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0 ~= 0
% % % %     w0_matrix.outer_OR_outer_merged = w0_matrix.outer;
% % % % else
% % % %     w0_matrix.outer_OR_outer_merged = w0_matrix.outer_merged;
% % % % end

% % % % % wm_targetClassID = 
% % % % wtID = w.wtID_used;

% _________________
% 
% Online setup info
% _________________

online.info.subject = wm_subjID2;
online.info.session = wm_sessionID2;
online.info.outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0 = c_outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0;
online.info.wt_taskOnset_cfWinOffset_ms = c_wt_taskOnset_cfWinOffset_ms;
online.info.CFx = SW.CFx;



% _________________
% 
% Online setup prep
% _________________

% w0_matrix.outer_OR_outer_merged.tt_param(wm_subjID2,wm_sessionID2,autorun_outerFoldID,wm_targetClassID,wtID).CSP
% w0_matrix.outer_OR_outer_merged.tt_param(wm_subjID2,wm_sessionID2,autorun_outerFoldID,wm_targetClassID,wtID).MI
% w0_matrix.outer_OR_outer_merged.tt_param(wm_subjID2,wm_sessionID2,autorun_outerFoldID,wm_targetClassID,wtID).CF

% EEG record
% __________

online.p.EEG.rec.sr = c.prep.EEG.rec.sr;

% Refference filter
% _________________

online.p.EEG.refFilt.used_non0_CAR1_Laplace2 = c.prep.EEG.filt.refFilt.usedMethod.non0_CAR1_Laplace2;

% EEG channel validation
% ______________________

% % online.p.EEG.rec.validChNumber = size(EEG_validation{wm_subjID2(1,1), wm_sessionID2(1,1)}.ch.valid_ID,2);
% % online.p.EEG.rec.validChIDs(1,:) = EEG_validation{wm_subjID2(1,1), wm_sessionID2(1,1)}.ch.valid_ID(1,:);
online.p.EEG.rec.validChNumber = size(EEG_validation{wm_subjID2(1,1), wm_sessionID2(1,1)}.ch.valid_ID,2);
online.p.EEG.rec.validChIDs(1,:) = EEG_validation{wm_subjID2(1,1), wm_sessionID2(1,1)}.ch.valid_ID(1,:);

% Bandpass / Bandpower calculation
% ________________________________

% Bandpass / babndpower selection:
% _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

online.p.EEG.used_bandpass1_bandpower2 = c.prep.EEG.filt.bandFilt.usedFeature_bandpass1_bandpower2;

% Bandpass filter (for bandpass or bandpower features):
% _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 

% % online.p.EEG.rec.sr = c.prep.EEG.rec.sr;
% online.p.EEG.bandPass.band(1,wm_bandID).low1
% online.p.EEG.bandPass.band(1,wm_bandID).low2
% online.p.EEG.bandPass.band(1,wm_bandID).high1
% online.p.EEG.bandPass.band(1,wm_bandID).high2
% online.p.EEG.bandPass.band_stop_dB
% online.p.EEG.bandPass.band_pass_dB 
% online.p.EEG.bandPass.wSize
online.p.EEG.bandPass = c.prep.EEG.filt.bandPass;

% Bandpower setup (need for bandpass modul also if there is a switch for bandpower option):
% _ _ _ _ _ _ _ _ _ 

% if online.p.EEG.used_bandpass1_bandpower2 == 2
    online.p.EEG.bandPower.wSize = 1;   % this set only as the variable included in the general simulkink modul for bandpower option (THAT IS NOT USED if online.p.EEG.used_bandpass1_bandpower2==1 
% end

% Downsampling
% ____________

online.p.EEG.downsamp.sr = c.prep.EEG.downsamp.sr;


% CSP
% ___

% In:
% % % % % c.tt.cf.p_options.CSP.selectedFilterPairNumber(1,wm_CSP_filterPairNumberID)
% % % % % w0_matrix.outer_OR_outer_merged.tt_param(wm_subjID2,wm_sessionID2,autorun_outerFoldID,wm_targetClassID,wtID).CSP.CSPMatrix{wm_bandID,1}(wm_CSP_filterID,wp)
% c_CP(wm_ClassPairID).tt.cf.p_options.CSP.selectedFilterPairNumber
% w0_matrix.outer_OR_outer_merged.tt_param(wm_subjID2,wm_sessionID2,autorun_outerFoldID,wm_targetClassID,wtID).CSP.CSPMatrix{wm_bandID,1}(wm_CSP_filterID,wp)
% 
% Out:
% online.p.CSP.
% SW.CFx=1 -> online.p.CSP.filters_used{wm_targetClassID, wm_bandID}(wp,wm_CSP_filterID2)
% SW.CFx=2 -> online.p.CSP.filters_used{wm_ClassPairID, wm_targetClassID, wm_bandID}(wp,wm_CSP_filterID2)

if SW.CFx == 1
  for wm_ClassPairID = 1 : size(w0_matrix,2)
   for wm_bandID = c.classSetup.band.usedIDs
	% wm1: number of used CSP filter pairs, wm2: the ctual CSP matrix -> online.p.CSP.filters_used(:,2xfilterPairNumber) 
    % wm1 = c.tt.cf.p_options.CSP.selectedFilterPairNumber(1, ...
    %           w0_matrix(wm_ClassPairID).inner.best_fixTTParam.CSP_filterPairNumberID(wm_subjID2(1,wm_ClassPairID),wm_sessionID2(1,wm_ClassPairID),autorun_outerFoldID));
    wm1 = c_CP(wm_ClassPairID).tt.cf.p_options.CSP.selectedFilterPairNumber;
    wm2 = w0_matrix(wm_ClassPairID).outer_OR_outer_merged.tt_param(wm_subjID2(1,wm_ClassPairID),wm_sessionID2(1,wm_ClassPairID),autorun_outerFoldID,1,wtID(wm_ClassPairID)).CSP.CSPMatrix{wm_bandID,1}(:,:);
    online.p.CSP.filters_used{wm_ClassPairID, wm_bandID}(:,:) = transpose(wm2([1:wm1, (end-wm1+1):end], :));
   end
  end
else
  for wm_ClassPairID = 1 : size(w0_matrix,2)
    for wm_targetClassID = 1 : size(w0_matrix(wm_ClassPairID).outer_OR_outer_merged.tt_param,4)
     for wm_bandID = c.classSetup.band.usedIDs
	% wm1: number of used CSP filter pairs, wm2: the ctual CSP matrix -> online.p.CSP.filters_used(:,2xfilterPairNumber) 
      % wm1 = c.tt.cf.p_options.CSP.selectedFilterPairNumber(1, ...
      %           w0_matrix(wm_ClassPairID).inner.best_fixTTParam.CSP_filterPairNumberID(wm_subjID2(1,wm_ClassPairID),wm_sessionID2(1,wm_ClassPairID),autorun_outerFoldID));
      wm1 = c_CP(wm_ClassPairID).tt.cf.p_options.CSP.selectedFilterPairNumber;
      wm2 = w0_matrix(wm_ClassPairID).outer_OR_outer_merged.tt_param(wm_subjID2(1,wm_ClassPairID),wm_sessionID2(1,wm_ClassPairID),autorun_outerFoldID,wm_targetClassID,wtID(wm_ClassPairID)).CSP.CSPMatrix{wm_bandID,1};
      online.p.CSP.filters_used{wm_ClassPairID, wm_targetClassID, wm_bandID}(:,:) = transpose(wm2([1:wm1, (end-wm1+1):end], :));
     end
    end
  end
end

% Feature Extraction
% __________________

% In:
% c.tt.cf.p.winSize.ms
% 
% Out:
% online.p.cf.winSize.ms

online.p.CF.winSize.ms = c.tt.cf.p.winSize.ms;

% MI
% __

% In:
% % % % % c.tt.cf.p_options.MI.out_featureNumberPerClass(1,wm_MI_out_featureNumberID)
% c_CP(wm_ClassPairID).tt.cf.p_options.MI.out_featureNumberPerClass
% % % % % w0_matrix.inner.best_fixTTParam.outFeatureNumberID(wm_subjID2,wm_sessionID2,autorun_outerFoldID)
% w0_matrix.outer_OR_outer_merged.tt_param(wm_subjID2,wm_sessionID2,autorun_outerFoldID,wm_targetClassID,wtID).MI.featureIDs(wm_MI_out_featureID,1)
% w0_matrix.outer_OR_outer_merged.tt_param(wm_subjID2,wm_sessionID2,autorun_outerFoldID,wm_targetClassID,wtID).MI.weights(wm_MI_out_featureID,1)
%
% out:
% SW.CFx=1 -> online.p.MI.out_usedFeatureIDs(wm_targetClassID,wm_MI_out_usedFeatureID2)
% SW.CFx=2 -> online.p.MI.out_usedFeatureIDs{wm_ClassPairID,wm_targetClassID}(1,wm_MI_out_usedFeatureID2)

% % % % % % wm = c.tt.cf.p_options.MI.out_featureNumberPerClass(1, ...
% % % % % %         w0_matrix.inner.best_fixTTParam.outFeatureNumberID(wm_subjID2,wm_sessionID2,autorun_outerFoldID));
% % % % % % for wm_targetClassID = 1 : size(w0_matrix.outer_OR_outer_merged.tt_param,4)
% % % % % %  % for wm_bandID = 1 : size(w0_matrix.outer_OR_outer_merged.tt_param(wm_subjID2,wm_sessionID2,autorun_outerFoldID,wm_targetClassID,wtID).CSP.CSPMatrix,1)
% % % % % %      % online.p.MI.features_used(wm_targetClassID,:) = sort(w0_matrix.outer_OR_outer_merged.tt_param(wm_subjID2,wm_sessionID2,autorun_outerFoldID,wm_targetClassID,wtID).MI.featureIDs(1:wm,1));
% % % % % %      online.p.MI.out_usedFeatureIDs(wm_targetClassID,:) = w0_matrix.outer_OR_outer_merged.tt_param(wm_subjID2,wm_sessionID2,autorun_outerFoldID,wm_targetClassID,wtID).MI.featureIDs(1:wm,1);
% % % % % %  % end
% % % % % % end
if SW.CFx == 1
  for wm_ClassPairID = 1 : size(w0_matrix,2)
    % wm = c.tt.cf.p_options.MI.out_featureNumberPerClass(1, ...
    %         w0_matrix(wm_ClassPairID).inner.best_fixTTParam.outFeatureNumberID(wm_subjID2(1,wm_ClassPairID),wm_sessionID2(1,wm_ClassPairID),autorun_outerFoldID));
    wm = c_CP(wm_ClassPairID).tt.cf.p_options.MI.out_featureNumberPerClass;
   % for wm_bandID = c.classSetup.band.usedIDs
       % online.p.MI.features_used(wm_ClassPairID,:) = sort(w0_matrix.outer_OR_outer_merged.tt_param(wm_subjID2,wm_sessionID2,autorun_outerFoldID,1,wtID(wm_ClassPairID)).MI.featureIDs(1:wm,1));
       online.p.MI.out_usedFeatureIDs{wm_ClassPairID,1}(1,:) = w0_matrix(wm_ClassPairID).outer_OR_outer_merged.tt_param(wm_subjID2(1,wm_ClassPairID),wm_sessionID2(1,wm_ClassPairID),autorun_outerFoldID,1,wtID(wm_ClassPairID)).MI.featureIDs(1:wm,1);
   % end
  end
else
  for wm_ClassPairID = 1 : size(w0_matrix,2)
    % wm = c.tt.cf.p_options.MI.out_featureNumberPerClass(1, ...
    %         w0_matrix(wm_ClassPairID).inner.best_fixTTParam.outFeatureNumberID(wm_subjID2(1,wm_ClassPairID),wm_sessionID2(1,wm_ClassPairID),autorun_outerFoldID));
    wm = c_CP(wm_ClassPairID).tt.cf.p_options.MI.out_featureNumberPerClass;
    for wm_targetClassID = 1 : size(w0_matrix(wm_ClassPairID).outer_OR_outer_merged.tt_param,4)
     % for wm_bandID = 1 : size(w0_matrix.outer_OR_outer_merged.tt_param(wm_subjID2,wm_sessionID2,autorun_outerFoldID,wm_targetClassID,wtID).CSP.CSPMatrix,1)
         % online.p.MI.features_used(wm_targetClassID,:) = sort(w0_matrix.outer_OR_outer_merged.tt_param(wm_subjID2,wm_sessionID2,autorun_outerFoldID,wm_targetClassID,wtID).MI.featureIDs(1:wm,1));
         online.p.MI.out_usedFeatureIDs{wm_ClassPairID,wm_targetClassID}(1,:) = w0_matrix(wm_ClassPairID).outer_OR_outer_merged.tt_param(wm_subjID2(1,wm_ClassPairID),wm_sessionID2(1,wm_ClassPairID),autorun_outerFoldID,wm_targetClassID,wtID(wm_ClassPairID)).MI.featureIDs(1:wm,1);
     % end
    end
  end
end


% multiple 2-class CF
% ___________________

% (score = ldaParams.a0 + ldaParams.a1N' * inputVec;)

% In:
% w0_matrix.outer_OR_outer_merged.tt_param(wm_subjID2,wm_sessionID2,autorun_outerFoldID,wm_targetClassID,wtID).CF.param.a0
% w0_matrix.outer_OR_outer_merged.tt_param(wm_subjID2,wm_sessionID2,autorun_outerFoldID,wm_targetClassID,wtID).CF.param.a1N(wm_MI_out_usedFeatureID2,1)
%
% out:
% SW.CFx=1 -> online.p.CF.param(wm_targetClassID,1).a0
% SW.CFx=1 -> online.p.CF.param(wm_targetClassID,1).a1N(wm_MI_out_usedFeatureID2,1)
% SW.CFx=2 -> online.p.CF.param(wm_ClassPairID,wm_targetClassID).a0
% SW.CFx=2 -> online.p.CF.param(wm_ClassPairID,wm_targetClassID).a1N(wm_MI_out_usedFeatureID2,1)

% % % % % % for wm_targetClassID = 1 : size(w0_matrix.outer_OR_outer_merged.tt_param,4)
% % % % % %     online.p.CF.param(wm_targetClassID,1).a0 = w0_matrix.outer_OR_outer_merged.tt_param(wm_subjID2,wm_sessionID2,autorun_outerFoldID,wm_targetClassID,wtID).CF.param.a0;
% % % % % %     online.p.CF.param(wm_targetClassID,1).a1N = w0_matrix.outer_OR_outer_merged.tt_param(wm_subjID2,wm_sessionID2,autorun_outerFoldID,wm_targetClassID,wtID).CF.param.a1N;
% % % % % % end
if SW.CFx == 1
  for wm_ClassPairID = 1 : size(w0_matrix,2)
    online.p.CF.param(wm_ClassPairID,1).a0 = w0_matrix(wm_ClassPairID).outer_OR_outer_merged.tt_param(wm_subjID2(1,wm_ClassPairID),wm_sessionID2(1,wm_ClassPairID),autorun_outerFoldID,1,wtID(wm_ClassPairID)).CF.param.a0;
    online.p.CF.param(wm_ClassPairID,1).a1N = w0_matrix(wm_ClassPairID).outer_OR_outer_merged.tt_param(wm_subjID2(1,wm_ClassPairID),wm_sessionID2(1,wm_ClassPairID),autorun_outerFoldID,1,wtID(wm_ClassPairID)).CF.param.a1N;
  end
else
  for wm_ClassPairID = 1 : size(w0_matrix,2)  
    for wm_targetClassID = 1 : size(w0_matrix(wm_ClassPairID).outer_OR_outer_merged.tt_param,4)
        online.p.CF.param(wm_ClassPairID,wm_targetClassID).a0 = w0_matrix(wm_ClassPairID).outer_OR_outer_merged.tt_param(wm_subjID2(1,wm_ClassPairID),wm_sessionID2(1,wm_ClassPairID),autorun_outerFoldID,wm_targetClassID,wtID(wm_ClassPairID)).CF.param.a0;
        online.p.CF.param(wm_ClassPairID,wm_targetClassID).a1N = w0_matrix(wm_ClassPairID).outer_OR_outer_merged.tt_param(wm_subjID2(1,wm_ClassPairID),wm_sessionID2(1,wm_ClassPairID),autorun_outerFoldID,wm_targetClassID,wtID(wm_ClassPairID)).CF.param.a1N;
    end
  end
end

% 2-class CF result norm
% ______________________

online.p.CF.substractedValue2_from_2ClassResults = c.online.p.CF.substractedValue2_from_2ClassResults;

online.p.CF.SW_2ClassResultNorm_notUsed0_autoBaseline1_specNorm2 = c.online.p.CF.SW_2ClassResultNorm_notUsed0_autoBaseline1_specNorm2;

online.p.CF.meanCurrent.wSize.ms = c.online.p.CF.meanCurrent.wSize.ms;    % used if online.p.CF.SW_2ClassResultNorm_notUsed0_autoBaseline1_specNorm2 == 1
online.p.CF.gapBetweenCurrentAndRefWindows.wSize.ms = c.online.p.CF.gapBetweenCurrentAndRefWindows.wSize.ms;    % used if online.p.CF.SW_2ClassResultNorm_notUsed0_autoBaseline1_specNorm2 == 1
online.p.CF.meanReference.wSize.ms = c.online.p.CF.meanReference.wSize.ms;    % used if online.p.CF.SW_2ClassResultNorm_notUsed0_autoBaseline1_specNorm2 == 1


% 2-class CF post-processing
% __________________________

online.p.CF_postProc.baseline = c.online.p.CF_postProc.baseline;
online.p.CF_postProc.baseAmp = c.online.p.CF_postProc.baseAmp;

online.p.CF_postProc.hyster.class1_on = c.online.p.CF_postProc.hyster.class1_on;
online.p.CF_postProc.hyster.class1_off = c.online.p.CF_postProc.hyster.class1_off;
online.p.CF_postProc.hyster.class2_on = c.online.p.CF_postProc.hyster.class2_on;
online.p.CF_postProc.hyster.class2_off = c.online.p.CF_postProc.hyster.class2_off;

online.p.CF_postProc.timer.hysterOnsetMin_sec = c.online.p.CF_postProc.timer.hysterOnsetMin_sec;    % (Timer1)
online.p.CF_postProc.timer.outClassWidth_sec = c.online.p.CF_postProc.timer.outClassWidth_sec;      % (Timer2)
online.p.CF_postProc.timer.deadband_sec = c.online.p.CF_postProc.timer.deadband_sec;                % (Deadband)


end



%% Comment

%{
online.p.CSP.filters_used{wm_ClassPairID, wm_bandID} ... -> online.p.CSP.filters_used{wm_ClassPairID, wm_targetClassID, wm_bandID} ...
%}






