classdef ptDataset < handle
    %MDATASET Preconfigured dataset management class
    %   On creation loads data from a specified file
    
    properties
        t_rpm_MCU_raw
        rpm_MCU_raw
        t_rpm_GCU_raw
        rpm_GCU_raw
        t_I_GCU_raw
        I_GCU_raw
        t_V_GCU_raw
        V_GCU_raw
        t_V_BMS_raw
        V_BMS_raw
        t_PWM_GCU_raw
        PWM_GCU_raw
        t_PWM_GCU_ref_raw
        PWM_GCU_ref_raw
        t_perc_MCU_ref_raw
        perc_MCU_ref_raw
        t_debug1_raw
        debug1_raw
        meandt
    end
    
    methods
        function obj = ptDataset(filename)
            %MDATASET Construct an instance of this class
            %   Opens a new figure and set its dimensions and styling
            %   according to type
            
            % Load raw data in workspace
            warning('off');
            load(filename, 'MCU_DATAS_TX_MCU_Speed', ...
                'GCU_DATA_TX_GCU_Motor_rpm', ...
                'GCU_DATA_TX_GCU_Motor_amps', ...
                'GCU_DATA_TX_GCU_Motor_PWM',...
                'GCU_INPUT_RX_GCU_Reference',...
                'GCU_BATTERY_DATA_TX_GCU_Battery_voltage',...
                'GCU_DATA_TX_GCU_Motor_voltage',...
                'MCU_INPUTS_RX_MCU_Throttle_value',...
                'E103_DEBUG_E103_debug_1');
            warning('on');

            % Extract meaningful tracks
            try
                obj.t_rpm_GCU_raw = GCU_DATA_TX_GCU_Motor_rpm(:, 1); % [s]
                obj.rpm_GCU_raw = GCU_DATA_TX_GCU_Motor_rpm(:, 2)/10.38; % [rpm]
                obj.t_I_GCU_raw = GCU_DATA_TX_GCU_Motor_amps(:, 1); % [s]
                obj.I_GCU_raw = GCU_DATA_TX_GCU_Motor_amps(:, 2)/10; % [A]
                obj.t_PWM_GCU_raw = GCU_DATA_TX_GCU_Motor_PWM(:, 1); % [s]
                obj.PWM_GCU_raw = GCU_DATA_TX_GCU_Motor_PWM(:, 2); % [PWM]
                obj.t_PWM_GCU_ref_raw = GCU_INPUT_RX_GCU_Reference(:, 1); % [s]
                obj.PWM_GCU_ref_raw = GCU_INPUT_RX_GCU_Reference(:, 2); % [PWM]
                obj.t_V_GCU_raw = GCU_DATA_TX_GCU_Motor_voltage(:, 1); % [s]
                obj.V_GCU_raw = GCU_DATA_TX_GCU_Motor_voltage(:, 2); % [V]
                obj.t_V_BMS_raw = GCU_BATTERY_DATA_TX_GCU_Battery_voltage(:, 1); % [s]
                obj.V_BMS_raw = GCU_BATTERY_DATA_TX_GCU_Battery_voltage(:, 2)/10; % [V]
                obj.t_rpm_MCU_raw = MCU_DATAS_TX_MCU_Speed(:, 1); % [s]
                obj.rpm_MCU_raw = MCU_DATAS_TX_MCU_Speed(:, 2); % [rpm]
                obj.t_perc_MCU_ref_raw = MCU_INPUTS_RX_MCU_Throttle_value(:, 1); % [s]
                obj.perc_MCU_ref_raw = MCU_INPUTS_RX_MCU_Throttle_value(:, 2); % [%]
                obj.t_debug1_raw = E103_DEBUG_E103_debug_1(:, 1); 
                obj.debug1_raw = E103_DEBUG_E103_debug_1(:, 2);
            catch
            end
            
            obj.meandt = mean(diff(obj.t_rpm_GCU_raw));
        end
        
        function [result] = extract(obj, dt, t0, t1)
            if t0 == -Inf
                t0 = obj.t_rpm_GCU_raw(1);
            end
            
            if t1 == Inf
                t1 = obj.t_rpm_GCU_raw(end);
            end
            
            t = t0:dt:t1;
            result.t = t;
            
            try
                result.rpm_GCU = interp1(obj.t_rpm_GCU_raw, obj.rpm_GCU_raw, t); % [rpm]
                result.I_GCU = interp1(obj.t_I_GCU_raw, obj.I_GCU_raw, t); % [A]
                result.PWM_GCU = interp1(obj.t_PWM_GCU_raw, obj.PWM_GCU_raw, t); % [PWM]
                result.PWM_GCU_ref = interp1(obj.t_PWM_GCU_ref_raw, obj.PWM_GCU_ref_raw, t); % [PWM]
                result.V_GCU = interp1(obj.t_V_GCU_raw, obj.V_GCU_raw, t); % [V] ?
                result.V_BMS = interp1(obj.t_V_BMS_raw, obj.V_BMS_raw, t); % [V] ?
                result.rpm_MCU = interp1(obj.t_rpm_MCU_raw, obj.rpm_MCU_raw, t); % [rpm]
                result.perc_MCU_ref = interp1(obj.t_perc_MCU_ref_raw, obj.perc_MCU_ref_raw, t); % [%]
                result.debug1 = interp1(obj.t_debug1_raw, obj.debug1_raw, t);
            catch
                
            end
        end
    end
end

