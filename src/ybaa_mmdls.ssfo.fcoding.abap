*&--------------------------------------------------------------------*
*&      Form  GET_PRINT_LANGUAGE
*&--------------------------------------------------------------------*
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
FORM GET_PRINT_LANGUAGE
USING     IS_CONTROL_PARAMETERS TYPE SSFCTRLOP
CHANGING  CV_LANGUAGE TYPE DDLANGUAGE.

IF IS_CONTROL_PARAMETERS-LANGU IS INITIAL.
CV_LANGUAGE = SY-LANGU.
ELSE.
CV_LANGUAGE = IS_CONTROL_PARAMETERS-LANGU.
ENDIF.

ENDFORM.                    "GET_PRINT_LANGUAGE
*&--------------------------------------------------------------------*
*&      Form  GET_VENDER_LAND
*&--------------------------------------------------------------------*
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
FORM GET_VENDER_LAND
USING     IS_EKKO TYPE EKKO
IS_NAST TYPE NAST
CHANGING  CV_VENDER_LAND.

DATA L_LFA1 LIKE LFA1.
DATA L_LFM1 LIKE LFM1.

IF  IS_NAST-PARNR NE SPACE AND
IS_NAST-PARNR NE IS_EKKO-LIFNR.
SELECT SINGLE LAND1 FROM LFA1 INTO CV_VENDER_LAND
WHERE LIFNR = IS_NAST-PARNR.
ELSE.
"--Get address number from table LFA1--
SELECT SINGLE LAND1 FROM LFA1 INTO CV_VENDER_LAND

WHERE LIFNR = IS_EKKO-LIFNR.
ENDIF.
ENDFORM.                    "GET_VENDER_LAND
*&--------------------------------------------------------------------*
*&      Form  GET_CUR_DECIMAL_FLAG
*&--------------------------------------------------------------------*
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
FORM     GET_CUR_DECIMAL_FLAG
USING     IV_WAERS TYPE WAERS
CHANGING  CV_FLAG  TYPE C.
DATA LS_TCURX TYPE TCURX.
SELECT SINGLE * FROM TCURX INTO LS_TCURX
WHERE CURRKEY = IV_WAERS.
IF SY-SUBRC = 0.
CV_FLAG = 'X'.

ELSE.
CLEAR CV_FLAG.
ENDIF.

ENDFORM.                    "GET_CUR_DECIMAL_FLAG
*&--------------------------------------------------------------------*
*&      Form  GET_STO_FLAG
*&--------------------------------------------------------------------*
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*

FORM GET_STO_FLAG
USING IS_EKKO TYPE EKKO
CHANGING CV_STO_FLAG.
CHECK IS_EKKO-BSTYP EQ 'F'.
DATA: LS_BREFN TYPE BREFN.
SELECT SINGLE BREFN FROM T161
INTO LS_BREFN WHERE BSART EQ IS_EKKO-BSART.
IF SY-SUBRC EQ 0.
IF LS_BREFN EQ 'UBF'.
CV_STO_FLAG = 'X'.
ELSE.
CLEAR CV_STO_FLAG.
ENDIF.
ENDIF.
ENDFORM.                    "GET_STO_FLAG
*----------------------------------------------------------------------*
*      Form  GET_VARIANT_DESC                                          *
*----------------------------------------------------------------------*
*      determine description of a variant condition                    *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM GET_VARIANT_DESC
USING    IV_SPRAS TYPE SYLANGU
IV_KNUMH TYPE KNUMB
CHANGING CS_BEZEI TYPE VTXTK.

CLEAR CS_BEZEI.

DATA: BEGIN OF LT_VCONDTEXT OCCURS 1.
INCLUDE STRUCTURE VCONDTEXT.
DATA: END OF LT_VCONDTEXT.

* initialize and assign values
REFRESH LT_VCONDTEXT.
CLEAR   LT_VCONDTEXT.
LT_VCONDTEXT-KNUMH = IV_KNUMH.
APPEND LT_VCONDTEXT.

* determine description of variant conditin (kntyp = 'O')
CALL FUNCTION 'RV_GET_VARCOND_DESCR'
EXPORTING
LANGUAGE            = IV_SPRAS
TABLES
CONDITION_TEXT      = LT_VCONDTEXT
EXCEPTIONS
COND_DOES_NOT_EXIST = 1.

IF SY-SUBRC = 0.
READ TABLE LT_VCONDTEXT INDEX 1.
IF SY-SUBRC = 0.
CS_BEZEI = LT_VCONDTEXT-VCTEXT.
ENDIF.
ENDIF.

