function [P, f] = calculateFFT(signal, Fs)
%---------------------------------------------------------------
% Calculates Single-Sided FFT Magnitude Spectrum
%
% Inputs:
%   signal : Input signal
%   Fs     : Sampling frequency
%
% Outputs:
%   P : Single-sided magnitude spectrum
%   f : Frequency vector
%---------------------------------------------------------------

% Remove DC
signal = signal - mean(signal);

N = length(signal);

% Apply Hann window
w = hann(N)';
signal = signal .* w;

% FFT
Y = fft(signal);

% Normalize
P = abs(Y) / sum(w);

% Single-sided spectrum
P = P(1:floor(N/2));
P(2:end) = 2 * P(2:end);

% Frequency vector
f = (0:length(P)-1) * Fs / N;

end