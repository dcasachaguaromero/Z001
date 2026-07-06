FUNCTION ZF4_ZAHLLAUF.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(F1TYP) TYPE  C DEFAULT 'D'
*"     VALUE(F1NME) TYPE  C DEFAULT SPACE
*"     VALUE(F2NME) TYPE  C DEFAULT 'F110V-LAUFI'
*"     VALUE(DISPLAY_LAUFK) TYPE  C DEFAULT 'X'
*"     VALUE(EXPLAIN_LAUFK) TYPE  C DEFAULT SPACE
*"     REFERENCE(BUKRS) TYPE  BUKRS
*"     REFERENCE(BANCO) TYPE  UBNKL
*"  EXPORTING
*"     VALUE(LAUFD) LIKE  F110V-LAUFD
*"     VALUE(LAUFI) LIKE  F110V-LAUFI
*"  TABLES
*"      LAUFK STRUCTURE  ILAUFK OPTIONAL
*"----------------------------------------------------------------------

  TABLES: DD07L, DD07V.

* Tabellen für F4 auf den Lauf
  DATA: BEGIN OF TAB_LAUF OCCURS 50,
          LAUFD LIKE REGUV-LAUFD,
          LAUFI LIKE REGUV-LAUFI,
        END OF TAB_LAUF.
  DATA: BEGIN OF TAB_LAUF1 OCCURS 50,
          LAUFD LIKE REGUV-LAUFD,
          LAUFI LIKE REGUV-LAUFI,
          STATU LIKE F110V-STATU,
        END OF TAB_LAUF1.
  DATA: BEGIN OF TAB_LAUF2 OCCURS 50,
          LAUFD LIKE REGUV-LAUFD,
          LAUFI LIKE REGUV-LAUFI,
          APPLT LIKE RSAHD-APPL_TEXT,
          STATU LIKE F110V-STATU,
        END OF TAB_LAUF2.
  DATA: BEGIN OF TAB_UPDATE OCCURS 1.
          INCLUDE STRUCTURE DYNPREAD.
  DATA: END OF TAB_UPDATE.
  DATA:   BEGIN OF return_tab OCCURS 2.
    INCLUDE STRUCTURE ddshretval.
  DATA:   END OF return_tab.
  DATA:   BEGIN OF ret_flds OCCURS 2.
    INCLUDE STRUCTURE dselc.
  DATA:   END OF ret_flds.
  DATA:   lc_tfill   LIKE sy-tfill,
          lc_subrc   LIKE sy-subrc.
  DATA:   sel_flg(1) TYPE C,
          li_ist     TYPE ddshmaxrec.
  TABLES: ILAUFK.
  RANGES: RNG_LAUFK FOR ILAUFK-LAUFK.

*------- Partnerfeld mit Wert aus Dynpro vorbelegen --------------------
  REFRESH TAB_UPDATE.
  CLEAR TAB_UPDATE.
  TAB_UPDATE-FIELDNAME = F2NME.
  APPEND TAB_UPDATE.
  CALL FUNCTION 'DYNP_VALUES_READ'
       EXPORTING
            DYNAME     = SY-CPROG
            DYNUMB     = SY-DYNNR
       TABLES
            DYNPFIELDS = TAB_UPDATE
       EXCEPTIONS
            OTHERS     = 4.
  IF SY-SUBRC EQ 0.
    READ TABLE TAB_UPDATE WITH KEY FIELDNAME = F2NME.
    IF F1TYP EQ 'D'.
      LAUFI = TAB_UPDATE-FIELDVALUE.
    ELSE.
      CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
           EXPORTING
                DATE_EXTERNAL = TAB_UPDATE-FIELDVALUE
          IMPORTING
                DATE_INTERNAL = LAUFD
          EXCEPTIONS
                OTHERS        = 4.
    ENDIF.
  ENDIF.

*------- maximale Trefferanzahl ermitteln -----------------------------
  CALL FUNCTION 'F4IF_MAXRECORDS_ALL'
    IMPORTING
      MAXRECORDS = max_rec.

