*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
FUNCTION ZFI_F4_MWSKZ.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_KALSM) LIKE  T005-KALSM
*"     VALUE(I_STBUK) LIKE  BSEG-STBUK DEFAULT SPACE
*"     VALUE(I_XSHOW) LIKE  RFCU4-FLAGX DEFAULT SPACE
*"     VALUE(I_LSTML) LIKE  BSET-LSTML DEFAULT SPACE
*"     REFERENCE(I_CONCT) LIKE  BOOLE STRUCTURE  BOOLE OPTIONAL
*"     REFERENCE(I_GENER) LIKE  T020-GENER OPTIONAL
*"     REFERENCE(I_GLVOR) LIKE  BKPF-GLVOR OPTIONAL
*"  EXPORTING
*"     VALUE(E_MWSKZ) LIKE  BSET-MWSKZ
*"----------------------------------------------------------------------

  DATA XWIA.
  DATA L_TEXT LIKE DD07T-DDTEXT.
  DATA: L_T001Z      LIKE  T001Z,                           "N1090810
        L_LSTML      LIKE  T007A-LSTML,                     "N1090810
        L_T001       LIKE  T001.                            "N1090810


*------- Initialisierung -----------------------------------------------
  CLEAR E_MWSKZ.


*------- MWSTAB füllen -------------------------------------------------
  REFRESH MWSTAB.

RANGES: P_MWSKZ   FOR T007A-MWSKZ.


  P_MWSKZ-sign    =  'I'.
  P_MWSKZ-option  =  'EQ'.
  P_MWSKZ-low     = 'C0'.
  APPEND P_MWSKZ.

P_MWSKZ-sign    =  'I'.
  P_MWSKZ-option  =  'EQ'.
  P_MWSKZ-low     = 'C9'.
  APPEND P_MWSKZ.


P_MWSKZ-sign    =  'I'.
  P_MWSKZ-option  =  'EQ'.
  P_MWSKZ-low     = 'C7'.
  APPEND P_MWSKZ.



  IF I_STBUK <> SPACE.
*   Ermittelt das Steuerschema aus dem Steuerbuchungskreis
    CALL FUNCTION 'FIND_TAX_SPREADSHEET'
      EXPORTING
        BUCHUNGSKREIS = I_STBUK
      IMPORTING
        SCHEMA        = I_KALSM.
  ENDIF.                               " i_stbuk <> space.

  IF I_KALSM IS INITIAL.
    I_KALSM = '%'.
  ENDIF.

  IF I_KALSM = '%'.
    CALL FUNCTION 'CHECK_PLANTS_ABROAD_ACTIVE'
      EXPORTING
        I_CUST        = 'X'
      IMPORTING
        E_FI_ISACTIVE = XWIA.
  ELSE.
    CALL FUNCTION 'CHECK_PLANTS_ABROAD_ACTIVE'
      EXPORTING
        I_KALSM       = I_KALSM
      IMPORTING
        E_FI_ISACTIVE = XWIA.
  ENDIF.


*------- FLDTAB füllen -------------------------------------------------
  REFRESH FLDTAB.
  CLEAR FLDTAB.
  IF I_KALSM = '%'.
    FLDTAB-TABNAME    = 'T007A'.
    FLDTAB-FIELDNAME  = 'KALSM'.
    APPEND FLDTAB.
  ENDIF.
  CLEAR FLDTAB.
  FLDTAB-TABNAME    = 'T007A'.
  FLDTAB-FIELDNAME  = 'MWSKZ'.
  FLDTAB-SELECTFLAG = 'X'.
  APPEND FLDTAB.
  CLEAR FLDTAB.
  FLDTAB-TABNAME    = 'T007S'.
  FLDTAB-FIELDNAME  = 'TEXT1'.
  APPEND FLDTAB.

  IF XWIA IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM T007A WHERE KALSM LIKE I_KALSM
*      AND MWSKZ IN P_MWSKZ.
*
* NEW CODE
    SELECT *
 FROM T007A WHERE KALSM LIKE I_KALSM
      AND MWSKZ IN P_MWSKZ ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
