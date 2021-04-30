function [thd] = ptTHD(x, fs, f0)
%PTTHD Custum Total Harmonic Component computation
%   thd = PTTHD(x, fs[, f0]) returns the ratio between the RMS value of
%   6 subharmonics and the fundamental component, assumed as the closest
%   peak to the given f0 frequency within 50% tolerance. If f0 is not
%   specified, the absolute peak is assumed.

% remove DC component
x = x - mean(x);

n = length(x);

% use Kaiser window to reduce effects of leakage
w = kaiser(n, 38);
rbw = enbw(w, fs);
[Pxx, F] = periodogram(x, w, n, fs, 'psd');

[peaks, f0s] = findpeaks(Pxx, F);
    
if exist('f0', 'var')
    % Restrict the peak search within 50% from the given frequency
    sel = f0s>(f0*0.5)&f0s<(f0*1.5);
    f0s = f0s(sel);
    peaks = peaks(sel);
end

[~, index] = max(peaks);

Ffund = f0s(index);

nHarm = 6;

% Preallocating
harmPow = zeros(1, nHarm);
harmFreq = zeros(1, nHarm);

% Fundamental power estimate
[Pfund, ~, ~, ~, ~] = signal.internal.getToneFromPSD(Pxx, F, rbw, Ffund);
harmPow(1) = Pfund;
harmFreq(1) = Ffund;

harmSum = 0;
for i=2:nHarm
  toneFreq = i*Ffund;
  [harmPow(i), harmFreq(i), ~, ~, ~] = signal.internal.getToneFromPSD(Pxx, F, rbw, toneFreq);
  
  % obtain local maximum value in neighborhood of bin   
  if ~isnan(harmPow(i))
    harmSum = harmSum + harmPow(i);
  end
end

thd = harmSum / harmPow(1);

% figure;
% plot(F, 10*log10(Pxx/Pfund));
% 
% for f=Ffund:Ffund:nHarm*Ffund
%     xline(f); 
% end
%  
% ylim([-40 10]);

end

