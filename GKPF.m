function GKPF(src,evnt,xfigure_This,h)
%GKPF(src,evnt,xfigure_This,h)
%   h is a struct that contains user defined graphical handles to be used
%   in this function.
%   xfigure_This is a handle to xfigure, returned by xfigure.
%   Usage:
%   [h, xf] = xfigure()
%   h.KeyPressFcn = {@GKPF,xf,h};

    %% Do not touch
    %Leave this be, we need the standard keypress function!
    xfigure_KPF(src, evnt, xfigure_This); %Do not touch
    
    %% Add own keys below
    if strcmpi(evnt.Character,'h')
        disp('e - Toggle edge on or off')
        disp('l - Toggle light on or off')
        disp('s - Toggle smoothness on or off')
        disp('Use numpad keys to rotate.')
    end
    
    if strcmpi(evnt.Character,'e')
        if strcmpi(h.patch.EdgeColor, 'none')
            h.patch.EdgeColor = 'k';
        else
            h.patch.EdgeColor = 'none';
        end
    end
    
    if strcmpi(evnt.Character,'l')
        for ilight = h.light
            if strcmpi(ilight.Visible,'on')
                ilight.Visible = 'off';
            else
                ilight.Visible = 'on';
            end
        end
    end
    
    if strcmpi(evnt.Character,'q')
        if isfield(h,'quiver')
            if strcmpi(h.quiver.Visible,'on')
                h.quiver.Visible = 'off';
            else
                h.quiver.Visible = 'on';
            end
        end
    end
    
    if strcmpi(evnt.Character,'s')
        if strcmpi(h.patch.FaceLighting,'gouraud')
            h.patch.FaceLighting = 'flat';
        else
            h.patch.FaceLighting = 'gouraud';
        end
    end
    
    
    if strcmpi(evnt.Key,'numpad4')
       [az,el] = view();
       az = az+5;
       view(az,el)
       set(xfigure_This.uistatusText, 'String', ['Az: ',num2str(az), ' El: ', num2str(el) ])
    end
    if strcmpi(evnt.Key,'numpad6')
       [az,el] = view();
       az = az-5;
       view(az,el)
       set(xfigure_This.uistatusText, 'String', ['Az: ',num2str(az), ' El: ', num2str(el) ])
    end
    if strcmpi(evnt.Key,'numpad8')
       [az,el] = view();
       el = el-5;
       view(az,el)
       set(xfigure_This.uistatusText, 'String', ['Az: ',num2str(az), ' El: ', num2str(el) ])
    end
    if strcmpi(evnt.Key,'numpad2')
       [az,el] = view();
       el = el+5;
       view(az,el)
       set(xfigure_This.uistatusText, 'String', ['Az: ',num2str(az), ' El: ', num2str(el) ])
    end
    if strcmpi(evnt.Key,'numpad5')
        [az,el] = view();
        v = [az,el];
        roundTargets = [-360 -270 -180 -90 0 90 180 270 360];
        vRounded = interp1(roundTargets,roundTargets,v,'nearest');
        az = vRounded(1);
        el = vRounded(2);
        view([az, el]);
        set(xfigure_This.uistatusText, 'String', ['Az: ',num2str(az), ' El: ', num2str(el) ])
    end
    
end

