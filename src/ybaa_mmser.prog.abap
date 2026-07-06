************************************************************************
*        Druckroutinen für Leistungserfassung                          *
************************************************************************
* Druckprogramm für SF-Formular AA_MMSER Service Entry
* Kopie aus SAPFM11P
*----------------------------------------------------------------------*
* Datenteil
*----------------------------------------------------------------------*
*INCLUDE FM11PTOP.
*INCLUDE /SMBA0/AA_MMSER_TOP.
************************************************************************
*        Datenteil SAPFM11P    Druck Leistungserfassung                *
************************************************************************
PROGRAM SAPFM11P MESSAGE-ID ME.

type-pools:  meein.

INCLUDE RVADTABL.

*- Tabellen -----------------------------------------------------------*
TABLES: ESSR,              "Erfassungsblatt
*       ESKL,              "Kontierungszuordnung
*       ESKN,              "Kontierungszeile
        ESLH,              "Leistungspaket Kopf intern
        ESLL,              "Leistungszeile
        ML_ESLL,
        RM11P,             "Hilfsfelder Leistungszeile
        ESUC,              "Kontraktposition ungeplante Limits
        RM06P,             "Hilfsfelder Druck Einkauf
        EKKO,              "Bestellkopf
        EKPO,              "Einkaufsposition
        EKPA,              "Partner
        EKET,              "Einteilung f. Lieferdatum
        LFA1,
        KNA1,
        THEAD, *THEAD,
        SADR,
        TTXIT,             "Text IDs
        T001,
        T001W,
        T006,
        T006A,
        T024,
        T024E,
*       T027A,
*       T027B,
*       T163X,
*       T166A,
*       T165P,
*       T166C,
*       T166T,
*       T166U.
        T166P.

*- INTERNE TABELLEN ---------------------------------------------------*


*- Tabelle der Positionstexte -----------------------------------------*
DATA: BEGIN OF IT166P OCCURS 10.
        INCLUDE STRUCTURE T166P.
DATA: END OF IT166P.

DATA: BEGIN OF XT166P OCCURS 10.
        INCLUDE STRUCTURE T166P.
DATA: END OF XT166P.

*- Tabelle der Textheader ---------------------------------------------*
DATA: BEGIN OF XTHEAD OCCURS 10.
        INCLUDE STRUCTURE THEAD.
DATA: END OF XTHEAD.

DATA: BEGIN OF XTHEADKEY,
         TDOBJECT LIKE THEAD-TDOBJECT,
         TDNAME LIKE THEAD-TDNAME,
         TDID LIKE THEAD-TDID,
      END OF XTHEADKEY.


*- Tabelle der Nachrichten alt/neu ------------------------------------*
DATA: BEGIN OF XNAST OCCURS 10.
        INCLUDE STRUCTURE NAST.
DATA: END OF XNAST.

DATA: BEGIN OF YNAST OCCURS 10.
        INCLUDE STRUCTURE NAST.
DATA: END OF YNAST.


*- Struktur des Archivobjekts -----------------------------------------*
DATA: BEGIN OF XOBJID,
        OBJKY  LIKE NAST-OBJKY,
        ARCNR  LIKE NAST-OPTARCNR,
      END OF XOBJID.

*- Hilfsfelder --------------------------------------------------------*
DATA: HADRNR(8),                       "Key TSADR
      ELEMENTN(30),                    "Name des Elements
      RETCO LIKE SY-SUBRC,             "Returncode Druck
      XDRFLG LIKE T166P-DRFLG,         "Hilfsfeld Textdruck
      ENTRIES  LIKE SY-TFILL.          "Zähler Tabelleneinträge

DATA: PFELD(8) TYPE P.                 "Rechenfeld

*- Drucksteuerung -----------------------------------------------------*
DATA: XDRUVO.                          "Druckvorgang
DATA: NEU  VALUE '1',                  "Neudruck
      AEND VALUE '2'.                  "Änderungsdruck

*- Hilfsfelder für Ausgabemedium --------------------------------------*
DATA: XDIALOG,                         "Kz. POP-UP
      XSCREEN,                         "Kz. Probeausgabe
*     XFORMULAR LIKE TNAPR-FONAM,      "Formular
      XDEVICE(10).                     "Ausgabemedium

* Datendefinitionen für Dienstleistungen

DATA  BEGIN OF GLIEDERUNG OCCURS 50.   "Tabelle Gliederungen
        INCLUDE STRUCTURE ML_ESLL.
DATA  END   OF GLIEDERUNG.

DATA  BEGIN OF LEISTUNG OCCURS 50.     "tabelle Leistungen
        INCLUDE STRUCTURE ML_ESLL.
DATA  END   OF LEISTUNG.

* Defintionen für Formeln

TYPE-POOLS MSFO.

DATA: VARIABLEN TYPE MSFO_TAB_VARIABLEN WITH HEADER LINE.

DATA: FORMEL TYPE MSFO_FORMEL.

*- SF-Ausgabe ----------------------* * *-- ---------------------------*
DATA: retcode   LIKE sy-subrc.         "Returncode

*SF-Formular ist Kopie von Bestellformular, daher müssen die Übergabe-
*stukturen da sein

data: l_doc   TYPE meein_purchase_doc_print,
      l_xkomk like table of komk with header line.

*----------------------------------------------------------------------*
* Datenbeschaffung
*----------------------------------------------------------------------*
*INCLUDE FM11PF01.
*INCLUDE /SMBA0/AA_MMSER_f01.
*----------------------------------------------------------------------*
*   INCLUDE FM11PF01                                                   *
*----------------------------------------------------------------------*
************************************************************************
*        Entries aus RSNAST00                                          *
************************************************************************

*eject
FORM ENTRY_NEW USING ENT_RETCO ENT_SCREEN.
*&---------------------------------------------------------------------*
*&      Form  ENTRY_NEW                                                *
*&---------------------------------------------------------------------*
*       Neudruck                                                       *
*----------------------------------------------------------------------*

  XSCREEN = ENT_SCREEN.
  IF NAST-AENDE EQ SPACE.
    XDRUVO = '1'.
  ELSE.
    XDRUVO = '2'.
  ENDIF.

*- Anstoß Verarbeitung ------------------------------------------------*
  CLEAR ENT_RETCO.
  PERFORM READ_DATA USING NAST-OBJKY.
  MOVE RETCO TO ENT_RETCO.

ENDFORM.                    "ENTRY_NEW

