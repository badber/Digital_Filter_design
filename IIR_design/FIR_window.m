% Author: Luis Badesa

%%
clear all
close all
clc

%% NOTES
% Delay of the filter: (M-1)/2 samples
% (where M is the NUMBER OF COEFFICIENTS, not the order of the filter)

% - For a high-pass filter, NEVER choose symmetric h(n) AND M even, 
%   because the gain at f=0.5 is always going to be 0.
%   (symmetric h(n) means a real Hr(f))
% - For a low-pass filter, NEVER choose anti-symmetric h(n) AND 
%   M odd, because the DC gain is always going to be 0. I THINK THAT
%   FOR M EVEN, IT WOULDN'T WORK EITHER.
%   (anti-symmetric h(n) means a purely imaginary Hr(f))

% Window method is only better than an equirpple desing in these 2 
% cases:
% - Fancy shapes in the passband like lines, parabollas, etc. 
%   (not possible to achieve using equiripple)
% - Very high order filters: Remez algorithm might not converge.

%%
% Parameters to change:
% 1) Window function shape: this is how we modify the gain of the 
%    rejection and pass bands. It also makes the transition band
%    wider.
%    ONCE IT BARELY MEETS THE SPECS, DON'T MODIFY THE PARAMETER OF
%    THE WINDOW FUNCTION AGAIN.
%    We can also try "chebwin" instead of "kaiser", it is similar 
%    to use.
% 2) M: modifies the width of the transition band.
% 3) Characterictics of Hr(w)

% #coefficients of the FIR filter:
% (order is M+1, higher order narrows the transition band)
M = 117; 

% Window function:
% (increasing the number of the Kaiser makes the ripple smaller)
% you can find more window functions in "help window"
my_window = kaiser(M,9.2)';
% (Chebyshev window, "chebwin", is also easy to use)

N = 8*1024; % Always a power of 2

Fs = 1; % Sampling Frequency

f = (0:N-1)/N;
f(N/2+1+1:end) = f(N/2+1+1:end)-1; % Place the negative frequencies
                                   % in the 2nd half of the array.
F = f*Fs;

% Desired specifications of the filter
Hr = (abs(F)<(0.1147)); % Low pass filter
Hr = Hr.*10.^(100*abs(F/Fs)/20);
Hr = Hr*.10^(0.17/20);

% For 2 band-pass, with gain:
% Hr1 = (abs(F)<(0.05*Fs))*10^(6/20);
% Hr2 = (abs(F)>12e3 & abs(F)<17e3)*10^(13/20); % Gain of 13dB
% Hr = Hr1 + Hr2;

% For a ramp in the pass-band:
% Hr = (abs(F)>8e3 & abs(F)<12e3);
% Hr = Hr.*10.^((abs(F)-8e3)*(13/(12e3-8e3))/20); % 13dB gain at 12e3Hz
%
% Hr = (abs(F)>8e3 & abs(F)<12e3);
% Hr = Hr.*10.^((12e3-abs(F))*(13/(12e3-8e3))/20); 

% For a parabolla in the pass-band:
% Hr = abs(F)<(0.1*48e3); % Low pass filter
% Hr = Hr.*10.^(500*(F/Fs).^2/20);

%%
figure(1)
plot(f,Hr,'.')
ylabel('Filter Gain')
xlabel('f (cycles/sample)')
title('Ideal filter specs')
%axis([0 0.5 -0.05 1.05])
%%
hr = ifft(Hr); % Impulse response of the ideal filter
% figure(2)
% stem(0:N-1,hr,'.')
% ylabel('h_{r}(n)')
% xlabel('n')
% title('Impulse response of the ideal filter')
%%
Hd = Hr.*exp(-j*2*pi*f*(M-1)/2); % Phase shift in the frequency domain,
                                 % so that the filter becomes causal.
hd = ifft(Hd);
% figure(3)
% stem(0:N-1,hd,'.')
% ylabel('h_{d}(n)')
% xlabel('n')
% title('Impulse response of the ideal, causal filter')
%%
% Now we approximate the impulse response of our filter, "h", by
% "hd*Wd":
h = hd(1:M).*my_window;
% figure(4)
% stem(0:M-1,h,'r.')
% ylabel('h(n)')
% xlabel('n')
% title('Impulse response of the real filter')

H = fft(h,N);
%%
figure(5)
% Plot polygons for the specs:
x = [0 0.1 0.1 0];
y = [-0.5 9.5 10.5 0.5];
patch(x,y,'blue','FaceAlpha',.3)
x = [0.14 0.14 0.5 0.5];
y = [-1e3 -80 -80 -1e3];
patch(x,y,'blue','FaceAlpha',.3)

% % For parabolla:
% freq = linspace(0,0.1,50);
% spec = 500*(freq).^2;
% patch([freq fliplr(freq)],[spec-0.2 fliplr(spec+0.2)],'flat')

hold on

plot(f,20*log10(abs(H)))
axis([0 0.5 -100 15])
ylabel('Gain (dB)')
xlabel('f (cycles/sample)')
title('Frequency response of the real filter')
%%
% figure(6)
% plot(f,angle(H))
% axis([0 0.5 -pi-0.1 pi+0.1])
% ylabel('Phase (rad)')
% xlabel('f (cycles/sample)')
% title('Phase response of the real filter')