*------- Lauftabelle füllen -------------------------------------------
  DESCRIBE TABLE TAB_LAUF2 LINES SY-TFILL.
  IF SY-TFILL = 0.
    REFRESH RNG_LAUFK.
    RNG_LAUFK-OPTION   = 'EQ'.
    RNG_LAUFK-HIGH     = SPACE.
    LOOP AT LAUFK.
      RNG_LAUFK-LOW    = LAUFK-LAUFK.
      RNG_LAUFK-SIGN   = LAUFK-SIGN.
      IF RNG_LAUFK-SIGN CN 'IE'.
        RNG_LAUFK-SIGN = 'I'.
      ENDIF.
      APPEND RNG_LAUFK.
    ENDLOOP.
    data: fecha like sy-datum.
    fecha = sy-datum - 15.

    SELECT * FROM REGUV where LAUFD > fecha ORDER BY LAUFD DESCENDING LAUFI ASCENDING.
      CHECK REGUV-LAUFI+5(1) IN RNG_LAUFK.

      select single * from reguh
                     where laufd       = REGUV-LAUFD
                     and   laufi       = REGUV-LAUFI
                     and   ZBUKR       = bukrs
                     and   UBNKL       = BANCO .

      check sy-subrc = 0.

      TAB_LAUF2-LAUFD = REGUV-LAUFD.
      TAB_LAUF2-LAUFI = REGUV-LAUFI.
      IF DISPLAY_LAUFK EQ SPACE.
        TAB_LAUF2-LAUFI+5 = SPACE.
      ENDIF.
      PERFORM STATUS_ERMITTELN(SAPF110V) USING REGUV TAB_LAUF2-STATU.
      IF EXPLAIN_LAUFK NE SPACE.
        DD07L-DOMNAME     = 'LAUFK_F110'.
        DD07L-DOMVALUE_L  = REGUV-LAUFI+5(1).
        CALL FUNCTION 'DD_DOMVALUE_TEXT_GET'
             EXPORTING
                  DOMNAME       = DD07L-DOMNAME
                  VALUE         = DD07L-DOMVALUE_L
             IMPORTING
                  DD07V_WA      = DD07V.
        TAB_LAUF2-APPLT = DD07V-DDTEXT.
        APPEND TAB_LAUF2.
      ELSE.
        MOVE-CORRESPONDING TAB_LAUF2 TO TAB_LAUF1.
        APPEND TAB_LAUF1.
      ENDIF.
      TAB_LAUF-LAUFD = REGUV-LAUFD.
      TAB_LAUF-LAUFI = REGUV-LAUFI.
      APPEND TAB_LAUF.
      li_ist = li_ist + 1.
      IF li_ist > max_rec.
        EXIT.
      ENDIF.
    ENDSELECT.
  ENDIF.

*------- maximale Trefferanzahl beachten ------------------------------
  IF li_ist > max_rec.
    MESSAGE S803(DH) WITH max_rec.
    CALL SCREEN 1104 STARTING AT 10 5.
    IF ok-code = 'CNCL'.
      EXIT.
    ENDIF.
    IF     max_rec     EQ 0
    OR     max_rec     GT li_ist
    OR     sel_char    NE '%'
    OR NOT f110v-vonld IS INITIAL
    OR     f110v-bisld LT '99991231'.
      " neu selektieren
      CLEAR:   tab_lauf, tab_lauf1, tab_lauf2.
      REFRESH: tab_lauf, tab_lauf1, tab_lauf2.
      CLEAR:   li_ist.
      SELECT * FROM REGUV WHERE laufd GE f110v-vonld
                            AND laufd LE f110v-bisld
                            AND laufi LIKE sel_char(6)
                          ORDER BY LAUFD DESCENDING LAUFI ASCENDING.
        CHECK REGUV-LAUFI+5(1) IN RNG_LAUFK.
        TAB_LAUF2-LAUFD = REGUV-LAUFD.
        TAB_LAUF2-LAUFI = REGUV-LAUFI.
        IF DISPLAY_LAUFK EQ SPACE.
          TAB_LAUF2-LAUFI+5 = SPACE.
        ENDIF.
        PERFORM STATUS_ERMITTELN(SAPF110V) USING REGUV TAB_LAUF2-STATU.
        IF EXPLAIN_LAUFK NE SPACE.
          DD07L-DOMNAME     = 'LAUFK_F110'.
          DD07L-DOMVALUE_L  = REGUV-LAUFI+5(1).
          CALL FUNCTION 'DD_DOMVALUE_TEXT_GET'
            EXPORTING
              DOMNAME       = DD07L-DOMNAME
              VALUE         = DD07L-DOMVALUE_L
            IMPORTING
              DD07V_WA      = DD07V.
          TAB_LAUF2-APPLT = DD07V-DDTEXT.
          APPEND TAB_LAUF2.
        ELSE.
          MOVE-CORRESPONDING TAB_LAUF2 TO TAB_LAUF1.
          APPEND TAB_LAUF1.
        ENDIF.
        TAB_LAUF-LAUFD = REGUV-LAUFD.
        TAB_LAUF-LAUFI = REGUV-LAUFI.
        APPEND TAB_LAUF.
        IF max_rec > 0.
          li_ist = li_ist + 1.
          IF li_ist >= max_rec.
            EXIT.
          ENDIF.
        ENDIF.
      ENDSELECT.
    ELSE.
      IF li_ist > max_rec.
        li_ist = max_rec + 1.
        DELETE tab_lauf1 FROM li_ist.
        DELETE tab_lauf2 FROM li_ist.
      ENDIF.
    ENDIF.
  ENDIF.

