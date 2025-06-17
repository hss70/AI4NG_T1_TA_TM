

% _______________________________________________
%
% DA plot (original and opt permuted in one plot)
% _______________________________________________

if SW.smoothed_plot == 1
    clearvars plotData_orig
    plotData_orig = result.orig.DA.smooth.testFold_DA_Plots(:,:);

    if isfield(result,'perm')
        wm1=0;
        clearvars plotData_perm
        for wm2 = 1 : size(result.perm,2)
            wm = size(result.perm{1, wm2}.DA.smooth.testFold_DA_Plots,1);
            plotData_perm(wm1+1 : wm1+wm, :) = result.perm{1, wm2}.DA.smooth.testFold_DA_Plots(:,:);
            wm1 = wm1+wm;
        end
    else
        plotData_perm = '';
    end
else
    clearvars plotData_orig
    plotData_orig = result.orig.DA.opt.testFold_DA_Plots(:,:);

    if isfield(result,'perm')
        wm1=0;
        clearvars plotData_perm
        for wm2 = 1 : size(result.perm,2)
            wm = size(result.perm{1, wm2}.DA.opt.testFold_DA_Plots,1);
            plotData_perm(wm1+1 : wm1+wm, :) = result.perm{1, wm2}.DA.opt.testFold_DA_Plots(:,:);
            wm1 = wm1+wm;
        end
    else
        plotData_perm = '';
    end
end

