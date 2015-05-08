function [h, this] = xfigure(varargin)
% xfigure
% xfigure(fignumber)
% xfigure(id) where id is a string e.g. xfigure('Mesh')
% h = xfigure(...)
% [h, xfigure_This] = xfigure(...)
%
%
% Press "G" to toggle grid
% Press "CTRL+R" to reset axis
% Press "Middlemousebuton and drag" to pan axis
% Press "CTRL+Click and drag" to rotate axis
% Press "SHIFT+S" snap the view to the view-box
% Press "SHIFT+P" to save the current window position
%
% Version 1.4, created by Mirza Cenanovic

%% Initiate
% global xfigure_This

xfigure_This.blankWindow = 0;
figureIDIsProvided = 0;
if nargin >= 1
    param1 = varargin{1};
    if isa(param1,'char')
        fighand = strToHandleID(param1);
        figureIDIsProvided = 1;
        if ishandle(fighand)
            figure(fighand)
            h = fighand; this = h;
            return
        end
    elseif isa(param1,'numeric')
        fighand = param1;
        if ishandle(fighand)
            figure(fighand)
            h = fighand; this = h;
            return
        end
    end
    
    xfigure_This.gui = figure(fighand);
    h = xfigure_This.gui;
    
    if nargin > 1
        varargin = varargin(2:end);
    end
else
    xfigure_This.gui = figure;
    xfigure_This.blankWindow = 1;
    h = xfigure_This.gui;
end


%% Figure properties
xfigure_This.bcolor = get(xfigure_This.gui,'Color');
if figureIDIsProvided > 0
    if verLessThan('matlab','8.4')
        set(xfigure_This.gui,'Tag',param1)
    else
        xfigure_This.gui.Tag = param1;
    end
else
    if verLessThan('matlab','8.4')
        set(xfigure_This.gui,'Tag',num2str(h))
    else
        xfigure_This.gui.Tag = num2str(h.Number);
    end
end
set(xfigure_This.gui,'ToolBar','figure')
if isenabled('Title', varargin)
    set(xfigure_This.gui, 'Name', getoption('Title', varargin))
elseif figureIDIsProvided > 0
    set(xfigure_This.gui, 'Name', param1)
end



%% Figure position
xfigure_This.filename = ['XFig',get(xfigure_This.gui,'Tag'),'Data.mat'];
if exist(xfigure_This.filename,'file') == 2
    S = load(xfigure_This.filename);
    if isfield(S,'WindowPosition')
        set(xfigure_This.gui, 'Position', S.WindowPosition)
    end
    if isfield(S,'View')
       xfigure_This.view = S.View;
    end
end
xfigure_This.WindowPosition = get(xfigure_This.gui, 'Position');


%% Axes
xfigure_This.axes = axes;
xfigure_This.axis = axis;

%% View
view(xfigure_This.view(1),xfigure_This.view(2))


%% Help text
xfigure_This.helpText = {'Press "G" to toggle grid'...
    'Press "CTRL+R" to reset axis'...
    'Press "Middlemousebuton and drag" to pan axis'...
    'Press "CTRL+Click and drag" to rotate axis'...
    'Press "SHIFT+S" snap the view to the view-box'...
    'Press "SHIFT+P" to save the current window position'};
xfigure_This.uiTextHelp = uicontrol('style','text','string',xfigure_This.helpText,'HorizontalAlignment','Left',...
    'Position', [5,5,500,64],'Visible','off','BackgroundColor','w');
ext1 = get(xfigure_This.uiTextHelp,'Extent');
set(xfigure_This.uiTextHelp,'Position',[5,20,ext1(3),ext1(4)])

%% Status text
xfigure_This.statusText = ' ';
% xfigure_This.uistatusText = uicontrol('style','text','string',xfigure_This.statusText,'HorizontalAlignment','Left',...
%     'Position', [7,5,20,20],'Visible','on');
xfigure_This.StatusBox = annotation('textbox', 'string', xfigure_This.statusText,'HorizontalAlignment','Left',...
    'Units','pixels','Position', [7,5,20,20],'LineStyle','none','Visible','on');
% set(xfigure_This.uistatusText,'BackgroundColor','w')
xfigure_This.statusTextWidth = xfigure_This.WindowPosition(3)-2*5;
xfigure_This.statusTextHeight = 15;
set(xfigure_This.StatusBox,'Position',[5, 5, xfigure_This.statusTextWidth, xfigure_This.statusTextHeight])


%% Axis properties
set(xfigure_This.axes, 'Units', 'pixels');
set(xfigure_This.axes, 'TickDir','out');
% set(xfigure_This.axes,'XColor', xfigure_This.bcolor,'YColor', xfigure_This.bcolor,'ZColor', xfigure_This.bcolor)

