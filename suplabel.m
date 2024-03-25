function varargout = suplabel(varargin)
%SUPLABEL Create title, xlabel, and ylabel for group of axes
%
% [h1, h2, ...] = suplabel(param, val, ...)
%
% This function adds a title, xlabel, and/or ylabel to a group of axes. 
%
% Input variables:
%
%   figure:     handle of figure where axes are located.  This is ignored
%               if specific axes handles are given.  Default is current
%               figure.
%
%   axes:       handles(s) of axes that will be labeled.  If omitted, all
%               visible axes in the specified figure (or current figure if
%               no figure is specified) are used. 
%
%   title:      title string
%   
%   xlabel:     xlabel string
%
%   ylabel:     ylabel string
%
%   buffert:    distance (normalized) between title string and top of axes
%               [0.02].  
%
%   bufferx:    distance (normalized) between xlabel string and bottom of
%               axes [0.05]
%
%   buffery:    distance (normalized) between ylabel string and left of
%               axes [0.05]
%
% Output variables:
%
%   h:          handles to labels added, in order listed in input.  If one
%               extra handle is requested (e.g. listed 2 label types but
%               you ask for 3 output variables), the handle to the axis
%               used to position the labels will be returned as well (this
%               axis is always an invisible axis with normalized position
%               [0 0 1 1]).

% Copyright 2008 Kelly Kearney


%-----------------------------
% Parse inputs
%-----------------------------

p = inputParser;
p.addParameter('figure', gcf);
p.addParameter('axes', []);
p.addParameter('title', '');
p.addParameter('xlabel', '');
p.addParameter('ylabel', '');
p.addParameter('buffert', .02);
p.addParameter('bufferx', .05);
p.addParameter('buffery', .05);
p.parse(varargin{:});

Param = p.Results;

if isempty(Param.axes)
    Param.axes = findobj('Parent', Param.figure, 'Type', 'axes', ...
                         'visible', 'on');
else
    if length(Param.axes) > 1
        parentfig = get(Param.axes, 'Parent');
        parentfig = cat(1, parentfig{:});
        parentfig = unique(parentfig);
        if length(parentfig) > 1
            error('All specified axes must be on the same figure');
        else
            Param.figure = parentfig;
        end
    else
        Param.figure = get(Param.axes, 'Parent');
    end
end

% Figure out order for handle return

param = reshape(varargin, 2, []);
param = param(1,:);
letter1 = cellfun(@(x) x(1), param, 'uni', 0);
[tf, loc] = ismember({'t', 'x', 'y'}, letter1);
[srt, isrt] = sort(loc(tf));
nh = length(find(tf));

error(nargoutchk(0,nh+1,nargout));

if nargout == nh+1
    tf = [tf true];
    isrt = [isrt max(isrt)+1];
else
    tf = [tf false];
end

%-----------------------------
% Get positions of all axes
%-----------------------------

units = get(Param.axes, 'Units');
set(Param.axes, 'Units', 'normalized');

pos = get(Param.axes, 'Position');
if iscell(pos)
    pos = cell2mat(pos);
end

if length(Param.axes) > 1
    for iax = 1:length(Param.axes)
        set(Param.axes(iax), 'units', units{iax});
    end
else
    set(Param.axes, 'units', units);
end

left   = min(pos(:,1));
bottom = min(pos(:,2));
right  = max(pos(:,1) + pos(:,3));
top    = max(pos(:,2) + pos(:,4));

%-----------------------------
% Create labels
%-----------------------------

a = axes('Parent', Param.figure, 'Position', [0 0 1 1], 'Visible', 'off');

tx = (left+right)/2;
ty = top + Param.buffert;
xx = tx;
xy = bottom - Param.bufferx;
yx = left - Param.buffery;
yy = (bottom+top)/2;

% plotflag = 0;
% if plotflag
%     ref1 = gridxy([left right], [top bottom]);
%     ref2 = gridxy([tx xx yx], [xy yy ty]);
%     set(ref1, 'color', 'b');
%     set(ref2, 'color', 'r');
% end

t = text(tx, ty, Param.title, 'vert', 'bottom', 'horiz', 'center', 'Parent', a);
x = text(xx, xy, Param.xlabel, 'vert', 'top', 'horiz', 'center', 'Parent', a);
y = text(yx, yy, Param.ylabel, 'Rotation', 90, 'vert', 'bottom', 'horiz', 'center', 'Parent', a);

%-----------------------------
% Adjust invisible axis so 
% doesn't interfere with
% normal figure behavior
%-----------------------------

% Move invisible axis to bottom

uistack(a, 'bottom');

% Turn off panning and zooming

z = zoom(Param.figure);
setAllowAxesZoom(z, a, false);

%-----------------------------
% Return handles
%-----------------------------

handles = [t x y a];
handles = handles(tf);
handles = handles(isrt);

for iout = 1:nargout
    varargout{iout} = handles(iout);
end




