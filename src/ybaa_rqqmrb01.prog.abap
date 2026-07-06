*&---------------------------------------------------------------------*
*& Report  /SMBA0/AA_RQQMRB01
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  YBAA_RQQMRB01.
************************************************************************
* Druckprogramm für ein Reklamationsschreiben in Qualitätsmeldungssystem
*                                                                      *
* Standard FORMULAR ist QM_COMPLAIN                                    *
*                                                                      *
************************************************************************

*$*$  D A T A    S E C T I O N    I N C L U D E S ---------------------*

INCLUDE riprid01.                     " Enthält DATA und TABLE Anweisung

*sf
TABLES: arc_params,                    "Archive parameters
        toa_dara,                      "Archive parameters
        addr_key.                      "Adressnumber for ADDRESS

TABLES: lfa1,                                "Lieferantenadresse
        sadr,                                "spez. Adresse
        t001,                                "Absenderland
        meico,                               "Einkaufsinfosatz
        eina,                                "Einkaufsinfosatz
        t024e.                               "Einkaufsorganisationen

DATA: g_anzahl TYPE i.

DATA:   BEGIN OF g_index_tab OCCURS 10.
        INCLUDE STRUCTURE  toa_dara.
DATA:   END   OF g_index_tab.


DATA:   BEGIN OF g_params_tab OCCURS 10.
        INCLUDE STRUCTURE  arc_params.
DATA:   END   OF g_params_tab.


DATA: form_kz TYPE c.
*------------------*
START-OF-SELECTION.
*------------------*

  PERFORM print_paper.      "ABAP kann direkt oder über Formular auf-
  "gerufen werden
*$*$ ................ M A I N     F O R M .............................*
*... DATA STRUCTURE: ..................................................*
*...                                                                   *
*...    VIQMEL (QMEL ILOA und QMIH in einer View) Meldungskopf         *
*...     !                                                             *
*...     !-- WQMFE/WQMUR           Fehlerposition                      *
*...     !   !                                                         *
*...     !-- !-- WQMMA             Aktionen zum Kopf/Fehler            *
*...     !   !                                                         *
*...     !-- !-- WQMSM             Maßnahmen zum Kopf/Fehler           *
*...                                                                   *
*......................................................................*



*----------------------------------------------------------------------*
*       FORM PRINT_PAPER                                               *
*----------------------------------------------------------------------*
*       Hauptform des Drucks                                           *
*       Alle Daten werden aus dem MEMORY importiert                    *
*----------------------------------------------------------------------*
*  -->  FORM        Name des SAPSCRIPT                                 *
*  -->  WWORKPAPER  Druckoptionen für SAPSCRIPT.                       *
*  -->  DATA STRUCTURES   Siehe Form DATA_IMPORT INCLUDE RIPRID01      *
*----------------------------------------------------------------------*
FORM print_paper.

  PERFORM data_import.              " Siehe INCLUDE RIPRID01
  PERFORM absenderland.             " Absenderland ermitteln
  PERFORM sender.                   " Anschrift ermitteln
  PERFORM infosatz.                 " Einkaufsinfosatz
  PERFORM partner                   " Sachbearbeiter
          TABLES notif_ihpad_tab.   "
  PERFORM read_catalogue_tables     " Kontroll Tabellen des QM lesen
          USING viqmel-qmart.       "
  PERFORM read_view_text_tables.    " Tabellen zu VIQMEL lesen

*Aufruf Smartforms - wenn SF-Formular nicht vorhanden wird SC aufgerufen
  clear form_kz.
  PERFORM sf_vorhanden CHANGING form_kz.
  IF NOT form_kz IS INITIAL.
    PERFORM main_print_sf.
  ELSE.
    PERFORM main_print.               " Brief-Druck
  ENDIF.

ENDFORM.                    "PRINT_PAPER


*$*$ MAIN PRINT SECTION CONTROLLED HERE................................
*... If you are making changes to Print ABAPS, (Naturally a copied
*... version) here is the place you can alter the logic and
*... and data supplied to the form.   You should not alter logic
*... before this point if you wish it to operate successfully
*... with the standard transactions
*... However if you wish the PRINT LOG to work you must take
*... care to make sure the LOG records are written to PMPP.
*......................................................................

