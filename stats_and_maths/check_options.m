function varargout = check_options(varargin,optionList,defaultList)
% this function prepare optional variables for a parent function
%
%   - inputs: 
%       varargin: optional variables specified with this structure
%                {'optionName1',optionValue1,'optionName2',optionValue2,...etc }
%       optionList: cell array of option names
%       defaultList: cell array of option default values
%   - outputs:
%       varargout: optional variables with default values affected if
%       unspecified before


% ex: [flag,varname] = check_options({'flag','varname'},{0,'x'})

% defaults
for i=1:numel(optionList)
   eval([ optionList{i}  ' =  defaultList{i};' ]);
end

% check varargin
for i=1:numel(varargin)
   if ischar(varargin{i})
       [ok,j] = ismember(varargin{i},optionList);
       if ok
           eval([ optionList{j}  ' =  varargin{i+1};' ]);
       end
   end
end

% output
for i=1:numel(optionList)
   eval([ 'varargout{i}  = '  optionList{i} ';' ]);
end    


end