clear;
clc;
close all;

%% Add Project Folders

addpath('../Signal');
addpath('../Modulators');
addpath('../Filters');
addpath('../Analysis');

%% ============================================================
% Simulation Parameters
% ============================================================

params.Fs  = 256e3;
params.Fin = 80;
params.A   = 0.7;
params.T   = 1000.0;

params.R = 256;
params.M = 1;

orders = [1 2 3 4 5];

%% ============================================================
% Generate Input Signal
% ============================================================

[t,x] = generateSignal(params);

%% ============================================================
% Delta-Sigma Modulator
% ============================================================

[bitstream,~] = dsm_third_order_CIFB_scaled(x);

Fs_out = params.Fs/params.R;

%% ============================================================
% Comparison Loop
% ============================================================

fprintf('\n');
fprintf('=============================================\n');
fprintf('      CIC FILTER ORDER COMPARISON\n');
fprintf('=============================================\n');
fprintf('%5s %12s %12s\n','Order','SNR (dB)','ENOB');
fprintf('---------------------------------------------\n');

SNR = zeros(size(orders));
ENOB = zeros(size(orders));

for k = 1:length(orders)

    params.N = orders(k);

    [cic_out,~] = cic_filter(...
        bitstream,...
        params.R,...
        params.N,...
        params.M);

    % FFT
    plotFFT(cic_out,Fs_out,...
        sprintf('CIC Order = %d',params.N));

    % Performance
    SNR(k) = calculateSNR(cic_out,Fs_out);

    ENOB(k) = calculateENOB(SNR(k));

    fprintf('%5d %12.2f %12.2f\n',...
        params.N,...
        SNR(k),...
        ENOB(k));

end

fprintf('=============================================\n');

%% ============================================================
% Summary Plot
% ============================================================

figure;

plot(orders,ENOB,'o-','LineWidth',2);

xlabel('CIC Filter Order');

ylabel('ENOB (bits)');

title('ENOB vs CIC Filter Order');

grid on;