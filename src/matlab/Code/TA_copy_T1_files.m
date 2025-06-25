% _____________________________________________________________________
% 
% Copy important param and result files to the final T1 sub-directories
% _____________________________________________________________________

  % Create/re-create actual T1 sub-directories
  % __________________________________________
    
    % 1: Prepare actual T1-Param directory
    % ____________________________________
    
    if ~isempty(V1_TRANS.f.T1_param_subSubDir)
      % Delete actually processed subDir within T1-Param dir if exists
      wm_out_subDir = [V1_TRANS.f.T1_subDir,'\',V1_TRANS.f.T1_param_subSubDir,'\', tr_subDir_list{wm_taskID}];
      tmp = [V1_TRANS.f.BaseDir,'\',wm_out_subDir];
      if isdir(tmp)
        rmdir(tmp,'s');
      end
      % Prep subfold
      mkdir(V1_TRANS.f.BaseDir,wm_out_subDir);
      wm_out_baseDir_param = [V1_TRANS.f.BaseDir,'\',wm_out_subDir];
    end
    
    % 2:  Prepare actual T1-Param2 directory
    % ______________________________________
    
    if ~isempty(V1_TRANS.f.T1_param2_subSubDir)
      % Delete actually processed subDir within T1-Param2 dir if exists
      wm_out_subDir = [V1_TRANS.f.T1_subDir,'\',V1_TRANS.f.T1_param2_subSubDir,'\', tr_subDir_list{wm_taskID}];
      tmp = [V1_TRANS.f.BaseDir,'\',wm_out_subDir];
      if isdir(tmp)
        rmdir(tmp,'s');
      end
      % Prep subfold
      mkdir(V1_TRANS.f.BaseDir,wm_out_subDir);
      wm_out_baseDir_param2 = [V1_TRANS.f.BaseDir,'\',wm_out_subDir];
    end
    
    % 3: Prepare actual T1-Results directory
    % ______________________________________
    
    if ~isempty(V1_TRANS.f.T1_results_subSubDir)
      % Delete actually processed subDir within T1-Results dir if exists
      wm_out_subDir = [V1_TRANS.f.T1_subDir,'\',V1_TRANS.f.T1_results_subSubDir,'\', tr_subDir_list{wm_taskID}];
      tmp = [V1_TRANS.f.BaseDir,'\',wm_out_subDir];
      if isdir(tmp)
        rmdir(tmp,'s');
      end
      % Prep subfold
      mkdir(V1_TRANS.f.BaseDir,wm_out_subDir);
      wm_out_baseDir_results = [V1_TRANS.f.BaseDir,'\',wm_out_subDir];
    end
    
  % Copy final param and result files to T1 sub-directories
  % _______________________________________________________
    
    % 1: Copy Prep plus (A09,A10,A10B,A11 | without class-trial files) + optimal FBCSP setup (w0_matrix, ...) from TrainTest dir to -> the final T1-param dir
    % _______________________________________________________________________________________________________________________________________________________
    
    if ~isempty(V1_TRANS.f.T1_param_subSubDir)
    
      w.f.in_baseDir = [V1_TRANS.f.BaseDir,'\TrainTest'];
      % w.f.in_baseDir = [V1_TRANS.f.BaseDir_for_trainTest,'\TrainTest'];
      w.f.out_baseDir = wm_out_baseDir_param;
    
      % Copy "FBCSP_offline_trainTest_01 [xxx].mat" files from optimal FBCSP setup dir 
      wm2a = 'FBCSP';
      if ~isdir([w.f.out_baseDir,'\',wm2a])
        mkdir([w.f.out_baseDir,'\',wm2a])
      end
      wm1 = [w.f.in_baseDir,'\- opt FBCSP'];
      wm2 = [w.f.out_baseDir,'\',wm2a];
      w_dirStruct = dir(wm1);
      for wm_dirID = 1 : size(w_dirStruct,1)
        if w_dirStruct(wm_dirID).name(1,1) == 'F'
          copyfile([wm1,'\',w_dirStruct(wm_dirID).name], [wm2,'\',w_dirStruct(wm_dirID).name]);
        end
      end
      
      % Copy "A09,A10,A10B,A11" files from optimal "Prep plus" dir 
      wm2a = 'Prep plus';
      if ~isdir([w.f.out_baseDir,'\',wm2a])
        mkdir([w.f.out_baseDir,'\',wm2a])
      end
      wm1 = [w.f.in_baseDir,'\Prep plus\EEG'];
      wm2 = [w.f.out_baseDir,'\',wm2a];
      w_dirStruct = dir(wm1);
      for wm_dirID = 1 : size(w_dirStruct,1)
        if w_dirStruct(wm_dirID).name(1,1) == 'A'
          copyfile([wm1,'\',w_dirStruct(wm_dirID).name], [wm2,'\',w_dirStruct(wm_dirID).name]);
        end
      end
      
      % Copy "Standard-10-20-Cap81.locs" and "TAv2_TrainTest [xxx].mat" files from source base dir
      wm1 = [w.f.in_baseDir];
      wm2 = [w.f.out_baseDir,'\'];
      w_dirStruct = dir(wm1);
      for wm_dirID = 1 : size(w_dirStruct,1)
        if w_dirStruct(wm_dirID).name(1,1) == 'S'
          copyfile([wm1,'\',w_dirStruct(wm_dirID).name], [wm2,'\',w_dirStruct(wm_dirID).name]);
        elseif w_dirStruct(wm_dirID).name(1,1) == 'T'
          copyfile([wm1,'\',w_dirStruct(wm_dirID).name], [wm2,'\',w_dirStruct(wm_dirID).name]);
        end
      end
      
    end
    
    % 2: Copy (large) class-trial files from Prep plus dir to -> the final T1-param2 dir
    % __________________________________________________________________________________
    
    if ~isempty(V1_TRANS.f.T1_param2_subSubDir)
      
      w.f.in_baseDir = [V1_TRANS.f.BaseDir,'\TrainTest'];
      % w.f.in_baseDir = [V1_TRANS.f.BaseDir_for_trainTest,'\TrainTest'];
      w.f.out_baseDir = wm_out_baseDir_param2;
    
      % Copy (large) class-trial files from optimal "Prep plus" dir 
      wm2a = 'Prep plus';
      if ~isdir([w.f.out_baseDir,'\',wm2a])
        mkdir([w.f.out_baseDir,'\',wm2a])
      end
      wm1 = [w.f.in_baseDir,'\Prep plus\EEG'];
      wm2 = [w.f.out_baseDir,'\',wm2a];
      w_dirStruct = dir(wm1);
      for wm_dirID = 1 : size(w_dirStruct,1)
        if w_dirStruct(wm_dirID).name(1,1) == 'c'
          copyfile([wm1,'\',w_dirStruct(wm_dirID).name], [wm2,'\',w_dirStruct(wm_dirID).name]);
        elseif w_dirStruct(wm_dirID).name(1,1) == 't'
          copyfile([wm1,'\',w_dirStruct(wm_dirID).name], [wm2,'\',w_dirStruct(wm_dirID).name]);
        end
      end
      
    end
    
    % 3: Copy final results of auto-selected setup from TrainTest dir to -> the final T1-Results dir
    % ______________________________________________________________________________________________
    
    if ~isempty(V1_TRANS.f.T1_results_subSubDir)
      
      w.f.in_baseDir = [V1_TRANS.f.BaseDir,'\TrainTest'];
      % w.f.in_baseDir = [V1_TRANS.f.BaseDir_for_trainTest,'\TrainTest'];
      w.f.out_baseDir = wm_out_baseDir_results;
    
      % Copy full content of the Figure dir
      wm2a = '+ Fig';
      if ~isdir([w.f.out_baseDir,'\',wm2a])
        mkdir([w.f.out_baseDir,'\',wm2a])
      end
      wm1 = [w.f.in_baseDir,'\- Fig'];
      wm2 = [w.f.out_baseDir,'\',wm2a];
      w_dirStruct = dir(wm1);
      for wm_dirID = 1 : size(w_dirStruct,1)
        if (size(w_dirStruct(wm_dirID).name,2)>1) && (w_dirStruct(wm_dirID).name(1,1) ~= '.')
         if w_dirStruct(wm_dirID).name(1,2) ~= '.'
            copyfile([wm1,'\',w_dirStruct(wm_dirID).name], [wm2,'\',w_dirStruct(wm_dirID).name]);
         end
        end
      end
      
      % Copy "Standard-10-20-Cap81.locs" and "TAv2_TrainTest [xxx].mat" files from source base dir
      wm1 = [w.f.in_baseDir];
      wm2 = [w.f.out_baseDir,'\'];
      w_dirStruct = dir(wm1);
      for wm_dirID = 1 : size(w_dirStruct,1)
        if w_dirStruct(wm_dirID).name(1,1) == 'S'
          copyfile([wm1,'\',w_dirStruct(wm_dirID).name], [wm2,'\',w_dirStruct(wm_dirID).name]);
        elseif w_dirStruct(wm_dirID).name(1,1) == 'T'
          copyfile([wm1,'\',w_dirStruct(wm_dirID).name], [wm2,'\',w_dirStruct(wm_dirID).name]);
        end
      end
      
    end

    
    

%% Comments

% % Copy DA plots
% % _____________
% fprintf('Copy DA plots ...\n')
% for wm_classID = 1 : size(w.f.load.classSubDir,2)
%   w_dirStruct = dir([w.f.load.baseDir,'\',w.f.load.FBCSP_subDir,'\',w.f.load.classSubDir{wm_classID}]);
%   for wm_dirID = 1 : size(w_dirStruct,1)
%     if w_dirStruct(wm_dirID).name(1,1) == 'A'
%       w_dirStruct2 = dir([w_dirStruct(wm_dirID).folder,'\',w_dirStruct(wm_dirID).name,'\Fig']);
%       for wm_dirID2 = 1 : size(w_dirStruct2,1)
%         if size(w_dirStruct2(wm_dirID2).name,2) > size('shadedDAOuter (Subj',2)
%           if strcmp(w_dirStruct2(wm_dirID2).name(1,1:size('shadedDAOuter (Subj',2)),'shadedDAOuter (Subj')
%             copyfile( [w_dirStruct(wm_dirID).folder,'\',w_dirStruct(wm_dirID).name,'\Fig\',w_dirStruct2(wm_dirID2).name],...
%                       [w.f.save.path,w.f.save.nameBase,' [',w.f.load.classSubDir{wm_classID},' ',w_dirStruct(wm_dirID).name,']', ...
%                             w_dirStruct2(wm_dirID2).name(1,max(find(ismember(w_dirStruct2(wm_dirID2).name,'.')==1)):end)] );
%           end
%         end
%       end
%     end
%   end
% end


