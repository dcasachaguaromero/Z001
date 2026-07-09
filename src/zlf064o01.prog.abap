*----------------------------------------------------------------------*
***INCLUDE LF064O01 .
*&---------------------------------------------------------------------*
*&      Module  READ_RECURRING_DOC_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE read_recurring_doc_data OUTPUT.
  IF g_aktyp EQ c_aktyp_change.
    SELECT SINGLE FOR UPDATE * FROM bkdf WHERE bukrs = xbkpf-bukrs AND
                                    belnr = xbkpf-belnr AND
                                    gjahr = xbkpf-gjahr.
  ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM bkdf WHERE bukrs = xbkpf-bukrs AND
*                                    belnr = xbkpf-belnr AND
*                                    gjahr = xbkpf-gjahr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM bkdf WHERE bukrs = xbkpf-bukrs AND
                                    belnr = xbkpf-belnr AND
                                    gjahr = xbkpf-gjahr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.

  rf05l-belnr = xbkpf-belnr.
  rf05l-bukrs = xbkpf-bukrs.
  rf05l-gjahr = xbkpf-gjahr.
  rf05l-dbtag = bkdf-dbtag.
  rf05l-dbatr = bkdf-dbatr.

ENDMODULE.                             " READ_RECURRING_DOC_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  D0101_MODIFICATION  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE d0101_modification OUTPUT.
* for now, recurring entry data can only be displayed:
  LOOP AT SCREEN.
    IF screen-name = 'BKDF-DBZHL'.
      CLEAR screen-input.
      MODIFY SCREEN.
    ENDIF.
*   if g_aktyp ne c_aktyp_change.
    CLEAR screen-input.
    MODIFY SCREEN.
*   endif.
  ENDLOOP.

ENDMODULE.                             " D0101_MODIFICATION  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PFSTATUS_RECURR_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pfstatus_recurr_data OUTPUT.
* if g_aktyp = c_aktyp_change.
*   set pf-status 'DBDV'.
*   set titlebar '006' with 'Dauerbuchungsdaten'(906).
* else.
  SET PF-STATUS 'DBDA'.
  SET TITLEBAR '005' WITH 'Dauerbuchungsdaten'(906).
* endif.

ENDMODULE.                             " PFSTATUS_RECURR_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  KOPF_MODIFIKATION  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE kopf_modifikation OUTPUT.
  TABLES: ttypt.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM ttypt WHERE spras EQ sy-langu
*                             AND   awtyp EQ bkpf-awtyp.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM ttypt WHERE spras EQ sy-langu
                             AND   awtyp EQ bkpf-awtyp ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  t001-waers = bkpf-hwaer.                                  "Note 44129
  IF bkpf-waers = t001-waers.
    LOOP AT SCREEN.
      CHECK screen-group2 = '001'
      OR    screen-group2 = '061'.
*
* Exchange rates (001) und inverse exchange rate check box (061)
*
      screen-output = c_off.
      screen-invisible = c_on.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

* read document type data:
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t003 WHERE blart = bkpf-blart.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t003 WHERE blart = bkpf-blart ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

*------- Aktivitaetstyp -----------------------------------------------*
  xbmodz = g_aktyp.

*---------------- Buchungsperiode offen ? ------------------------------
  CLEAR s_status-buper.
  frpe1 = bkpf-monat.
  CALL FUNCTION 'FI_PERIOD_CHECK'
    EXPORTING
      i_bukrs          = bkpf-bukrs
      i_gjahr          = bkpf-gjahr
      i_koart          = '+'
      i_monat          = frpe1
    EXCEPTIONS
      error_period     = 1
      error_period_acc = 2
      OTHERS           = 3.
  IF sy-subrc = 0.
    s_status-buper = 'X'.
  ENDIF.

* begin of note 1023317
* initial state bkpf-vatdate on screen 1710: no input
  IF bkpf-vatdate IS INITIAL
  AND t001-xvatdate IS INITIAL.
    LOOP AT SCREEN.
      IF screen-name CS 'VATDATE'.
        screen-invisible = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.
* vatdate cannot be changed here on this screen.
  ENDIF.
* end of note 1023317

  PERFORM dynpro_mod_modif3(sapff012) USING s_status-buper xbmodz.

*------- Bei Einzelbelegen kein Buchungskreis --------------------------
  IF status NE c_stat_hierseq.
    LOOP AT SCREEN.
      IF screen-name = 'BKPF-BUKRS'.
        screen-output = c_off.
        screen-invisible = c_on.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

*------- Passendes Schlüsselwort for STBLG -----------------------------

  PERFORM reversal_text.                                   " Note 354186

*------ Logisches System ggf. ergänzen (SPACE heißt lokal) -------------
*------ RF05l-AWSYS2 ist das Anzeigefeld -------------------------------
  IF bkpf-awsys IS INITIAL.
    CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
      IMPORTING
        own_logical_system = rf05l-awsys2
      EXCEPTIONS
        OTHERS             = 1.
    IF sy-subrc NE 0.
      rf05l-awsys2 = bkpf-awsys.
    ENDIF.
  ELSE.
    rf05l-awsys2 = bkpf-awsys.
  ENDIF.