FORM main_print.
*... Es wird ein Schreiben gedruck, das dafür gedacht ist es als
*... Reklamationsbericht an den Lieferanten zu versenden


  PERFORM open_form USING g_arc_type    "archive type
                          viqmel-qmnum  "notif number as key
                          ' '.          " New form for each position
  PERFORM lock_and_set         " Enque and determine copy number
          USING c_header.      " Overview logged at header level

  PERFORM set_title.

*... Variable PRINT_LANGUAGE setzen
  PERFORM define_variable USING 'PRINT_LANGUAGE' print_language.

  PERFORM repeat.              " Wiederholungsdruck
  PERFORM text1.               " 1. Text des Hauptteils

*... um zu verhindern, das die folgenden Textelemente nicht aus-
*... einandergerissen werden
  PERFORM sapscript_command USING  'PROTECT'.  "Nicht übersetzen
  DESCRIBE TABLE iviqmfe LINES g_anzahl.
  IF g_anzahl GT 0.
    PERFORM findings.                 " Überschrift für Fehlerliste

    MOVE space  TO iviqmfe.
    LOOP AT iviqmfe
           WHERE kzloesch = space.       " deleted position
*... drucke jeden Fehler
      MOVE-CORRESPONDING iviqmfe TO wqmfe.
*... die workarea für QMFE ist nun gefüllt (WQMFE)
      IF sy-tabix > 1.
        PERFORM skip_ausfuehren.
      ENDIF.
      IF NOT print_language IS INITIAL.
        PERFORM read_code_text USING tq80-fekat
                                     wqmfe-fegrp
                                     wqmfe-fecod
                                     wqmfe-fever
                            CHANGING wqmfe-txtcdgr.
      ENDIF.
      PERFORM defects.                " Druckt die Fehler
    ENDLOOP.
    PERFORM uline.                  " Unterstreichungslinie
  ENDIF.
*... beenden des Seitenumbruchschutzes
  PERFORM sapscript_command USING  'ENDPROTECT'.      "

*... um zu verhindern, das der Langtext und die Ulines nicht durch
*... einen Seitenumbruch auseinandergerissen werden
  PERFORM sapscript_command USING  'PROTECT'.  "Nicht übersetzen

  PERFORM remarks.                  " Langtext zur Q-Meldung

*... beenden des Seitenumbruchschutzes
  PERFORM sapscript_command USING  'ENDPROTECT'.      "

  PERFORM text2.                   " 2. Text des Hauptteils
  PERFORM text3.                   " 3. Text des Hauptteils

  PERFORM close_form.             " Schließt das Formular
  PERFORM unlock_and_log.         " Dequeue and Log print

ENDFORM.                    "MAIN_PRINT

*&---------------------------------------------------------------------*
*&      Form  sf_vorhanden
*&
*&      Prüfung ob Smartforms Formular in Tab. STXFADM
*&---------------------------------------------------------------------*
FORM sf_vorhanden CHANGING form_kz TYPE c.

  DATA: h_formname           TYPE tdsfname.
  DATA: lf_formname           TYPE tdsfname.

  IF NOT t390-form IS INITIAL.
    lf_formname = t390-form.
  ENDIF.

  SELECT SINGLE formname FROM stxfadm INTO h_formname
  WHERE formname = lf_formname.

  IF sy-subrc = 0. "formular da
    form_kz = 'x'.
  ENDIF.

ENDFORM.                    "sf_vorhanden

*&---------------------------------------------------------------------*
*&      Form  main_print_sf
*&
*&      Ausgabe Smartforms Formular
*&---------------------------------------------------------------------*
FORM main_print_sf.
  DATA: lf_fm_name            TYPE rs38l_fnam.
  DATA: ls_control_param      TYPE ssfctrlop.
  DATA: ls_composer_param     TYPE ssfcompop.
  DATA: ls_recipient          TYPE swotobjid.
  DATA: ls_sender             TYPE swotobjid.
  DATA: lf_formname           TYPE tdsfname.
  DATA: ls_addr_key           LIKE addr_key.
  DATA: gv_language           LIKE thead-tdspras.
  DATA: retcode               LIKE sy-subrc.         "Returncode