*------- Value request aufrufen ---------------------------------------
  REFRESH return_tab.
  REFRESH ret_flds.
  ret_flds-fldname   = 'F0001'.
  ret_flds-dyfldname = 'PXLAUFD'.
  APPEND ret_flds.
  ret_flds-fldname   = 'F0002'.
  ret_flds-dyfldname = 'PXLAUFI'.
  APPEND ret_flds.

  IF explain_laufk NE SPACE.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        value_org       = 'S'
        retfield        = 'LAUFI'
        window_title    = TEXT-999
      TABLES
        value_tab       = tab_lauf2
        return_tab      = return_tab
        dynpfld_mapping = ret_flds
    EXCEPTIONS
        parameter_error = 1
        no_values_found = 2.
  ELSE.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        value_org       = 'S'
        retfield        = 'LAUFI'
        window_title    = TEXT-999
      TABLES
        value_tab       = tab_lauf1
        return_tab      = return_tab
        dynpfld_mapping = ret_flds
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2.
  ENDIF.
  lc_subrc = sy-subrc.
  DESCRIBE TABLE return_tab LINES lc_tfill.
  IF lc_tfill EQ 0. RETURN. ENDIF.
  IF lc_subrc NE 0.
    MESSAGE S007(SH).
  ELSE.
    CLEAR tab_lauf.
    LOOP AT return_tab.
      CASE return_tab-fieldname.
        WHEN 'F0001'.
          CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
            EXPORTING
                DATE_EXTERNAL = return_tab-fieldval
            IMPORTING
                DATE_INTERNAL = tab_lauf-laufd
            EXCEPTIONS
                OTHERS        = 4.
        WHEN 'F0002'.
          tab_lauf-laufi = return_tab-fieldval.
      ENDCASE.
    ENDLOOP.

*------- Rückgabefeld nur versorgen, wenn eingabebereit ----------------
    IF NOT F1NME IS INITIAL.
      LOOP AT SCREEN.
        IF SCREEN-NAME EQ F1NME AND SCREEN-INPUT EQ 0.
          CLEAR F1NME.
        ENDIF.
      ENDLOOP.
      IF F1NME IS INITIAL.
        EXIT.
      ENDIF.
    ENDIF.
    IF F1TYP EQ 'D'.
      LAUFD = TAB_LAUF-LAUFD.
    ELSE.
      LAUFI = TAB_LAUF-LAUFI.
    ENDIF.

*------- Partnerfeld auch versorgen ------------------------------------
    LOOP AT SCREEN.
      IF SCREEN-NAME EQ F2NME AND SCREEN-INPUT EQ 0.
        CLEAR F2NME.
      ENDIF.
    ENDLOOP.
    IF F2NME IS INITIAL.
      EXIT.
    ENDIF.
    REFRESH TAB_UPDATE.
    CLEAR TAB_UPDATE.
    TAB_UPDATE-FIELDNAME    = F2NME.
    IF F1TYP EQ 'D'.
      LAUFI = TAB_LAUF-LAUFI.
      TAB_UPDATE-FIELDVALUE = LAUFI.
    ELSE.
      LAUFD = TAB_LAUF-LAUFD.
      WRITE LAUFD TO TAB_UPDATE-FIELDVALUE DD/MM/YYYY.
    ENDIF.
    APPEND TAB_UPDATE.
    CALL FUNCTION 'DYNP_VALUES_UPDATE'
         EXPORTING
              DYNAME     = SY-CPROG
              DYNUMB     = SY-DYNNR
         TABLES
              DYNPFIELDS = TAB_UPDATE
         EXCEPTIONS
              OTHERS     = 8.
  ENDIF.

ENDFUNCTION.
