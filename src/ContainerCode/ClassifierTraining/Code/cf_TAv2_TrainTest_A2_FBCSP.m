% Config file for
% Multi-class Classification, task manager 

% Input structures

% Output structures

% REQUIRESTMENT: Matlab
% Copyright(c)2020 Attila Korik, http://isrc.ulster.ac.uk/akorik/contact.html


%% VA Setup (A2 FBCSP) parfor setup

%     TM.parfor.perm.parforUsed = 0;       % =0:parfor NOT used, =1:parfor, =2:parfor_with_parDir (will initialized and used during code execution)  % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
%     TM.parfor.core.parforUsed = 0;       % =0:parfor NOT used, =1:parfor (will initialized and used during code execution)   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
%     % 
    TM.parfor.perm.parforUsed = 0;       % =0:parfor NOT used, =1:parfor, =2:parfor_with_parDir (will initialized and used during code execution)  % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
    TM.parfor.core.parforUsed = 0;       % =0:parfor NOT used, =1:parfor (will initialized and used during code execution)   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
%     % 
%     TM.parfor.perm.parforUsed = 1;       % =0:parfor NOT used, =1:parfor, =2:parfor_with_parDir (will initialized and used during code execution)  % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
%     TM.parfor.core.parforUsed = 0;       % =0:parfor NOT used, =1:parfor (will initialized and used during code execution)   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
%     % 
%     TM.parfor.perm.parforUsed = 2;       % =0:parfor NOT used, =1:parfor, =2:parfor_with_parDir (will initialized and used during code execution)  % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
%     TM.parfor.core.parforUsed = 0;       % =0:parfor NOT used, =1:parfor (will initialized and used during code execution)   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
    
    if TM.parfor.perm.parforUsed == 1   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
        % TM.parfor.perm.location = 'HPCServerProfile1';
        % % TM.parfor.perm.number_basis = -1;    % >0:number of parfor cores, =-1:number of used cores will equal:(size(autorun.tt.used.subjects,2) * size(autorun.tt.used.sessions,2) * c.tt.folds.outerFoldNumber) 
        % TM.parfor.perm.number_basis = 101;    % >0:number of parfor cores, =-1:number of used cores will equal:(size(autorun.tt.used.subjects,2) * size(autorun.tt.used.sessions,2) * c.tt.folds.outerFoldNumber) 
        % TM.parfor.perm.reOpenIfOpen = 0;     % =1:close and open with TM.parfor.perm.number at start, =0:keep open with the same workers if open 
        % TM.parfor.perm.closeAtEnd = 0;       % =1:close parpool after run, =0:keep open parpool after run 
    
        % %  !!! THIS IS FOR X-core local RUN !!!
        % TM.parfor.perm.location = 'local';
        % TM.parfor.perm.number_basis = 4;    % >0:number of parfor cores, =-1:number of used cores will equal:(size(autorun.tt.used.subjects,2) * size(autorun.tt.used.sessions,2) * c.tt.folds.outerFoldNumber) 
        % TM.parfor.perm.reOpenIfOpen = 0;     % =1:close and open with TM.parfor.perm.number at start, =0:keep open with the same workers if open 
        % TM.parfor.perm.closeAtEnd = 0;       % =1:close parpool after run, =0:keep open parpool after run 
        
        %  !!! THIS IS FOR X-core local RUN !!!
        TM.parfor.perm.location = 'local';
        TM.parfor.perm.number_basis = 8;    % >0:number of parfor cores, =-1:number of used cores will equal:(size(autorun.tt.used.subjects,2) * size(autorun.tt.used.sessions,2) * c.tt.folds.outerFoldNumber) 
        TM.parfor.perm.reOpenIfOpen = 0;     % =1:close and open with TM.parfor.perm.number at start, =0:keep open with the same workers if open 
        TM.parfor.perm.closeAtEnd = 0;       % =1:close parpool after run, =0:keep open parpool after run 
    end
    
    if TM.parfor.core.parforUsed == 1    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
        % TM.parfor.core.location = 'HPCServerProfile1';
        % % TM.parfor.core.number_basis = -1;    % >0:number of parfor cores, =-1:number of used cores will equal:(size(autorun.tt.used.subjects,2) * size(autorun.tt.used.sessions,2) * c.tt.folds.outerFoldNumber) 
        % TM.parfor.core.number_basis = 101;    % >0:number of parfor cores, =-1:number of used cores will equal:(size(autorun.tt.used.subjects,2) * size(autorun.tt.used.sessions,2) * c.tt.folds.outerFoldNumber) 
        % TM.parfor.core.reOpenIfOpen = 0;     % =1:close and open with TM.parfor.core.number at start, =0:keep open with the same workers if open 
        % TM.parfor.core.closeAtEnd = 0;       % =1:close parpool after run, =0:keep open parpool after run 
    
        % %  !!! THIS IS FOR X-core local RUN !!!
        % TM.parfor.core.location = 'local';
        % TM.parfor.core.number_basis = 4;    % >0:number of parfor cores, =-1:number of used cores will equal:(size(autorun.tt.used.subjects,2) * size(autorun.tt.used.sessions,2) * c.tt.folds.outerFoldNumber) 
        % TM.parfor.core.reOpenIfOpen = 0;     % =1:close and open with TM.parfor.core.number at start, =0:keep open with the same workers if open 
        % TM.parfor.core.closeAtEnd = 0;       % =1:close parpool after run, =0:keep open parpool after run 
        
        %  !!! THIS IS FOR X-core local RUN !!!
        TM.parfor.core.location = 'local';
        TM.parfor.core.number_basis = 8;    % >0:number of parfor cores, =-1:number of used cores will equal:(size(autorun.tt.used.subjects,2) * size(autorun.tt.used.sessions,2) * c.tt.folds.outerFoldNumber) 
        TM.parfor.core.reOpenIfOpen = 0;     % =1:close and open with TM.parfor.perm.number at start, =0:keep open with the same workers if open 
        TM.parfor.core.closeAtEnd = 0;       % =1:close parpool after run, =0:keep open parpool after run 
    end


