function [] = set_all_properties(varargin)

for i=1:nargin
    if ischar(varargin{i}) && i~=nargin
        name = varargin{i};
        value = varargin{i+1};
        ob = findobj('-property',name);
        if  ~isempty(ob)
            for iO = 1:numel(ob)
                ob(iO).(name) = value;
            end
        end
    end
end

end