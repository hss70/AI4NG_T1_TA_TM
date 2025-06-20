
% Config file for
% Multi-class Classification, task manager 

% Input structures

% Output structures

% REQUIRESTMENT: Matlab
% Copyright(c)2020 Attila Korik, http://isrc.ulster.ac.uk/akorik/contact.html


%% VA Setup (A1 prep)

VA_TRANS.SW = true;     % =1 need for transfer required VA_TRANS parameters in called process codes
VA_TRANS.SW_print_trainTest_details = 0;     % =1: detailedmessages printed during trainTest code run, =0: the trainTest code run without printing detailed messages 
VA_TRANS.SW_close_figures = 1;     % =1: close result figures after plotted and saved, =0: keep open the figures

VA_TRANS.c.eval.permut_number = 0;     % =0: no permutation test, >0: number of permutations
% VA_TRANS.c.eval.permut_number = 1;     % =0: no permutation test, >0: number of permutations
% VA_TRANS.c.eval.permut_number = 2;     % =0: no permutation test, >0: number of permutations
% VA_TRANS.c.eval.permut_number = 3;     % =0: no permutation test, >0: number of permutations
% VA_TRANS.c.eval.permut_number = 7;     % =0: no permutation test, >0: number of permutations
% VA_TRANS.c.eval.permut_number = 100;     % =0: no permutation test, >0: number of permutations

VA_TRANS.c.eval.permut_number_min = 0;     % =0: no permutation test, >0: number of permutations
% VA_TRANS.c.eval.permut_number_min = 1;     % =0: no permutation test, >0: number of permutations
% VA_TRANS.c.eval.permut_number_min = 2;     % =0: no permutation test, >0: number of permutations
% VA_TRANS.c.eval.permut_number_min = 5;     % =0: no permutation test, >0: number of permutations
% VA_TRANS.c.eval.permut_number_min = 40;     % =0: no permutation test, >0: number of permutations

% V1_TRANS.f.HomeDir = 'Q:\BCI\DCR\FBCSP 2022-CL';
%Not needed, the HomeDir is set in cf_T1_TAv2_TM.m and the getV1_TRANSConfig
%tmp_dir = pwd; cd ..; 
%V1_TRANS.f.HomeDir = pwd; 
%cd(tmp_dir); 
%clearvars tmp_dir


if(exist('V1_TRANS', 'var'))
    baseDir = V1_TRANS.f.BaseDir;
end

VA_TRANS.f.workDir = [baseDir];   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! % =1: task VS relax classification pair used   
VA_TRANS.f.dataDir = [VA_TRANS.f.workDir,'\TMP Data'];   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! % =1: task VS relax classification pair used      
VA_TRANS.f.baseDir = [VA_TRANS.f.workDir,'\TrainTest'];   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! % =1: task VS relax classification pair used      


% % % % VA_TRANS.f.classSubDir{1} = '01 LR';
% % % % VA_TRANS.f.classSubDir{2} = '02 FR';
% % % % VA_TRANS.f.classSubDir{3} = '03 LF';
VA_TRANS.f.classSubDir{1} = 'EEG';
VA_TRANS.f.SW.task_vs_relax_CP_used = 0;   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! % =1: task VS relax classification pair used      
% % % % VA_TRANS.f.SW.task_vs_relax_CP_used = 1;   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! % =1: task VS relax classification pair used      
% % % % if VA_TRANS.f.SW.task_vs_relax_CP_used
% % % %     VA_TRANS.f.classSubDir{4} = '04 TX';
% % % % end
% % VA_TRANS.f.A09_EEG_validation.subDir = 'A09 EEG validation';
% % VA_TRANS.f.A10_offlineClass_prep.subDir = 'A10 offlineClass EEG prep';
% % VA_TRANS.f.A10B_offlineTrial_validation.subDir = 'A10B offlineTrial validation';
% % VA_TRANS.f.A11_offlineClass_classSetup.subDir = 'A11 offlineClass classSetup';
VA_TRANS.f.A09_EEG_validation.subDir = 'Prep plus';
VA_TRANS.f.A10_offlineClass_prep.subDir = 'Prep plus';
VA_TRANS.f.A10B_offlineTrial_validation.subDir = 'Prep plus';
VA_TRANS.f.A11_offlineClass_classSetup.subDir = 'Prep plus';

