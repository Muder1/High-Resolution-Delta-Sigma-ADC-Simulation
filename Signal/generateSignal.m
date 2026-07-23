function [t, x] = generateSignal(params)

t = 0:1/params.Fs:params.T-1/params.Fs;
x = params.A * sin(2*pi*params.Fin*t);

end