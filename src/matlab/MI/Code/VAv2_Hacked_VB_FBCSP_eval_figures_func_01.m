function VAv2_Hacked_VB_FBCSP_eval_figures_func_01(FUNC_IN, FUNC_IN2)

% % !!!!!!!!! for ERROR CORRECTTION FOR CHANNEL ISSUE CAUSED CSP PROBLEM -> CSP-MI topoplot issue -> have to comment out line where this value used !!!!!!!!!!!!!!
% CH_ERROR_LIMIT = 1000;

% % % % w = FUNC_IN.w;
% % % % SW = FUNC_IN.SW;
% % % % autorun = FUNC_IN.autorun;
% % % % c = FUNC_IN.c;
SW = FUNC_IN.SW;
PLOT = FUNC_IN.PLOT;
w = FUNC_IN.w;

clearvars FUNC_IN



%% FilterBankCSP Multi-class Classification, offline EEG trainTest: figures

% Input structures

% Output structures

% REQUIRESTMENT: Matlab
% Copyright(c)2018 Attila Korik, http://isrc.ulster.ac.uk/akorik/contact.html



% ________________
%
% Loading Datasets
%_________________

% w.m = questdlg('Do you want to load required input datasets ?','Setup','Load input datasets','Continue without loading','Load input datasets');
% if strcmp(w.m,'Load input datasets')
if w.file.load.autoload == 1

    % fprintf('\n');

    % % MCC_FBCSP_offline_trainTest_01
    fprintf('Loading data files ...\n');
    % [w.file.load.nameBasis, w.file.load.path] = uigetfile(strcat('MCC_FBCSP_offline_trainTest_01.mat'),'Load input dataset');
    % w.file.load.nameBasis1 = w.file.load.nameBasis( 1 : max(find(w.file.load.nameBasis(1,:)=='['))-2);

    w.file.load.name = strcat(w.file.load.nameBasis1,' [autorun].mat');
    load([w.file.load.path,w.file.load.name]);
    autorun = copy_of_autorun;
    clear copy_of_autorun

    w.file.load.name = strcat(w.file.load.nameBasis1,' [config].mat');
    load([w.file.load.path,w.file.load.name]);
    c = copy_of_c;
    clear copy_of_c

    %     if (SW.plot_shaded_DA == 1) || ...
    %        (SW.plot_paramEval == 1) || ...
    %        (SW.plot_freqEval_v1 == 1) || ...
    %        (SW.plot_freqEval_v2 == 1) || ...
    %        (SW.plot_freqEval_v3 == 1) || ...
    %        (SW.plot_topoplot_CSPMI == 1)
    %
    w.file.load.name = strcat(w.file.load.nameBasis1,' [w0_matrix].mat');
    load([w.file.load.path,w.file.load.name]);
    w0_matrix = copy_of_w0_matrix;
    clear copy_of_w0_matrix
    %     end

    if (SW.plot_topoplot_CSPMI == 1) || ...
            (SW.plot_freqEval_v4 == 1) || ...
            (SW.plot_topoplot_ERDS == 1)

        c.eval.EEG.standard_chanlocs.chanlocs = readlocs([w.file.load_chanlocs.path,w.file.load_chanlocs.name]);
    end

    % fprintf('\n');
    fprintf('Dataset loading: DONE\n\n');

end

if (SW.plot_topoplot_CSPMI == 1) || ...
        (SW.plot_freqEval_v4 == 1) || ...
        (SW.plot_topoplot_ERDS == 1)
    if PLOT.w.topoplot.common.wtIDs_restTaskSetup_fix1_auto2 == 2
        % % PLOT.w.topoplot.common.wtIDs_rest = 1 : fix((((-1*c.prep.trial.trig_PRE_ms)-c.tt.cf.p.winSize.ms)/c.tt.cf.p.winStep.ms)+1);
        % PLOT.w.topoplot.common.wtIDs_task = fix((((-1*c.prep.trial.trig_PRE_ms)-c.tt.cf.p.winSize.ms)/c.tt.cf.p.winStep.ms)+2) : size(w0_matrix.outer.DA.multiClass_test_DA_average,3);
        PLOT.w.topoplot.common.wtIDs_task = fix((((-1*c.prep.trial.trig_PRE_ms)-c.tt.cf.p.winSize.ms)/c.tt.cf.p.winStep.ms)+2) : fix((((-1*c.prep.trial.trig_PRE_ms)+c.prep.trial.trig_PST_ms-c.tt.cf.p.winSize.ms)/c.tt.cf.p.winStep.ms)+1);
    end
end

w.autorun_sessionGroups = autorun.tt.used.sessions;
if isfield(c.tt,'session')
    if c.tt.session.use_allSessionsTogether == 1    % =1: combine classTrial datasets together from all sessions, =0:handle separately
        w.autorun_sessionGroups = 1;
    end
end


if nargin == 2  % Only for vHand dataset where the older code did not save the "c.prep" to structure to the "MTP_vHand_TC11_offlineClass_classSetup_v01 [config].mat" file:
    c.prep = FUNC_IN2;
    clearvars FUNC_IN2
end


%% Common codes for (Topoplot v1) and (ERD/ERS topoplots v1)

