function [ret] = ReadOxymeter(command)
%
% Attempting to talk to the contec.com.cn CMS60C Pulse Oximeter over USB.
% Caspar Addyman Oct 2011
%
% CMS60C Communication Protocol in the pdf file in this folder.
% ./Communication protocol of pulse oximeter V7.0.pdf
%
% Note: You must first have installed the SiLabs
% USB to UART Bridge Virtual Comm Port (VCP) Drivers
%
% http://www.silabs.com/products/mcu/Pages/USBtoUARTBridgeVCPDrivers.aspx
%
% and PsychoToolBox in order to use the IOPORT function
%  
% http://psychtoolbox.org/HomePage
% http://docs.psychtoolbox.org/IOPort
%
% v0.1  - alpha version - just about works (8/11/2011) 

global ioPortOpen;
global monitorIO;
global PCtoMonitorBytes;
global port;
global lastPacketTime;

%     port='/dev/cu.SLAB_USBtoUART';
%     port='COM3';

    if (nargin < 1)
        command = 'livedata';
    end
    
    timestamp=NaN;

    switch lower (command)
        
        case 'connect'
            ret = connect();
        case 'livedata'
            [ret] = livedata();
        case 'flush'
            %clear queued data
            %not implemented yet
        case 'close'
            close();
        otherwise
            connect();
            ret = livedata();       
    end
end

function stayconnected()
%need to send stillconnected command at least once every 5 seconds
%can send it more often  
    
global lastConnected    
global ioPortOpen
global monitorIO

    if isempty(ioPortOpen) || isempty(lastConnected)
        disp('stay connected - reconnect');
        connect();
    end
    
    if toc(lastConnected) < now - 3
        disp('already connected ');
        %inform device we are connected 
%         [cmdstr cmdarray] = CMS60CInputCommand('connected');
%         [nwritten, when, errmsg, prewritetime, postwritetime, lastchecktime] = IOPort('Write', monitorIO, cmdarray);
        lastConnected = tic;
    end
end

% function [ret timestamp] = livedata()    
function [ret] = livedata()    
% return livedata (this can build up in queue if request not made often enough)

global ioPortOpen
global monitorIO
global lastPacket
global lastConnected
global lastCheckTime
global lastPacketTime

    timestamp = toc(lastConnected);
    % TODO : get time form device
    
    data = [lastPacket IOPort('Read', monitorIO)];    

    ALLPULSEDATA = [];
    ALLTIMEDATA = [];
    lastPacketTime_temp=[];
    NData = length(data);
    datablockindices = find(data>=128);
    NBlocks = length(datablockindices);
    for j = 1:NBlocks
        % DATA:5 bytes in 1 package, ~60 packages/second
        if datablockindices(j)+4 < NData
            packet = data(datablockindices(j):datablockindices(j)+4);
            [PulseObj, PulseArray] = CMS60CRealTimeDataDecode(packet);
            
            if j==1 & ~isempty(lastPacketTime)
                TimeBlock = lastPacketTime;
            else
                TimeBlock = lastCheckTime + [datablockindices(j)/NData]*(timestamp-lastCheckTime);
            end
            
            ALLPULSEDATA = [ ALLPULSEDATA ; PulseArray];
            ALLTIMEDATA  = [ ALLTIMEDATA ; TimeBlock];
            
        else
            lastPacket = data(datablockindices(j):end);
            lastPacketTime_temp =lastCheckTime + [datablockindices(j)/NData]*(timestamp-lastCheckTime);
            
        end
    end
%     ret = ALLPULSEDATA;
    
%     ret = [ALLPULSEDATA , [lastPacketTime ; ALLTIMEDATA]];
    ret = [ALLPULSEDATA , [ ALLTIMEDATA]];
    lastCheckTime=timestamp;
    lastPacketTime=lastPacketTime_temp;
    
end

