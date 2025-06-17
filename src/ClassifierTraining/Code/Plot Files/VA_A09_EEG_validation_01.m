% Multi-class Classification, offline EEG channel validation 

% Input structures

% Output structures

% REQUIRESTMENT: Matlab
% Copyright(c)2019 Attila Korik, http://isrc.ulster.ac.uk/akorik/contact.html


%% Function headline

% % % % function VA_C2019_A09_EEG_validation_01(VA)
% % % % % function FN_out = VA_C2019_A09_EEG_validation_01(VA)
% % % % % FN_out = 'N/A';
% % % % 
% % % % % % %% VA Setup
% % % % % % if VA.SW
% % % % % %     % allChValid or not
% % % % % %     VA.set.w.switch.ch.allValid = 1;
% % % % % % end

if exist('VA','var')
   VA.SW = true;
   
% %    % allChValid or not
% %    VA.set.w.switch.ch.allValid = 1;
else
   VA.SW = false;
end


%% Code 1. Data Loading

% clear; close all;

% _________________
% 
% allChValid or not
% _________________

if VA.SW
    w.switch.ch.allValid = VA.set.w.switch.ch.allValid;
else
    % % w.switch.ch.allValid = 0;
    % w.switch.ch.allValid = 1;
    w.m = questdlg('Do you want to load input datasets ?','Setup','EEG validation','all valid','EEG validation');
    if strcmp(w.m,'all valid')
        w.switch.ch.allValid = 1;
    else
        w.switch.ch.allValid = 0;
    end
end

% % % w.switch.task.allValid = 0;
% % w.switch.task.allValid = 1;


% ______
% 
% Config
% ______

if VA.SW
    c.autorun.used.subjects = VA.autorun.used.subjects;
    c.autorun.used.sessions = VA.autorun.used.sessions;
else
    % c.autorun.used.subjects = 1:10;
    % c.autorun.used.subjects = [2,5,11];
    c.autorun.used.subjects = 12;
    % c.autorun.used.sessions = 1:3;
    c.autorun.used.sessions = 5;
end

if VA.SW
    c.EEG.import.chNumber = VA.c.prep.EEG.import.chNumber;
    c.EEG.import.chIDs = VA.c.prep.EEG.import.chIDs;
    c.EEG.rec.ch.name = VA.c.prep.EEG.rec.ch.name;
    c.EEG.used.ch.name = VA.c.prep.EEG.used.ch.name;
else
    % c.EEG.import.chNumber = 16;
    % c.EEG.import.chIDs = 2 : c.EEG.import.chNumber+1;
    % % c.EEG.rec.ch.name = {'F3';'F4';'FC5';'FC1';'FC2';'FC6';'C3';'CZ';'C4';'CP5';'CP1';'CP2';'CP6';'P3';'PZ';'P4'; ...
    % %                      'AF3';'AF4';'F7';'FZ';'F8';'T7';'T8';'P7';'P8';'PO3';'PO4';'O1';'OZ';'O2';'EOGH';'EOGV'};
    % % c.EEG.rec.ch.name = {'F3';'F4';'FC5';'FC1';'FC2';'FC6';'C3';'CZ';'C4';'CP5';'CP1';'CP2';'CP6';'P3';'PZ';'P4'; ...
    % %                      'AF3';'AF4';'F7';'FZ';'F8';'T7';'T8';'P7';'P8';'PO3';'PO4';'O1';'OZ';'O2'};
    % % c.EEG.rec.ch.name = {'F3';'F4';'FC5';'FC1';'FC2';'FC6';'C3';'CZ';'C4';'CP5';'CP1';'CP2';'CP6';'P3';'PZ';'P4'};
    
    % % g.Nautilus 16 channels 10-20 setup:
    % c.EEG.import.chNumber = 16;
    % c.EEG.import.chIDs = 2 : c.EEG.import.chNumber+1;
    % c.EEG.rec.ch.name = {'FP1';'FP2';'F3';'FZ';'F4';'T7';'C3';'CZ';'C4';'T8';'P3';'PZ';'P4';'PO7';'PO8';'OZ'};
    
    % g.Nautilus 32 channels 10-20 setup:
    c.EEG.import.chNumber = 32;
    c.EEG.import.chIDs = 2 : c.EEG.import.chNumber+1;
    c.EEG.rec.ch.name = {'FP1';'FP2';'AF3';'AF4';'F7';'F3';'FZ';'F4';'F8';'FC5';'FC1';'FC2';'FC6'; ...
                         'T7';'C3';'CZ';'C4';'T8';'CP5';'CP1';'CP2';'CP6';'P7';'P3';'PZ';'P4';'P8';'PO7';'PO3';'PO4';'PO8';'OZ'};
    c.EEG.used.ch.name = c.EEG.rec.ch.name;
    % c.EEG.used.ch.name = {'F7';'F3';'FZ';'F4';'F8';'FC5';'FC1';'FC2';'FC6';'C3';'CZ';'C4';'CP5';'CP1';'CP2';'CP6';'P7';'P3';'PZ';'P4';'P8'}; 