if (SW.plot_topoplot_CSPMI == 1) || ...
        (SW.plot_freqEval_v4 == 1) || ...
        (SW.plot_topoplot_ERDS == 1)

    fprintf('Common codes for topoplots ...\n')

    % Input:
    % % % % wm_featureID2 = bandNumber*(2*CSPFfilterPairNumber)
    % w0_matrix.outer.tt_param(wm_subjID,wm_sessionID,wm_outerFoldID,wm_classID,wtID).CSP.CSPMatrix{wm_bandID,1}(wp,wk)
    % w0_matrix.outer.tt_param(wm_subjID,wm_sessionID,wm_outerFoldID,wm_classID,wtID).MI.featureIDs(wm_featureID2,1)
    % w0_matrix.outer.tt_param(wm_subjID,wm_sessionID,wm_outerFoldID,wm_classID,wtID).MI.weights(wm_featureID2,1)
    % w0_matrix.outer.tt_param(wm_subjID,wm_sessionID,wm_outerFoldID,wm_classID,wtID).LDA.ldaParams

    % __________________________
    %
    % Chanlocs setup (displayed)
    % __________________________

    % for wm1 = 1 : size(c.prep.EEG.rec.ch.name,1)
    for wm1 = 1 : size(c.prep.EEG.used.ch.name,1)
        for wm2 = 1 : size(c.eval.EEG.standard_chanlocs.chanlocs,2)
            if strcmp(upper(c.prep.EEG.used.ch.name{wm1,1}), upper(c.eval.EEG.standard_chanlocs.chanlocs(1,wm2).labels))
                c.eval.EEG.standard_chanlocs.ch.usedID(wm1,1) = wm2;
            end
        end
    end
    c.eval.EEG.standard_chanlocs.ch.dummyID = find(~ismember(1:size(c.eval.EEG.standard_chanlocs.chanlocs,2), c.eval.EEG.standard_chanlocs.ch.usedID));
    % c.eval.EEG.standard_chanlocs.ch.displayedID = 1 : size(c.eval.EEG.standard_chanlocs.chanlocs,2);
    if sum(ismember(c.eval.EEG.standard_chanlocs.ch.usedID,75))==1    % !!!! EEG_lab BUG CORRECTION !!!!
        c.eval.EEG.standard_chanlocs.ch.displayedID = [c.eval.EEG.standard_chanlocs.ch.usedID];     % OROGINAL (normally ok)
    else
        c.eval.EEG.standard_chanlocs.ch.displayedID = [c.eval.EEG.standard_chanlocs.ch.usedID',75]';    % ERROR CORRECTION VERSION
    end

    % ________________________________
    %
    % Chanlocs setup (displayed dummy)
    % ________________________________

    if ~isempty(c.prep.EEG.dummy.ch.name)
        for wm1 = 1 : size(c.prep.EEG.dummy.ch.name,1)
            for wm2 = 1 : size(c.eval.EEG.standard_chanlocs.chanlocs,2)
                if strcmp(upper(c.prep.EEG.dummy.ch.name{wm1,1}), upper(c.eval.EEG.standard_chanlocs.chanlocs(1,wm2).labels))
                    c.eval.EEG.standard_chanlocs.ch.displayed_dummyID(wm1,1) = wm2;
                end
            end
        end
    end

    % __________________________________________________________
    %
    % wtID selection for topoplots from resting and task periods
    % __________________________________________________________

    for wm_subjID2 = 1 : size(autorun.tt.used.subjects,2)
        % for wm_subjID2 = 1 : size(w0_matrix.outer.tt_param,1)
        wm_subjID = autorun.tt.used.subjects(1,wm_subjID2);
        for wm_sessionID2 = 1 : size(w.autorun_sessionGroups,2)
            % for wm_sessionID2 = 1 : size(w0_matrix.outer.tt_param,2)
            wm_sessionID = w.autorun_sessionGroups(1,wm_sessionID2);
            for wm_outerFoldID = 1 : c.tt.folds.outerFoldNumber
                % for wm_outerFoldID = 1 : size(w0_matrix.outer.tt_param,3)

                if ~isfield(SW,'HACKED')
                    PLOT.w.topoplot.common.selected_wtID_forRest(wm_subjID2,wm_sessionID2,wm_outerFoldID) = ...
                        fix( (((-1*c.prep.trial.trig_PRE_ms)-c.tt.cf.p.winSize.ms)/c.tt.cf.p.winStep.ms)+1 + ...
                        PLOT.w.topoplot.common.endOfRestWindow_ms/c.tt.cf.p.winStep.ms );
                else
                    PLOT.w.topoplot.common.selected_wtID_forRest(wm_subjID2,wm_sessionID2,wm_outerFoldID) = SW.HACKED.selected_wtID_forRest;
                end

                % w0_matrix.outer.DA.multiClass_test_DA(wm_subjID,wm_sessionID,wm_outerFoldID,wtID)
                clearvars wm
                wm(:,1) = w0_matrix.outer.DA.multiClass_test_DA(wm_subjID,wm_sessionID,wm_outerFoldID,:);
                % [wm1,wm2] = max(wm(PLOT.w.topoplot.common.wtIDs_rest,1));
                % PLOT.w.topoplot.common.selected_wtID_forRest(wm_subjID2,wm_sessionID2,wm_outerFoldID) = PLOT.w.topoplot.common.wtIDs_rest(1,wm2);
                [wm1,wm2] = max(wm(PLOT.w.topoplot.common.wtIDs_task,1));
                if ~isfield(SW,'HACKED')
                    PLOT.w.topoplot.common.selected_wtID_forTask(wm_subjID2,wm_sessionID2,wm_outerFoldID) = PLOT.w.topoplot.common.wtIDs_task(1,wm2);   % wm2: selectedRest_wtID_task
                else
                    PLOT.w.topoplot.common.selected_wtID_forTask(wm_subjID2,wm_sessionID2,wm_outerFoldID) = SW.HACKED.selected_wtID_forTask;
                end
                clearvars wm wm1 wm2

            end

        end
    end
    % PLOT.w.topoplot.common.selected_wtID_usingOutFoldAverage_nonRounded_forRest(wm_subjID2,wm_sessionID2)
    % PLOT.w.topoplot.common.selected_wtID_usingOutFoldAverage_nonRounded_forTask(wm_subjID2,wm_sessionID2)
    PLOT.w.topoplot.common.selected_wtID_usingOutFoldAverage_nonRounded_forRest(:,:) = mean(PLOT.w.topoplot.common.selected_wtID_forRest,3);
    PLOT.w.topoplot.common.selected_wtID_usingOutFoldAverage_nonRounded_forTask(:,:) = mean(PLOT.w.topoplot.common.selected_wtID_forTask,3);

    % PLOT.w.topoplot.common.selected_wtID_usingOutFoldAverage_forRest(wm_subjID2,wm_sessionID2)
    % PLOT.w.topoplot.common.selected_wtID_usingOutFoldAverage_forTask(wm_subjID2,wm_sessionID2)
    PLOT.w.topoplot.common.selected_wtID_usingOutFoldAverage_forRest(:,:) = round(mean(PLOT.w.topoplot.common.selected_wtID_forRest,3));
    PLOT.w.topoplot.common.selected_wtID_usingOutFoldAverage_forTask(:,:) = round(mean(PLOT.w.topoplot.common.selected_wtID_forTask,3));

end


%% Identical codes for (Topoplot CSP-MI)

% % if SW.plot_topoplot_CSPMI == 1
% % if (SW.plot_topoplot_CSPMI == 1) || ...
% %    (SW.plot_topoplot_CSPMI_based_freqEval == 1)
if (SW.plot_topoplot_CSPMI == 1) || ...
        (SW.plot_freqEval_v4 == 1)

    fprintf('CSP/MI weight topoplot ...\n')

    if w.file.save.autosave == 1
        % PLOT.file.save.path = 'Q:\BCI\Results\Shape 5B SC\FBCSP MCC15\xxx\- Figures\Shaded\';
        PLOT.file.save.path = w.file.save.path;
    end

    % ______________
    %
    % Topoplot setup
    % ______________

    w.fig.topoplot.plotrad = 1;
    w.fig.topoplot.headrad = 0.5;

    % topoplot fix color limit
    w.fig.colorLimit(1,1) = 0;
    % w.fig.colorLimit(1,2) = 0.45;

    PLOT.file.save.nameBasis = 'CSP-MI topoplot';

    % ________
    %
    % plotPrep
    % ________

    % w0_matrix.outer.tt_param(wm_subjID,wm_sessionID,wm_outerFoldID,wm_classID,wtID).CSP.CSPMatrix{wm_bandID,1}
    % w0_matrix.outer.tt_param(wm_subjID,wm_sessionID,wm_outerFoldID,wm_classID,wtID).MI.weights(featureID2,1)

    for wm_subjID2 = 1 : size(autorun.tt.used.subjects,2)
        % for wm_subjID2 = 1 : size(w0_matrix.outer.tt_param,1)
        wm_subjID = autorun.tt.used.subjects(1,wm_subjID2);
        for wm_sessionID2 = 1 : size(w.autorun_sessionGroups,2)
            % for wm_sessionID2 = 1 : size(w0_matrix.outer.tt_param,2)
            wm_sessionID = w.autorun_sessionGroups(1,wm_sessionID2);
            for wm_outerFoldID = 1 : c.tt.folds.outerFoldNumber
                % for wm_outerFoldID = 1 : size(w0_matrix.outer.tt_param,3)
                % wm_CSP_filterPairNumber = c.tt.cf.p_options.CSP.selectedFilterPairNumber(1,w0_matrix.inner.best_fixTTParam.CSP_filterPairNumberID(wm_subjID,wm_sessionID,wm_outerFoldID));
                wm_CSP_filterPairNumber = c.tt.cf.p_options.CSP.selectedFilterPairNumber;
                % for wm_classID = 1 : size(c.classSetup.class.targetIDs_linkedTo_classID,1)
                if (c.tt.cf.p.use_multiClass_cf_onlyIf_numberOfClassesMoreThanTwo==1) && (size(c.classSetup.class.targetIDs_linkedTo_classID,1)==2)
                    tmp_wm = 1;
                else
                    tmp_wm = size(c.classSetup.class.targetIDs_linkedTo_classID,1);
                end
                for wm_classID = 1 : tmp_wm
                    % for wm_classID = 1 : size(w0_matrix.outer.tt_param,4)
                    % for wt = c.tt.cf.p.winSize.samp : c.tt.cf.p.winStep.samp : size(w2.tt.allClass_validCh_trials.test{1, c.classSetup.band.usedIDs(1,1)},1)
                    %  wtID = ((wt-c.tt.cf.p.winSize.samp)/c.tt.cf.p.winStep.samp)+1;
                    for wtID = 1 : size(w0_matrix.outer.tt_param,5)

                        for wm_bandID2 = 1 : size(c.classSetup.band.usedIDs,2)
                            % for wm_bandID2 = 1 : size(w0_matrix.outer.tt_param(wm_subjID,wm_sessionID,wm_outerFoldID,wm_classID,wtID).CSP.CSPMatrix,1)
                            wm_bandID = c.classSetup.band.usedIDs(1,wm_bandID2);

                            plotPrep.CSP.CSPMatrix_usedFilters{wm_subjID2,wm_sessionID2,wm_outerFoldID}(wm_classID,wtID,wm_bandID2,:,:) = ...
                                w0_matrix.outer.tt_param(wm_subjID,wm_sessionID,wm_outerFoldID,wm_classID,wtID).CSP.CSPMatrix{wm_bandID,1} ...
                                ([1:wm_CSP_filterPairNumber, end-wm_CSP_filterPairNumber+1:end],:);
                            % plotPrep.MI.weights{wm_subjID2,wm_sessionID2,wm_outerFoldID}(wm_classID,wtID,:) = ...
                            %     w0_matrix.outer.tt_param(wm_subjID,wm_sessionID,wm_outerFoldID,wm_classID,wtID).MI.weights(:,1);
                            %             plotPrep.MI.weights2{wm_subjID2,wm_sessionID2,wm_outerFoldID}(wm_classID,wtID,:) = ...
                            %                 w0_matrix.outer.tt_param(wm_subjID,wm_sessionID,wm_outerFoldID,wm_classID,wtID).MI.weights( ...
                            %                     w0_matrix.outer.tt_param(wm_subjID,wm_sessionID,wm_outerFoldID,wm_classID,wtID).MI.featureIDs(:,1),1);
                            for wp = 1 : size(w0_matrix.outer.tt_param(wm_subjID,wm_sessionID,wm_outerFoldID,wm_classID,wtID).MI.featureIDs,1)
                                plotPrep.MI.weights2{wm_subjID2,wm_sessionID2,wm_outerFoldID}(wm_classID,wtID,wp) = ...
                                    w0_matrix.outer.tt_param(wm_subjID,wm_sessionID,wm_outerFoldID,wm_classID,wtID).MI.weights( ...
                                    find(w0_matrix.outer.tt_param(wm_subjID,wm_sessionID,wm_outerFoldID,wm_classID,wtID).MI.featureIDs(:,1)==wp),1);
                            end
                        end
                    end
                end
            end
        end
    end
    clearvars wm_CSP_filterPairNumber

    %     plotPrep.CSP.CSPMatrix(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wtID,wm_bandID2,:,:)
    %     plotPrep.MI.weights{wm_subjID2,wm_sessionID2,wm_outerFoldID}(wm_classID,wtID,:)

    for wm_subjID2 = 1 : size(autorun.tt.used.subjects,2)
        % for wm_subjID2 = 1 : size(w0_matrix.outer.tt_param,1)
        wm_subjID = autorun.tt.used.subjects(1,wm_subjID2);
        for wm_sessionID2 = 1 : size(w.autorun_sessionGroups,2)
            % for wm_sessionID2 = 1 : size(w0_matrix.outer.tt_param,2)
            wm_sessionID = w.autorun_sessionGroups(1,wm_sessionID2);
            for wm_outerFoldID = 1 : c.tt.folds.outerFoldNumber
                % for wm_outerFoldID = 1 : size(w0_matrix.outer.tt_param,3)
                % wm_CSP_filterPairNumber = c.tt.cf.p_options.CSP.selectedFilterPairNumber(1,w0_matrix.inner.best_fixTTParam.CSP_filterPairNumberID(wm_subjID,wm_sessionID,wm_outerFoldID));
                wm_CSP_filterPairNumber = c.tt.cf.p_options.CSP.selectedFilterPairNumber;
                % for wm_classID = 1 : size(c.classSetup.class.targetIDs_linkedTo_classID,1)
                if (c.tt.cf.p.use_multiClass_cf_onlyIf_numberOfClassesMoreThanTwo==1) && (size(c.classSetup.class.targetIDs_linkedTo_classID,1)==2)
                    tmp_wm = 1;
                else
                    tmp_wm = size(c.classSetup.class.targetIDs_linkedTo_classID,1);
                end
                for wm_classID = 1 : tmp_wm
                    % for wm_classID = 1 : size(w0_matrix.outer.tt_param,4)
                    % for wt = c.tt.cf.p.winSize.samp : c.tt.cf.p.winStep.samp : size(w2.tt.allClass_validCh_trials.test{1, c.classSetup.band.usedIDs(1,1)},1)
                    %  wtID = ((wt-c.tt.cf.p.winSize.samp)/c.tt.cf.p.winStep.samp)+1;
                    for wtID = 1 : size(w0_matrix.outer.tt_param,5)

                        % w0_matrix.outer.tt_param(wm_subjID,wm_sessionID,wm_outerFoldID,wm_classID,wtID).CSP.CSPMatrix{wm_bandID,1}(wp,wk)
                        wk_number = size(w0_matrix.outer.tt_param(wm_subjID,wm_sessionID,wm_outerFoldID,wm_classID,wtID).CSP.CSPMatrix{wm_bandID,1},2);

                        % plotPrep.chRank(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wtID,wm_bandID2,wk)
                        % ___________________________________________________________________________________________________________

                        for wk = 1 : wk_number
                            plotPrep.chRank(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wtID,wk) = 0;
                            for wm_bandID2 = 1 : size(c.classSetup.band.usedIDs,2)
                                % for wm_bandID2 = 1 : size(w0_matrix.outer.tt_param(wm_subjID,wm_sessionID,wm_outerFoldID,wm_classID,wtID).CSP.CSPMatrix,1)
                                % wm_bandID = c.classSetup.band.usedIDs(1,wm_bandID2);
                                plotPrep.chRank_separBand(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wtID,wm_bandID2,wk) = 0;
                                % for wp = 1 : (2*wm_CSP_filterPairNumber)
                                if PLOT.w.topoplot.CSP_MI.used_CSPFilterPairPart == 0
                                    wm1 = 2;
                                    wm2 = 1 : (2*wm_CSP_filterPairNumber);
                                elseif PLOT.w.topoplot.CSP_MI.used_CSPFilterPairPart == 1
                                    wm1 = 1;
                                    wm2 = 1 : (1*wm_CSP_filterPairNumber);
                                elseif PLOT.w.topoplot.CSP_MI.used_CSPFilterPairPart == 2
                                    wm1 = 1;
                                    wm2 = wm_CSP_filterPairNumber+1 : (2*wm_CSP_filterPairNumber);
                                end
                                for wp = wm2
                                    plotPrep.chRank(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wtID,wk) = ...
                                        plotPrep.chRank(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wtID,wk) + ...
                                        abs( plotPrep.CSP.CSPMatrix_usedFilters{wm_subjID2,wm_sessionID2,wm_outerFoldID}(wm_classID,wtID,wm_bandID2,wp,wk) * ...
                                        plotPrep.MI.weights2{wm_subjID2,wm_sessionID2,wm_outerFoldID}(wm_classID,wtID, ((wm_bandID2-1)*wm1*wm_CSP_filterPairNumber)+wp) );
                                    % plotPrep.MI.weights{wm_subjID2,wm_sessionID2,wm_outerFoldID}(wm_classID,wtID, ((wm_bandID2-1)*wm1*wm_CSP_filterPairNumber)+wp) );
                                    plotPrep.chRank_separBand(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wtID,wm_bandID2,wk) = ...
                                        plotPrep.chRank_separBand(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wtID,wm_bandID2,wk) + ...
                                        abs( plotPrep.CSP.CSPMatrix_usedFilters{wm_subjID2,wm_sessionID2,wm_outerFoldID}(wm_classID,wtID,wm_bandID2,wp,wk) * ...
                                        plotPrep.MI.weights2{wm_subjID2,wm_sessionID2,wm_outerFoldID}(wm_classID,wtID, ((wm_bandID2-1)*wm1*wm_CSP_filterPairNumber)+wp) );
                                    % plotPrep.MI.weights{wm_subjID2,wm_sessionID2,wm_outerFoldID}(wm_classID,wtID, ((wm_bandID2-1)*wm1*wm_CSP_filterPairNumber)+wp) );
                                end
                                plotPrep.chRank_separBand(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wtID,wm_bandID2,wk) = ...
                                    plotPrep.chRank_separBand(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wtID,wm_bandID2,wk) / (wm1*wm_CSP_filterPairNumber);
                            end
                            plotPrep.chRank(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wtID,wk) = ...
                                plotPrep.chRank(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wtID,wk) / (size(c.classSetup.band.usedIDs,2) * (wm1*wm_CSP_filterPairNumber));
                        end



                    end
                end
            end
        end
    end
    clearvars wm_CSP_filterPairNumber

    % _____________________________________________________
    %
    % chRank at selected wtID from resting and task periods
    % _____________________________________________________

    for wm_subjID2 = 1 : size(autorun.tt.used.subjects,2)
        % for wm_subjID2 = 1 : size(w0_matrix.outer.tt_param,1)
        wm_subjID = autorun.tt.used.subjects(1,wm_subjID2);
        for wm_sessionID2 = 1 : size(w.autorun_sessionGroups,2)
            % for wm_sessionID2 = 1 : size(w0_matrix.outer.tt_param,2)
            wm_sessionID = w.autorun_sessionGroups(1,wm_sessionID2);
            for wm_outerFoldID = 1 : c.tt.folds.outerFoldNumber
                % for wm_outerFoldID = 1 : size(w0_matrix.outer.tt_param,3)

                % % plotPrep.chRank(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wtID,wk)
                % % plotPrep.chRank_at_selected_wtID{1,wm_Rest1_Task2}(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wk)
                % plotPrep.chRank_at_selected_wtID{1,1}(wm_subjID2,wm_sessionID2,wm_outerFoldID,:,:) = ...
                %     plotPrep.chRank(wm_subjID2,wm_sessionID2,wm_outerFoldID,:, PLOT.w.topoplot.common.selected_wtID_forRest(wm_subjID2,wm_sessionID2,wm_outerFoldID), :);
                % plotPrep.chRank_at_selected_wtID{1,2}(wm_subjID2,wm_sessionID2,wm_outerFoldID,:,:) = ...
                %     plotPrep.chRank(wm_subjID2,wm_sessionID2,wm_outerFoldID,:, PLOT.w.topoplot.common.selected_wtID_forTask(wm_subjID2,wm_sessionID2,wm_outerFoldID), :);
                %
                % for wm_bandID2 = 1 : size(c.classSetup.band.usedIDs,2)
                %     % plotPrep.chRank(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wtID,wk)
                %     % plotPrep.chRank_at_selected_wtID{1,wm_Rest1_Task2}(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wk)
                %
                %     % plotPrep.chRank_separBand(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wtID,wm_bandID2,wk)
                %     % plotPrep.chRank_separBand_at_selected_wtID{1,wm_Rest1_Task2}(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wm_bandID2,wk)
                %     plotPrep.chRank_separBand_at_selected_wtID{1,1}(wm_subjID2,wm_sessionID2,wm_outerFoldID,:,wm_bandID2,:) = ...
                %         plotPrep.chRank_separBand(wm_subjID2,wm_sessionID2,wm_outerFoldID,:, PLOT.w.topoplot.common.selected_wtID_forRest(wm_subjID2,wm_sessionID2,wm_outerFoldID), wm_bandID2,:);
                %     plotPrep.chRank_separBand_at_selected_wtID{1,2}(wm_subjID2,wm_sessionID2,wm_outerFoldID,:,wm_bandID2,:) = ...
                %         plotPrep.chRank_separBand(wm_subjID2,wm_sessionID2,wm_outerFoldID,:, PLOT.w.topoplot.common.selected_wtID_forTask(wm_subjID2,wm_sessionID2,wm_outerFoldID), wm_bandID2,:);
                % end

                % plotPrep.chRank(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wtID,wk)
                % plotPrep.chRank_at_selected_wtID{1,wm_Rest1_Task2}(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wk)
                plotPrep.chRank_at_selected_wtID{1,1}(wm_subjID2,wm_sessionID2,wm_outerFoldID,:,:) = ...
                    plotPrep.chRank(wm_subjID2,wm_sessionID2,wm_outerFoldID,:, PLOT.w.topoplot.common.selected_wtID_forRest(wm_subjID2,wm_sessionID2,wm_outerFoldID), :);
                plotPrep.chRank_at_selected_wtID{1,2}(wm_subjID2,wm_sessionID2,wm_outerFoldID,:,:) = ...
                    plotPrep.chRank(wm_subjID2,wm_sessionID2,wm_outerFoldID,:, PLOT.w.topoplot.common.selected_wtID_forTask(wm_subjID2,wm_sessionID2,wm_outerFoldID), :);

                for wm_bandID2 = 1 : size(c.classSetup.band.usedIDs,2)
                    % plotPrep.chRank(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wtID,wk)
                    % plotPrep.chRank_at_selected_wtID{1,wm_Rest1_Task2}(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wk)

                    % plotPrep.chRank_separBand(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wtID,wm_bandID2,wk)
                    % plotPrep.chRank_separBand_at_selected_wtID{1,wm_Rest1_Task2}(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wm_bandID2,wk)
                    plotPrep.chRank_separBand_at_selected_wtID{1,1}(wm_subjID2,wm_sessionID2,wm_outerFoldID,:,wm_bandID2,:) = ...
                        plotPrep.chRank_separBand(wm_subjID2,wm_sessionID2,wm_outerFoldID,:, PLOT.w.topoplot.common.selected_wtID_forRest(wm_subjID2,wm_sessionID2,wm_outerFoldID), wm_bandID2,:);
                    plotPrep.chRank_separBand_at_selected_wtID{1,2}(wm_subjID2,wm_sessionID2,wm_outerFoldID,:,wm_bandID2,:) = ...
                        plotPrep.chRank_separBand(wm_subjID2,wm_sessionID2,wm_outerFoldID,:, PLOT.w.topoplot.common.selected_wtID_forTask(wm_subjID2,wm_sessionID2,wm_outerFoldID), wm_bandID2,:);

                end
            end
        end
    end


    % _____________________________________
    %
    % Subj Session selection using limit DA
    % _____________________________________

    % plotPrep.chRank_at_selected_wtID{1,wm_Rest1_Task2}(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wk)
    % plotPrep.chRank_separBand_at_selected_wtID{1,wm_Rest1_Task2}(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wm_bandID2,wk)
    %
    % plotPrep.selectedSubjSession_chRank_at_selected_wtID{1,wm_Rest1_Task2}(wm_selectedSubjSessionID2,wm_outerFoldID,wm_classID,wk)
    % plotPrep.selectedSubjSession_chRank_separBand_at_selected_wtID{1,wm_Rest1_Task2}(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wm_bandID2,wk)
    wm_selectedSubjSessionID2 = 0;
    for wm_subjID2 = 1 : size(autorun.tt.used.subjects,2)
        wm_subjID = autorun.tt.used.subjects(1,wm_subjID2);
        for wm_sessionID2 = 1 : size(w.autorun_sessionGroups,2)
            wm_sessionID = w.autorun_sessionGroups(1,wm_sessionID2);
            % w0_matrix.outer.DA.multiClass_test_DA(wm_subjID,wm_sessionID,wm_outerFoldID,wtID)
            % PLOT.w.topoplot.common.selected_wtID_usingOutFoldAverage_forTask(wm_subjID2,wm_sessionID2)
            if ( mean(w0_matrix.outer.DA.multiClass_test_DA( wm_subjID, wm_sessionID, :, PLOT.w.topoplot.common.selected_wtID_usingOutFoldAverage_forTask(wm_subjID2,wm_sessionID2) ),3) >= ...
                    PLOT.w.topoplot.common.minTaskDA_usedTopoplotCalc_subj_session )

                wm_selectedSubjSessionID2 = wm_selectedSubjSessionID2+1;
                plotPrep2.selectedSubjSession(wm_selectedSubjSessionID2,1).IDs.wm_subjID2 = wm_subjID2;
                plotPrep2.selectedSubjSession(wm_selectedSubjSessionID2,1).IDs.wm_subjID = wm_subjID;
                plotPrep2.selectedSubjSession(wm_selectedSubjSessionID2,1).IDs.wm_sessionID2 = wm_sessionID2;
                plotPrep2.selectedSubjSession(wm_selectedSubjSessionID2,1).IDs.wm_sessionID = wm_sessionID;
                plotPrep2.selectedSubjSession(wm_selectedSubjSessionID2,1).selected_wtID_usingOutFoldAverage_forTask = PLOT.w.topoplot.common.selected_wtID_usingOutFoldAverage_forTask(wm_subjID2,wm_sessionID2);
                plotPrep2.selectedSubjSession(wm_selectedSubjSessionID2,1).DA = mean(w0_matrix.outer.DA.multiClass_test_DA( wm_subjID, wm_sessionID, :, PLOT.w.topoplot.common.selected_wtID_usingOutFoldAverage_forTask(wm_subjID2,wm_sessionID2) ),3);
                %        plotPrep.selectedSubjSession.wm_subjID2(wm_selectedSubjSessionID2,1) = wm_subjID2;
                %        plotPrep.selectedSubjSession.wm_subjID(wm_selectedSubjSessionID2,1) = wm_subjID;
                %        plotPrep.selectedSubjSession.wm_sessionID2(wm_selectedSubjSessionID2,1) = wm_sessionID2;
                %        plotPrep.selectedSubjSession.wm_sessionID(wm_selectedSubjSessionID2,1) = wm_sessionID;
                %        plotPrep.selectedSubjSession.selected_wtID_usingOutFoldAverage_forTask(wm_selectedSubjSessionID2,1) = PLOT.w.topoplot.common.selected_wtID_usingOutFoldAverage_forTask(wm_subjID2,wm_sessionID2);
                %        plotPrep.selectedSubjSession.DA(wm_selectedSubjSessionID2,1) = mean(w0_matrix.outer.DA.multiClass_test_DA( wm_subjID, wm_sessionID, :, PLOT.w.topoplot.common.selected_wtID_usingOutFoldAverage_forTask(wm_subjID2,wm_sessionID2) ),3);
                for wm_Rest1_Task2_ID = 1 : size(plotPrep.chRank_at_selected_wtID,2)
                    % plotPrep.chRank_at_selected_wtID{1,wm_Rest1_Task2}(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wk)
                    % plotPrep.selectedSubjSession_chRank_at_selected_wtID{1,wm_Rest1_Task2}(wm_selectedSubjSessionID2,wm_outerFoldID,wm_classID,wk)
                    plotPrep.selectedSubjSession_chRank_at_selected_wtID{1,wm_Rest1_Task2_ID}(wm_selectedSubjSessionID2,:,:,:) = ...
                        plotPrep.chRank_at_selected_wtID{1,wm_Rest1_Task2_ID}(wm_subjID2,wm_sessionID2,:,:,:);

                    % plotPrep.chRank_separBand_at_selected_wtID{1,wm_Rest1_Task2}(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wm_bandID2,wk)
                    % plotPrep.selectedSubjSession_chRank_separBand_at_selected_wtID{1,wm_Rest1_Task2}(wm_selectedSubjSessionID2,wm_outerFoldID,wm_classID,wm_bandID2,wk)
                    plotPrep.selectedSubjSession_chRank_separBand_at_selected_wtID{1,wm_Rest1_Task2_ID}(wm_selectedSubjSessionID2,:,:,:,:) = ...
                        plotPrep.chRank_separBand_at_selected_wtID{1,wm_Rest1_Task2_ID}(wm_subjID2,wm_sessionID2,:,:,:,:);
                end

            end
        end
    end


    % __________________________________
    %
    % Plotting topoplots (CSP-MI weight)
    % __________________________________

    if SW.plot_topoplot_CSPMI == 1

        % PLOT.fig.scrsz = get(0,'ScreenSize');
        % PLOT.fig.figID = figure('Name',['topoplot ... (outer folds)'],'Position',[1,1,PLOT.fig.scrsz(3),PLOT.fig.scrsz(4)],'Visible',SW.figures_visible);
        % PLOT.fig.figID = figure('Name',['topoplot (outer folds) ',PLOT.file.save.nameBasis2],'NumberTitle','off','Visible',SW.figures_visible);
        if SW.HACKED.close_figures == 1
            PLOT.fig.figID = figure('NumberTitle','off','Visible',SW.figures_visible);
        end


        % topoplots: targetClass separation
        % _________________________________

        % % % % plotPrep.chRank_at_selected_wtID{1,wm_Rest1_Task2}(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wk)
        % plotPrep.selectedSubjSession_chRank_at_selected_wtID{1,wm_Rest1_Task2}(wm_selectedSubjSessionID2,wm_outerFoldID,wm_classID,wk)
        % a2{1,wm_Rest1_Task2}(wm_classID,wk)
        clearvars a2
        % a2{1,1}(:,:) = mean(mean(mean(plotPrep.chRank_at_selected_wtID{1,1},3),2),1);
        % a2{1,2}(:,:) = mean(mean(mean(plotPrep.chRank_at_selected_wtID{1,2},3),2),1);
        if (c.tt.cf.p.use_multiClass_cf_onlyIf_numberOfClassesMoreThanTwo==1) && (size(c.classSetup.class.targetIDs_linkedTo_classID,1)==2)
            % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            % !!!!!!!!!!!!!!!! HERE MAYBE ERROR AS SAME AS AFTER THE ELSE !!!!!!!!!!!!!!!!!
            % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            % a2{1,1}(1,:) = mean(mean(mean(plotPrep.chRank_at_selected_wtID{1,1},3),2),1);
            % a2{1,2}(1,:) = mean(mean(mean(plotPrep.chRank_at_selected_wtID{1,2},3),2),1);
            a2{1,1}(1,:) = mean(mean(plotPrep.selectedSubjSession_chRank_at_selected_wtID{1,1},2),1);
            a2{1,2}(1,:) = mean(mean(plotPrep.selectedSubjSession_chRank_at_selected_wtID{1,2},2),1);
        else
            % a2{1,1}(:,:) = mean(mean(mean(plotPrep.chRank_at_selected_wtID{1,1},3),2),1);
            % a2{1,2}(:,:) = mean(mean(mean(plotPrep.chRank_at_selected_wtID{1,2},3),2),1);
            a2{1,1}(:,:) = mean(mean(plotPrep.selectedSubjSession_chRank_at_selected_wtID{1,1},2),1);
            a2{1,2}(:,:) = mean(mean(plotPrep.selectedSubjSession_chRank_at_selected_wtID{1,2},2),1);
        end
        % % !!!!!!!!! ERROR CORRECTTION FOR CHANNEL ISSUE CAUSED CSP PROBLEM -> CSP-MI topoplot issue !!!!!!!!!!!!!!
        % a2{1,1}(find(a2{1,1}>CH_ERROR_LIMIT)) = 0;
        % a2{1,2}(find(a2{1,2}>CH_ERROR_LIMIT)) = 0;
        for wm_Rest1_Task2 = PLOT.w.topoplot.CSP_MI.plotted_rest1_task2
            if wm_Rest1_Task2 == 0
                wm = [0,1];
            else
                wm = 0;
            end
            for wm_minColorLimit_is_negativeMaxColorLimit = wm
                wm_Rest1_Task2_tmp = 1;     % only for tmp work
                for wm_classID = 1 : size(a2{1,wm_Rest1_Task2_tmp},1)
                    clearvars plotData
                    if wm_Rest1_Task2 == 0
                        topoplot_chData(1,:) = a2{1,2}(wm_classID,:) - a2{1,1}(wm_classID,:);
                        plotData(c.eval.EEG.standard_chanlocs.ch.usedID,1) = a2{1,2}(wm_classID,:) - a2{1,1}(wm_classID,:);
                        plotData(c.eval.EEG.standard_chanlocs.ch.dummyID,1) = 0;
                        if PLOT.w.topoplot.common.colorLimitMax_fix1_auto2 == 1
                            w.fig.colorLimit(1,2) = PLOT.w.topoplot.common.colorLimitMax_fixValue;
                        else
                            if wm_minColorLimit_is_negativeMaxColorLimit == 0
                                w.fig.colorLimit(1,2) = max( a2{1,2}(wm_classID,:) - a2{1,1}(wm_classID,:) );
                            else
                                w.fig.colorLimit(1,2) = max(abs( a2{1,2}(wm_classID,:) - a2{1,1}(wm_classID,:) ));
                            end
                        end
                    else
                        % plotData(c.eval.EEG.standard_chanlocs.ch.usedID,1) = a2{1,wm_Rest1_Task2}(wm_classID,:);
                        topoplot_chData(1,:) = a2{1,wm_Rest1_Task2}(wm_classID,:);
                        plotData(c.eval.EEG.standard_chanlocs.ch.usedID,1) = topoplot_chData;
                        plotData(c.eval.EEG.standard_chanlocs.ch.dummyID,1) = 0;
                        if PLOT.w.topoplot.common.colorLimitMax_fix1_auto2 == 1
                            w.fig.colorLimit(1,2) = PLOT.w.topoplot.common.colorLimitMax_fixValue;
                        else
                            if PLOT.w.topoplot.common.colorLimitMax_sameAutoForRestAndTask == 1
                                % w.fig.colorLimit(1,2) = max( [max(max(a2{1,1},[],2),[],1),max(max(a2{1,2},[],2),[],1)] );
                                w.fig.colorLimit(1,2) = max( [max(a2{1,1}(wm_classID,:)),max(a2{1,2}(wm_classID,:))] );
                            else
                                % w.fig.colorLimit(1,2) = max(plotData(:,1));
                                % w.fig.colorLimit(1,2) = max(max(a2{1,wm_Rest1_Task2},[],2),[],1);
                                w.fig.colorLimit(1,2) = max(a2{1,wm_Rest1_Task2}(wm_classID,:));
                            end
                        end
                    end
                    if isfield(PLOT.w.topoplot,'colorLimitMin_fix')
                        w.fig.colorLimit(1,1) = PLOT.w.topoplot.colorLimitMin_fixValue;
                    else
                        if wm_minColorLimit_is_negativeMaxColorLimit == 0
                            w.fig.colorLimit(1,1) = 0;
                        else
                            w.fig.colorLimit(1,1) = -w.fig.colorLimit(1,2);
                        end
                    end
                    if wm_minColorLimit_is_negativeMaxColorLimit == 0
                        PLOT.file.save.nameBasis2 = ['(restTask',num2str(wm_Rest1_Task2),',class',num2str(wm_classID),',band0)'];
                    else
                        PLOT.file.save.nameBasis2 = ['(restTask','0B',',class',num2str(wm_classID),',band0)'];
                    end
                    % PLOT.fig.scrsz = get(0,'ScreenSize');
                    % PLOT.fig.figID = figure('Name',['topoplot (outer folds) ',PLOT.file.save.nameBasis2],'Position',[1,1,PLOT.fig.scrsz(3),PLOT.fig.scrsz(4)],'NumberTitle','off','Visible',SW.figures_visible);
                    % PLOT.fig.figID = figure('Name',['topoplot (outer folds) ',PLOT.file.save.nameBasis2],'NumberTitle','off','Visible',SW.figures_visible);
                    if SW.HACKED.close_figures == 1
                        set(PLOT.fig.figID,'Name',['topoplot (outer folds) ',PLOT.file.save.nameBasis2],'NumberTitle','off','Visible',SW.figures_visible)
                        clf(PLOT.fig.figID)
                    else
                        % PLOT.fig.figID = figure('NumberTitle','off','Visible',SW.figures_visible);
                        PLOT.fig.figID = figure('Name',['topoplot (outer folds) ',PLOT.file.save.nameBasis2],'NumberTitle','off','Visible',SW.figures_visible);
                    end
                    % topoplot( plotData, c.eval.EEG.standard_chanlocs.chanlocs, 'conv','off','style','both', ...
                    %   'plotrad',w.fig.topoplot.plotrad,'headrad',w.fig.topoplot.headrad,'maplimits',[w.fig.colorLimit(1,1), w.fig.colorLimit(1,2)], 'electrodes','on', 'conv','on', 'shading','interp');      % conv = on: not write colors out of the head
                    % topoplot( plotData, c.eval.EEG.standard_chanlocs.chanlocs, 'conv','off','style','both', ...
                    % % !!!!!!!!! ERROR CORRECTTION FOR CHANNEL ISSUE CAUSED CSP PROBLEM -> CSP-MI topoplot issue !!!!!!!!!!!!!!
                    tmp_displayesChID = c.eval.EEG.standard_chanlocs.ch.displayedID( ~ismember(c.eval.EEG.standard_chanlocs.ch.displayedID,find(plotData==0)), 1);
                    if ~isempty(c.prep.EEG.dummy.ch.name)
                        tmp_displayesChID = [tmp_displayesChID', c.eval.EEG.standard_chanlocs.ch.displayed_dummyID'];
                    end
                    topoplot( plotData, c.eval.EEG.standard_chanlocs.chanlocs, 'conv',PLOT.w.topoplot.common.SW.conv,'style','both', ...
                        'plotchans',tmp_displayesChID, ...
                        'plotrad',w.fig.topoplot.plotrad,'headrad',w.fig.topoplot.headrad,'maplimits',[w.fig.colorLimit(1,1), w.fig.colorLimit(1,2)], 'electrodes','on', 'conv','on', 'shading','interp');      % conv = on: not write colors out of the head
                    % %       topoplot( plotData, c.eval.EEG.standard_chanlocs.chanlocs, 'conv',PLOT.w.topoplot.common.SW.conv,'style','both', ...
                    % %         'plotchans',c.eval.EEG.standard_chanlocs.ch.displayedID, ...
                    % %         'plotrad',w.fig.topoplot.plotrad,'headrad',w.fig.topoplot.headrad,'maplimits',[w.fig.colorLimit(1,1), w.fig.colorLimit(1,2)], 'electrodes','on', 'conv','on', 'shading','interp');      % conv = on: not write colors out of the head
                    colorbar
                    if isfield(SW,'HACKED')
                        % title('All used bands')
                        % tmp='All Bands: ';
                        tmp='';
                        for tmp1 = c.classSetup.band.usedIDs
                            tmp = [tmp,num2str(c.prep.EEG.filt.bandPass.band(tmp1).low2),'-',num2str(c.prep.EEG.filt.bandPass.band(tmp1).high1),', '];
                        end
                        tmp = tmp(1:end-2);
                        tmp = [tmp,'Hz'];
                        title(tmp);
                        set(findall(gcf,'-property','FontSize'),'FontSize',11)
                    end

                    % pause(0.5)
                    % PLOT.file.save.name = [PLOT.file.save.nameBasis,' (Subj',num2str(wm_subjID),',Session',num2str(wm_sessionID),')'];
                    PLOT.file.save.name = [PLOT.file.save.nameBasis,' ',PLOT.file.save.nameBasis2];
                    saveas(PLOT.fig.figID, [PLOT.file.save.path,PLOT.file.save.name],'fig');
                    % saveas(PLOT.fig.figID, [PLOT.file.save.path,PLOT.file.save.name],'jpg');
                    saveas(PLOT.fig.figID, [PLOT.file.save.path,PLOT.file.save.name],'png');
                    
                    %Save JSON config
                    jsonFilePath = [PLOT.file.save.path, PLOT.file.save.name, '.json'];
                    savePlotConfigToJSON(PLOT.fig.figID, [PLOT.file.save.path, PLOT.file.save.name, '.mat'], 'topoplot', jsonFilePath);

                    % saveas(PLOT.fig.figID, [PLOT.file.save.path,PLOT.file.save.name],'tif');
                    % saveas(PLOT.fig.figID, [PLOT.file.save.path,PLOT.file.save.name],'pdf');
                    % if SW.HACKED.close_figures == 1
                    %   close(PLOT.fig.figID);
                    % end

                    save([PLOT.file.save.path,PLOT.file.save.name,'.mat'],'topoplot_chData','-v7.3');
                    clearvars topoplot_chData

                    clearvars plotData
                end
            end
        end
        clearvars a2



        % topoplots: targetClass separation (with freq separation)
        % ________________________________________________________

        % % % % plotPrep.chRank_separBand_at_selected_wtID{1,wm_Rest1_Task2}(wm_subjID2,wm_sessionID2,wm_outerFoldID,wm_classID,wm_bandID2,wk)
        % plotPrep.selectedSubjSession_chRank_separBand_at_selected_wtID{1,wm_Rest1_Task2}(wm_selectedSubjSessionID2,wm_outerFoldID,wm_classID,wm_bandID2,wk)
        % a2{1,wm_Rest1_Task2}(wm_classID,wm_bandID2,wk)
        clearvars a3
        % a3{1,1}(:,:,:) = mean(mean(mean(plotPrep.chRank_separBand_at_selected_wtID{1,1},3),2),1);
        % a3{1,2}(:,:,:) = mean(mean(mean(plotPrep.chRank_separBand_at_selected_wtID{1,2},3),2),1);
        if (c.tt.cf.p.use_multiClass_cf_onlyIf_numberOfClassesMoreThanTwo==1) && (size(c.classSetup.class.targetIDs_linkedTo_classID,1)==2)
            % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            % !!!!!!!!!!!!!!!! HERE MAYBE ERROR AS SAME AS AFTER THE ELSE !!!!!!!!!!!!!!!!!
            % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            % a3{1,1}(1,:,:) = mean(mean(mean(plotPrep.chRank_separBand_at_selected_wtID{1,1},3),2),1);
            % a3{1,2}(1,:,:) = mean(mean(mean(plotPrep.chRank_separBand_at_selected_wtID{1,2},3),2),1);
            a3{1,1}(1,:,:) = mean(mean(plotPrep.selectedSubjSession_chRank_separBand_at_selected_wtID{1,1},2),1);
            a3{1,1}=permute(a3{1,1},[1,3,2]);   % !!!!!!!!!!!! DIMENSION ORDER MODIFICATION FOR C2019 !!!!!!!!!!!!
            a3{1,2}(1,:,:) = mean(mean(plotPrep.selectedSubjSession_chRank_separBand_at_selected_wtID{1,2},2),1);
            a3{1,2}=permute(a3{1,2},[1,3,2]);   % !!!!!!!!!!!! DIMENSION ORDER MODIFICATION FOR C2019 !!!!!!!!!!!!
        else
            % a3{1,1}(:,:,:) = mean(mean(mean(plotPrep.chRank_separBand_at_selected_wtID{1,1},3),2),1);
            % a3{1,2}(:,:,:) = mean(mean(mean(plotPrep.chRank_separBand_at_selected_wtID{1,2},3),2),1);
            a3{1,1}(:,:,:) = mean(mean(plotPrep.selectedSubjSession_chRank_separBand_at_selected_wtID{1,1},2),1);
            a3{1,1}=permute(a3{1,1},[1,3,2]);   % !!!!!!!!!!!! DIMENSION ORDER MODIFICATION FOR C2019 !!!!!!!!!!!!
            a3{1,2}(:,:,:) = mean(mean(plotPrep.selectedSubjSession_chRank_separBand_at_selected_wtID{1,2},2),1);
            a3{1,2}=permute(a3{1,2},[1,3,2]);   % !!!!!!!!!!!! DIMENSION ORDER MODIFICATION FOR C2019 !!!!!!!!!!!!
        end
        % % !!!!!!!!! ERROR CORRECTTION FOR CHANNEL ISSUE CAUSED CSP PROBLEM -> CSP-MI topoplot issue !!!!!!!!!!!!!!
        % a3{1,1}(find(a3{1,1}>CH_ERROR_LIMIT)) = 0;
        % a3{1,2}(find(a3{1,2}>CH_ERROR_LIMIT)) = 0;
        for wm_Rest1_Task2 = PLOT.w.topoplot.CSP_MI.plotted_rest1_task2
            if wm_Rest1_Task2 == 0
                wm = [0,1];
            else
                wm = 0;
            end
            for wm_minColorLimit_is_negativeMaxColorLimit = wm
                wm_Rest1_Task2_tmp = 1;     % only for tmp work
                for wm_classID = 1 : size(a3{1,wm_Rest1_Task2_tmp},1)
                    for wm_bandID2 = 1 : size(c.classSetup.band.usedIDs,2)
                        if wm_Rest1_Task2 == 0
                            topoplot_chData(1,:) = a3{1,2}(wm_classID,wm_bandID2,:) - a3{1,1}(wm_classID,wm_bandID2,:);
                            plotData(c.eval.EEG.standard_chanlocs.ch.usedID,1) = a3{1,2}(wm_classID,wm_bandID2,:) - a3{1,1}(wm_classID,wm_bandID2,:);
                            plotData(c.eval.EEG.standard_chanlocs.ch.dummyID,1) = 0;
                            if PLOT.w.topoplot.common.colorLimitMax_fix1_auto2 == 1
                                w.fig.colorLimit(1,2) = PLOT.w.topoplot.common.colorLimitMax_fixValue;
                            else
                                if wm_minColorLimit_is_negativeMaxColorLimit == 0
                                    w.fig.colorLimit(1,2) = max( a3{1,2}(wm_classID,wm_bandID2,:) - a3{1,1}(wm_classID,wm_bandID2,:) );
                                else
                                    w.fig.colorLimit(1,2) = max(abs( a3{1,2}(wm_classID,wm_bandID2,:) - a3{1,1}(wm_classID,wm_bandID2,:) ));
                                end
                            end
                        else
                            % plotData(c.eval.EEG.standard_chanlocs.ch.usedID,1) = a3{1,wm_Rest1_Task2}(wm_classID,wm_bandID2,:);
                            topoplot_chData(1,:) = a3{1,wm_Rest1_Task2}(wm_classID,wm_bandID2,:);
                            plotData(c.eval.EEG.standard_chanlocs.ch.usedID,1) = topoplot_chData;
                            plotData(c.eval.EEG.standard_chanlocs.ch.dummyID,1) = 0;
                            if PLOT.w.topoplot.common.colorLimitMax_fix1_auto2 == 1
                                w.fig.colorLimit(1,2) = PLOT.w.topoplot.common.colorLimitMax_fixValue;
                            else
                                if PLOT.w.topoplot.common.colorLimitMax_sameAutoForRestAndTask == 1
                                    % w.fig.colorLimit(1,2) = max( [max(max(a2{1,1},[],2),[],1),max(max(a2{1,2},[],2),[],1)] );
                                    w.fig.colorLimit(1,2) = max( [max(a3{1,1}(wm_classID,wm_bandID2,:)),max(a3{1,2}(wm_classID,wm_bandID2,:))] );
                                else
                                    % w.fig.colorLimit(1,2) = max(plotData(:,1));
                                    % w.fig.colorLimit(1,2) = max(max(a2{1,wm_Rest1_Task2},[],2),[],1);
                                    w.fig.colorLimit(1,2) = max(a3{1,wm_Rest1_Task2}(wm_classID,wm_bandID2,:));
                                end
                            end
                        end
                        if isfield(PLOT.w.topoplot,'colorLimitMin_fix')
                            w.fig.colorLimit(1,1) = PLOT.w.topoplot.colorLimitMin_fixValue;
                        else
                            if wm_minColorLimit_is_negativeMaxColorLimit == 0
                                w.fig.colorLimit(1,1) = 0;
                            else
                                w.fig.colorLimit(1,1) = -w.fig.colorLimit(1,2);
                            end
                        end
                        if wm_minColorLimit_is_negativeMaxColorLimit == 0
                            PLOT.file.save.nameBasis2 = ['(restTask',num2str(wm_Rest1_Task2),',class',num2str(wm_classID),',band',num2str(wm_bandID2)];
                        else
                            PLOT.file.save.nameBasis2 = ['(restTask','0B',',class',num2str(wm_classID),',band',num2str(wm_bandID2)];
                        end
                        % PLOT.fig.scrsz = get(0,'ScreenSize');
                        % PLOT.fig.figID = figure('Name',['topoplot (outer folds) ',PLOT.file.save.nameBasis2],'Position',[1,1,PLOT.fig.scrsz(3),PLOT.fig.scrsz(4)],'NumberTitle','off','Visible',SW.figures_visible);
                        % PLOT.fig.figID = figure('Name',['topoplot (outer folds) ',PLOT.file.save.nameBasis2],'NumberTitle','off','Visible',SW.figures_visible);
                        if SW.HACKED.close_figures == 1
                            set(PLOT.fig.figID,'Name',['topoplot (outer folds) ',PLOT.file.save.nameBasis2],'NumberTitle','off','Visible',SW.figures_visible)
                            clf(PLOT.fig.figID)
                        else
                            % PLOT.fig.figID = figure('NumberTitle','off','Visible',SW.figures_visible);
                            PLOT.fig.figID = figure('Name',['topoplot (outer folds) ',PLOT.file.save.nameBasis2],'NumberTitle','off','Visible',SW.figures_visible);
                        end
                        % topoplot( plotData, c.eval.EEG.standard_chanlocs.chanlocs, 'conv','off','style','both', ...
                        %   'plotrad',w.fig.topoplot.plotrad,'headrad',w.fig.topoplot.headrad,'maplimits',[w.fig.colorLimit(1,1), w.fig.colorLimit(1,2)], 'electrodes','on', 'conv','on', 'shading','interp');      % conv = on: not write colors out of the head
                        % topoplot( plotData, c.eval.EEG.standard_chanlocs.chanlocs, 'conv','off','style','both', ...
                        % % !!!!!!!!! ERROR CORRECTTION FOR CHANNEL ISSUE CAUSED CSP PROBLEM -> CSP-MI topoplot issue !!!!!!!!!!!!!!
                        tmp_displayesChID = c.eval.EEG.standard_chanlocs.ch.displayedID( ~ismember(c.eval.EEG.standard_chanlocs.ch.displayedID,find(plotData==0)), 1);
                        if ~isempty(c.prep.EEG.dummy.ch.name)
                            tmp_displayesChID = [tmp_displayesChID', c.eval.EEG.standard_chanlocs.ch.displayed_dummyID'];
                        end
                        topoplot( plotData, c.eval.EEG.standard_chanlocs.chanlocs, 'conv',PLOT.w.topoplot.common.SW.conv,'style','both', ...
                            'plotchans',tmp_displayesChID, ...
                            'plotrad',w.fig.topoplot.plotrad,'headrad',w.fig.topoplot.headrad,'maplimits',[w.fig.colorLimit(1,1), w.fig.colorLimit(1,2)], 'electrodes','on', 'conv','on', 'shading','interp');      % conv = on: not write colors out of the head
                        % %       topoplot( plotData, c.eval.EEG.standard_chanlocs.chanlocs, 'conv',PLOT.w.topoplot.common.SW.conv,'style','both', ...
                        % %         'plotchans',c.eval.EEG.standard_chanlocs.ch.displayedID, ...
                        % %         'plotrad',w.fig.topoplot.plotrad,'headrad',w.fig.topoplot.headrad,'maplimits',[w.fig.colorLimit(1,1), w.fig.colorLimit(1,2)], 'electrodes','on', 'conv','on', 'shading','interp');      % conv = on: not write colors out of the head
                        colorbar
                        if isfield(SW,'HACKED')
                            tmp1 = c.classSetup.band.usedIDs(1,wm_bandID2);
                            title([num2str(c.prep.EEG.filt.bandPass.band(tmp1).low2),'-',num2str(c.prep.EEG.filt.bandPass.band(tmp1).high1),'Hz']);
                            set(findall(gcf,'-property','FontSize'),'FontSize',11)
                        end

                        % pause(0.5)
                        % PLOT.file.save.name = [PLOT.file.save.nameBasis,' (Subj',num2str(wm_subjID),',Session',num2str(wm_sessionID),')'];
                        PLOT.file.save.name = [PLOT.file.save.nameBasis,' ',PLOT.file.save.nameBasis2];
                        saveas(PLOT.fig.figID, [PLOT.file.save.path,PLOT.file.save.name],'fig');
                        % saveas(PLOT.fig.figID, [PLOT.file.save.path,PLOT.file.save.name],'jpg');
                        saveas(PLOT.fig.figID, [PLOT.file.save.path,PLOT.file.save.name],'png');
                        %Save JSON config
                        jsonFilePath = [PLOT.file.save.path, PLOT.file.save.name, '.json'];
                        savePlotConfigToJSON(PLOT.fig.figID, [PLOT.file.save.path, PLOT.file.save.name, '.mat'], 'topoplot', jsonFilePath);
                        % saveas(PLOT.fig.figID, [PLOT.file.save.path,PLOT.file.save.name],'tif');
                        % saveas(PLOT.fig.figID, [PLOT.file.save.path,PLOT.file.save.name],'pdf');
                        % if SW.HACKED.close_figures == 1
                        %   close(PLOT.fig.figID);
                        %      end

                        save([PLOT.file.save.path,PLOT.file.save.name,'.mat'],'topoplot_chData','-v7.3');
                        clearvars topoplot_chData

                        clearvars plotData
                    end
                    % % close all
                    % % pause(1.5)
                end
            end
        end
        clearvars a3



        % ____________
        %
        % Close figure
        % ____________

        if SW.HACKED.close_figures == 1
            close(PLOT.fig.figID);
        end
        clearvars plotPrep

    end

end





%% Frequency evaluation v4

if SW.plot_freqEval_v4 == 1

    fprintf('Frequency evaluation v4 ...\n')

    if w.file.save.autosave == 1
        % PLOT.file.save.path = 'Q:\BCI\Results\Shape 5B SC\FBCSP MCC15\xxx\- Figures\Shaded\';
        PLOT.file.save.path = w.file.save.path;
    end


    % ________________________________________________
    %
    % wtID selection for topoplots from resting period
    % ________________________________________________

    if ~isfield(SW,'HACKED')
        PLOT.w.common.selected_wtID_forRest = ...
            fix( (((-1*c.prep.trial.trig_PRE_ms)-c.tt.cf.p.winSize.ms)/c.tt.cf.p.winStep.ms)+1 + ...
            PLOT.w.topoplot.common.endOfRestWindow_ms/c.tt.cf.p.winStep.ms );
    end

    % ____________________
    %
    % frequency evaluation
    % ____________________

    % Input:
    % w0_matrix.outer.tt_param(wm_subjID,wm_sessionID,wm_outerFoldID,wm_classID,wtID).MI.featureIDs
    % % % w0_matrix.outer.tt_param(wm_subjID,wm_sessionID,wm_outerFoldID,wm_classID,wtID).MI.weights

    % PLOT.fig.scrsz = get(0,'ScreenSize');
    % PLOT.fig.figID = figure('Name',['inner.best_fixTTParam.CSP_filterPairNumberID'],'Position',[1,1,PLOT.fig.scrsz(3),PLOT.fig.scrsz(4)],'Visible',SW.figures_visible);
    % PLOT.file.save.nameBasis = 'heatmap';
    % PLOT.file.save.name1 = 'heatmap (CSP_filterPairNumberID)';
    % PLOT.title1 = 'inner.best_fixTTParam.CSP_filterPairNumberID';
    PLOT.file.save.name = 'heatmap (Freq v4)';
    PLOT.file.save.name_mean = 'heatmap (Freq v4) selectedAverage';
    % PLOT.title = 'Freq';

    for wm_subjID2 = 1 : size(autorun.tt.used.subjects,2)
        wm_subjID = autorun.tt.used.subjects(1,wm_subjID2);
        for wm_sessionID2 = 1 : size(w.autorun_sessionGroups,2)
            wm_sessionID = w.autorun_sessionGroups(1,wm_sessionID2);

            % plotData{wm_subjID2,wm_sessionID2}(wm_bandID,wtID)
            plotData{wm_subjID2,wm_sessionID2} = zeros( size(c.classSetup.band.usedIDs,2), size(w0_matrix.outer.tt_param,5) );

            % for wm_bandID = c.classSetup.band.usedIDs
            for wm_bandID2 = 1 : size(c.classSetup.band.usedIDs,2)
                for wtID = 1 : size(w0_matrix.outer.tt_param,5)

                    % for wm_classID = 1 : size(c.classSetup.class.targetIDs_linkedTo_classID,1)
                    %       % for wm_classID = 1 : size(w0_matrix.outer.tt_param,4)
                    % for wm_classID = 1 : size(c.classSetup.class.targetIDs_linkedTo_classID,1)
                    if (c.tt.cf.p.use_multiClass_cf_onlyIf_numberOfClassesMoreThanTwo==1) && (size(c.classSetup.class.targetIDs_linkedTo_classID,1)==2)
                        tmp_wm = 1;
                    else
                        tmp_wm = size(c.classSetup.class.targetIDs_linkedTo_classID,1);
                    end
                    for wm_classID = 1 : tmp_wm
                        for wm_outerFoldID = 1 : c.tt.folds.outerFoldNumber
                            % wm_CSP_filterPairNumber = c.tt.cf.p_options.CSP.selectedFilterPairNumber(1, w0_matrix.inner.best_fixTTParam.CSP_filterPairNumberID(wm_subjID,wm_sessionID,wm_outerFoldID));
                            wm_CSP_filterPairNumber = c.tt.cf.p_options.CSP.selectedFilterPairNumber;
                            for wm_CSP_filterID = 1 : 2*wm_CSP_filterPairNumber
                                wm_featureID2 = find(w0_matrix.outer.tt_param(wm_subjID,wm_sessionID,wm_outerFoldID,wm_classID,wtID).MI.featureIDs(:,1)==((wm_bandID2-1)*2*wm_CSP_filterPairNumber)+wm_CSP_filterID);
                                plotData{wm_subjID2,wm_sessionID2}(wm_bandID2,wtID) = ...
                                    plotData{wm_subjID2,wm_sessionID2}(wm_bandID2,wtID) + ...
                                    w0_matrix.outer.tt_param(wm_subjID,wm_sessionID,wm_outerFoldID,wm_classID,wtID).MI.weights(wm_featureID2,1) / ...
                                    (size(c.classSetup.class.targetIDs_linkedTo_classID,1) * size(c.tt.folds.outerFoldNumber,2) * (2*wm_CSP_filterPairNumber));   % " / ..." only for normalization
                                % w0_matrix.outer.tt_param(wm_subjID,wm_sessionID,wm_outerFoldID,wm_classID,wtID).MI.weights(wm_featureID2,1);
                            end
                        end

                    end
                end

            end
        end
    end

    for wm_selectedSubjSessionID2 = 1 : size(plotPrep2.selectedSubjSession,1)
        % plotData{wm_subjID2,wm_sessionID2}(wm_bandID2,wtID)
        %
        % plotData_selectedSubjSession(wm_selectedSubjSessionID2,wm_bandID2,wtID)
        plotData_selectedSubjSession(wm_selectedSubjSessionID2,:,:) = ...
            plotData{ plotPrep2.selectedSubjSession(wm_selectedSubjSessionID2,1).IDs.wm_subjID2, ...
            plotPrep2.selectedSubjSession(wm_selectedSubjSessionID2,1).IDs.wm_sessionID2}(:,:);
    end

    % Separate subjects
    % _________________
    % PLOT.fig.figID = figure('Name',['inner.best_fixTTParam.CSP_filterPairNumberID'],'Visible',SW.figures_visible);
    PLOT.fig.scrsz = get(0,'ScreenSize');
    PLOT.fig.figID = figure('Name',['Multi-class Frequency map (outer folds)'],'Position',[1,1,PLOT.fig.scrsz(3),PLOT.fig.scrsz(4)],'Visible',SW.figures_visible);
    for wm_selectedSubjSessionID2 = 1 : size(plotPrep2.selectedSubjSession,1)
        wm_subjID2 = plotPrep2.selectedSubjSession(wm_selectedSubjSessionID2,1).IDs.wm_subjID2;
        wm_subjID = plotPrep2.selectedSubjSession(wm_selectedSubjSessionID2,1).IDs.wm_subjID;
        wm_sessionID2 = plotPrep2.selectedSubjSession(wm_selectedSubjSessionID2,1).IDs.wm_sessionID2;
        wm_sessionID = plotPrep2.selectedSubjSession(wm_selectedSubjSessionID2,1).IDs.wm_sessionID;

        % subplot{wm_subjID2 , wm_sessionID2}(wm_bandID2 , wtID)
        % subplot( size(autorun.tt.used.subjects,2), size(w.autorun_sessionGroups,2) , ((wm_subjID2-1)*size(w.autorun_sessionGroups,2)) + wm_sessionID2 )
        subplot( size(plotPrep2.selectedSubjSession,1), 1 , wm_selectedSubjSessionID2 )
        clearvars a2
        % % plotData_selectedSubjSession(wm_selectedSubjSessionID2,wm_bandID2,wtID)
        a2(:,:) = plotData_selectedSubjSession(wm_selectedSubjSessionID2,:,:);
        a2 = flip(a2,1);  % change band order from bottom to top
        freqPlot_data = a2;
        if ~isfield(SW,'HACKED')
            heatmap(a2(:,:),'CellLabelColor','none');
        else
            %  clearvars tmp
            %  tmp2 = c.tt.cf.p.winSize.ms/1000 : c.tt.cf.p.winStep.ms/1000 : -c.prep.trial.trig_PRE_ms/1000 + c.prep.trial.trig_PST_ms/1000;
            %  for tmp1 = 1 : size(a2,2)
            %   tmp{1,tmp1} = num2str(tmp2(1,tmp1));
            %  end
            %  xvalues = tmp;
            %  clearvars tmp
            %  for tmp1ID = 1 : size(c.classSetup.band.usedIDs,2)
            %   tmp1 = c.classSetup.band.usedIDs(1,tmp1ID);
            %   tmp{1,tmp1ID} = [num2str(c.prep.EEG.filt.bandPass.band(tmp1).low2),'-',num2str(c.prep.EEG.filt.bandPass.band(tmp1).high1)];
            %  end
            %  yvalues = tmp;
            %  % xvalues = {'Small','Medium','Large'};
            %  % yvalues = {'Green','Red','Blue','Gray'};
            %  % h_heatmapID = heatmap(xvalues, yvalues, a2(:,:),'CellLabelColor','none');
            %  if SW.HACKED.freqWval_v4_colormap_change == 1
            %     h_colormapID = colormap(flipud(autumn));
            %  end
            %  if SW.HACKED.freqWval_v4_colormap_change == 2
            %     h_colormapID = colormap(jet);
            %  end
            %  h_heatmapID = heatmap(xvalues, yvalues, a2(:,:),'CellLabelColor','none','colormap',h_colormapID);
            %  h_heatmapID.FontSize = 14;
            %  h_heatmapID.XLabel = 'time(s)';
            %  h_heatmapID.YLabel = 'Frequency(Hz)';
            tmp_rescale = 100;
            [X,Y] = meshgrid(1:size(a2,2), 1:size(a2,1));
            [X2,Y2] = meshgrid(1 : 1/tmp_rescale : size(a2,2), 1 : 1/tmp_rescale :size(a2,1));
            outData = interp2(X, Y, a2, X2, Y2, 'linear');
            h_imagescID = imagesc(outData);
            colormap(jet);
            % xticks = 1 : (1000/c.tt.cf.p.winStep.ms)*tmp_rescale : size(a2,2)*tmp_rescale;
            % xlabels = c.tt.cf.p.winSize.ms/1000 : -c.prep.trial.trig_PRE_ms/1000 + c.prep.trial.trig_PST_ms/1000;
            xticks = 1 : (1000/c.tt.cf.p.winStep.ms)*tmp_rescale : ((size(a2,2)-1)*tmp_rescale)+1;
            xlabels = c.tt.cf.p.winSize.ms/1000 : -c.prep.trial.trig_PRE_ms/1000 + c.prep.trial.trig_PST_ms/1000;
            set(gca, 'XTick', xticks, 'XTickLabel', xlabels);
            yticks = 1 : ((size(c.classSetup.band.usedIDs,2)-1)*tmp_rescale)/size(c.classSetup.band.usedIDs,2) : ((size(c.classSetup.band.usedIDs,2)-1)*tmp_rescale)+1;
            clearvars ylabels
            for tmp1ID = 1 : size(c.classSetup.band.usedIDs,2)
                tmp1 = c.classSetup.band.usedIDs(1,tmp1ID);
                ylabels(1,tmp1ID) = c.prep.EEG.filt.bandPass.band(tmp1).low2;
            end
            ylabels(1,tmp1ID+1) = c.prep.EEG.filt.bandPass.band(tmp1).high1;
            ylabels = flip(ylabels,2);  % change bandLabel order from bottom to top
            set(gca, 'YTick',yticks, 'YTickLabel',ylabels);
            set(findall(gcf,'-property','FontSize'),'FontSize',18)
            xlabel('time(s)')
            ylabel('Frequency(Hz)')
            colorbar
        end
        if PLOT.w.freqMap.common.colorLimitMax_fix1_auto2 == 1
            if isfield(PLOT.w.freqMap.common,'colorLimitMin_fixValue')
                caxis([PLOT.w.freqMap.common.colorLimitMin_fixValue, PLOT.w.freqMap.common.colorLimitMax_fixValue]);
            else
                caxis([0, PLOT.w.freqMap.common.colorLimitMax_fixValue]);
            end
        end
        if ~isfield(SW,'HACKED')
            title(['Subj:',num2str(wm_subjID),',Session:',num2str(wm_sessionID)])
        end
    end
    % PLOT.file.save.name = [PLOT.file.save.nameBasis,' (Subj',num2str(wm_subjID),',Session',num2str(wm_sessionID),')'];
    saveas(PLOT.fig.figID, [PLOT.file.save.path,PLOT.file.save.name],'fig');
    % saveas(PLOT.fig.figID, [PLOT.file.save.path,PLOT.file.save.name],'jpg');
    saveas(PLOT.fig.figID, [PLOT.file.save.path,PLOT.file.save.name],'png');
    %Save JSON config
    jsonFilePath = [PLOT.file.save.path, PLOT.file.save.name, '.json'];
    savePlotConfigToJSON(PLOT.fig.figID, [PLOT.file.save.path, PLOT.file.save.name, '.mat'], 'spectrogram', jsonFilePath);
    % saveas(PLOT.fig.figID, [PLOT.file.save.path,PLOT.file.save.name],'tif');
    % saveas(PLOT.fig.figID, [PLOT.file.save.path,PLOT.file.save.name],'pdf');
    if SW.HACKED.close_figures == 1
        close(PLOT.fig.figID);
    end

    save([PLOT.file.save.path,PLOT.file.save.name,'.mat'],'freqPlot_data','-v7.3');
    clearvars freqPlot_data

    clearvars plotData

end









%% Comments

% Pfurtscheller et al. - 2001 - Functional brain imaging based on ERD ERS.pdf (Functional brain imaging based on ERD/ERS)
% Pfurtscheller and DaSilva - 1999 - Event related EEG MEG synchronization and desynchronization.pdf (Event-related EEG/MEG synchronization and desynchronization: basic)


%{
% Plots

figure; w.a(1,:)=w0.inner.DA.multiClass_test_DA_average(2,1,2,:); plot(w.a(1,:))
figure; w.a(1,:)=w0.inner.DA.multiClass_test_DA_average_smooth(2,1,2,:); plot(w.a(1,:))
figure; plot(w0.inner_merged.DA.multiClass_test_DA_average(1,:))
figure; plot(w0.outer.DA.multiClass_test_DA_average(1,:))


figure; a(1,:)=w0{10,1,2}.inner.DA.multiClass_test_DA_average(2,1,2,:); plot(a(1,:))
figure; a(1,:)=w0{10,1,2}.inner.DA.multiClass_test_DA_average_smooth(2,1,2,:); plot(a(1,:))
figure; plot(w0{10,1,2}.inner_merged.DA.multiClass_test_DA_average(1,:))
figure; plot(w0{10,1,2}.inner_merged.DA.multiClass_test_DA_average_smooth(1,:))
figure; plot(w0{10,1,2}.outer.DA.multiClass_test_DA_average(1,:))
figure; plot(w0{10,1,2}.outer.DA.multiClass_test_DA_average_smooth(1,:))

figure; a(1,:)=w0{10,1,6}.inner.DA.multiClass_test_DA_average(2,1,2,:); plot(a(1,:))
figure; a(1,:)=w0{10,1,6}.inner.DA.multiClass_test_DA_average_smooth(2,1,2,:); plot(a(1,:))
figure; plot(w0{10,1,6}.inner_merged.DA.multiClass_test_DA_average(1,:))
figure; plot(w0{10,1,6}.inner_merged.DA.multiClass_test_DA_average_smooth(1,:))
figure; plot(w0{10,1,6}.outer.DA.multiClass_test_DA_average(1,:))
figure; plot(w0{10,1,6}.outer.DA.multiClass_test_DA_average_smooth(1,:))


figure; a(1,:)=w0_matrix.outer.DA.multiClass_test_DA_average(10,1,:); plot(a(1,:))
figure; a(1,:)=w0_matrix.outer.DA.multiClass_test_DA_average_smooth(10,1,:); plot(a(1,:))
%}



%{

% ____________________
% 
% BEST DA Mean and STD
% ____________________

% PLOT.w.topoplot.common.selected_wtID_forTask(wm_subjID2,wm_sessionID2,wm_outerFoldID)
% w0_matrix.outer.DA.multiClass_test_DA(autorun_subjID2,autorun_sessionID2,autorun_outerFoldID,wtID)

clearvars TEST
% TEST.selected_wtID_forTask(:,:) = round(mean(PLOT.w.topoplot.common.selected_wtID_forTask,3));
for wm_subjID2 = 1 : size(PLOT.w.topoplot.common.selected_wtID_forTask,1)
 wm_subjID = autorun.tt.used.subjects(1,wm_subjID2);
 for wm_sessionID2 = 1 : size(PLOT.w.topoplot.common.selected_wtID_forTask,2)
  wm_sessionID = w.autorun_sessionGroups(1,wm_sessionID2);
    clearvars a4;
    a4 = mean(w0_matrix.outer.DA.multiClass_test_DA,3);
    [wm1,wm2] = max(a4(wm_subjID,wm_sessionID,1,:));
    TEST.selected_wtID_forTask(wm_subjID2,wm_sessionID2) = wm2;
 end
end
for wm_subjID2 = 1 : size(PLOT.w.topoplot.common.selected_wtID_forTask,1)
 wm_subjID = autorun.tt.used.subjects(1,wm_subjID2);
 for wm_sessionID2 = 1 : size(PLOT.w.topoplot.common.selected_wtID_forTask,2)
  wm_sessionID = w.autorun_sessionGroups(1,wm_sessionID2);
  for wm_outerFoldID = 1 : size(PLOT.w.topoplot.common.selected_wtID_forTask,3)
    % TEST.DA_at_selected_wtID_forTask(wm_subjID2,wm_sessionID2,wm_outerFoldID) = w0_matrix.outer.DA.multiClass_test_DA(wm_subjID,wm_sessionID,wm_outerFoldID, ...
    %     TEST.selected_wtID_forTask(wm_subjID2,wm_sessionID2));
    TEST.DA_at_selected_wtID_forTask(wm_subjID2,wm_sessionID2,wm_outerFoldID) = w0_matrix.outer.DA.multiClass_test_DA(wm_subjID,wm_sessionID,wm_outerFoldID, ...
        TEST.selected_wtID_forTask(wm_subjID2,wm_sessionID2));
  end
 end
end

TEST.DA_meanOfFolds_at_selected_wtID_forTask = mean(TEST.DA_at_selected_wtID_forTask,3);
TEST.DA_stdOfFolds_at_selected_wtID_forTask = std(TEST.DA_at_selected_wtID_forTask,0,3);
wm = 0;
for wm_subjID2 = 1 : size(PLOT.w.topoplot.common.selected_wtID_forTask,1)
 for wm_sessionID2 = 1 : size(PLOT.w.topoplot.common.selected_wtID_forTask,2)
    wm = wm+1;
    TEST.DA_meanOfFolds_at_selected_wtID_forTask_1D_subjXSess1toN(wm,1) = TEST.DA_meanOfFolds_at_selected_wtID_forTask(wm_subjID2,wm_sessionID2);
    TEST.DA_stdOfFolds_at_selected_wtID_forTask_1D_subjXSess1toN(wm,1) = TEST.DA_stdOfFolds_at_selected_wtID_forTask(wm_subjID2,wm_sessionID2);
 end
end

% copy_of_TEST = TEST;

% for excell plot:
TEST.DA_meanOfFolds_at_selected_wtID_forTask_1D_subjXSess1toN - (TEST.DA_stdOfFolds_at_selected_wtID_forTask_1D_subjXSess1toN/2);
TEST.DA_stdOfFolds_at_selected_wtID_forTask_1D_subjXSess1toN;

% a2(:,:) = TEST.DA_at_selected_wtID_forTask(:,wm_sessionID2,:);
%}