*  PERFORM set_print_param USING      addr_key
*                            CHANGING ls_control_param
*                                     ls_composer_param
*                                     ls_recipient
*                                     ls_sender
*                                     retcode.



*Get the Smart Form name.
  IF NOT t390-form IS INITIAL.
    lf_formname = t390-form.
  ELSE.
    MESSAGE e001(ssfcomposer).
  ENDIF.

* Determine smartform function module for purchase document
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = lf_formname
    IMPORTING
      fm_name            = lf_fm_name
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
    MESSAGE e001(ssfcomposer).
*    PERFORM protocol_update_i.
  ENDIF.


** if it is faxed, changed its title to PO number
*  IF ls_control_param-device = 'TELEFAX'.
*    ls_composer_param-tdtitle = l_doc-xekko-ebeln.
*  ENDIF.
*
** if it is mail, changed its title to PO number
*  IF ls_control_param-device = 'MAIL'.
*    ls_composer_param-tdtitle = l_doc-xekko-ebeln.
*  ENDIF.

  PERFORM set_title.

*... Variable PRINT_LANGUAGE setzen
* PERFORM define_variable USING 'PRINT_LANGUAGE' print_language.

  toa_dara       = g_toa_dara_tab.
  arc_params     = g_arc_params_tab.
*      DEVICE         = DEST_DEVICE
  gv_language    = wworkpaper-print_lang. "PRINT_LANGUAGE.
  ls_control_param-langu = wworkpaper-print_lang.

*      OPTIONS        = ITCPO.

  DESCRIBE TABLE iviqmfe LINES g_anzahl.

*>>>>> Change of Parameters <<<<<<<<<<<<<<<<<<<<<<<
  CALL FUNCTION lf_fm_name
    EXPORTING
      archive_index      = toa_dara
      archive_parameters = arc_params
      control_parameters = ls_control_param
      mail_recipient     = ls_recipient
      mail_sender        = ls_sender
      output_options     = ls_composer_param
      user_settings      = ' '  "Disable User Printer
*      is_pekko           = l_doc-xpekko
      gv_language        = gv_language
      g_repeat           = g_repeat
      g_anzahl           = g_anzahl
      is_viqmel          = viqmel
      is_lfa1            = lfa1
      is_eina            = eina
      is_ihpad           = ihpad
      is_riwo00          = riwo00
*      is_wqmfe           = wqmfe
      is_wiprt           = wiprt
      is_t390            = t390
     TABLES
      t_wqmfe            = iviqmfe
     EXCEPTIONS
      formatting_error   = 1
      internal_error     = 2
      send_error         = 3
      user_canceled      = 4
      OTHERS             = 5.

*  IF sy-subrc <> 0.
*
*  ENDIF.

ENDFORM.                    "MAIN_PRINT_sf

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
**ins ini
  DATA : nast TYPE nast.
**ins fin
  lf_repid = sy-repid.

  CALL FUNCTION 'WFMC_PREPARE_SMART_FORM'
    EXPORTING
**uncomment
      pi_nast       = nast             "#EC FB_PAR_MIS
**uncomment
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
*    cs_control_param-preview     = xscreen.
    cs_control_param-getotf      = ls_itcpo-tdgetotf.
*    cs_control_param-langu       = print_language.
    cs_control_param-langu       = wworkpaper-print_lang.
  ENDIF.

ENDFORM.                               " set_print_param

*$*$   F O R M    R O U T I N E S -------------------------------------*

*...   Spezielle Formroutinen

INCLUDE riprif01.                     " General PRINT routines
INCLUDE riprifqm.                     " Special QM routines

*.......................................................................



*$*$ G E N E R A L     F O R M     R O U T I N E S ....................*



