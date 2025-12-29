clear all; close all; clc;

% Load the audio File
[audio, fs] = audioread('arpeggio.wav'); % Load WAV file
audio = mean(audio, 2); % Convert to mono if stereo

% Define the Filter Parameters
N = 8192; % Set number of frequency points based on desired precision
f = linspace(0, pi, N); % Frequency vector

% Design a Group Delay Filter
tau = 5 + 2*sin(10*f); % Example group delay function
phase = -cumsum(tau) * (f(2) - f(1)); % Compute phase response

H = exp(1j * phase); % Convert phase response to frequency response
h = ifft(H, 'symmetric'); % Convert to impulse response

% Apply the filter
filtered_audio = conv(audio, h, 'same');

% Normalize and Save the Output
filtered_audio = filtered_audio / max(abs(filtered_audio)); % Normalize
audiowrite('filtered_output_basic.wav', filtered_audio, fs); % Save processed audio

%% Plotting
[H_freq, w] = freqz(h, 1, N, fs); % Compute frequency response

figure;

% Plot Impulse Response
subplot(3,2,1);
plot(h, 'b'); title('Impulse Response');
xlabel('Samples'); ylabel('Amplitude'); grid on;

% Plot Magnitude Response
subplot(3,2,2);
plot(w, abs(H_freq), 'r'); title('Magnitude Response');
xlabel('Frequency (Hz)'); ylabel('Magnitude'); grid on;

% Plot Phase Response
subplot(3,2,3);
plot(w, angle(H_freq), 'm'); title('Phase Response');
xlabel('Frequency (Hz)'); ylabel('Phase (radians)'); grid on;

% Plot Group Delay
subplot(3,2,4);
plot(f * fs / (2*pi), tau, 'g'); title('Group Delay');
xlabel('Frequency (Hz)'); ylabel('Delay (samples)'); grid on;

% Plot Original Audio Signal
subplot(3,2,5);
plot(audio, 'k'); title('Original Audio Signal');
xlabel('Samples'); ylabel('Amplitude'); grid on;

% Plot Filtered Audio Signal
subplot(3,2,6);
plot(filtered_audio, 'c'); title('Filtered Audio Signal');
xlabel('Samples'); ylabel('Amplitude'); grid on;
