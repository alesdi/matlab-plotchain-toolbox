function [bounds] = ptPersistentTimeSeriesBounds(t, y, storeName, invalidate)
    %MPERSISTENTPROMPTEDBOUNDS Returns a struct that defines time bounds on a
    % time series plot, given the time 't' and value 'y' vectors. When
    % possible, bounds are loaded from persistent storage.  If the
    % optional argument 'invalidate' is true or if the field does not exist,
    % the user is prompted to select the time bounds on the plot.
    %
    % Optionally, you can specify the persistent storage field key 'storeName'.
    % If you don't, or provide an empty string, the key is computed
    % automatically basing on plot data (identical plots will be assumed to
    % have identical bounds).

    if(~exist('invalidate', 'var'))
        invalidate = false;
    end

    if(~exist('storeName', 'var')||strlength(storeName)==0)
        % If no storeName is provided, it is computed as an hash of the plot
        % data, with  the 'ptPTSB' prefix 
        data = [t y];
        data = typecast(data(:),'uint8');

        md = java.security.MessageDigest.getInstance('SHA-1');
        md.update(data);

        hash = reshape(dec2hex(typecast(md.digest(),'uint8'))',1,[]);

        storeName = strcat('ptPTSB', hash);
    end

    store = ptStore();

    if(invalidate || ~store.hasKey(storeName) || ~isfield(store.get(storeName), 't0') || ~isfield(store.get(storeName), 't1'))
        fig = ptFigure().xLabel('time');

        store = ptStore();
        bounds = store.get(storeName, struct());

        refreshFigure(fig, t, y, store, storeName);
        
        height = 20;
        margin = 10;
        
        p = uipanel(fig.fig, 'Units', 'pixel', 'Position', [margin margin 500, height+2*margin]);
        
        % Start form
        startTitle = uicontrol(p, 'Style', 'text', 'Visible', 'on');
        startTitle.String = 'Start: ';
        startTitle.HorizontalAlignment = 'right';
        startTitle.Position = [margin margin 40 height-4];
        
        startField=uicontrol(p, 'Style','edit','Visible','on');
        if(isfield(bounds, 't0'))
            startField.String = num2str(bounds.t0);
        end
        startField.Callback = @(src, event) editStart(fig, t, y, store, storeName, startField);
        startField.Position = [margin+40 margin+1 80 height-2];
        
        startButton=uicontrol(p, 'Style','pushbutton','Visible','on');
        startButton.String = 'Pick';
        startButton.Callback = @(src, event) pickStart(fig, t, y, store, storeName, startField);
        startButton.Position = [margin+120 margin 40 height];
        
        % End form
        endOffset = 200;
        endTitle = uicontrol(p, 'Style', 'text', 'Visible', 'on');
        endTitle.String = 'End: ';
        endTitle.HorizontalAlignment = 'right';
        endTitle.Position = [endOffset+margin margin 40 height-4];
        
        endField=uicontrol(p, 'Style','edit','Visible','on');
        if(isfield(bounds, 't0'))
            endField.String = num2str(bounds.t1);
        end
        endField.Position = [endOffset+margin+40 margin+1 80 height-2];
        endField.Callback = @(src, event) editEnd(fig, t, y, store, storeName, endField);
        
        endButton=uicontrol(p, 'Style','pushbutton','Visible','on');
        endButton.String = 'Pick';
        endButton.Position = [endOffset+margin+120 margin 40 height];
        endButton.Callback = @(src, event) pickEnd(fig, t, y, store, storeName, endField);
        
        % Submit
        submitButton=uicontrol(p, 'Style','pushbutton','Visible','on');
        submitButton.String = 'Save';
        submitButton.Position = [endOffset*2+margin margin 70 height];
        submitButton.Callback = @(src, event) fig.close();
        
        waitfor(fig.fig);
        bounds = store.get(storeName, struct());
    else
        bounds = store.get(storeName);
    end
end

function editStart(fig, t, y, store, storeName, startLabel)
    bounds = store.get(storeName, struct());
    bounds.t0 = str2double(startLabel.String);
    store.set(storeName, bounds);
    refreshFigure(fig, t, y, store, storeName);
end

function pickStart(fig, t, y, store, storeName, startLabel)
    bounds = store.get(storeName, struct());
    bounds.t0 = fig.promptX();
    startLabel.String = num2str(bounds.t0);
    store.set(storeName, bounds);
    refreshFigure(fig, t, y, store, storeName);
end

function editEnd(fig, t, y, store, storeName, label)
    bounds = store.get(storeName, struct());
    bounds.t1 = str2double(label.String);
    store.set(storeName, bounds);
    refreshFigure(fig, t, y, store, storeName);
end

function pickEnd(fig, t, y, store, storeName, label)
    bounds = store.get(storeName, struct());
    bounds.t1 = fig.promptX();
    label.String = num2str(bounds.t1);
    store.set(storeName, bounds);
    refreshFigure(fig, t, y, store, storeName);
end

function refreshFigure(fig, t, y, store, storeName)
    bounds = store.get(storeName, struct());
    
    axis = gca(fig.fig);
    cla(axis);
    axis.Position = [0.1 0.3 0.8 0.6];
    fig.color('black').plot('', t, y);
    
    if(isfield(bounds, 't0'))
        fig.xLine('$t_0$', bounds.t0, '-', 'grey');
    end
    
    if(isfield(bounds, 't1'))
        fig.xLine('$t_1', bounds.t1, '-', 'grey');
    end
end