*&---------------------------------------------------------------------*
*&      Form  FINDINGS
*&---------------------------------------------------------------------*
FORM findings.

  CALL FUNCTION 'WRITE_FORM'  " Druckt die Überschrift für den Befund
       EXPORTING
            element   = 'FINDINGS'
            window    = 'MAIN'.

ENDFORM.                    " FINDINGS

*&---------------------------------------------------------------------*
*&      Form  REMARKS
*&---------------------------------------------------------------------*
*  Druck den Langtexdt der Q-Meldung                                   *
*----------------------------------------------------------------------*
FORM remarks.


*... Langtext zum Meldungskopf
  IF NOT viqmel-indtx IS INITIAL.   "gibt es überhaupt einen Langtext

    CALL FUNCTION 'WRITE_FORM'   " Druckt eine Überschrift zum Langtext
         EXPORTING
              element   = 'REMARKS'
              window    = 'MAIN'.


*... setzt den Textnamen zusammen
    text_object_name = viqmel-qmnum.
    CONDENSE text_object_name NO-GAPS.

*... druckt den Langtext
    PERFORM print_longtext USING c_qmel
                                 text_object_name
                                 viqmel-kzmla
                                 ltxt_id
                                 c_main
                                 c_start_line_nr
                                 c_last_line_nr
                                 no.   "with underline around text


  ENDIF.



ENDFORM.                    " BEMERKUNG

*&---------------------------------------------------------------------*
*&      Form  DEFECTS
*&---------------------------------------------------------------------*
*  Listet die Fehlersätze auf                                          *
*----------------------------------------------------------------------*
FORM defects.

  PERFORM textkey_qmfe.
  CALL FUNCTION 'WRITE_FORM'  " Druckt eine Fehlerliste
       EXPORTING
            element   = 'DEFECTS'
            window    = 'MAIN'.


ENDFORM.                    " FEHLERLISTE

*&---------------------------------------------------------------------*
*&      Form  TEXT1
*&---------------------------------------------------------------------*
*       Gibt einen Text aus                                            *
*----------------------------------------------------------------------*
FORM text1.

  CALL FUNCTION 'WRITE_FORM'  " Druckt einen Text
       EXPORTING
            element   = 'TEXT1'
            window    = 'MAIN'.

ENDFORM.                                                    " TEXT1

*&---------------------------------------------------------------------*
*&      Form  UNDERLINE
*&---------------------------------------------------------------------*
*      Gibt eine ULINE aus                                             *
*----------------------------------------------------------------------*
FORM underline.

  DATA: l_underscore_str(80) VALUE
  '______________________________________________________________'.


  WRITE l_underscore_str  TO wiprt-colhd.    " Underline
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element = 'UNDERLINE'
      window  = 'MAIN'.


ENDFORM.                    " UNDERLINE

*&---------------------------------------------------------------------*
*&      Form  TEXT2
*&---------------------------------------------------------------------*
*       Gibt einen Text aus                                            *
*----------------------------------------------------------------------*
FORM text2.

  CALL FUNCTION 'WRITE_FORM'  " Druckt einen Text
       EXPORTING
            element   = 'TEXT2'
            window    = 'MAIN'.

ENDFORM.                                                    " TEXT2

*&---------------------------------------------------------------------*
*&      Form  TEXTKEY_QMFE
*&---------------------------------------------------------------------*
* generiert den Textschlüssel für Positionen                           *
*----------------------------------------------------------------------*
FORM textkey_qmfe.

*... Langtext zur Position

*... Textschlüssel zusammen bauen
  text_object_name+0(12) = wqmfe-qmnum.
  text_object_name+12(4) = wqmfe-fenum.
  CONDENSE text_object_name NO-GAPS.

  PERFORM define_variable USING 'TEXT_QMFE' text_object_name.


ENDFORM.                    " TEXTKEY_QMFE

*&---------------------------------------------------------------------*
*&      Form  DEFINE_VARIABLE
*&---------------------------------------------------------------------*
* Textschlüssel ans Formular schicken                                  *
*----------------------------------------------------------------------*
* --> P_NAME     name of the DEFINE                                    *
* --> P_CONTENT  Value of the defined variable                         *
*----------------------------------------------------------------------*
FORM define_variable USING value(p_name)
                          value(p_content).
