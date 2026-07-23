function [y, state] = dsm_first_order(x)
%---------------------------------------------------------------
% First-Order Delta-Sigma Modulator
%
% Input:
%   x : Input signal (normalized between -1 and +1)
%
% Output:
%   y     : 1-bit output bitstream (+1 / -1)
%   state : Internal states for debugging and analysis
%---------------------------------------------------------------

% Difference equations:
%
% e[n] = x[n] - y[n-1]
%
% v[n] = v[n-1] + e[n]
%
% y[n] = sign(v[n])

N = length(x);

% Output vector
y = zeros(1, N);

% Internal state vectors
integrator = zeros(1, N);
error = zeros(1, N);
feedback = zeros(1, N);
running_average = zeros(1,N);

% Initial conditions
integrator_out = 0;
dac_out = 0;
running_sum = 0;

for n = 1:N

    % Error between input and previous output
    error(n) = x(n) - dac_out;

    % Integrator
    integrator_out = integrator_out + error(n);
    integrator(n) = integrator_out;

    % 1-bit Quantizer
    if integrator_out>=0
        y(n) = 1;
    else
        y(n) = -1;
    end

    % Feedback DAC
    dac_out = y(n);
    feedback(n) = dac_out;

    running_sum = running_sum + y(n);
    running_average(n) = running_sum/n;

end

% Store Internal States
state.input = x;
state.integrator = integrator;
state.error = error;
state.feedback = feedback;
state.average_output = running_average;

end

