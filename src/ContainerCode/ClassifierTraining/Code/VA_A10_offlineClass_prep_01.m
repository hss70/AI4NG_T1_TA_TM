% Multi-class Classification, offline EEG preprocessing

% Input structures

% Output structures
% tr{wm_subjID2,wm_sessionID2}{wm_bandID,wm_targetID}(wk,wt,wm_trialID)


% REQUIRESTMENT: Matlab
% Copyright(c)2019 Attila Korik, http://isrc.prep.ulster.ac.prep.uk/akorik/contact.html


%% Function headline

% % % % function VA_C2019_A10_offlineClass_prep_01(VA)
% % % % % function FN_out = VA_C2019_A10_offlineClass_prep_01(FN_in)
% % % % % FN_out = 'N/A';
% % % % 
% % % % % % %% VA Setup
% % % % % % if VA.SW
% % % % % % end

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

if VA.SW
    autorun.prep.used.subjects = VA.autorun.used.subjects;
    autorun.prep.used.sessions = VA.autorun.used.sessions;
else
    % autorun.prep.used.subjects = 1:10;
    % autorun.prep.used.subjects = [2,5,11];
    autorun.prep.used.subjects = 12;
    % autorun.prep.used.sessions = 1:3;
    autorun.prep.used.sessions = 5;
end

if VA.SW
    c.prep.EEG.import.chNumber = VA.c.prep.EEG.import.chNumber;
    c.prep.EEG.import.trigCh = VA.c.prep.EEG.import.trigCh;
    c.prep.EEG.import.chIDs = VA.c.prep.EEG.import.chIDs;
    c.prep.EEG.rec.ch.name = VA.c.prep.EEG.rec.ch.name;
    c.prep.EEG.used.ch.name = VA.c.prep.EEG.used.ch.name;
    c.prep.EEG.dummy.ch.name = VA.c.prep.EEG.dummy.ch.name;
else
    % c.prep.EEG.import.chNumber = 16;
    % c.prep.EEG.import.trigCh = 18;
    % c.prep.EEG.import.chIDs = 2 : c.prep.EEG.import.chNumber+1;
    % % c.prep.EEG.rec.ch.name = {'F3';'F4';'FC5';'FC1';'FC2';'FC6';'C3';'CZ';'C4';'CP5';'CP1';'CP2';'CP6';'P3';'PZ';'P4'; ...
    % %                           'AF3';'AF4';'F7';'FZ';'F8';'T7';'T8';'P7';'P8';'PO3';'PO4';'O1';'OZ';'O2';'EOGH';'EOGV'};
    % % c.prep.EEG.rec.ch.name = {'F3';'F4';'FC5';'FC1';'FC2';'FC6';'C3';'CZ';'C4';'CP5';'CP1';'CP2';'CP6';'P3';'PZ';'P4'; ...
    % %                           'AF3';'AF4';'F7';'FZ';'F8';'T7';'T8';'P7';'P8';'PO3';'PO4';'O1';'OZ';'O2'};
    % % c.prep.EEG.rec.ch.name = {'F3';'F4';'FC5';'FC1';'FC2';'FC6';'C3';'CZ';'C4';'CP5';'CP1';'CP2';'CP6';'P3';'PZ';'P4'};
    
    % % g.Nautilus 16 channels 10-20 setup:
    % c.prep.EEG.import.chNumber = 16;
    % c.prep.EEG.import.trigCh = 18;
    % c.prep.EEG.import.chIDs = 2 : c.prep.EEG.import.chNumber+1;
    % c.prep.EEG.rec.ch.name = {'FP1';'FP2';'F3';'FZ';'F4';'T7';'C3';'CZ';'C4';'T8';'P3';'PZ';'P4';'PO7';'PO8';'OZ'};
    
    % g.Nautilus 32 channels 10-20 setup:
    c.prep.EEG.import.chNumber = 32;
    c.prep.EEG.import.trigCh = 34;
    c.prep.EEG.import.chIDs = 2 : c.prep.EEG.import.chNumber+1;
    c.prep.EEG.rec.ch.name = {'FP1';'FP2';'AF3';'AF4';'F7';'F3';'FZ';'F4';'F8';'FC5';'FC1';'FC2';'FC6'; ...
                              'T7';'C3';'CZ';'C4';'T8';'CP5';'CP1';'CP2';'CP6';'P7';'P3';'PZ';'P4';'P8';'PO7';'PO3';'PO4';'PO8';'OZ'};
	c.prep.EEG.used.ch.name = c.prep.EEG.rec.ch.name;
    % c.prep.EEG.used.ch.name = {'F7';'F3';'FZ';'F4';'F8';'FC5';'FC1';'FC2';'FC6';'C3';'CZ';'C4';'CP5';'CP1';'CP2';'CP6';'P7';'P3';'PZ';'P4';'P8'}; 