*
  DATA: BEGIN OF command,
          x1(8)              VALUE 'DEFINE',
          x2(30),
          x3(3)              VALUE ' = ',
          x4 LIKE thead-tdname,
        END OF command,
        length TYPE i.
  FIELD-SYMBOLS: <l_f>.
*
  MOVE p_name TO command-x2.
  SHIFT command-x2 RIGHT.
  MOVE '&' TO command-x2(1).
  length = STRLEN( command-x2 ).
  ASSIGN command-x2+length(1) TO <l_f>.
  MOVE '&' TO <l_f>.
*
  MOVE p_content TO command-x4.
  SHIFT command-x4 RIGHT.
  MOVE '''' TO command-x4(1).
  length = STRLEN( command-x4 ).
  ASSIGN command-x4+length(1) TO <l_f>.
  MOVE '''' TO <l_f>.
*
  CALL FUNCTION 'CONTROL_FORM'
    EXPORTING
      command = command.
*

ENDFORM.                    " DEFINE_VARIABLE

*&---------------------------------------------------------------------*
*&      Form  ABSENDERLAND
*&---------------------------------------------------------------------*
* Absenderland ermitteln                                               *
*----------------------------------------------------------------------*
FORM absenderland.

  SELECT SINGLE * FROM t024e WHERE ekorg EQ viqmel-ekorg.
  SELECT SINGLE * FROM t001 WHERE bukrs EQ t024e-bukrs.

ENDFORM.                    " ABSENDERLAND

*&---------------------------------------------------------------------*
*&      Form  SENDER
*&---------------------------------------------------------------------*
* Absender ermittel                                                    *
*----------------------------------------------------------------------*
FORM sender.

  DATA: l_addr1_sel LIKE addr1_sel.

  IF viqmel-adrnr IS INITIAL.
    READ TABLE ihpad_tab WITH KEY parvw = tq80-parvw_lief.
    IF sy-subrc = 0.
      viqmel-adrnr = ihpad_tab-adrnr.
    ENDIF.
  ENDIF.

  IF viqmel-adrnr IS INITIAL.
    SELECT SINGLE * FROM lfa1 WHERE
          lifnr = viqmel-lifnum.
    IF wworkpaper-print_lang IS INITIAL.
      MOVE lfa1-spras TO wworkpaper-print_lang.
    ENDIF.
*--- will man faxen, so muß die Faxnummer auf dem Druckwindow angegeben
*--- werden, da hier vorher eine Prüfung stattfindet, ob der angegebe
*--- Drucker ein Faxgerät ist. Denn SAPSCRIPT will immer faxen, wenn das
*--- Feld wworkpaper-tdtelenum gefüllt ist
*--- Zu 4.0 kann die Lieferantenfaxnummer ganz einfach über F4
*--- auf dem Drucksteuerwindow eingetragen werden
*  if wworkpaper-tdtelenum is initial.
*    move lfa1-telfx to wworkpaper-tdtelenum.
*  endif.
  ELSE.
    MOVE viqmel-adrnr TO l_addr1_sel-addrnumber.
    CALL FUNCTION 'ADDR_GET'
         EXPORTING
              address_selection       = l_addr1_sel
*            ADDRESS_GROUP           =
*            READ_SADR_ONLY          = ' '
*            READ_TEXTS              = ' '
         IMPORTING
*            ADDRESS_VALUE           =
*            ADDRESS_ADDITIONAL_INFO =
*            RETURNCODE              =
*            ADDRESS_TEXT            =
              sadr                    = sadr.
*       TABLES
*            ADDRESS_GROUPS          =
*            ERROR_TABLE             =
*            VERSIONS                =
*       EXCEPTIONS
*            PARAMETER_ERROR         = 1
*            ADDRESS_NOT_EXIST       = 2
*            VERSION_NOT_EXIST       = 3
*            INTERNAL_ERROR          = 4
*            OTHERS                  = 5