ENDFORM.                    "GET_VARIANT_DESC


*&--------------------------------------------------------------------*
*&      Form  JUDGE_PRINT_INDICATOR
*&--------------------------------------------------------------------*
FORM JUDGE_PRINT_INDICATOR
USING     IS_KO             TYPE KOMV
IS_PREVIOUS_VALUE TYPE KWERT
CHANGING  CV_INDICATOR      TYPE XFLAG
.
* Printing at item level (previous procedure)
IF IS_KO-DRUKZ = 'X'.
CV_INDICATOR = 'X'.

* Printing at totals level (previous procedure)
ELSEIF IS_KO-DRUKZ = 'S'.
CV_INDICATOR = 'S'.

* Total: General
ELSEIF IS_KO-DRUKZ = 'A'.
CV_INDICATOR = 'S'.

* Total: if value <> zero
ELSEIF IS_KO-DRUKZ = 'B'.
IF IS_KO-KWERT <> 0.
CV_INDICATOR = 'S'.
ELSE.
CV_INDICATOR = ' '.
ENDIF.
* Total: if value <> previous value
ELSEIF IS_KO-DRUKZ = 'C'.
*    CHECK SY-INDEX NE 1.
IF IS_KO-KWERT <> IS_PREVIOUS_VALUE.
CV_INDICATOR = 'S'.
ELSE.
CV_INDICATOR = ' '.
ENDIF.

* Total: if value <> zero and value <> previous value
ELSEIF IS_KO-DRUKZ = 'D'.
*    CHECK SY-INDEX NE 1.
IF IS_KO-KWERT <> IS_PREVIOUS_VALUE
AND IS_KO-KWERT <> 0
.
CV_INDICATOR = 'S'.
ELSE.
CV_INDICATOR = ' '.
ENDIF.

* at item: General
ELSEIF IS_KO-DRUKZ = 'a'.
CV_INDICATOR = 'X'.

* at item: if value <> zero
ELSEIF IS_KO-DRUKZ = 'b'.
IF IS_KO-KWERT <> 0.
CV_INDICATOR = 'X'.
ELSE.
CV_INDICATOR = ' '.
ENDIF.

*  at item: if value <> previous value
ELSEIF IS_KO-DRUKZ = 'c'.
*    CHECK SY-TABIX NE 1.
IF IS_KO-KWERT <> IS_PREVIOUS_VALUE.
CV_INDICATOR = 'X'.
ELSE.
CV_INDICATOR = ' '.
ENDIF.

*  at item: if value <> zero and value <> previous value
ELSEIF IS_KO-DRUKZ = 'd'.
*    CHECK SY-INDEX NE 1.
IF IS_KO-KWERT <> IS_PREVIOUS_VALUE
AND IS_KO-KWERT <> 0.
CV_INDICATOR = 'X'.
ELSE.
CV_INDICATOR = ' '.
ENDIF.

ELSE.
CV_INDICATOR = ' '.
ENDIF.

ENDFORM.                    "JUDGE_PRINT_INDICATOR

*&---------------------------------------------------------------------*
*&      Form  GET_PLANT_ADDRESS
*&---------------------------------------------------------------------*
FORM GET_PLANT_ADDRESS USING    IS_WERKS LIKE T001W-WERKS
CHANGING CV_ADRNR
CS_SADR LIKE SADR.

* parameter cv_adrnr without type since there are several address
* fields with different domains

DATA: L_EKKO LIKE EKKO,
L_ADDRESS LIKE ADDR1_VAL.

CHECK NOT IS_WERKS IS INITIAL.
L_EKKO-RESWK = IS_WERKS.
L_EKKO-BSAKZ = 'T'.
CALL FUNCTION 'MM_ADDRESS_GET'
EXPORTING
I_EKKO    = L_EKKO
IMPORTING
E_ADDRESS = L_ADDRESS
E_SADR    = CS_SADR.
CV_ADRNR = L_ADDRESS-ADDRNUMBER.

ENDFORM.                               " GET_PLANT_ADDRESS

*&---------------------------------------------------------------------*
*&      Form  GET_VENDOR_ADDRESS
*&---------------------------------------------------------------------*
FORM GET_VENDOR_ADDRESS USING    IS_EMLIF LIKE LFA1-LIFNR
CHANGING CV_ADRNR.
* parameter cv_adrnr without type since there are several address
* fields with different domains

DATA: L_LFA1 LIKE LFA1.