VA_TRANS.f.FBCSP_offline_trainTest_taskManager.subDir = '+ FBCSP';
% VA_TRANS.f.chanlocs_path = 'Q:\BCI\DCR\Cybathlon 2019\Results\- work\';
VA_TRANS.f.chanlocs_dir = VA_TRANS.f.baseDir;
VA_TRANS.f.chanlocs_filename = 'Standard-10-20-Cap81.locs';

% VA_TRANS.autorun.used.subjects = 1:10;
% VA_TRANS.autorun.used.subjects = [2,5,11];
% % VA_TRANS.autorun.used.subjects = 12;     	% !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
VA_TRANS.autorun.used.subjects = 1;     	% !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% VA_TRANS.autorun.used.sessions = 1:3;
% % VA_TRANS.autorun.used.sessions = 5;         % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
VA_TRANS.autorun.used.sessions = 1;         % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% VA_TRANS.c.classSetup.band.usedIDs = 1:6;         % from preprocessed EEG data with these bandIDs will be used for trainTest
% VA_TRANS.c.classSetup.band.usedIDs = [11,12,2,3];         % from preprocessed EEG data with these bandIDs will be used for trainTest
% VA_TRANS.c.classSetup.band.usedIDs = [12,2,3,4];         % from preprocessed EEG data with these bandIDs will be used for trainTest
% VA_TRANS.c.classSetup.band.usedIDs = 1:4;         % from preprocessed EEG data with these bandIDs will be used for trainTest
% VA_TRANS.c.classSetup.band.usedIDs = 2:5;   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!!          % from preprocessed EEG data with these bandIDs will be used for trainTest
VA_TRANS.c.classSetup.band.usedIDs = 3:6;   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!!          % from preprocessed EEG data with these bandIDs will be used for trainTest

VA_TRANS.set.w.switch.tr.allValid = 1;      % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 

% % VA_TRANS.c.prep.EEG.rec.sr = 125;           % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% VA_TRANS.c.prep.EEG.rec.sr = 250;           % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% VA_TRANS.c.prep.EEG.downsamp.sr = 250;

%VA_TRANS.c.prep.EEG.rec.sr = 250;           % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
%VA_TRANS.c.prep.EEG.downsamp.sr = 250;  'downsample is off'

% Need to check the sr and downsample sr from config
VA_TRANS.c.prep.EEG.rec.sr = eegConfig.EEGConfig.Frequency;           % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
VA_TRANS.c.prep.EEG.downsamp.sr = eegConfig.EEGConfig.Frequency;  'downsample is off'


% VA_TRANS.c.prep.EEG.downsamp.sr = 125;

