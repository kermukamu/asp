clear all; close all; clc;

%% Define parameters
N = 8192; % Number of frequency points
fs = 44100;
k = 10000; % Maximum delay (samples)
f_mod = 5; % Modulation frequency (Hz)

%% Generate a Synthetic Sound
duration = 2;
t = (0:1/fs:duration-1/fs)';

% Impulse train
impulse_interval = round(fs / 5); % Spacing between impulses
x = zeros(size(t));
x(1:impulse_interval:end) = 1; % Generate impulse train

%% Compute Modulated Group Delay
f = linspace(0, pi, N);
tau = k * cos(2 * pi * f * f_mod); 

% Compute Phase Response
phase = -cumsum(tau) * (f(2) - f(1));

% Convert to Frequency Response of Allpass Filter
H = exp(1j * phase);
h = ifft(H, 'symmetric');

% Apply filter
y = conv(x, h, 'same');

% Normalize and Save Output
y = y / max(abs(y));
audiowrite('synthesized_modulation.wav', y, fs);

% Compute Frequency Response
[H_freq, w] = freqz(h, 1, N, fs);

%% Play the Sound
sound(y*0.1, fs);

%% Plot
figure;

% Stair-Stepped Group Delay
subplot(3,1,1);
plot(f * fs / (2*pi), tau, 'g'); 
title('Modulated Group Delay');
xlabel('Frequency (Hz)'); ylabel('Delay (samples)'); grid on;

% Magnitude Response
subplot(3,1,2);
plot(w, abs(H_freq), 'r'); title('Magnitude Response');
xlabel('Frequency (Hz)'); ylabel('Magnitude'); grid on;

% Phase Response
subplot(3,1,3);
plot(w, angle(H_freq), 'm'); 
title('Phase Response');
xlabel('Frequency (Hz)'); ylabel('Phase (radians)'); grid on;
