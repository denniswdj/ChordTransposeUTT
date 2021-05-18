clc
clear all

%% Pre - processing
generator = input('Please input the generating element candidate: ','s');

x = strsplit(generator,{'<',',','>'});
x1 = x(2); x2 = str2double(x(3)); x3 = str2double(x(4));
if x1 == "+"
        x1 = 0;
    else
        x1 = 1;
end
   
TTS_Triad(1,1) = x1; TTS_Triad(1,2) = x2; TTS_Triad(1,3) = x3;

i = 1; j = 2; 

while TTS_Triad(i,1) ~= 0 || TTS_Triad(i,2) ~= 0 || TTS_Triad(i,3) ~= 0 
    [z1,z2,z3] = composition(TTS_Triad(j-1,1),TTS_Triad(j-1,2),TTS_Triad(j-1,3),TTS_Triad(1,1),TTS_Triad(1,2),TTS_Triad(1,3));
    i = i + 1;
    TTS_Triad(i,1) = z1;
    TTS_Triad(i,2) = z2;
    TTS_Triad(i,3) = z3;
    j = j + 1;
end

for a = 1 : i %Generate chord di matriks TTS_Triad mulai dari C
    [r,sigma] = UTTransformation(TTS_Triad(a,1),TTS_Triad(a,2),TTS_Triad(a,3),0,0);
    TTS_Triad(a,4) = r; TTS_Triad(a,5) = sigma;
end

%% Program Utama
if i == 24
    sprintf('%s GENERATES SUCCESSFULLY',generator)
    
    nadaDasarAwal = input('Input initial basic tone: ','s');
    [rAwal, sigmaAwal] = numberChord(char(nadaDasarAwal));
    
    chordString = input('Input chord sequence: ','s');
    
    nadaDasarTujuan = input('Input basic tone target: ','s');
    [rAkhir, sigmaAkhir] = numberChord(char(nadaDasarTujuan));
    tic;
    chordArray = strsplit(chordString, ' ');
    
    banyakLangkah = mod(Langkah(rAkhir,sigmaAkhir,TTS_Triad) - Langkah(rAwal,sigmaAwal,TTS_Triad),24);
    
    for i = 1:length(chordArray)
        %Konversi chord ke number chord
        chord = chordArray(i); 
        [r,sigma] = numberChord(char(chord));
        B(i,1) = r; B(i,2) = sigma;
        
        %Chord hasil transposisi ada di langkah berapa
        k = Langkah(B(i,1),B(i,2),TTS_Triad);
        Posisi(1,i) = Langkah(B(i,1),B(i,2),TTS_Triad);
        k = mod(k + banyakLangkah,24);
        if k == 0 
            k = 24;
        end
        C(i) = k ;
        Posisi(2,i) = k;
    end
    
    
    for i = 1:length(chordArray)
        [r,sigma] = UTTransformation( TTS_Triad(C(i),1) , TTS_Triad(C(i),2) , TTS_Triad(C(i),3) , 0 , 0 );
        D(i,1) = r;
        D(i,2) = sigma; 
        
        %Konversi triad ke chord, taruh di array Final
        Final(i) = alphabetChord(D(i,1),D(i,2));
    end
     
    textAkhir = '';
    for i = 1:length(chordArray)
        textAkhir = textAkhir + Final(i) + ' ';
    end
    fprintf("Transposition result: %s",textAkhir)
else
    fprintf('%s DOES NOT GENERATE SUCCESSFULLY',generator)
end
toc;

%% Komposisi UTT
function [z1,z2,z3] = composition(a,b,c,d,e,f) 
    if a == 0
        z2 = mod(b + e, 12);
        z3 = mod(c + f, 12);
    else
        z2 = mod(b + f, 12);
        z3 = mod(c + e, 12);
    end
    
    z1 = mod(a + d, 2);
end

%% Konversi Chord ke bentuk Triad
function [r,sigma] = numberChord(x)
    if length(x) == 3
        sigma = 1; %1 minus (minor)
        chord_simple = x(1:2);
    elseif length(x) == 2
        if x(2:2) == 'm'
            sigma = 1; 
            chord_simple = x(1:1);
        else
            sigma = 0;
            chord_simple = x;
        end
    else
        sigma = 0 ;
        chord_simple = x; 
    end

    switch chord_simple
        case 'C'
            r = 0;
        case {'C#','Db'}
            r = 1;
        case 'D'
            r = 2;
        case {'D#','Eb'}
            r = 3;
        case 'E'
            r = 4;
        case 'F'
            r = 5;
        case {'F#','Gb'}
            r = 6;
        case 'G'
            r = 7;
        case {'G#','Ab'}
            r = 8;
        case 'A'
            r = 9;
        case {'A#','Bb'}
            r = 10;
        case 'B'
            r = 11;    
        otherwise
            warning('No chord available')
    end
end

%% Konversi Triad ke Chord

function x = alphabetChord(r,sigma)
    if sigma == 1
        text2 = 'm';
    else
        text2 = '';
    end
    
    switch r
        case 0
            text1 = 'C';
        case 1
            text1 = 'C#';
        case 2
            text1 = 'D';
        case 3
            text1 = 'D#';
        case 4
            text1 = 'E';
        case 5
            text1 = 'F';
        case 6
            text1 = 'F#';
        case 7
            text1 = 'G';
        case 8
            text1 = 'G#';
        case 9
            text1 = 'A';
        case 10
            text1 = 'A#';
        case 11
            text1 = 'B';
        case 12
            text1 = 'C';
    end
    
    x = string(strcat(text1,text2)); %strcat: ngubah '...' jadi "...". string utk masuk ke array
end

%% UTT
function [r,sigma] = UTTransformation(a,b,c,d,e) %<a,b,c>(d,e) = ...
    if e == 0 
        r = mod(d + b,12);
    else
        r = mod(d + c,12);
    end
    
    if a == 0
        sigma = e;
    else
        sigma = mod(e + 1,2);
    end
end

function i = Langkah(rCek,sigmaCek,TTS_Triad)
    for i = 1:24
        if rCek == TTS_Triad(i,4)
            if sigmaCek == TTS_Triad(i,5)
                break
            end
        end
    end
end
