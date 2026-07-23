function [y, state] = dsm_second_order_CIFB(x)
%---------------------------------------------------------------
% Second-Order Delta-Sigma Modulator (CIFB Architecture)
%
% Architecture:
%
%          x
%          |
%        (+) <-----------------------------+
%         |                                |
%         v                                |
%   First Integrator                       |
%         |                                |
%        (+) <-----------------------------+
%         |                                |
%         v                                |
%   Second Integrator                      |
%         |                                |
%         v                                |
%     1-bit Quantizer ----------------------
%
%
% Input:
%   x : Input signal (-1 to +1)
%
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

error1 = zeros(1,N);
error2 = zeros(1,N);

feedback = zeros(1,N);

running_average = zeros(1,N);

%% Initial Conditions

int1 = 0;
int2 = 0;

feedback_state = 0;

average = 0;

%% Main Loop

for n = 1:N

    %-----------------------------------------------------------
    % First Summer
    %-----------------------------------------------------------

    error1(n) = x(n) - feedback_state;

    %-----------------------------------------------------------
    % First Integrator
    %-----------------------------------------------------------

    int1 = int1 + error1(n);

    integrator1(n) = int1;

    %-----------------------------------------------------------
    % Second Summer (CIFB)
    %-----------------------------------------------------------

    error2(n) = int1 - feedback_state;

    %-----------------------------------------------------------
    % Second Integrator
    %-----------------------------------------------------------

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
    % Feedback DAC
    %-----------------------------------------------------------

    feedback_state = y(n);

    feedback(n) = feedback_state;

    %-----------------------------------------------------------
    % Running Average
    %-----------------------------------------------------------

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