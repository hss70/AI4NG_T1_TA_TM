function savePlotConfigToJSON(figHandle, dataFilePath, plotType, jsonFilePath)
% Save plot configuration and metadata to JSON
%
% Inputs:
%   - figHandle: figure handle (e.g., gcf)
%   - dataFilePath: path to associated data file (e.g., the .mat file with data)
%   - plotType: string describing the plot type ('topoplot', 'heatmap', 'line-shadedError')
%   - jsonFilePath: full path to the JSON file to save (including .json extension)
%

% Title and axis labels
plotConfig.title = get(get(gca, 'Title'), 'String');
plotConfig.xlabel = get(get(gca, 'XLabel'), 'String');
plotConfig.ylabel = get(get(gca, 'YLabel'), 'String');

% Axis limits
plotConfig.xlim = get(gca, 'XLim');
plotConfig.ylim = get(gca, 'YLim');

% Figure size
plotConfig.figSize = get(figHandle, 'Position');

% Associated data file
plotConfig.dataFile = dataFilePath;
plotConfig.dataType = plotType;

% Timestamp
plotConfig.timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');

% Colorbar (if applicable)
cbar = findobj(figHandle, 'Type', 'ColorBar');
plotConfig.colorbar = ~isempty(cbar);

% Plot-type specific details
switch plotType
    case 'topoplot'
        % Topoplot-specific: colormap
        plotConfig.colormap = colormap(gca);
        
    case 'heatmap'
        % Heatmap-specific: colormap
        plotConfig.colormap = colormap(gca);
        if plotConfig.colorbar
            plotConfig.caxis = caxis;
        end
        
    case 'line-shadedError'
        % Line shaded error plot: get line color and style
        lines = findobj(gca, 'Type', 'Line');
        if ~isempty(lines)
            % Assuming one line, you can adapt for multiple lines if needed
            lineColor = get(lines(1), 'Color');
            lineStyle = get(lines(1), 'LineStyle');
            marker = get(lines(1), 'Marker');
            plotConfig.lines = struct( ...
                'color', lineColor, ...
                'lineStyle', lineStyle, ...
                'marker', marker, ...
                'errorShading', true ...
            );
        end
end

% Save to JSON
fid = fopen(jsonFilePath, 'w');
if fid == -1
    error('Cannot create JSON config file: %s', jsonFilePath);
end
fprintf(fid, '%s', jsonencode(plotConfig, 'PrettyPrint', true));
fclose(fid);

fprintf('Saved JSON config: %s\n', jsonFilePath);

end
