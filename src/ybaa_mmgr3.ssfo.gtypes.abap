
types: begin of s_traptab  .
include structure mseg.
types:
vgart like mkpf-vgart,
blart like mkpf-blart,
blaum like mkpf-blaum,
bldat like mkpf-bldat,
budat like mkpf-budat,
cpudt like mkpf-cpudt,
cputm like mkpf-cputm,
aedat like mkpf-aedat,
usnam like mkpf-usnam,
tcode like mkpf-tcode,
xblnr like mkpf-xblnr,
bktxt like mkpf-bktxt,
frath like mkpf-frath,
frbnr like mkpf-frbnr,
wever like mkpf-wever,
end of s_traptab.

*Test system fields
TYPES: BEGIN OF sysinfo,
system       TYPE	cccategory,
fonam	       TYPE	na_fname,
sform	       TYPE	na_fname,
pgnam	       TYPE	na_pgnam,
param    	TYPE	char1,
END OF sysinfo.








