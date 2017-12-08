function [  ] = makewordreport( filename, reportfolder )

    % arguments
    if nargin<2
        reportfolder = [ pwd filesep filename ];
    end
        
    % publish 
    publish([ filename '.m'],...
            'format','doc',...
            'outputDir',reportfolder)


end

