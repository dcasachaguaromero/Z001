TABLES bseg.
TABLES bkpf.
TABLES bsec.

SELECT SINGLE * FROM bkpf INTO h_bkpf
WHERE bukrs = mhnd-bbukrs
AND   gjahr = mhnd-gjahr
AND   belnr = mhnd-belnr.

SELECT SINGLE * FROM bseg INTO h_bseg
WHERE bukrs = mhnd-bbukrs
AND   gjahr = mhnd-gjahr
AND   belnr = mhnd-belnr
AND   buzei = mhnd-buzei.

IF h_bseg-xcpdd NE space.
SELECT SINGLE * FROM bsec INTO h_bsec
WHERE bukrs = mhnd-bbukrs
AND   gjahr = mhnd-gjahr
AND   belnr = mhnd-belnr
AND   buzei = mhnd-buzei.
ENDIF.
* ignore text if necessary
IF h_bseg-sgtxt(1) NE '*'.
h_bseg-sgtxt = space.
ELSE.
SHIFT  h_bseg-sgtxt LEFT BY 1 PLACES.
ENDIF.
