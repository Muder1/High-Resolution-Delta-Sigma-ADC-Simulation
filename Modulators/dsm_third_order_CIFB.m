function [y, state] = dsm_third_order_CIFB(x)
%---------------------------------------------------------------
% Third-Order Delta-Sigma Modulator (CIFB Architecture)
%
% Architecture:
%
%          x
%          |
%        (+) <-----------------------------------------+
%         |                                            |
%         v                                            |
%   First Integrator                                   |
%         |                                            |
%        (+) <-----------------------------------------+
%         |                                            |
%         v                                            |
%   Second Integrator                                  |
%         |                                            |
%        (+) <-----------------------------------------+
%         |                                            |
%         v                                            |
%   Third Integrator                                   |
%         |                                            |
%         v                                            |
%     1-bit Quantizer ----------------------------------
%
% Input:
%   x : Input signal
% Output:
%   y     : 1-bit output (+1 / -1)
%   state : Internal states
%---------------------------------------------------------------
N = length(x);

%% Output
y = zeros(1,N);

%% Internal States
integrator1 = zeros(1,N);
integrator2 = zeros(1,N);
integrator3 = zeros(1,N);
error1 = zeros(1,N);
error2 = zeros(1,N);
error3 = zeros(1,N);

%% Initial Conditions
int1 = 0;
int2 = 0;
int3 = 0;
feedback_state = 0;

%% Main Loop
for n = 1:N
    %-----------------------------------------------------------
    % First Stage
    %-----------------------------------------------------------
    error1(n) = x(n) - feedback_state;
    int1 = int1 + error1(n);
    integrator1(n) = int1;

    %-----------------------------------------------------------
    % Second Stage
    %-----------------------------------------------------------
    error2(n) = int1 - feedback_state;
    int2 = int2 + error2(n);
    integrator2(n) = int2;

    %-----------------------------------------------------------
    % Third Stage
    %-----------------------------------------------------------
    error3(n) = int2 - feedback_state;
    int3 = int3 + error3(n);
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
state.error1 = error1;
state.error2 = error2;
state.error3 = error3;
end