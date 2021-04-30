function ptEnd()
    %PTEND Conclusive script operations
    %   Prints the total execution time and sets to false the global
    %   Execution indicator "fullExecution".
    global ptScriptTimer fullExecution;
    
    if ~isempty(fullExecution)&&fullExecution
        fprintf("Full execution completed.\nTotal execution time: %.2f s\n", seconds(datetime()-ptScriptTimer));
    end
    
    fullExecution = false;
end

