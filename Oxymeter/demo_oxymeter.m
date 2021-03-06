%% demo_oxymeter
% this script demonstrate how to use contec pulse oxymeter recording
% functions
%
% requirements:
%   MATLAB
%   PsychoToolbppg: http://psychtoolbppg.org/HomePage
%   Virtual Com Port emulator: http://www.silabs.com/products/mcu/Pages/USBtoUARTBridgeVCPDrivers.aspx
%   oxymeter library 
%
%
% Nicolas Borderies- February 2017

%% initalize
%---------------------------
clear all; close all;
clc;

% find emulated serial-to-usb port
% valid 'portname' depends on the machine and the platform you are using,
% try manually to find the one that match (check device manager, COM PORT)
if ispc
    portname = 'COM3' ; %  common names: 'COM1','COM2','COM3'
elseif ismac
    portname = '/dev/cu.usbserial-FT3Z95V5' ; %  common names: '/dev/cu.usbserial-FT3Z95V5'
elseif isunix
    portname = '/dev/ttyUSB0' ; % common names: '/dev/ttyUSB0','/dev/ttyS0'
end

% start connection
IOPort('CloseAll'); % reset usb port communication
global port ; port = portname;
ReadOxymeter('connect'); % open new connection with the device

% reset real-time data buffer 
purgedone=0;
while purgedone==0
    ret = ReadOxymeter('livedata');
    purgedone=isempty(ret);
end

% start recording
% ---------------------------
% recording parameters
Tmax = 60; % sec
dt = 0.02; % display refresh duration
stop=0;
tic;
% display parameters
figure; hold on; 
ax=gca;
xlim([0 10]);
ylim([0 100]);
nsample = 500;
time = nan(Tmax*60,1); % time (sec)
ppg = nan(Tmax*60,1); % photoplethysmographic signal (au.)
beat = nan(Tmax*60,1); % heart-beat flag (1/0) % inacurate estimates by the device
hr = nan(Tmax*60,1); % heart-rate (bpm)        % inacurate estimates by the device
spO2 = nan(Tmax*60,1); % oxygen saturation (%)

% time loop
i=0; pause(1); htext=[];stext=[];
while stop==0
    pause(dt); 
    
    ret = ReadOxymeter('livedata'); % record
    
    ns=size(ret,1);
    time(i+1:i+ns) = ret(:,12);
    ppg(i+1:i+ns) = ret(:,5);
    beat(i+1:i+ns) = ret(:,4);
    hr(i+1:i+ns) = ret(:,10);
    spO2(i+1:i+ns) = ret(:,11);

    i=i+ns;
    t=toc;
    
    %display
    if beat(i)==1
        col='r.';
    else
        col='b.';
    end
%     plot(time(i),ppg(i),'b.','LineWidth',2); 
    samples = [max(1,i-nsample+1):i];
    plot(time(samples),ppg(samples),'b','LineWidth',2); 
    tlim = [time(samples(1)) time(samples(end))];
    set(ax,'XLim',tlim); 
    
    % text annotation
    xpos = 0.7*(tlim(2)-tlim(1)) + tlim(1);
    hrtext = ['HR = ' num2str(hr(i)) ' bpm'];
    delete(htext);
    htext = text(xpos,80,hrtext,'FontSize',20,'Color','r');
    
    signaltext = ['signal quality = ' num2str(8-ret(end,1)) '/8'];  % signal quality: should be >= 4/8 (arbitrary threshold)
    delete(stext);
    stext = text(xpos,60,signaltext,'FontSize',20,'Color','r');
    
    if ret(end,2)==1 || ret(end,3)==1 % signal loss warnings (or your subject is about to have respiratory failure)
        signaltext = ['signal lost!'];
        delete(stext);
        stext = text(xpos,60,signaltext,'FontSize',20,'Color','r');
    end
    
    % exit loop
    [keyisdown] = KbCheck;
    if keyisdown 
        break
    end

end

% summary display
plot(time,ppg,'b-','LineWidth',1); % ppg waveform
plot(time(beat==1),ppg(beat==1),'r.','MarkerSize',20);  % rough beat detection




% stop recording
% ---------------------------
ReadOxymeter('close');