*  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  endif.


    IF wworkpaper-print_lang IS INITIAL.
      MOVE sadr-spras TO wworkpaper-print_lang.
    ENDIF.
*--- will man faxen, so muß die Faxnummer auf dem Druckwindow angegeben
*--- werden, da hier vorher eine Prüfung stattfindet, ob der angegebe
*--- Drucker ein Faxgerät ist. Denn SAPSCRIPT will immer faxen, wenn das
*--- Feld wworkpaper-tdtelenum gefüllt ist
*--- Zu 4.0 kann die Lieferantenfaxnummer ganz einfach über F4
*--- auf dem Drucksteuerwindow eingetragen werden
*  if wworkpaper-tdtelenum is initial.
*    move sadr-telfx to wworkpaper-tdtelenum.
*  endif.
  ENDIF.


ENDFORM.                    " SENDER
*&---------------------------------------------------------------------*
*&      Form  INFOSATZ
*&---------------------------------------------------------------------*
* Einkaufsinfosatz                                                     *
*----------------------------------------------------------------------*
FORM infosatz.

  meico-lifnr = viqmel-lifnum.
  meico-matnr = viqmel-matnr.

  CALL FUNCTION 'ME_READ_INFORECORD'
       EXPORTING
          incom             = meico
*         INPREISSIM        = ' '
       IMPORTING
*         daten             =
          einadaten         = eina
*         einedaten         =
*         excom             =
*         expreissim        =
       EXCEPTIONS
          bad_comin         = 1
          bad_material      = 2
          bad_materialclass = 3
          bad_supplier      = 4
          not_found         = 5
          OTHERS            = 6.

ENDFORM.                    " INFOSATZ
*&---------------------------------------------------------------------*
*&      Form  TEXT3
*&---------------------------------------------------------------------*
*       Gibt einen Text aus
*----------------------------------------------------------------------*
FORM text3.

  CALL FUNCTION 'WRITE_FORM'  " Druckt einen Text
       EXPORTING
            element   = 'TEXT3'
            window    = 'MAIN'.

ENDFORM.                                                    " TEXT3
*&---------------------------------------------------------------------*
*&      Form  REPEAT
*&---------------------------------------------------------------------*
* Wiederholungsdruck                                                   *
*----------------------------------------------------------------------*
FORM repeat.

  IF g_repeat GT 1.
    CALL FUNCTION 'WRITE_FORM'  " Druckt einen Text
        EXPORTING
           element   = 'REPEAT'
           window    = 'REPEAT'.
  ENDIF.

ENDFORM.                    " REPEAT
*&---------------------------------------------------------------------*
*&      Form  SKIP_AUSFUEHREN
*&---------------------------------------------------------------------*
FORM skip_ausfuehren.

  CALL FUNCTION 'WRITE_FORM'  " Druckt eine Leerzeile
      EXPORTING
         element   = 'SKIP'
         window    = 'MAIN'.

ENDFORM.                    " SKIP_AUSFUEHREN
*&---------------------------------------------------------------------*
*&      Form  PARTNER
*&---------------------------------------------------------------------*
* Sachbearbeiter ermitteln                                             *
* das Programm ermittelt als verantwortlichen Sachbearbeiter den       *
* Partner, der als erster die Partnerrolle besitzt, die in der Tabelle *
* TQ80 als Verantwortlicher angegeben ist                              *
*----------------------------------------------------------------------*
FORM partner TABLES ihpad_loc STRUCTURE ihpad.

  LOOP AT ihpad_loc
     WHERE parvw = tq80-parvw_vera.
    ihpad = ihpad_loc.        " only can pass ddic fields to SAPSCRIPT
    EXIT.
  ENDLOOP.

ENDFORM.                    " PARTNER
*&---------------------------------------------------------------------*
*&      Form  ULINE
*&---------------------------------------------------------------------*
* UNTERSTRICH                                                          *
*----------------------------------------------------------------------*
FORM uline.

  CALL FUNCTION 'WRITE_FORM'  " Druckt eine Leerzeile
      EXPORTING
         element   = 'ULINE'
         window    = 'MAIN'.

ENDFORM.                    " ULINE