% FlexEEG 3 channels 10-20 setup:       % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!!
if(eegConfig.EEGConfig.EEGChannels == 3)
    % FlexEEG 3 channels 10-20 setup:       % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!!
    VA_TRANS.c.prep.EEG.import.chNumber = 3;   
    VA_TRANS.c.prep.EEG.import.trigCh = VA_TRANS.c.prep.EEG.import.chNumber + 1;
    VA_TRANS.c.prep.EEG.import.chIDs = 1 : VA_TRANS.c.prep.EEG.import.chNumber;
    VA_TRANS.c.prep.EEG.rec.ch.name = {'C3';'CZ';'C4'};
    VA_TRANS.c.prep.EEG.used.ch.name = VA_TRANS.c.prep.EEG.rec.ch.name;       % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% VA_TRANS.c.prep.EEG.used.ch.name = {'FP1';'FP2';'F3';'FZ';'F4';'C3';'CZ';'C4';'P3';'PZ';'P4';'PO7';'PO8'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% VA_TRANS.c.prep.EEG.used.ch.name = {'F3';'FZ';'F4';'C3';'CZ';'C4';'P3';'PZ';'P4'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
elseif eegConfig.EEGConfig.EEGChannels == 8

% % FlexEEG 8 channels 10-20 setup:       % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
    VA_TRANS.c.prep.EEG.import.chNumber = 8;   
    VA_TRANS.c.prep.EEG.import.trigCh = VA_TRANS.c.prep.EEG.import.chNumber + 1;
    VA_TRANS.c.prep.EEG.import.chIDs = 1 : VA_TRANS.c.prep.EEG.import.chNumber;
    VA_TRANS.c.prep.EEG.rec.ch.name = {'C3';'CZ';'C4';'P3';'O1';'P7';'OZ';'PZ'};
    VA_TRANS.c.prep.EEG.used.ch.name = VA_TRANS.c.prep.EEG.rec.ch.name;       % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
    % VA_TRANS.c.prep.EEG.used.ch.name = {'FP1';'FP2';'F3';'FZ';'F4';'C3';'CZ';'C4';'P3';'PZ';'P4';'PO7';'PO8'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
    % VA_TRANS.c.prep.EEG.used.ch.name = {'F3';'FZ';'F4';'C3';'CZ';'C4';'P3';'PZ';'P4'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
    % VA_TRANS.c.prep.EEG.dummy.ch.name = {'F3';'FZ';'F4';'P3';'PZ';'P4';'T7';'T8'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
    % VA_TRANS.c.prep.EEG.dummy.ch.name = {'FP1';'FP2';'T7';'T8';'PO7';'PO8';'OZ'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
else
    error("Can't handle the number of channels from the config. The number is %s \n", eegConfig.EEGConfig.EEGChannels)
end 

VA_TRANS.c.prep.EEG.dummy.ch.name = {'F3';'FZ';'F4';'P3';'PZ';'P4';'T7';'T8'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% VA_TRANS.c.prep.EEG.dummy.ch.name = {'FP1';'FP2';'T7';'T8';'PO7';'PO8';'OZ'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 

% % FlexEEG 8 channels 10-20 setup:       % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% VA_TRANS.c.prep.EEG.import.chNumber = 8;   
% VA_TRANS.c.prep.EEG.import.trigCh = VA_TRANS.c.prep.EEG.import.chNumber + 1;
% VA_TRANS.c.prep.EEG.import.chIDs = 1 : VA_TRANS.c.prep.EEG.import.chNumber;
% VA_TRANS.c.prep.EEG.rec.ch.name = {'C3';'CZ';'C4';'P3';'O1';'P7';'OZ';'PZ'};
% VA_TRANS.c.prep.EEG.used.ch.name = VA_TRANS.c.prep.EEG.rec.ch.name;       % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% % VA_TRANS.c.prep.EEG.used.ch.name = {'FP1';'FP2';'F3';'FZ';'F4';'C3';'CZ';'C4';'P3';'PZ';'P4';'PO7';'PO8'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% % VA_TRANS.c.prep.EEG.used.ch.name = {'F3';'FZ';'F4';'C3';'CZ';'C4';'P3';'PZ';'P4'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% % VA_TRANS.c.prep.EEG.dummy.ch.name = {'F3';'FZ';'F4';'P3';'PZ';'P4';'T7';'T8'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% % VA_TRANS.c.prep.EEG.dummy.ch.name = {'FP1';'FP2';'T7';'T8';'PO7';'PO8';'OZ'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 

% % FlexEEG MIF 8 channels 10-20 setup:       % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% VA_TRANS.c.prep.EEG.import.chNumber = 8;   
% VA_TRANS.c.prep.EEG.import.trigCh = VA_TRANS.c.prep.EEG.import.chNumber + 1;
% VA_TRANS.c.prep.EEG.import.chIDs = 1 : VA_TRANS.c.prep.EEG.import.chNumber;
% VA_TRANS.c.prep.EEG.rec.ch.name = {'C4';'C6';'C2';'CZ';'FZ';'C1';'C3';'C5'};
% VA_TRANS.c.prep.EEG.used.ch.name = VA_TRANS.c.prep.EEG.rec.ch.name;       % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% % VA_TRANS.c.prep.EEG.used.ch.name = {'FP1';'FP2';'F3';'FZ';'F4';'C3';'CZ';'C4';'P3';'PZ';'P4';'PO7';'PO8'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% % VA_TRANS.c.prep.EEG.used.ch.name = {'F3';'FZ';'F4';'C3';'CZ';'C4';'P3';'PZ';'P4'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% VA_TRANS.c.prep.EEG.dummy.ch.name = {'F3';'FZ';'F4';'P3';'PZ';'P4';'T7';'T8'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% % VA_TRANS.c.prep.EEG.dummy.ch.name = {'FP1';'FP2';'T7';'T8';'PO7';'PO8';'OZ'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 


% % g.Nautilus 16 channels 10-20 setup:       % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% VA_TRANS.c.prep.EEG.import.chNumber = 16;   
% VA_TRANS.c.prep.EEG.import.trigCh = VA_TRANS.c.prep.EEG.import.chNumber + 1;
% VA_TRANS.c.prep.EEG.import.chIDs = 1 : VA_TRANS.c.prep.EEG.import.chNumber;
% VA_TRANS.c.prep.EEG.rec.ch.name = {'FP1';'FP2';'F3';'FZ';'F4';'T7';'C3';'CZ';'C4';'T8';'P3';'PZ';'P4';'PO7';'PO8';'OZ'};
% VA_TRANS.c.prep.EEG.used.ch.name = VA_TRANS.c.prep.EEG.rec.ch.name;       % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% % VA_TRANS.c.prep.EEG.used.ch.name = {'FP1';'FP2';'F3';'FZ';'F4';'C3';'CZ';'C4';'P3';'PZ';'P4';'PO7';'PO8'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% % VA_TRANS.c.prep.EEG.used.ch.name = {'F3';'FZ';'F4';'C3';'CZ';'C4';'P3';'PZ';'P4'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% VA_TRANS.c.prep.EEG.dummy.ch.name = '';    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% % VA_TRANS.c.prep.EEG.dummy.ch.name = {'FP1';'FP2';'T7';'T8';'PO7';'PO8';'OZ'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 


% % g.Nautilus 28 channels 10-20 setup:       % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% VA_TRANS.c.prep.EEG.import.chNumber = 28;   
% VA_TRANS.c.prep.EEG.import.trigCh = VA_TRANS.c.prep.EEG.import.chNumber + 1;
% VA_TRANS.c.prep.EEG.import.chIDs = 1 : VA_TRANS.c.prep.EEG.import.chNumber;
% VA_TRANS.c.prep.EEG.rec.ch.name = {'AF3';'AF4';'F7';'F3';'FZ';'F4';'F8';'FC5';'FC1';'FC2';'FC6';'T7';'C3';'CZ';'C4';'T8';'CP5';'CP1';'CP2';'CP6';'P7';'P3';'PZ';'P4';'P8';'PO3';'PO4';'OZ'};
% VA_TRANS.c.prep.EEG.used.ch.name = VA_TRANS.c.prep.EEG.rec.ch.name;       % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% % VA_TRANS.c.prep.EEG.used.ch.name = {'FP1';'FP2';'F3';'FZ';'F4';'C3';'CZ';'C4';'P3';'PZ';'P4';'PO7';'PO8'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% % VA_TRANS.c.prep.EEG.used.ch.name = {'F3';'FZ';'F4';'C3';'CZ';'C4';'P3';'PZ';'P4'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% VA_TRANS.c.prep.EEG.dummy.ch.name = '';    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% % VA_TRANS.c.prep.EEG.dummy.ch.name = {'FP1';'FP2';'T7';'T8';'PO7';'PO8';'OZ'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 


% % g.Nautilus 32 channels 10-20 setup:       % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% VA_TRANS.c.prep.EEG.import.chNumber = 32;
% VA_TRANS.c.prep.EEG.import.trigCh = VA_TRANS.c.prep.EEG.import.chNumber + 1;
% VA_TRANS.c.prep.EEG.import.chIDs = 1 : VA_TRANS.c.prep.EEG.import.chNumber;
% VA_TRANS.c.prep.EEG.rec.ch.name = {'FP1';'FP2';'AF3';'AF4';'F7';'F3';'FZ';'F4';'F8';'FC5';'FC1';'FC2';'FC6'; ...
%                 'T7';'C3';'CZ';'C4';'T8';'CP5';'CP1';'CP2';'CP6';'P7';'P3';'PZ';'P4';'P8';'PO7';'PO3';'PO4';'PO8';'OZ'};
% VA_TRANS.c.prep.EEG.used.ch.name = VA_TRANS.c.prep.EEG.rec.ch.name;       % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% % VA_TRANS.c.prep.EEG.used.ch.name = {'F7';'F3';'FZ';'F4';'F8';'FC5';'FC1';'FC2';'FC6';'C3';'CZ';'C4';'CP5';'CP1';'CP2';'CP6';'P7';'P3';'PZ';'P4';'P8'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% % VA_TRANS.c.prep.EEG.used.ch.name = {'F7';'F3';'FZ';'F4';'F8';'FC5';'FC1';'FC2';'FC6';'C3';'CZ';'C4';'CP5';'CP1';'CP2';'CP6'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% VA_TRANS.c.prep.EEG.dummy.ch.name = '';    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% % VA_TRANS.c.prep.EEG.dummy.ch.name = {'FP1';'FP2';'T7';'T8';'PO7';'PO8';'OZ'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 

% % % spec 8 channels setup:       % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% VA_TRANS.c.prep.EEG.import.chNumber = 8;
% VA_TRANS.c.prep.EEG.import.trigCh = 10;
% VA_TRANS.c.prep.EEG.import.chIDs = 2 : VA_TRANS.c.prep.EEG.import.chNumber+1;
% VA_TRANS.c.prep.EEG.rec.ch.name = {'FC4';'FCZ';'FC3';'C3';'C6';'C5';'C4';'CZ'};
% VA_TRANS.c.prep.EEG.used.ch.name = VA_TRANS.c.prep.EEG.rec.ch.name;       % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% % VA_TRANS.c.prep.EEG.used.ch.name = {'FC4';'FCZ';'FC3';    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% VA_TRANS.c.prep.EEG.dummy.ch.name = '';    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% % VA_TRANS.c.prep.EEG.dummy.ch.name = {'FP1';'FP2';'T7';'T8';'PO7';'PO8';'OZ'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 

if ~exist('STACK')
  VA_TRANS = config_modification('',V1_TRANS, VA_TRANS);
else
  VA_TRANS = config_modification(STACK,'', VA_TRANS);
end

%% Normal Timing Setup 
% VA_TRANS.c.prep.trial.trig_PRE_ms = -1000-2000-0;    % -CLWinSize -priorSec (-instructionLenght) 
% VA_TRANS.c.prep.trial.trig_PST_ms = 6000;
% VA_TRANS.c.prep.trial.trig_PRE_ms = -1000-0-3000;    % -CLWinSize -priorSec (-instructionLenght) 
VA_TRANS.c.prep.trial.trig_PRE_ms = -3000;    % -CLWinSize -priorSec (-instructionLenght) 
% VA_TRANS.c.prep.trial.trig_PST_ms = 5000;
VA_TRANS.c.prep.trial.trig_PST_ms = 7000;
% VA_TRANS.c.prep.trial.trig_PRE_ms = -4000;    % -CLWinSize -priorSec (-instructionLenght) 
% VA_TRANS.c.prep.trial.trig_PST_ms = 5000;
% 
% % % % % % % % % VA_TRANS.c.prep.trial.eval.taskStartFromTrig_ms = 0;
% % % % % % % % % % VA_TRANS.c.prep.trial.eval.refPoint_fromTaskStart_ms = -800-0;    % -priorSec_of_intervalSide1 -instructionLenght_if_have_taskInfo_in_that 
% % % % % % % % % % VA_TRANS.c.prep.trial.eval.refIntervalShift1_ms = -200-0;    % -priorSec_of_intervalSide1 -instructionLenght_if_have_taskInfo_in_that 
% % % % % % % % % % VA_TRANS.c.prep.trial.eval.refIntervalShift2_ms = +200-0;    % -priorSec_of_intervalSide2 -instructionLenght_if_have_taskInfo_in_that 
% % % % % % % % % VA_TRANS.c.prep.trial.eval.refPoint_fromTaskStart_ms = -1000;    % -priorSec_of_intervalSide1 -instructionLenght_if_have_taskInfo_in_that 
% % % % % % % % % VA_TRANS.c.prep.trial.eval.refIntervalShift1_ms = 0;    % -priorSec_of_intervalSide1 -instructionLenght_if_have_taskInfo_in_that 
% % % % % % % % % VA_TRANS.c.prep.trial.eval.refIntervalShift2_ms = +400-0;    % -priorSec_of_intervalSide2 -instructionLenght_if_have_taskInfo_in_that 
% % % % % % % % % % VA_TRANS.c.prep.trial.eval.refPoint_fromTaskStart_ms = -1000-3000;    % -priorSec_of_intervalSide1 -instructionLenght_if_have_taskInfo_in_that 
% % % % % % % % % % VA_TRANS.c.prep.trial.eval.refPoint2_fromTaskStart_ms = -200-3000;    % -priorSec_of_intervalSide2 -instructionLenght_if_have_taskInfo_in_that 
% % % % % % % % % VA_TRANS.c.prep.trial.eval.peakIntervalShift1_ms = (VA_TRANS.c.prep.trial.eval.refIntervalShift1_ms - VA_TRANS.c.prep.trial.eval.refIntervalShift2_ms) /2;    % -priorSec_of_intervalSide1 -instructionLenght_if_have_taskInfo_in_that 
% % % % % % % % % VA_TRANS.c.prep.trial.eval.peakIntervalShift2_ms = (-1) * VA_TRANS.c.prep.trial.eval.peakIntervalShift1_ms;    % -priorSec_of_intervalSide2 -instructionLenght_if_have_taskInfo_in_that 
VA_TRANS.c.prep.trial.eval.smoothDistance_ms = 100;
% VA_TRANS.c.prep.trial.eval.smoothDistance_ms = 150;
VA_TRANS.c.prep.trial.eval.ref_interval_ms = [-1000,0];     % refPeakDA_searchInterval_basedOnTrig_ms
% VA_TRANS.c.prep.trial.eval.task_interval_ms = [400,5000];   % taskPeakDA_searchInterval_basedOnTrig_ms
VA_TRANS.c.prep.trial.eval.task_interval_ms = [400,7000];   % taskPeakDA_searchInterval_basedOnTrig_ms

% % % % % % % % % VA_TRANS.c.prep.trial.eval.taskStartFromTrig_ms = 0;
% % % % % % % % % % VA_TRANS.c.prep.trial.eval.refPoint_fromTaskStart_ms = -800-0;    % -priorSec_of_intervalSide1 -instructionLenght_if_have_taskInfo_in_that 
% % % % % % % % % % VA_TRANS.c.prep.trial.eval.refIntervalShift1_ms = -200-0;    % -priorSec_of_intervalSide1 -instructionLenght_if_have_taskInfo_in_that 
% % % % % % % % % % VA_TRANS.c.prep.trial.eval.refIntervalShift2_ms = +200-0;    % -priorSec_of_intervalSide2 -instructionLenght_if_have_taskInfo_in_that 
% % % % % % % % % VA_TRANS.c.prep.trial.eval.refPoint_fromTaskStart_ms = -1000;    % -priorSec_of_intervalSide1 -instructionLenght_if_have_taskInfo_in_that 
% % % % % % % % % VA_TRANS.c.prep.trial.eval.refIntervalShift1_ms = 0;    % -priorSec_of_intervalSide1 -instructionLenght_if_have_taskInfo_in_that 
% % % % % % % % % VA_TRANS.c.prep.trial.eval.refIntervalShift2_ms = +400-0;    % -priorSec_of_intervalSide2 -instructionLenght_if_have_taskInfo_in_that 
% % % % % % % % % % VA_TRANS.c.prep.trial.eval.refPoint_fromTaskStart_ms = -1000-3000;    % -priorSec_of_intervalSide1 -instructionLenght_if_have_taskInfo_in_that 
% % % % % % % % % % VA_TRANS.c.prep.trial.eval.refPoint2_fromTaskStart_ms = -200-3000;    % -priorSec_of_intervalSide2 -instructionLenght_if_have_taskInfo_in_that 
% % % % % % % % % VA_TRANS.c.prep.trial.eval.peakIntervalShift1_ms = (VA_TRANS.c.prep.trial.eval.refIntervalShift1_ms - VA_TRANS.c.prep.trial.eval.refIntervalShift2_ms) /2;    % -priorSec_of_intervalSide1 -instructionLenght_if_have_taskInfo_in_that 
% % % % % % % % % VA_TRANS.c.prep.trial.eval.peakIntervalShift2_ms = (-1) * VA_TRANS.c.prep.trial.eval.peakIntervalShift1_ms;    % -priorSec_of_intervalSide2 -instructionLenght_if_have_taskInfo_in_that 
% VA_TRANS.c.prep.trial.eval.smoothDistance_ms = 100;
% % VA_TRANS.c.prep.trial.eval.smoothDistance_ms = 150;
% VA_TRANS.c.prep.trial.eval.ref_interval_ms = [-1000,0];     % refPeakDA_searchInterval_basedOnTrig_ms
% % VA_TRANS.c.prep.trial.eval.task_interval_ms = [400,5000];   % taskPeakDA_searchInterval_basedOnTrig_ms
% VA_TRANS.c.prep.trial.eval.task_interval_ms = [400,7000];   % taskPeakDA_searchInterval_basedOnTrig_ms


% %% BCI competition IV 2A 
% VA_TRANS.c.prep.trial.trig_PRE_ms = -2000;    % -CLWinSize -priorSec (-instructionLenght) 
% VA_TRANS.c.prep.trial.trig_PST_ms = 4000;
% VA_TRANS.c.prep.trial.eval.smoothDistance_ms = 100;
% VA_TRANS.c.prep.trial.eval.ref_interval_ms = [-1000,0];     % refPeakDA_searchInterval_basedOnTrig_ms
% VA_TRANS.c.prep.trial.eval.task_interval_ms = [1000,4000];   % taskPeakDA_searchInterval_basedOnTrig_ms


VA_TRANS.c.prep.EEG.filt.refFilt.usedMethod.non0_CAR1_Laplace2 = 0;       % used reference filter: =0:notUsed, =1:CAR, ((=2:Laplace))
VA_TRANS.c.prep.EEG.filt.bandFilt.usedFeature_bandpass1_bandpower2 = 1;



%% Band basis-setup

    VA_TRANS.c.prep.EEG.filt.bandPass.band_pass_dB = 1;
    VA_TRANS.c.prep.EEG.filt.bandPass.band_stop_dB = 60;

% %     % % % Band setup (setup2B):
% %     % % Domain 1:  (0.5)4-10(16)Hz
% %     % % Domain 2:   (4)10-16(22)Hz
% %     % % Domain 3:  (10)16-22(28)Hz
% %     % % Domain 4:  (16)22-28(34)Hz
% %     % % Domain 5:  (22)28-34(40)Hz
% %     % % Domain 6:  (28)34-40(46)Hz
% %     % Set1
% %     % wFFTdomainID = 1;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,1).low1 = 0.5;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,1).low2 = 4;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,1).high1 = 10;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,1).high2 = 16;
% %     % Set2
% %     % wFFTdomainID = 2;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,2).low1 = 4;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,2).low2 = 10;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,2).high1 = 16;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,2).high2 = 22;
% %     % Set3
% %     % wFFTdomainID = 3;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,3).low1 = 10;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,3).low2 = 16;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,3).high1 = 22;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,3).high2 = 28;
% %     % Set4
% %     % wFFTdomainID = 4;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,4).low1 = 16;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,4).low2 = 22;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,4).high1 = 28;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,4).high2 = 34;
% %     % Set5
% %     % wFFTdomainID = 5;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,5).low1 = 22;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,5).low2 = 28;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,5).high1 = 34;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,5).high2 = 40;
% %     % wFFTdomainID = 6;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,6).low1 = 28;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,6).low2 = 34;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,6).high1 = 40;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,6).high2 = 46;

    % % % Band setup (setup2B):
    % % Domain 1B:(0.01)2-2(6)Hz
    % % Domain 1: (0.01)2-4(8)Hz
    % % Domain 2:    (2)4-8(14)Hz
    % % Domain 3:    (4)8-12(18)Hz
    % % Domain 4:   (6)12-18(26)Hz
    % % Domain 5:  (12)18-28(36)Hz
    % % Domain 6:  (22)28-40(48)Hz
    % % % Set1B
    % % % wFFTdomainID = 1;
    % % VA_TRANS.c.prep.EEG.filt.bandPass.band(1,1).low1 = 0.01;
    % % VA_TRANS.c.prep.EEG.filt.bandPass.band(1,1).low2 = 2;
    % % VA_TRANS.c.prep.EEG.filt.bandPass.band(1,1).high1 = 2;
    % % VA_TRANS.c.prep.EEG.filt.bandPass.band(1,1).high2 = 6;
    % Set1D
    % wFFTdomainID = 1;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,1).low1 = 0.01;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,1).low2 = 0.5;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,1).high1 = 4;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,1).high2 = 8;
