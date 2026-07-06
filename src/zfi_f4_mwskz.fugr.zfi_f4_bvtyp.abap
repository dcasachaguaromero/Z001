FUNCTION ZFI_F4_BVTYP.
*"--------------------------------------------------------------------
*"*"Interfase global
*"  IMPORTING
*"     VALUE(I_KUNNR) LIKE  KNBK-KUNNR DEFAULT SPACE
*"     VALUE(I_LIFNR) LIKE  LFBK-LIFNR DEFAULT SPACE
*"     VALUE(I_XSHOW) LIKE  RFCU4-FLAGX DEFAULT SPACE
*"  EXPORTING
*"     VALUE(E_BVTYP) LIKE  LFBK-BVTYP
*"  EXCEPTIONS
*"      NO_BVTYP_FOUND
*"      INVALID_CALL
*"--------------------------------------------------------------------

  DATA: l_iban TYPE iban.                                   "Note642346
  DATA: x_notiban(1) TYPE c.

  DATA: fieldtab  LIKE dfies      OCCURS 0 WITH HEADER LINE. "Note893929
  DATA: returntab LIKE ddshretval OCCURS 0 WITH HEADER LINE. "Note893929
  DATA: xtech_account TYPE c.             "X = technical account number,
  "space = normal account number


*------- Initialisierung -----------------------------------------------
  CLEAR e_bvtyp.

*------- Entweder Debitor oder Kreditor angegeben? ---------------------
  CHECK NOT i_kunnr IS INITIAL
  OR    NOT i_lifnr IS INITIAL.
  IF  NOT i_kunnr IS INITIAL
  AND NOT i_lifnr IS INITIAL.
    MESSAGE e401 RAISING invalid_call.
  ENDIF.

*------- Partnerbanktypen zu I_LIFNR und zugehörige Bankverbindungen ---
*        in BVTTAB stellen
  IF NOT i_lifnr IS INITIAL.
    IF i_lifnr <> old_lifnr.
      REFRESH bvttab.
      CLEAR bvttab.

       CALL FUNCTION 'FUNCTION_EXISTS'                      "Note642346
         EXPORTING
           funcname           = 'READ_IBAN'
         EXCEPTIONS
           function_not_exist = 1
           OTHERS             = 2.
        IF sy-subrc NE space.
          x_notiban = 'X'.
        ENDIF.

      SELECT * FROM lfbk
             WHERE lifnr =  i_lifnr
             AND   bvtyp <> space
             ORDER BY bvtyp banks bankl bankn.
        IF sy-subrc = 0 AND x_notiban EQ space.             "Note642346
          IF lfbk-banks NE t005-land1.                      "Note814711
            SELECT SINGLE * FROM t005 WHERE land1 = lfbk-banks.
          ENDIF.
          IF t005-bnkey = 2.
            lfbk-bankl = lfbk-bankn.
          ENDIF.
          CALL FUNCTION 'READ_IBAN'                         "#EC EXISTS
            EXPORTING
              i_banks = lfbk-banks
              i_bankl = lfbk-bankl
              i_bankn = lfbk-bankn
              i_bkont = lfbk-bkont
              i_bkref = lfbk-bkref                          "Note772574
               IMPORTING
              e_iban  = l_iban
            EXCEPTIONS
              OTHERS  = 1.
          IF sy-subrc <> 0.
            CLEAR l_iban.
          ENDIF.
          IF t005-bnkey = 2.                                "Note814711
            CLEAR lfbk-bankl.
          ENDIF.
        ENDIF.

*       Check whether bank account is a technical account number. Then it's an IBAN
*       without bank account
        IF lfbk-bankn <> space AND l_iban <> space.
          CALL FUNCTION 'FI_TECH_ACCNO_CHECK_TRY'
            EXPORTING
              i_bankn = lfbk-bankn
            IMPORTING
              e_xtech = xtech_account.
        ENDIF.

        bvttab-bvtyp = lfbk-bvtyp. APPEND bvttab.
        bvttab-bvtyp = lfbk-banks. APPEND bvttab.
        bvttab-bvtyp = lfbk-bankl. APPEND bvttab.

*       Don't show bank account if it's only technical
        IF xtech_account = space.
          bvttab-bvtyp = lfbk-bankn. APPEND bvttab.
        ELSE.
          bvttab-bvtyp = space.      APPEND bvttab.
          CLEAR: xtech_account.
        ENDIF.

        bvttab-bvtyp = lfbk-bkref. APPEND bvttab.           "Note590483
        IF x_notiban EQ space.                              "Note642346
          bvttab-bvtyp = l_iban.   APPEND bvttab.
        ENDIF.

      ENDSELECT.
      old_lifnr = i_lifnr.
      CLEAR old_kunnr.
    ENDIF.

