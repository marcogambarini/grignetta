clc, clear all, close all

fileName = 'esempio_norm_0.wav';
%fileName = 'esempio_norm_0.wav';
tic
disp('Reading audio...')
fflush(stdout()); %print to screen immediately
[yprenorm, Fs] = audioread(fileName, 'native');
%[y, Fs] = audioread('esempio_norm_-1.wav', 'native');
%p = audioplayer(yprenorm, Fs);
%play(p);
Nbit = 16;

%qui lavoro su audio già normalizzato a 0dB, che corrisponde a un valore
%massimo di 1 nel formato double, e al valore 2^(Nbit-1)-1 nel formato
%native. I lavalier sono normalmente registrati a 16 o 24 bit

disp('Normalizing...')
fflush(stdout());
%normalizzazione
ynorm = double(yprenorm)/double(max(abs(yprenorm))) * (2^(Nbit-1)-1);
%casting
y = cast(ynorm, 'int16');



%figure
%subplot(2, 1, 1)
%plot(y, '.-')
%title('signal')
%%xlim([68315 68325])
%subplot(2, 1, 2)
%plot(abs(diff(y)), '.-')
%title('signal variation')
%%xlim([68315 68325])


%usare i percentili per individuare i punti di probabile clipping non ha
%senso, perché potrei avere un audio tutto silenzioso con una sola battuta
%e allora tutta la battuta sarebbe nel 95esimo percentile
%devo usare un criterio assoluto, legato alla quantizzazione

%peakthreshold e diffthreshold saranno le manopole del plugin

peakThreshold = 2^(Nbit-1) - 5000; %cerco attorno ai punti con almeno questa intensità
diffThreshold = 800; %ritengo che un punto sia clippato se differisce di così poco dal precedente
numThreshold = 3; %e se questo succede per almeno numthreshold punti di fila



windowSize = 20;


%%

ii = 1;
Ny = length(y);

clippedSamples = zeros(size(y));
clippedSamples(:) = NaN;

yclean = cast(y, 'double');

disp('Declipping')
fflush(stdout());
%hwb = waitbar(0, '0.00%%');
while (ii<=Ny)
    if (abs(y(ii)) > peakThreshold)
        secStart = ii;
        secCount = 0;
        while ( (ii < Ny-diffThreshold) && ...
                (abs(y(ii)) > peakThreshold) && ...
                (abs(y(ii+1) - y(ii)) < diffThreshold) )
            ii = ii+1;
            secCount = secCount+1;
        end
        if (secCount >= numThreshold)
            clippedSamples(secStart:secStart + secCount) = y(secStart:secStart + secCount); 
            filteringArea = y(secStart-2:secStart+secCount+2);
            filteringArea = cast(filteringArea, 'double');
            filteringArea(3:end-2) = NaN;
            filteringArea = peak_restore(filteringArea);
            yclean(secStart-2:secStart+secCount+2) = filteringArea;
            %averaging at the extremities for better matching
          %  yclean(secStart-2:secStart-1) = 0.5*(yclean(secStart-2:secStart-1)+...
          %                                      y(secStart-2:secStart-1));
          %  yclean(secStart+secCount+1:secStart+secCount+2) = 0.5*(yclean(secStart+secCount+1:secStart+secCount+2)+...
          %                                                          y(secStart+secCount+1:secStart+secCount+2));
        end
    end
    ii = ii+1;
   % waitbar(ii/Ny, hwb, sprintf('%.2f%%',100*ii/Ny));
end

%%
%ricostruzione
%y = fillgaps(double(y), 1000);
%normalizzazione
yclean = yclean/max(abs(yclean)) * (2^(Nbit-1)-1);
%casting
yclean = cast(yclean, 'int16');

%p_clean = audioplayer(yclean, Fs);
%play(p_clean);

numClippedSamples = sum(~isnan(clippedSamples));
printf('There were %i clipped samples on a total %i samples, %d%% \n', ...
          numClippedSamples, Ny, 100*numClippedSamples/Ny);

disp('Exporting...')
fflush(stdout());
mkdir clean;
audiowrite(['clean/' fileName], yclean, Fs);

timeElapsed = toc;
printf('Time elapsed = %i /// %.1fx faster than realtime \n', timeElapsed, Ny/Fs/timeElapsed);     
%figure
%subplot(2, 1, 1)
%plot(yclean, '.-')
%title('processed signal')
%hold on
%plot(clippedSamples, 'k.-');
%%xlim([68315 68325])
%subplot(2, 1, 2)
%%plot(abs(diff(y)), '.-')
%plot(yclean-y)
%title('processed-raw signal')
%%xlim([68315 68325])
