clc, clear all, close all


x = linspace(0, 3*pi, 100);
y = cos(x);

y_nan = y;
y_nan(57:72) = NaN;
y_r = peak_restore(y_nan);

figure
plot(y, '*');
hold on
plot(y_r, 'o');
