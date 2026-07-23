function plotCIC(signal, numSamples)

if nargin<2
    numSamples = 1000;
end

figure;
plot(signal(1:numSamples),'LineWidth',1.5);
xlabel('Sample');
ylabel('Amplitude');
title('CIC Filter Output');
grid on;

end