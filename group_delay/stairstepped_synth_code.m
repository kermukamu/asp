clear all; close all; clc;

%% Define parameters
N = 8192; % Number of frequency points
fs = 44100;
m = 500; % Scaling factor for delay
n = 50; % Number of steps
alpha = 0.001; % Smoothing parameter

%% Generate a Synthetic Sound
duration = 2;
t = (0:1/fs:duration-1/fs)';

% Impulse train
impulse_interval = round(fs / 5); % Spacing between impulses
x = zeros(size(t));
x(1:impulse_interval:end) = 1; % Generate impulse train

%% Create stair steps
f = linspace(0, pi, N);

% Smoothed stair-step group delay
%step_size = pi / n; 
%tau = m * (...
%    (tanh((f ./ (alpha * step_size)) - ((1/alpha) * floor(f / step_size)) - (2/alpha)) ./ ...
%    (2 * tanh(2 / alpha))) + 0.5 + floor(f / step_size));

% Compute step centers
step_centers = linspace(0, pi, n + 1);

% Initialize staircase function
tau = zeros(size(f));

% Loop through each step
for k = 1:n
    tau = tau + (1 + tanh((1/alpha) * (f - step_centers(k)))) / 2;
end

% Normalize to scaling factor
tau = tau * (n / max(tau)) * m;

% Compute Phase Response from Group Delay
phase = -cumsum(tau) * (f(2) - f(1));

% Convert Phase to Frequency Response of Allpass Filter
H = exp(1j * phase);
h = ifft(H, 'symmetric');

% Apply filter
y = conv(x, h, 'same');

% Normalize and Save Output
y = y / max(abs(y));
audiowrite('synthesized_stairstep.wav', y, fs);

% Compute Frequency Response
[H_freq, w] = freqz(h, 1, N, fs);

%% Play the Sound
sound(y*0.1, fs);

%% Plot Results
figure;

% Stair-Stepped Group Delay
subplot(3,1,1);
plot(f * fs / (2*pi), tau, 'g'); title('Stair-Stepped Group Delay');
xlabel('Frequency (Hz)'); ylabel('Delay (samples)'); grid on;

% Magnitude Response
subplot(3,1,2);
plot(w, abs(H_freq), 'r'); title('Magnitude Response');
xlabel('Frequency (Hz)'); ylabel('Magnitude'); grid on;

% Phase Response
subplot(3,1,3);
plot(w, angle(H_freq), 'm'); title('Phase Response');
xlabel('Frequency (Hz)'); ylabel('Phase (radians)'); grid on;