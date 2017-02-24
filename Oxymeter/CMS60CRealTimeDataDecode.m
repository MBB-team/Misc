function [RealTimeData RealTimeArray] = CMS60CRealTimeDataDecode(DataPackage)
%
% decode the data package sent by the CMS60C
% based on the specfication in the communication protocol v7.0
%
% input is an 8 byte message from the pulse oximeter
% outputs
%  RealTimeData - a matlab data structure
%  RealTimeArray - same data as a matlab array

if length(DataPackage) ~= 5
    RealTimeData.Status = 'DataPackage was not 5 bytes long';
    RealTimeArray  = zeros(11,1);
    return;
end

%Byte 1 
RealTimeData.SignalStrength     = read_bits(DataPackage(1),0,4); % bits 0-3
RealTimeData.SearchTimeOut      = read_bits(DataPackage(1),4,1); % bits 4
RealTimeData.SignalDrop         = read_bits(DataPackage(1),5,1); % bits 5
RealTimeData.BeepFlag           = read_bits(DataPackage(1),6,1); % bits 6

%Byte 2
RealTimeData.WaveForm           = read_bits(DataPackage(2),0,7); % bits 0-6
RealTimeData.SearchingForPulse  = read_bits(DataPackage(2),7,1); % bits 7

%Byte 3 
RealTimeData.BarGraph           = read_bits(DataPackage(3),0,4); % bits 0-3
RealTimeData.ProbeError         = read_bits(DataPackage(3),4,1); % bits 4
RealTimeData.Searching          = read_bits(DataPackage(3),5,1); % bits 5
PulsRateBit7       = read_bits(DataPackage(3),6,1); % bits 6

%Byte 4
PulseRateBits      = read_bits(DataPackage(4),0,7); % bits 0-6
RealTimeData.PulseRate          = PulsRateBit7.*128 + PulseRateBits;

%Byte 5 
RealTimeData.SPO2               = read_bits(DataPackage(5),0,7); % bits 0-6


RealTimeArray = [   RealTimeData.SignalStrength    
                    RealTimeData.SearchTimeOut      
                    RealTimeData.SignalDrop
                    RealTimeData.BeepFlag
                    RealTimeData.WaveForm
                    RealTimeData.SearchingForPulse
                    RealTimeData.BarGraph
                    RealTimeData.ProbeError
                    RealTimeData.Searching
                    RealTimeData.PulseRate
                    RealTimeData.SPO2
                    ]';                   

RealTimeData.decoded = true;
RealTimeData.status = 'Success';

end


function value = read_bits(byte,position,nBits)
%READ_BITS extract a value included in a byte
% Given a byte of information, return the decimal value encoded by the
% nBits bits located to the right of position (inclusive).
%
% value = READ_BITS(byte, position, nBits)

% Align position to the low bit side
shifted = bitshift(byte,-position) ;

% Keep only the bytes of interest
value = bitand(shifted,2^nBits-1);

end