%% VA Setup (A2 FBCSP) Common setup

% TM.commonParam.c.eval.SW.eval_used = 1;      % =1: evaluation run by taskManager after trainTest % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
TM.commonParam.c.eval.SW.taskFigPrep_used = 0;      % =1: taskFigure preparation run by taskManager after trainTest % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
TM.commonParam.c.eval.SW.DA_eval_used = 1;      % =1: DA_eval run by taskManager after trainTest done for all tasks % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% TM.commonParam.c.eval.SW.topoplot.CSP_MI.plotted_rest1_task2 = [1,2,0];      % 0: difference of task and rest : abs(task-rest) % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
TM.commonParam.c.eval.SW.topoplot.CSP_MI.plotted_rest1_task2 = [1,2];      % 0: difference of task and rest : abs(task-rest) % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% TM.commonParam.c.eval.SW.topoplot.CSP_MI.plotted_rest1_task2 = 2;      % 0: difference of task and rest : abs(task-rest) % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 

%% VA Setup (A2 FBCSP) Task-related Setup

wm_taskID = 1;  % A01 (width1s) validTr MI-feat4
TM.taskParam{wm_taskID,1}.c.tt.cf.p.use_multiClass_cf_onlyIf_numberOfClassesMoreThanTwo = 1;   % =1:use multi-class classification only if number of classes more than 2, =0:use multi-class method for any number of classes (if number of classes 2 than 2-class classification runs 2 times and use multi-class selection method using both results)
% TM.taskParam{wm_taskID,1}.c.tt.cf.p.winSize.ms = 2000;     % classification steps in ms (steps of classifier window in looped calculation across the used trial interval)
% TM.taskParam{wm_taskID,1}.c.tt.cf.p.winSize.ms = 1200;     % classification steps in ms (steps of classifier window in looped calculation across the used trial interval)
TM.taskParam{wm_taskID,1}.c.tt.cf.p.winSize.ms = 1000;    % classifier window size in ms
    TM = config_modification(VA_TRANS, TM,wm_taskID);   % !!!!! T1_mixed_result_table__from_ALLCh9Ch_CF1sCF2s and wm_taskID based config modification !!!!!
