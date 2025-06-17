% Multi-class Classification, offline EEG trial validation 

% Input structures

% Output structures

% REQUIRESTMENT: Matlab
% Copyright(c)2019 Attila Korik, http://isrc.ulster.ac.uk/akorik/contact.html


%% Function headline

% % % % function FN_out = VA_C2019_A10B_offlineTrial_validation_01(FN_in)
% % % % FN_out = 'N/A';

if exist('VA','var')
   VA.SW = true;

% %     VA.set.w.switch.tr.allValid = 0;
else
   VA.SW = false;
end


%% Code 1. Data Loading

% clear; close all;

if VA.SW
    w.switch.tr.allValid = VA.set.w.switch.tr.allValid;
else
    % % w.switch.tr.allValid = 0;
    % w.switch.tr.allValid = 1;
    w.m = questdlg('Setup','Setup','trial validation','all valid','trial validation');
    if strcmp(w.m,'all valid')
        w.switch.tr.allValid = 1;
    else
        w.switch.tr.allValid = 0;
    end
end

% % % ______
% % % 
% % % Config
% % % ______
% % 
% % c.autorun.used.subjects = 1:10;
% % c.autorun.used.sessions = 1;
% % % c.autorun.used.sessions = 1:3;
% % 
% % c.EEG.import.chNumber = 30;
% % c.EEG.import.chIDs = 2 : c.EEG.import.chNumber+1;
% % 
% % c.EEG.rec.ch.name = {'F3';'F4';'FC5';'FC1';'FC2';'FC6';'C3';'CZ';'C4';'CP5';'CP1';'CP2';'CP6';'P3';'PZ';'P4'; ...
% %                      'AF3';'AF4';'F7';'FZ';'F8';'T7';'T8';'P7';'P8';'PO3';'PO4';'O1';'OZ';'O2';'EOGH';'EOGV'};
% % % c.EEG.rec.ch.name = {'F3';'F4';'FC5';'FC1';'FC2';'FC6';'C3';'CZ';'C4';'CP5';'CP1';'CP2';'CP6';'P3';'PZ';'P4'; ...
% % %                      'AF3';'AF4';'F7';'FZ';'F8';'T7';'T8';'P7';'P8';'PO3';'PO4';'O1';'OZ';'O2'};
% % c.EEG.rec.ch.ID = 1 : size(c.EEG.rec.ch.name,1);

% ______________
%
% Setup for load
% ______________

if VA.SW
    autorun.file.load.autoload = 1;
    if w.switch.tr.allValid == 0
        % EEG_rec
        autorun.file.load.path.EEG_rec = VA.set.autorun.f.load.path.EEG_rec;
        autorun.file.load.nameBasis.EEG_rec_fileName = 'EEG_rec.mat';
        
        % A09_EEG_validation_01
        autorun.file.load.path.EEG_validation = VA.set.autorun.f.load.path.EEG_validation;
        autorun.file.load.nameBasis1.EEG_validation = 'A09_EEG_validation_01';
    end
    
    % A10_offlineClass_prep_01
    autorun.file.load.path.offlineClass_prep = VA.set.autorun.f.load.path.offlineClass_prep;
    autorun.file.load.nameBasis1.offlineClass_prep = 'A10_offlineClass_prep_01';