xfigure_This.axesMarginSides = 60; %pixels
xfigure_This.axesMarginTop = 40;
xfigure_This.axesMarginBottom = xfigure_This.statusTextHeight + xfigure_This.axesMarginSides;

xfigure_This.axesWidth = xfigure_This.WindowPosition(3)-xfigure_This.axesMarginSides*2;
xfigure_This.axesHeight = xfigure_This.WindowPosition(4) - xfigure_This.axesMarginBottom - xfigure_This.axesMarginTop;

set(xfigure_This.axes,'Position', [xfigure_This.axesMarginSides, xfigure_This.axesMarginBottom, xfigure_This.axesWidth,xfigure_This.axesHeight])


% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% title('Hello')

%
%% Properties
xfigure_This.rotate3d = 0;
xfigure_This.hrot = 0;
xfigure_This.grid = 0;
xfigure_This.CameraViewAngleDefault = get(xfigure_This.axes,'CameraViewAngle');
xfigure_This.CameraViewAngle = xfigure_This.CameraViewAngleDefault;
xfigure_This.ZoomLevel = xfigure_This.CameraViewAngleDefault;
xfigure_This.CameraDefaultPosition = get(xfigure_This.axes,'CameraPosition');
xfigure_This.CameraTarget = get(xfigure_This.axes,'CameraTarget');


%% Original figure state
xfigure_This.axO = xfigure_This.axis;
[xfigure_This.azO,xfigure_This.elO] = view;
xfigure_This.axesPosO = get(xfigure_This.axes,'Position');

try
    xfigure_This.PanStart = get(gca,'Position');
    xfigure_This.PanStartX = xfigure_This.PanStart(1);
    xfigure_This.PanStartY = xfigure_This.PanStart(2);
catch
    xfigure_This.PanStartX = 0;
    xfigure_This.PanStartY = 0;
end

%% Listeners
set(xfigure_This.gui, 'KeyPressFcn',{@xfigure_KPF,xfigure_This})
set(xfigure_This.gui, 'WindowScrollWheelFcn',@ScrollFcn)
set(xfigure_This.gui, 'WindowButtonDownFcn',@buttonDownFcn)
set(xfigure_This.gui, 'WindowButtonUpFcn',@buttonUpFcn)
set(xfigure_This.gui, 'ResizeFcn', @ResizeFcn)
% set(xfigure_This.gui, 'CloseRequestFcn',@mainCloseReq)
this = xfigure_This;
    
%% CallBackFunctions
    



%% CallBackFunctions

    function buttonDownFcn(varargin)
        modifier = get(gcf,'currentModifier');
        if isempty(modifier)
            modifier = 0;
        end
        selection = get(gcf,'SelectionType');
        
        %% Middlemouse
        if strcmpi(selection,'extend')
            
            xfigure_This.panSensitivity = 1;
            
            set(gcf,'Pointer','fleur')
            set(gcf,'WindowButtonMotionFcn', @PanWindowButtonFcn)
           
            crd = get(gcf, 'CurrentPoint');
            x = crd(1);
            y = crd(2);
            
            xfigure_This.xstartPos = x;
            xfigure_This.ystartPos = y;
        end
        
        %% CTRL + Middlemouse = rotate
        if (strcmpi(selection,'alt') || strcmpi(selection,'open')) && strcmp(modifier,'control')
            xfigure_This.rotateSensitivity = 0.5;
            
            set(xfigure_This.gui,'Pointer','circle')
            set(xfigure_This.gui,'WindowButtonMotionFcn', @RotateWindowButtonFcn)
            
            crd = get(xfigure_This.gui, 'CurrentPoint');
            
            x = crd(1);
            y = crd(2);
            xfigure_This.xs = x;
            xfigure_This.ys = y;
            [xfigure_This.az,xfigure_This.el] = view;
            try
                set(xfigure_This.StatusBox, 'String', ['Az: ',num2str(xfigure_This.az), ' El: ', num2str(xfigure_This.el) ])
            catch
%                 disp(['Az: ',num2str(xfigure_This.az), ' El: ', num2str(xfigure_This.el) ])
            end
        end      
    end

    function buttonUpFcn(varargin)
        set(xfigure_This.gui,'WindowButtonMotionFcn','');
        set(xfigure_This.gui,'Pointer','arrow')
        try
            set(xfigure_This.StatusBox, 'String', [' '])
        end
        
    end
    
    function PanWindowButtonFcn(varargin)

        
        %% Old
        crd = get(gcf, 'CurrentPoint');
        x = crd(1);
        y = crd(2);
        dx = -(xfigure_This.xstartPos - x);
        dy = -(xfigure_This.ystartPos - y);
        xfigure_This.xstartPos = x;
        xfigure_This.ystartPos = y;
        
        
        Pos = get(gca,'Position');
        
        Pos = Pos + xfigure_This.panSensitivity * [dx,dy,0,0];
        
        set(gca,'Position', Pos)
        %% New