*eject
FORM ENTRY_CHANGE USING ENT_RETCO ENT_SCREEN.
*&---------------------------------------------------------------------*
*&      Form  ENTRY_NEW                                                *
*&---------------------------------------------------------------------*
*       Aenderungsdruck                                                *
*----------------------------------------------------------------------*

  XSCREEN = ENT_SCREEN.
  XDRUVO = '2'.

*- Anstoß Verarbeitung ------------------------------------------------*
  CLEAR ENT_RETCO.
  PERFORM READ_DATA USING NAST-OBJKY.
  MOVE RETCO TO ENT_RETCO.

ENDFORM.                    "ENTRY_CHANGE

************************************************************************
*   FORMS for DATA SELECTION                                           *
************************************************************************

FORM READ_DATA USING LES_LBLNI.
*&---------------------------------------------------------------------*
*&      Form  READ_DATA                                                *
*&---------------------------------------------------------------------*
*       Daten lesen                                                    *
*----------------------------------------------------------------------*
*  -->  LBLNI     Erfassungsblattnummer = NAST-OBJKY
*----------------------------------------------------------------------*

  DATA: H_PARVW LIKE EKPA-PARVW.

* Lesen Erfassungsblattkopf -------------------------------------------*
  SELECT SINGLE * FROM ESSR WHERE LBLNI EQ LES_LBLNI.

* Lesen Bestelldaten --------------------------------------------------*
  IF ESSR-EBELN NE EKKO-EBELN.
    SELECT SINGLE * FROM EKKO WHERE EBELN EQ ESSR-EBELN.
  ENDIF.
  IF EKPO-EBELN NE ESSR-EBELN OR EKPO-EBELP NE ESSR-EBELP.
    SELECT SINGLE * FROM EKPO WHERE EBELN EQ ESSR-EBELN
                              AND   EBELP EQ ESSR-EBELP.
*..Lieferdatum
    CLEAR: RM06P-LFDAT, RM06P-PRITX.
    SELECT * FROM EKET WHERE EBELN EQ EKPO-EBELN
                       AND   EBELP EQ EKPO-EBELP.
      EXIT.
    ENDSELECT.
    IF SY-SUBRC EQ 0 AND EKET-EINDT NE 0.
      PERFORM AUFBEREITEN_LIEFERDATUM USING EKET-EINDT EKET-LPEIN
                                            RM06P-LFDAT EKET-LPEIN
                                            RM06P-PRITX.
    ENDIF.
  ENDIF.

* Zurücksetzen Konditionen --------------------------------------------*
*F EKKO-STAKO EQ SPACE.
*  CALL FUNCTION 'PRICING_REFRESH'
*       TABLES
*            TKOMK = TKOMK
*            TKOMV = TKOMV.
*NDIF.

* Lesen Lieferantendaten ----------------------------------------------*
  IF EKKO-LIFNR NE SPACE.
*--- Abweichende Bestelladresse verwenden, dann aussternen
*  H_PARVW = 'BA'.
    CLEAR EKPA.
    IF H_PARVW NE SPACE.
      SELECT * FROM EKPA WHERE EBELN = EKKO-EBELN AND PARVW = H_PARVW.
        EXIT.
      ENDSELECT.
    ENDIF.
    IF EKPA-LIFN2 NE SPACE.
      SELECT SINGLE * FROM LFA1 WHERE LIFNR = EKPA-LIFN2.
    ELSE.
      CALL FUNCTION 'MM_ADDRESS_GET'
        EXPORTING
          I_EKKO = EKKO
        IMPORTING
          E_SADR = SADR
        EXCEPTIONS
          OTHERS = 1.
      MOVE-CORRESPONDING SADR TO LFA1.
    ENDIF.
  ENDIF.

* Lesen Tabellen ------------------------------------------------------*
  SELECT SINGLE * FROM T024 WHERE EKGRP EQ EKKO-EKGRP.
  SELECT SINGLE * FROM T024E WHERE EKORG EQ EKKO-EKORG.
  SELECT SINGLE * FROM T001 WHERE BUKRS EQ EKKO-BUKRS.

* Steuertabelle T166P fuer Zeilenlangtext puffern
  SELECT * FROM T166P INTO TABLE IT166P
           WHERE DRUVO EQ XDRUVO
           AND   BSTYP EQ 'Q'
           AND   BSART EQ EKKO-BSART
           AND   PSTYP EQ EKPO-PSTYP.

  PERFORM WERKSANSCHRIFT USING EKPO-WERKS.

* Ausgabe Kopf --------------------------------------------------------*
*PERFORM AUSGABE_KOPF.
*CHECK RETCO EQ 0.

* Ausgabe Überschrift -------------------------------------------------*
*PERFORM AUSGABE_UEB.

* Lesen und Ausgeben Leistungen ---------------------------------------*
  IF NOT ESSR-PACKNO IS INITIAL.

    REFRESH: GLIEDERUNG, LEISTUNG.
    CLEAR:   GLIEDERUNG, LEISTUNG.

* Gliederung lesen
    CALL FUNCTION 'MS_SUBDIVISION_FOR_PRINT'
      EXPORTING
        PACKNO           = ESSR-PACKNO
      TABLES
        GLIEDERUNG       = GLIEDERUNG
      EXCEPTIONS
        PACKNO_NOT_EXIST = 01.

    IF SY-SUBRC EQ 0.
      LOOP AT GLIEDERUNG.
*         PERFORM PRINT_GLIEDERUNG.
* Leistungen lesen (zur Gliederung)
        CALL FUNCTION 'MS_SERVICES_FOR_PRINT'
          EXPORTING
            PACKNO            = GLIEDERUNG-SUB_PACKNO
          TABLES
            LEISTUNG          = LEISTUNG
          EXCEPTIONS
            NO_SERVICES_FOUND = 01.
        IF SY-SUBRC EQ 0.
*           PERFORM PRINT_SRVPOS.
        ENDIF.
      ENDLOOP.
*      PERFORM PRINT_TOTAL_AMOUNT.

    ENDIF.
  ENDIF.

* Ausgabe ansteuern ---------------------------------------------------*
  perform PRINT_SMARTFORM.

*PERFORM ENDE.

ENDFORM.                    " READ_DATA

