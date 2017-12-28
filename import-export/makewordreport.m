function [  ] = makewordreport( filename, reportfolder, showCode )
%% function [  ] = makewordreport( filename, reportfolder, showCode )

    % arguments
    if nargin<2
        reportfolder = [ pwd filesep filename ];
    end
    if nargin<3
        showCode = true;
    end
        
    % publish 
    publish([ filename '.m'],...
            'format','doc',...
            'outputDir',reportfolder,...
            'showCode',showCode);


end

