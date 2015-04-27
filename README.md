# xfigure - v1.4
Extended figure with additional interactive mouse controls.

[![xfigure demo](https://github.com/cenmir/xfigure/raw/master/XfigureDemo.gif)](https://www.youtube.com/watch?v=fAuVkC5DVEo)


### News:
- 1.4 Added GKPF. Graphical Key Press Function. Ammends the default keypress with user defined keys. Use GKPF to add own hotkeys. Keep GKPF.m inside your project files.

## Features
**Mouse features**

- CTRL + click to rotate. Useful for any 3d Visualization
- CTRL + scroll to zoom in and out
- Middle mouse + drag to pan

----------
**Keyboard Hotkeys**

- G - to toggle Grid
- CTRL+R to reset axis (beta)
- Shift+S to snap the view.
- Shift+P to save the current position and size of the figure window. Next time it loads, the figure with the same number will automatically assume the saved figure position.

## Installation
Put *xfigure.m* and *xfigure_KPF.m* somewhere on your matlab path.
Use GKPF as a template in each project where you want to override keypresses. 

## GKPF
**Usage** (Matlab 2014b)

	[h1.fig,xf1] = xfigure;
    h1.patch = patch(....);
	h1.quiver = quiver3(...);
	h1.light(1) = light;
	h1.fig.KeyPressFcn = {@GKPF,xf1,h1};