*&---------------------------------------------------------------------*
*&      Form  WERKSANSCHRIFT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->WAN_WERKS  text
*----------------------------------------------------------------------*
FORM WERKSANSCHRIFT USING WAN_WERKS.
*&---------------------------------------------------------------------*
*&      Form  WERKSANSCHRIFT
*&---------------------------------------------------------------------*
*       Lesen Werk und Werksanschrift.                                 *
*----------------------------------------------------------------------*

  DATA: H_EKKO LIKE EKKO.
  CLEAR SADR.
  CHECK WAN_WERKS NE SPACE.
  SELECT SINGLE * FROM  T001W
         WHERE  WERKS       = WAN_WERKS.
  CHECK SY-SUBRC EQ 0.
  H_EKKO-RESWK = WAN_WERKS.
  H_EKKO-BSAKZ = 'T'.
  CALL FUNCTION 'MM_ADDRESS_GET'
    EXPORTING
      I_EKKO = H_EKKO
    IMPORTING
      E_SADR = SADR
    EXCEPTIONS
      OTHERS = 0.

ENDFORM.                    " WERKSANSCHRIFT

*eject
FORM LESEN_TTXIT USING TITDR OBJECT ID.
*&---------------------------------------------------------------------*
*&      Form  LESEN_TTXIT
*&---------------------------------------------------------------------*
*       Bezeichnung des Textes lesen                                   *
*----------------------------------------------------------------------*

  CLEAR TTXIT.
  CASE TITDR.
    WHEN 'X'.
      SELECT SINGLE * FROM TTXIT WHERE TDSPRAS  EQ EKKO-SPRAS
                                 AND   TDOBJECT EQ OBJECT
                                 AND   TDID     EQ ID.
  ENDCASE.

ENDFORM.                    " LESEN_TTXIT

*eject
FORM AUFBEREITEN_LIEFERDATUM USING ALI_DATUMI ALI_LPEINI
                                   ALI_DATUME ALI_LPEINE ALI_PRITXE.
*&---------------------------------------------------------------------*
*&      Form  AUFBEREITEN_LIEFERDATUM
*&---------------------------------------------------------------------*
*       Lieferdatum in Druckformat                                     *
*----------------------------------------------------------------------*

  CALL FUNCTION 'PERIOD_AND_DATE_CONVERT_OUTPUT'
    EXPORTING
      INTERNAL_DATE      = ALI_DATUMI
      INTERNAL_PERIOD    = ALI_LPEINI
      LANGUAGE           = EKKO-SPRAS
      COUNTRY            = LFA1-LAND1
    IMPORTING
      EXTERNAL_DATE      = ALI_DATUME
      EXTERNAL_PERIOD    = ALI_LPEINE
      EXTERNAL_PRINTTEXT = ALI_PRITXE.

ENDFORM.                    " AUFBEREITEN_LIEFERDATUM

*&---------------------------------------------------------------------*
*&      Form  PROTOCOL_UPDATE
*&---------------------------------------------------------------------*
* Verarbeitungsprotokoll der Nachrichten fortschreiben                 *
*----------------------------------------------------------------------*
FORM PROTOCOL_UPDATE USING PRU_MSGNO PRU_MSGV1 PRU_MSGV2
                                     PRU_MSGV3 PRU_MSGV4.
  SYST-MSGID = 'ME'.
  SYST-MSGNO = PRU_MSGNO.
  SYST-MSGTY = 'W'.
  SYST-MSGV1 = PRU_MSGV1.
  SYST-MSGV2 = PRU_MSGV2.
  SYST-MSGV3 = PRU_MSGV3.
  SYST-MSGV4 = PRU_MSGV4.
  CHECK XSCREEN = SPACE.
  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
    EXPORTING
      MSG_ARBGB = SYST-MSGID
      MSG_NR    = SYST-MSGNO
      MSG_TY    = SYST-MSGTY
      MSG_V1    = SYST-MSGV1
      MSG_V2    = SYST-MSGV2
      MSG_V3    = SYST-MSGV3
      MSG_V4    = SYST-MSGV4
    EXCEPTIONS
      OTHERS    = 1.


ENDFORM.                    " PROTOCOL_UPDATE
*&---------------------------------------------------------------------*
*&      Form  PRINT_TIME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_TIME.

  CHECK NOT ML_ESLL-PERNR IS INITIAL OR
        NOT ML_ESLL-PERSEXT IS INITIAL OR
        NOT ML_ESLL-SDATE IS INITIAL OR
        NOT ML_ESLL-BEGTIME IS INITIAL OR
        NOT ML_ESLL-ENDTIME IS INITIAL.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'TIME_DATA'.
*          others        = 1.        "Parameter nicht vorhanden (TODO)

ENDFORM.                    " PRINT_TIME
*&---------------------------------------------------------------------*
*&      Form  PRINT_FORMEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_FORMEL.

  DATA: FELD(15).
  FIELD-SYMBOLS: <VALUE>.
  CHECK NOT ML_ESLL-FORMELNR IS INITIAL.

  CALL FUNCTION 'MS_READ_AND_CHECK_FORMULA'
    EXPORTING
      I_FORMELNR = ML_ESLL-FORMELNR
      NO_ERRORS  = 'X'
    IMPORTING
      E_FORMEL   = FORMEL
    TABLES
      VARIABLEN  = VARIABLEN
    EXCEPTIONS
      OTHERS     = 0.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      ELEMENT = 'FORMEL_KOPF'.
*          others        = 1.               "wegen TODO entfernt
  MOVE 'ML_ESLL-FRMVAL1' TO FELD.
  LOOP AT VARIABLEN.
    MOVE SY-TABIX TO FELD+14(1).
    ASSIGN (FELD) TO <VALUE>.
    MOVE <VALUE> TO ML_ESLL-FRMVAL1.
    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        ELEMENT = 'FORMEL_BODY'.
*              others        = 1.               "wegen TODO entfernt
  ENDLOOP.

ENDFORM.                    " PRINT_FORMEL


*----------------------------------------------------------------------*
* Druckausgabe
*----------------------------------------------------------------------*
*INCLUDE FM11PF02.
*INCLUDE /SMBA0/AA_MMSER_f02.
************************************************************************
*        Druckausgabe Leistungserfassung                               *
************************************************************************
* Ausgabe des SF-Formulars
*
* - begin of insertion note 429806 ------------------------------------*
DATA: ls_snast       LIKE snast,
      lf_programm    TYPE tdprogram,
      ls_comm_type   TYPE ad_comm,
      ls_comm_values TYPE szadr_comm_values,
      ls_recipient   LIKE swotobjid,
      ls_sender      LIKE swotobjid.
* - end of insertion note 429806 --------------------------------------*

*CLEAR RETCO.
*SET LANGUAGE EKKO-SPRAS.
*SET COUNTRY  LFA1-LAND1.

