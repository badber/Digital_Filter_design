% Author: Luis Badesa

%%
clear all
close all
clc

% This code gets the frequencies and amplitudes of the 2 main sinusoindal
% components contained in a signal, using the DFT.

% The data contains samples in volts of a signal sampled using a sampling 
% frequency of 500 ksp

%% Inputs
x = load('signal_data.txt');
Fs = 500e3; % The signal was sampled using a frequency of 500ksps.

%%
n_samples = length(x);

N = n_samples*16; % Zero-pad the signal, so that the DFT has a better resolution 

% Compute the DFT:
X = fft(x,N);

f = (0:N-1)/N;
f(N/2+1+1:end) = f(N/2+1+1:end)-1; % Place the negative frequencies
                                   % in the 2nd half of the array.
F = f*Fs;    
figure(1)
plot(F/1e3,20*log10(abs(X)))
ylabel('|X(k)| (dB)')
xlabel('F (kHz)')

%%
% Now let's identify the frequency of the main sinusoidal component:
a = 85e3/Fs;
b = 90e3/Fs; % "a" and "b" are the 2 ends of the interval

index1 = ceil(a*N);
index2 = ceil(b*N); % Indexes for the vector "f"

% Just to check:
f(index1)
f(index2)

f_interval1 = f(index1:index2);
X_interval1 = X(index1:index2);

[Magnitude_dB,index] = max(20*log10(abs(X_interval1)));

% To get the magnitude of the signal in volts, we can 
% obtain the Fourier series coefficient correspondent to
% the harmonic:
% 
% X(k)/n_samples, where "k" gets the value of the varible "index"
% in this case.
%
% After that, we have to multiply the Fourier coefficient by 2.
Magnitude_main = 2*abs(X_interval1(index))/n_samples

Freq_main = f_interval1(index)*Fs % Units: Hz

