clear;
clc;
close all;

%% Add Paths

addpath('../Signal');
addpath('../Modulators');
addpath('../Filters');
addpath('../Analysis');

%% ============================================================
% Simulation Parameters
% ============================================================

params.Fs  = 128e3;
params.Fin = 80;
params.A   = 0.8;
params.T   = 100.0;

params.N = 4;      % Keep CIC Order fixed
params.M = 1;

decimationFactors = [32 64 128 256 512];

%% ============================================================
% Generate Input Signal
% ============================================================

t = 0:1/params.Fs:params.T-1/params.Fs;
x = params.A*sin(2*pi*params.Fin*t);

%% ============================================================
% Delta-Sigma Modulator
% ============================================================

[bitstream,~] = dsm_third_order_CIFB_scaled(x);

%% ============================================================
% Comparison
% ============================================================

fprintf('\n');
fprintf('=============================================================\n');
fprintf('         DECIMATION FACTOR COMPARISON\n');
fprintf('=============================================================\n');
fprintf('%8s %12s %12s %12s\n','R','Fs_out(Hz)','SNR(dB)','ENOB');
fprintf('-------------------------------------------------------------\n');

SNR  = zeros(size(decimationFactors));
ENOB = zeros(size(decimationFactors));
FsOut = zeros(size(decimationFactors));

for k = 1:length(decimationFactors)
    params.R = decimationFactors(k);
    FsOut(k) = params.Fs/params.R;
    
    [cic_out,~] = cic_filter( ...
        bitstream,...
        params.R,...
        params.N,...
        params.M);
        
    % Discard the transient (first 10% of the signal) ---
    start_idx = floor(0.1 * length(cic_out)) + 1;
    steady_state_out = cic_out(start_idx:end);
    
    % FFT plot steady state to verify clean sine wave)
    plotFFT(steady_state_out,...
        FsOut(k),...
        sprintf('Decimation Factor R = %d',params.R));
        
    % Performance: Calculate on steady_state_out!
    SNR(k) = calculateSNR(steady_state_out, FsOut(k));
    ENOB(k) = calculateENOB(SNR(k));
    
    fprintf('%8d %12.0f %12.2f %12.2f\n',...
        params.R,...
        FsOut(k),...
        SNR(k),...
        ENOB(k));
end

fprintf('=============================================================\n');

%% ============================================================
% ENOB vs Decimation Factor
% ============================================================

figure;

plot(decimationFactors,...
     ENOB,...
     'o-','LineWidth',2);

xlabel('Decimation Factor (R)');
ylabel('ENOB (bits)');
title('ENOB vs Decimation Factor');
grid on;

%% ============================================================
% SNR vs Decimation Factor
% ============================================================

figure;

plot(decimationFactors,...
     SNR,...
     's-','LineWidth',2);

xlabel('Decimation Factor (R)');
ylabel('SNR (dB)');
title('SNR vs Decimation Factor');
grid on;

%% ============================================================
% Output Sampling Rate vs ENOB
% ============================================================

figure;

plot(FsOut,...
     ENOB,...
     '^-','LineWidth',2);

xlabel('Output Sampling Rate (Hz)');
ylabel('ENOB (bits)');
title('ENOB vs Output Sampling Rate');
grid on;
set(gca,'XDir','reverse');