CHECK NOT IS_EMLIF IS INITIAL.
CALL FUNCTION 'VENDOR_MASTER_DATA_SELECT_00'
EXPORTING
I_LFA1_LIFNR     = IS_EMLIF
I_DATA           = 'X'
I_PARTNER        = ' '
IMPORTING
A_LFA1           = L_LFA1
EXCEPTIONS
VENDOR_NOT_FOUND = 1.
IF SY-SUBRC EQ 0.
CV_ADRNR = L_LFA1-ADRNR.
ELSE.
CLEAR CV_ADRNR.
ENDIF.

ENDFORM.                               " GET_VENDOR_ADDRESS

*&---------------------------------------------------------------------*
*&      Form  GET_CUSTOMER_ADDRESS
*&---------------------------------------------------------------------*
FORM GET_CUSTOMER_ADDRESS USING    IS_KUNNR LIKE EKPO-KUNNR
CHANGING CV_ADRNR.
* parameter cv_adrnr without type since there are several address
* fields with different domains

DATA: L_ADRNR LIKE KNA1-ADRNR.

CHECK NOT IS_KUNNR IS INITIAL.
SELECT SINGLE ADRNR FROM  KNA1 INTO (L_ADRNR)
WHERE  KUNNR  = IS_KUNNR.
IF SY-SUBRC EQ 0.
CV_ADRNR = L_ADRNR.
ELSE.
CLEAR CV_ADRNR.
ENDIF.

ENDFORM.                               " GET_CUSTOMER_ADDRESS

*&---------------------------------------------------------------------*
*&      Form  ERGAENZEN_XAEND
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM  ERGAENZEN_XAEND
USING    IS_EKPO  TYPE EKPO
IS_PEKPO TYPE PEKPO
IS_EKKO  TYPE EKKO
CHANGING CT_XAEND TYPE TY_MEEIN_XAEND_TAB.

DATA LV_INSERT.
DATA LV_H_IND   LIKE SY-TABIX.
DATA LS_XAEND   TYPE TY_MEEIN_XAEND.

LOOP AT CT_XAEND INTO LS_XAEND WHERE EBELP EQ IS_PEKPO-EBELP.
LV_H_IND = SY-TABIX.

" Sonderbearbeitung ------------------
" neue Position ----------------------
IF LS_XAEND-INSERT NE SPACE.
LV_INSERT = 'X'.
LS_XAEND-TEXT_CASE = 'X'.
MODIFY CT_XAEND FROM LS_XAEND.
EXIT.
ENDIF.
CHECK LS_XAEND-ROUNR NE 0.
CASE LS_XAEND-ROUNR.
" Einteilungsaenderung ---------------
WHEN 1.
IF IS_PEKPO-EINDT NE 0.
LS_XAEND-CTXNR = 'S1-1'.
ELSE.
LS_XAEND-CTXNR = 'S1-2'.
ENDIF.
" Zielmenge/Anfragemenge -------------
WHEN 2.
IF IS_EKKO-BSTYP EQ 'A'.
LS_XAEND-CTXNR = 'S2-A'.
ELSE.
LS_XAEND-CTXNR = 'S2-R'.
ENDIF.
" Loeschkennzeichen ------------------
WHEN 3.
CASE IS_EKPO-LOEKZ.
WHEN 'L'.
LS_XAEND-CTXNR = 'S3-L'.
WHEN 'S'.
LS_XAEND-CTXNR = 'S3-S'.
WHEN ' '.
LS_XAEND-CTXNR = 'S3-X'.
ENDCASE.
ENDCASE.
MODIFY CT_XAEND FROM LS_XAEND INDEX LV_H_IND.
ENDLOOP.
IF SY-SUBRC EQ 0 AND NOT IS_EKPO-UEBPO IS INITIAL.
READ TABLE CT_XAEND WITH KEY EBELP = IS_EKPO-UEBPO
BINARY SEARCH TRANSPORTING NO FIELDS.
IF SY-SUBRC NE 0.
CLEAR LS_XAEND.
LS_XAEND-EBELP = IS_EKPO-UEBPO.
INSERT LS_XAEND INTO  CT_XAEND INDEX SY-TABIX.
ENDIF.
ENDIF.

" bei neuer Position keine anderen Änderungen drucken --
IF LV_INSERT NE SPACE.
LOOP AT CT_XAEND INTO LS_XAEND
WHERE EBELP  EQ IS_PEKPO-EBELP
AND   INSERT EQ SPACE.
DELETE CT_XAEND.
ENDLOOP.
ENDIF.

ENDFORM.                    "ERGAENZEN_XAEND