%{
% % % % figure;
% % % % subplot(2,2,1); plot(plotData{wm_taskID}'); title('plot: test DA folds')
% % % % subplot(2,2,2); shadedErrorBar([], mean(plotData{wm_taskID},1)*100, std(plotData{wm_taskID},1)*100, 'lineprops','bp-'); title('shadedErrorBar: test DA folds') 
% % % % subplot(2,2,3); plot(plotDataSmooth{wm_taskID}'); title('plot: smoothed test DA folds')
% % % % subplot(2,2,4); shadedErrorBar([], mean(plotDataSmooth{wm_taskID},1)*100, std(plotDataSmooth{wm_taskID},1)*100, 'lineprops','b'); title('shadedErrorBar: smoothed test DA folds') 
%}

% _________________________
%
% Figure directory (create)
% _________________________

wm_save_subDir = '- Fig';
if ~isdir([VA_TRANS.f.baseDir,'\',wm_save_subDir,'\'])
    mkdir(VA_TRANS.f.baseDir, wm_save_subDir);
end
PLOT.file.save.path = [VA_TRANS.f.baseDir,'\',wm_save_subDir,'\'];

% ____________________
%
% Plot and save Figure
% ____________________

PLOT.fig.h.figID = figure;
if SW.smoothed_plot == 1
    PLOT.fig.h.shadedPlot_orig = shadedErrorBar([], mean(plotData_orig,1)*100, std(plotData_orig,1)*100, 'lineprops','b');  % 'b' or 'bp-' or 'bo-'
    % PLOT.fig.h.shadedPlot_orig = shadedErrorBar([], mean(plotData_orig,1)*100, std(plotData_orig,1)*100, 'lineprops','bp-');  % 'b' or 'bp-' or 'bo-'
else
    % PLOT.fig.h.shadedPlot_orig = shadedErrorBar([], mean(plotData_orig,1)*100, std(plotData_orig,1)*100, 'lineprops','b');  % 'b' or 'bp-' or 'bo-'
    PLOT.fig.h.shadedPlot_orig = shadedErrorBar([], mean(plotData_orig,1)*100, std(plotData_orig,1)*100, 'lineprops','bp-');  % 'b' or 'bp-' or 'bo-'
end
if isfield(result,'perm')
    PLOT.fig.h.shadedPlot_perm = shadedErrorBar([], mean(plotData_perm,1)*100, std(plotData_perm,1)*100, 'lineprops','r--');  % 'k' or 'r'
    % PLOT.fig.h.shadedPlot_perm = shadedErrorBar([], mean(plotData_perm,1)*100, std(plotData_perm,1)*100, 'lineprops','r');    % 'k' or 'r'

    if SW.smoothed_plot == 1
        title([VA_TRANS.subjID_text,': smoothed time-varying DA and randPerm DA'])
    else
        title([VA_TRANS.subjID_text,': time-varying DA and randPerm DA'])
    end
    % title([VA_TRANS.subjID_text,': ',...
    %       'peakDA=',num2str(result.summary.orig_peak_DA_mean*100,'%4.2f'),'(',num2str(result.summary.orig_peak_DA_std*100,'%4.2f'),'), ', ...
    %       'permDA=',num2str(result.summary.perm_peak_DA_mean*100,'%4.2f'),'(',num2str(result.summary.perm_peak_DA_std*100,'%4.2f'),'), ', ...
    %       'pV=',num2str(result.summary.mc_p_OF_orig_vs_perm_peak_DA,'%4.2f')])
    % title([VA_TRANS.subjID_text,': Time-varying CVAC and permAC'])
else
    %   title([VA_TRANS.subjID_text,': ',SW.smoothed_plot,'Time-varying DA and randPerm DA'])
    if SW.smoothed_plot == 1
        title([VA_TRANS.subjID_text,': smoothed time-varying DA'])
    else
        title([VA_TRANS.subjID_text,': time-varying DA'])
    end
end
set(gcf,'color','w');
grid on
c = VA_TRANS.c;
c.tt = TM.taskParam{1,end}.c.tt;
xlim([-(c.tt.cf.p.winSize.ms/c.tt.cf.p.winStep.ms)+1, size(plotData_orig,2)])
xticks(-(c.tt.cf.p.winSize.ms/c.tt.cf.p.winStep.ms)+1 : 1000/c.tt.cf.p.winStep.ms : size(plotData_orig,2))
% xticklabels(num2cell(c.prep.trial.trig_PRE_ms/1000 : 1 : c.prep.trial.trig_PST_ms/1000))
xticklabels(num2cell(0 : 1 : -c.prep.trial.trig_PRE_ms/1000 + c.prep.trial.trig_PST_ms/1000))
xlabel('time(ms)')
ylabel('DA(%)')
% ylabel('AC(%)')
ylim([10,100])
% ylim([PLOT.w.ylim])
% if isfield(result,'perm')
%   legend([PLOT.fig.h.shadedPlot_orig.mainLine, PLOT.fig.h.shadedPlot_perm.mainLine], 'DA','perm DA')
%   if SW.annotation.permDA_ifExist == 1
%   elseif SW.annotation.permDA_ifExist == 0
%       if SW.smoothed_plot == 1
%         wm = {['DA(',num2str(result.orig.timeInfo.ms_from_PRE_point.smooth_peakDAPoint_task/1000,'%4.1f'),'s)', ...
%                ' = ',num2str(result.orig.DA.smooth.taskPeakDA_mean*100,'%4.1f'),'±',num2str(result.orig.DA.smooth.taskPeakDA_std*100,'%4.1f'),'%']; ...
%               ['perm DA(',num2str(result.orig.timeInfo.ms_from_PRE_point.smooth_peakDAPoint_task/1000,'%4.1f'),'s)', ...
%                ' = ',num2str(result.all_perms.DA.smooth.perm_DA_mean__atOrigSmoothTaskPeak*100,'%4.1f'),'±',num2str(result.all_perms.DA.smooth.perm_DA_std__atOrigSmoothTaskPeak*100,'%4.1f'),'%']};
%       else
%         wm = {['DA(',num2str(result.orig.timeInfo.ms_from_PRE_point.opt_peakDAPoint_task/1000,'%4.1f'),'s)', ...
%                ' = ',num2str(result.orig.DA.opt.taskPeakDA_mean*100,'%4.1f'),'±',num2str(result.orig.DA.opt.taskPeakDA_std*100,'%4.1f'),'%']; ...
%               ['perm DA(',num2str(result.orig.timeInfo.ms_from_PRE_point.opt_peakDAPoint_task/1000,'%4.1f'),'s)', ...
%                ' = ',num2str(result.all_perms.DA.opt.perm_DA_mean__atOrigTaskPeak*100,'%4.1f'),'±',num2str(result.all_perms.DA.opt.perm_DA_std__atOrigTaskPeak*100,'%4.1f'),'%']};
%       end
%   end
% else
%   legend([PLOT.fig.h.shadedPlot_orig.mainLine], 'DA')
%   if SW.annotation.refDA == 1
%    if SW.smoothed_plot == 1
%     wm = {['DA(',num2str(result.orig.timeInfo.ms_from_PRE_point.smooth_peakDAPoint_task/1000,'%4.1f'),'s)', ...
%            ' = ',num2str(result.orig.DA.smooth.taskPeakDA_mean*100,'%4.1f'),'±',num2str(result.orig.DA.smooth.taskPeakDA_std*100,'%4.1f'),'%']; ...
%           ['ref DA(',num2str(result.orig.timeInfo.ms_from_PRE_point.smooth_peakDAPoint_ref/1000,'%4.1f'),'s)', ...
%            ' = ',num2str(result.orig.DA.smooth.refPeakDA_mean*100,'%4.1f'),'±',num2str(result.orig.DA.smooth.refPeakDA_std*100,'%4.1f'),'%', ...
%            ' (p=',num2str(result.orig.RT_stat.smooth.refPeakDA_lowerThan_taskPeakDA.p_tt,'%4.2f'),')']};
%    else
%     wm = {['DA(',num2str(result.orig.timeInfo.ms_from_PRE_point.opt_peakDAPoint_task/1000,'%4.1f'),'s)', ...
%            ' = ',num2str(result.orig.DA.opt.taskPeakDA_mean*100,'%4.1f'),'±',num2str(result.orig.DA.opt.taskPeakDA_std*100,'%4.1f'),'%']; ...
%           ['ref DA(',num2str(result.orig.timeInfo.ms_from_PRE_point.opt_peakDAPoint_ref/1000,'%4.1f'),'s)', ...
%            ' = ',num2str(result.orig.DA.opt.refPeakDA_mean*100,'%4.1f'),'±',num2str(result.orig.DA.opt.refPeakDA_std*100,'%4.1f'),'%', ...
%            ' (p=',num2str(result.orig.RT_stat.opt.refPeakDA_lowerThan_taskPeakDA.p_tt,'%4.2f'),')']};
%    end
%   elseif SW.annotation.refDA == 0
%    if SW.smoothed_plot == 1
%     wm = ['DA(',num2str(result.orig.timeInfo.ms_from_PRE_point.smooth_peakDAPoint_task/1000,'%4.1f'),'s)', ...
%           ' = ',num2str(result.orig.DA.smooth.taskPeakDA_mean*100,'%4.1f'),'±',num2str(result.orig.DA.smooth.taskPeakDA_std*100,'%4.1f'),'%'];
%    else
%     wm = ['DA(',num2str(result.orig.timeInfo.ms_from_PRE_point.opt_peakDAPoint_task/1000,'%4.1f'),'s)', ...
%           ' = ',num2str(result.orig.DA.opt.taskPeakDA_mean*100,'%4.1f'),'±',num2str(result.orig.DA.opt.taskPeakDA_std*100,'%4.1f'),'%'];
%    end
%   end
% end
if isfield(result,'perm')
    legend([PLOT.fig.h.shadedPlot_orig.mainLine, PLOT.fig.h.shadedPlot_perm.mainLine], 'DA','perm DA')
else
    legend([PLOT.fig.h.shadedPlot_orig.mainLine], 'DA')
end
if SW.smoothed_plot == 1
    wm = {['DA(',num2str(result.orig.timeInfo.ms_from_PRE_point.smooth_peakDAPoint_task/1000,'%4.1f'),'s)', ...
        ' = ',num2str(result.orig.DA.smooth.taskPeakDA_mean*100,'%4.1f'),'±',num2str(result.orig.DA.smooth.taskPeakDA_std*100,'%4.1f'),'%']};
else
    wm = {['DA(',num2str(result.orig.timeInfo.ms_from_PRE_point.opt_peakDAPoint_task/1000,'%4.1f'),'s)', ...
        ' = ',num2str(result.orig.DA.opt.taskPeakDA_mean*100,'%4.1f'),'±',num2str(result.orig.DA.opt.taskPeakDA_std*100,'%4.1f'),'%']};
end
if isfield(result,'perm') && (SW.annotation.permDA_ifExist == 1)
    if SW.smoothed_plot == 1
        wm{end+1,1} = ...
            ['perm DA(',num2str(result.orig.timeInfo.ms_from_PRE_point.smooth_peakDAPoint_task/1000,'%4.1f'),'s)', ...
            ' = ',num2str(result.all_perms.DA.smooth.perm_DA_mean__atOrigSmoothTaskPeak*100,'%4.1f'),'±',num2str(result.all_perms.DA.smooth.perm_DA_std__atOrigSmoothTaskPeak*100,'%4.1f'),'%'];
    else
        wm{end+1,1} = ...
            ['perm DA(',num2str(result.orig.timeInfo.ms_from_PRE_point.opt_peakDAPoint_task/1000,'%4.1f'),'s)', ...
            ' = ',num2str(result.all_perms.DA.opt.perm_DA_mean__atOrigTaskPeak*100,'%4.1f'),'±',num2str(result.all_perms.DA.opt.perm_DA_std__atOrigTaskPeak*100,'%4.1f'),'%'];
    end
end
if SW.annotation.refDA == 1
    if SW.smoothed_plot == 1
        wm{end+1,1} = ...
            ['ref DA(',num2str(result.orig.timeInfo.ms_from_PRE_point.smooth_peakDAPoint_ref/1000,'%4.1f'),'s)', ...
            ' = ',num2str(result.orig.DA.smooth.refPeakDA_mean*100,'%4.1f'),'±',num2str(result.orig.DA.smooth.refPeakDA_std*100,'%4.1f'),'%', ...
            ' (p=',num2str(result.orig.RT_stat.smooth.refPeakDA_lowerThan_taskPeakDA.p_tt,'%4.2f'),')'];
    else
        wm{end+1,1} = ...
            ['ref DA(',num2str(result.orig.timeInfo.ms_from_PRE_point.opt_peakDAPoint_ref/1000,'%4.1f'),'s)', ...
            ' = ',num2str(result.orig.DA.opt.refPeakDA_mean*100,'%4.1f'),'±',num2str(result.orig.DA.opt.refPeakDA_std*100,'%4.1f'),'%', ...
            ' (p=',num2str(result.orig.RT_stat.opt.refPeakDA_lowerThan_taskPeakDA.p_tt,'%4.2f'),')'];
    end
end
if (SW.annotation.refDA + (isfield(result,'perm')*SW.annotation.permDA_ifExist)) < 2
    annotation('textbox', [0.14, 0.13, 0.1, 0.1], 'String', wm, 'FitBoxToText','on')
else
    annotation('textbox', [0.14, 0.17, 0.1, 0.1], 'String', wm, 'FitBoxToText','on')
end
clearvars c

% Save and close the plot
% PLOT.file.save.name = [PLOT.file.save.nameBasis,' (Subj',num2str(wm_subjID),',Session',num2str(wm_sessionID),')'];
if SW.smoothed_plot == 1
    PLOT.file.save.name = ['DA plot (smoothed)'];
else
    PLOT.file.save.name = ['DA plot'];
end
saveas(PLOT.fig.h.figID, [PLOT.file.save.path,PLOT.file.save.name],'fig');
% saveas(PLOT.fig.h.figID, [PLOT.file.save.path,PLOT.file.save.name],'jpg');
saveas(PLOT.fig.h.figID, [PLOT.file.save.path,PLOT.file.save.name],'png');
%Save JSON config
jsonFilePath = [PLOT.file.save.path, PLOT.file.save.name, '.json'];
savePlotConfigToJSON(PLOT.fig.h.figID, [PLOT.file.save.path, PLOT.file.save.name, '.mat'], 'line-shadedError', jsonFilePath);
% saveas(PLOT.fig.h.figID, [PLOT.file.save.path,PLOT.file.save.name],'tif');
% saveas(PLOT.fig.h.figID, [PLOT.file.save.path,PLOT.file.save.name],'pdf');
if VA_TRANS.SW_close_figures == 1
    close(PLOT.fig.h.figID);
end

plotData.orig.data = plotData_orig;
plotData.orig.mean = mean(plotData_orig,1);
plotData.orig.std = std(plotData_orig,1);
plotData.orig.median = median(plotData_orig,1);
plotData.orig.min = min(plotData_orig,[],1);
plotData.orig.max = max(plotData_orig,[],1);
if isfield(result,'perm')
    % plotData.perm.data = plotData_perm;
    plotData.perm.mean = mean(plotData_perm,1);
    plotData.perm.std = std(plotData_perm,1);
    plotData.perm.median = median(plotData_perm,1);
    plotData.perm.min = min(plotData_perm,[],1);
    plotData.perm.max = max(plotData_perm,[],1);
end
save([PLOT.file.save.path,PLOT.file.save.name,'.mat'],'plotData','-v7.3');
clearvars plotData