else
    %This bit looks quite manual, maybe can delete?
    w.m = questdlg('Do you want to load input datasets ?','Setup','Select input directory','Continue without loading','Select input directory');
    if strcmp(w.m,'Select input directory')
        autorun.file.load.autoload = 1;

        if w.switch.tr.allValid == 0
            % EEG_rec
            autorun.file.load.path.EEG_rec = uigetdir('','Select input directory (EEG_rec)');
            % autorun.file.load.path.EEG_rec = [autorun.file.load.path.EEG_rec,'\'];
                VA.w.wm_subDirID = 1;
                VA.f.classSubDir{VA.w.wm_subDirID} = autorun.file.load.path.EEG_rec( max(find(autorun.file.load.path.EEG_rec(1,:)=='\'))+1 : size(autorun.file.load.path.EEG_rec,2));
                autorun.file.load.path.EEG_rec = autorun.file.load.path.EEG_rec( 1 : max(find(autorun.file.load.path.EEG_rec(1,:)=='u'))-2);
            autorun.file.load.nameBasis.EEG_rec_fileName = 'EEG_rec.mat';

            % A09_EEG_validation_01
            [autorun.file.load.nameBasis.EEG_validation, autorun.file.load.path.EEG_validation] = uigetfile(strcat('A09_EEG_validation_01 [config].mat'),'Load input dataset');
            autorun.file.load.nameBasis1.EEG_validation = autorun.file.load.nameBasis.EEG_validation( 1 : max(find(autorun.file.load.nameBasis.EEG_validation(1,:)=='['))-2);
        end

        % A10_offlineClass_prep_01
        [autorun.file.load.nameBasis.offlineClass_prep, autorun.file.load.path.offlineClass_prep] = uigetfile(strcat('A10_offlineClass_prep_01 [config].mat'),'Load input dataset');
        autorun.file.load.nameBasis1.offlineClass_prep = autorun.file.load.nameBasis.offlineClass_prep( 1 : max(find(autorun.file.load.nameBasis.offlineClass_prep(1,:)=='['))-2);
    else
        autorun.file.load.autoload = 0;
    end
end
if autorun.file.load.autoload == 1
    autorun.file.load.nameBasis1.offlineClass_prep_tr = 'tr';
end

% ______________
%
% Setup for save
% ______________

if VA.SW
    autorun.file.save.autosave = 1;
    autorun.file.save.path = VA.set.autorun.f.save.path;
else
    w.m = questdlg('Do you want to save result files ?','Setup','Auto save','Not save','Auto save');
    if strcmp(w.m,'Auto save')
        % [autorun.file.save.nameBasis, autorun.file.save.path] = uiputfile(strcat('D4_31_EEG_Bandpower_09.mat'),'Set up result directory and filename');
        % autorun.file.save.nameBasis1 = autorun.file.save.nameBasis( 1 : max(find(autorun.file.save.nameBasis(1,:)=='.'))-1);
        autorun.file.save.autosave = 1;

        autorun.file.save.path = uigetdir('','Set directory for the result');
        autorun.file.save.path = [autorun.file.save.path,'\'];

    % %     autorun.file.save.nameBasis.trial_validation = 'Shape5B_SC10_trial_validation_01';
    else
        autorun.file.save.autosave = 0;
    end
end



%% Load common dataset

  % _______________
  %
  % Loading Dataset
  % _______________

  if autorun.file.load.autoload == 1
    % fprintf('\n');
    
    % offlineClass_prep: autorun
    % fprintf('Loading A10_offlineClass_prep_01 [autorun].mat ...\n');
    w.file.load.name = [autorun.file.load.nameBasis1.offlineClass_prep, ' [autorun].mat'];
    fprintf(['Loading ',w.file.load.name,' ...\n']);
    load([autorun.file.load.path.offlineClass_prep,w.file.load.name]);
    autorun.prep = copy_of_autorun;
    clear copy_of_autorun
    
    % offlineClass_prep: EEG Config
    % fprintf('Loading A10_offlineClass_prep_01 [config].mat ...\n');
    w.file.load.name = [autorun.file.load.nameBasis1.offlineClass_prep, ' [config].mat'];
    fprintf(['Loading ',w.file.load.name,' ...\n']);
    load([autorun.file.load.path.offlineClass_prep,w.file.load.name]);
    c = copy_of_c;
    clear copy_of_c
    
    if w.switch.tr.allValid == 0
        
        % A09_EEG_validation_01: [EEG_validation] -> EEG_validation
        w.file.load.name = [autorun.file.load.nameBasis1.EEG_validation,' [EEG_validation].mat'];
        fprintf(['Loading ',w.file.load.name,' ...\n']);
        load([autorun.file.load.path.EEG_validation, w.file.load.name]);
        EEG_validation = copy_of_EEG_validation;
        clear copy_of_EEG_validation
    end
    
    % fprintf('Dataset loading: DONE\n');
    % fprintf('\n');
    
  end
  
  
%% Autorun

% _______
% 
% Autorun
% _______

TRANS.c = c;
TRANS.autorun = autorun;
TRANS.w = w;
clearvars config autorun w;

tic

% for autorun_subjID2 = TRANS.c.autorun.used.subjects
%  for autorun_sessionID2 = TRANS.c.autorun.used.sessions
for autorun_subjID2 = TRANS.autorun.prep.prep.used.subjects
 for autorun_sessionID2 = TRANS.autorun.prep.prep.used.sessions
      
  % clearvars -except STACK TRANS autorun_subjID2 autorun_sessionID2 EEG_validation tr_validMask
  clearvars -except STACK VA_TRANS VA TRANS autorun_subjID2 autorun_sessionID2 EEG_validation tr_validMask
  
  c = TRANS.c;
  autorun = TRANS.autorun;
  w = TRANS.w;
  
  wm_subjID2 = autorun_subjID2;
  wm_sessionID2 = autorun_sessionID2;
  
  fprintf(['SubjID2: ',num2str(wm_subjID2),'/',num2str(size(autorun.prep.prep.used.subjects,2)), ...
           ', SessionID2: ',num2str(wm_sessionID2),'/',num2str(size(autorun.prep.prep.used.sessions,2)),'\n'])
  
  % ____________________
  % 
  % EEG Trial validation
  % ____________________
  
  if w.switch.tr.allValid == 1

    % ______________________
    % 
    % ALL trial valid option
    % ______________________
    
    % _______________
    %
    % Loading Dataset
    % _______________

    if autorun.file.load.autoload == 1
        % fprintf('\n');

        % offlineClass_prep: tr{autorun_subjID2,autorun_sessionID2}
        % fprintf('Loading tr{',num2str(autorun_subjID2),',',num2str(autorun_sessionID2),'}.mat ...\n');
        w.file.load.name = [autorun.file.load.nameBasis1.offlineClass_prep_tr,'{',num2str(wm_subjID2),',',num2str(wm_sessionID2),'}.mat'];
        fprintf(['Loading ',w.file.load.name,' ...\n']);
        load([autorun.file.load.path.offlineClass_prep, w.file.load.name]);
        tr{wm_subjID2,wm_sessionID2} = copy_of_tr{wm_subjID2,wm_sessionID2};
        clear copy_of_tr

        fprintf('Dataset loading: DONE\n');
        fprintf('\n');
    end
    
    % tr_validMask{wm_subjID2,wm_sessionID2}(wm_classID,wm_trialID)
    wm_bandID=1; wm_targetID=1;     % any as same for each band and if allValid also same for any target(i.e., class)
    tr_validMask{wm_subjID2,wm_sessionID2} = ones(size(c.prep.experiment.target.IDs,2), size(tr{wm_subjID2,wm_sessionID2}{wm_bandID,wm_targetID},3));
    % tr_validMask{wm_subjID2,wm_sessionID2} = ones(size(tr{wm_subjID2,wm_sessionID2},2), size(tr{wm_subjID2,wm_sessionID2}{wm_bandID,wm_targetID},3));

  else
    % ______________________
    % 
    % Trial validation option
    % _______________________
   
    % _______________
    %
    % Loading Dataset
    % _______________

    if autorun.file.load.autoload == 1
        % fprintf('\n');

        % EEG record
        % w.file.load.path = [autorun.file.load.path.EEG_rec,'Subj 0',num2str(autorun_subjID2),'\Session 0',num2str(autorun_sessionID2),'\01 Rec\'];
        % w.file.load.path = [autorun.file.load.path.EEG_rec,'Subj ',subFunc_num2str_2digit(autorun_subjID2),'\Session ',subFunc_num2str_2digit(autorun_sessionID2),'\01 Rec\'];
        w.file.load.path = [autorun.file.load.path.EEG_rec,'Subj ',subFunc_num2str_2digit(autorun_subjID2),'\Session ',subFunc_num2str_2digit(autorun_sessionID2),'\',VA.f.classSubDir{VA.w.wm_subDirID},'\'];
        fprintf(['Loading EEG_rec dataset ...\n']);
        w.file.load.name = autorun.file.load.nameBasis.EEG_rec_fileName;
        load([w.file.load.path,w.file.load.name]);
        w.import.EEG_rec = EEG_rec;
        clear EEG_rec

        fprintf('Dataset loading: DONE\n');
        fprintf('\n');
    end
  
    w.wm_loop = 0;
    w.figure.setup.scrsz = get(0,'ScreenSize');
    w.figure.ID = figure('Position',[1,1,w.figure.setup.scrsz(3),w.figure.setup.scrsz(4)]);
    
    % Data slicing
    % ____________
    
    % w_tr{1,wm_classID}(wk,wt,wm_trialID)
    w_tr = subFunc_EEG_slicing_and_downsamp(c, w.import.EEG_rec(c.prep.EEG.import.chIDs,:), w.import.EEG_rec(c.prep.EEG.import.trigCh,:));
     
    % tr_validMask{wm_subjID2,wm_sessionID2}(wm_classID,wm_trialID)
    wm_classID = 1;     % any class here as same for each class
    tr_validMask{wm_subjID2,wm_sessionID2} = ones(size(w_tr,2), size(w_tr{1,wm_classID},3));
    
    % Trial validation
    % ________________
    
    % for wm_classID = c.prep.experiment.target.IDs
    % for wm_classID = 1 : size(tr{wm_subjID2,wm_sessionID2},2)
    % % for wm_classID = 1 : size(w_tr,2)
    % %  for wm_trialID = 1 : size(w_tr{1,wm_classID},3)
    wm_classID = 0;
    w.wm_loop = 1;
    while wm_classID < size(w_tr,2)
     if w.wm_loop == -2
        wm_classID = wm_classID -1;
        wm_trialID = size(w_tr{1,wm_classID},3) -1;
        w.wm_loop = 1;
     else
        wm_classID = wm_classID +1;
        wm_trialID = 0;
     end
     while (wm_trialID < size(w_tr{1,wm_classID},3)) && ...
           (w.wm_loop ~= -2)
      wm_trialID = wm_trialID +1;
         
        plot(w_tr{1,wm_classID}(EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID, :, wm_trialID)');
        line([-((c.prep.trial.trig_PRE_ms/1000)*c.prep.EEG.downsamp.sr)+1, -((c.prep.trial.trig_PRE_ms/1000)*c.prep.EEG.downsamp.sr)+1], ...
             [min(min(w_tr{1,wm_classID}(EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID, :, wm_trialID))), max(max(w_tr{1,wm_classID}(EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID, :, wm_trialID)))], ...
             'LineWidth',4,'LineStyle','--','Color',[0,0,0]);
        title(['Subject',num2str(wm_subjID2),', Session',num2str(wm_sessionID2),', class',num2str(wm_classID),', trial',num2str(wm_trialID)])
        xlim([1,size(w_tr{1,wm_classID},2)])
        xticks(1 : c.prep.EEG.downsamp.sr : size(w_tr{1,wm_classID},2))
        xticklabels(num2cell((c.prep.trial.trig_PRE_ms/1000) : 1 : c.prep.trial.trig_PST_ms/1000))
        % % % % xlabel('time (ms)')
        % % % % ylabel('Amplitude')
        % ylim([10,40])
        % ylim([PLOT.w.averagedSubjSession_ylim])
        if w.wm_loop == 1
            w.wm_loop = 0;
        end
        while w.wm_loop == 0
          w.wm2 = getkey;
         if w.wm2 == 28         % 28: left arrow (<-) = valid
            tr_validMask{wm_subjID2,wm_sessionID2}(wm_classID,wm_trialID) = 1;
            w.wm_loop = 1;
          elseif w.wm2 == 29     % 29: right arrow (->) invalid
            tr_validMask{wm_subjID2,wm_sessionID2}(wm_classID,wm_trialID) = 0;
            w.wm_loop = 1;
          elseif w.wm2 == 8      % 8: backspace = go back to the previous plot
            if wm_trialID > 1
                wm_trialID = wm_trialID -2;
                w.wm_loop = 1;
            elseif wm_classID == 1
                wm_trialID = wm_trialID -1;
                w.wm_loop = 1;
            else
                w.wm_loop = -2;
            end
          elseif w.wm2 == 27    % 27: "ESC"
              w.wm_loop = -1;
          end
        end
        if w.wm_loop == -1
            break
        end
         
         
     end
    end
    close(w.figure.ID)
    
  end
  
 end
end

% % % % c_for_validation = c;
% % % % % Manual save: c_for_validation trial_validation

% _________
% 
% AUTO SAVE
% _________

% c = TRANS.c;                % save this
% autorun = TRANS.autorun;    % save this
if autorun.file.save.autosave == 1
    fprintf('Saving tr_validMask structure ...\n');
    copy_of_tr__validMask = tr_validMask;
    w.file.save.name = ['tr_validMask.mat'];
    save([autorun.file.save.path,w.file.save.name],'copy_of_tr__validMask','-v7.3');
    clear copy_of_tr__validMask
end


fprintf('\n');
fprintf('Running: Finished\n\n');

% toc


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

function wf_tr = subFunc_EEG_slicing_and_downsamp(c, EEG_data, EEG_trig)

    % Data slicing
    % ____________
    
    wf.TRIG = gettrigger(EEG_trig(1,:) ,0); % trigger at ascending edge
    % [wf.X, wf.sz] = trigg(transpose(EEG_data(:,:)), wf.TRIG, fix(c.prep.trial.trig_PRE_ms/1000*c.prep.EEG.rec.sr), fix(c.prep.trial.trig_PST_ms/1000*c.prep.EEG.rec.sr));
    [wf.X, wf.sz] = trigg(transpose(EEG_data(:,:)), wf.TRIG, fix(c.prep.trial.trig_PRE_ms/1000*c.prep.EEG.rec.sr), fix(c.prep.trial.trig_PST_ms/1000*c.prep.EEG.rec.sr)+1);
    wf.X3D = reshape(wf.X, wf.sz);
    for wf_wm = c.prep.experiment.target.IDs
        % wf_tr{wf_wm} = wf.X3D(:,:,EEG_trig(1,wf.TRIG)==wf_wm);    % for: without downsamp option
        wf_w_tr{wf_wm} = wf.X3D(:,:,EEG_trig(1,wf.TRIG)==wf_wm);
    end

    % Downsampling
    % ____________
    
    if c.prep.EEG.rec.sr == c.prep.EEG.downsamp.sr
        wf_tr = wf_w_tr;
    else
      for wf_wm = c.prep.experiment.target.IDs
        wf_tr{wf_wm} = wf_w_tr{wf_wm}(:, find(mod(1:size(wf_w_tr{wf_wm},2), c.prep.EEG.rec.sr/c.prep.EEG.downsamp.sr)==0), :);
      end
    end

end


% % % % %% Function end
% % % % end


%% Comments

% Left arrow  (<-) : valid
% Right arrow (->) : invalid

% ESC: break with NaN










