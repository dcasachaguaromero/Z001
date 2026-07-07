DATA LS_LPEIN TYPE LPEIN.
DATA LS_T006 TYPE T006.

CLEAR GS_PRT_AUX.
***********************************************
***Get the output format of Schedule Date ****
* Formated date saved in variants
*   GS_PRT_AUX-LFDAT "Delivery Time
*   GS_PRT_AUX-PRITX "Date format (e.g Week/Day)

CALL FUNCTION 'PERIOD_AND_DATE_CONVERT_OUTPUT'
EXPORTING
INTERNAL_DATE      = <EK>-EINDT
INTERNAL_PERIOD    = <EK>-LPEIN
LANGUAGE           = IS_EKKO-SPRAS
COUNTRY            = GV_VENDER_LAND
IMPORTING
EXTERNAL_DATE      = GS_PRT_AUX-LFDAT
EXTERNAL_PERIOD    = LS_LPEIN
EXTERNAL_PRINTTEXT = GS_PRT_AUX-PRITX.

***********************************************
***Get right output quantity format

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE * FROM T006 INTO LS_T006
*WHERE MSEHI EQ <FS>-MEINS.       
*
* NEW CODE
SELECT *
UP TO 1 ROWS  FROM T006 INTO LS_T006
WHERE MSEHI EQ <FS>-MEINS ORDER BY PRIMARY KEY.       

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01"Order unit

***Scheduled Quantity => GS_PRT_AUX-PRMG1
WRITE <EK>-MENGE NO-SIGN DECIMALS LS_T006-DECAN
TO GS_PRT_AUX-PRMG1.

***Delivered Quantity => GS_PRT_AUX-PRMG3
WRITE <EK>-WEMNG NO-SIGN DECIMALS LS_T006-DECAN
TO GS_PRT_AUX-PRMG2.

***********************************************
***Get right output time format
CLEAR GV_PRT_TIME.
IF NOT <EK>-UZEIT IS INITIAL.
GV_PRT_TIME(2)   = <EK>-UZEIT(2).
GV_PRT_TIME+2(1) = ':'.
GV_PRT_TIME+3(2) = <EK>-UZEIT+2(2).
ENDIF.














































