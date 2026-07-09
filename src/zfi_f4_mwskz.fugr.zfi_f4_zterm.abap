*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
FUNCTION ZFI_F4_ZTERM.
*"--------------------------------------------------------------------
*"*"Interfase global
*"  IMPORTING
*"     VALUE(I_KOART) LIKE  T052-KOART DEFAULT SPACE
*"     VALUE(I_ZTERM) LIKE  T052-ZTERM DEFAULT SPACE
*"     VALUE(I_XSHOW) LIKE  RFCU4-FLAGX DEFAULT SPACE
*"     VALUE(I_ZTYPE) LIKE  RFCU4-CHAR1 DEFAULT SPACE
*"  EXPORTING
*"     VALUE(E_ZTERM) LIKE  T052-ZTERM
*"  EXCEPTIONS
*"      NOTHING_FOUND
*"--------------------------------------------------------------------

*------- Einzelfelder --------------------------------------------------
  DATA:  TFILL LIKE SY-TFILL.              " Anzahl Zeilen in Tabelle

  SET LANGUAGE SY-LANGU.                   " Note 608998

*------- Initialisierung -----------------------------------------------
  CLEAR: E_ZTERM.
  IF I_ZTYPE NA ' RN'.
    I_ZTYPE = SPACE.
  ENDIF.

*------- XT052 und ZBTXT füllen ----------------------------------------
  PERFORM XT052_FUELLEN.
  PERFORM ZBTXT_FUELLEN.

*------- Eingabemöglichkeiten vorhanden? -------------------------------
  DESCRIBE TABLE ZBTXT LINES TFILL.
  IF TFILL = 0.
    MESSAGE S406 RAISING NOTHING_FOUND.
    EXIT.
  ENDIF.
* ------ SACC
  DATA:   LT_ZBTXT  LIKE ZBTXT OCCURS 2 WITH HEADER LINE.
  DATA: LD_ZTERM TYPE DZTERM.
  REFRESH FLDTAB.
  PERFORM FLDTAB_EINTRAGEN USING 'T052'  'ZTERM' 'X'.
  PERFORM FLDTAB_EINTRAGEN USING 'T052U' 'TEXT1' ' '.
* ------ hide key field is case of multiple records for key field
  LT_ZBTXT[] = ZBTXT[].
  LOOP AT LT_ZBTXT.
    IF LT_ZBTXT-ZTERM <> LD_ZTERM.
      LD_ZTERM = LT_ZBTXT-ZTERM.
    ELSE.
      CLEAR LT_ZBTXT-ZTERM.
      MODIFY LT_ZBTXT.
    ENDIF.
  ENDLOOP.
  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      SELECTFIELD         = 'ZTERM'
      TITEL               = TEXT-027
      NO_PERS_HELP_SELECT = 'X'
      DISPLAY             = I_XSHOW                          "Note921077
    IMPORTING
      IND                 = SY-TABIX
    TABLES
      FIELDS              = FLDTAB
      FULL_TABLE          = LT_ZBTXT
    EXCEPTIONS
      OTHERS              = 4.
  IF SY-TABIX = 0.
* message
  ELSE.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
SORT ZBTXT .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
    READ TABLE ZBTXT INDEX SY-TABIX.
    E_ZTERM = ZBTXT-ZTERM.
  ENDIF.
*------- Koordinaten des Popups bestimmen ------------------------------
*    X1 = SY-CUCOL.
*    Y1 = SY-CUROW.
*    IF X1 >= SY-SCOLS.
*      X1 = 1.
*    ENDIF.
*    IF Y1 >= SY-SROWS.
*      Y1 = 1.
*    ENDIF.
*    X2 = X1 + 64.
*    IF TFILL > 15.
*      Y2 = Y1 + 17.
*    ELSE.
*      Y2 = Y1 + TFILL + 2.
*    ENDIF.
*
*------- Eingabemöglichkeiten anzeigen ---------------------------------
*    INCLUDE = 'LFHL2U04'.
*    CALL SCREEN 200
*         STARTING AT X1 Y1
*         ENDING   AT X2 Y2.
  ENDFUNCTION.
