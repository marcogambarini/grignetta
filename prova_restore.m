clc, clear all, close all

[y, Fs] = audioread('esempio_norm_0.wav', 'native');
%[y, Fs] = audioread('esempio_norm_-1.wav', 'native');
p = audioplayer(y, Fs);
%play(p);
Nbit = 16;

%qui lavoro su audio già normalizzato a 0dB, che corrisponde a un valore
%massimo di 1 nel formato double, e al valore 2^(Nbit-1)-1 nel formato
%native. I lavalier sono normalmente registrati a 16 o 24 bit

%per normalizzare dovrei applicare un gain (moltiplicare tutti i valori per
%una costante) pari al valore massimo rappresentabile diviso per il valore
%massimo nel segnale, e poi quantizzare il risultato. questo non è banale!
%(dithering?)

figure
subplot(2, 1, 1)
plot(y, '.-')
%xlim([68315 68325])
subplot(2, 1, 2)
plot(abs(diff(y)), '.-')
%xlim([68315 68325])


%usare i percentili per individuare i punti di probabile clipping non ha
%senso, perché potrei avere un audio tutto silenzioso con una sola battuta
%e allora tutta la battuta sarebbe nel 95esimo percentile
%devo usare un criterio assoluto, legato alla quantizzazione

%peakthreshold e diffthreshold saranno le manopole del plugin

peakThreshold = 2^(Nbit-1) - 2000; %cerco attorno ai punti con almeno questa intensità
diffThreshold = 800; %ritengo che un punto sia clippato se differisce di così poco dal precedente
numThreshold = 3; %e se questo succede per almeno numthreshold punti di fila

%per evitare di applicare l'autoregressione su tutto il segnale (che
%sarebbe inutile) spezzo il segnale di partenza attorno ai punti che vanno
%puliti, ma a questo penserò dopo

%analizzare sempre i tempi con tic toc per capire se sto davvero
%migliorando o se sono solo paranoie

windowSize = 20;


%%

ii = 1;
Ny = length(y);

clippedSamples = zeros(size(y));
clippedSamples(:) = NaN;

yclean = cast(y, 'double');

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
        end
    end
    ii = ii+1;
end

%%
%ricostruzione
%y = fillgaps(double(y), 1000);
%normalizzazione
yclean = yclean/max(abs(yclean)) * (2^(Nbit-1)-1);
%casting
yclean = cast(yclean, 'int16');

p_clean = audioplayer(yclean, Fs);
play(p_clean);

figure
subplot(2, 1, 1)
plot(yclean, '.-')
hold on
plot(clippedSamples, 'k.-');
%xlim([68315 68325])
subplot(2, 1, 2)
%plot(abs(diff(y)), '.-')
plot(yclean-y)
%xlim([68315 68325])
