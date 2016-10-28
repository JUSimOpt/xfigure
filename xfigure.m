function varargout = xfigure(varargin)
%XFIGURE Extended figure function
%
% xfigure
% xfigure(fignumber)
% xfigure(fignumber, 'PropertyName',propertyvalue,...)
% [h, H] = xfigure()
% [h, H] = xfigure(...)
%
% Optional Parameter:
% PropertyName | Default | Description  
% -------------|---------|--------------
% Tag          | ''      |
% Title        | ''      |
% InfoText     | ''      | TextBox with specified text.
%
% Press "G" to toggle grid
% Press "CTRL+R" to reset axis
% Press "Middlemousebuton and drag" to pan axis
% Press "CTRL+Click and drag" to rotate axis
% Press "SHIFT+S" snap the view to the view-box
% Press "SHIFT+P" to save the current window position
%
% Version 1.6, created by Mirza Cenanovic
%
% Changelog:
% Version 1.5 - Uses input parser.
% Version 1.6 - InfoText added

%% Initiate
% global xfigure_This

H.blankWindow = 0;

p = inputParser;
addOptional(p,'fignum',0,@isnumeric);
addParameter(p,'Tag','')
addParameter(p,'Title','')
addParameter(p,'InfoText','')
parse(p,varargin{:});
PR = p.Results;

if PR.fignum == 0
    H.gui = figure;
    H.blankWindow = 1;
    h = H.gui;
else
    H.gui = figure(PR.fignum);
    h = H.gui;
end
H.gui.Color = 'w';

%% Figure properties
H.bcolor = get(H.gui,'Color');

if strcmpi(PR.Tag, '')
    if verLessThan('matlab','8.4')
        set(H.gui,'Tag',num2str(h))
    else
        H.gui.Tag = num2str(h.Number);
    end
else
    if verLessThan('matlab','8.4')
        set(H.gui,'Tag',PR.Tag)
    else
        H.gui.Tag = PR.Tag;
    end
end
set(H.gui,'ToolBar','figure')
H.gui.Name = PR.Title;
% if ~strcmpi(PR.Tag, '')
%     set(H.gui, 'Name', PR.Tag)
% end

%% Axes
if ~ishold
    cla
    H.axes = gca;
else
    H.axes = gca;
end
H.axis = axis;

%% Figure position, view, axis position and camerazoom
H.filename = ['XFig',get(H.gui,'Tag'),'Data.mat'];
if exist(H.filename,'file') == 2
    S = load(H.filename);
    if isfield(S,'WindowPosition')
        set(H.gui, 'Position', S.WindowPosition)
    end
    if isfield(S,'View')
       H.view = S.View;
       view(H.view(1),H.view(2))
    end
    if isfield(S,'CameraZoom')
        set(gca,'CameraViewAngle',S.CameraZoom)
    end
    
    
    
end
H.WindowPosition = get(H.gui, 'Position');

%% View
if isfield(H,'view')
    view(H.view(1),H.view(2))
end


%% Help text
H.helpText = {'Press "G" to toggle grid'...
    'Press "CTRL+R" to reset axis'...
    'Press "Middlemousebuton and drag" to pan axis'...
    'Press "CTRL+Click and drag" to rotate axis'...
    'Press "SHIFT+S" snap the view to the view-box'...
    'Press "SHIFT+P" to save the current window position'};
H.uiTextHelp = uicontrol('style','text','string',H.helpText,'HorizontalAlignment','Left',...
    'Position', [5,5,500,64],'Visible','off','BackgroundColor','w');
ext1 = get(H.uiTextHelp,'Extent');
set(H.uiTextHelp,'Position',[5,20,ext1(3),ext1(4)])

%% Status text
H.statusText = ' ';
% xfigure_This.uistatusText = uicontrol('style','text','string',xfigure_This.statusText,'HorizontalAlignment','Left',...
%     'Position', [7,5,20,20],'Visible','on');
H.StatusBox = annotation('textbox', 'string', H.statusText,'HorizontalAlignment','Left',...
    'Units','pixels','Position', [7,5,20,20],'LineStyle','none','Visible','on');
% set(xfigure_This.uistatusText,'BackgroundColor','w')
H.statusTextWidth = H.WindowPosition(3)-2*5;
H.statusTextHeight = 15;
set(H.StatusBox,'Position',[5, 5, H.statusTextWidth, H.statusTextHeight])

%% InfoText
H.InfoText = annotation('textbox', 'string', '','HorizontalAlignment','Left',...
    'Units','normalized','Position', [0.1, 0.2, 0.1, 0.1], 'LineStyle','-','Visible','off',...
    'BackgroundColor','w','FontName','Times', 'Interpreter', 'latex', 'FitBoxToText', 'on');
if ~strcmpi(PR.InfoText, '')
    set(H.InfoText,'String', PR.InfoText, 'Visible','on');  
end
%% Axis properties
set(H.axes, 'Units', 'pixels');
set(H.axes, 'TickDir','out');
% set(xfigure_This.axes,'XColor', xfigure_This.bcolor,'YColor', xfigure_This.bcolor,'ZColor', xfigure_This.bcolor)

H.axesMarginSides = 60; %pixels
H.axesMarginTop = 40;
H.axesMarginBottom = H.statusTextHeight + H.axesMarginSides;

H.axesWidth = H.WindowPosition(3)-H.axesMarginSides*2;
H.axesHeight = H.WindowPosition(4) - H.axesMarginBottom - H.axesMarginTop;

set(H.axes,'Position', [H.axesMarginSides, H.axesMarginBottom, H.axesWidth,H.axesHeight])

