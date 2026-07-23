function [y, state] = dsm_third_order_CIFB_scaled(x)
%---------------------------------------------------------------
% Scaled Third-Order Delta-Sigma Modulator (CIFB)
%
% Architecture uses fractional scaling coefficients to prevent 
% integrator overload and guarantee stability.
%---------------------------------------------------------------
N = length(x);
y = zeros(1,N);

%% Internal States for Analysis
integrator1 = zeros(1,N);
integrator2 = zeros(1,N);
integrator3 = zeros(1,N);

%% Scaling Coefficients (Stable NTF with OOB Gain = 1.5)
a1 = 0.0440;    % Feedback gain to Stage 1
a2 = 0.2852;    % Feedback gain to Stage 2
a3 = 0.7997;    % Feedback gain to Stage 3
b1 = 0.0440;    % Input feedforward gain

%% Initial Conditions
int1 = 0;
int2 = 0;
int3 = 0;
feedback_state = 0;

%% Main Loop
for n = 1:N
    %-----------------------------------------------------------
    % First Stage (Scaled Input & Scaled Feedback)
    %-----------------------------------------------------------
    error1 = (b1 * x(n)) - (a1 * feedback_state);
    int1 = int1 + error1;
    integrator1(n) = int1;

    %-----------------------------------------------------------
    % Second Stage (Scaled Feedback)
    %-----------------------------------------------------------
    error2 = int1 - (a2 * feedback_state);
    int2 = int2 + error2;
    integrator2(n) = int2;

    %-----------------------------------------------------------
    % Third Stage (Scaled Feedback)
    %-----------------------------------------------------------
    error3 = int2 - (a3 * feedback_state);
    int3 = int3 + error3;
    integrator3(n) = int3;

    %-----------------------------------------------------------
    % 1-bit Quantizer
    %-----------------------------------------------------------
    if int3 >= 0
        y(n) = 1;
    else
        y(n) = -1;
    end

    %-----------------------------------------------------------
    % Feedback DAC
    %-----------------------------------------------------------
    feedback_state = y(n);
end

%% Store States
state.integrator1 = integrator1;
state.integrator2 = integrator2;
state.integrator3 = integrator3;
end