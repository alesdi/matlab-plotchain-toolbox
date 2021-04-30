classdef ptCell < handle
    %PTCELL A single cell of a ptFigure
    
    properties
        plotIndex = 1
        colorIndex = 1
        plots = []
        legendEntries = {}
        axes
    end
    
    methods
        function obj = ptCell()
            %PTCELL Constructs an instance of this class
        end
        
        function plot(obj, name, x, y, style, color, width)
            if style=="stem"
                obj.plots(obj.plotIndex) = stem(x, y, 'Marker', 'none', 'Color', color, 'LineWidth', width);
            else
                obj.plots(obj.plotIndex) = plot(x, y, style, 'Color', color, 'LineWidth', width, 'MarkerSize', width*3);
            end
            
            obj.legendEntries{obj.plotIndex} = char(name);
            obj.plotIndex = obj.plotIndex+1;
        end
        
        function xLine(obj, name, c, style, color)
            obj.plots(obj.plotIndex) = xline(c, style, 'Color', color, 'LineWidth', 1.5);
                
            obj.legendEntries{obj.plotIndex} = char(name);
            obj.plotIndex = obj.plotIndex+1;
        end
        
        function yLine(obj, name, c, style, color)
            obj.plots(obj.plotIndex) = yline(c, style, 'Color', color, 'LineWidth', 1.5);
                
            obj.legendEntries{obj.plotIndex} = char(name);
            obj.plotIndex = obj.plotIndex+1;
        end
        
        function spectrogram(obj, x, window, overlap, fs, tstart)
            [~, F, T, P] = spectrogram(x, window, overlap, [], fs, 'yaxis');
            imagesc(T+tstart, F, 20*log10(P));
            obj.axes = gca;
            obj.axes.YDir = 'normal';
            %colormap([linspace(255,110,256)', linspace(255,177,256)', linspace(255,221,256)']/255);
            
            tmp = ptPalette();
            colormap(tmp.colormap('grey', 'white'));
            
            c = colorbar('southoutside');
            c.TickLabelInterpreter = 'latex';
            c.Label.String = 'potenza/frequenza [dB/Hz]';
            c.Label.Interpreter = 'latex';    
            xlim([T(1) T(end)]);
            ylim([0 fs/2]);
        end
        
        function setAxes(obj, axes)
           obj.axes = axes;
           obj.axes.TickLabelInterpreter = 'latex';
           obj.axes.FontSize = 14;
           
           hold on;
           grid on;
           box on;
        end
        
        function crop(obj, x0, y0, w, h)
            set(obj.axes, 'units', 'normalized'); %Just making sure it's normalized
            Tight = get(obj.axes, 'TightInset');  %Gives you the bording spacing between plot box and any axis labels
                                              %[Left Bottom Right Top] spacing
            Tight(1) = mod(Tight(1), w);
            Tight(2) = mod(Tight(2), h);
            Tight(3) = mod(Tight(3), w);
            Tight(4) = mod(Tight(4), h);
            
            obj.axes.Position = [x0+Tight(1) y0+Tight(2) w-Tight(1)-Tight(3) h-Tight(2)-Tight(4)]; %New plot position [X Y W H]
        end
        
        function setScaleX(obj, scale)
            set(obj.axes, 'XScale', scale);
        end
        
        function setScaleY(obj, scale)
            set(obj.axes, 'YScale', scale);
        end
    end
end

