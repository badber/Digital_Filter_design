% Author: Luis Badesa

%%
clear all
close all
clc

%% NOTEs
% About equiripple:
% - For certain specs, equiripple gives the LOWEST ORDER
% - For a fixed order, equiripple gives the NARROWEST TRANSITION BAND

% Order of an IIR filter = #biquads * 2 (which is M)
% Number of coefficients = order*2+1 (which is M+N+1, as M=N)

% multiplications/OUTPUT = #coef's, which is M+N+1 (usually M=N, 
%                                                   which is the 
%                                                   order of the 
%                                                   filter)
% Example: 8th order IIR, #multiplication/output_sample = 8+8+1 = 17

%% IIR (order specified)
% Elliptic Lowpass filter designed using FDESIGN.LOWPASS.
%
% All frequency values are in Hz.
Fs = 1;  % Sampling Frequency

N     = 6;     % Order
Fpass = 0.05;  % Passband Frequency
Apass = 0.2;   % Passband Ripple (dB)
Astop = 60;    % Stopband Attenuation (dB)

% Construct an FDESIGN object and call its ELLIP method.
h  = fdesign.lowpass('N,Fp,Ap,Ast', N, Fpass, Apass, Astop, Fs);
Hd = design(h, 'ellip');

% For a bandpass:
% Fpass1 = 0.15;  % First Passband Frequency
% Fpass2 = 0.2;   % Second Passband Frequency
% h  = fdesign.bandpass('N,Fp1,Fp2,Ast1,Ap,Ast2', N, Fpass1, Fpass2, ...
%                       Astop, Apass, Astop);

% For a highpass:
% h  = fdesign.highpass('N,Fp,Ast,Ap', N, Fpass, Astop, Apass);

% For a bandstop:
% Fpass1 = 0.15;  % First Passband Frequency
% Fpass2 = 0.45;  % Second Passband Frequency
% h  = fdesign.bandstop('N,Fp1,Fp2,Ap,Ast', N, Fpass1, Fpass2, Apass, Astop);


%% IIR (order not specified)
% Elliptic Bandpass filter designed using FDESIGN.BANDPASS.
%
% All frequency values are in Hz.
Fs = 1;  % Sampling Frequency

sampling_rate = 48e3;

Fstop1 = 11200/sampling_rate;   % First Stopband Frequency
Fpass1 = 12000/sampling_rate;   % First Passband Frequency
Fpass2 = 15000/sampling_rate;   % Second Passband Frequency
Fstop2 = 16000/sampling_rate;   % Second Stopband Frequency
Astop1 = 70;      % First Stopband Attenuation (dB)
Apass  = 0.1;     % Passband Ripple (dB)
Astop2 = 70;      % Second Stopband Attenuation (dB)
match  = 'both';  % Band to match exactly

% Construct an FDESIGN object and call its ELLIP method.
h  = fdesign.bandpass(Fstop1, Fpass1, Fpass2, Fstop2, Astop1, Apass, ...
                      Astop2, Fs);
Hd = design(h, 'ellip', 'MatchExactly', match);
%
%
% % For the low-pass case, change "h":
% h  = fdesign.lowpass(Fpass, Fstop, Apass, Astop, Fs);
%
% % For the high-pass case, change "h":
% h  = fdesign.highpass(Fstop, Fpass, Astop, Apass, Fs);
%
% % For the band-stop case, change "h":
% h  = fdesign.bandstop(Fpass1, Fstop1, Fstop2, Fpass2, Apass1, Astop, ...
%                      Apass2, Fs);

%%
% Now I modify the object created by MATLAB:
SOS = Hd.sosMatrix;	
Gains = Hd.ScaleValues;
Gain = prod(Gains);

%%
% And the magnitude response of the filter:
[h,w] = freqz(SOS,'whole',2001);

% Plot polygons for the specs:
x = [0 0 Fstop1 Fstop1];
y = [-1e3 -Astop1 -Astop1 -1e3];
patch(x,y,'blue','FaceAlpha',.3)
x = [Fpass1 Fpass1 Fpass2 Fpass2];
y = [Gain -Apass -Apass Gain];
patch(x,y,'blue','FaceAlpha',.3)
x = [Fstop2 Fstop2 0.5 0.5];
y = [-1e3 -Astop2 -Astop2 -1e3];
patch(x,y,'blue','FaceAlpha',.3)
hold on

plot(w/(2*pi),20*log10(abs(Gain*h)))
    
axis([0 0.5 -80 5])
xlabel('Normalized Frequency (cycles/sample)')
ylabel('Magnitude (dB)')
title('Filter 2')
grid on
     

