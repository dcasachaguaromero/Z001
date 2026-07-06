DATA LS_EKET TYPE EKET.

CLEAR GV_DLV_CHTXT.

READ TABLE IT_EKET INTO LS_EKET
WITH KEY
EBELN = <FS>-EBELN
EBELP = <FS>-EBELP.

* In case a position has been delivered partially.
IF SY-SUBRC = 0 AND LS_EKET-WEMNG <> 0.
SELECT SINGLE CHTXT FROM  T166T
INTO   GV_DLV_CHTXT
WHERE  SPRAS  = IS_EKKO-SPRAS
AND    CTXNR  = 'P15'.

* If a position has been delivered completely, it is deleted
* from Xeket and therefore sy-subrc <> 0.
ELSEIF SY-SUBRC <> 0.
IF <FS>-PSTYP <> '6'.   "not text item
SELECT SINGLE CHTXT FROM  T166T
INTO   GV_DLV_CHTXT
WHERE  SPRAS  = IS_EKKO-SPRAS
AND    CTXNR  = 'P14'.
ENDIF.
ENDIF.

























