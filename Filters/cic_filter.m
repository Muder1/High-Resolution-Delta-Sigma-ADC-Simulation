% Inputs:
%   x : Input bitstream
%   R : Decimation Factor
%   N : Number of Stages
%   M : Differential Delay
%
% Outputs:
%   y     : Normalized CIC Output
%   state : Internal signals for analysis
%---------------------------------------------------------------

function [y, state] = cic_filter(x, R, N, M)
%---------------------------------------------------------------
% Cascaded Integrator-Comb (CIC) Filter - FIR EQUIVALENT
%
% This uses the FIR equivalent of a CIC filter to prevent 
% floating-point precision loss (cumsum overflow) in MATLAB.
%---------------------------------------------------------------

    % A single CIC stage is mathematically a moving average of length R*M
    h = ones(1, R*M);
    
    % Cascade N stages
    temp = x;
    for stage = 1:N
        temp = filter(h, 1, temp);
    end
    
    % Downsample by R
    downsampled_out = temp(1:R:end);
    
    % Gain Compensation
    gain = (R*M)^N;
    y = downsampled_out / gain;
    
    % Store minimal internal states for compatibility
    state.downsampled = downsampled_out;
    state.gain = gain;
    state.integrator = temp; % Placeholder so the plot functions don't crash
end