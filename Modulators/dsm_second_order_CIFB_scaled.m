function [y, state] = dsm_second_order_CIFB_scaled(x)
%---------------------------------------------------------------
% Scaled Second-Order Delta-Sigma Modulator (CIFB Architecture)
%
% Architecture uses fractional scaling coefficients (0.5) to 
% prevent integrator overload and allow larger input amplitudes.
%---------------------------------------------------------------
N = length(x);

%% Output
y = zeros(1,N);

%% Internal States
integrator1 = zeros(1,N);
integrator2 = zeros(1,N);
error1 = zeros(1,N);
error2 = zeros(1,N);
feedback = zeros(1,N);
running_average = zeros(1,N);

%% Scaling Coefficients
a1 = 0.5;
a2 = 0.5;
b1 = 0.5; 

%% Initial Conditions
int1 = 0;
int2 = 0;
feedback_state = 0;
average = 0;

%% Main Loop
for n = 1:N
    %-----------------------------------------------------------
    % First Stage (Scaled Input & Feedback)
    %-----------------------------------------------------------
    error1(n) = (b1 * x(n)) - (a1 * feedback_state);
    int1 = int1 + error1(n);
    integrator1(n) = int1;

    %-----------------------------------------------------------
    % Second Stage (Scaled Feedback)
    %-----------------------------------------------------------
    error2(n) = int1 - (a2 * feedback_state);
    int2 = int2 + error2(n);
    integrator2(n) = int2;

    %-----------------------------------------------------------
    % 1-bit Quantizer
    %-----------------------------------------------------------
    if int2 >= 0
        y(n) = 1;
    else
        y(n) = -1;
    end

    %-----------------------------------------------------------
    % Feedback DAC & Average
    %-----------------------------------------------------------
    feedback_state = y(n);
    feedback(n) = feedback_state;

    average = average + y(n);
    running_average(n) = average/n;
end

%% Store States
state.integrator1 = integrator1;
state.integrator2 = integrator2;
state.error1 = error1;
state.error2 = error2;
state.feedback = feedback;
state.average_output = running_average;
end