% 
% for n = 1:120
%     WaitSecs(1/60);
%     if mod(n,60) == 0
%         [nwritten, when, errmsg, prewritetime, postwritetime, lastchecktime] = IOPort('Write', monitorIO, StillConnected, blocking);
%     end
%     navailable = IOPort('BytesAvailable', monitorIO);
%     [data, when, errmsg] = IOPort('Read', monitorIO);    
%     NData = length(data);
%     datablockindices = find(data==1);
%     NBlocks = length(datablockindices);
% 
%     % DATA:8 bytes in 1 package, ~60 packages/second
%     
% 
%     for j = 1:NBlocks
%         if datablockindices(j)+8 <= NData
%             packet = data(datablockindices(j)+1:datablockindices(j)+8);
%             [PulseObj PulseArray] = CMS60CRealTimeDataDecode(packet);
%             ALLPULSEDATA = [ ALLPULSEDATA ; PulseArray];
%         end
%     end
% end
% 
% 
% ret = ALLPULSEDATA;
%



function ret = connect()

global ioPortOpen
global monitorIO
global lastConnected
global port
global lastCheckTime


try
%     IOPort('CloseAll');
    disp(['**** connecting to CMS60C Heart Rate monitor *****']);
    disp(['**** on port  -  ' port  '      ****']);

    
    % Data Format: 1 Start bit + 8 data bits + 1 stop bit, odd;
% NOTE DIFFERENT CMS Models use different baud rates you may have to edit the following lines
 %   % Baud Rate: 19200  (CMS50D)
   configString = 'ReceiverEnable=1 BaudRate=19200 StartBits=1 DataBits=8 StopBits=1 Parity=No OutputBufferSize=2048 InputBufferSize=1024 RTS=0 DTR=1';
    % Baud Rate: 115200  (CMS60C)
%     configString = 'ReceiverEnable=1 BaudRate=115200 StartBits=1 DataBits=8 StopBits=1 Parity=No OutputBufferSize=512 InputBufferSize=1024 RTS=0 DTR=1';
    [monitorIO, errmsg] = IOPort('OpenSerialPort', port, configString);
    if monitorIO < 0
         error('Error-connecting to heartrate monitor over virtual comm port -- not found...this feature will be disabled');
    end


    IOPort('Flush', monitorIO); %flush data queued to send to device 
    IOPort('Purge', monitorIO); %clear existing data queues.
    while ~isempty(IOPort('Read', monitorIO)), end

    %the second sequence command codes sent by the PC software in byte 3
    %these are sent indiviually and a response read for each one
%    Command{1} = 'stopstore'; % stop sending stored data
%    Command{2} = 'stopreal'; % stop sending real time data
%    Command{3} = 'storeid'; % ask for storage indentifiers
%    Command{4} = 'realtimepi'; % ask for for PI realtime support
%    Command{5} = 'devid'; % ask for device identifiers
%    Command{6} = 'realtime'; % ask for real time data

    
%         Command(1) = uint8(hex2dec('A7')); % stop sending stored data
%     Command(2) = uint8(hex2dec('A2')); % stop sending real time data
%     Command(3) = uint8(hex2dec('A0')); %
%     Command(4) = uint8(hex2dec('B0')); % ask for storage indentifiers
%     Command(5) = uint8(hex2dec('AC')); % ask for storage indentifiers
%     Command(6) = uint8(hex2dec('B3')); % unknown
%     Command(7) = uint8(hex2dec('A8')); % unknown
%     Command(8) = uint8(hex2dec('AA')); % ask for device identifiers
%     Command(9) = uint8(hex2dec('A9')); % unknown
%     Command(10) = uint8(hex2dec('A1')); % ask for real time data

    %send these commands individually
%     for i  = 6
%         [cmdstr cmdarray] = CMS60CInputCommand(Command{i});
%         disp(['*** startup command: ' cmdstr]);
% %         [nwritten, when, errmsg, prewritetime, postwritetime, lastchecktime] = IOPort('Write', monitorIO, cmdarray);
%         WaitSecs(0.05);
%         navailable = IOPort('BytesAvailable', monitorIO);
%         [data, when, errmsg] = IOPort('Read', monitorIO);
%         disp(['returns ' num2str(data)]);
%     end
    ioPortOpen = true;
    lastConnected = tic;
    lastCheckTime=toc(lastConnected);
    ret = true;
    
catch exception
    disp(exception.message);
    ioPortOpen = [];
    lastConnected = false;%uint64(0);
    IOPort('CloseAll');
    ret = false;
end
end

function close()
    IOPort('CloseAll');
end
