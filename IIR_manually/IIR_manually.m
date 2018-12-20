% Author: Luis Badesa

%%
clear all
close all
clc

%%
% Steps to follow:
% -   Place zeros, in the unit-circle, for the frequencies that must be wiped out: the frequencies that start the stop-bands.
% -   Place poles for the frequencies where the pass-bands start.
% -   Place zeros also inside the stop-bands, so that the magnitude goes down in those regions. Comment: place zeros always in the unit-circle, it is better like that.
% -   Make 0 magnitude in the other poles, they are no necessary. However, we have to include them in the code so that the size of the “biquad” sections is right.
% -   Adjust the DC gain so that the maximum magnitude of the function is as specified.
% -   Adjust the magnitude of the poles so that the pass-band meets the specs.

%% Filter specifications:
%Figure 1 shows required limits on the gain of the filter |H(f)| in dB 
% versus the normalized frequency "f". 

figure(1)
x = [0 0 0.04 0.04];
y = [-1e3 -40 -40 -1e3];
patch(x,y,'blue','FaceAlpha',.3)
x = [0.32 0.32 0.5 0.5];
y = [-1e3 -35 -35 -1e3];
patch(x,y,'blue','FaceAlpha',.3)
x = [0.1 0.1 0.25 0.25];
y = [-7 -5 -0 -2];
patch(x,y,'blue','FaceAlpha',.3)

axis([0 0.5 -45 5])
hold on     
grid on
ylabel('Filter Gain (dB)')
xlabel('Normalized Frequency f=F/F_{s}')

%% Designing the filter which meets the listed specifications:

% Unit circle of the pole-zero diagram:
figure(2)
w = -pi:0.01:pi;
z = exp(j*w);
plot(real(z),imag(z))
axis square
axis([-1.15 1.15 -1.15 1.15])
ylabel('Im(z)')
xlabel('Re(z)')
title('Pole-zero diagram')
grid on

% (these specifications can be seen as rectangles in the Gain vs.
% Normalized frequency plot, which is included later)
zeros = [1*exp(j*2*pi*0.04 * [-1 1])... % Wipes out f = 0.04
         1*exp(j*2*pi*0.32 * [-1 1])... % Wipes out f = 0.32
         1*exp(j*2*pi*0.02 * [-1 1])...
         1*exp(j*2*pi*0.36 * [-1 1])...
         1*exp(j*2*pi*0.455 * [-1 1])];
     
poles = [0.895*exp(j*2*pi*0.25 * [-1 1])... % Passband
         0.88*exp(j*2*pi*0.1 * [-1 1])... % Passband
         0*exp(j*2*pi*0.1 * [-1 1])...
         0*exp(j*2*pi*0.1 * [-1 1])...
         0*exp(j*2*pi*0.1 * [-1 1])];
     
%%
% Plot the zeros and poles:     
hold on
plot(real(poles),imag(poles),'x')
plot(real(zeros),imag(zeros),'o')

%%
% Plot Gain vs. Normalized frequency of the filter:
num = poly(zeros);
den = poly(poles);

f = 0:0.001:0.5;
z = exp(j*2*pi*f);
G = 3e-2;
HdB = 20*log10(G*abs(polyval(num,z)./polyval(den,z)));

figure(3)
axis([0 0.5 -45 5])

% Plot rectangles for the specs:
x = [0 0 0.04 0.04];
y = [-1e3 -40 -40 -1e3];
patch(x,y,'blue','FaceAlpha',.3)
x = [0.32 0.32 0.5 0.5];
y = [-1e3 -35 -35 -1e3];
patch(x,y,'blue','FaceAlpha',.3)
x = [0.1 0.1 0.25 0.25];
y = [-7 -5 -0 -2];
patch(x,y,'blue','FaceAlpha',.3)

hold on     
plot(f,HdB)     
grid on

ylabel('Filter Gain (dB)')
xlabel('Normalized Frequency f=F/F_{s}')
     
