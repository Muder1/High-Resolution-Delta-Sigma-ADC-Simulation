function plotFFT(signal, Fs, titleText)

[P,f] = calculateFFT(signal, Fs);

figure;
plot(f,20*log10(P+eps),'LineWidth',1.5);
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title(titleText);
grid on;

end