% TM.taskParam{wm_taskID,1}.c.tt.cf.p.winStep.ms = 200;    % classifier window step in ms
% TM.taskParam{wm_taskID,1}.c.tt.cf.p.winStep.ms = 60;    % classifier window step in ms
TM.taskParam{wm_taskID,1}.c.tt.cf.p.winStep.ms = 40;    % classifier window step in ms
% % % % TM.taskParam{wm_taskID,1}.c.tt.cf.p_options.CSP.selectedFilterPairNumber = [2]; % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!!   % parameter options: number of selected spatial filter pairs (e.g., 2pairs/class)

if length(VA_TRANS.c.prep.EEG.rec.ch.name)<4
    TM.taskParam{wm_taskID,1}.c.tt.cf.p_options.CSP.selectedFilterPairNumber = [1]; % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!!   % parameter options: number of selected spatial filter pairs (e.g., 2pairs/class)
elseif length(VA_TRANS.c.prep.EEG.rec.ch.name)==4||length(VA_TRANS.c.prep.EEG.rec.ch.name)==5
    TM.taskParam{wm_taskID,1}.c.tt.cf.p_options.CSP.selectedFilterPairNumber = [2]; % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!!   % parameter options: number of selected spatial filter pairs (e.g., 2pairs/class)
else
    TM.taskParam{wm_taskID,1}.c.tt.cf.p_options.CSP.selectedFilterPairNumber = [3]; % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!!   % parameter options: number of selected spatial filter pairs (e.g., 2pairs/class)
end

TM.taskParam{wm_taskID,1}.c.tt.cf.p_options.MI.quantization_level = [3];          % parameter options: number of the quantization levels used for mutual info code
TM.taskParam{wm_taskID,1}.c.tt.cf.p_options.MI.out_featureNumberPerClass = [4]; % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!!       % parameter options: output feature number of the MI (mutual info) code
% % % % TM.taskParam{wm_taskID,1}.c.tt.cf.p_options.MI.out_featureNumberPerClass = [6]; % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!!       % parameter options: output feature number of the MI (mutual info) code
TM.taskParam{wm_taskID,1}.c.tt.cf.p.CF.method.toolbox = 'RCSPToolbox';      % info: LDA_train
% TM.taskParam{wm_taskID,1}.c.tt.cf.p.CF.method.trainMethod = 'LDA';         % LDA training method setup (LDA, RLDA)
TM.taskParam{wm_taskID,1}.c.tt.cf.p.CF.method.trainMethod = 'RLDA';         % LDA training method setup (LDA, RLDA)

TM.taskParam{wm_taskID,1}.c.eval.SW.plot_shaded_DA = 1;
TM.taskParam{wm_taskID,1}.c.eval.SW.plot_paramEval = 0;
TM.taskParam{wm_taskID,1}.c.eval.SW.plot_freqEval_v1 = 0;
TM.taskParam{wm_taskID,1}.c.eval.SW.plot_freqEval_v2 = 0;
TM.taskParam{wm_taskID,1}.c.eval.SW.plot_freqEval_v3 = 0;
% TM.taskParam{wm_taskID,1}.c.eval.SW.plot_topoplot_CSPMI = 1;
% TM.taskParam{wm_taskID,1}.c.eval.SW.plot_freqEval_v4 = 1;
TM.taskParam{wm_taskID,1}.c.eval.SW.plot_topoplot_CSPMI = 0;
TM.taskParam{wm_taskID,1}.c.eval.SW.plot_freqEval_v4 = 0;
% % c.eval.SW.plot_topoplot_ERP = 0;
TM.taskParam{wm_taskID,1}.c.eval.SW.plot_topoplot_ERDS = 0;

wm_taskID = 2;  % A02 (width1s) validTr MI-feat6
TM.taskParam{wm_taskID,1}.c.tt.cf = TM.taskParam{wm_taskID-1,1}.c.tt.cf;
TM.taskParam{wm_taskID,1}.c.eval.SW = TM.taskParam{wm_taskID-1,1}.c.eval.SW;
% TM.taskParam{wm_taskID,1}.c.tt.cf.p.winSize.ms = 1000;    % classifier window size in ms
TM.taskParam{wm_taskID,1}.c.tt.cf.p_options.MI.out_featureNumberPerClass = [6]; % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!!       % parameter options: output feature number of the MI (mutual info) code
% % % % TM.taskParam{wm_taskID,1}.c.tt.cf.p_options.MI.out_featureNumberPerClass = [10]; % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!!       % parameter options: output feature number of the MI (mutual info) code

