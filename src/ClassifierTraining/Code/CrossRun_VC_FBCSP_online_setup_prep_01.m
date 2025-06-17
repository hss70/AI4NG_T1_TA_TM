% Online Setup Preparation (with func) using Offline Results from FilterBankCSP Multi-class Classification
% (this code call: VC_FBCSP_online_setup_prep_funct_01)

% Input structures

% Output structures
% c.online. ...

% REQUIRESTMENT: Matlab
% Copyright(c)2018 Attila Korik, http://isrc.ulster.ac.uk/akorik/contact.html


%% Function headline

% % % % function FN_out = VA_A10B_offlineTrial_validation_01(FN_in)
% % % % FN_out = 'N/A';

if exist('VA','var')
   VA.SW = true;

% %     VA.set.w.switch.tr.allValid = 0;
else
   VA.SW = false;
end

if VA.SW
    % VA.c.SW.CFx = VA.c.SW.CFx;   % =1:Classification use 1 CF lane (target vs others),  =2:Classification use difference of 2 CF lanes (target vs others - others vs target) 
else
    VA.c.SW.CFx = 1;   % =1:Classification use 1 CF lane (target vs others),  =2:Classification use difference of 2 CF lanes (target vs others - others vs target) 
end


%% Code 1. taskManager parameter setup: common parameters

% clear; close all;


% ___________________
%
% Task vs Relax used?
% ___________________

if VA.SW
else
    w.m = questdlg('Task vs Relax included?','Setup','T123 (only)','T123+R','T123+R');
    if strcmp(w.m,'T123 (only)')
        VA.f.SW.task_vs_relax_CP_used = 0;
    else
        VA.f.SW.task_vs_relax_CP_used = 1;
    end
end

% ________________
%
% Loading Datasets
%_________________

