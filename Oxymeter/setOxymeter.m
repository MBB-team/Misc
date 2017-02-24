%% setOxymeter
% initialize oxymetric recording


% find emulated serial-to-usb port
% valid 'portname' depends on the machine and the platform you are using,
% try manually to find the one that match
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