end
c.prep.EEG.rec.ch.ID = 1 : size(c.prep.EEG.rec.ch.name,1);

if VA.SW
    c.prep.trial = VA.c.prep.trial;
else
    c.prep.trial.trig_PRE_ms = -1000-2000;
    c.prep.trial.trig_PST_ms = 6000;
end

if VA.SW
    c.prep.EEG.filt.refFilt.usedMethod.non0_CAR1_Laplace2 = VA.c.prep.EEG.filt.refFilt.usedMethod.non0_CAR1_Laplace2;
    c.prep.EEG.filt.bandFilt.usedFeature_bandpass1_bandpower2 = VA.c.prep.EEG.filt.bandFilt.usedFeature_bandpass1_bandpower2;
else
    c.prep.EEG.filt.refFilt.usedMethod.non0_CAR1_Laplace2 = 0;       % used reference filter: =0:notUsed, =1:CAR, ((=2:Laplace))
    c.prep.EEG.filt.bandFilt.usedFeature_bandpass1_bandpower2 = 1;
end

% !!!!!!!!!!!!!! Normalization method not written yet !!!!!!!!!!!!!!
c.prep.EEG.norm.notUsed0_identificBaseline1_globalBaseline2 = 0;     %  =0:not used, =1:EEG data norm separately for each (wm_run, wm_targetID, wk, wm_band), =2:EEG data norm separately for each (wk, wm_band) using mean of result from (wm_run, wm_targetID) 
if c.prep.EEG.norm.notUsed0_identificBaseline1_globalBaseline2 == 1
    c.prep.EEG.norm.beginOfIntervalFromCue_ms.beforeTrig = -2000;    % this ms is the distance of the beginniong of the normalization interval and onset of the movement 
    c.prep.EEG.norm.endOfIntervalFromCue_ms.beforeTrig = -100;       % this ms is the distance of the end of the normalization interval and onset of the movement 
end

% % c.prep.experiment.target.IDs = 1:5;
% % c.prep.experiment.target.name{1,1} = 'Sphere';
% % c.prep.experiment.target.name{2,1} = 'Cone';
% % c.prep.experiment.target.name{3,1} = 'Pyramid';
% % c.prep.experiment.target.name{4,1} = 'Cylinder';
% % c.prep.experiment.target.name{5,1} = 'Cube';
c.prep.experiment.target.IDs = 1:2;
c.prep.experiment.target.name{1,1} = 'T1';
c.prep.experiment.target.name{2,1} = 'T2';

% % c.prep.experiment.run.number = 3;
% % c.prep.experiment.block.number = 4;
% % % c.prep.experiment.target.number = 5;     % number of shapes
% % c.prep.experiment.target.number = size(c.prep.experiment.target.IDs,2);     % number of shapes
% % c.prep.experiment.task.repeat = 6;       % repeations of the same target (shape) in the same block
c.prep.experiment.run.number = 1;
c.prep.experiment.block.number = 1;
% c.prep.experiment.target.number = 5;     % number of shapes
c.prep.experiment.target.number = size(c.prep.experiment.target.IDs,2);     % number of shapes
% % c.prep.experiment.task.repeat = 6;       % repeations of the same target (shape) in the same block
% % % % c.prep.experiment.task.repeat = 30;       % repeations of the same target (shape) in the same block


% Bandpower bandpass filter (+ downsampling) config
% _________________________________________________

if VA.SW
    c.prep.EEG.rec.sr = VA.c.prep.EEG.rec.sr;
    c.prep.EEG.downsamp.sr = VA.c.prep.EEG.downsamp.sr;
else
    c.prep.EEG.rec.sr = 250;
    % c.prep.EEG.rec.sr = 125;
    % c.prep.EEG.downsamp.sr = 250;    % !!!!!!!!!!!!!!!!!! Dowwnsampled sampling rate (Hz) !!!!!!!!!!!!!!!!!!
    c.prep.EEG.downsamp.sr = 125;    % !!!!!!!!!!!!!!!!!! Dowwnsampled sampling rate (Hz) !!!!!!!!!!!!!!!!!!