if exist(H.filename,'file') == 2
    S = load(H.filename);
    if isfield(S,'AxisPosition')
        set(gca,'Position',S.AxisPosition)
    end
end

% xlabel('X')
% ylabel('Y')
% zlabel('Z')
% title('Hello')

%
%% Properties
H.rotate3d = 0;
H.hrot = 0;
H.grid = 0;
H.CameraViewAngleDefault = get(H.axes,'CameraViewAngle');
H.CameraViewAngle = H.CameraViewAngleDefault;
H.ZoomLevel = H.CameraViewAngleDefault;
H.CameraDefaultPosition = get(H.axes,'CameraPosition');
H.CameraTarget = get(H.axes,'CameraTarget');


%% Original figure state
H.axO = H.axis;
[H.azO,H.elO] = view;
H.axesPosO = get(H.axes,'Position');

try
    H.PanStart = get(gca,'Position');
    H.PanStartX = H.PanStart(1);
    H.PanStartY = H.PanStart(2);
catch
    H.PanStartX = 0;
    H.PanStartY = 0;
end

%% Listeners
set(H.gui, 'KeyPressFcn',{@xfigure_KPF,H})
set(H.gui, 'WindowScrollWheelFcn',@ScrollFcn)
set(H.gui, 'WindowButtonDownFcn',@buttonDownFcn)
set(H.gui, 'WindowButtonUpFcn',@buttonUpFcn)
set(H.gui, 'ResizeFcn', @ResizeFcn)
% set(xfigure_This.gui, 'CloseRequestFcn',@mainCloseReq)

%% Output
varargout{1} = h;
varargout{2} = h;
if nargout == 0
    varargout = {};
end


%% CallBackFunctions

    function buttonDownFcn(varargin)
        modifier = get(gcf,'currentModifier');
        if isempty(modifier)
            modifier = 0;
        end
        selection = get(gcf,'SelectionType');
        
        %% Middlemouse
        if strcmpi(selection,'extend')
            
            H.panSensitivity = 1;
            
            set(gcf,'Pointer','fleur')
            set(gcf,'WindowButtonMotionFcn', @PanWindowButtonFcn)
           
            crd = get(gcf, 'CurrentPoint');
            x = crd(1);
            y = crd(2);
            
            H.xstartPos = x;
            H.ystartPos = y;
        end
        
        %% CTRL + Middlemouse = rotate
        if (strcmpi(selection,'alt') || strcmpi(selection,'open')) && strcmp(modifier,'control')
            H.rotateSensitivity = 0.5;
            
            set(H.gui,'Pointer','circle')
            set(H.gui,'WindowButtonMotionFcn', @RotateWindowButtonFcn)
            
            crd = get(H.gui, 'CurrentPoint');
            
            x = crd(1);
            y = crd(2);
            H.xs = x;
            H.ys = y;
            [H.az,H.el] = view;
            try
                set(H.StatusBox, 'String', ['Az: ',num2str(H.az), ' El: ', num2str(H.el) ])
            catch
%                 disp(['Az: ',num2str(xfigure_This.az), ' El: ', num2str(xfigure_This.el) ])
            end
        end      
    end

    function buttonUpFcn(varargin)
        set(H.gui,'WindowButtonMotionFcn','');
        set(H.gui,'Pointer','arrow')
        try
            set(H.StatusBox, 'String', [' '])
        end
        
    end
    
    function PanWindowButtonFcn(varargin)

        
        %% Old
        crd = get(gcf, 'CurrentPoint');
        x = crd(1);
        y = crd(2);
        dx = -(H.xstartPos - x);
        dy = -(H.ystartPos - y);
        H.xstartPos = x;
        H.ystartPos = y;
        
        
        Pos = get(gca,'Position');
        
        Pos = Pos + H.panSensitivity * [dx,dy,0,0];
        
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
        crd = get(H.gui, 'CurrentPoint');
        x = crd(1);
        y = crd(2);
        dx = (H.xs - x);
        dy = (H.ys - y);
        H.xs = x;
        H.ys = y;
        
%         daz = sign(dx);
%         del = sign(dy);

        daz = dx;
        del = dy;

        %         [daz,del]*xfigure_This.rotateSensitivity;
        H.az = H.az + round(daz * H.rotateSensitivity);
        H.el = H.el + round(del * H.rotateSensitivity);
        
        view(H.az,H.el)
        
        if H.az > 360
            H.az = H.az - 360;
        end
        if H.az < -360
            H.az = H.az + 360;
        end
        if H.el > 360
            H.el = H.el - 360;
        end
        if H.el < -360
            H.el = H.el + 360;
        end
        try
            set(H.StatusBox, 'String', ['Az: ',num2str(H.az), ' El: ', num2str(H.el) ])
        catch
%             disp(['Az: ',num2str(xfigure_This.az), ' El: ', num2str(xfigure_This.el) ])
        end

    end

    function ScrollFcn(varargin)
        %% Zoom factor:        
        controlIsPressed = 0;
        modifier = get(H.gui,'currentModifier');
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
        H.WindowPosition = get(H.gui,'Position');
        H.statusTextWidth = H.WindowPosition(3)-2*5;
        try
            set(H.StatusBox,'Position',[5, 5, H.statusTextWidth, H.statusTextHeight])
        end
        H.axesWidth = H.WindowPosition(3)-H.axesMarginSides*2;
        H.axesHeight = H.WindowPosition(4) - H.axesMarginBottom - H.axesMarginTop;
        try
            set(H.axes,'Position', [H.axesMarginSides, H.axesMarginBottom, H.axesWidth,H.axesHeight])
        end
    end


end

