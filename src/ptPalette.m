classdef ptPalette < handle
    properties
        presets;
        colors = {};
    end
    
    methods
        function obj = ptPalette(name)
            obj.presets.default.colors{1}.name = "blue";
            obj.presets.default.colors{1}.rgb = [81 153 224]./255;
            obj.presets.default.colors{2}.name = "green";
            obj.presets.default.colors{2}.rgb = [164 221 110]./255;
            obj.presets.default.colors{3}.name = "orange";
            obj.presets.default.colors{3}.rgb = [221 148 110]./255;
            obj.presets.default.colors{4}.name = "violet";
            obj.presets.default.colors{4}.rgb = [185 110 221]./255;
            obj.presets.default.colors{5}.name = "dark blue";
            obj.presets.default.colors{5}.rgb = [39 100 161]./255;
            obj.presets.default.colors{6}.name = "dark green";
            obj.presets.default.colors{6}.rgb = [76 102 51]./255;
            obj.presets.default.colors{7}.name = "dark orange";
            obj.presets.default.colors{7}.rgb = [102 68 51]./255;
            obj.presets.default.colors{8}.name = "dark violet";
            obj.presets.default.colors{8}.rgb = [85 51 102]./255;
            obj.presets.default.colors{9}.name = "light grey";
            obj.presets.default.colors{9}.rgb = [162 182 195]./255;
            obj.presets.default.colors{10}.name = "grey";
            obj.presets.default.colors{10}.rgb = [86 114 133]./255;
            obj.presets.default.colors{11}.name = "dark grey";
            obj.presets.default.colors{11}.rgb = [57 76 88]./255;
            obj.presets.default.colors{12}.name = "black";
            obj.presets.default.colors{12}.rgb = [0 0 0]./255;
            obj.presets.default.colors{13}.name = "white";
            obj.presets.default.colors{13}.rgb = [255 255 255]./255;
            
            if(exist('name', 'var'))
                obj.load(name);
            else
                obj.load('default');
            end
        end

        function obj = load(obj, name)
            obj.colors = obj.presets.(name).colors;
        end
        
        function [rgb] = color(obj, nameOrIndex)
            if(isnumeric(nameOrIndex))
                rgb = obj.colors{nameOrIndex}.rgb;
                return;
                %TODO: cyclic index
            elseif(isstring(nameOrIndex)||ischar(nameOrIndex))
                nameOrIndex = convertCharsToStrings(nameOrIndex);
                for k = 1:length(obj.colors)
                    if obj.colors{k}.name == nameOrIndex
                        rgb = obj.colors{k}.rgb;
                        return;
                    end
                end
                
                error("Undefined color %s.", nameOrIndex); 
            end
            
            error("Invalid argument");
        end
        
        function newPalette = generateBrightnessVariations(obj, color, nSteps)
            color = convertCharsToStrings(color);
            
            rgb = obj.color(color);
            hsv = rgb2hsv(rgb);
            limit = 0.4;
            dv = (hsv(3)-limit)/(nSteps-1);
            steps = hsv(3):-dv:limit;
            
            newPalette = ptPalette();
            newPalette.colors = {};
            for k = 1:length(steps)
                newPalette.colors{k}.rgb = hsv2rgb([hsv(1:2) steps(k)]);
            end
        end
        
        function res = colormap(obj, color1, color2)
           c1 = obj.color(color1);
           c2 = obj.color(color2);
           r = linspace(min(c1(1), c2(1)), max(c1(1), c2(1)), 256);
           g = linspace(min(c1(2), c2(2)), max(c1(2), c2(2)), 256);
           b = linspace(min(c1(3), c2(3)), max(c1(3), c2(3)), 256);
           
           res = [r' g' b']; 
        end
    end
end