function enob = calculateENOB(snr)
%---------------------------------------------------------------
% Calculates Effective Number of Bits (ENOB)
%
% Input:
%   snr : Signal-to-Noise Ratio (dB)
%
% Output:
%   enob : Effective Number of Bits
%---------------------------------------------------------------

enob = (snr - 1.76) / 6.02;

end