function [] = set_all_properties(varargin)
% function [] = set_all_properties(varargin)
% syntax: 
%   set_all_properties('PropertyName',PropertyValue,...)
%       set the listed properties of all the graphic objects in the current workspace  to the
%       specified value
%   set_all_properties(graphicHandle,'PropertyName',PropertyValue,...)
%       set the listed properties of all the children-objects included in the object specified by the handle to the
%       specified value

% detect graphic handle
if ishandle(varargin{1})
    graphicHandle = varargin{1};
else
    graphicHandle = groot;
end

% modify property values
for i=1:nargin
    if ischar(varargin{i}) && i~=nargin
        name = varargin{i};
        value = varargin{i+1};
        ob = findobj(graphicHandle,'-property',name);
        if  ~isempty(ob)
            for iO = 1:numel(ob)
                ob(iO).(name) = value;
            end
        end
    end
end

end