*  IF  T007A-MWSKZ  EQ 'C0'  OR T007A-MWSKZ EQ 'C9'.
        IF I_KALSM = '%'.
          MWSTAB-MWSTX = T007A-KALSM.
          APPEND MWSTAB.
        ENDIF.
          MWSTAB-MWSTX = T007A-MWSKZ.
          APPEND MWSTAB.
        CLEAR T007S.
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES01 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM T007S WHERE SPRAS = SY-LANGU AND
*                                         KALSM = T007A-KALSM AND
*                                         MWSKZ = T007A-MWSKZ
*                                         AND MWSKZ IN P_MWSKZ.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM T007S WHERE SPRAS = SY-LANGU AND
                                         KALSM = T007A-KALSM AND
                                         MWSKZ = T007A-MWSKZ
                                         AND MWSKZ IN P_MWSKZ ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

*- Soll der Text mit dem key versehen werden (in Listboxes sinnvoll) ---
        L_TEXT = T007S-TEXT1.
        IF NOT I_CONCT IS INITIAL.
          PERFORM CONCATENATE
                      USING
                         T007A-MWSKZ
                      CHANGING
                         L_TEXT.
        ENDIF.
        MWSTAB-MWSTX = L_TEXT.
        APPEND MWSTAB.
      ENDSELECT.
    ELSE.
      IF I_LSTML IS INITIAL.
        IF I_GENER = 0.
          CALL SCREEN 010 STARTING AT 17 07. "fills T007A-LSTML
        ELSE.
          T007A-LSTML = I_LSTML.                             "note 424583
        ENDIF.
      ELSE.
        T007A-LSTML = I_LSTML.
      ENDIF.
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES01 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM T001Z INTO L_T001Z
*                                 WHERE BUKRS = I_STBUK AND
*                                       PARTY = 'PNOWIA'.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM T001Z INTO L_T001Z
                                 WHERE BUKRS = I_STBUK AND
                                       PARTY = 'PNOWIA' ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF SY-SUBRC = 0.
      ELSE.
        CLEAR L_T001Z.
      ENDIF.
      IF L_T001Z-PAVAL = 'X'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM T001 INTO L_T001
*                     WHERE BUKRS  = I_STBUK.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM T001 INTO L_T001
                     WHERE BUKRS  = I_STBUK ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF SY-SUBRC = 0.
          L_LSTML = SPACE.
        ELSE.
          CLEAR L_T001.
        ENDIF.
      ELSE.
        L_T001-LAND1 = T007A-LSTML.
        L_LSTML      = T007A-LSTML.
      ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT * FROM T007A WHERE KALSM LIKE I_KALSM
*                                AND MWSKZ IN P_MWSKZ AND
**                              lstml = t007a-lstml.              "N1090810
*                              (  LSTML = L_T001-LAND1  OR   "N1090810
*                                 LSTML = L_LSTML ).         
*
* NEW CODE
      SELECT *
 FROM T007A WHERE KALSM LIKE I_KALSM
                                AND MWSKZ IN P_MWSKZ AND
*                              lstml = t007a-lstml.              "N1090810
                              (  LSTML = L_T001-LAND1  OR   "N1090810
                                 LSTML = L_LSTML ) ORDER BY PRIMARY KEY.         

* END. 07-07-2026 - ATC - ATC-03"N1090810

        IF I_KALSM = '%'.
            MWSTAB-MWSTX = T007A-KALSM.
            APPEND MWSTAB.
        ENDIF.
          MWSTAB-MWSTX = T007A-MWSKZ.
          APPEND MWSTAB.
        CLEAR T007S.
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES01 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM T007S WHERE SPRAS = SY-LANGU AND
*                                         KALSM = T007A-KALSM AND
*                                         MWSKZ = T007A-MWSKZ.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM T007S WHERE SPRAS = SY-LANGU AND
                                         KALSM = T007A-KALSM AND
                                         MWSKZ = T007A-MWSKZ ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

*- Soll der Text mit dem key versehen werden (in Listboxes sinnvoll) ---
        L_TEXT = T007S-TEXT1.
        IF NOT I_CONCT IS INITIAL.
          PERFORM CONCATENATE
                      USING
                         T007A-MWSKZ
                      CHANGING
                         L_TEXT.
        ENDIF.
        MWSTAB-MWSTX = L_TEXT.
        APPEND MWSTAB.
      ENDSELECT.
    ENDIF.
*------- Steuerkennzeichen anzeigen ------------------------------------
    CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE'
      EXPORTING
        DISPLAY      = I_XSHOW
        FIELDNAME    = 'MWSKZ'
        TABNAME      = 'T007A'
      IMPORTING
        SELECT_VALUE = E_MWSKZ
      TABLES
        FIELDS       = FLDTAB
        VALUETAB     = MWSTAB.

  ENDFUNCTION.