*------ Sonderbehandlung für Argentinien: XBLNR, BRNCH und NUMPG
  CALL FUNCTION 'J_1BSA_COMPONENT_ACTIVE'
    EXPORTING
      bukrs     = bkpf-bukrs
      component = 'AR'
    EXCEPTIONS
      OTHERS    = 1.
  IF sy-subrc = 0.                     "Bukrs in Argentinien
    IF t003-xnmrl = 'X' AND t003-xausg = 'X'.
      "Argentisch numerierter Beleg: XBLNR, BRNCH nicht aenderbar
      LOOP AT SCREEN.
        IF screen-name = 'BKPF-XBLNR' OR screen-name = 'BKPF-BRNCH'.
          screen-input = c_off.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ELSE.                                "alle anderen Länder
    LOOP AT SCREEN.
      IF screen-name = 'BKPF-BRNCH' OR screen-name = 'BKPF-NUMPG'.
        screen-output = c_off.
        screen-invisible = c_on.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

*------ Special treatment for Italy: Display XBLNR_ALT
  CALL FUNCTION 'J_1BSA_COMPONENT_ACTIVE'
    EXPORTING
      bukrs     = bkpf-bukrs
      component = 'IT'
    EXCEPTIONS
      OTHERS    = 1.
  IF sy-subrc = 0.                "Italian company code
    LOOP AT SCREEN.
      IF screen-name = 'BKPF-XBLNR_ALT'.
        screen-output = c_on.
        screen-invisible = c_off.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSE.                            " all other countries
    LOOP AT SCREEN.
      IF screen-name = 'BKPF-XBLNR_ALT'.
        screen-output = c_off.
        screen-invisible = c_on.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

* for now, document header data can only be displayed:
  LOOP AT SCREEN.
    screen-input = c_off.
    MODIFY SCREEN.
  ENDLOOP.
*----- PPA IS-PS Barua
  DATA: l_active.

  CALL FUNCTION 'FM_CHECK_PPA_ACTIVE_CORE'
    EXPORTING
      i_company_code = bkpf-bukrs
    IMPORTING
      e_active       = l_active.
  IF l_active = space.
    LOOP AT SCREEN.
      IF screen-name = 'BKPF-REINDAT'.
        screen-invisible = c_on.
        screen-input = c_off.
        screen-output = c_off.
        screen-required = c_off.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
*}   INSERT

*--------------------- Open FI -----------------------------------------
  REFRESH: noinputtab, invisibletab.
  CLEAR  : noinputtab, invisibletab.
  CALL FUNCTION 'OPEN_FI_PERFORM_00001410_P'
    EXPORTING
      i_bkpf         = bkpf
      i_aktyp        = g_aktyp
    TABLES
      t_noinput      = noinputtab
      t_invisible    = invisibletab
    EXCEPTIONS
      nothing_active = 4
      OTHERS         = 8.
  IF sy-subrc = 0.
    LOOP AT SCREEN.
      READ TABLE noinputtab WITH KEY = screen-name.
      IF sy-subrc = 0.
        screen-input = c_off.
        screen-required = c_off.
        MODIFY SCREEN.
      ENDIF.
      READ TABLE invisibletab WITH KEY = screen-name.
      IF sy-subrc = 0.
        screen-invisible = c_on.
        screen-input = c_off.
        screen-output = c_off.
        screen-required = c_off.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDMODULE.                             " KOPF_MODIFIKATION  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  PFSTATUS_POPU  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pfstatus_popu OUTPUT.
* if g_aktyp = c_aktyp_change.
*   set pf-status 'DBDV'.
* else.
  SET PF-STATUS 'DBDA'.
* endif.
  SET TITLEBAR '018' WITH bkpf-bukrs.
ENDMODULE.                             " PFSTATUS_POPU  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INHALTE_MERKEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE inhalte_merken OUTPUT.
  old_bktxt = bkpf-bktxt.
  old_xblnr = bkpf-xblnr.
ENDMODULE.                             " INHALTE_MERKEN  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  TITLEBAR_WINDOW  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE titlebar_window OUTPUT.
  SET PF-STATUS 'NB'.
  SET TITLEBAR '009'.
ENDMODULE.                             " TITLEBAR_WINDOW  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  GJAHR_VORSCHLAGEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE gjahr_vorschlagen OUTPUT.
  rf05l-belnr = bkpf-belnr.
  rf05l-gjahr = space.
  GET PARAMETER ID 'BUK' FIELD rf05l-bukrs.
  IF rf05l-bukrs NE space.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM t001
*      WHERE bukrs = rf05l-bukrs.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM t001
      WHERE bukrs = rf05l-bukrs ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF t001-xgjrv = c_x
    OR sy-calld = c_x.
      GET PARAMETER ID 'GJR' FIELD rf05l-gjahr.
    ENDIF.
  ENDIF.
ENDMODULE.                             " GJAHR_VORSCHLAGEN  OUTPUT
* Begin of ALRK
*&---------------------------------------------------------------------*
*&      Module  STATUS_1120  OUTPUT
*&---------------------------------------------------------------------*
*       Set status in reversal popup.
*----------------------------------------------------------------------*
MODULE d1120_status OUTPUT.
  SET PF-STATUS 'REVS'.
  SET TITLEBAR 'REV'.
ENDMODULE.                             " STATUS_1120  OUTPUT
* End of ALRK
