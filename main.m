clear;
clc;
close all;

%% Add Project Folders
addpath('Modulators');
addpath('Filters');
addpath('Analysis');
addpath('Signal');
addpath('Experiments');

%% ============================================================
% Simulation Parameters
% ============================================================
params.Fs  = 128e3;      % Modulator Sampling Frequency
params.Fin = 80;         % Input Signal Frequency
params.A   = 0.8;        % Input Amplitude

params.T   = 100;         % Simulation Time

% CIC Parameters
params.R = 256;          % Decimation Factor
params.N = 4;            % Number of CIC Stages
params.M = 1;            % Differential Delay

%% ============================================================
% Generate Input Signal
% ============================================================
[t, x] = generateSignal(params);

%% ============================================================
% Input Signal Analysis
% ============================================================
plotTimeSignal(t, x);
plotFFT(x, params.Fs, 'Input Signal FFT');

%% ============================================================
% Third-Order Delta-Sigma Modulator
% ============================================================

[bitstream, state] = dsm_third_order_CIFB_scaled(x);

%% ============================================================
% Modulator Analysis
% ============================================================
plotBitstream(bitstream);
plotIntegrator(state.integrator1,'First Integrator Output');
plotIntegrator(state.integrator2,'Second Integrator Output');
plotIntegrator(state.integrator3,'Third Integrator Output');
plotPSD(bitstream, params.Fs);

%% ============================================================
% CIC Filter (4th-Order)
% ============================================================
[cic_out, cic_state] = cic_filter(...
    bitstream,...
    params.R,...
    params.N,...
    params.M);

%% ============================================================
% CIC Analysis
% ============================================================
plotCIC(cic_state.integrator,5000);

figure;
stem(cic_state.downsampled,'filled');
grid on;
title('Downsampled Output');
xlabel('Sample');
ylabel('Amplitude');

figure;
plot(cic_out,'LineWidth',1.5);
grid on;
title('Normalized CIC Output');
xlabel('Sample');
ylabel('Amplitude');
plotFFT(cic_out, params.Fs/params.R, 'Recovered Signal FFT');

%% ============================================================
% ADC Performance
% ============================================================
Fs_out = params.Fs / params.R;

% Discard the transient (first 10% of the signal)
start_idx = floor(0.1 * length(cic_out)) + 1;
steady_state_out = cic_out(start_idx:end);

% Calculate Performance on the steady-state only
snr = calculateSNR(steady_state_out, Fs_out);
enob = calculateENOB(snr);

fprintf('\n');
fprintf('========================================\n');
fprintf('      THIRD-ORDER DELTA-SIGMA ADC       \n');
fprintf('========================================\n');
fprintf('Output Sampling Rate : %.0f Hz\n', Fs_out);
fprintf('SNR                  : %.2f dB\n', snr);
fprintf('ENOB                 : %.2f bits\n', enob);
fprintf('========================================\n');

%% ============================================================
% Export Bitstream for Verilog Co-Simulation
% ============================================================
disp('Exporting bitstream to text file...');

% 1. Convert +1 / -1 to digital 1 / 0
verilog_bitstream = (bitstream > 0);

% 2. Open (or create) the text file
fid = fopen('bitstream_in.txt', 'w');

% 3. Write the bits column-wise (line-by-line)
fprintf(fid, '%d\n', verilog_bitstream);

% 4. Close the file
fclose(fid);

disp('Success: bitstream_in.txt generated!');