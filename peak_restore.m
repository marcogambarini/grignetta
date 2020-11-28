function y_r = peak_restore(y)

% restores peak (points in peak to be restored must be NaN)

% trova inizio e fine delle regioni NaN
ii=1;
while (isfinite(y(ii)))
    ii = ii+1;
end
x_s = ii-1;
while (isnan(y(ii)))
    ii = ii+1;
end
x_e = ii;


% valori noti per fit
y_s = y(x_s);
y_e = y(x_e);
yp_s = y(x_s) - y(x_s-1);
yp_e = y(x_e+1) - y(x_e);


% matrice del sistema

M = [0            0           1;
     0            1           0;
     (x_e-x_s)^2  x_e-x_s     1;
     2*(x_e-x_s)  1           0];
 
A = M'*M;
b = M'*[y_s; yp_s; y_e; yp_e];

coeff = A\b;

% ricostruzione
y_r = y;

for ii=x_s+1:x_e-1
    y_r(ii) = coeff(1)*(ii-x_s)^2 + coeff(2)*(ii-x_s) + coeff(3);
end

end