*&--------------------------------------------------------------------*
*&      Form  PRINT_SMARTFORM
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM PRINT_SMARTFORM.
  DATA: lf_fm_name            TYPE rs38l_fnam.
  DATA: ls_control_param      TYPE ssfctrlop.
  DATA: ls_composer_param     TYPE ssfcompop.
  DATA: ls_recipient          TYPE swotobjid.
  DATA: ls_sender             TYPE swotobjid.
  DATA: lf_formname           TYPE tdsfname.
  DATA: ls_addr_key           LIKE addr_key.
  data: ls_job_info           type ssfcrescl.
  data: l_spoolid             type rspoid.

  CHECK retcode = 0.
  PERFORM set_print_param USING      ls_addr_key
                            CHANGING ls_control_param
                                     ls_composer_param
                                     ls_recipient
                                     ls_sender
                                     retcode.


*Get the Smart Form name.
  IF NOT tnapr-sform IS INITIAL.
    lf_formname = tnapr-sform.
  ELSE.
    MESSAGE e001(ssfcomposer).
  ENDIF.

* determine smartform function module
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
       EXPORTING  formname           = lf_formname
*                 variant            = ' '
*                 direct_call        = ' '
       IMPORTING  fm_name            = lf_fm_name
       EXCEPTIONS no_form            = 1
                  no_function_module = 2
                  OTHERS             = 3.
  IF sy-subrc <> 0.
*   error handling
    retcode = sy-subrc.
    IF sy-subrc = 1.
      MESSAGE e001(ssfcomposer).
    ENDIF.
    IF sy-subrc = 2.
      MESSAGE e002(ssfcomposer).
    ENDIF.
    PERFORM protocol_update2.
  ENDIF.

  CALL FUNCTION lf_fm_name
    EXPORTING
       archive_index              = toa_dara
*   ARCHIVE_INDEX_TAB          =
       archive_parameters         = arc_params
       control_parameters         = ls_control_param
*   MAIL_APPL_OBJ              =
       mail_recipient             = ls_recipient
       mail_sender                = ls_sender
       output_options             = ls_composer_param
       user_settings              = ' '
       is_ekko            = ekko
*       is_pekko           = l_doc-xpekko
       is_nast            = nast
*       iv_from_mem        = l_from_memory
       iv_druvo           = xdruvo
*       iv_xfz             = iv_xfz
*       formel             = formel "für SF-übergabe ddic nötig
        is_essr            = essr
    TABLES
      it_gliederung      = gliederung
      it_leistung        = leistung
*      variablen         = variablen "für SF-übergabe ddic nötig
      it_ekpo            = l_doc-xekpo[]
      it_ekpa            = l_doc-xekpa[]
      it_pekpo           = l_doc-xpekpo[]
      it_eket            = l_doc-xeket[]
      it_tkomv           = l_doc-xtkomv[]
      it_ekkn            = l_doc-xekkn[]
      it_ekek            = l_doc-xekek[]
      it_komk            = l_xkomk[]
******

* IMPORTING
*   DOCUMENT_OUTPUT_INFO       =
*   JOB_OUTPUT_INFO            =
*   JOB_OUTPUT_OPTIONS         =
*tables
**********
EXCEPTIONS
 formatting_error           = 1
 internal_error             = 2
 send_error                 = 3
 user_canceled              = 4
 OTHERS                     = 5
            .
  IF sy-subrc <> 0.
    retcode = sy-subrc.
    PERFORM protocol_update2.
* get SmartForm protocoll and store it in the NAST protocoll
*    PERFORM add_smfrm_prot.
  else.
    read table ls_job_info-spoolids into l_spoolid index 1.
    if sy-subrc is initial.
      export spoolid = l_spoolid to memory id 'KYK_SPOOLID'.
    endif.

  ENDIF.

ENDFORM.                    "PRINT SMARTFORM

************************************
* STANDARD SMARTFORM FORM ROUTINES *
************************************

*---------------------------------------------------------------------*
*       FORM PROTOCOL_UPDATE2                                         *
*---------------------------------------------------------------------*
*       The messages are collected for the processing protocol.       *
*---------------------------------------------------------------------*

FORM protocol_update2.

  CHECK xscreen = space.
  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
    EXPORTING
      msg_arbgb = syst-msgid
      msg_nr    = syst-msgno
      msg_ty    = syst-msgty
      msg_v1    = syst-msgv1
      msg_v2    = syst-msgv2
      msg_v3    = syst-msgv3
      msg_v4    = syst-msgv4
    EXCEPTIONS
      OTHERS    = 1.

ENDFORM.                    "protocol_update2
*&---------------------------------------------------------------------*
*&      Form  set_print_param
*&---------------------------------------------------------------------*
FORM set_print_param USING    is_addr_key LIKE addr_key
                     CHANGING cs_control_param TYPE ssfctrlop
                              cs_composer_param TYPE ssfcompop
                              cs_recipient TYPE  swotobjid
                              cs_sender TYPE  swotobjid
                              cf_retcode TYPE sy-subrc.

  DATA: ls_itcpo     TYPE itcpo.
  DATA: lf_repid     TYPE sy-repid.
  DATA: lf_device    TYPE tddevice.
  DATA: ls_recipient TYPE swotobjid.
  DATA: ls_sender    TYPE swotobjid.

  lf_repid = sy-repid.

  CALL FUNCTION 'WFMC_PREPARE_SMART_FORM'
    EXPORTING
      pi_nast       = nast
      pi_addr_key   = is_addr_key
      pi_repid      = lf_repid
    IMPORTING
      pe_returncode = cf_retcode
      pe_itcpo      = ls_itcpo
      pe_device     = lf_device
      pe_recipient  = cs_recipient
      pe_sender     = cs_sender.

  IF cf_retcode = 0.
    MOVE-CORRESPONDING ls_itcpo TO cs_composer_param.
*    cs_composer_param-tdnoprint = 'X'.                     "Note 591576
    cs_control_param-device      = lf_device.
    cs_control_param-no_dialog   = 'X'.
    cs_control_param-preview     = xscreen.
    cs_control_param-getotf      = ls_itcpo-tdgetotf.
    cs_control_param-langu       = nast-spras.
  ENDIF.
ENDFORM.                    "set_print_param

*&---------------------------------------------------------------------*
*&      Form  add_smfrm_prot
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_smfrm_prot.
  DATA: lt_errortab             TYPE tsferror.
  DATA: lf_msgnr                TYPE sy-msgno.
  DATA:  l_s_log                TYPE bal_s_log,
         p_loghandle            TYPE balloghndl,
         l_s_msg                TYPE bal_s_msg.
  FIELD-SYMBOLS: <fs_errortab>  TYPE LINE OF tsferror.

