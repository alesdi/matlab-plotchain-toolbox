classdef ptFigure < handle
    %PTFIGURE Preconfigured figure management class
    %   On creation displays a blank figure with preconfigured graphical
    %   features
    
    properties
        fig
        name
        colors
    end
    
    properties (Access=private)
        gridLayout
        palette
        currentWidth
        currentColor
        currentStyle
        defaultWidth = 1.5
        defaultColor = []
        defaultStyle = '-'
    end
    
    methods
        function obj = ptFigure(name, type, xLabel, yLabel, gridR, gridC)
            %MFIGURE Creates an instance of this class
            % Opens a new figure and set its dimensions and styling
            % according to type.
            obj.fig = figure;
            
            if(~exist('name', 'var'))
                name = 'figure';
            end
            
            if(exist('type', 'var'))
                obj.size(type);
            end
            
            % Initialize properties
            obj.name = name;
            obj.currentColor = obj.defaultColor;
            obj.currentWidth = obj.defaultWidth;
            obj.currentStyle = obj.defaultStyle;
            
            % Initialize figure handle
            set(obj.fig, 'color', 'w');
            set(obj.fig, 'Renderer', 'Painters');
            
            % Initialize palette
            obj.palette = ptPalette();
            
            % Initialize grid layout
            if exist('gridR', 'var') && exist('gridC', 'var')
                obj.grid(gridR, gridC);
            else
                obj.grid(1, 1);
            end
            
            % Write labels
            if exist('xLabel', 'var')&&xLabel~=""
                obj.xLabel(xLabel);
            end
            
            if exist('yLabel', 'var')&&yLabel~=""
                obj.yLabel(yLabel);
            end
        end
        
        function obj=focus(obj)
            %FOCUS Focus the figure to edit it
            figure(obj.fig);
        end
        
        function obj=size(obj, w, h)
            %SIZE Set the figure size, according to standard types or exact
            %width and height
            if(exist('h', 'var'))
                set(obj.fig, 'Position', [0 0 w h])
            else
                switch w
                    case 'full'
                        set(obj.fig, 'Position', [0 0 1125 500]);
                    case '2/3'
                        set(obj.fig, 'Position', [0 0 750 500]);
                    case 'half'
                        set(obj.fig, 'Position', [0 0 560 500]);
                    case '1/3'
                        set(obj.fig, 'Position', [0 0 375 500]);
                    case 'quarter'
                        set(obj.fig, 'Position', [0 0 560 250]);
                    case 'page'
                        set(obj.fig, 'Position', [0 0 500 350]);
                    case 'page shorter'
                        set(obj.fig, 'Position', [0 0 500 180]);
                    case 'page short'
                        set(obj.fig, 'Position', [0 0 500 250]);
                    case 'page long'
                        set(obj.fig, 'Position', [0 0 500 600]);
                    otherwise
                        warning("Undefined size '%s'.", w);
                end
            end
        end
        
        function obj = style(obj, style)
            %STYLE Sets the style for the next plots
            % e.g. '-' for solid line, '--' for dashed, '.' for dotted.
            
            if(exist('style', 'var'))
                obj.currentStyle = style;
            else
                obj.currentStyle = obj.defaultStyle;
            end
        end
        
        function obj = color(obj, color)
            %COLOR Sets the color for the the next plot
            % Leave empty to restore the default color computed according
            % to figure's palette.
            
            if(exist('color', 'var'))
                obj.currentColor = color;
            else
                obj.currentColor = obj.defaultColor;
            end
        end
        
        function obj = width(obj, width)
            %WIDTH Sets the line width for the next plot
            
            if(exist('width', 'var'))
                obj.currentWidth = width;
            else
                obj.currentWidth = obj.defaultWidth;
            end
        end
        
        function obj=cropAll(obj, margin)
            if(~exist('margin', 'var'))
                margin = 0;
            end
            
            %CROPALL Crops all axes to eliminate any external margin
            h = (1-margin*(obj.gridLayout.r-1))/obj.gridLayout.r;
            w = (1-margin*(obj.gridLayout.c-1))/obj.gridLayout.c;
            
            xg = 1;
            
            x0 = 0;
            y0 = 0;
            
            for i = 1:length(obj.gridLayout.cells)
                cell = obj.gridLayout.cells{i};
                
                cell.crop(x0, 1-h-y0, w, h);
                
                x0 = x0 + w + margin;
                xg = xg+1;
                
                if(xg>obj.gridLayout.c)
                    xg = 1;
                    x0 = 0;
                    y0 = y0 + h + margin;
                end
            end
        end
        
        function obj=save(obj, suffix)
            %SAVE Saves the figure in the figure subfolder of the current
            %path
            
            global ptFiguresFolder;
            
            if exist('suffix', 'var')
                suffix = strcat('_', suffix);
            else
                suffix = '';
            end
            
            if ~exist(ptFiguresFolder, 'dir')
                mkdir(ptFiguresFolder)
            end
            if ~exist(strcat(ptFiguresFolder, '/png'), 'dir')
                mkdir(strcat(ptFiguresFolder, '/png'))
            end
            if ~exist(strcat(ptFiguresFolder, '/fig'), 'dir')
                mkdir(strcat(ptFiguresFolder, '/fig'))
            end
            saveas(obj.fig, strcat(ptFiguresFolder, '/fig/', obj.name, suffix, '.fig'));
            saveas(obj.fig, strcat(ptFiguresFolder, '/png/', obj.name, suffix, '.png'));
        end
        
        function obj=savePDF(obj, suffix)
            %SAVEPDF Saves the figure as PDF
            
            global ptFiguresFolder;
            
            if exist('suffix', 'var')
                suffix = strcat('_', suffix);
            else
                suffix = '';
            end
            
            set(obj.fig,'Units','Centimeters');
            pos = get(obj.fig,'Position');
            
            set(obj.fig,...
                'PaperPositionMode', 'Auto',...
                'PaperSize', pos(3:4));
            
            if ~exist(strcat(ptFiguresFolder, '/pdf'), 'dir')
                mkdir(strcat(ptFiguresFolder, '/pdf'))
            end
            
            print(obj.fig, strcat(ptFiguresFolder, '/pdf/', obj.name, suffix, '.pdf'), '-dpdf', '-r0', '-fillpage', '-loose');
        end
        
        function obj=colorNext(obj, skip)
            %COLORNEXT Switch to the next color in the palette sequence
            %   COLORNEXT([skip]) skips a number of colors in the palette
            %   sequence as specified in the parameters. By default skip=1.
            
            if ~exist('skip', 'var')
                skip = 1;
            end
            
            cell = obj.gridLayout.cells{obj.gridLayout.index};
            cell.colorIndex =  min(cell.colorIndex+skip, length(obj.palette.colors));
        end
        
        function obj=colorPrev(obj, skip)
            %COLORPREV Switch to the previous color in the palette sequence
            %   COLORPREV([skip]) skips back a number of colors in the
            %   palette sequence as specified in the parameters. By default
            %   skip=1.
            
            if ~exist('skip', 'var')
                skip = 1;
            end
            
            cell = obj.gridLayout.cells{obj.gridLayout.index};
            cell.colorIndex = max(cell.colorIndex-skip, 1);
        end
        
        function close(obj, save)
            %CLOSE Closes the figure
            %   CLOSE([save]) Closes the figure. If the parameter "save" is
            %   specified and true, the figure is saved. Then the window is
            %   closed, but only if the global variable fullExecution is
            %   true. Therefore only after ptInit and before ptEnd are
            %   called.
            
            if exist('save', 'var')&&save
                obj.save();
            end
            
            close(obj.fig);
        end
        
        function obj=plot(obj, varargin)
            %PLOT Plots the given points
            % PLOT(X, Y) plots a X-Y curve with the currently set color,
            % line width and style, that can be changed through the
            % corresponding methods. The line won't appear in the legend.
            % 
            % PLOT(name, X, Y) plots a X-Y curve with the currently set
            % color, line width and style, that can be changed through the
            % corresponding methods. The provided 'name' will appear in the
            % legend.
            
            if(length(varargin)==2)
                obj.untitledPlot(varargin{:});
            else
                obj.titledPlot(varargin{:});
            end
        end
        
        function obj = spectrogram(obj, x, window, overlap, fs, tstart)
            if ~exist('tstart', 'var')
                tstart = 0;
            end
            %SPECTROGRAM Plots a spectrogram in the current cell
            %   SPECTROGRAM(x, window, overlap, fs) Plots a spectrogram
            %   given the samples vector x, the window size (in samples), the
            %   overlap (in samples) and the sampling frequency.
            cell = obj.gridLayout.cells{obj.gridLayout.index};
            cell.spectrogram(x, window, overlap, fs, tstart);
        end
        
        function obj = addLegend(obj, location)
            if ~exist('location', 'var')
                location = 'northeast';
            end
            
            cell = obj.gridLayout.cells{obj.gridLayout.index};
            
            tmpPlots = cell.plots(cell.legendEntries ~= "");
            tmpLabels = cell.legendEntries(cell.legendEntries ~= "");
         
            tmp = legend(tmpPlots, tmpLabels);
            tmp.Location = location;
            tmp.Interpreter = 'latex';
        end
        
        function obj=xLabel(obj, label, unit)
            %XLABEL Sets the label of x axis. If a 'unit' is provided, the
            % label is printed in the following format: 'label [unit]'
            
            if ~exist('unit', 'var')
                xlabel(label, 'Interpreter','latex');
            else
                xlabel(strcat(label, ' [', unit, ']'), 'Interpreter','latex');
            end
        end
        
        function obj=yLabel(obj, label, unit)
            %YLABEL Sets the label of y axis. If a 'unit' is provided, the
            % label is printed in the following format: 'label [unit]'
            
            if ~exist('unit', 'var')
                ylabel(label, 'Interpreter','latex');
            else
                ylabel(strcat(label, ' [', unit, ']'), 'Interpreter','latex');
            end
        end
        
        function obj=title(obj, text)
            %TITLE Sets figure title
            
            title(text, 'Interpreter', 'latex');
        end
        
        function obj=xLim(obj, low, high)
            %XLIM Sets x axis limits
            
            xlim([low high]);
        end
        
        function obj=yLim(obj, low, high)
            %YLIM Sets y axis limits
            
            ylim([low high]);
        end
        
        function obj=xScale(obj, scale)
            cell = obj.gridLayout.cells{obj.gridLayout.index};
            cell.setScaleX(scale);
        end
        
        function obj=yScale(obj, scale)
            cell = obj.gridLayout.cells{obj.gridLayout.index};
            cell.setScaleY(scale);
        end
        
        function obj=xLine(obj, name, c, style, color)
            %XLINE Plots a vertical line
            
            if ~exist('style', 'var')
                style = '';
            end
            
            cell = obj.gridLayout.cells{obj.gridLayout.index};
            
            if ~exist('color', 'var')
                color = obj.palette.color(cell.colorIndex);
                cell.colorIndex = cell.colorIndex+1;
            elseif isstring(color)||ischar(color)
                color = obj.palette.color(color);
            end
            
            cell.xLine(name, c, style, color);
        end
        
        function obj=yLine(obj, name, c, style, color)
            %YLINE Plots a horizontal line
            
            if ~exist('style', 'var')
                style = '';
            end
            
            cell = obj.gridLayout.cells{obj.gridLayout.index};
            
            if ~exist('color', 'var')
                color = obj.palette.color(cell.colorIndex);
                cell.colorIndex = cell.colorIndex+1;
            elseif isstring(color)||ischar(color)
                color = obj.palette.color(color);
            end
            
            cell.yLine(name, c, style, color);
        end
        
        function obj=grid(obj, r, c)
            %GRID Prepares a grid of plots with r rows and c columns and
            % move the plot cursor to the first cell
            
            obj.gridLayout.r = r;
            obj.gridLayout.c = c;
            obj.gridLayout.index = 0;
            obj.gridLayout.cells{r*c} = ptCell;
            for ii=1:(r*c-1)
                obj.gridLayout.cells{ii} = ptCell;
            end
            obj.gridNext();
        end
        
        function obj=gridSet(obj, index)
            %GRIDSET Sets the plot cursor in the current grid to the given
            % index (cells are numbered from left to right, top to bottom)
            
            cell = obj.gridLayout.cells{index};
            cell.setAxes(subplot(obj.gridLayout.r, obj.gridLayout.c, index));
            obj.gridLayout.index = index;
        end
        
        function obj=gridFocus(obj)
            %GRIDFOCUS Restores focus on the current grid cell, if necessary
            
            obj.gridSet(obj.gridLayout.index);
        end
        
        function obj=gridNext(obj, xLabel, yLabel)
            %GRIDNEXT Moves the plot cursor in the current grid to the next
            % cell
            
            obj.gridLayout.index = obj.gridLayout.index+1;
            obj.gridSet(obj.gridLayout.index);
            
            if exist('xLabel', 'var')&&xLabel~=""
                obj.xLabel(xLabel);
            end
            
            if exist('yLabel', 'var')&&yLabel~=""
                obj.yLabel(yLabel);
            end
        end
        
        function obj=gridPrev(obj)
            %GRIDPREV Moves the plot cursor in the current grid to the
            % previous cell
            
            obj.gridLayout.index = obj.gridLayout.index-1;
            obj.gridSet(obj.gridLayout.index);
        end
        
        function obj=linkX(obj)
            %LINKX Links all the x axes of the plots in the current grid
            obj.focus();
            
            axes = [];
            
            for k = length(obj.gridLayout.cells):-1:1
                axes(k) = obj.gridLayout.cells{k}.axes;
            end
            
            linkaxes(axes, 'x');
        end
        
        function obj=linkY(obj)
            %LINKY Links all the y axes of the plots in the current grid
            obj.focus();
            
            axes = [];
            
            for k = length(obj.gridLayout.cells):-1:1
                axes(k) = obj.gridLayout.cells{k}.axes;
            end
            
            linkaxes(axes, 'y');
        end
        
        function obj=setPalette(obj, palette)
            %SETPALETTE Sets the color palette
            
            if(isstring(palette))
                obj.palette.load(palette);
            else
                obj.palette = palette;
            end
            
            for k = 1:length(obj.gridLayout.cells)
                obj.gridLayout.cells{k}.colorIndex = 1;
            end
        end
        
        function res=promptX(~, n)
            %PROMPTX Prompts for the selection of n points on the current
            % plot and returns their x coordinates as a vector
            
           if ~exist('n', 'var')
               n = 1;
           end
           
           [xs, ~] = ginput(n);
           
           res = xs;
        end
        
        function obj=promptY(obj, n, prefix)
            %PROMPTY Prompts for the selection of n points on the current
            % plot and returns their y coordinates as a vector
            
           if ~exist('prefix', 'var')
                prefix = 'x';
           end
           
           [~, ys] = ginput(n);
           
           index = 0;
           for y = ys
               fprintf('%s%d = %f;\n', prefix, index, y);
               
               index = index+1;
           end
        end
    end
    
    
    methods (Access = private)
        function obj=titledPlot(obj, name, x, y, style, color, width)
            if ~exist('style', 'var')
                style = obj.currentStyle;
            end
            
            if ~exist('width', 'var')
                width = obj.currentWidth;
            end
            
            cell = obj.gridLayout.cells{obj.gridLayout.index};
            
            if ~exist('color', 'var')
                if(isempty(obj.currentColor))
                    color = obj.palette.color(cell.colorIndex);
                    cell.colorIndex = cell.colorIndex+1;
                else
                    color = obj.palette.color(obj.currentColor);
                end
            elseif isstring(color)||ischar(color)
                color = obj.palette.color(color);
            end
            
            cell.plot(name, x, y, style, color, width);
        end
        
        function obj=untitledPlot(obj, x, y)
            style = obj.currentStyle;
            width = obj.currentWidth;
            
            cell = obj.gridLayout.cells{obj.gridLayout.index};
            
            if(isempty(obj.currentColor))
                color = obj.palette.color(cell.colorIndex);
                cell.colorIndex = cell.colorIndex+1;
            else
                color = obj.palette.color(obj.currentColor);
            end
            
            cell.plot('', x, y, style, color, width);
        end
    end
end

