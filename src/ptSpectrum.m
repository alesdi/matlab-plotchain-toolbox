function [s, f] = ptSpectrum(samples, fs)
%PTSPECTRUM Compute the spectrum of the given waveform
%   [s, f] = PTSPECTRUM(samples, fs) returns the spectrum and frequency
%   vectors given the samples vector and sampling frequency

samples = samples - mean(samples);
L=length(samples);
f = fs*(0:(L/2))/L;

fft_data=fft(samples); % Fourier transform

s = abs(fft_data/L); % Two-sided spectrum
s = 2*s(1:floor(L/2)+1); % Single-sided spectrum

end