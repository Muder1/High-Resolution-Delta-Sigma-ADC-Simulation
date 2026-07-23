function plotBitstream(bitstream, numSamples)

if nargin < 2
    numSamples = 200;
end

figure;
stairs(bitstream(1:numSamples), 'LineWidth', 1.5);
xlabel('Sample');
ylabel('Output');
title('First-Order Delta-Sigma Bitstream');
ylim([-1.5 1.5]);
grid on;

end