end
c.EEG.rec.ch.ID = 1 : size(c.EEG.rec.ch.name,1);

% ______________
%
% Setup for load
% ______________

if VA.SW
    % autorun.file.load.autoload = VA.set.autorun.f.load.autoload;
    autorun.file.load.autoload = 1;
    autorun.file.load.path = VA.set.autorun.f.load.path;
else
    w.m = questdlg('Do you want to load input datasets ?','Setup','Select input directory','Load from default directory','Continue without loading','Load from default directory');
    if strcmp(w.m,'Load from default directory')
        autorun.file.load.autoload = 1;
        autorun.file.load.path = 'Q:\BCI\Data\Data Shape 01\- Work (doubled2)\';
    elseif strcmp(w.m,'Select input directory')
        autorun.file.load.autoload = 1;
        autorun.file.load.path = uigetdir('','Select input directory');
        % autorun.file.load.path = [autorun.file.load.path,'\'];
            VA.w.wm_subDirID = 1;
            VA.f.classSubDir{VA.w.wm_subDirID} = autorun.file.load.path( max(find(autorun.file.load.path(1,:)=='\'))+1 : size(autorun.file.load.path,2));
            autorun.file.load.path = autorun.file.load.path( 1 : max(find(autorun.file.load.path(1,:)=='u'))-2);
    else
        autorun.file.load.autoload = 0;
    end
end
if autorun.file.load.autoload == 1
    autorun.file.load.nameBasis.EEG_rec_fileName = 'EEG_rec.mat';
end

% ______________
%
% Setup for save
% ______________

if VA.SW
    % autorun.file.save.autosave = VA.set.autorun.f.save.autosave;
    autorun.file.save.autosave = 1;
    autorun.file.save.path = VA.set.autorun.f.save.path;
    autorun.file.save.nameBasis.A09_EEG_validation = 'A09_EEG_validation_01';
else
    w.m = questdlg('Do you want to save result files ?','Setup','Auto save','Not save','Auto save');
    if strcmp(w.m,'Auto save')
        % [autorun.file.save.nameBasis, autorun.file.save.path] = uiputfile(strcat('D4_31_EEG_Bandpower_09.mat'),'Set up result directory and filename');
        % autorun.file.save.nameBasis1 = autorun.file.save.nameBasis( 1 : max(find(autorun.file.save.nameBasis(1,:)=='.'))-1);
        autorun.file.save.autosave = 1;

        autorun.file.save.path = uigetdir('','Set directory for the result');
        autorun.file.save.path = [autorun.file.save.path,'\'];

        autorun.file.save.nameBasis.A09_EEG_validation = 'A09_EEG_validation_01';
    else
        autorun.file.save.autosave = 0;
    end
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

for autorun_subjID2 = TRANS.c.autorun.used.subjects
 for autorun_sessionID2 = TRANS.c.autorun.used.sessions
      
  % clearvars -except STACK TRANS autorun_subjID2 autorun_sessionID2 EEG_validation
  clearvars -except STACK VA_TRANS VA TRANS autorun_subjID2 autorun_sessionID2 EEG_validation attempt
  
  c = TRANS.c;
  autorun = TRANS.autorun;
  w = TRANS.w;
  
  wm_subjID2 = autorun_subjID2;
  wm_sessionID2 = autorun_sessionID2;
  
  fprintf(['SubjID2: ',num2str(wm_subjID2),'/',num2str(size(c.autorun.used.subjects,2)), ...
           ', SessionID2: ',num2str(wm_sessionID2),'/',num2str(size(c.autorun.used.sessions,2)),'\n'])
  
  % _______________
  %
  % Loading Dataset
  % _______________

  if autorun.file.load.autoload == 1
    % fprintf('\n');
    
    % w.file.load.path = [autorun.file.load.path,'Subj 0',num2str(autorun_subjID2),'\Session 0',num2str(autorun_sessionID2),'\01 Rec\'];
    % w.file.load.path = [autorun.file.load.path,'Subj ',subFunc_num2str_2digit(autorun_subjID2),'\Session ',subFunc_num2str_2digit(autorun_sessionID2),'\01 Rec\'];
    w.file.load.path = [autorun.file.load.path,'Subj ',subFunc_num2str_2digit(autorun_subjID2),'\Session ',subFunc_num2str_2digit(autorun_sessionID2),'\',VA.f.classSubDir{VA.w.wm_subDirID},'\'];
    
    % EEG record
    fprintf(['Loading EEG_rec dataset ...\n']);
    w.file.load.name = autorun.file.load.nameBasis.EEG_rec_fileName;
    TMP = load([w.file.load.path,w.file.load.name]);
    w.import.EEG_rec = TMP.EEG_rec;
    clear TMP
    
    
    fprintf('Dataset loading: DONE\n');
    fprintf('\n');
    
  end
  
  
  % ______________________
  % 
  % EEG Channel validation
  % ______________________
  
% %   if w.switch.ch.allValid == 1
% %     % ALL channel valid option
% %     % ________________________
% %     
% %     EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID = 1 : size(c.EEG.import.chIDs,2);
% %     EEG_validation{wm_subjID2,wm_sessionID2}.ch.invalid_ID = [];
% %     EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_mask = ones(1, size(c.EEG.import.chIDs,2));
% %   else
% %     % Channel validation option
% %     % _________________________
% %    
% %     w.wm_loop = 0;
% %     w.figure.setup.scrsz = get(0,'ScreenSize');
% %     w.figure.ID = figure('Position',[1,1,w.figure.setup.scrsz(3),w.figure.setup.scrsz(4)]);
% %     EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID = [];
% %     EEG_validation{wm_subjID2,wm_sessionID2}.ch.invalid_ID = [];
% %     EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_mask = NaN(1, size(c.EEG.import.chIDs,2));
% %     for wk = 1 : size(c.EEG.import.chIDs,2)
% %         plot(w.import.EEG_rec(c.EEG.import.chIDs(1,wk),:));
% %         title(['Subject',num2str(wm_subjID2),', Session',num2str(wm_sessionID2),', channel',num2str(wk),' (',c.EEG.rec.ch.name{wk,1},')'])
% %         if w.wm_loop == 1
% %             w.wm_loop = 0;
% %         end
% %         while w.wm_loop == 0
% %           w.wm2 = getkey;
% %           if w.wm2 == 28         % 28: left arrow (valid)
% %             EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID = [EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID, wk];
% %             EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_mask(1,wk) = 1;
% %             w.wm_loop = 1;
% %           elseif w.wm2 == 29     % 29: right arrow (invalid)
% %             EEG_validation{wm_subjID2,wm_sessionID2}.ch.invalid_ID = [EEG_validation{wm_subjID2,wm_sessionID2}.ch.invalid_ID, wk];
% %             EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_mask(1,wk) = 0;
% %             w.wm_loop = 1;
% %           elseif w.wm2 == 27    % 27: "ESC"
% %               w.wm_loop = -1;
% %           end
% %         end
% %         if w.wm_loop == -1
% %             break
% %         end
% %     end
% %     close(w.figure.ID)
% %     if w.wm_loop == -1
% %         break
% %     end
% %     
% %   end
  if w.switch.ch.allValid == 1
    % ALL channel valid option
    % ________________________
    
    wm = transpose(ismember(VA.c.prep.EEG.rec.ch.name, VA.c.prep.EEG.used.ch.name));
    EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID = find(wm==1);
    EEG_validation{wm_subjID2,wm_sessionID2}.ch.invalid_ID = find(wm==0);
    EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_mask = wm;
  else
    % Channel validation option
    % _________________________
   
    w.wm_loop = 0;
    w.figure.setup.scrsz = get(0,'ScreenSize');
    w.figure.ID = figure('Position',[1,1,w.figure.setup.scrsz(3),w.figure.setup.scrsz(4)]);
    EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID = [];
    EEG_validation{wm_subjID2,wm_sessionID2}.ch.invalid_ID = [];
    EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_mask = NaN(1, size(c.EEG.import.chIDs,2));
    for wk = 1 : size(c.EEG.import.chIDs,2)
      if ismember(c.EEG.rec.ch.name{wk,1}, VA.c.prep.EEG.used.ch.name)
        plot(w.import.EEG_rec(c.EEG.import.chIDs(1,wk),:));
        title(['Subject',num2str(wm_subjID2),', Session',num2str(wm_sessionID2),', channel',num2str(wk),' (',c.EEG.rec.ch.name{wk,1},')'])
        if w.wm_loop == 1
            w.wm_loop = 0;
        end
        while w.wm_loop == 0
          w.wm2 = getkey;
          if w.wm2 == 28         % 28: left arrow (valid)
            EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID = [EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID, wk];
            EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_mask(1,wk) = 1;
            w.wm_loop = 1;
          elseif w.wm2 == 29     % 29: right arrow (invalid)
            EEG_validation{wm_subjID2,wm_sessionID2}.ch.invalid_ID = [EEG_validation{wm_subjID2,wm_sessionID2}.ch.invalid_ID, wk];
            EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_mask(1,wk) = 0;
            w.wm_loop = 1;
          elseif w.wm2 == 27    % 27: "ESC"
              w.wm_loop = -1;
          end
        end
        if w.wm_loop == -1
            break
        end
      else
          EEG_validation{wm_subjID2,wm_sessionID2}.ch.invalid_ID = [EEG_validation{wm_subjID2,wm_sessionID2}.ch.invalid_ID, wk];
          EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_mask(1,wk) = 0;
      end
    end
    close(w.figure.ID)
    if w.wm_loop == -1
        break
    end
    
  end
  
  % valid and invalid ch name setup
  % _______________________________
  
  if ~isempty(EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID)
    for wk2ID = 1 : size(EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID,2)
      EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_name{1,wk2ID} = c.EEG.rec.ch.name{EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID(wk2ID),1};
    end
  end
  if ~isempty(EEG_validation{wm_subjID2,wm_sessionID2}.ch.invalid_ID)
    for wk2ID = 1 : size(EEG_validation{wm_subjID2,wm_sessionID2}.ch.invalid_ID,2)
      EEG_validation{wm_subjID2,wm_sessionID2}.ch.invalid_name{1,wk2ID} = c.EEG.rec.ch.name{EEG_validation{wm_subjID2,wm_sessionID2}.ch.invalid_ID(wk2ID),1};
    end
  end
  
  
  % _______________
  % 
  % task validation
  % _______________
  
  % !!!!!!!!!!!!! task validation code: N/A !!!!!!!!!!!!!!! 
  
  
  
  
  
  
  
  
 end
end

% % % % c_for_validation = c;
% % % % % Manual save: c_for_validation EEG_validation

% _________
% 
% AUTO SAVE
% _________

% c = TRANS.c;                % save this
% autorun = TRANS.autorun;    % save this
if autorun.file.save.autosave == 1
    fprintf('Saving config structure ...\n');
    copy_of_c = TRANS.c;
    w.file.save.name = [autorun.file.save.nameBasis.A09_EEG_validation, ' [config].mat'];
    save([autorun.file.save.path,w.file.save.name],'copy_of_c','-v7.3');
    clear copy_of_c
    
    fprintf('Saving autorun structure ...\n');
    copy_of_autorun = TRANS.autorun;
    w.file.save.name = [autorun.file.save.nameBasis.A09_EEG_validation, ' [autorun].mat'];
    save([autorun.file.save.path,w.file.save.name],'copy_of_autorun','-v7.3');
    clear copy_of_autorun
    
    fprintf('Saving EEG_validation structure ...\n');
    copy_of_EEG_validation = EEG_validation;
    w.file.save.name = [autorun.file.save.nameBasis.A09_EEG_validation, ' [EEG_validation].mat'];
    save([autorun.file.save.path,w.file.save.name],'copy_of_EEG_validation','-v7.3');
    clear copy_of_EEG_validation
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


% % % % %% Function end
% % % % end


%% Comments

% EEG_rec([2:18],:) = rundat(:,1:17)';
% EEG_rec(1,:) = 0:0.008:((size(EEG_rec,2)-1)/125);



