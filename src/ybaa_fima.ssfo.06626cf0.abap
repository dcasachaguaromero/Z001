
clear SUMTAB.
h_f150d = f150d.
if f150d-mhngf ne 0.
h_f150d-waerf = t047c-waers.
h_f150d-waerh = t001-waers.

sumtab-waers = f150d-waerf.
sumtab-wrshb = f150d-mhngf.
sumtab-ffshb = f150d-mhngf.
if f150d-waerf = f150d-waerh.
sumtab-dmshb = f150d-mhngh.
sumtab-fhshb = f150d-mhngf.
else.
sumtab-dmshb = f150d-mhngh.
sumtab-fhshb = f150d-mhngh.
endif.
collect sumtab into t_sumtab.
endif.












