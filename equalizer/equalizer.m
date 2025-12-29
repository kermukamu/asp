clear all; close all; clc;

fs = 44100;            % Sampling rate [Hz]
fc_low = 200;          % Low-shelf corner frequency
fc_high = 2000;        % High-shelf corner frequency
glp_db = 6;            % Low-shelf gain in dB
ghp_db = 6;            % High-shelf gain in dB

% Shelving coefficients
[b_low, a_low] = shelving_coefficients(glp_db, fc_low, 'lowpass', fs);
[b_high, a_high] = shelving_coefficients(ghp_db, fc_high, 'highpass', fs);
b_total = conv(b_low, b_high);
a_total = conv(a_low, a_high);

% High-pass and low-pass response
[h_low, f_low] = freqz(b_low, a_low, 2000, fs);
[h_high, f_high] = freqz(b_high, a_high, 2000, fs);

% Total response
[h_total, f_total] = freqz(b_total, a_total, 2000, fs);

% Convert to dB scale
mag_lp_db    = 20*log10(abs(h_low));
mag_hp_db    = 20*log10(abs(h_high));
mag_total_db = 20*log10(abs(h_total));

% Plot
figure('Name','Two-band Shelving EQ','NumberTitle','off');
semilogx(f_low, mag_lp_db, 'LineWidth', 1.5); hold on;
semilogx(f_high, mag_hp_db, 'LineWidth', 1.5);
semilogx(f_total, mag_total_db, 'k','LineWidth', 2);

grid on; 
xlabel('Frequency (Hz)'); 
ylabel('Magnitude (dB)');
title('First-Order Low/High Shelf Filters and Cascaded Response');
legend('Low Shelf (6dB, 200 Hz corner frequency)','High Shelf (6dB, 2000 Hz corner frequency)','Cascaded');
xlim([20 20000]);
ylim([-15 15]);

function [b, a] = shelving_coefficients(g_db, fc, type, fs)
    w_c = ((fc*2*pi)/fs);
    g = 10^(g_db/20);

    % Calculating the coefficients
    if (strcmp(type, 'highpass'))
        b0 = sqrt(g)*tan(w_c/2)+g;
        b1 = sqrt(g)*tan(w_c/2)-g;
        a0 = sqrt(g)*tan(w_c/2)+1;
        a1 = sqrt(g)*tan(w_c/2)-1;
    end
    if (strcmp(type, 'lowpass'))
        b0 = g*tan(w_c/2) + sqrt(g);
        b1 = g*tan(w_c/2) - sqrt(g);
        a0 = tan(w_c/2) + sqrt(g);
        a1 = tan(w_c/2) - sqrt(g);
    end
    b = [b0, b1];
    a = [a0, a1];
end