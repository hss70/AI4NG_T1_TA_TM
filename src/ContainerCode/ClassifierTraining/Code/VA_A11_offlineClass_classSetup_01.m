% Multi-class Classification, offline EEG class setup

% Input structures
% tr{wm_subjID2,wm_sessionID2}{wm_bandID,wm_targetID}(wk,wt,wm_trialID)

% Output structures

% REQUIRESTMENT: Matlab
% Copyright(c)2019 Attila Korik, http://isrc.ulster.ac.uk/akorik/contact.html


%% Function headline

% % % % function FN_out = VA_C2019_A11_offlineClass_classSetup_01(FN_in)
% % % % FN_out = 'N/A';

if exist('VA','var')
   VA.SW = true;
else
   VA.SW = false;
end


%% Code 1. Data Loading

% clear; close all;

% _________________
%
% Parfor Core Setup
% _________________

% % w.parCore.location = 'local';
% % % w.parCore.location = 'HPCServerProfile1';
% % % w.parCore.number = 0;
% % w.parCore.number = 4;
% % w.parCore.reOpenIfOpen = 0;      % =1:close and open with w.parCore.number at start, =0:keep open with the same workers if open 
% % w.parCore.closeAtEnd = 0;        % =1:close parpool after run, =0:keep open parpool after run 
% % % w.parCore.lastCheckedStatus = gcp('nocreate'); % If no pool, do not create new one.
% % if w.parCore.number ~= 0
% %   if isempty(gcp('nocreate')) || (w.parCore.reOpenIfOpen == 1)
% %     delete(gcp('nocreate'))     % parpool close
% %     parpool (w.parCore.location, w.parCore.number)       % open cores
% %   end
% % end



% ______
% 
% Config
% ______

% % % Class setup (2-class): 5 Shapes
% % c.classSetup.class.classDescription{1,1} = 'Sphere';
% % c.classSetup.class.classDescription{2,1} = 'Cone';
% % c.classSetup.class.classDescription{3,1} = 'Pyramid';
% % c.classSetup.class.classDescription{4,1} = 'Cylinder';
% % c.classSetup.class.classDescription{5,1} = 'Cube';
% % c.classSetup.class.targetIDs_linkedTo_classID{1,1} = 1;      % trials with these targetIDs involved in this class
% % c.classSetup.class.targetIDs_linkedTo_classID{2,1} = 2;      % trials with these targetIDs involved in this class
% % c.classSetup.class.targetIDs_linkedTo_classID{3,1} = 3;      % trials with these targetIDs involved in this class
% % c.classSetup.class.targetIDs_linkedTo_classID{4,1} = 4;      % trials with these targetIDs involved in this class
% % c.classSetup.class.targetIDs_linkedTo_classID{5,1} = 5;      % trials with these targetIDs involved in this class
% Class setup (2-class): 5 Shapes
c.classSetup.class.classDescription{1,1} = 'T1';
c.classSetup.class.classDescription{2,1} = 'T2';
c.classSetup.class.targetIDs_linkedTo_classID{1,1} = 1;      % trials with these targetIDs involved in this class
c.classSetup.class.targetIDs_linkedTo_classID{2,1} = 2;      % trials with these targetIDs involved in this class
% % % Class setup (2-class): Spec example
% % c.classSetup.class.classDescription{1,1} = 'Sphere & Cube';
% % c.classSetup.class.classDescription{2,1} = 'Cone & Pyramid';
% % c.classSetup.class.targetIDs_linkedTo_classID{1,1} = [1,5];      % trials with these targetIDs involved in this class
% % c.classSetup.class.targetIDs_linkedTo_classID{2,1} = [2,3];      % trials with these targetIDs involved in this class

if VA.SW
    c.classSetup.band.usedIDs = VA.c.classSetup.band.usedIDs;
else
    c.classSetup.band.usedIDs = 1:6;         % from preprocessed EEG data with these bandIDs will be used for trainTest
    % c.classSetup.band.usedIDs = 1:4;         % from preprocessed EEG data with these bandIDs will be used for trainTest
    % c.classSetup.band.usedIDs = 3:6;         % from preprocessed EEG data with these bandIDs will be used for trainTest
end

% % c.classSetup.trial.used_runIDs = 1 : c.experiment.run.number;    % these runs selected for each class 
% c.classSetup.trial.used_runIDs = 1:6;        % these runs selected for each class 