end

% !!!!!!!!!!!!!!!!! NOT NEED THIS HERE !!!!!!!!!!!!!!!!!
% % %     w.c.prep.EEG.filt.bandPass.used_bandIDs = 1:6;
%     w.c.prep.EEG.filt.bandPass.used_bandIDs = 3:6;
%     % w.c.prep.EEG.filt.bandPass.usewd_bandIDs = 3:6;

    if c.prep.EEG.filt.bandFilt.usedFeature_bandpass1_bandpower2 == 2
        c.prep.EEG.filt.bandPower.windowSizeInSec = 0.25;    % bandpower calculation window size in seconds (250ms involve a full period of 4Hz signal + it is no miss info until timeLagDistance(LD)<=200ms : maybe use LD=200ms_with_lagNumber=5(sampleNumber=5+1=6)_at_8channels)
        c.prep.EEG.filt.bandPower.windowSizeInSamples = round(c.prep.EEG.filt.bandPower.windowSizeInSec * c.prep.PR.EEG.sr);       % bandpower calculation window size in samples
    end

% % % %     c.prep.EEG.features.sr = c.prep.EEG.rec.sr;

% % % %     c.prep.EEG.filt.bandPass.band_pass_dB = 1;
% % % %     c.prep.EEG.filt.bandPass.band_stop_dB = 60;
% % % % 
% % % % % %     % % % Band setup (setup2B):
% % % % % %     % % Domain 1:  (0.5)4-10(16)Hz
% % % % % %     % % Domain 2:   (4)10-16(22)Hz
% % % % % %     % % Domain 3:  (10)16-22(28)Hz
% % % % % %     % % Domain 4:  (16)22-28(34)Hz
% % % % % %     % % Domain 5:  (22)28-34(40)Hz
% % % % % %     % % Domain 6:  (28)34-40(46)Hz
% % % % % %     % Set1
% % % % % %     % wFFTdomainID = 1;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,1).low1 = 0.5;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,1).low2 = 4;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,1).high1 = 10;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,1).high2 = 16;
% % % % % %     % Set2
% % % % % %     % wFFTdomainID = 2;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,2).low1 = 4;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,2).low2 = 10;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,2).high1 = 16;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,2).high2 = 22;
% % % % % %     % Set3
% % % % % %     % wFFTdomainID = 3;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,3).low1 = 10;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,3).low2 = 16;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,3).high1 = 22;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,3).high2 = 28;
% % % % % %     % Set4
% % % % % %     % wFFTdomainID = 4;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,4).low1 = 16;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,4).low2 = 22;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,4).high1 = 28;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,4).high2 = 34;
% % % % % %     % Set5
% % % % % %     % wFFTdomainID = 5;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,5).low1 = 22;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,5).low2 = 28;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,5).high1 = 34;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,5).high2 = 40;
% % % % % %     % wFFTdomainID = 6;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,6).low1 = 28;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,6).low2 = 34;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,6).high1 = 40;
% % % % % %     c.prep.EEG.filt.bandPass.band(1,6).high2 = 46;
% % % % 
% % % %     % % % Band setup (setup2B):
% % % %     % % Domain 1B:(0.01)2-2(6)Hz
% % % %     % % Domain 1: (0.01)2-4(8)Hz
% % % %     % % Domain 2:    (2)4-8(14)Hz
% % % %     % % Domain 3:    (4)8-12(18)Hz
% % % %     % % Domain 4:   (6)12-18(26)Hz
% % % %     % % Domain 5:  (12)18-28(36)Hz
% % % %     % % Domain 6:  (22)28-40(48)Hz
% % % %     % Set1B
% % % %     % wFFTdomainID = 1;
% % % %     c.prep.EEG.filt.bandPass.band(1,1).low1 = 0.01;
% % % %     c.prep.EEG.filt.bandPass.band(1,1).low2 = 2;
% % % %     c.prep.EEG.filt.bandPass.band(1,1).high1 = 2;
% % % %     c.prep.EEG.filt.bandPass.band(1,1).high2 = 6;
% % % %     % Set2
% % % %     % wFFTdomainID = 2;
% % % %     c.prep.EEG.filt.bandPass.band(1,2).low1 = 2;
% % % %     c.prep.EEG.filt.bandPass.band(1,2).low2 = 4;
% % % %     c.prep.EEG.filt.bandPass.band(1,2).high1 = 8;
% % % %     c.prep.EEG.filt.bandPass.band(1,2).high2 = 14;
% % % %     % Set3
% % % %     % wFFTdomainID = 3;
% % % %     c.prep.EEG.filt.bandPass.band(1,3).low1 = 4;
% % % %     c.prep.EEG.filt.bandPass.band(1,3).low2 = 8;
% % % %     c.prep.EEG.filt.bandPass.band(1,3).high1 = 12;
% % % %     c.prep.EEG.filt.bandPass.band(1,3).high2 = 18;
% % % %     % Set4
% % % %     % wFFTdomainID = 4;
% % % %     c.prep.EEG.filt.bandPass.band(1,4).low1 = 6;
% % % %     c.prep.EEG.filt.bandPass.band(1,4).low2 = 12;
% % % %     c.prep.EEG.filt.bandPass.band(1,4).high1 = 18;
% % % %     c.prep.EEG.filt.bandPass.band(1,4).high2 = 26;
% % % %     % Set5
% % % %     % wFFTdomainID = 5;
% % % %     c.prep.EEG.filt.bandPass.band(1,5).low1 = 12;
% % % %     c.prep.EEG.filt.bandPass.band(1,5).low2 = 18;
% % % %     c.prep.EEG.filt.bandPass.band(1,5).high1 = 28;
% % % %     c.prep.EEG.filt.bandPass.band(1,5).high2 = 36;
% % % %     % wFFTdomainID = 6;
% % % %     c.prep.EEG.filt.bandPass.band(1,6).low1 = 22;
% % % %     c.prep.EEG.filt.bandPass.band(1,6).low2 = 28;
% % % %     c.prep.EEG.filt.bandPass.band(1,6).high1 = 40;
% % % %     c.prep.EEG.filt.bandPass.band(1,6).high2 = 48;
c.prep.EEG.filt.bandPass = VA_TRANS.c.prep.EEG.filt.bandPass;


