% Collect DA plots from trainTest directories

% Input structures

% Output structures
% c.online. ...

% REQUIRESTMENT: Matlab
% Copyright(c)2019 Attila Korik, http://isrc.ulster.ac.uk/akorik/contact.html


%% Code headline

if exist('VA','var')
   VA.SW = true;
else
   VA.SW = false;
end


%% Setup

% clear; clc;

% Load Setup
% __________
if VA.SW
    w.f.load.baseDir = VA_TRANS.f.baseDir;
else
    w.f.load.baseDir = 'R:\BCI\DCR\Cybathlon 2019\Results\- work\TrainTest';
end
w.f.load.FBCSP_subDir = '+ FBCSP';
% % % % w.f.load.classSubDir{1} = '01 LR';
% % % % w.f.load.classSubDir{2} = '02 FR';
% % % % w.f.load.classSubDir{3} = '03 LF';
% % % % w.f.load.classSubDir{4} = '04 TX';
w.f.load.classSubDir = VA.f.classSubDir;
% w.f.save.path = 'R:\BCI\DCR\Cybathlon 2019\Results\- work\TrainTest (DA plots)\';
w.f.save.subDir = '- (DOUBLED) DA plots';
w.f.save.nameBase = 'DA plot';


%% Code

w.f.save.path = [w.f.load.baseDir,'\',w.f.save.subDir,'\'];
mkdir(w.f.save.path);

% Copy DA plots
% _____________
fprintf('Copy DA plots ...\n')
for wm_classID = 1 : size(w.f.load.classSubDir,2)
  w_dirStruct = dir([w.f.load.baseDir,'\',w.f.load.FBCSP_subDir,'\',w.f.load.classSubDir{wm_classID}]);
  for wm_dirID = 1 : size(w_dirStruct,1)
    if w_dirStruct(wm_dirID).name(1,1) == 'A'
      w_dirStruct2 = dir([w_dirStruct(wm_dirID).folder,'\',w_dirStruct(wm_dirID).name,'\Fig']);
      for wm_dirID2 = 1 : size(w_dirStruct2,1)
        if size(w_dirStruct2(wm_dirID2).name,2) > size('shadedDAOuter (Subj',2)
          if strcmp(w_dirStruct2(wm_dirID2).name(1,1:size('shadedDAOuter (Subj',2)),'shadedDAOuter (Subj')
            copyfile( [w_dirStruct(wm_dirID).folder,'\',w_dirStruct(wm_dirID).name,'\Fig\',w_dirStruct2(wm_dirID2).name],...
                      [w.f.save.path,w.f.save.nameBase,' [',w.f.load.classSubDir{wm_classID},' ',w_dirStruct(wm_dirID).name,']', ...
                            w_dirStruct2(wm_dirID2).name(1,max(find(ismember(w_dirStruct2(wm_dirID2).name,'.')==1)):end)] );
          end
        end
      end
    end
  end
end
fprintf('DONE.\n')


%% Comments






