function wordreport_demo
% wordreport_demo: report generation including Simulink and Statflow screenshots
% usage: wordreport_demo
%
% WORDREPORT_DEMO works on 'fuelsys.mdl', a model provided in the 'Examples'
% section of the Statefow documentation. It has been renamed (so as to
% not shadow the existing file) and included in the zip file . The demo
% makes its way through the diagram and take screenshots of every standard
% subsystems and stateflow charts, including each in a dedicated section
% of the report named accordingly.
%
% Author: Laurent Vaylet
% E-mail: laurent.vaylet@gmail.com
% Release: 1.0
% Release date: 16/10/07

% Define model name and verify existence
modelName = 'fuelsys_demo.mdl'
if ~exist(modelName, 'file')
    error(['Model ''' modelName ''' does not exist.']);
end

% Create a new report in current directory, discarding any existing content
reportFilename = 'demo.doc';
if exist(reportFilename, 'file')
    delete(reportFilename);
end
wr = wordreport(fullfile(pwd, reportFilename));

% Define generic name for heading styles ('Heading 1', 'Heading 2', ...)
% If you are NOT using an English version of Word, put here the generic
% name for your language ('Titre ' in french for example)
% This generic name is replaced with the english one if the first attempt
% to add a title goes wrong
headingString = 'Titre ';
try
    % Set style to 'Heading 1' for top level titles
    wr.setstyle([headingString '1']);
    % Define title
    textString = 'Report generation demo';
    % Insert title in the document
    wr.addtext(textString, [0 2]); % two line breaks after text
catch
    % Error when trying to insert first heading. The generic name for
    % heading styles must be wrong, problably due to Microsoft Office
    % language. Resetting to default: ENGLISH (see above for more details)
    warning('Resetting generic name for heading styles to default ''Heading ''');
    headingString = 'Heading ';
    wr.setstyle([headingString '1']);
    textString = 'Report generation demo';
    wr.addtext(textString, [0 2]); % two line breaks after text
end

% Create a table of contents
wr.createtoc();

% Open Simulink/Stateflow model
open_system(modelName);

% Retrieve handles of all standard and non-masked subsystems (standard
% meaning non-Stateflow, as they are processed separately)
hdlStdSubs = find_system(bdroot, 'BlockType', 'SubSystem', 'Mask', 'off');
namesStdSubs = get_param(hdlStdSubs, 'Name');
% Retrieve handles of all Stateflow charts
hdlSf = find_system(bdroot, 'BlockType', 'SubSystem', 'MaskDescription', 'Stateflow diagram');
namesSf = get_param(hdlSf, 'Name');

% Take a screenshot of each standard subsystem and add it to the report
% under a section whose heading is block name
for k = 1:numel(hdlStdSubs)
    wr.setstyle([headingString '2']);
    wr.addtext(namesStdSubs{k});
    % Open subsystem, take screenshot and add it to the document
    open_system(hdlStdSubs{k});
    wr.addmodel(hdlStdSubs{k});
end

% Take a screenshot of each Stateflow chart and add it to the report
% under a section whose heading is chart name
for k = 1:numel(hdlSf)

    % Take a screenshot of top level chart
    wr.setstyle([headingString '2']);
    wr.addtext(namesSf{k});
    open_system(hdlSf{k});
    wr.addstateflow(hdlSf{k});

    % Look for subcharts
    rt = sfroot; % root diagram
    hdlSubcharts = rt.find('IsSubchart', true);
    namesSubcharts = get(hdlSubcharts, 'Name'); % Names only
    pathsSubcharts = get(hdlSubcharts, 'Path'); % Full paths
    for m = 1:numel(hdlSubcharts)
        wr.setstyle([headingString '3']);
        wr.addtext(namesSubcharts{m});
        open_system(pathsSubcharts{m});
        wr.addstateflow(get(hdlSubcharts(m), 'Id'));
    end

    % Close all open Stateflow charts
    sfclose all;
end

% Close model
close_system(modelName);

% Update table of contents
wr.updatetoc();
% Save and close
wr.close();

% Open the newly generated report ?
dlgString = 'The report has been successfully generated. Do you want to open it ?';
dlgTitle = 'Open the report ?';
answer = questdlg(dlgString, dlgTitle, 'Yes', 'No', 'Yes');
if strcmp(answer, 'Yes')
    open(reportFilename);
end
