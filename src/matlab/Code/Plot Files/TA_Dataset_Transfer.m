% ... - Dataset transfer

% Input structures

% Output structures

% REQUIRESTMENT: Matlab
% Copyright(c)2020 Attila Korik, http://isrc.ulster.ac.uk/akorik/contact.html


%% Code 01

cf_TAv2_TrainTest_A1_prep

% Source data to Work data (EEG_rec) 
  % __________________________________
  
  if strcmp(V1_TRANS.f.SourceDataName, 'EEG_rec.mat')
    load(V1_TRANS.tr_file_list{wm_taskID});
  elseif strcmp(V1_TRANS.f.SourceDataName, 'tr.mat')
    % Load tr.mat and convert rundat to EEG_rec
    tmp = load(V1_TRANS.tr_file_list{wm_taskID});
      EEG_rec([VA_TRANS.c.prep.EEG.import.chIDs,VA_TRANS.c.prep.EEG.import.trigCh],:) = tmp.rundat(:,1:VA_TRANS.c.prep.EEG.import.chNumber+1)';
      clearvars VA_TRANS
    clear tmp
  end
    
% % % % % % % %   % __________________________
% % % % % % % %   %
% % % % % % % %   % EEG hardware related setup
% % % % % % % %   % __________________________
% % % % % % % %   
% % % % % % % %    if size(imp.game.ScopeData.signals,2) == 9
% % % % % % % %     result.info.EEG_rec_chNumber = 8;
% % % % % % % %     VA_TRANS.c.prep.EEG.import.chNumber = VA_TRANS.c.prep.EEG_Flex8.import.chNumber;
% % % % % % % %     VA_TRANS.c.prep.EEG.import.trigCh = VA_TRANS.c.prep.EEG_Flex8.import.trigCh;
% % % % % % % %     VA_TRANS.c.prep.EEG.import.chIDs = VA_TRANS.c.prep.EEG_Flex8.import.chIDs;
% % % % % % % %     VA_TRANS.c.prep.EEG.rec.ch.name = VA_TRANS.c.prep.EEG_Flex8.rec.ch.name;
% % % % % % % %     VA_TRANS.c.prep.EEG.used.ch.name = VA_TRANS.c.prep.EEG_Flex8.used.ch.name;
% % % % % % % % %     VA_TRANS.c.prep.EEG.used2.ch.name = VA_TRANS.c.prep.EEG_Flex8.used2.ch.name;
% % % % % % % %     % for wk = VA_TRANS.c.prep.EEG.import.chIDs
% % % % % % % %     for wk = 1 : size(imp.game.ScopeData.signals,2)
% % % % % % % %       w.import.EEG_rec(wk,:) = imp.game.ScopeData.signals(1,wk).values(1,1,:);
% % % % % % % %     end
% % % % % % % %     for wk = 1 : size(imp.game.ScopeData.signals,2)-1
% % % % % % % %       w.import.EEG_rec(wk,:) = w.import.EEG_rec(wk,:) * VA_TRANS.c.prep.EEG_Flex8.import.rescaleValue;
% % % % % % % %       w.import.EEG_rec(wk,find(abs(w.import.EEG_rec(wk,:)) > VA_TRANS.c.prep.EEG_Flex8.import.signalLimit)) = VA_TRANS.c.prep.EEG_Flex8.import.signalLimit_replacement;
% % % % % % % %     end
% % % % % % % %    elseif size(imp.game.ScopeData.signals,2) == 33
% % % % % % % %     result.info.EEG_rec_chNumber = 32;
% % % % % % % %     VA_TRANS.c.prep.EEG.import.chNumber = VA_TRANS.c.prep.EEG_GTech32.import.chNumber;
% % % % % % % %     VA_TRANS.c.prep.EEG.import.trigCh = VA_TRANS.c.prep.EEG_GTech32.import.trigCh;
% % % % % % % %     VA_TRANS.c.prep.EEG.import.chIDs = VA_TRANS.c.prep.EEG_GTech32.import.chIDs;
% % % % % % % %     VA_TRANS.c.prep.EEG.rec.ch.name = VA_TRANS.c.prep.EEG_GTech32.rec.ch.name;
% % % % % % % %     VA_TRANS.c.prep.EEG.used.ch.name = VA_TRANS.c.prep.EEG_GTech32.used.ch.name;
% % % % % % % % %     VA_TRANS.c.prep.EEG.used2.ch.name = VA_TRANS.c.prep.EEG_GTech32.used2.ch.name;
% % % % % % % %     % for wk = VA_TRANS.c.prep.EEG.import.chIDs
% % % % % % % %     for wk = 1 : size(imp.game.ScopeData.signals,2)
% % % % % % % %       w.import.EEG_rec(wk,:) = imp.game.ScopeData.signals(1,wk).values(:,1);
% % % % % % % %     end
% % % % % % % %     for wk = 1 : size(imp.game.ScopeData.signals,2)-1
% % % % % % % %       w.import.EEG_rec(wk,:) = w.import.EEG_rec(wk,:) * VA_TRANS.c.prep.EEG_GTech32.import.rescaleValue;
% % % % % % % %       w.import.EEG_rec(wk,find(abs(w.import.EEG_rec(wk,:)) > VA_TRANS.c.prep.EEG_GTech32.import.signalLimit)) = VA_TRANS.c.prep.EEG_GTech32.import.signalLimit_replacement;
% % % % % % % %     end
% % % % % % % %    end
% % % % % % % %    VA_TRANS.c.prep.EEG.used.ch.ID = find(ismember(VA_TRANS.c.prep.EEG.rec.ch.name, VA_TRANS.c.prep.EEG.used.ch.name));
% % % % % % % % %    VA_TRANS.c.prep.EEG.used2.ch.ID = find(ismember(VA_TRANS.c.prep.EEG.rec.ch.name, VA_TRANS.c.prep.EEG.used2.ch.name));
% % % % % % % %   
% % % % % % % % clearvars imp
  
  % Re-distribute triggers for Q&A dataset
  % ______________________________________
  
  clearvars tmp
  tmp.wm = strfind(V1_TRANS.tr_file_list{wm_taskID},'\');
  if contains(lower(V1_TRANS.tr_file_list{wm_taskID}(1,tmp.wm(1,end-1)+1:tmp.wm(1,end)-1)), 'q')
    tmp.wm0 = unique(EEG_rec(VA_TRANS.c.prep.EEG.import.trigCh,:));
    
    % All question categories:
    tmp.wm2 = tmp.wm0(1,find(tmp.wm0>=101));
    tmp.cl2 = tmp.wm2(1,find(tmp.wm2<150));
    tmp.wm1 = tmp.wm0(1,find(tmp.wm0>=150));
    tmp.cl1 = tmp.wm1(1,find(tmp.wm1<200));
    
% %     % Bio (biomethrical) questions:
% %     tmp.wm2 = tmp.wm0(1,find(tmp.wm0>=101));
% %     tmp.cl2 = tmp.wm2(1,find(tmp.wm2<=112));
% %     tmp.wm1 = tmp.wm0(1,find(tmp.wm0>=150));
% %     tmp.cl1 = tmp.wm1(1,find(tmp.wm1<=161));
% %     % Sit (situational) questions:
% %     tmp.wm2 = tmp.wm0(1,find(tmp.wm0>=113));
% %     tmp.cl2 = tmp.wm2(1,find(tmp.wm2<=124));
% %     tmp.wm1 = tmp.wm0(1,find(tmp.wm0>=162));
% %     tmp.cl1 = tmp.wm1(1,find(tmp.wm1<=173));
% %     % Log (logical) questions:
% %     tmp.wm2 = tmp.wm0(1,find(tmp.wm0>=125));
% %     tmp.cl2 = tmp.wm2(1,find(tmp.wm2<=136));
% %     tmp.wm1 = tmp.wm0(1,find(tmp.wm0>=174));
% %     tmp.cl1 = tmp.wm1(1,find(tmp.wm1<=185));
% %     % Num (numerical) questions:
% %     tmp.wm2 = tmp.wm0(1,find(tmp.wm0>=137));
% %     tmp.cl2 = tmp.wm2(1,find(tmp.wm2<=148));
% %     tmp.wm1 = tmp.wm0(1,find(tmp.wm0>=186));
% %     tmp.cl1 = tmp.wm1(1,find(tmp.wm1<=197));
    
    tmp.trigCh = zeros(1, size(EEG_rec,2)); 
    tmp.trigCh(1, find(ismember(EEG_rec(VA_TRANS.c.prep.EEG.import.trigCh,:),tmp.cl1))) = 1;
    tmp.trigCh(1, find(ismember(EEG_rec(VA_TRANS.c.prep.EEG.import.trigCh,:),tmp.cl2))) = 2;
% a=EEG_rec;
    EEG_rec(VA_TRANS.c.prep.EEG.import.trigCh,:) = tmp.trigCh;
%{
figure;
subplot(2,1,1); plot(a(end,:));
subplot(2,1,2); plot(EEG_rec(end,:));
%}
  end
  clearvars tmp
  
  
  % Save transfered dataset
  % _______________________
  
  % Delete Output Data dir with subdirs if exists
  tmp = [V1_TRANS.f.BaseDir, '\', V1_TRANS.f.DataSubDir];
  if isdir(tmp)
    rmdir(tmp,'s');
  end
  clearvars tmp
  
  % Prep Data subfold
  wm_save_subDir = [V1_TRANS.f.DataSubDir, '\', V1_TRANS.f.Subj1Sess1SubDir, '\', V1_TRANS.f.classSubDir{1}];
  % mkdir(V1_TRANS.f.BaseDir, wm_save_subDir);
tmp.wm = 1;
tmp.wm2 = 1;
while tmp.wm < 100
try
  tmp.wm2 = tmp.wm;
  mkdir(V1_TRANS.f.BaseDir, wm_save_subDir);
  tmp.wm = 100;
catch
    if tmp.wm == 1
      fprintf('mkdir is broken ...\n')
    end
    pause(10)
    tmp.wm = tmp.wm+1;
end
end
if tmp.wm == 1
  fprintf(['mkdir was success after ',num2str(tmp.wm),' try\n'])
end
TEST.TA_Dataset_Transfer__mkdir_tryNumber(wm_taskID,1) = tmp.wm2;
clearvars tmp
  
    % Save EEG_rec.mat
    save([V1_TRANS.f.BaseDir, '\', wm_save_subDir, '\EEG_rec.mat'],'EEG_rec','-v7.3');
    clear EEG_rec
  
  

%% Comments











