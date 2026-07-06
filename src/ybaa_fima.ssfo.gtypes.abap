
types:   BEGIN OF th_SALTAB,
WAERS   LIKE MHND-WAERS,
WRSHB   LIKE F150D-SALFW,
DMSHB   LIKE F150D-SALHW,
END OF th_SALTAB,
tt_saltab type standard table of th_saltab.

*------- Summe der gedruckten Posten ----------------------------
types:   BEGIN OF th_SUMTAB,
WAERS   LIKE MHND-WAERS,
WRSHB   LIKE MHND-WRSHB,
DMSHB   LIKE MHND-DMSHB,
FFSHB   LIKE MHND-WRSHB,    "Faellige Posten in FW
FHSHB   LIKE MHND-WRSHB,    "Faellige Posten in HW
WZSBT   LIKE MHND-WZSBT,    "Zinsen in FW
ZSBTR   LIKE MHND-ZSBTR,    "Zinsen in HW
END OF th_SUMTAB,
tt_sumtab type standard table of th_sumtab.

*Test system fields
TYPES: BEGIN OF sysinfo,
system       TYPE	cccategory,
fonam	       TYPE	na_fname,
sform	       TYPE	na_fname,
pgnam	       TYPE	na_pgnam,
param    	TYPE	char1,
END OF sysinfo.




