% ______________________
%
% Trial validation setup
% ______________________

if VA.SW
    w.switch.tr.allValid = VA.set.w.switch.tr.allValid;
else
    w.m = questdlg('Used trials','Setup','valid trials','all trials','valid trials');
    if strcmp(w.m,'all trials')
        w.switch.tr.allValid = 1;
    else
        w.switch.tr.allValid = 0;
    end
end

% ______________
%
% Setup for load
% ______________

if VA.SW
    autorun.classSetup.file.load.autoload = 1;
    % A10_offlineClass_prep_01
    autorun.classSetup.file.load.path.offlineClass_prep = VA.set.autorun.f.load.path.offlineClass_prep;
    autorun.classSetup.file.load.nameBasis1.offlineClass_prep = 'A10_offlineClass_prep_01';
    if w.switch.tr.allValid == 0
        % A10B_offlineTrial_validation_01
        autorun.classSetup.file.load.path.tr_validMask = VA.set.autorun.f.load.path.tr_validMask;
        autorun.classSetup.file.load.nameBasis1.tr_validMask = 'tr_validMask.mat';
    end
else
    % % w.m = questdlg('Do you want to load input datasets ?','Setup','Select input directory','Load from default directory','Continue without loading','Select input directory');
    % % if strcmp(w.m,'Load from default directory')
    % %     autorun.classSetup.file.load.autoload = 1;
    % %     
    % %     % A10_offlineClass_prep_01
    % %     autorun.classSetup.file.load.nameBasis1.offlineClass_prep = 'A10_offlineClass_prep_01';
    % %     autorun.classSetup.file.load.path.offlineClass_prep = 'Q:\BCI\Results\Shape 5B SC\SC10 offlineClass EEG prep\noRef 6x6Hz_in_4-40Hz\';
    % %     % autorun.classSetup.file.load.path.offlineClass_prep = 'Q:\BCI\Results\Shape 5B SC\SC10 offlineClass EEG prep\CAR (using validCh) 6x6Hz_in_4-40Hz\';
    % %     
    % %     % % % A09_EEG_validation_01
    % %     % % autorun.classSetup.file.load.nameBasis1.EEG_validation = 'A09_EEG_validation_01';
    % %     % % autorun.classSetup.file.load.path.EEG_validation = 'Q:\BCI\Results\Shape 5B SC\SC09 EEG ch validation\allValid\';
    % %     % % % autorun.classSetup.file.load.path.EEG_validation = 'Q:\BCI\Results\Shape 5B SC\SC09 EEG ch validation\validEEG\';
    % % elseif strcmp(w.m,'Select input directory')
    w.m = questdlg('Do you want to load input datasets ?','Setup','Select input directory','Continue without loading','Select input directory');
    if strcmp(w.m,'Select input directory')
        autorun.classSetup.file.load.autoload = 1;

        % A10_offlineClass_prep_01
        [autorun.classSetup.file.load.nameBasis.offlineClass_prep, autorun.classSetup.file.load.path.offlineClass_prep] = uigetfile(strcat('A10_offlineClass_prep_01 [config].mat'),'Load input dataset');
        autorun.classSetup.file.load.nameBasis1.offlineClass_prep = autorun.classSetup.file.load.nameBasis.offlineClass_prep( 1 : max(find(autorun.classSetup.file.load.nameBasis.offlineClass_prep(1,:)=='['))-2);

        if w.switch.tr.allValid == 0
            % A10B_offlineTrial_validation_01
            [autorun.classSetup.file.load.nameBasis.tr_validMask, autorun.classSetup.file.load.path.tr_validMask] = uigetfile(strcat('tr_validMask.mat'),'Load input dataset');
            autorun.classSetup.file.load.nameBasis1.tr_validMask = autorun.classSetup.file.load.nameBasis.tr_validMask;
        end

        % % % A09_EEG_validation_01
        % % [autorun.classSetup.file.load.nameBasis.EEG_validation, autorun.classSetup.file.load.path.EEG_validation] = uigetfile(strcat('A09_EEG_validation_01 [config].mat'),'Load input dataset');
        % % autorun.classSetup.file.load.nameBasis1.EEG_validation = autorun.classSetup.file.load.nameBasis.EEG_validation( 1 : max(find(autorun.classSetup.file.load.nameBasis.EEG_validation(1,:)=='['))-2);
    else
        autorun.classSetup.file.load.autoload = 0;
    end