if VA.SW
    for wm_subDirID = 1 : size(VA.f.classSubDir,2)
        w.file.load.autoload = 1;

        % MCC_FBCSP_offline_trainTest_01
        w.file.load_CP(wm_subDirID).path = [VA.f.load.baseDir_FBCSP,'\', ...
            VA.f.classSubDir{wm_subDirID},'\A',num2str(subFunc_num2str_2digit(VA.c.eval.FBCSP_option_Axx_used(1,wm_subDirID))),'\'];
        w.file.load_CP(wm_subDirID).nameBasis1 = VA.f.load.nameBasis1_FBCSP;
    end
else
    w.m = questdlg('Do you want to load required input datasets ?','Setup','Load input datasets','Continue without loading','Load input datasets');
    if strcmp(w.m,'Load input datasets')

        fprintf('\n');
        % fprintf('Loading input dataset (it may take some minutes):\n\n');

            % % FBCSP_MCC15_offline_trainTest_01 [config]
            % [w.file.load.nameBasis, w.file.load.path] = uigetfile(strcat('FBCSP_MCC15_offline_trainTest_01 [config].mat'),'Load input dataset');
            % w.file.load.nameBasis1 = w.file.load.nameBasis( 1 : max(find(w.file.load.nameBasis(1,:)=='['))-2);

            % ClassPair1
            % FBCSP_offline_trainTest_01 [config]
            [w.file.load_CP(1).nameBasis, w.file.load_CP(1).path] = uigetfile(strcat('FBCSP_offline_trainTest_01 [config].mat'),'Load input dataset');
            w.file.load_CP(1).nameBasis1 = w.file.load_CP(1).nameBasis( 1 : max(find(w.file.load_CP(1).nameBasis(1,:)=='['))-2);

            % ClassPair2
            % FBCSP_offline_trainTest_01 [config]
            [w.file.load_CP(2).nameBasis, w.file.load_CP(2).path] = uigetfile(strcat('FBCSP_offline_trainTest_01 [config].mat'),'Load input dataset');
            w.file.load_CP(2).nameBasis1 = w.file.load_CP(2).nameBasis( 1 : max(find(w.file.load_CP(2).nameBasis(1,:)=='['))-2);

            % ClassPair3
            % FBCSP_offline_trainTest_01 [config]
            [w.file.load_CP(3).nameBasis, w.file.load_CP(3).path] = uigetfile(strcat('FBCSP_offline_trainTest_01 [config].mat'),'Load input dataset');
            w.file.load_CP(3).nameBasis1 = w.file.load_CP(3).nameBasis( 1 : max(find(w.file.load_CP(3).nameBasis(1,:)=='['))-2);

            if VA.f.SW.task_vs_relax_CP_used
                % ClassPair4 (Task vs Relax)
                % FBCSP_offline_trainTest_01 [config]
                [w.file.load_CP(4).nameBasis, w.file.load_CP(4).path] = uigetfile(strcat('FBCSP_offline_trainTest_01 [config].mat'),'Load input dataset');
                w.file.load_CP(4).nameBasis1 = w.file.load_CP(4).nameBasis( 1 : max(find(w.file.load_CP(4).nameBasis(1,:)=='['))-2);
            end
            
        w.file.load.autoload = 1;
    else
        w.file.load.autoload = 0;
    end
end

if w.file.load.autoload == 1
    
        % Load common files for all ClassPairs
        % ____________________________________
        
        w.file.load = w.file.load_CP(1);

        fprintf('Loading EEG_validation ...\n');
        w.file.load.name = strcat(w.file.load.nameBasis1,' [EEG_validation].mat');
        load([w.file.load.path,w.file.load.name]);
        EEG_validation = copy_of_EEG_validation;
        clear copy_of_EEG_validation

% % % %         % Load [autorun]
% % % %         % ______________
% % % %         
% % % %         % ClassPair1
% % % %         fprintf('Loading autorun ...\n');
% % % %         w.file.load.name = strcat(w.file.load_CP(1).nameBasis1,' [autorun].mat');
% % % %         load([w.file.load_CP(1).path,w.file.load.name]);
% % % %         autorun_CP(1) = copy_of_autorun;
% % % %         clear copy_of_autorun
% % % % 
% % % %         % ClassPair2
% % % %         fprintf('Loading autorun ...\n');
% % % %         w.file.load.name = strcat(w.file.load_CP(2).nameBasis1,' [autorun].mat');
% % % %         load([w.file.load_CP(2).path,w.file.load.name]);
% % % %         autorun_CP(2) = copy_of_autorun;
% % % %         clear copy_of_autorun
% % % % 
% % % %         % ClassPair3
% % % %         fprintf('Loading autorun ...\n');
% % % %         w.file.load.name = strcat(w.file.load_CP(3).nameBasis1,' [autorun].mat');
% % % %         load([w.file.load_CP(3).path,w.file.load.name]);
% % % %         autorun_CP(3) = copy_of_autorun;
% % % %         clear copy_of_autorun
% % % % 
% % % %         if VA.f.SW.task_vs_relax_CP_used
% % % %             % ClassPair4 (Task vs Relax)
% % % %             fprintf('Loading autorun ...\n');
% % % %             w.file.load.name = strcat(w.file.load_CP(4).nameBasis1,' [autorun].mat');
% % % %             load([w.file.load_CP(4).path,w.file.load.name]);
% % % %             autorun_CP(4) = copy_of_autorun;
% % % %             clear copy_of_autorun
% % % %         end
% % % % 
% % % %         % Load [config]
% % % %         % _____________
% % % %         
% % % %         % ClassPair1
% % % %         fprintf('Loading config ...\n');
% % % %         w.file.load.name = strcat(w.file.load_CP(1).nameBasis1,' [config].mat');
% % % %         load([w.file.load_CP(1).path,w.file.load.name]);
% % % %         c_CP(1) = copy_of_c;
% % % %         clear copy_of_c
% % % %         
% % % %         % For common part of c
% % % %         c = c_CP(1);
% % % % 
% % % %         % ClassPair2
% % % %         fprintf('Loading config ...\n');
% % % %         w.file.load.name = strcat(w.file.load_CP(2).nameBasis1,' [config].mat');
% % % %         load([w.file.load_CP(2).path,w.file.load.name]);
% % % %         c_CP(2) = copy_of_c;
% % % %         clear copy_of_c
% % % % 
% % % %         % ClassPair3
% % % %         fprintf('Loading config ...\n');
% % % %         w.file.load.name = strcat(w.file.load_CP(3).nameBasis1,' [config].mat');
% % % %         load([w.file.load_CP(3).path,w.file.load.name]);
% % % %         c_CP(3) = copy_of_c;
% % % %         clear copy_of_c
% % % % 
% % % %         if VA.f.SW.task_vs_relax_CP_used
% % % %             % ClassPair4 (Task vs Relax)
% % % %             fprintf('Loading config ...\n');
% % % %             w.file.load.name = strcat(w.file.load_CP(4).nameBasis1,' [config].mat');
% % % %             load([w.file.load_CP(4).path,w.file.load.name]);
% % % %             c_CP(4) = copy_of_c;
% % % %             clear copy_of_c
% % % %         end
% % % % 
% % % %         % Load w0_matrix
% % % %         % ______________
% % % %         
% % % %         % fprintf('Loading w0_matrix ...\n');
% % % %         % w.file.load.name = strcat(w.file.load.nameBasis1,' [w0_matrix].mat');
% % % %         % load([w.file.load.path,w.file.load.name]);
% % % %         % w0_matrix = copy_of_w0_matrix;
% % % %         % clear copy_of_w0_matrix
% % % % 
% % % %         % ClassPair1
% % % %         fprintf('Loading w0_matrix for ClassPair1 ...\n');
% % % %         w.file.load.name = strcat(w.file.load_CP(1).nameBasis1,' [w0_matrix].mat');
% % % %         load([w.file.load_CP(1).path,w.file.load.name]);
% % % %         w0_matrix(1) = copy_of_w0_matrix;
% % % %         clear copy_of_w0_matrix
% % % % 
% % % %         % ClassPair2
% % % %         fprintf('Loading w0_matrix for ClassPair2 ...\n');
% % % %         w.file.load.name = strcat(w.file.load_CP(2).nameBasis1,' [w0_matrix].mat');
% % % %         load([w.file.load_CP(2).path,w.file.load.name]);
% % % %         w0_matrix(2) = copy_of_w0_matrix;
% % % %         clear copy_of_w0_matrix
% % % % 
% % % %         % ClassPair3
% % % %         fprintf('Loading w0_matrix for ClassPair3 ...\n');
% % % %         w.file.load.name = strcat(w.file.load_CP(3).nameBasis1,' [w0_matrix].mat');
% % % %         load([w.file.load_CP(3).path,w.file.load.name]);
% % % %         w0_matrix(3) = copy_of_w0_matrix;
% % % %         clear copy_of_w0_matrix
% % % % 
% % % %         if VA.f.SW.task_vs_relax_CP_used
% % % %             % ClassPair4 (Task vs Relax)
% % % %             fprintf('Loading w0_matrix for ClassPair4 ...\n');
% % % %             w.file.load.name = strcat(w.file.load_CP(4).nameBasis1,' [w0_matrix].mat');
% % % %             load([w.file.load_CP(4).path,w.file.load.name]);
% % % %             w0_matrix(4) = copy_of_w0_matrix;
% % % %             clear copy_of_w0_matrix
% % % %         end
        for wm_subDirID = 1 : size(VA.f.classSubDir,2)
            
            % Load [autorun]
            % ______________
            
            fprintf('Loading autorun ...\n');
            w.file.load.name = strcat(w.file.load_CP(wm_subDirID).nameBasis1,' [autorun].mat');
            load([w.file.load_CP(wm_subDirID).path,w.file.load.name]);
            autorun_CP(wm_subDirID) = copy_of_autorun;
            clear copy_of_autorun
            
            % Load [config]
            % _____________
            
            fprintf('Loading config ...\n');
            w.file.load.name = strcat(w.file.load_CP(wm_subDirID).nameBasis1,' [config].mat');
            load([w.file.load_CP(wm_subDirID).path,w.file.load.name]);
            c_CP(wm_subDirID) = copy_of_c;
            clear copy_of_c
            
            % Load w0_matrix
            % ______________
            
            fprintf(['Loading w0_matrix for ClassPair',num2str(wm_subDirID),' ...\n']);
            w.file.load.name = strcat(w.file.load_CP(wm_subDirID).nameBasis1,' [w0_matrix].mat');
            load([w.file.load_CP(wm_subDirID).path,w.file.load.name]);
            w0_matrix(wm_subDirID) = copy_of_w0_matrix;
            clear copy_of_w0_matrix
        end

        % For common part of c
        c = c_CP(1);

    % fprintf('\n');
    % fprintf('Dataset loading: DONE\n\n');
    fprintf('Dataset loading: DONE\n');
end

% ________________________________________________
%
% Setup for automatic save during progress of code
% ________________________________________________

if VA.SW
     w.file.save.autosave = 1;
     w.file.save.path = [VA.f.save.baseDir,'\'];
     mkdir(w.file.save.path);
     w.file.save.nameBasis1 = VA.f.save.nameBasis1;
else
    w.m = questdlg('Do you want automatic save of result ?','Setup','Auto save','Not save','Auto save');
    if strcmp(w.m,'Auto save')
        [w.file.save.nameBasis, w.file.save.path] = uiputfile(strcat('FBCSP_online_setup_prep_01.mat'),'Set up result directory and filename');
        w.file.save.nameBasis1 = w.file.save.nameBasis( 1 : max(find(w.file.save.nameBasis(1,:)=='.'))-1);

        w.file.save.autosave = 1;
    else
        w.file.save.autosave = 0;
    end
end



% ___________
%
% Basis setup
% ___________

if ~isnan(str2double('1;2;3'))
    w.str2double = 1;
else
    w.str2double = 0;
end

c.online.ClassPair.TaskTask_Number = 3;   % Number of 2-class classification modules
if VA.f.SW.task_vs_relax_CP_used
    c.online.ClassPair.TaskRelax_Used = 1;
else
    c.online.ClassPair.TaskRelax_Used = 0;
end

% % c.online.subjectID = size(autorun.tt.used.subjects,2);
% % c.online.subject = autorun.tt.used.subjects(1,c.online.subjectID);
% % c.online.sessionID = size(autorun.tt.used.sessions,2);
% % c.online.session = autorun.tt.used.sessions(1,c.online.sessionID);

if VA.SW
    for wm_subDirID = 1 : size(VA.f.classSubDir,2)
        c.online.subject(1,wm_subDirID) = autorun_CP(wm_subDirID).tt.used.subjects(1,:);    % !!! THIS IS FOR SINGLE SUBJ-SESS BUT CAN BE COMBINED FROM MULTIPLE trainTest TASK_MANAGER !!! 
        c.online.session(1,wm_subDirID) = autorun_CP(wm_subDirID).tt.used.sessions(1,:);    % !!! THIS IS FOR SINGLE SUBJ-SESS BUT CAN BE COMBINED FROM MULTIPLE trainTest TASK_MANAGER !!! 
    end
else
    for wm_subDirID = 1 : size(VA.f.classSubDir,2)
        % % c.online.subjectID = 1 : size(autorun.tt.used.subjects,2);
        c.online.subject(1,:) = autorun.tt.used.subjects(1,:);        % !!! THIS IS FOR MULTI SUBJ-SESS BUT FROM THE SAME trainTest TASK_MANAGER !!! 
        % % c.online.sessionID = 1 : size(autorun.tt.used.sessions,2);
        c.online.session(1,:) = autorun.tt.used.sessions(1,:);        % !!! THIS IS FOR MULTI SUBJ-SESS BUT FROM THE SAME trainTest TASK_MANAGER !!! 
    end
end
c.online.outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0 = 0;

if VA.f.SW.task_vs_relax_CP_used == 0
    c.online.p.CF.substractedValue2_from_2ClassResults = [0;0;0];     % online.p.CF.baseline_of_2ClassResults(wm_targetClassID,1): baseline correction (this class specific value will be substracted from 2Class CF result)
else
    c.online.p.CF.substractedValue2_from_2ClassResults = [0;0;0;0];     % online.p.CF.baseline_of_2ClassResults(wm_targetClassID,1): baseline correction (this class specific value will be substracted from 2Class CF result)
end
c.online.p.CF.SW_2ClassResultNorm_notUsed0_autoBaseline1_specNorm2 = 0;     % (=0:notUsed, =1:autoBaseline, =2:specNorm(N/A))
c.online.p.CF.meanCurrent.wSize.ms = 200;    % used if online.p.CF.SW_2ClassResultNorm_notUsed0_autoBaseline1_specNorm2 == 1
c.online.p.CF.gapBetweenCurrentAndRefWindows.wSize.ms = 600;    % used if online.p.CF.SW_2ClassResultNorm_notUsed0_autoBaseline1_specNorm2 == 1
c.online.p.CF.meanReference.wSize.ms = 200;    % used if online.p.CF.SW_2ClassResultNorm_notUsed0_autoBaseline1_specNorm2 == 1

if VA.SW
    c.online.wt_taskOnset_cfWinOffset_ms = VA.c.eval.FBCSP_option_wt_taskOnset_cfWinOffset_ms;
else
    if VA.f.SW.task_vs_relax_CP_used == 0
        c.online.wt_taskOnset_cfWinOffset_ms = [1200;1200;1200];
    else
        c.online.wt_taskOnset_cfWinOffset_ms = [1200;1200;1200;1200];
    end


    % Dialog
    
    numLines=1;
    cellNames = {'Subjects (used for online setup):' ...
                 'Session (used for online setup):' ...
                 'Selected BCI setup (type outerFoldID OR 999:lastOuterFold OR 0:allMergedOuterFolds:' ...
                 'ClassPair1-3: Time between task onset and classification window offset [ms]:' ...
                 'CP1-3: Baseline correction for 2Class results (these values will be substracted for class 1..n):' ...
                 '2-Class resultNorm (=0:notUsed, =1:autoBaseline, =2:specNorm(N/A)):' ...
                 'FOR 2-Class resultNorm (=1:autoBaseline): current meanWin width (ms):' ...
                 'FOR 2-Class resultNorm (=1:autoBaseline): gap between currentWin and refWin (ms):' ...
                 'FOR 2-Class resultNorm (=1:autoBaseline): reference meanWin width (ms):' };
    default = { num2str(c.online.subject), ...
                num2str(c.online.session), ...
                num2str(c.online.outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0), ...
                num2str(transpose(c.online.wt_taskOnset_cfWinOffset_ms)), ...
                num2str(transpose(c.online.p.CF.substractedValue2_from_2ClassResults)), ...
                num2str(c.online.p.CF.SW_2ClassResultNorm_notUsed0_autoBaseline1_specNorm2), ...
                num2str(c.online.p.CF.meanCurrent.wSize.ms), ...
                num2str(c.online.p.CF.gapBetweenCurrentAndRefWindows.wSize.ms), ...
                num2str(c.online.p.CF.meanReference.wSize.ms) };
    w.m = inputdlg(cellNames,'Setup', numLines, default);
    if w.str2double == 1
      if ~isempty(w.m)         % Ha nem Cancel
        c.online.subject = str2double(cell2mat(w.m(1)));
        c.online.session = str2double(cell2mat(w.m(2)));
        c.online.outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0 = str2double(cell2mat(w.m(3)));
        c.online.wt_taskOnset_cfWinOffset_ms = transpose(str2double(cell2mat(w.m(4))));
        c.online.p.CF.substractedValue2_from_2ClassResults = transpose(str2double(cell2mat(w.m(5))));
        c.online.p.CF.SW_2ClassResultNorm_notUsed0_autoBaseline1_specNorm2 = str2double(cell2mat(w.m(6)));
        c.online.p.CF.meanCurrent.wSize.ms = str2double(cell2mat(w.m(7)));
        c.online.p.CF.gapBetweenCurrentAndRefWindows.wSize.ms = str2double(cell2mat(w.m(8)));
        c.online.p.CF.meanReference.wSize.ms = str2double(cell2mat(w.m(9)));
      end
    else
      if ~isempty(w.m)         % Ha nem Cancel
        c.online.subject = str2num(cell2mat(w.m(1)));
        c.online.session = str2num(cell2mat(w.m(2)));
        c.online.outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0 = str2num(cell2mat(w.m(3)));
        c.online.wt_taskOnset_cfWinOffset_ms = transpose(str2num(cell2mat(w.m(4))));
        c.online.p.CF.substractedValue2_from_2ClassResults = transpose(str2num(cell2mat(w.m(5))));
        c.online.p.CF.SW_2ClassResultNorm_notUsed0_autoBaseline1_specNorm2 = str2num(cell2mat(w.m(6)));
        c.online.p.CF.meanCurrent.wSize.ms = str2num(cell2mat(w.m(7)));
        c.online.p.CF.gapBetweenCurrentAndRefWindows.wSize.ms = str2num(cell2mat(w.m(8)));
        c.online.p.CF.meanReference.wSize.ms = str2num(cell2mat(w.m(9)));
      end
    end
end


% __________________________
% 
% Setup using previous setup
% __________________________

% c.prep.trial.trig_PRE_ms
% c.prep.trial.trig_PST_ms
% c.prep.EEG.downsamp.sr
% c.tt.cf.p.winSize.samp
% c.tt.cf.p.winSize.ms
% c.tt.cf.p.winStep.samp
% c.tt.cf.p.winStep.ms
% % w.wt0ID = ((-c.prep.trial.trig_PRE_ms-c.tt.cf.p.winSize.ms)/c.tt.cf.p.winStep.ms) +1;
% % w.wtID_used = w.wt0ID + fix(c.online.wt_taskOnset_cfWinOffset_ms/c.tt.cf.p.winStep.ms);


% 2-class CF post-processing
% __________________________

% Timer1=0.3        % required minimal hysteresis onset stability time (s)
% Timer2=0.01       % output class signal width in UDP (s)
% DeadbandDelay=4   % after an output class signal for this time the system is blocked
% upperOn=0.3
% upperOff=upperOn-0

if VA.f.SW.task_vs_relax_CP_used == 0
    wm = 0;
    c.online.p.CF_postProc.baseline = [wm;wm;wm];
    wm = 1;
    c.online.p.CF_postProc.baseAmp = [wm;wm;wm];

    wm = 0;
    % wm = 0.3;
    c.online.p.CF_postProc.hyster.class1_on = [wm;wm;wm];
    wm = 0;
    % wm = 0.3;
    c.online.p.CF_postProc.hyster.class1_off = [wm;wm;wm];
    wm = 0;
    % wm = 0.3;
    c.online.p.CF_postProc.hyster.class2_on = [wm;wm;wm];
    wm = 0;
    % wm = 0.3;
    c.online.p.CF_postProc.hyster.class2_off = [wm;wm;wm];
else
    wm = 0;
    c.online.p.CF_postProc.baseline = [wm;wm;wm;wm];
    wm = 1;
    c.online.p.CF_postProc.baseAmp = [wm;wm;wm;wm];

    wm = 0;
    % wm = 0.3;
    c.online.p.CF_postProc.hyster.class1_on = [wm;wm;wm;wm];
    wm = 0;
    % wm = 0.3;
    c.online.p.CF_postProc.hyster.class1_off = [wm;wm;wm;wm];
    wm = 0;
    % wm = 0.3;
    c.online.p.CF_postProc.hyster.class2_on = [wm;wm;wm;wm];
    wm = 0;
    % wm = 0.3;
    c.online.p.CF_postProc.hyster.class2_off = [wm;wm;wm;wm];
end

% Timer1:
c.online.p.CF_postProc.timer.hysterOnsetMin_sec = 0.3;
% Timer2:
% c.online.p.CF_postProc.timer.outClassWidth_sec = 0.01;
c.online.p.CF_postProc.timer.outClassWidth_sec = 0.1;
% Deadband:
c.online.p.CF_postProc.timer.deadband_sec = 2;




%% Code 2. Online setup preparation


% FUNC_IN prep for online_setup_prep_funct
% ________________________________________

FUNC_IN.VA = VA;

FUNC_IN.c = c;
FUNC_IN.c_CP = c_CP;
FUNC_IN.EEG_validation = EEG_validation;

FUNC_IN.wm_subjID2 = c.online.subject;      % !!! the called function handle only for one subject !!!
FUNC_IN.wm_sessionID2 = c.online.session;   % !!! the called function handle only for one session !!!

% % % % FUNC_IN.c_outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0 = c.online.outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0;
% % % % if FUNC_IN.c_outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0 ~= 0
% % % % % % % % % %     FUNC_IN.w0_matrix.outer_OR_outer_merged = w0_matrix.outer;
% % % %     FUNC_IN.w0_matrix(1).outer_OR_outer_merged = w0_matrix(1).outer;
% % % %     FUNC_IN.w0_matrix(2).outer_OR_outer_merged = w0_matrix(2).outer;
% % % %     FUNC_IN.w0_matrix(3).outer_OR_outer_merged = w0_matrix(3).outer;
% % % %     if VA.f.SW.task_vs_relax_CP_used
% % % %         FUNC_IN.w0_matrix(4).outer_OR_outer_merged = w0_matrix(4).outer;
% % % %     end
% % % % else
% % % % % % % % % %     FUNC_IN.w0_matrix.outer_OR_outer_merged = w0_matrix.outer_merged;
% % % %     FUNC_IN.w0_matrix(1).outer_OR_outer_merged = w0_matrix(1).outer_merged;
% % % %     FUNC_IN.w0_matrix(2).outer_OR_outer_merged = w0_matrix(2).outer_merged;
% % % %     FUNC_IN.w0_matrix(3).outer_OR_outer_merged = w0_matrix(3).outer_merged;
% % % %     if VA.f.SW.task_vs_relax_CP_used
% % % %         FUNC_IN.w0_matrix(4).outer_OR_outer_merged = w0_matrix(4).outer_merged;
% % % %     end
% % % % end
% % % % if FUNC_IN.c_outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0 == 0
% % % %     FUNC_IN.autorun_outerFoldID = 1;
% % % % elseif FUNC_IN.c_outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0 == 999
% % % % % % % % % %     FUNC_IN.autorun_outerFoldID = size(w0_matrix.outer.tt_param,3);
% % % %     FUNC_IN.autorun_outerFoldID(1) = size(w0_matrix(1).outer.tt_param,3);
% % % %     FUNC_IN.autorun_outerFoldID(2) = size(w0_matrix(2).outer.tt_param,3);
% % % %     FUNC_IN.autorun_outerFoldID(3) = size(w0_matrix(3).outer.tt_param,3);
% % % %     if VA.f.SW.task_vs_relax_CP_used
% % % %         FUNC_IN.autorun_outerFoldID(4) = size(w0_matrix(4).outer.tt_param,3);
% % % %     end
% % % % else
% % % %     FUNC_IN.autorun_outerFoldID = FUNC_IN.c_outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0;
% % % % end
FUNC_IN.c_outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0 = c.online.outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0;
if FUNC_IN.c_outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0 ~= 0
% % % % % %     FUNC_IN.w0_matrix.outer_OR_outer_merged = w0_matrix.outer;
    for wm_subDirID = 1 : size(w0_matrix,2)
        FUNC_IN.w0_matrix(wm_subDirID).outer_OR_outer_merged = w0_matrix(wm_subDirID).outer;
    end
else
% % % % % %     FUNC_IN.w0_matrix.outer_OR_outer_merged = w0_matrix.outer_merged;
    for wm_subDirID = 1 : size(w0_matrix,2)
        FUNC_IN.w0_matrix(wm_subDirID).outer_OR_outer_merged = w0_matrix(wm_subDirID).outer_merged;
    end
end
if FUNC_IN.c_outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0 == 0
    FUNC_IN.autorun_outerFoldID = 1;
elseif FUNC_IN.c_outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0 == 999
% % % % % %     FUNC_IN.autorun_outerFoldID = size(w0_matrix.outer.tt_param,3);
    for wm_subDirID = 1 : size(w0_matrix,2)
        FUNC_IN.autorun_outerFoldID(wm_subDirID) = size(w0_matrix(wm_subDirID).outer.tt_param,3);
    end
else
    FUNC_IN.autorun_outerFoldID = FUNC_IN.c_outerFoldID_or_lastOuterFold999_or_allMergedOuterFolds0;
end

FUNC_IN.c_wt_taskOnset_cfWinOffset_ms = c.online.wt_taskOnset_cfWinOffset_ms;
% FUNC_IN.c_wt_taskOnset_cfWinOffset_ms(1,1) = c.online.wt_taskOnset_cfWinOffset_ms(1,1);
% FUNC_IN.c_wt_taskOnset_cfWinOffset_ms(2,1) = c.online.wt_taskOnset_cfWinOffset_ms(2,1);
% FUNC_IN.c_wt_taskOnset_cfWinOffset_ms(3,1) = c.online.wt_taskOnset_cfWinOffset_ms(3,1);
% % % % w.wt0ID = ((-c.prep.trial.trig_PRE_ms-c.tt.cf.p.winSize.ms)/c.tt.cf.p.winStep.ms) +1;
% % % % % w.wtID_used = w.wt0ID + fix(FUNC_IN.c_wt_taskOnset_cfWinOffset_ms/c.tt.cf.p.winStep.ms);
% % % % % FUNC_IN.wtID = w.wtID_used;
% % % % FUNC_IN.wtID = w.wt0ID + fix(FUNC_IN.c_wt_taskOnset_cfWinOffset_ms/c.tt.cf.p.winStep.ms);
% % % % % FUNC_IN.wtID(1,1) = w.wt0ID + fix(FUNC_IN.c_wt_taskOnset_cfWinOffset_ms(1,1)/c.tt.cf.p.winStep.ms);
% % % % % FUNC_IN.wtID(2,1) = w.wt0ID + fix(FUNC_IN.c_wt_taskOnset_cfWinOffset_ms(2,1)/c.tt.cf.p.winStep.ms);
% % % % % FUNC_IN.wtID(3,1) = w.wt0ID + fix(FUNC_IN.c_wt_taskOnset_cfWinOffset_ms(3,1)/c.tt.cf.p.winStep.ms);

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% for wm_subDirID = 1 : size(VA.f.classSubDir,2)
%     w.wt0ID_CP(wm_subDirID) = ((-c_CP(wm_subDirID).prep.trial.trig_PRE_ms-c_CP(wm_subDirID).tt.cf.p.winSize.ms)/c_CP(wm_subDirID).tt.cf.p.winStep.ms) +1;
%     FUNC_IN.wtID(wm_subDirID) = w.wt0ID_CP(wm_subDirID) + fix(FUNC_IN.c_wt_taskOnset_cfWinOffset_ms(wm_subDirID)/c_CP(wm_subDirID).tt.cf.p.winStep.ms);
% end
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  % Load TAv2_TrainTest [result].mat and denote FUNC_IN.wtID(wm_subDirID)
  % _____________________________________________________________________
  
  % VA_TRANS.c.eval.FBCSP_option_wt_taskOnset_cfWinOffset_ms = T1_result_table(V1_TRANS.wm_taskID,1).taskPeak_ms;
  tmp = load([V1_TRANS.f.Input_T1_BaseDir,'\T1\Param\',V1_TRANS.tr_subDir_list{V1_TRANS.wm_taskID},'\TAv2_TrainTest [result].mat']);
  wm_subDirID = 1;
  FUNC_IN.wtID(wm_subDirID) = tmp.result.orig.opt_tt.task_wtID;
  clearvars tmp


% online_setup_prep_funct
% _______________________

online = CrossRun_VC_FBCSP_online_setup_prep_funct_01(FUNC_IN);
clearvars FUNC_IN







%% Code 3. Saving Results


% ________________________
%
% Autosave or Save results
% ________________________

if w.file.save.autosave == 1
        
        fprintf('\n');
        fprintf('Autosave (it may take some minutes):\n');

        fprintf('Saving config structure ...\n');
        copy_of_c = c;
        saveName = strcat( w.file.save.nameBasis1,' [c].mat');
        save([w.file.save.path,saveName],'copy_of_c','-v7.3');
        clear copy_of_c

% %         fprintf('Saving online structure ...\n');
% %         copy_of_online = online;
% %         saveName = strcat( w.file.save.nameBasis1,' [online].mat');
% %         save([w.file.save.path,saveName],'copy_of_online','-v7.3');
% %         clear copy_of_online
        fprintf('Saving online structure ...\n');
        saveName = strcat( w.file.save.nameBasis1,' [online].mat');
        save([w.file.save.path,saveName],'online','-v7.3');
        
        
end

fprintf('\n');
fprintf('Running: Finished\n\n');



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


%% Comments

% w0_matrix(1)
% w0_matrix(2)
% w0_matrix(3)
% 
% c.online.p.CF.substractedValue2_from_2ClassResults = [0;0;0];     % online.p.CF.baseline_of_2ClassResults(wm_targetClassID,1): baseline correction (this class specific value will be substracted from 2Class CF result)
% c.online.wt_taskOnset_cfWinOffset_ms = [1200;1200;1200];
% 
%     FUNC_IN.autorun_outerFoldID(1) = size(w0_matrix(1).outer.tt_param,3);
%     FUNC_IN.autorun_outerFoldID(2) = size(w0_matrix(2).outer.tt_param,3);
%     FUNC_IN.autorun_outerFoldID(3) = size(w0_matrix(3).outer.tt_param,3);
% 
% FUNC_IN.c_wt_taskOnset_cfWinOffset_ms = c.online.wt_taskOnset_cfWinOffset_ms;
% % FUNC_IN.c_wt_taskOnset_cfWinOffset_ms(1,1) = c.online.wt_taskOnset_cfWinOffset_ms(1,1);
% % FUNC_IN.c_wt_taskOnset_cfWinOffset_ms(2,1) = c.online.wt_taskOnset_cfWinOffset_ms(2,1);
% % FUNC_IN.c_wt_taskOnset_cfWinOffset_ms(3,1) = c.online.wt_taskOnset_cfWinOffset_ms(3,1);
% 
% FUNC_IN.wtID = w.wt0ID + fix(FUNC_IN.c_wt_taskOnset_cfWinOffset_ms/c.tt.cf.p.winStep.ms);
% % FUNC_IN.wtID(1,1) = w.wt0ID + fix(FUNC_IN.c_wt_taskOnset_cfWinOffset_ms(1,1)/c.tt.cf.p.winStep.ms);
% % FUNC_IN.wtID(2,1) = w.wt0ID + fix(FUNC_IN.c_wt_taskOnset_cfWinOffset_ms(2,1)/c.tt.cf.p.winStep.ms);
% % FUNC_IN.wtID(3,1) = w.wt0ID + fix(FUNC_IN.c_wt_taskOnset_cfWinOffset_ms(3,1)/c.tt.cf.p.winStep.ms);