% TimeSeries config
% _________________

% !!!!!!!!!!!!!!!!!!!!!! MAYBE NOT USED: config.fix.PR.trainTest.EEG.timeSeries. ... !!!!!!!!!!!!!!!!!!!!!! 
% % % % config.fix.EEG.features.used_singleBand1_multiBand2 = 2;     % =1: timeSeries involve one optimal band/channel, =2: timeSeries involve multipli bands/channel
% % % % if config.fix.EEG.features.usedFeature_bandpass1_bandpower2 == 1
% % % %     % used for first optimization step(s) (ok for PTS):
% % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.usedInOpt1(1,1).timeLagDist = 1;
% % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.usedInOpt1(1,1).timeLagNumber = 8;
% % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.usedInOpt1(2,1).timeLagDist = 3;
% % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.usedInOpt1(2,1).timeLagNumber = 8;
% % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.usedInOpt1(3,1).timeLagDist = 6;
% % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.usedInOpt1(3,1).timeLagNumber = 8;
% % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.usedInOpt1(4,1).timeLagDist = 12;
% % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.usedInOpt1(4,1).timeLagNumber = 8;
% % % %     
% % % %     % used for final optimization step(s) (ok for PTS):
% % % % % % % %     config.fix.PR.trainTest.EEG.timeSeries.ch_number_finalMin = 6;           % (in final set) min number of selected EEG channels (electrodes) in the input (bandpower) timeSeries 
% % % % % % % %     config.fix.PR.trainTest.EEG.timeSeries.ch_number_finalMax = 14;           % (in final set) max number of selected EEG channels (electrodes) in the input (bandpower) timeSeries 
% % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.basis.lag_distance_sample = [1,3,6,12];      % distance [by recorded EEG sample] of two samples in the input timeSeries (EEG SR=120Hz: 6->50ms, 12->100ms, ...) 
% % % %     % config.fix.PR.trainTest.EEG.timeSeries.timeLag.basis.lag_number = [1,2,4,8];   % number of selected samples in the input time series for one channel = config.fix.PR.trainTest.EEG.lag.number+1
% % % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.basis.lag_number = [0,1,2,4,8];   % number of selected samples in the input time series for one channel = config.fix.PR.trainTest.EEG.lag.number+1
% % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.basis.lag_number = [1,2,4,8];   % number of selected samples in the input time series for one channel = config.fix.PR.trainTest.EEG.lag.number+1
% % % %     % config.fix.PR.trainTest.EEG.timeSeries.timeLag.basis.maxTimeLagWindow_ms = 1200;       % Max size of the EEG input time series (ms)
% % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.basis.maxTimeLagWindow_ms = 1600;       % Basis: max size of the EEG input time series (ms) (it maybe shorter based on selected timeLagDistance and timeLagNumber combinations) 
% % % %     
% % % % elseif config.fix.EEG.features.usedFeature_bandpass1_bandpower2 == 2
% % % %     % used for first optimization step(s) (ok for BTS):
% % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.usedInOpt1(1,1).timeLagDist = 6;
% % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.usedInOpt1(1,1).timeLagNumber = 8;
% % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.usedInOpt1(2,1).timeLagDist = 12;
% % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.usedInOpt1(2,1).timeLagNumber = 8;
% % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.usedInOpt1(3,1).timeLagDist = 24;
% % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.usedInOpt1(4,1).timeLagNumber = 6;
% % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.usedInOpt1(5,1).timeLagDist = 36;
% % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.usedInOpt1(6,1).timeLagNumber = 4;
% % % %     
% % % %     % used for final optimization step(s) (ok for BTS):
% % % % % % % %     % config.fix.PR.trainTest.EEG.timeSeries.ch_number_finalMin = 6;           % (in final set) min number of selected EEG channels (electrodes) in the input (bandpower) timeSeries 
% % % % % % % %     config.fix.PR.trainTest.EEG.timeSeries.ch_number_finalMin = 8;           % (in final set) min number of selected EEG channels (electrodes) in the input (bandpower) timeSeries 
% % % % % % % %     config.fix.PR.trainTest.EEG.timeSeries.ch_number_finalMax = 14;           % (in final set) max number of selected EEG channels (electrodes) in the input (bandpower) timeSeries 
% % % % % % % % %     config.fix.PR.trainTest.EEG.timeSeries.ch_number_finalMax = 12;           % (in final set) max number of selected EEG channels (electrodes) in the input (bandpower) timeSeries 
% % % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.basis.lag_distance_sample = [12,24,48];      % distance [by recorded EEG sample] of two samples in the input timeSeries (EEG SR=120Hz: 6->50ms, 12->100ms, ...) 
% % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.basis.lag_distance_sample = [6,12,24];      % distance [by recorded EEG sample] of two samples in the input timeSeries (EEG SR=120Hz: 6->50ms, 12->100ms, ...) 
% % % %     % config.fix.PR.trainTest.EEG.timeSeries.timeLag.basis.lag_distance_sample = [0];      % distance [by recorded EEG sample] of two samples in the input timeSeries (EEG SR=120Hz: 6->50ms, 12->100ms, ...) 
% % % %     % config.fix.PR.trainTest.EEG.timeSeries.timeLag.basis.lag_number = [2,4,6,8];   % number of selected samples in the input time series for one channel = config.fix.PR.trainTest.EEG.lag.number+1
% % % %     % config.fix.PR.trainTest.EEG.timeSeries.timeLag.basis.lag_number = [0,1,2,4,8];   % number of selected samples in the input time series for one channel = config.fix.PR.trainTest.EEG.lag.number+1
% % % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.basis.lag_number = [1,2,4,8];   % number of selected samples in the input time series for one channel = config.fix.PR.trainTest.EEG.lag.number+1
% % % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.basis.lag_number = [0,2,4];   % number of selected samples in the input time series for one channel = config.fix.PR.trainTest.EEG.lag.number+1
% % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.basis.lag_number = [2,4,6];   % number of selected samples in the input time series for one channel = config.fix.PR.trainTest.EEG.lag.number+1
% % % %     % config.fix.PR.trainTest.EEG.timeSeries.timeLag.basis.lag_number = [0];   % number of selected samples in the input time series for one channel = config.fix.PR.trainTest.EEG.lag.number+1
% % % %     % config.fix.PR.trainTest.EEG.timeSeries.timeLag.basis.maxTimeLagWindow_ms = 1200;       % Max size of the EEG input time series (ms)
% % % %     % config.fix.PR.trainTest.EEG.timeSeries.timeLag.basis.maxTimeLagWindow_ms = 1600;       % Basis: max size of the EEG input time series (ms) (it maybe shorter based on selected timeLagDistance and timeLagNumber combinations) 
% % % %     config.fix.PR.trainTest.EEG.timeSeries.timeLag.basis.maxTimeLagWindow_ms = 1200;       % Basis: max size of the EEG input time series (ms) (it maybe shorter based on selected timeLagDistance and timeLagNumber combinations) 
% % % % end