%         crd = get(xfigure_This.gui, 'CurrentPoint');
%         x = crd(1); y = crd(2);
%         dx = -(xfigure_This.xstartPos - x)
%         dy = -(xfigure_This.ystartPos - y)
%         xfigure_This.xstartPos = x;
%         xfigure_This.ystartPos = y;
%         camdolly(-dx/100,-dy/100,0,'movetarget','camera')
%         
%         xfigure_This.CameraPosition
        
    end

    function RotateWindowButtonFcn(varargin)        
        crd = get(xfigure_This.gui, 'CurrentPoint');
        x = crd(1);
        y = crd(2);
        dx = (xfigure_This.xs - x);
        dy = (xfigure_This.ys - y);
        xfigure_This.xs = x;
        xfigure_This.ys = y;
        
%         daz = sign(dx);
%         del = sign(dy);

        daz = dx;
        del = dy;

        %         [daz,del]*xfigure_This.rotateSensitivity;
        xfigure_This.az = xfigure_This.az + round(daz * xfigure_This.rotateSensitivity);
        xfigure_This.el = xfigure_This.el + round(del * xfigure_This.rotateSensitivity);
        
        view(xfigure_This.az,xfigure_This.el)
        
        if xfigure_This.az > 360
            xfigure_This.az = xfigure_This.az - 360;
        end
        if xfigure_This.az < -360
            xfigure_This.az = xfigure_This.az + 360;
        end
        if xfigure_This.el > 360
            xfigure_This.el = xfigure_This.el - 360;
        end
        if xfigure_This.el < -360
            xfigure_This.el = xfigure_This.el + 360;
        end
        try
            set(xfigure_This.StatusBox, 'String', ['Az: ',num2str(xfigure_This.az), ' El: ', num2str(xfigure_This.el) ])
        catch
%             disp(['Az: ',num2str(xfigure_This.az), ' El: ', num2str(xfigure_This.el) ])
        end

    end

    function ScrollFcn(varargin)
        %% Zoom factor:        
        controlIsPressed = 0;
        modifier = get(xfigure_This.gui,'currentModifier');
        if ~isempty(modifier)
            switch modifier{1}
                case 'control'
                    controlIsPressed = 1;
            end
        end
        
        if varargin{2}.VerticalScrollCount < 0 && controlIsPressed
            %Zoom in
            camzoom(1.1)
            
        elseif varargin{2}.VerticalScrollCount > 0 && controlIsPressed
            % zoom out
            camzoom(0.8)
        end
    end

    function ResizeFcn(varargin)
        xfigure_This.WindowPosition = get(xfigure_This.gui,'Position');
        xfigure_This.statusTextWidth = xfigure_This.WindowPosition(3)-2*5;
        try
            set(xfigure_This.StatusBox,'Position',[5, 5, xfigure_This.statusTextWidth, xfigure_This.statusTextHeight])
        end
        xfigure_This.axesWidth = xfigure_This.WindowPosition(3)-xfigure_This.axesMarginSides*2;
        xfigure_This.axesHeight = xfigure_This.WindowPosition(4) - xfigure_This.axesMarginBottom - xfigure_This.axesMarginTop;
        try
            set(xfigure_This.axes,'Position', [xfigure_This.axesMarginSides, xfigure_This.axesMarginBottom, xfigure_This.axesWidth,xfigure_This.axesHeight])
        end
    end


end

% function KeyPressFcn(source,event,xfigure_This)
% xfigure_KPF(source, event, xfigure_This);
% 
% end

function rv = isenabled(mode, varargin)
if nargin < 1
    error('No arguments')
end
varargin = varargin{:};

ind = find(strcmpi(varargin,mode), 1);
if ~isempty(ind)
    rv = 1;
else
    rv = 0;
end
end
function param = getoption(mode, varargin)
varargin = varargin{:};
ind1 = find(strcmpi(varargin,mode), 1);
if ~isempty(ind1)
    %Errorhandling
    if ~iscell(varargin)
        varargin = {varargin};
    end
    if ind1+1 <= length(varargin)
        param = varargin{ind1+1};
    else
        %         error(['No options are followed by the property ''', mode,''' '])
        param = [];
    end
else
    param = [];
end
end

function h = strToHandleID(str)
h = round(norm(double(str)-44,1));
if h > intmax-1
    error('h is exceeding intmax!')
end
end