% if length(VA_TRANS.c.classSetup.band.usedIDs)*TM.taskParam{wm_taskID,1}.c.tt.cf.p_options.CSP.selectedFilterPairNumber*2<9
    wm_taskID = 3;  % A03 (width1s) validTr MI-feat8
    TM.taskParam{wm_taskID,1}.c.tt.cf = TM.taskParam{wm_taskID-1,1}.c.tt.cf;
    TM.taskParam{wm_taskID,1}.c.eval.SW = TM.taskParam{wm_taskID-1,1}.c.eval.SW;
    % TM.taskParam{wm_taskID,1}.c.tt.cf.p.winSize.ms = 1000;    % classifier window size in ms
    TM.taskParam{wm_taskID,1}.c.tt.cf.p_options.MI.out_featureNumberPerClass = [8]; % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!!       % parameter options: output feature number of the MI (mutual info) code
    % % % % TM.taskParam{wm_taskID,1}.c.tt.cf.p_options.MI.out_featureNumberPerClass = [14]; % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!!       % parameter options: output feature number of the MI (mutual info) code
% end
   
if length(VA_TRANS.c.classSetup.band.usedIDs)*TM.taskParam{wm_taskID,1}.c.tt.cf.p_options.CSP.selectedFilterPairNumber*2>9
    wm_taskID = 4;  % A04 (width1s) validTr MI-feat10
    TM.taskParam{wm_taskID,1}.c.tt.cf = TM.taskParam{wm_taskID-1,1}.c.tt.cf;
    TM.taskParam{wm_taskID,1}.c.eval.SW = TM.taskParam{wm_taskID-1,1}.c.eval.SW;
    % TM.taskParam{wm_taskID,1}.c.tt.cf.p.winSize.ms = 1000;    % classifier window size in ms
    TM.taskParam{wm_taskID,1}.c.tt.cf.p_options.MI.out_featureNumberPerClass = [10]; % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!!       % parameter options: output feature number of the MI (mutual info) code
    % % % % TM.taskParam{wm_taskID,1}.c.tt.cf.p_options.MI.out_featureNumberPerClass = [18]; % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!!       % parameter options: output feature number of the MI (mutual info) code
end 
% wm_taskID = 5;  % A04 (width1s) validTr MI-feat12
% TM.taskParam{wm_taskID,1}.c.tt.cf = TM.taskParam{wm_taskID-1,1}.c.tt.cf;
% TM.taskParam{wm_taskID,1}.c.eval.SW = TM.taskParam{wm_taskID-1,1}.c.eval.SW;
% % TM.taskParam{wm_taskID,1}.c.tt.cf.p.winSize.ms = 1000;    % classifier window size in ms
% TM.taskParam{wm_taskID,1}.c.tt.cf.p_options.MI.out_featureNumberPerClass = [12]; % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!!       % parameter options: output feature number of the MI (mutual info) code
% % % % % TM.taskParam{wm_taskID,1}.c.tt.cf.p_options.MI.out_featureNumberPerClass = [18]; % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!!       % parameter options: output feature number of the MI (mutual info) code
% 
% wm_taskID = 6;  % A04 (width1s) validTr MI-feat14
% TM.taskParam{wm_taskID,1}.c.tt.cf = TM.taskParam{wm_taskID-1,1}.c.tt.cf;
% TM.taskParam{wm_taskID,1}.c.eval.SW = TM.taskParam{wm_taskID-1,1}.c.eval.SW;
% % TM.taskParam{wm_taskID,1}.c.tt.cf.p.winSize.ms = 1000;    % classifier window size in ms
% TM.taskParam{wm_taskID,1}.c.tt.cf.p_options.MI.out_featureNumberPerClass = [14]; % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!!       % parameter options: output feature number of the MI (mutual info) code
% % % % % TM.taskParam{wm_taskID,1}.c.tt.cf.p_options.MI.out_featureNumberPerClass = [18]; % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!!       % parameter options: output feature number of the MI (mutual info) code

