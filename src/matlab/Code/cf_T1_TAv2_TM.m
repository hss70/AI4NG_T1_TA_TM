% Config file for
% Task manager for: 
% Evaluation of FilterBankCSP Classification, offline EEG trainTest figures

% Input structures

% Output structures

% REQUIRESTMENT: Matlab
% Copyright(c)2020 Attila Korik, http://isrc.ulster.ac.uk/akorik/contact.html


%% V1 Setup

% V1_TRANS.f.HomeDir = 'Q:\BCI\DCR\FBCSP 2022-CL';
tmp_dir = pwd;
cd ..; 
V1_TRANS.f.HomeDir = pwd 
cd(tmp_dir); 
clearvars tmp_dir

% V1_TRANS.f.SourceDataDir = [V1_TRANS.f.HomeDir,'\Work\SourceData'];   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
V1_TRANS.f.SourceDataDir =  [V1_TRANS.f.HomeDir,'\Work\SourceData (EEG_rec)'];   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! 
% 
% V1_TRANS.f.SourceDataName = 'tr.mat';   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!!
V1_TRANS.f.SourceDataName = 'EEG_rec.mat';   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!!

V1_TRANS.f.PreviousResultDir =  [V1_TRANS.f.HomeDir,'\Work\T1\Results'];   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! % ='': full data - OTHERWISE: have to set old result T1/Result dir for expeption of currently processed data 
% V1_TRANS.f.PreviousResultDir = [V1_TRANS.f.HomeDir,'\Results\Perm3, B3-6, cf1s (parts)\part 02 stop with ERROR (+ q&a)\T1\Results'];   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! % ='': full data - OTHERWISE: have to set old result T1/Result dir for expeption of currently processed data 

V1_TRANS.f.BaseDir = [V1_TRANS.f.HomeDir,'\Work'];   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! % =1: task VS relax classification pair used      
% % % % V1_TRANS.f.BaseDir_for_trainTest = [V1_TRANS.f.HomeDir,'\Work'];   % !!!!!!!!!!!!!!!! CHECK THIS !!!!!!!!!!!!!!!! % =1: task VS relax classification pair used      
V1_TRANS.f.DataSubDir = 'TMP Data';
V1_TRANS.f.TrainTestSubDir = 'TrainTest';
V1_TRANS.f.Subj1Sess1SubDir = 'Subj 01\Session 01';
% % % % VA_TRANS.f.classSubDir{1} = '01 LR';
% % % % VA_TRANS.f.classSubDir{2} = '02 FR';
% % % % VA_TRANS.f.classSubDir{3} = '03 LF';
V1_TRANS.f.classSubDir{1} = 'EEG';

V1_TRANS.f.T1_subDir = 'T1';
% V1_TRANS.f.T1_online_subSubDir = '';          % if='': not used (including auto-selected conf & w0_matrix ...)
V1_TRANS.f.T1_online_subSubDir = 'Online';          % if='': not used (including auto-selected conf & w0_matrix ...)
% V1_TRANS.f.T1_param_subSubDir = '';          % if='': not used (including auto-selected conf & w0_matrix ...)
V1_TRANS.f.T1_param_subSubDir = 'Param';          % if='': not used (including auto-selected conf & w0_matrix ...)
V1_TRANS.f.T1_param2_subSubDir = '';          % if='': not used (including auto-selected conf & w0_matrix ...)
% V1_TRANS.f.T1_param2_subSubDir = 'Param2';          % if='': not used (including auto-selected conf & w0_matrix ...)
% V1_TRANS.f.T1_result_subSubDir = '';  % if='': not used (including results of the auto-selected FBCSP)
V1_TRANS.f.T1_results_subSubDir = 'Results';  % if='': not used (including results of the auto-selected FBCSP)
V1_TRANS.f.save__T1_results = 0;  % =1: save 'T1 [result_table].mat', =0: NOT save 'T1 [result_table].mat'

% % % % V1_TRANS.f.T1_results_fileName = 'T1 [results].mat';
% % % % V1_TRANS.f.T1_result_table_fileName = 'T1 [result_table].mat';

V1_TRANS.f.chanlocs_dir = [V1_TRANS.f.HomeDir,'\Code'];
% V1_TRANS.f.chanlocs_dir = 'C:\BCI\DCR\191217 CL\Code';
V1_TRANS.f.chanlocs_filename = 'Standard-10-20-Cap81.locs';


V1_TRANS.processed_taskIDs = '';
% V1_TRANS.processed_taskIDs = [122, 130, 142:174, 209:309, 338:366];

V1_TRANS.SW.T1_maxTrainTestTry = 0;  % possible options: =0, =1, =2, =3")



%% Comments






