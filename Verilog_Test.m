%% ============================================================
% Verilog Hardware Verification
% ============================================================

addpath('Modulators');
addpath('Filters');
addpath('Analysis');
addpath('Signal');
addpath('Experiments');

disp('Loading RTL output data...');
rtl_data = load('rtl_output.txt');

rtl_data = rtl_data(:)';

% Normalize the 20-bit signed integer back to a floating point (-1.0 to 1.0)
rtl_normalized = rtl_data / (2^19);

% Discard the startup transient (first 10% of the data)
start_idx = floor(0.1 * length(rtl_normalized)) + 1;
steady_state_rtl = rtl_normalized(start_idx:end);

% Calculate Performance
Fs_out = 128000 / 256; % 500 Hz target output rate
snr_rtl = calculateSNR(steady_state_rtl, Fs_out);
enob_rtl = calculateENOB(snr_rtl);

% Print the final hardware results
fprintf('\n========================================\n');
fprintf('      VERILOG HARDWARE VERIFICATION     \n');
fprintf('========================================\n');
fprintf('Output Rate          : %.0f Hz\n', Fs_out);
fprintf('SNR                  : %.2f dB\n', snr_rtl);
fprintf('ENOB                 : %.2f bits\n', enob_rtl);
fprintf('========================================\n');

% 1. Plot the Time-Domain Sine Wave
figure('Name', 'Verilog Hardware Output');
plot(steady_state_rtl, 'LineWidth', 1.5);
grid on;
title(sprintf('Verilog Hardware Output (ENOB: %.2f bits)', enob_rtl));
xlabel('Sample');
ylabel('Amplitude (Normalized)');
xlim([0, 50]);

% 2. Plot the FFT
figure('Name', 'Verilog Hardware FFT');
plotFFT(steady_state_rtl, Fs_out, 'Verilog 20-bit Output FFT');