*------- Partnerbanktypen zu I_KUNNR und zugehörige Bankverbindungen ---
*        in BVTTAB stellen
  ELSE.
    IF i_kunnr <> old_kunnr.
      REFRESH bvttab.
      CLEAR bvttab.

        CALL FUNCTION 'FUNCTION_EXISTS'                     "Note642346
          EXPORTING
            funcname           = 'READ_IBAN'
          EXCEPTIONS
            function_not_exist = 1
            OTHERS             = 2.
        IF sy-subrc NE space.
          x_notiban = 'X'.
        ENDIF.

      SELECT * FROM knbk
             WHERE kunnr =  i_kunnr
             AND   bvtyp <> space
             ORDER BY bvtyp banks bankl bankn.
        IF sy-subrc = 0 AND x_notiban EQ space.             "Note642346
          IF lfbk-banks NE t005-land1.                      "Note814711
            SELECT SINGLE * FROM t005 WHERE land1 = lfbk-banks.
          ENDIF.
          IF t005-bnkey = 2.
            lfbk-bankl = lfbk-bankn.
          ENDIF.
          CALL FUNCTION 'READ_IBAN'                         "#EC EXISTS
            EXPORTING
              i_banks = knbk-banks                          "Note716414
              i_bankl = knbk-bankl                          "Note716414
              i_bankn = knbk-bankn                          "Note716414
              i_bkont = knbk-bkont                          "Note716414
              i_bkref = knbk-bkref                          "Note772574
               IMPORTING
              e_iban  = l_iban
            EXCEPTIONS
              OTHERS  = 1.
          IF sy-subrc <> 0.
            CLEAR l_iban.
          ENDIF.
          IF t005-bnkey = 2.                                "Note814711
            CLEAR lfbk-bankl.
          ENDIF.
        ENDIF.

*       Check whether bank account is a technical account number. Then it's an IBAN
*       without bank account
        IF knbk-bankn <> space AND l_iban <> space.
          CALL FUNCTION 'FI_TECH_ACCNO_CHECK_TRY'
            EXPORTING
              i_bankn = knbk-bankn
            IMPORTING
              e_xtech = xtech_account.
        ENDIF.

        bvttab-bvtyp = knbk-bvtyp. APPEND bvttab.
        bvttab-bvtyp = knbk-banks. APPEND bvttab.
        bvttab-bvtyp = knbk-bankl. APPEND bvttab.

*       Don't show bank account if it's only technical
        IF xtech_account = space.
          bvttab-bvtyp = knbk-bankn. APPEND bvttab.
        ELSE.
          bvttab-bvtyp = space.      APPEND bvttab.
          CLEAR: xtech_account.
        ENDIF.

        bvttab-bvtyp = knbk-bkref. APPEND bvttab.           "Note590483
        IF x_notiban EQ space.                              "Note642346
          bvttab-bvtyp = l_iban.   APPEND bvttab.
        ENDIF.

      ENDSELECT.
      old_kunnr = i_kunnr.
      CLEAR old_lifnr.
    ENDIF.
  ENDIF.

*------- Partnerbanktypen vorhanden? -----------------------------------
  DESCRIBE TABLE bvttab LINES sy-tfill.
  IF sy-tfill = 0.
    MESSAGE s402 RAISING no_bvtyp_found.
    EXIT.
  ENDIF.

*------- FLDTAB füllen -------------------------------------------------
*  REFRESH fldtab.
*  CLEAR fldtab.
*
*  fldtab-tabname    = 'LFBK'.
*  fldtab-fieldname  = 'BVTYP'.
*  fldtab-selectflag = 'X'.
*  APPEND fldtab.
*
*  CLEAR fldtab-selectflag.
*  fldtab-fieldname  = 'BANKS'. APPEND fldtab.
*  fldtab-fieldname  = 'BANKL'. APPEND fldtab.
*  fldtab-fieldname  = 'BANKN'. APPEND fldtab.
*  fldtab-fieldname  = 'BKREF'. APPEND fldtab.               "Note590483
*
*  IF x_notiban EQ space.                                    "Note642346
*    fldtab-tabname    = 'TIBAN'.
*    fldtab-fieldname  = 'IBAN'.
*    APPEND fldtab.
*  ENDIF.

* Start of note 893929
  REFRESH fieldtab.
  CLEAR fieldtab.

  fieldtab-tabname    = 'LFBK'.
  fieldtab-fieldname  = 'BVTYP'.
  APPEND fieldtab.

  fieldtab-fieldname  = 'BANKS'. APPEND fieldtab.
  fieldtab-fieldname  = 'BANKL'. APPEND fieldtab.
  fieldtab-fieldname  = 'BANKN'. APPEND fieldtab.
  fieldtab-fieldname  = 'BKREF'. APPEND fieldtab.

  IF x_notiban EQ space.
    fieldtab-tabname    = 'TIBAN'.
    fieldtab-fieldname  = 'IBAN'.
    APPEND fieldtab.
  ENDIF.

*------- Partnerbanktypen anzeigen -------------------------------------
*  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE'
*    EXPORTING
*      display      = i_xshow
*      fieldname    = 'BVTYP'
*      tabname      = 'BSEG'
*    IMPORTING
*      select_value = e_bvtyp
*    TABLES
*      fields       = fldtab
*      valuetab     = bvttab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield   = 'BVTYP'
      display    = i_xshow
    TABLES
      value_tab  = bvttab
      field_tab  = fieldtab
      return_tab = returntab.

  e_bvtyp = returntab-fieldval.
* End of note 893929

ENDFUNCTION.
