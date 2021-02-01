
%% Read frame data
vid = VideoReader('fingertip.mp4')
nf = vid.NumFrames;
frameavg = 0;
fs = 30 % 30 frames/sec

% For each frame:
for i = 1:nf
    frame = read(vid,i); % Extract frame
    red = frame(:,:,1); % Extract red channel
    frameavg(i) = mean2(red); % Calculate mean red of frame
end

DCframes = frameavg - mean(frameavg) % We only care about changes, not DC

%Plot unfiltered signal
figure(1);
plot(DCframes)
title("Unfiltered signal")
xlabel("frames")
ylabel("Intensity")


%% Extract heart rate

%Heart rate frequency ~50bpm-200bpm = 0.833-3.3Hz = 0.027fs to 0.110fs
%Low pass filter to eliminate garbage
lpfilt = designfilt('lowpassfir','PassbandFrequency',0.210, ...
         'StopbandFrequency',0.3,'PassbandRipple',0.1, ...
         'StopbandAttenuation',10,'DesignMethod','kaiserwin');
     
lp = filter(lpfilt,DCframes); % Pass data through filter

%High pass filter to eliminate breathing rate
hpfilt = designfilt('highpassfir','PassbandFrequency',0.025, ...
         'StopbandFrequency',0.003,'PassbandRipple',0.1, ...
         'StopbandAttenuation',10,'DesignMethod','kaiserwin');     
     
bp = filter(hpfilt, lp); % Run lowpass'd data through highpass, to create bandpass filter

figure(2);
plot(bp)
title("Heart Rate signal")
xlabel("frames")
ylabel("Intensity")
ffthr = abs(fft(bp)); % FFT Magnitudes for the heart rate signal
figure(3);
plot(ffthr); % Plot FFT Magnitudes
title("Heart rate signal - FFT")
xlabel("Frequency bin")
ylabel("Magnitude")

peaks = find(ffthr==max(ffthr)); % Find biggest FFT peaks
peak = peaks(1); % 2 FFT spikes: true frequency, and nyquist artifact

f_hr = (peak/length(ffthr)) * fs % Convert FFT # to beats/second
bpm = f_hr * 60 % beats/minute = beats/second * 60 seconds/minute


%% Extract Breathing rate

% Low pass filter
% Breathing rate ~12-20bpm, 0.2-0.4 hz, ~0.006fs to 0.013fs 
lpfilt = designfilt('lowpassfir','PassbandFrequency',0.013, ...
         'StopbandFrequency',0.03,'PassbandRipple',0.1, ...
         'StopbandAttenuation',20,'DesignMethod','kaiserwin');
     
lp = filter(lpfilt,DCframes);

%No high pass filter needed

figure(4);
plot(lp) % Plot breathing rate-filtered signal
title("Breathing Rate Signal")
xlabel("frames")
ylabel("Intensity")

figure(5);
fftbr = abs(fft(bp)); % FFT Magnitudes for the breath rate signal
plot(fftbr); % Plot FFT Magnitudes
title("Breathing Rate Signal - FFT")
xlabel("Frequency bin")
ylabel("Magnitude")


peaks = find(fftbr==max(fftbr)); % Find biggest FFT peaks
peak = peaks(1); % 2 FFT spikes: true frequency, and nyquist artifact

f_br = (peak/length(fftbr)) * fs % Convert FFT # to beats/second
bpm_br = f_br * 60 % beats/minute = beats/second * 60 seconds/minute