* get smart form protocoll
  CALL FUNCTION 'SSF_READ_ERRORS'
    IMPORTING
      errortab = lt_errortab.

* add smartform protocoll to nast protocoll
  LOOP AT lt_errortab ASSIGNING <fs_errortab>.
    CLEAR lf_msgnr.
    lf_msgnr = <fs_errortab>-errnumber.
    CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
      EXPORTING
        msg_arbgb = <fs_errortab>-msgid
        msg_nr    = lf_msgnr
        msg_ty    = <fs_errortab>-msgty
        msg_v1    = <fs_errortab>-msgv1
        msg_v2    = <fs_errortab>-msgv2
        msg_v3    = <fs_errortab>-msgv3
        msg_v4    = <fs_errortab>-msgv4
      EXCEPTIONS
        OTHERS    = 1.
  ENDLOOP.
* open the application log
  l_s_log-extnumber    = sy-uname.
  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log      = l_s_log
    IMPORTING
      e_log_handle = p_loghandle
    EXCEPTIONS
      OTHERS       = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  LOOP AT lt_errortab ASSIGNING <fs_errortab>.
    MOVE-CORRESPONDING <fs_errortab> TO l_s_msg.
    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle = p_loghandle
        i_s_msg      = l_s_msg
      EXCEPTIONS
        OTHERS       = 1.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDLOOP.

** Function module to display error logs during
** smart form processing
** Notice , the function 'BAL_DSP_LOG_DISPLAY' can
** not be used when you using output dispatch time
** 4 (Send immediately), so the statement is comment
** out by default.

** You can enable the function call statement
** if your form can not be output and you want to
** see the error log. Set output dispatch time to 3
** before save your order, then print or preview the
** output.

  DATA lv_debug.
  IF NOT lv_debug IS INITIAL.
    CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'.
  ENDIF.

