

SELECT SINGLE cccategory FROM t000 INTO sysinfo-system
WHERE mandt = sy-mandt.

*Ausgabe nicht in Prod.
IF sysinfo-system = 'P'.
CLEAR sysinfo-system.
ENDIF.


GET PARAMETER ID 'FOM' FIELD sysinfo-param.

