% % wm_taskID = 5;  % A05 (width2s) validTr MI-feat4
% % TM.taskParam{wm_taskID,1}.c.tt.cf = TM.taskParam{wm_taskID-1,1}.c.tt.cf;
% % TM.taskParam{wm_taskID,1}.c.eval.SW = TM.taskParam{wm_taskID-1,1}.c.eval.SW;
% % TM.taskParam{wm_taskID,1}.c.tt.cf.p.winSize.ms = 2000;    % classifier window size in ms
% % TM.taskParam{wm_taskID,1}.c.tt.cf.p_options.MI.out_featureNumberPerClass = [4];       % parameter options: output feature number of the MI (mutual info) code
% % 
% % wm_taskID = 6;  % A06 (width2s) validTr MI-feat6
% % TM.taskParam{wm_taskID,1}.c.tt.cf = TM.taskParam{wm_taskID-1,1}.c.tt.cf;
% % TM.taskParam{wm_taskID,1}.c.eval.SW = TM.taskParam{wm_taskID-1,1}.c.eval.SW;
% % TM.taskParam{wm_taskID,1}.c.tt.cf.p.winSize.ms = 2000;    % classifier window size in ms
% % TM.taskParam{wm_taskID,1}.c.tt.cf.p_options.MI.out_featureNumberPerClass = [6];       % parameter options: output feature number of the MI (mutual info) code
% % 
% % wm_taskID = 7;  % A07 (width2s) validTr MI-feat8
% % TM.taskParam{wm_taskID,1}.c.tt.cf = TM.taskParam{wm_taskID-1,1}.c.tt.cf;
% % TM.taskParam{wm_taskID,1}.c.eval.SW = TM.taskParam{wm_taskID-1,1}.c.eval.SW;
% % TM.taskParam{wm_taskID,1}.c.tt.cf.p.winSize.ms = 2000;    % classifier window size in ms
% % TM.taskParam{wm_taskID,1}.c.tt.cf.p_options.MI.out_featureNumberPerClass = [8];       % parameter options: output feature number of the MI (mutual info) code
% % 
% % wm_taskID = 8;  % A08 (width2s) validTr MI-feat10
% % TM.taskParam{wm_taskID,1}.c.tt.cf = TM.taskParam{wm_taskID-1,1}.c.tt.cf;
% % TM.taskParam{wm_taskID,1}.c.eval.SW = TM.taskParam{wm_taskID-1,1}.c.eval.SW;
% % TM.taskParam{wm_taskID,1}.c.tt.cf.p.winSize.ms = 2000;    % classifier window size in ms
% % TM.taskParam{wm_taskID,1}.c.tt.cf.p_options.MI.out_featureNumberPerClass = [10];       % parameter options: output feature number of the MI (mutual info) code


%% Function
% T1_mixed_result_table__from_ALLCh9Ch_CF1sCF2s and wm_taskID based config modification

function TM = config_modification(VA_TRANS, TM,wm_taskID)
   if isfield(VA_TRANS,'T1_mixed_result_table__from_ALLCh9Ch_CF1sCF2s') % code: without band set option
    if ~isempty(VA_TRANS.T1_mixed_result_table__from_ALLCh9Ch_CF1sCF2s)
      wm = VA_TRANS.T1_mixed_result_table__from_ALLCh9Ch_CF1sCF2s(VA_TRANS.wm_T1TATM_taskID,1);
    end
   end
   if isfield(VA_TRANS,'T1_mixed_result_table__from_ALLCh9Ch_CF1sCF2s_BandSetID') % code: with band set option
    if ~isempty(VA_TRANS.T1_mixed_result_table__from_ALLCh9Ch_CF1sCF2s_BandSetID)
      wm = VA_TRANS.T1_mixed_result_table__from_ALLCh9Ch_CF1sCF2s_BandSetID(VA_TRANS.wm_T1TATM_taskID,1);
    end
   end
   
   if exist('wm','var')
    if wm < 100
      wm12 = wm - (fix(wm/100)*100);
    else
      wm12 = fix(wm/10);
    end
    if (wm12 == 11) || (wm12 == 91)
      TM.taskParam{wm_taskID,1}.c.tt.cf.p.winSize.ms = 1000;    % classifier window size in ms
    elseif (wm12 == 12) || (wm12 == 92)
      TM.taskParam{wm_taskID,1}.c.tt.cf.p.winSize.ms = 2000;    % classifier window size in ms
    else
      BREAK_THE_CODE_HERE_WITH_ERROR
    end
   end
end


%% Comments