% %     % Set1D1
% %     % wFFTdomainID = 1;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,1).low1 = 0.01;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,1).low2 = 0.5;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,1).high1 = 2;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,1).high2 = 6;
% %     % Set1D2
% %     % wFFTdomainID = 1;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,1).low1 = 0.5;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,1).low2 = 2;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,1).high1 = 4;
% %     VA_TRANS.c.prep.EEG.filt.bandPass.band(1,1).high2 = 8;
    % Set2
    % wFFTdomainID = 2;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,2).low1 = 2;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,2).low2 = 4;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,2).high1 = 8;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,2).high2 = 14;
    % Set3
    % wFFTdomainID = 3;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,3).low1 = 4;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,3).low2 = 8;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,3).high1 = 12;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,3).high2 = 18;
    % Set4
    % wFFTdomainID = 4;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,4).low1 = 6;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,4).low2 = 12;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,4).high1 = 18;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,4).high2 = 26;
    % Set5
    % wFFTdomainID = 5;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,5).low1 = 12;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,5).low2 = 18;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,5).high1 = 28;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,5).high2 = 36;
    % wFFTdomainID = 6;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,6).low1 = 22;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,6).low2 = 28;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,6).high1 = 40;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,6).high2 = 48;
    
    % Set1D1
    % wFFTdomainID = 11;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,11).low1 = 0.01;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,11).low2 = 0.5;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,11).high1 = 2;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,11).high2 = 6;
    % Set1D2
    % wFFTdomainID = 12;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,12).low1 = 0.5;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,12).low2 = 2;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,12).high1 = 4;
    VA_TRANS.c.prep.EEG.filt.bandPass.band(1,12).high2 = 8;


