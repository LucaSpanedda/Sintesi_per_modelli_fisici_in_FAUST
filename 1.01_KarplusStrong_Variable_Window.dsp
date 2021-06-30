// ----------------------------------------
// KARPLUS STRONG VARIABLE WINDOW
// ----------------------------------------

// Importo libreria standard di FAUST
import("stdfaust.lib");



/* 
Algoritmo di simulazione della corda 
secondo il modello KARPLUS STRONG
con finestra triangolare variabile con
controllo della potenza (POW)
*/



eccitator(frequency,powwindow) = outeccitator
with{ 
    // NOISE GENERATION
    random  = +(12345)~*(1103515245);
    noise   = random/2147483647.0;
    // TRIANG WINDOW FOR THE NOISE WITH POW
    decimale(x)= x-int(x);
    phase = (frequency/ma.SR : (+ : decimale) ~ _)-0.5;
    phasorscaleneg = (((phase > 0)*phase)*-1);
    phasorneg = ((phase < 0)*phase);
    phasesum = ((phasorneg+phasorscaleneg)+0.5)*2;
    phasepow = phasesum: pow(powwindow);
    outeccitator = noise*phasepow;
};

resonator(delfreq,feedback,lowpass) = lfbcf
with{ 
    // LOWPASS FEEDBACK COMB FILTER
    lfbcf = (+ : @(ma.SR/(delfreq-1)) : 
    _*lowpass : +~(_ : *(1-lowpass)))~ *(feedback) : mem;
};

// KARPLUS STRONG FUNCTION WITH WINDOW
kstrongpow(fimp,windimp,freq,fb,lowcut) = 
eccitator(fimp,windimp) : 
resonator(freq,fb,lowcut) : 
fi.dcblocker;

// (impulse-freq,window(0-1000),frequency,feedback(0-1),lowcut(0-1)) 
process = kstrongpow(0.5,800,261.6/2,0.999,0.4) <:_,_;