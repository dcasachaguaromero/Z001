
SELECT SINGLE cccategory FROM t000 INTO sysinfo-system
WHERE mandt = sy-mandt.

*Ausgabe nicht in Prod.
IF sysinfo-system = 'P'.
CLEAR sysinfo-system.
ENDIF.

SELECT SINGLE fonam sform pgnam FROM tnapr INTO (sysinfo-fonam,
sysinfo-sform,
sysinfo-pgnam)
WHERE kschl = is_nast-kschl
AND nacha = is_nast-nacha
AND kappl = is_nast-kappl.

GET PARAMETER ID 'FOM' FIELD sysinfo-param.

