% ______________
%
% Setup for load
% ______________

if VA.SW
    % autorun.file.load.autoload = VA.set.autorun.file.load.autoload;
    autorun.prep.file.load.autoload = 1;
    autorun.prep.file.load.path.EEG_rec = VA.set.autorun.f.load.path.EEG_rec;
    autorun.prep.file.load.path.validation = VA.set.autorun.f.load.path.validation;
else
    w.m = questdlg('Do you want to load input datasets ?','Setup','Select input directory','Load from default directory','Continue without loading','Load from default directory');
    if strcmp(w.m,'Load from default directory')
        autorun.prep.file.load.autoload = 1;
        autorun.prep.file.load.path.EEG_rec = 'Q:\BCI\Data\Data Shape 01\- Work (doubled2)\';
        autorun.prep.file.load.path.validation = 'Q:\BCI\Results\Shape 5B SC\SC09 EEG ch validation\allValid\';
        % autorun.prep.file.load.path.validation = 'Q:\BCI\Results\Shape 5B SC\SC09 EEG ch validation\validEEG\';
    elseif strcmp(w.m,'Select input directory')
        autorun.prep.file.load.autoload = 1;
        autorun.prep.file.load.path.EEG_rec = uigetdir('','Select input data directory');
        % autorun.prep.file.load.path.EEG_rec = [autorun.prep.file.load.path.EEG_rec,'\'];
            VA.w.wm_subDirID = 1;
            VA.f.classSubDir{VA.w.wm_subDirID} = autorun.prep.file.load.path.EEG_rec( max(find(autorun.prep.file.load.path.EEG_rec(1,:)=='\'))+1 : size(autorun.prep.file.load.path.EEG_rec,2));
            autorun.prep.file.load.path.EEG_rec = autorun.prep.file.load.path.EEG_rec( 1 : max(find(autorun.prep.file.load.path.EEG_rec(1,:)=='u'))-2);
        autorun.prep.file.load.path.validation = uigetdir('','Select validation directory');
        autorun.prep.file.load.path.validation = [autorun.prep.file.load.path.validation,'\'];
    else
        autorun.prep.file.load.autoload = 0;
    end
end
if autorun.prep.file.load.autoload == 1
    autorun.prep.file.load.nameBasis.EEG_rec_fileName = 'EEG_rec.mat';
    autorun.prep.file.load.nameBasis.EEG_validation_fileName = 'A09_EEG_validation_01';
end

% _______________
%
% Loading Dataset
% _______________

if autorun.prep.file.load.autoload == 1
    % fprintf('\n');
    
    % EEG validation
    % fprintf('A09_EEG_validation_01 [EEG_validation].mat ...\n');
    w.file.load.name = [autorun.prep.file.load.nameBasis.EEG_validation_fileName, ' [EEG_validation].mat'];
    fprintf(['Loading ',w.file.load.name,' ...\n']);
    TMP = load([autorun.prep.file.load.path.validation,w.file.load.name]);
    EEG_validation = TMP.copy_of_EEG_validation;
    clear TMP
    
    fprintf('Dataset loading: DONE\n');
    % fprintf('\n');
end

% ______________
%
% Setup for save
% ______________

if VA.SW
    % autorun.file.save.autosave = VA.set.autorun.f.save.autosave;
    autorun.prep.file.save.autosave = 1;
    autorun.prep.file.save.path = VA.set.autorun.f.save.path;
    autorun.prep.file.save.nameBasis.A10_offlineClass_prep = 'A10_offlineClass_prep_01';
else
    w.m = questdlg('Do you want to save result files ?','Setup','Auto save','Not save','Auto save');
    if strcmp(w.m,'Auto save')
        % [autorun.prep.file.save.nameBasis, autorun.prep.file.save.path] = uiputfile(strcat('D4_31_EEG_Bandpower_09.mat'),'Set up result directory and filename');
        % autorun.prep.file.save.nameBasis1 = autorun.prep.file.save.nameBasis( 1 : max(find(autorun.prep.file.save.nameBasis(1,:)=='.'))-1);
        autorun.prep.file.save.autosave = 1;

        autorun.prep.file.save.path = uigetdir('','Set directory for the result');
        autorun.prep.file.save.path = [autorun.prep.file.save.path,'\'];

        autorun.prep.file.save.nameBasis.A10_offlineClass_prep = 'A10_offlineClass_prep_01';
    else
        autorun.prep.file.save.autosave = 0;
    end
end



%% Autorun

% _______
% 
% Autorun
% _______

TRANS.c = c;
TRANS.autorun = autorun;
TRANS.EEG_validation = EEG_validation;
clearvars config autorun;

tic

for autorun_subjID2 = TRANS.autorun.prep.used.subjects
 for autorun_sessionID2 = TRANS.autorun.prep.used.sessions
      
  % clearvars -except STACK TRANS autorun_subjID2 autorun_sessionID2
  clearvars -except STACK VA_TRANS VA TRANS autorun_subjID2 autorun_sessionID2
  
  c = TRANS.c;
  autorun = TRANS.autorun;
  EEG_validation = TRANS.EEG_validation;
  
  wm_subjID2 = autorun_subjID2;
  wm_sessionID2 = autorun_sessionID2;
  

  % _______________
  %
  % Loading Dataset
  % _______________

  if autorun.prep.file.load.autoload == 1
    fprintf('\n');
    
    % w.file.load.path.EEG_rec = [autorun.prep.file.load.path.EEG_rec,'Subj 0',num2str(autorun_subjID2),'\Session 0',num2str(autorun_sessionID2),'\01 Rec\'];
    % w.file.load.path.EEG_rec = [autorun.prep.file.load.path.EEG_rec,'Subj ',subFunc_num2str_2digit(autorun_subjID2),'\Session ',subFunc_num2str_2digit(autorun_sessionID2),'\01 Rec\'];
    w.file.load.path.EEG_rec = [autorun.prep.file.load.path.EEG_rec,'Subj ',subFunc_num2str_2digit(autorun_subjID2),'\Session ',subFunc_num2str_2digit(autorun_sessionID2),'\',VA.f.classSubDir{VA.w.wm_subDirID},'\'];
    
    % EEG record
    fprintf(['Loading EEG_rec dataset ...\n']);
    w.file.load.name = autorun.prep.file.load.nameBasis.EEG_rec_fileName;
    TMP = load([w.file.load.path.EEG_rec,w.file.load.name]);
    w.import.EEG_rec = TMP.EEG_rec;
    clear TMP
    
    
    fprintf('Dataset loading: DONE\n');
    fprintf('\n');
    
  end


  % __________
  % 
  % Ref filter
  % __________
  
  if c.prep.EEG.filt.refFilt.usedMethod.non0_CAR1_Laplace2 == 0
      
      % noRef
      % _____
      
      % w_refFiltOut = w.import.EEG_rec;
      w_refFiltOut = w.import.EEG_rec(c.prep.EEG.import.chIDs,:);
  end
  
  if c.prep.EEG.filt.refFilt.usedMethod.non0_CAR1_Laplace2 == 1
      
      % CAR
      % ___
      
      sm.p.EEG.sr = c.prep.EEG.rec.sr;
      sm_EEG_data = transpose(w.import.EEG_rec(c.prep.EEG.import.chIDs(1,EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID(1,:)),:));
      sm.p.EEG.chNumber = size(sm_EEG_data,2);
      sim('sim_CAR.slx');
      % w_refFiltOut = w.import.EEG_rec;
      % w_refFiltOut(c.prep.EEG.import.chIDs(1,EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID(1,:)),:) = EEG_CAR(:,:);
      w_refFiltOut = w.import.EEG_rec(c.prep.EEG.import.chIDs,:);
      w_refFiltOut(EEG_validation{wm_subjID2,wm_sessionID2}.ch.valid_ID(1,:),:) = transpose(EEG_CAR(:,:));
  end
  
  if c.prep.EEG.filt.refFilt.usedMethod.non0_CAR1_Laplace2 == 2
      
      % Laplace filter
      % ______________
      
      % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
      % !!!!!!!!!!!!!!!!! N/A !!!!!!!!!!!!!!!!!!! 
      % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
      
      
      
      
  end
  
  % __________________________________
  %
  % EEG preprocessing and data slicing
  % __________________________________

  % for wm_bandID = 1:size(c.prep.EEG.filt.bandPass.band,2)
if VA.SW
    wm = VA.c.classSetup.band.usedIDs;
else
    wm = c.prep.EEG.filt.bandPass.band;
end
  for wm_bandID = wm
%     fprintf(['SubjID2: ',num2str(wm_subjID2),'/',num2str(size(c.prep.subj.used.IDs,2)),'\n'])
%     [actual_c, EEG_rec, sm] = Shape5B_EEG_setup_01(c.prep.file.data, c.prep.subj.used.IDs(1,wm_subjID2), wm_subjID2);
    fprintf(['SubjID2: ',num2str(wm_subjID2),'/',num2str(size(autorun.prep.used.subjects,2)), ...
             ', SessionID2: ',num2str(wm_sessionID2),'/',num2str(size(autorun.prep.used.sessions,2)), ...
             ', BandID: ',num2str(wm_bandID),'/',num2str(size(c.prep.EEG.filt.bandPass.band,2)),'\n'])
    
    % bandFilter (bandpass or bandpower)
    % __________________________________
    
    sm.p.EEG.sr = c.prep.EEG.rec.sr;
    sm.p.EEG.band.low1 = c.prep.EEG.filt.bandPass.band(1,wm_bandID).low1;
    sm.p.EEG.band.low2 = c.prep.EEG.filt.bandPass.band(1,wm_bandID).low2;
    sm.p.EEG.band.high1 = c.prep.EEG.filt.bandPass.band(1,wm_bandID).high1;
    sm.p.EEG.band.high2 = c.prep.EEG.filt.bandPass.band(1,wm_bandID).high2;
    sm.p.EEG.band_pass_dB = c.prep.EEG.filt.bandPass.band_pass_dB;
    sm.p.EEG.band_stop_dB = c.prep.EEG.filt.bandPass.band_stop_dB;

    sm_EEG_data = transpose(w_refFiltOut);
    assignin('base',"sm_EEG_data",sm_EEG_data);
    if c.prep.EEG.filt.bandFilt.usedFeature_bandpass1_bandpower2 == 1
        assignin('base',"sm",sm);
        sim('sim_bandpass_singleBand.slx');
        w_bandFiltOut = transpose(Bandpass_singleBand);
        clearvars Bandpass_singleBand
    else
        sm.p.EEG.FFT.wSize = c.prep.EEG.filt.bandPower.windowSizeInSamples;  % only for bandpower
        assignin('base',"sm",sm);
        sim('sim_bandpower_singleBand.slx');
        w_bandFiltOut = transpose(Bandpass_singleBand);
        clearvars Bandpass_singleBand
    end

    % Data slicing
    % ____________
    
    w_tr = subFunc_EEG_slicing_and_downsamp(c, w_bandFiltOut, w.import.EEG_rec(c.prep.EEG.import.trigCh,:));
    for wm_targetID = c.prep.experiment.target.IDs
        tr{wm_subjID2,wm_sessionID2}{wm_bandID,wm_targetID} = w_tr{1,wm_targetID};
    end
    clearvars w_tr
    
  end
  clearvars w_refFiltOut
  
  
  % _________
  % 
  % AUTO SAVE
  % _________
  
  if autorun.prep.file.save.autosave == 1
    fprintf('Saving tr{SubjID2,SessionID2} structure ...\n');
    copy_of_tr = tr;
    w.file.save.name = ['tr{',num2str(wm_subjID2),',',num2str(wm_sessionID2),'}.mat'];
    save([autorun.prep.file.save.path,w.file.save.name],'copy_of_tr','-v7.3');
    clear copy_of_tr
  end
  
 end
end

% _________
% 
% AUTO SAVE
% _________

if autorun.prep.file.save.autosave == 1
    fprintf('Saving config structure ...\n');
    copy_of_c = c;
    w.file.save.name = [autorun.prep.file.save.nameBasis.A10_offlineClass_prep, ' [config].mat'];
    save([autorun.prep.file.save.path,w.file.save.name],'copy_of_c','-v7.3');
    clear copy_of_c
    
    fprintf('Saving autorun structure ...\n');
    copy_of_autorun = autorun;
    w.file.save.name = [autorun.prep.file.save.nameBasis.A10_offlineClass_prep, ' [autorun].mat'];
    save([autorun.prep.file.save.path,w.file.save.name],'copy_of_autorun','-v7.3');
    clear copy_of_autorun
end

fprintf('\n');
fprintf('Running: Finished\n\n');

toc



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
    [wf.X, wf.sz] = trigg(transpose(EEG_data(:,:)), wf.TRIG, fix(c.prep.trial.trig_PRE_ms/1000*c.prep.EEG.rec.sr), fix(c.prep.trial.trig_PST_ms/1000*c.prep.EEG.rec.sr));
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

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% !!!!!!!!!! HAVE TO REWRITE RUN DATA FROM HERE !!!!!!!!!!!!!!
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