end
if autorun.classSetup.file.load.autoload == 1
    autorun.classSetup.file.load.nameBasis1.offlineClass_prep_tr = 'tr';
end

% % % _______________
% % %
% % % Loading Dataset
% % % _______________
% % 
% % if autorun.classSetup.file.load.autoload == 1
% %     fprintf('\n');
% %     
% %     % EEG validation
% %     % fprintf('Loading A09_EEG_validation_01 [EEG_validation].mat ...\n');
% %     w.file.load.name = [autorun.classSetup.file.load.nameBasis1.EEG_validation, ' [EEG_validation].mat'];
% %     fprintf(['Loading',w.file.load.name,' ...\n']);
% %     load([autorun.classSetup.file.load.path.validation,w.file.load.name]);
% %     EEG_validation = copy_of_EEG_validation;
% %     clear copy_of_EEG_validation
% %     
% %     fprintf('Dataset loading: DONE\n');
% %     fprintf('\n');
% % end
  
% ______________
%
% Setup for save
% ______________

if VA.SW
    autorun.classSetup.file.save.autosave = 1;
    autorun.classSetup.file.save.path = VA.set.autorun.f.save.path;
    autorun.classSetup.file.save.nameBasis.A11_offlineClass_classSetup = 'A11_offlineClass_classSetup_01';
    autorun.classSetup.file.save.nameBasis.A11_offlineClass_classSetup__classTrials = 'classTrials';