ENDFORM.                               " add_smfrm_prot
****************************************
**&---------------------------------------------------------------------*
**&      Form  AUSGABE_KOPF
**&---------------------------------------------------------------------*
**       Ausgabe Kopf Erfassungsblatt                                   *
**----------------------------------------------------------------------*
*FORM AUSGABE_KOPF.
*
*CLEAR XDIALOG.
*CLEAR XDEVICE.
*CLEAR ITCPO.
*MOVE-CORRESPONDING NAST TO ITCPO.
*  itcpo-tdtitle = nast-tdcovtitle.                          "433786
*  itcpo-tdfaxuser = nast-usnam.                             "433786
*
**- Ausgabemedium festlegen --------------------------------------------*
*CASE NAST-NACHA.
*   WHEN '2'.
*      XDEVICE = 'TELEFAX'.
*      IF NAST-TELFX EQ SPACE.
*         XDIALOG = 'X'.
*      ELSE.
*         ITCPO-TDTELENUM  = NAST-TELFX.
*         ITCPO-TDTELELAND = LFA1-LAND1.
*      ENDIF.
*   WHEN '3'.
*      XDEVICE = 'TELETEX'.
*      IF NAST-TELTX EQ SPACE.
*         XDIALOG = 'X'.
*      ELSE.
*         ITCPO-TDTELENUM  = NAST-TELTX.
*         ITCPO-TDTELELAND = LFA1-LAND1.
*      ENDIF.
*   WHEN '4'.
*      XDEVICE = 'TELEX'.
*      IF NAST-TELX1 EQ SPACE.
*         XDIALOG = 'X'.
*      ELSE.
*         ITCPO-TDTELENUM  = NAST-TELX1.
*         ITCPO-TDTELELAND = LFA1-LAND1.
*      ENDIF.
** -------- start of insertion note 429806 -----------------------------*
*    WHEN '5'.
**   ... use stratagy to get communication type
*      CALL FUNCTION 'ADDR_GET_NEXT_COMM_TYPE'
*        EXPORTING
*          strategy                 = nast-tcode
**         ADDRESS_TYPE             =
*          address_number           = lfa1-adrnr
**         PERSON_NUMBER            = addr_key-persnumber
*        IMPORTING
*          comm_type                = ls_comm_type
*          comm_values              = ls_comm_values
**       TABLES
**         STRATEGY_TABLE           =
*        EXCEPTIONS
*          address_not_exist        = 1
*          person_not_exist         = 2
*          no_comm_type_found       = 3
*          internal_error           = 4
*          parameter_error          = 5
*          OTHERS                   = 6.
*      IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*      ENDIF.
*
** convert communication data
*      MOVE-CORRESPONDING nast TO ls_snast.
*      MOVE sy-repid           TO lf_programm.
*      CALL FUNCTION 'CONVERT_COMM_TYPE_DATA'
*           EXPORTING
*                pi_comm_type              = ls_comm_type
*                pi_comm_values            = ls_comm_values
**               pi_screen                 = us_screen
**           PI_NEWID                  =
*                pi_country                = lfa1-land1
*                pi_repid                  = lf_programm
*                pi_snast                  = ls_snast
*           IMPORTING
*                pe_itcpo                  = itcpo
*                pe_device                 = xdevice
*                pe_mail_recipient         = ls_recipient
*                pe_mail_sender            = ls_sender
*           EXCEPTIONS
*                comm_type_not_supported   = 1
*                recipient_creation_failed = 2
*                sender_creation_failed    = 3
*                OTHERS                    = 4.
*      IF sy-subrc <> 0.
**   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*      ENDIF.
** - end of insertion note 429806 --------------------------------------*
*
*   WHEN OTHERS.
*      XDEVICE = 'PRINTER'.
*      IF NAST-LDEST EQ SPACE.
*         XDIALOG = 'X'.
*      ELSE.
*         ITCPO-TDDEST   = NAST-LDEST.
*      ENDIF.
*ENDCASE.
*
**- Testausgabe --------------------------------------------------------*
*IF XSCREEN NE SPACE.
**- Testausgabe auf Bildschirm -----------------------------------------*
*   IF NAST-TCODE EQ 'XTST'.
*      ITCPO-TDPREVIEW = 'X'.
*   ENDIF.
*ENDIF.
*
**itcpo-noprint   =
*ITCPO-TDCOVER    = NAST-TDOCOVER.
*ITCPO-TDCOPIES   = NAST-ANZAL.
*ITCPO-TDDATASET  = NAST-DSNAM.
*ITCPO-TDSUFFIX1  = NAST-DSUF1.
*ITCPO-TDSUFFIX2  = NAST-DSUF2.
*ITCPO-TDIMMED    = NAST-DIMME.
*ITCPO-TDDELETE   = NAST-DELET.
*ITCPO-TDSENDDATE = NAST-VSDAT.
*ITCPO-TDSENDTIME = NAST-VSURA.
*ITCPO-TDPROGRAM  = SY-REPID.
*
** Formular festlegen -------------------------------------------------*
*CALL FUNCTION 'OPEN_FORM'
*     EXPORTING FORM = XFORMULAR
*               LANGUAGE = EKKO-SPRAS
*               OPTIONS = ITCPO
*               ARCHIVE_INDEX  = TOA_DARA
*               ARCHIVE_PARAMS = ARC_PARAMS
**              ARCHIVE_PARAMS = ALARC_PAR1
*               DEVICE = XDEVICE
*               DIALOG = XDIALOG
*               mail_sender    = ls_sender
*               mail_recipient = ls_recipient
*     EXCEPTIONS CANCELED = 01.
*IF SY-SUBRC NE 0.
*   RETCO = SY-SUBRC.                                           "962793
*   PERFORM PROTOCOL_UPDATE USING '142' EKKO-EBELN SPACE SPACE SPACE.
*   EXIT.
*ENDIF.
*
** Folgeseitenzaehler -------------------------------------------------*
*CALL FUNCTION 'WRITE_FORM'
*       EXPORTING
*            element = 'NEXTPAGE'
*            window  = 'NEXTPAGE'
*       EXCEPTIONS
*            OTHERS  = 01.
*CLEAR SY-SUBRC.
*
** Kopfdaten Titel    -------------------------------------------------*
*CALL FUNCTION 'WRITE_FORM'
*       EXPORTING
*            element = 'TITEL'
*            window  = 'TITEL'
*       EXCEPTIONS
*            OTHERS  = 01.
*CLEAR SY-SUBRC.
*
** Auftraggeber -------------------------------------------------------*
*CALL FUNCTION 'WRITE_FORM'
*       EXPORTING
*            element = 'ADDRESS'
*            window  = 'ADDRESS'
*       EXCEPTIONS
*            OTHERS  = 01.
*CLEAR SY-SUBRC.
*
*
** Auftragnehmer ------------------------------------------------------*
*CALL FUNCTION 'WRITE_FORM'
*       EXPORTING
*            element = 'ADDRESS1'
*            window  = 'ADDRESS1'
*       EXCEPTIONS
*            OTHERS  = 01.
*CLEAR SY-SUBRC.
*
** Ort ----------------------------------------------------------------*
*IF NOT ESSR-DLORT IS INITIAL.
*   CALL FUNCTION 'WRITE_FORM'
*         EXPORTING
*              element = 'LOCATION'
*              window  = 'LOCATION'
*         EXCEPTIONS
*              OTHERS  = 01.
*   CLEAR SY-SUBRC.
*ENDIF.
*
** Zeitraum -----------------------------------------------------------*
*IF NOT ESSR-LZVON IS INITIAL OR NOT ESSR-LZBIS IS INITIAL.
*   CALL FUNCTION 'WRITE_FORM'
*         EXPORTING
*              element = 'PERIOD'
*              window  = 'PERIOD'
*         EXCEPTIONS
*              OTHERS  = 01.
*   CLEAR SY-SUBRC.
*ENDIF.
*
** Kopfdaten Kurztext -------------------------------------------------*
*CALL FUNCTION 'WRITE_FORM'
*       EXPORTING
*            element = 'HEADER'
*            window  = 'HEADER'
*       EXCEPTIONS
*            OTHERS  = 01.
*CLEAR SY-SUBRC.
*
** MAIN Fenster -------------------------------------------------------*
** Kopftext -----------------------------------------------------------*
*CALL FUNCTION 'WRITE_FORM'
*       EXPORTING
*            element = 'HEADER_TEXT'
*       EXCEPTIONS
*            OTHERS  = 01.
*CLEAR SY-SUBRC.
*
*
*ENDFORM.                    " AUSGABE_KOPF
*
**&---------------------------------------------------------------------*
**&      Form  AUSGABE_UEB
**&---------------------------------------------------------------------*
**       Überschrift ausgeben                                           *
**----------------------------------------------------------------------*
*FORM AUSGABE_UEB.
*
** Positionszeilen - Überschrift - 1. Seite ----------------------------*
*CALL FUNCTION 'WRITE_FORM'
*       EXPORTING
*            element = 'ITEM_HEADER'
*       EXCEPTIONS
*            OTHERS  = 01.
*CLEAR SY-SUBRC.
*
** Positionszeilen - Überschrift - Folgeseiten -------------------------*
*CALL FUNCTION 'WRITE_FORM'
*       EXPORTING
*            element = 'ITEM_HEADER'
*            type    = 'TOP'
*       EXCEPTIONS
*            OTHERS  = 01.
*CLEAR SY-SUBRC.
*
*ENDFORM.                    " AUSGABE_UEB
*
**eject
**&---------------------------------------------------------------------*
**&      Form  PRINT_GLIEDERUNG
**&---------------------------------------------------------------------*
**       Gliederung und Leistungen ausgeben                             *
**----------------------------------------------------------------------*
*FORM PRINT_GLIEDERUNG.
*
*CHECK GLIEDERUNG-RANG NE 0.
*MOVE GLIEDERUNG TO ML_ESLL.
*CALL FUNCTION 'WRITE_FORM'
*       EXPORTING
*            element = 'SERVICES'
*       EXCEPTIONS
*            OTHERS  = 01.
*PERFORM TEXTE USING  GLIEDERUNG-PACKNO GLIEDERUNG-INTROW '*'.
*CLEAR ML_ESLL.
*
*ENDFORM.
*
**---------------------------------------------------------------------*
**       FORM PRINT_SRVPOS                                             *
**---------------------------------------------------------------------*
**       ........                                                      *
**---------------------------------------------------------------------*
*FORM PRINT_SRVPOS.
**&---------------------------------------------------------------------*
**&      Form  PRINT_SRVPOS
**&---------------------------------------------------------------------*
**       Leistungen ausgeben                                            *
**----------------------------------------------------------------------*
*
*DATA: H_BRTWR TYPE F.
*DATA: HELP_BRTPR TYPE F.
*
* LOOP AT LEISTUNG.
*    IF LEISTUNG-ALTERNAT NE SPACE.
*       SELECT SINGLE * FROM ESLL
*          WHERE PACKNO EQ LEISTUNG-PACKNO
*          AND   INTROW EQ LEISTUNG-ALT_INTROW.
*    ENDIF.
*    MOVE SPACE TO LEISTUNG-EXTGROUP.
*    MOVE '0'   TO LEISTUNG-RANG.
*    MOVE LEISTUNG TO ML_ESLL.
*    MOVE ESLL-EXTROW TO ML_ESLL-ALT_INTROW.
** Aufbereiten Preiseinheit --------------------------------------------*
*    CLEAR RM11P-PRPEI.
*    IF ML_ESLL-PEINH NE 1.
*      RM11P-PRPEI(1) = '/'.
*      WRITE ML_ESLL-PEINH NO-SIGN TO RM11P-PRPEI+1(6).
*      DO.
*        IF RM11P-PRPEI+1(1) NE SPACE.
*          RM11P-PRPEI(1) = '/'.
*          EXIT.
*        ENDIF.
*        SHIFT RM11P-PRPEI LEFT.
*      ENDDO.
*    ENDIF.
*
**    pfeld         = ml_esll-brtwr * 1000.
**    IF ml_esll-menge NE 0.
**       h_brtwr = pfeld / ml_esll-menge * ml_esll-peinh.
**       MOVE h_brtwr TO  ml_esll-brtwr.
**   ENDIF.
*
** Logik für alte Belege ohne Bruttopreis
*   IF ML_ESLL-TBTWR IS INITIAL.
*     H_BRTWR = ML_ESLL-BRTWR * 1000.
*     IF ML_ESLL-MENGE NE 0.
*       IF ML_ESLL-PEINH NE 0.
*         HELP_BRTPR = H_BRTWR / ML_ESLL-MENGE * ML_ESLL-PEINH.
*         ML_ESLL-TBTWR = HELP_BRTPR.
*       ELSE.
*         HELP_BRTPR = H_BRTWR / ML_ESLL-MENGE.
*         ML_ESLL-TBTWR = HELP_BRTPR.
*       ENDIF.
*     ELSE.
*       IF ML_ESLL-PEINH NE 0.
*         HELP_BRTPR = H_BRTWR * ML_ESLL-PEINH.
*         ML_ESLL-TBTWR = HELP_BRTPR.
*       ELSE.
*         ML_ESLL-TBTWR = H_BRTWR.
*       ENDIF.
*     ENDIF.
*   ENDIF.
*
*
** Lesen Langtext Mengeneinheit ----------------------------------------*
*    CLEAR T006A.
*    SELECT SINGLE * FROM T006A WHERE SPRAS EQ EKKO-SPRAS
*                               AND   MSEHI EQ LEISTUNG-MEINS.
*
** Ermitteln Nachkommastellen ------------------------------------------*
*    CLEAR T006.
*    SELECT SINGLE * FROM T006 WHERE MSEHI EQ LEISTUNG-MEINS.
*
** Ermitteln externe Planzeile und Gruppe aus der Bestellung------------*
*    CLEAR: RM11P-PLN_EXTROW, RM11P-PLN_GRP.
*    IF NOT ML_ESLL-PLN_INTROW IS INITIAL.
*       CALL FUNCTION 'MS_GET_EXTERNAL_ROW'
*            EXPORTING
*                 I_PACKNO   = ML_ESLL-PLN_PACKNO
*                 I_INTROW   = ML_ESLL-PLN_INTROW
*            IMPORTING
*                 E_EXTROW   = RM11P-PLN_EXTROW
*                 E_EXTPATH  = RM11P-PLN_GRP.
*    ENDIF.
*
** Ermitteln Daten bei ungeplanter Leistung aus Kontraktlimit-----------*
*    CLEAR: RM11P-KNT_EXTROW, RM11P-KNT_GROUP, ESUC-EBELN, ESUC-EBELP.
*    IF NOT ML_ESLL-KNT_INTROW IS INITIAL.
*       CALL FUNCTION 'MS_GET_EXTERNAL_ROW'
*            EXPORTING
*                 I_PACKNO   = ML_ESLL-KNT_PACKNO
*                 I_INTROW   = ML_ESLL-KNT_INTROW
*            IMPORTING
*                 E_EXTROW   = RM11P-KNT_EXTROW
*                 E_EXTPATH  = RM11P-KNT_GROUP
*                 E_EBELN    = ESUC-EBELN
*                 E_EBELP    = ESUC-EBELP.
*    ENDIF.
*
** Ausgabe des Textelementes SERVICES ----------------------------------*
*    CALL FUNCTION 'WRITE_FORM'
*         EXPORTING
*              element = 'SERVICES'
*         EXCEPTIONS
*              OTHERS  = 01.
*
**...Langtexte selektieren und ausgeben
*    PERFORM TEXTE USING  LEISTUNG-PACKNO LEISTUNG-INTROW '*'.
**    Zeitdaten Ausgeben
*       PERFORM PRINT_TIME.
**    Formel ausgeben
*       PERFORM PRINT_FORMEL.
*
*    CLEAR ML_ESLL.
* ENDLOOP.
*
*ENDFORM.
*
**---------------------------------------------------------------------*
**       FORM TEXTE                                                    *
**---------------------------------------------------------------------*
**       ........                                                      *
**---------------------------------------------------------------------*
**  -->  PACKNO                                                        *
**  -->  INTROW                                                        *
**  -->  ID                                                            *
**---------------------------------------------------------------------*
*FORM TEXTE USING PACKNO INTROW ID.
**&---------------------------------------------------------------------*
**&      Form  TEXTE
**&---------------------------------------------------------------------*
**       Texte ausgeben entsprechend Tabelle 166P                       *
**----------------------------------------------------------------------*
*
*DATA: XNAME LIKE THEAD-TDNAME.
*
*XNAME  = PACKNO.
*XNAME+10 = INTROW.
*CLEAR XTHEADKEY.
*
**..lesen Textsteuerungstabelle
*REFRESH XT166P.
*CLEAR XT166P.
*LOOP AT IT166P.
*   MOVE IT166P TO XT166P.
*      CASE XT166P-TDOBJECT.
*        WHEN 'ASMD'.    "Activity Master
*          IF ML_ESLL-SRVPOS NE SPACE.
*             PERFORM TEXT_SELECT USING 'ASMD' ML_ESLL-SRVPOS
*                                       XT166P-TDID.
*             READ TABLE XTHEAD INDEX 1.
*             IF SY-SUBRC EQ 0.
*                XT166P-TXNAM = ML_ESLL-SRVPOS.
*                APPEND XT166P.
*             ENDIF.
*          ENDIF.
*      WHEN 'ESLL'.
***.....Text zur Leistung ESLL
*        IF XTHEADKEY-TDOBJECT NE 'ESLL'.
*          PERFORM TEXT_SELECT USING 'ESLL'  XNAME ID.
*        ENDIF.
*        XTHEADKEY-TDID = XT166P-TDID.
*        READ TABLE XTHEAD WITH KEY
*                         TDOBJECT      = XTHEADKEY-TDOBJECT
*                         TDNAME        = XTHEADKEY-TDNAME
*                   BINARY SEARCH.
*        IF SY-SUBRC EQ 0.
*           XT166P-TXNAM = XNAME.
*           APPEND XT166P.
*          ENDIF.
*        WHEN OTHERS.
*             APPEND XT166P.
*      ENDCASE.
**    IF XT166P-TDOBJECT = 'ESLL'.
***.....Text zur Leistung ESLL
**      IF XTHEADKEY-TDOBJECT NE 'ESLL'.
**        PERFORM TEXT_SELECT USING 'ESLL'  XNAME ID.
**      ENDIF.
**      XTHEADKEY-TDID = XT166P-TDID.
**      READ TABLE XTHEAD WITH KEY XTHEADKEY BINARY SEARCH.
**      IF SY-SUBRC EQ 0.
**        XT166P-TXNAM = XNAME.
**        APPEND XT166P.
**      ENDIF.
**    ELSE.
***.....sonstige Langtexte
**      CASE XT166P-TDOBJECT.
**        WHEN 'ASMD'.                   "Activity Master
**          IF ML_ESLL-SRVPOS NE SPACE.
**            PERFORM TEXT_SELECT USING 'ASMD' ML_ESLL-SRVPOS
**                                      XT166P-TDID.
**            READ TABLE XTHEAD INDEX 1.
**            IF SY-SUBRC EQ 0.
**              XT166P-TXNAM = ML_ESLL-SRVPOS.
**              APPEND XT166P.
**            ENDIF.
**          ENDIF.
**        WHEN OTHERS.
**          APPEND XT166P.
**      ENDCASE.
**    ENDIF.
*ENDLOOP.
*SORT XT166P BY DRFLG DRPRI.
*
**..kein weiterer Text mit gleicher Reihenfolge erlauben
*
*
*XDRFLG = '#'.
*LOOP AT XT166P.
*   IF XT166P-DRFLG EQ XDRFLG.
*      DELETE XT166P.
*   ELSE.
*      XDRFLG = XT166P-DRFLG.
*   ENDIF.
*ENDLOOP.
*
*
*
**  Langtexte ausgeben
*LOOP AT XT166P.
*   MOVE XT166P TO T166P.
**..Langtextbezeichnung
*   PERFORM LESEN_TTXIT USING XT166P-TITDR XT166P-TDOBJECT XT166P-TDID.
*   CALL FUNCTION 'WRITE_FORM'
*         EXPORTING
*              element = 'ITEM_TEXT'
*         EXCEPTIONS
*              OTHERS  = 01.
*  CLEAR SY-SUBRC.
*ENDLOOP.
*
*ENDFORM.
*
**---------------------------------------------------------------------*
**       FORM TEXT_SELECT                                              *
**---------------------------------------------------------------------*
**       ........                                                      *
**---------------------------------------------------------------------*
**  -->  OBJECT                                                        *
**  -->  NAME                                                          *
**  -->  ID                                                            *
**---------------------------------------------------------------------*
*FORM TEXT_SELECT  USING OBJECT NAME ID.
**&---------------------------------------------------------------------*
**&      Form  TEXT_SELECT
**&---------------------------------------------------------------------*
**       Text-Header selektieren                                        *
**----------------------------------------------------------------------*
*
** Textheader lesen
*    THEAD-TDOBJECT  = OBJECT.
*    THEAD-TDSPRAS   = EKKO-SPRAS.
*    THEAD-TDNAME    = NAME.
*    THEAD-TDID      = ID.
*    MOVE-CORRESPONDING THEAD TO XTHEADKEY.
*
*    CALL FUNCTION 'SELECT_TEXT'
*         EXPORTING
*              ID       = THEAD-TDID
*              LANGUAGE = THEAD-TDSPRAS
*              NAME     = THEAD-TDNAME
*              OBJECT   = THEAD-TDOBJECT
*         IMPORTING
*              ENTRIES = ENTRIES
*         TABLES
*              SELECTIONS = XTHEAD.
*    SORT XTHEAD BY TDID.
*
*ENDFORM.
*
**&---------------------------------------------------------------------*
**&      Form  ENDE
**&---------------------------------------------------------------------*
**       Formulardruck beenden                                          *
**----------------------------------------------------------------------*
*FORM ENDE.
*
** Unterschrift -------------------------------------------------------*
*CALL FUNCTION 'WRITE_FORM'
*       EXPORTING
*            element = 'LAST'
*       EXCEPTIONS
*            OTHERS  = 01.
*CLEAR SY-SUBRC.
*
** Folgeseitenzaehler löschen -----------------------------------------*
*CALL FUNCTION 'WRITE_FORM'
*       EXPORTING
*            element  = 'NEXTPAGE'
*            window   = 'NEXTPAGE'
*            function = 'DELETE'
*       EXCEPTIONS
*            OTHERS   = 01.
*CLEAR SY-SUBRC.
*
** Ende Formulardruck --------------------------------------------------*
*DATA: RESULT LIKE ITCPP.
*CALL FUNCTION 'CLOSE_FORM'
*       IMPORTING
*            result = result.
*IF RESULT-USEREXIT = 'E'.
*   LEAVE TO TRANSACTION SY-TCODE.
*ENDIF.
*
*ENDFORM.                    " ENDE
*
**&---------------------------------------------------------------------*
**&      Form  PRINT_TOTAL_AMOUNT
**&---------------------------------------------------------------------*
**       Gesamtsumme ausgeben                                           *
**----------------------------------------------------------------------*
*FORM PRINT_TOTAL_AMOUNT.
*
*CALL FUNCTION 'WRITE_FORM'
*       EXPORTING
*            element = 'TOTAL_AMOUNT'
*       EXCEPTIONS
*            OTHERS  = 01.
*CLEAR SY-SUBRC.
*
*ENDFORM.                    " PRINT_TOTAL
