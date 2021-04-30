function ptInit(figuresFolder, clearfigures)
    %MINIT Basic initialization function for any script
    %   Close all windows, clear the workspace, initialize the global timer
    %   and, if specified, clear the figure folder, add libraries
    clc;
   % close all;
    global ptScriptTimer ptFiguresFolder fullExecution;
    
    fullExecution = true;
    
    if ~exist('figuresFolder', 'var')||isempty(figuresFolder)
        figuresFolder = "figures";
    else
        figuresFolder = strcat("figures_", figuresFolder);
    end
    
    ptFiguresFolder = figuresFolder;
    
    if exist('clearfigures', 'var')&&exist(ptFiguresFolder, 'dir')&&clearfigures
        fprintf("All saved figures cleared.\n");
        rmdir(ptFiguresFolder, 's')
    end
    
    ptScriptTimer = datetime();
    
    fprintf("Execution started.\n");
    clear;
end

