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