clc; clear all; close all;

% Read humina.wav or jawharp.wav or any audio to be extended to desired len
[audio, fs] = audioread('humina.wav');

% Select first second
segment_duration = 1;
segment_samples = segment_duration * fs;
audio_segment = audio(1:segment_samples);

% Compute FFT of segment
N_fft = 2^nextpow2(segment_samples);
X = fft(audio_segment, N_fft);
X_mag = abs(X);

% Generate random phases
half_N = N_fft/2 - 1;
random_phase = 2*pi*rand(half_N, 1) - pi; % Random phases between -pi and pi

% Create symmetric phase vector (to ensure real signal after IFFT)
phase_vector = [0; random_phase; 0; -flipud(random_phase)];

% Construct complex spectrum with original magnitudes and random phases
Y = X_mag .* exp(1j * phase_vector);

% Inverse FFT and its normalization
synthetic_segment = real(ifft(Y));
synthetic_segment = synthetic_segment / max(abs(synthetic_segment));

% Concatenate segments and trim to desired length
num_repeats = 10;
synthetic_audio = repmat(synthetic_segment, num_repeats, 1);
synthetic_audio = synthetic_audio(1:num_repeats*segment_samples);

% Save audio
audiowrite('synthetic_audio_IFFT.wav', synthetic_audio, fs);

% Plot for comparison
time_axis_original = (0:segment_samples-1)/fs;
time_axis_synthetic = (0:length(synthetic_audio)-1)/fs;

figure;
subplot(2,1,1);
plot(time_axis_original, audio_segment);
title('Original Audio Segment');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(2,1,2);
plot(time_axis_synthetic, synthetic_audio);
title('Synthetic Audio (Inverse FFT Method)');
xlabel('Time (s)');
ylabel('Amplitude');

% Spectra
f_axis = fs/2 * linspace(0, 1, N_fft/2+1);
orig_spectrum = 20*log10(abs(X(1:N_fft/2+1))/max(abs(X)));
synthetic_spectrum = 20*log10(abs(Y(1:N_fft/2+1))/max(abs(Y)));

figure;
plot(f_axis, orig_spectrum, 'b-', 'LineWidth', 1.2); hold on;
plot(f_axis, synthetic_spectrum, 'r.', 'LineWidth', 1.2);
grid on;
title('Magnitude Spectrum Comparison');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
legend('Original Segment', 'Synthetic Segment (IFFT)');
