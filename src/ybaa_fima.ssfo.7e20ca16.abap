TABLES bseg.
TABLES bkpf.
TABLES bsec.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE * FROM bkpf INTO h_bkpf
*WHERE bukrs = mhnd-bbukrs
*AND   gjahr = mhnd-gjahr
*AND   belnr = mhnd-belnr.
*
* NEW CODE
SELECT *
UP TO 1 ROWS  FROM bkpf INTO h_bkpf
WHERE bukrs = mhnd-bbukrs
AND   gjahr = mhnd-gjahr
AND   belnr = mhnd-belnr ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE * FROM bseg INTO h_bseg
*WHERE bukrs = mhnd-bbukrs
*AND   gjahr = mhnd-gjahr
*AND   belnr = mhnd-belnr
*AND   buzei = mhnd-buzei.
*
* NEW CODE
SELECT *
UP TO 1 ROWS  FROM bseg INTO h_bseg
WHERE bukrs = mhnd-bbukrs
AND   gjahr = mhnd-gjahr
AND   belnr = mhnd-belnr
AND   buzei = mhnd-buzei ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

IF h_bseg-xcpdd NE space.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE * FROM bsec INTO h_bsec
*WHERE bukrs = mhnd-bbukrs
*AND   gjahr = mhnd-gjahr
*AND   belnr = mhnd-belnr
*AND   buzei = mhnd-buzei.
*
* NEW CODE
SELECT *
UP TO 1 ROWS  FROM bsec INTO h_bsec
WHERE bukrs = mhnd-bbukrs
AND   gjahr = mhnd-gjahr
AND   belnr = mhnd-belnr
AND   buzei = mhnd-buzei ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
ENDIF.
* ignore text if necessary
IF h_bseg-sgtxt(1) NE '*'.
h_bseg-sgtxt = space.
ELSE.
SHIFT  h_bseg-sgtxt LEFT BY 1 PLACES.
ENDIF.
