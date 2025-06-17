% _____________________________________________________________________
% 
% Copy important param and result files to the final T1 sub-directories
% _____________________________________________________________________

  % Create/re-create actual T1 sub-directories
  % __________________________________________
    
    % X: Prepare actual T1-online directory
    % _____________________________________
    
    if ~isempty(V1_TRANS.f.T1_online_subSubDir)
      % Delete actually processed subDir within T1-online dir if exists
      wm_out_subDir = [V1_TRANS.f.T1_subDir,'\',V1_TRANS.f.T1_online_subSubDir,'\', tr_subDir_list{wm_taskID}];
      tmp = [V1_TRANS.f.BaseDir,'\',wm_out_subDir];
      if isdir(tmp)
        rmdir(tmp,'s');
      end
      % Prep subfold
      mkdir(V1_TRANS.f.BaseDir,wm_out_subDir);
      wm_out_baseDir_online = [V1_TRANS.f.BaseDir,'\',wm_out_subDir];
    end
    
  % Copy final param and result files to T1 sub-directories
  % _______________________________________________________
    
    % X: Copy files from Online dir to -> the final T1-online dir
    % ___________________________________________________________
    
    if ~isempty(V1_TRANS.f.T1_online_subSubDir)
      
      w.f.in_baseDir = [V1_TRANS.f.BaseDir,'\Online'];
      % w.f.in_baseDir = [V1_TRANS.f.BaseDir_for_trainTest,'\TrainTest'];
      w.f.out_baseDir = wm_out_baseDir_online;
    
      % Copy files from Online dir to -> the final T1-online dir 
      wm1 = [w.f.in_baseDir];
      wm2 = [w.f.out_baseDir];
      w_dirStruct = dir(wm1);
      for wm_dirID = 1 : size(w_dirStruct,1)
        if w_dirStruct(wm_dirID).name(1,1) == 'F'
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


