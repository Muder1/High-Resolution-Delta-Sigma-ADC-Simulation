function plotTimeSignal(t, x)

figure;
plot(t, x, 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Amplitude');
title('Input Signal');
grid on;
xlim([0 0.05]);

end