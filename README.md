# xfigure - v1.4
Extended figure with additional interactive mouse controls.

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

## GKPF
**Usage** (Matlab 2014b)

	[h1.fig,xf1] = xfigure;
    h1.patch = patch(....);
	h1.quiver = quiver3(...);
	h1.light(1) = light;
	h1.fig.KeyPressFcn = {@GKPF,xf1,h1};

