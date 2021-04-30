classdef ptStore < handle
    %MSTORE A simple folder-based persistent data storage
    
    properties (Access=private)
        data
    end
        
    methods
        function obj = ptStore()
            %MSTORE Constructs an instance of this class
            %   Loads data from the sotrage or creates the needed
            %   subfolders if absent
            
            obj.refresh();
        end
        
        function set(obj, key, value, skipConsolidation)
            %SET Sets the provided value for the specified field
            obj.assertValidKey(key);
            
            if(~exist('skipConsolidation', 'var'))
                skipConsolidation = false;
            end
            
            obj.data.(key) = value;
            
            if(~skipConsolidation)
                obj.consolidate();
            end
        end
        
        function res = get(obj, key, default)
            %GET Returns the value for the specified field. If the field
            % does not exists sets it to the default value and returns it.
            obj.assertValidKey(key);
            
            if(isfield(obj.data, key))
                res = obj.data.(key);
            elseif(exist('default', 'var'))
                res = default;
                obj.set(key, default);
            else
                error('The persistent storage field %s does not exist in the current folder. Create it or provide a default value.', key);
            end
        end
        
        function res = hasKey(obj, key)
            %HASKEY Returns true if the specified key exists. False
            % otherwise.
            obj.assertValidKey(key);
            
            res  = isfield(obj.data, key);
        end
        
        function refresh(obj)
            %REFRESH Reloads data from the file system
            if ~exist('.store', 'dir')
                mkdir('.store')
            end
            
            obj.data = struct();
            
            if exist('.store/store.mat', 'file')
               obj.data = load('.store/store.mat');
            end
        end
        
        function consolidate(obj)
            %CONSOLIDATE Saves data to the file system
            body = obj.data;
            save('.store/store.mat', '-struct', 'body');
        end
        
        function clear(obj, key)
            %CLEAR Clear data from local storage
            % CLEAR() Clear all data
            %
            % CLEAR(key) Clear only given key
            if(exist('key', 'var'))
                obj.data = rmfield(obj.data, key);
                obj.consolidate();
            else
                obj.data = [];
                rmdir('.store', 's');
            end
        end
    end
    
    
    methods (Access=private)
        function res = isValidKey(~, key)
            res = isvarname(key);
        end
        
        function assertValidKey(obj, key)
            if(~obj.isValidKey(key))
                error('Invalid key name ''%s''.', key);
            end
        end
    end
end