else
    w.m = questdlg('Do you want to save result files ?','Setup','Auto save','Not save','Auto save');
    if strcmp(w.m,'Auto save')
        autorun.classSetup.file.save.autosave = 1;

        autorun.classSetup.file.save.path = uigetdir('','Set directory for the result');
        autorun.classSetup.file.save.path = [autorun.classSetup.file.save.path,'\'];

        autorun.classSetup.file.save.nameBasis.A11_offlineClass_classSetup = 'A11_offlineClass_classSetup_01';

        autorun.classSetup.file.save.nameBasis.A11_offlineClass_classSetup__classTrials = 'classTrials';
    else
        autorun.classSetup.file.save.autosave = 0;
    end
end



%% Load common dataset

  % _______________
  %
  % Loading Dataset
  % _______________
  
  w.c.classSetup = c.classSetup;

  if autorun.classSetup.file.load.autoload == 1
    % fprintf('\n');
    
    % offlineClass_prep: autorun
    % fprintf('Loading A10_offlineClass_prep_01 [autorun].mat ...\n');
    w.file.load.name = [autorun.classSetup.file.load.nameBasis1.offlineClass_prep, ' [autorun].mat'];
    fprintf(['Loading ',w.file.load.name,' ...\n']);
    load([autorun.classSetup.file.load.path.offlineClass_prep,w.file.load.name]);
    autorun.prep = copy_of_autorun.prep;
    clear copy_of_autorun
    
    % offlineClass_prep: EEG Config
    % fprintf('Loading A10_offlineClass_prep_01 [config].mat ...\n');
    w.file.load.name = [autorun.classSetup.file.load.nameBasis1.offlineClass_prep, ' [config].mat'];
    fprintf(['Loading ',w.file.load.name,' ...\n']);
    load([autorun.classSetup.file.load.path.offlineClass_prep,w.file.load.name]);
    c = copy_of_c;
    clear copy_of_c
    c.classSetup = w.c.classSetup;
    
    if w.switch.tr.allValid == 0
        % Shape5B_SC10B_offlineTrial_validation_01
        w.file.load.name = autorun.classSetup.file.load.nameBasis1.tr_validMask;
        fprintf(['Loading ',w.file.load.name,' ...\n']);
        load([autorun.classSetup.file.load.path.tr_validMask, w.file.load.name]);
        tr_validMask = copy_of_tr__validMask;
        clear copy_of_tr__validMask
    end
    
    % fprintf('Dataset loading: DONE\n');
    % fprintf('\n');
    
  end
  
  
% autorun.classSetup.used.subjects = 1:10;
% autorun.classSetup.used.sessions = 1:1;
% % autorun.classSetup.used.subjects = [2,5,11];
% % autorun.classSetup.used.sessions = 1:3;
autorun.classSetup.used.subjects = autorun.prep.used.subjects;
autorun.classSetup.used.sessions = autorun.prep.used.sessions;



  
%% Autorun

% _______
% 
% Autorun
% _______

TRANS.w.switch.tr.allValid = w.switch.tr.allValid;
TRANS.c = c;
TRANS.autorun = autorun;
% % TRANS.EEG_validation = EEG_validation;
clearvars c autorun

tic

for autorun_subjID2 = TRANS.autorun.classSetup.used.subjects
 for autorun_sessionID2 = TRANS.autorun.classSetup.used.sessions
      
  % clearvars -except STACK TRANS autorun_subjID2 autorun_sessionID2 tr_validMask
  clearvars -except STACK VA_TRANS VA TRANS autorun_subjID2 autorun_sessionID2 tr_validMask
  
  w.switch.tr.allValid = TRANS.w.switch.tr.allValid;
  % c = TRANS.c;
  c.prep = TRANS.c.prep;
  c.classSetup = TRANS.c.classSetup;
  autorun = TRANS.autorun;
  % % EEG_validation = TRANS.EEG_validation;
  
  wm_subjID2 = autorun_subjID2;
  wm_sessionID2 = autorun_sessionID2;
  
    fprintf(['SubjID2: ',num2str(wm_subjID2),'/',num2str(size(TRANS.autorun.classSetup.used.subjects,2)), ...
             ', SessionID2: ',num2str(wm_sessionID2),'/',num2str(size(TRANS.autorun.classSetup.used.sessions,2)),'\n'])

  % _______________
  %
  % Loading Dataset
  % _______________

  if autorun.classSetup.file.load.autoload == 1
    % fprintf('\n');
    
    % offlineClass_prep: tr{autorun_subjID2,autorun_sessionID2}
    % fprintf('Loading tr{',num2str(autorun_subjID2),',',num2str(autorun_sessionID2),'}.mat ...\n');
    w.file.load.name = [autorun.classSetup.file.load.nameBasis1.offlineClass_prep_tr,'{',num2str(wm_subjID2),',',num2str(wm_sessionID2),'}.mat'];
    fprintf(['Loading ',w.file.load.name,' ...\n']);
    load([autorun.classSetup.file.load.path.offlineClass_prep,w.file.load.name]);
    tr{wm_subjID2,wm_sessionID2} = copy_of_tr{wm_subjID2,wm_sessionID2};
    clear copy_of_tr
    
    % fprintf('Dataset loading: DONE\n');
    % fprintf('\n');
    
  end

  % c.classSetup = TRANS.c.classSetup;
  
  % _______________________
  %
  % Class Trial Preparation
  % _______________________
  
  % Input:
  % c.classSetup.class.targetIDs_linkedTo_classID{wm_classID,1}(1,wm_targetID)
  % c.classSetup.band.usedIDs(1,wm_bandID) 
  % tr{wm_subjID2,wm_sessionID2}{wm_bandID,wm_targetID}(wk,wt,wm_trialID)

  % Output:
  % classTrials{wm_subjID2,wm_sessionID2}{wm_class, wm_bandID}(wm_trialID, wk, wt)
  
  for wm_classID = 1 : size(c.classSetup.class.targetIDs_linkedTo_classID,1)
   for wm_bandID = c.classSetup.band.usedIDs
    wm_trialID2 = 0;
    for wm_targetID2 = 1 : size(c.classSetup.class.targetIDs_linkedTo_classID{wm_classID,1},2)
      wm_targetID = c.classSetup.class.targetIDs_linkedTo_classID{wm_classID,1}(1,wm_targetID2);
      % for wm_run = c.classSetup.trial.used_runIDs
      for wm_trialID = 1 : size(tr{wm_subjID2,wm_sessionID2}{wm_bandID,wm_targetID},3)
          wm_trialID2 = wm_trialID2 +1;
          % classTrials{wm_subjID2,wm_sessionID2}{wm_classID, wm_bandID}(wm_trialID2,:,:) = ...
          classTrials_allTrials{wm_subjID2,wm_sessionID2}{wm_classID, wm_bandID}(wm_trialID2,:,:) = ...
              tr{wm_subjID2,wm_sessionID2}{wm_bandID,wm_targetID}(:,:,wm_trialID);
      end
      % end
    end
   end
  end
  clearvars tr
  
  % valid trial selectoin
  % _____________________
  
  if w.switch.tr.allValid == 1
      classTrials_validTrials = classTrials_allTrials;
  else
   for wm_classID = 1 : size(c.classSetup.class.targetIDs_linkedTo_classID,1)
    for wm_bandID = c.classSetup.band.usedIDs
      classTrials_validTrials{wm_subjID2,wm_sessionID2}{wm_classID, wm_bandID} = ...
          classTrials_allTrials{wm_subjID2,wm_sessionID2}{wm_classID, wm_bandID}( tr_validMask{wm_subjID2,wm_sessionID2}(wm_classID,:)==1, :, : );
    end
   end
  end
  clearvars classTrials_allTrials
  
  
  % _________
  % 
  % AUTO SAVE
  % _________
  
  if autorun.classSetup.file.save.autosave == 1
    % fprintf('Saving classTrials{SubjID2,SessionID2} structure ...\n');
    fprintf(['Saving classTrials{',num2str(wm_subjID2),',',num2str(wm_sessionID2),'} structure ...\n']);
    % copy_of_classTrials = classTrials;
    copy_of_classTrials = classTrials_validTrials;
    w.file.save.name = [autorun.classSetup.file.save.nameBasis.A11_offlineClass_classSetup__classTrials,'{',num2str(wm_subjID2),',',num2str(wm_sessionID2),'}.mat'];
    save([autorun.classSetup.file.save.path,w.file.save.name],'copy_of_classTrials','-v7.3');
    clear copy_of_classTrials
    
    fprintf('\n');
  end
  
 end
end

% _________
% 
% AUTO SAVE
% _________

% c = TRANS.c;                % save this
% autorun = TRANS.autorun;    % save this
if autorun.classSetup.file.save.autosave == 1
    fprintf('Saving config structure ...\n');
    % copy_of_c = TRANS.c;
    copy_of_c = c;
    w.file.save.name = [autorun.classSetup.file.save.nameBasis.A11_offlineClass_classSetup, ' [config].mat'];
    save([autorun.classSetup.file.save.path,w.file.save.name],'copy_of_c','-v7.3');
    clear copy_of_c
    
    fprintf('Saving autorun structure ...\n');
    % copy_of_autorun = TRANS.autorun;
    copy_of_autorun = autorun;
    w.file.save.name = [autorun.classSetup.file.save.nameBasis.A11_offlineClass_classSetup, ' [autorun].mat'];
    save([autorun.classSetup.file.save.path,w.file.save.name],'copy_of_autorun','-v7.3');
    clear copy_of_autorun
end


fprintf('\n');
fprintf('Running: Finished\n\n');

toc



% % % % %% Function end
% % % % end


%% Comments

% % % __________
% % %
% % % Dialog box
% % % __________
% % 
% %     if ~isnan(str2double('1;2;3'))
% %         w.str2double = 1;
% %     else
% %         w.str2double = 0;
% %     end
% % 
% % TRANS.config.fix.EEG.refFilter.usedMethod.non0_CAR1_Laplace2 = 1;      % used reference filter: =0:notUsed, =1:CAR, ((=2:Laplace))
% % TRANS.config.fix.EEG.features.usedFeature_bandpass1_bandpower2 = 1;
% % 
% %     numLines=1;
% %     cellNames = {'Used EEG feature (=1:bandpass filter, =2:bandpower):', ...
% %                  'Reference filter: =0:withoutRefFilt =1:CAR, ((=2:Laplace (N/A)))'};
% %     default = { num2str(TRANS.config.fix.EEG.features.usedFeature_bandpass1_bandpower2), ...
% %                 num2str(TRANS.config.fix.EEG.refFilter.usedMethod.non0_CAR1_Laplace2) };
% %     w.m = inputdlg(cellNames,'Setup', numLines, default);
% %     if w.str2double == 1
% %       if ~isempty(w.m)         % Ha nem Cancel
% %         TRANS.config.fix.EEG.features.usedFeature_bandpass1_bandpower2 = str2double(cell2mat(w.m(1)));
% %         TRANS.config.fix.EEG.refFilter.usedMethod.non0_CAR1_Laplace2 = str2double(cell2mat(w.m(2)));
% %       end
% %     else
% %       if ~isempty(w.m)         % Ha nem Cancel
% %         TRANS.config.fix.EEG.features.usedFeature_bandpass1_bandpower2 = str2num(cell2mat(w.m(1)));
% %         TRANS.config.fix.EEG.refFilter.usedMethod.non0_CAR1_Laplace2 = str2num(cell2mat(w.m(2)));
% %       end
% %     end




