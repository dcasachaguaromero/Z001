FUNCTION ZFI_F4_CURTP.
*"--------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_XSHOW) LIKE  RFCU4-FLAGX DEFAULT SPACE
*"     VALUE(I_XCT10) LIKE  RFCU4-FLAGX DEFAULT SPACE
*"     VALUE(I_XCT00) LIKE  RFCU4-FLAGX DEFAULT SPACE
*"  EXPORTING
*"     VALUE(E_CURTP) LIKE  T001A-CURTP
*"--------------------------------------------------------------------

  DATA: CURTP_VALUE LIKE DD07L-DOMVALUE_L.       " Domänenfestwert

*------- Initialisierung -----------------------------------------------
  CLEAR E_CURTP.

*------- FLDTAB füllen -------------------------------------------------
  REFRESH FLDTAB.
  CLEAR FLDTAB.
  FLDTAB-TABNAME    = 'T001A'.
  FLDTAB-FIELDNAME  = 'CURTP'.
  FLDTAB-SELECTFLAG = 'X'.
  APPEND FLDTAB.
  CLEAR FLDTAB.
  FLDTAB-TABNAME    = 'DD07T'.
  FLDTAB-FIELDNAME  = 'DDTEXT'.
  APPEND FLDTAB.

*------- CTPTAB füllen -------------------------------------------------
  DESCRIBE TABLE CTPTAB LINES SY-TFILL.
  IF SY-TFILL = 0.

*------- ... Währungstyp 00 gewünscht? ---------------------------------
    IF I_XCT00 <> SPACE.
      CTPTAB-CURTP = '00'.
      APPEND CTPTAB.
      CURTP_VALUE = '00'.
      PERFORM CURTP_TEXT_LESEN USING CURTP_VALUE CTPTAB-CURTP.
      APPEND CTPTAB.
    ENDIF.

*------- ... Währungstyp 10 gewünscht? ---------------------------------
    IF I_XCT10 <> SPACE.
      CTPTAB-CURTP = '10'.
      APPEND CTPTAB.
      CURTP_VALUE = '10'.
      PERFORM CURTP_TEXT_LESEN USING CURTP_VALUE CTPTAB-CURTP.
      APPEND CTPTAB.
    ENDIF.

*------- ... Währungstyp 30,40,50,60 -----------------------------------
*                        11,31,12,32
    CTPTAB-CURTP = '11'.
    APPEND CTPTAB.
    CURTP_VALUE = '11'.
    PERFORM CURTP_TEXT_LESEN USING CURTP_VALUE CTPTAB-CURTP.
    APPEND CTPTAB.
    CTPTAB-CURTP = '12'.
    APPEND CTPTAB.
    CURTP_VALUE = '12'.
    PERFORM CURTP_TEXT_LESEN USING CURTP_VALUE CTPTAB-CURTP.
    APPEND CTPTAB.
    CTPTAB-CURTP = '30'.
    APPEND CTPTAB.
    CURTP_VALUE = '30'.
    PERFORM CURTP_TEXT_LESEN USING CURTP_VALUE CTPTAB-CURTP.
    APPEND CTPTAB.
    CTPTAB-CURTP = '31'.
    APPEND CTPTAB.
    CURTP_VALUE = '31'.
    PERFORM CURTP_TEXT_LESEN USING CURTP_VALUE CTPTAB-CURTP.
    APPEND CTPTAB.
    CTPTAB-CURTP = '32'.
    APPEND CTPTAB.
    CURTP_VALUE = '32'.
    PERFORM CURTP_TEXT_LESEN USING CURTP_VALUE CTPTAB-CURTP.
    APPEND CTPTAB.
    CTPTAB-CURTP = '40'.
    APPEND CTPTAB.
    CURTP_VALUE = '40'.
    PERFORM CURTP_TEXT_LESEN USING CURTP_VALUE CTPTAB-CURTP.
    APPEND CTPTAB.
    CTPTAB-CURTP = '50'.
    APPEND CTPTAB.
    CURTP_VALUE = '50'.
    PERFORM CURTP_TEXT_LESEN USING CURTP_VALUE CTPTAB-CURTP.
    APPEND CTPTAB.
    CTPTAB-CURTP = '60'.
    APPEND CTPTAB.
    CURTP_VALUE = '60'.
    PERFORM CURTP_TEXT_LESEN USING CURTP_VALUE CTPTAB-CURTP.
    APPEND CTPTAB.
  ENDIF.

*------- Währungstypen anzeigen ----------------------------------------
  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE'
       EXPORTING
            DISPLAY      = I_XSHOW
            FIELDNAME    = 'CURTP'
            TABNAME      = 'T001A'
       IMPORTING
            SELECT_VALUE = E_CURTP
       TABLES
            FIELDS       = FLDTAB
            VALUETAB     = CTPTAB.

ENDFUNCTION.
