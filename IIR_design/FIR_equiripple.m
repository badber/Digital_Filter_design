% Author: Luis Badesa

%%
clear all
close all
clc

%% NOTES
f = [0 0.07 0.12 0.5]/0.5; % This is just an example. These are the 
                           % limits of the passband and stopband, in 
                           % this case for a low-pass filter. Each 
                           % element corresponds to a gain contained
                           % in vector "A".              
      % The "/0.5" is very important, as MATLAB normalizes by the 
      % Nyquist frequency.
      % If the specs are given in kHz, divide by Fs/2 instead of Fs.

A = [1 1 0 0]; % Change the 1s if the gain in the passband has another
               % value.

% Don't use this method when certain shape specs have to be met in the
% passband (like following a parabolla, etc.). Use the window method for
% that.

% Try to guess the order, and ultimately choose the one that barely 
% meets the specs.

% - For a high-pass filter, NEVER choose symmetric h(n) AND M even, 
%   because the gain at f=0.5 is always going to be 0.
%   (symmetric h(n) means a real Hr(f))
% - For a low-pass filter, NEVER choose anti-symmetric h(n) AND 
%   M odd, because the DC gain is always going to be 0. I THINK THAT
%   FOR M EVEN, IT WOULDN'T WORK EITHER.
%   (anti-symmetric h(n) means a purely imaginary Hr(f))

% Number of coefficients of the filter = M
% Order of the filter = M-1
% (SEE FROM LINE 81 FOR A MORE DETAILED EXPLANATION)

% multiplications/OUTPUT = #coef's

% An equiripple design gives you:
% - Lowest order for a certain specs
% - Narrowest transition band for a certain order

%% Main code
Fs = 1; % Sampling Frequency

% Passband 1
gain_dB = 30;
gain = 10^(gain_dB/20);
f = [0 0.13]/(Fs/2);
A = [gain gain];

% Stopband 1
f = horzcat(f,[0.15 0.2]/(Fs/2));
A = [A 0 0];

% Passband 2
f = horzcat(f,[0.23 0.5]/(Fs/2));
A = [A gain gain];

%%
ripple_pass_dB = 0.5; % MODIFY FOR EACH CASE
delta1_1 = 10^((gain_dB+ripple_pass_dB)/20) - gain;
delta1_2 = gain - 10^((gain_dB-ripple_pass_dB)/20);
delta1 = min(delta1_1,delta1_2);

ripple_stop_dB = 60; % MODIFY FOR EACH CASE
delta2 = 10^((-ripple_stop_dB)/20);

W = [1/delta1 1/delta2 1/delta1];

%%
% Number of coefficients of the filter:
M = 131; % TAKE A GUESS

% I input "M-1" instead of "M" because we have to input the order
% of the filter (Example: a 49 order polynomial has 50 coef's)
h = firpm(M-1,f,A,W);

N = 8*1024; % Always a power of 2
f = (0:N-1)/N;
f(N/2+1+1:end) = f(N/2+1+1:end)-1; % Place the negative frequencies
                                   % in the 2nd half of the array.
H = fft(h, N);

%%
figure(1)
% Plot polygons for the specs:
x = [0 0 0.13 0.13]*1/Fs;
y = [gain_dB-ripple_pass_dB gain_dB+ripple_pass_dB...
    gain_dB+ripple_pass_dB gain_dB-ripple_pass_dB];
patch(x,y,'blue','FaceAlpha',.3)
x = [0.15 0.15 0.2 0.2]*1/Fs;
y = [-1e3 -60 -60 -1e3];
patch(x,y,'blue','FaceAlpha',.3)
x = [0.23 0.23 0.5 0.5]*1/Fs;
y = [gain_dB-ripple_pass_dB gain_dB+ripple_pass_dB...
    gain_dB+ripple_pass_dB gain_dB-ripple_pass_dB];
patch(x,y,'blue','FaceAlpha',.3)
hold on
%%
plot(f,20*log10(abs(H)));
ylabel('Gain (dB)')
xlabel('f (cycles/sample)')
axis([0 0.5 -70 40])
%%



% Check if the filter is linear phase:
max(h-h(end:-1:1)) % Should be close to zero

% Check that all the coefficients are real
