// ----------------------------------------
// KARPLUS STRONG
// ----------------------------------------

// Importo libreria standard di FAUST
import("stdfaust.lib");



/* 
Algoritmo di simulazione della corda 
secondo il modello KARPLUS STRONG
con IMPULSO DI DIRAC come eccitatore 
attenuato da filtro ONEPOLE
*/



eccitator(impsamples,implowc,gimp) = opfdirac
with{ 
    // DIRAC --> ONEPOLE LOWPASS
    diracvariable = 1-1@(impsamples);
    opfdirac = diracvariable*implowc : +~(_ : *(1- implowc));
    gainout = opfdirac*gimp;
};

resonator(delfreq,feedback,lowpass) = lfbcf
with{ 
    // LOWPASS FEEDBACK COMB FILTER
    lfbcf = (+ : @(ma.SR/(delfreq-1)) : 
    _*lowpass : +~(_ : *(1-lowpass)))~ *(feedback) : mem;
};

// KARPLUS STRONG FUNCTION
kstrongpow(gain,impsamp,impcut,freq,fb,lowcut) = 
eccitator(impsamp,impcut,gain) : 
resonator(freq,fb,lowcut) :
fi.dcblocker;


// (gain,impinsamples,impucut(0-1),frequency,feedback(0-1),resoncut(0-1)) 
process = kstrongpow(0.5,300,0.9,261.6,0.99,0.6) <:_,_;