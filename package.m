% Package the toolbox
try
    dirPath = fileparts(which(mfilename));
    projectPath = [dirPath '/mToolbox.prj'];
    outputPath = [dirPath '/build/mToolbox'];
    matlab.addons.toolbox.packageToolbox(projectPath, outputPath);
    
    fprintf('Toolbox successfully packaged:\n%s\n', outputPath);
catch e
    disp(e);
end