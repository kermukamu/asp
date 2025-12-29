clc; clear all; close all;

% Read humina.wav or jawharp.wav or any audio to be extended to desired len
[audio, fs] = audioread('humina.wav');

% Select first second
segment_duration = 1;
segment_samples = segment_duration * fs;
audio_segment = audio(1:segment_samples);

% Calculate filter coefficients
lp_order = 10000;
lp_coeffs = lpc(audio_segment, lp_order);

% Generate synthetic audio by filtering white noise
duration_synth = 10;
num_samples_synth = duration_synth * fs;
white_noise = randn(num_samples_synth, 1);
synthetic_audio = filter(1, lp_coeffs, white_noise);
synthetic_audio = synthetic_audio / max(abs(synthetic_audio));

% Save audio
audiowrite('synthetic_audio_white.wav', synthetic_audio, fs);

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
title('Synthetic Audio (LP-based)');
xlabel('Time (s)');
ylabel('Amplitude');

% Compute FFT parameters
nfft = 2^nextpow2(segment_samples);
freq_axis = fs/2 * linspace(0, 1, nfft/2+1);

% Compute spectrum of the original segment
orig_fft = fft(audio_segment, nfft);
orig_magnitude = abs(orig_fft(1:nfft/2+1));
orig_magnitude = 20*log10(orig_magnitude/max(orig_magnitude)); % dB scale

% Compute spectrum of the synthetic audio
synthetic_fft = fft(synthetic_audio(1:segment_samples), nfft);
synthetic_magnitude = abs(synthetic_fft(1:nfft/2+1));
synthetic_magnitude = 20*log10(synthetic_magnitude/max(synthetic_magnitude)); % dB scale

% Plot both spectra for comparison
figure;
plot(freq_axis, orig_magnitude, 'b', 'LineWidth', 1.2); hold on;
plot(freq_axis, synthetic_magnitude, 'r', 'LineWidth', 1.2);
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Magnitude Spectrum Comparison');
legend('Original Audio', 'Filtered White Noise');
xlim([0 fs/2]);