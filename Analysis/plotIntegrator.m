function plotIntegrator(integratorOutput, titleText)

figure;
plot(integratorOutput(1:1000),'LineWidth',1.5);
xlabel('Sample');
ylabel('Integrator Output');
title(titleText);
grid on;

end