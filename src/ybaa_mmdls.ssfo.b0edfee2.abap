
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE cccategory FROM t000 INTO sysinfo-system
*WHERE mandt = sy-mandt.
*
* NEW CODE
SELECT cccategory
UP TO 1 ROWS  FROM t000 INTO sysinfo-system
WHERE mandt = sy-mandt ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

*Ausgabe nicht in Prod.
IF sysinfo-system = 'P'.
CLEAR sysinfo-system.
ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE fonam sform pgnam FROM tnapr INTO (sysinfo-fonam,
*sysinfo-sform,
*sysinfo-pgnam)
*WHERE kschl = is_nast-kschl
*AND nacha = is_nast-nacha
*AND kappl = is_nast-kappl.
*
* NEW CODE
SELECT fonam sform pgnam
UP TO 1 ROWS  FROM tnapr INTO (sysinfo-fonam,
sysinfo-sform,
sysinfo-pgnam)
WHERE kschl = is_nast-kschl
AND nacha = is_nast-nacha
AND kappl = is_nast-kappl ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

GET PARAMETER ID 'FOM' FIELD sysinfo-param.

