%% Function
% T1_mixed_result_table__from_ALLCh9Ch_CF1sCF2s and wm_taskID based config modification

function VA_TRANS = config_modification(STACK,V1_TRANS, VA_TRANS)
  if isempty(V1_TRANS)
    for tmp_wm = 1 : size(STACK.varNameList,1)
     if strcmp(STACK.varNameList{tmp_wm,1},'V1_TRANS')
       V1_TRANS = STACK.var{1,tmp_wm};
     end
    end
  end
  wm_taskID = V1_TRANS.wm_taskID;
  
  if isfield(V1_TRANS,'T1_mixed_result_table__from_ALLCh9Ch_CF1sCF2s') % for code: without band set option
    VA_TRANS.T1_mixed_result_table__from_ALLCh9Ch_CF1sCF2s = V1_TRANS.T1_mixed_result_table__from_ALLCh9Ch_CF1sCF2s;
    VA_TRANS.wm_T1TATM_taskID = wm_taskID;
    wm = VA_TRANS.T1_mixed_result_table__from_ALLCh9Ch_CF1sCF2s(wm_taskID,1);
  end
  if isfield(V1_TRANS,'T1_mixed_result_table__from_ALLCh9Ch_CF1sCF2s_BandSetID') % for code: without band set option
    VA_TRANS.T1_mixed_result_table__from_ALLCh9Ch_CF1sCF2s_BandSetID = V1_TRANS.T1_mixed_result_table__from_ALLCh9Ch_CF1sCF2s_BandSetID;
    VA_TRANS.wm_T1TATM_taskID = wm_taskID;
    wm = VA_TRANS.T1_mixed_result_table__from_ALLCh9Ch_CF1sCF2s_BandSetID(wm_taskID,1);
  end
  
  if exist('wm','var')
    if wm < 100
      wm12 = wm - (fix(wm/100)*100);
    else
      wm12 = fix(wm/10);
    end
    if (wm12 == 11) || (wm12 == 12)
      VA_TRANS.c.prep.EEG.rec.ch.name = {'FP1';'FP2';'F3';'FZ';'F4';'T7';'C3';'CZ';'C4';'T8';'P3';'PZ';'P4';'PO7';'PO8';'OZ'};
      VA_TRANS.c.prep.EEG.used.ch.name = VA_TRANS.c.prep.EEG.rec.ch.name;       % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
      VA_TRANS.c.prep.EEG.dummy.ch.name = '';    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
    elseif (wm12 == 91) || (wm12 == 92)
      VA_TRANS.c.prep.EEG.rec.ch.name = {'FP1';'FP2';'F3';'FZ';'F4';'T7';'C3';'CZ';'C4';'T8';'P3';'PZ';'P4';'PO7';'PO8';'OZ'};
      VA_TRANS.c.prep.EEG.used.ch.name = {'F3';'FZ';'F4';'C3';'CZ';'C4';'P3';'PZ';'P4'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
      VA_TRANS.c.prep.EEG.dummy.ch.name = {'FP1';'FP2';'T7';'T8';'PO7';'PO8';'OZ'};    % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
    else
      BREAK_THE_CODE_HERE_WITH_ERROR
    end
  end
  
  if exist('wm','var')
    if wm > 99   % for code: with band set selection
      wm3 = mod(wm,10);
      VA_TRANS.c.classSetup.band.usedIDs = V1_TRANS.T1_mixed_result_table__BandSets(wm3,:); 
    end
  end
  
end


%% Comments









