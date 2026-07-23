function snr = calculateSNR(signal, Fs)
%---------------------------------------------------------------
% Calculates Signal-to-Noise Ratio (SNR)
%
% Inputs:
%   signal : ADC Output
%   Fs     : Sampling frequency
%
% Output:
%   snr    : Signal-to-Noise Ratio (dB)
%---------------------------------------------------------------

[P, ~] = calculateFFT(signal, Fs);

powerSpectrum = P.^2;

% Remove DC
powerSpectrum(1) = 0;

% Find signal peak
[~, peakIndex] = max(powerSpectrum);

% Define a fixed frequency window (e.g., +/- 2 Hz)
bin_resolution = Fs / length(powerSpectrum); % Hz per bin
window = ceil(2.0 / bin_resolution);         % Convert 2 Hz to number of bins

left = max(1, peakIndex-window);
right = min(length(powerSpectrum), peakIndex+window);

% Signal power
signalPower = sum(powerSpectrum(left:right));

% Noise power
noisePower = sum(powerSpectrum) - signalPower;

% Compute SNR
snr = 10 * log10(signalPower / noisePower);

end