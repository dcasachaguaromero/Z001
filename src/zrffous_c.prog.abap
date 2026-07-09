*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
************************************************************************
*                                                                      *
*  Check print program RFFOUS_C                                        *
*                                                                      *
************************************************************************


*----------------------------------------------------------------------*
* Program includes:                                                    *
*                                                                      *
* RFFORI0M  Definition of macros                                       *
* RFFORI00  international data definitions                             *
* RFFORI01  check                                                      *
* ZRFFORI06  remittance advice                                         *
* RFFORI07  payment summary list                                       *
* RFFORI99  international subroutines                                  *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* report header                                                        *
*----------------------------------------------------------------------*
REPORT rffous_c
  LINE-SIZE 132
  MESSAGE-ID f0
  NO STANDARD PAGE HEADING.

*----------------------------------------------------------------------*
*  segments and tables for prenumbered checks                          *
*----------------------------------------------------------------------*
TABLES:
  reguh,
  regup,
  t001z,
  bseg,
  adrc,
  zfipg002_det,
  zfipg003.

DATA: BEGIN OF datos_det OCCURS 30.
        INCLUDE STRUCTURE zform2016cheq_vdet_est.
DATA: END OF datos_det.

DATA : BEGIN OF t_bseg OCCURS 0,
         belnr LIKE bseg-belnr,
         koart LIKE bseg-koart,
         hkont LIKE bseg-hkont,
         sgtxt LIKE bseg-sgtxt,
         stcd1 LIKE reguh-stcd1,
         ort01 LIKE lfa1-ort01,
         shkzg LIKE bseg-shkzg,
         dmbtr LIKE bseg-dmbtr,
         zfbdt LIKE bseg-zfbdt,
         xblnr LIKE bkpf-xblnr,
         debe(12),
         haber(12),
       END OF t_bseg.
DATA : wa_debe   LIKE bseg-dmbtr,
       wa_haber  LIKE bseg-dmbtr,
       wa_debe2  LIKE bseg-dmbtr,
       wa_haber2 LIKE bseg-dmbtr.

DATA: v_totalchq TYPE regud-swnes.
DATA: z_indhab(1).
DATA: v_cont TYPE i.
DATA: v_debe(20).
DATA: v_haber(20).
DATA: a.
DATA: v_lifnr LIKE reguh-lifnr.
DATA: v_banco(1).
DATA: v_stcd1 LIKE reguh-stcd1.
DATA: v_sgtxt TYPE sgtxt.
DATA: v_dmbtr TYPE dmbtr.
DATA: v_negativo(20).
DATA: v_desc_agen(40).
DATA: v_desc_mot(40).

DATA: ti_regup   LIKE regup OCCURS 0 WITH HEADER LINE.
DATA: ti_regupnc LIKE regup OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF rut_impr OCCURS 0,
      stcd1 LIKE reguh-stcd1.
DATA: END OF rut_impr.

*Tabla que controlará la impresión de la Caratula de de los Cheques sin Voucher.
DATA: BEGIN OF ti_aviso OCCURS 0.
        INCLUDE STRUCTURE zchq_aviso.
DATA: END OF ti_aviso.
DATA: v_aviso(1).
DATA: v_xblnr TYPE xblnr.
DATA: v_tabix2 LIKE sy-tabix.

DATA: v_znm1s(60),
      v1_znm1s(70),
      v2_znm1s(70),
      v3_znm1s(70),
      v4_znm1s(70).
DATA: v_znm2s(35).

DATA: ncheques(6) TYPE n,
      tchq(6) TYPE n,
      titulo(68).
* cheques
DATA: reguh1   LIKE reguh OCCURS 0 WITH HEADER LINE.
DATA: regud1   LIKE regud OCCURS 0 WITH HEADER LINE.
DATA: reguh2   LIKE reguh OCCURS 0 WITH HEADER LINE.
DATA: regud2   LIKE regud OCCURS 0 WITH HEADER LINE.
DATA: reguh3   LIKE reguh OCCURS 0 WITH HEADER LINE.
DATA: regud3   LIKE regud OCCURS 0 WITH HEADER LINE.
DATA: reguh4   LIKE reguh OCCURS 0 WITH HEADER LINE.
DATA: regud4   LIKE regud OCCURS 0 WITH HEADER LINE.

DATA: spell1 LIKE spell OCCURS 0 WITH HEADER LINE.
DATA: spell2 LIKE spell OCCURS 0 WITH HEADER LINE.
DATA: spell3 LIKE spell OCCURS 0 WITH HEADER LINE.
DATA: spell4 LIKE spell OCCURS 0 WITH HEADER LINE.
DATA: fm1(20) TYPE c.
DATA: fm2(20) TYPE c.

DATA: v_cheque TYPE i.
DATA: v_scheque(6) TYPE c.
DATA: vname1 LIKE reguh-name1.
DATA: it_zconfchk LIKE zconfchk OCCURS 0 WITH HEADER LINE.


* Tabellen fÃ¼r den Angabeteil von Auslandsschecks in Ã–sterreich
* Austria only
DATA:
  BEGIN OF up_oenb_angaben OCCURS 5, "Angaben zur OeNB-Meldung
    diekz    LIKE regup-diekz,       "Anmerkung: die betragshÃ¶chste
    lzbkz    LIKE regup-lzbkz,       "Angabe wird auf den Angabenteil
    summe(7) TYPE p,                 "Ã¼bernommen
  END OF up_oenb_angaben,
  BEGIN OF up_oenb_kontowae OCCURS 5,"KontowÃ¤hrung der Hausbankkonten
    ubhkt    LIKE reguh-ubhkt,       "fÃ¼r die OeNB-Meldung
    uwaer    LIKE t012k-waers,
  END OF up_oenb_kontowae.

DATA: v_max TYPE i VALUE 14.

DATA: v_acumula(1).
DATA: v_totlin LIKE regup-dmbtr.
DATA: v_doctos(500).
DATA: v_group(1).
DATA: v_largo TYPE i,
      f_largo(3) TYPE n,
      f1_largo(3) TYPE n,
      f2_largo(3) TYPE n,
      f3_largo(3) TYPE n,
      f4_largo(3) TYPE n,
      largotot(3) TYPE n VALUE 50,
      v_nomban LIKE bnka-banka,
      v_cruzado(3) VALUE '   ',
      v1_cruzado(3) VALUE '   ',
      v2_cruzado(3) VALUE '   ',
      v3_cruzado(3) VALUE '   ',
      v4_cruzado(3) VALUE '   ',
      v1_desc_agen LIKE bseg-zz_agencia,
      v2_desc_agen LIKE bseg-zz_agencia,
      v3_desc_agen LIKE bseg-zz_agencia,
      v4_desc_agen LIKE bseg-zz_agencia,
      v1_desc_mot LIKE bseg-zzmot_emis,
      v2_desc_mot LIKE bseg-zzmot_emis,
      v3_desc_mot LIKE bseg-zzmot_emis,
      v4_desc_mot LIKE bseg-zzmot_emis.

*modificacion herman flag
*inicio
DATA: i_flag TYPE statusflag1,
      i_cont TYPE i.
*fin

DATA: vari_desc TYPE varid,
      param     TYPE rsparams OCCURS 0 WITH HEADER LINE,
      param2    TYPE rsparams OCCURS 0 WITH HEADER LINE.
DATA: iname     TYPE stxbitmaps-tdname.
*----------------------------------------------------------------------*
*  macro definitions                                                   *
*----------------------------------------------------------------------*
INCLUDE rffori0m.

INITIALIZATION.

*  CALL FUNCTION 'RS_VARIANT_CONTENTS'
*    EXPORTING
*      report                      = sy-cprog
*      variant                     = sy-slset
**   MOVE_OR_WRITE               = 'W'
**   NO_IMPORT                   = ' '
**   EXECUTE_DIRECT              = ' '
** IMPORTING
**   SP                          =
*    TABLES
**   L_PARAMS                    =
**   L_PARAMS_NONV               =
**   L_SELOP                     =
**   L_SELOP_NONV                =
*      valutab                     = param[]
**   OBJECTS                     =
**   FREE_SELECTIONS_DESC        =
**   FREE_SELECTIONS_VALUE       =
** EXCEPTIONS
**   VARIANT_NON_EXISTENT        = 1
**   VARIANT_OBSOLETE            = 2
**   OTHERS                      = 3
*            .
*  IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.
*
*  SELECT * UP TO 1 ROWS
*  FROM varid
*  INTO vari_desc
*  WHERE report = sy-cprog
*  AND variant = sy-slset.
*  ENDSELECT.
*
*  CHECK sy-subrc EQ 0.
*
*  LOOP AT param.
*    CASE param-selname.
*      WHEN 'PAR_NEUD'.
*        CLEAR param-low.
*      WHEN 'PAR_CHKF'.
*        CLEAR: param-low, param-high.
*      WHEN 'PAR_VOID'.
*        CLEAR: param-low.
*      WHEN 'ZW_LAUFD'.
*        IF param-low IS INITIAL OR param-low = '00....00..' OR param-low = '00.00.0000'.
*          CLEAR: param-low.
*        ELSE.
*          CONCATENATE param-low+6 param-low+3(2) param-low(2) INTO param-low.
*        ENDIF.
*    ENDCASE.
*
*    APPEND param TO param2.
*
*  ENDLOOP.

*  CALL FUNCTION 'RS_CHANGE_CREATED_VARIANT'
*    EXPORTING
*      curr_report                     = sy-cprog
*      curr_variant                    = sy-slset
*      vari_desc                       = vari_desc
**   ONLY_CONTENTS                   =
*    TABLES
*      vari_contents                   = param2[]
**   VARI_TEXT                       =
**   VARI_SEL_DESC                   =
**   OBJECTS                         =
** EXCEPTIONS
**   ILLEGAL_REPORT_OR_VARIANT       = 1
**   ILLEGAL_VARIANTNAME             = 2
**   NOT_AUTHORIZED                  = 3
**   NOT_EXECUTED                    = 4
**   REPORT_NOT_EXISTENT             = 5
**   REPORT_NOT_SUPPLIED             = 6
**   VARIANT_DOESNT_EXIST            = 7
**   VARIANT_LOCKED                  = 8
**   SELECTIONS_NO_MATCH             = 9
**   OTHERS                          = 10
*            .
*  IF sy-subrc <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*  ENDIF.




*----------------------------------------------------------------------*
*  parameters and select-options                                       *
*----------------------------------------------------------------------*
  block 1.
  SELECT-OPTIONS:
    sel_zawe FOR  reguh-rzawe,              "payment method
    sel_uzaw FOR  reguh-uzawe,              "payment method supplement
    sel_gsbr FOR  reguh-srtgb,              "business area
    sel_hbki FOR  reguh-hbkid NO-EXTENSION NO INTERVALS, "house bank id
    sel_hkti FOR  reguh-hktid NO-EXTENSION NO INTERVALS. "account id
  SELECTION-SCREEN:
    BEGIN OF LINE,
    COMMENT 01(30) text-106 FOR FIELD par_stap,
    POSITION POS_LOW.
  PARAMETERS:
    par_stap LIKE rfpdo-fordstap.           "check lot number
  SELECTION-SCREEN:
    COMMENT 40(30) textinfo FOR FIELD par_stap,
    END OF LINE.
  PARAMETERS:
    par_rchk LIKE rfpdo-fordrchk.           "Restart from
  SELECT-OPTIONS:
    sel_waer FOR  reguh-waers,              "currency
    sel_vbln FOR  reguh-vblnr.              "payment document number
  SELECTION-SCREEN END OF BLOCK 1.

  block 2.
  auswahl: zdru z, avis a, begl b.
  spool_authority.                     "Spoolberechtigung
  SELECTION-SCREEN END OF BLOCK 2.

  block 3.
  PARAMETERS:
    par_zfor LIKE rfpdo1-fordzfor,          "different form
    par_fill LIKE rfpdo2-fordfill,          "filler for spell_amount
    par_anzp LIKE rfpdo-fordanzp,           "number of test prints
    par_maxp LIKE rfpdo-fordmaxp,           "no of items in summary list
    par_belp LIKE rfpdo-fordbelp,           "payment doc. validation
    par_espr LIKE rfpdo-fordespr,           "texts in reciepient's lang.
    par_isoc LIKE rfpdo-fordisoc,           "currency in ISO code
    par_nosu LIKE rfpdo2-fordnosu,          "no summary page
    par_novo LIKE rfpdo2-fordnovo.          "no voiding of checks
  SELECTION-SCREEN END OF BLOCK 3.

  SELECTION-SCREEN:
    BEGIN OF BLOCK 4 WITH FRAME TITLE text-100,
    BEGIN OF LINE.
  PARAMETERS:
    par_neud AS CHECKBOX.
*    par_neud AS CHECKBOX DEFAULT ''.
  SELECTION-SCREEN:
    COMMENT 03(70) text-101 FOR FIELD par_neud ,
    END OF LINE,
    BEGIN OF LINE,
    COMMENT 01(31) textchkf FOR FIELD par_chkf,
    POSITION POS_LOW.
  PARAMETERS:
    par_chkf LIKE payr-checf DEFAULT space.
  SELECTION-SCREEN:
    COMMENT 52(05) textchkt FOR FIELD par_chkt,
    POSITION POS_HIGH.
  PARAMETERS:
    par_chkt LIKE payr-chect.
  SELECTION-SCREEN:
    END OF LINE,
    BEGIN OF LINE,
    COMMENT 01(30) text-107 FOR FIELD par_void,
    POSITION POS_LOW.
  PARAMETERS:
    par_void LIKE payr-voidr.
*    par_void LIKE payr-voidr DEFAULT space.
  SELECTION-SCREEN:
    COMMENT 38(30) textvoid FOR FIELD par_void,
    END OF LINE,
    END OF BLOCK 4.

  PARAMETERS:
    par_xdta LIKE rfpdo-fordxdta  NO-DISPLAY,
    par_priw LIKE rfpdo-fordpriw  NO-DISPLAY,
    par_sofw LIKE rfpdo1-fordsofw NO-DISPLAY,
    par_dtyp LIKE rfpdo-forddtyp  NO-DISPLAY,
    par_unix LIKE rfpdo2-fordnamd NO-DISPLAY,
    par_nenq(1)  TYPE c           NO-DISPLAY,
    par_vari(14) TYPE c           NO-DISPLAY,
    par_sofo(1)  TYPE c           NO-DISPLAY.


*----------------------------------------------------------------------*
*  Default values for parameters and select-options                    *
*----------------------------------------------------------------------*
  PERFORM init.
  PERFORM text(sapdbpyf) USING 102 textzdru.
  PERFORM text(rfchkl00) USING: textchkf 200, textchkt 201.
  sel_zawe-low    = 'C'.
  sel_zawe-option = 'EQ'.
  sel_zawe-sign   = 'I'.
  APPEND sel_zawe.

  par_belp = space.
  par_zdru = 'X'.
  par_xdta = space.
  par_dtyp = space.
  par_avis = space.
  par_begl = 'X'.
  par_fill = space.
  par_anzp = 2.
  par_espr = space.
  par_isoc = space.
  par_maxp = 9999.

*----------------------------------------------------------------------*
*  tables / fields / field-groups / at selection-screen                *
*----------------------------------------------------------------------*
  INCLUDE rffori00.

* AT SELECTION-SCREEN.

  PERFORM scheckdaten_eingabe USING par_rchk
                                    par_stap
                                    textinfo.

  textvoid = space.
  IF par_neud EQ 'X'.                    "Neu drucken / reprint
    IF par_rchk NE space.
      SET CURSOR FIELD 'PAR_RCHK'.
      MESSAGE e561(fs).                  "kein Neu drucken bei Restart
    ENDIF.                               "no reprint in restart mode
    IF zw_xvorl NE space.
      SET CURSOR FIELD 'ZW_XVORL'.
      MESSAGE e561(fs).                  "kein Neu drucken bei Vorschlag
    ENDIF.                               "no reprint if proposal run
    IF par_chkf EQ space AND par_chkt NE space.
      par_chkf = par_chkt.
    ENDIF.
    IF par_chkt EQ space.
      par_chkt = par_chkf.
    ENDIF.
    IF par_chkt LT par_chkf.
      SET CURSOR FIELD 'PAR_CHKF'.
      MESSAGE e650(db).
    ENDIF.
    IF par_chkf NE space OR par_void NE 0.
      IF par_chkf EQ space.
        SET CURSOR FIELD 'PAR_CHKF'.
        MESSAGE e055(00).
      ENDIF.
      SELECT * FROM payr UP TO 1 ROWS    "im angegebenen Intervall mÃ¼ssen
        WHERE zbukr EQ zw_zbukr-low      "Schecks vorhanden sein
        AND hbkid EQ sel_hbki-low        "check interval is not allowed to
          AND hktid EQ sel_hkti-low      "be empty
          AND checf LE par_chkt
          AND chect GE par_chkf
          AND ichec EQ space
          AND voidr EQ 0
          AND xbanc EQ space.
      ENDSELECT.
      IF sy-subrc NE 0.
        SET CURSOR FIELD 'PAR_CHKF'.
        MESSAGE e509(fs).
      ENDIF.
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM tvoid WHERE voidr EQ par_void.
**
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM tvoid WHERE voidr EQ par_void ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc NE 0 OR tvoid-xsyse NE space.
        SET CURSOR FIELD 'PAR_VOID'.
        MESSAGE e539(fs).
      ELSE.
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM tvoit
*          WHERE langu EQ sy-langu AND voidr EQ par_void.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM tvoit
          WHERE langu EQ sy-langu AND voidr EQ par_void ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        textvoid = tvoit-voidt.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR:
      par_chkf,
      par_chkt,
      par_void.
  ENDIF.



AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 EQ 1.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
    IF screen-name EQ 'ZW_ZBUKR-HIGH' OR
       screen-name EQ '%_ZW_ZBUKR_%_APP_%-VALU_PUSH'.
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_stap.
  CALL FUNCTION 'F4_CHECK_LOT'
    EXPORTING
      i_xdynp      = 'X'
      i_dynp_progn = 'RFFOUS_C'
      i_dynp_dynnr = '1000'
      i_dynp_zbukr = 'ZW_ZBUKR-LOW'
      i_dynp_hbkid = 'SEL_HBKI-LOW'
      i_dynp_hktid = 'SEL_HKTI-LOW'
    IMPORTING
      e_stapl      = par_stap
    EXCEPTIONS
      OTHERS       = 0.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_zfor.
  PERFORM f4_formular USING par_zfor.

AT SELECTION-SCREEN ON par_zfor.
  IF par_zfor NE space.
    SET CURSOR FIELD 'PAR_ZFOR'.
    CALL FUNCTION 'FORM_CHECK'
      EXPORTING
        i_pzfor = par_zfor.
  ENDIF.

*----------------------------------------------------------------------*
*  batch heading (for the payment summary list)                        *
*----------------------------------------------------------------------*
TOP-OF-PAGE.

  IF flg_begleitl EQ 1.
    PERFORM kopf_zeilen.                                    "RFFORI07
  ENDIF.

*----------------------------------------------------------------------*
*  preparations                                                        *
*----------------------------------------------------------------------*
START-OF-SELECTION.

  hlp_auth  = par_auth.                "spool authority
  hlp_temse  = '----------'.           "Keine TemSe-Verwendung
  hlp_filler = par_fill.
  hlp_ep_element = '525'.    " note 794910

  i_flag  = space.                     "Flag de Borrado de Firma

*  DATA: var(1) VALUE 'X'.
*  WHILE var = 'X'.
*  ENDWHILE.

*************************************************************************
* Se llena las variables fm1 y fm2 para las variantes que no tienen cheque
* igual llene las variables y borre las firmas al salir
* CII - 20100817
*************************************************************************
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE tdname
*    FROM zfirmadigital
*    INTO fm1
*    WHERE bukrs EQ zw_zbukr-low
*    AND orden EQ 1.
*
* NEW CODE
  SELECT tdname
  UP TO 1 ROWS 
    FROM zfirmadigital
    INTO fm1
    WHERE bukrs EQ zw_zbukr-low
    AND orden EQ 1 ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE tdname
*    FROM zfirmadigital
*    INTO fm2
*    WHERE bukrs EQ zw_zbukr-low
*    AND orden EQ 2.
*
* NEW CODE
  SELECT tdname
  UP TO 1 ROWS 
    FROM zfirmadigital
    INTO fm2
    WHERE bukrs EQ zw_zbukr-low
    AND orden EQ 2 ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*************************************************************************

  PERFORM vorbereitung.

  PERFORM scheckdaten_pruefen USING par_rchk
                                    par_stap.

  IF zw_xvorl EQ space AND par_zdru NE space AND par_neud NE space.
    IF par_chkf NE space.
      flg_neud = 1.                    "neu drucken durchs Druckprogramm
      REFRESH tab_check.               "print program reprints checks
      tab_check-option = 'EQ'.
      tab_check-sign   = 'I'.
      tab_check-high   = space.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT * FROM payr
*        WHERE zbukr EQ zw_zbukr-low
*          AND hbkid EQ sel_hbki-low
*          AND hktid EQ sel_hkti-low
*          AND checf LE par_chkt
*          AND chect GE par_chkf
*          AND ichec EQ space
*          AND voidr EQ 0
*          AND xbanc EQ space.
*
* NEW CODE
      SELECT *
 FROM payr
        WHERE zbukr EQ zw_zbukr-low
          AND hbkid EQ sel_hbki-low
          AND hktid EQ sel_hkti-low
          AND checf LE par_chkt
          AND chect GE par_chkf
          AND ichec EQ space
          AND voidr EQ 0
          AND xbanc EQ space ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
        tab_check-low = payr-checf.
        APPEND tab_check.
      ENDSELECT.
      INSERT *payr INTO daten.
    ELSE.
      REFRESH tab_check.
      flg_neud = 2.
    ENDIF.
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM tvoid WHERE voidr EQ par_void.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM tvoid WHERE voidr EQ par_void ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.

  IF par_zdru EQ 'X'.
    IF sy-calld EQ space.              "fremder Enqueue nur wenn
      par_nenq = space.                "Programm gerufen wurde
    ENDIF.                             "foreign enqueue only if called
    IF par_nenq EQ space.
      PERFORM schecknummern_sperren.                        "RFFORI01
    ELSE.
      par_anzp = 0.         "sonst funktioniert die Umnumerierung nicht
    ENDIF.
  ENDIF.



*----------------------------------------------------------------------*
*  check and extract data                                              *
*----------------------------------------------------------------------*
GET reguh.

  CHECK sel_zawe.
  CHECK sel_uzaw.
  CHECK sel_gsbr.
  CHECK sel_hbki.
  CHECK sel_hkti.
  CHECK sel_waer.
  CHECK sel_vbln.

  CLEAR titulo.

  tchq = 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE *  FROM zfipg002_det
*                              WHERE laufd = zw_laufd
*                              AND   laufi = zw_laufi.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS   FROM zfipg002_det
                              WHERE laufd = zw_laufd
                              AND   laufi = zw_laufi ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc <> 0.
    IF  par_vari+13(1) = '1'.
      tchq = 99999.
    ELSE.
      tchq = 0.
    ENDIF.
  ELSE.
    tchq = zfipg002_det-nchequ_s.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE descr INTO titulo  FROM zfipg002_cab
*                              WHERE bukrs    = zfipg002_det-bukrs
*                              AND   nproceso = zfipg002_det-nproceso.
*
* NEW CODE
    SELECT descr
    UP TO 1 ROWS  INTO titulo  FROM zfipg002_cab
                              WHERE bukrs    = zfipg002_det-bukrs
                              AND   nproceso = zfipg002_det-nproceso ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF  par_vari+13(1) = '1'.
      CONCATENATE 'Cheques Individual'  zfipg002_det-hbkid titulo  INTO titulo SEPARATED BY space.
******modificacion herman flag
******inicio
******IF zfipg002_det-nchequ_s eq zfipg002_det-ndocu.
*********i_flag  = 'X'. "Flag de Borrado de Firma
******ELSE.
*********i_flag  = space. "Flag de Borrado de Firma
******ENDIF.
******fin
    ELSE.
      CONCATENATE 'Cheques'  zfipg002_det-hbkid titulo  INTO titulo SEPARATED BY space.
******modificacion herman flag
******inicio
******i_flag  = 'X'. "Flag de Borrado de Firma
******fin
    ENDIF.
  ENDIF.

  ncheques  = ncheques + 1.

  IF  par_vari+13(1) = '1'.
    CHECK  ncheques  <= tchq.
  ELSE.
    CHECK  ncheques   > tchq.
  ENDIF.


  PERFORM pruefung.
  PERFORM scheckinfo_pruefen.                               "RFFORI01
  IF reguh-kunnr <> space.
    TABLES knb1.
    DATA ls_kna1 LIKE kna1.
    DATA ld_remit LIKE knb1-remit.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE remit INTO ld_remit FROM knb1
*         WHERE bukrs = reguh-absbu AND kunnr = reguh-kunnr.
*
* NEW CODE
    SELECT remit
    UP TO 1 ROWS  INTO ld_remit FROM knb1
         WHERE bukrs = reguh-absbu AND kunnr = reguh-kunnr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc = 0 AND ld_remit <> space.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM kna1 INTO ls_kna1 WHERE kunnr = ld_remit.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM kna1 INTO ls_kna1 WHERE kunnr = ld_remit ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc = 0.
        reguh-zadnr = ls_kna1-adrnr.
        reguh-zanre = ls_kna1-anred.
        reguh-znme1 = ls_kna1-name1.
        reguh-znme2 = ls_kna1-name2.
        reguh-znme3 = ls_kna1-name3.
        reguh-znme4 = ls_kna1-name4.

        PERFORM revisa_string USING reguh-znme1.
        PERFORM revisa_string USING reguh-znme2.

        reguh-zpstl = ls_kna1-pstlz.
        reguh-zort1 = ls_kna1-ort01.
        reguh-zort2 = ls_kna1-ort02.
        reguh-zstra = ls_kna1-stras.
        reguh-zpfac = ls_kna1-pfach.
        reguh-zpst2 = ls_kna1-pstl2.
        reguh-zpfor = ls_kna1-pfort.
        reguh-zland = ls_kna1-land1.
        reguh-zspra = ls_kna1-spras.
        reguh-zregi = ls_kna1-regio.
        reguh-ztlfx = ls_kna1-telfx.
        reguh-ztelf = ls_kna1-telf1.
        reguh-ztelx = ls_kna1-telx1.

      ENDIF.
    ENDIF.
  ENDIF.
* Nombre banco
  reguh-name4 = v_nomban.
  PERFORM extract_vorbereitung.


GET regup.

  PERFORM extract.
  IF reguh-zbukr NE regup-bukrs.
    tab_uebergreifend-zbukr = reguh-zbukr.
    tab_uebergreifend-vblnr = reguh-vblnr.
    COLLECT tab_uebergreifend.
  ENDIF.

*----------------------------------------------------------------------*
*  print checks, remittance advices and lists                          *
*----------------------------------------------------------------------*
END-OF-SELECTION.

  IF flg_selektiert NE 0.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *
*      FROM zconfchk
*      INTO it_zconfchk
*     WHERE zbukr EQ zw_zbukr-low
*       AND hbkid EQ sel_hbki-low
*       AND hktid EQ sel_hkti-low.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
      FROM zconfchk
      INTO it_zconfchk
     WHERE zbukr EQ zw_zbukr-low
       AND hbkid EQ sel_hbki-low
       AND hktid EQ sel_hkti-low ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*      AND formulario EQ par_zfor.
*

    IF par_zdru EQ 'X'.
      hlp_zforn = par_zfor.
      hlp_checf_restart = par_rchk.
      IF par_novo NE space.
        flg_schecknum = 2.
      ENDIF.

      CLEAR: f1_largo, f2_largo, f3_largo, f4_largo.
      CLEAR: v1_znm1s, v2_znm1s, v3_znm1s, v4_znm1s.
      CLEAR: v1_desc_agen, v2_desc_agen, v3_desc_agen, v4_desc_agen.
      CLEAR: v1_desc_mot, v2_desc_mot, v3_desc_mot, v4_desc_mot.
      CLEAR: v1_cruzado, v2_cruzado, v3_cruzado, v4_cruzado.

* Limpieza de variales de nombre.
      CLEAR: v_znm1s, v_znm2s.




      IF it_zconfchk-cantchk EQ 1 or   par_vari+13(1) = '1'.
        IF it_zconfchk-fmto_nuevo = 'X'.
          PERFORM scheck_new.
        ELSE.
          PERFORM scheck.                                   "RFFORI01
        ENDIF.
      ELSEIF it_zconfchk-cantchk EQ 4.
        IF it_zconfchk-fmto_nuevo = 'X'.
          PERFORM scheck_new.
        ELSE.
          PERFORM scheck4.                                    "RFFORI01
        ENDIF.
      ELSEIF it_zconfchk-cantchk GT 1.
        IF it_zconfchk-fmto_nuevo = 'X'.
          PERFORM scheck_new.
        ENDIF.
      ELSEIF it_zconfchk-cantchk EQ 0.
        PERFORM scheck.                                     "RFFORI01
      ENDIF.

      IF par_nenq EQ space.
        PERFORM schecknummern_entsperren.                   "RFFORI01
      ENDIF.
    ENDIF.

    IF par_avis EQ 'X'.
      flg_schecknum = 1.
      PERFORM avis.                                         "ZRFFORI06
    ENDIF.

    IF par_begl EQ 'X' AND par_maxp GT 0.
      flg_bankinfo = 1.
      PERFORM begleitliste.                                 "RFFORI07
    ENDIF.


    IF reguh-xvorl NE 'X'.
*-- Insercion TES_DOCPAGO --------------------------------------------
*-- HERMAN ROSALES --------------------------------------------
      IF reguh-zbukr EQ 'CL01' OR reguh-zbukr EQ 'CL24' .
        CALL FUNCTION 'ZINSERTA_CHEQUES'
          EXPORTING
            bukrs    = reguh-zbukr
            v_fecha  = reguh-laufd
            v_nomina = reguh-laufi.
*       IMPORTING
*         STATUS         =
      ENDIF.

*-- FIN HERMAN ROSALES --------------------------------------------

    ENDIF.
  ENDIF.

  "Inicio cambio CII - 20100817
  IF  par_vari+13(1) <> '1'.
    IF reguh-xvorl NE 'X'.    "NO ES EJECUCION DE PROPUESTA?
      IF NOT zfipg002_det IS INITIAL .
        IF NOT fm1 IS INITIAL.
          iname = fm1.
          CALL FUNCTION 'SAPSCRIPT_DELETE_GRAPHIC_BDS'
            EXPORTING
              i_object       = 'GRAPHICS'
              i_name         = iname
              i_id           = 'BMAP'
              i_btype        = 'BCOL'
              dialog         = ''
            EXCEPTIONS
              enqueue_failed = 1
              delete_failed  = 2
              not_found      = 3
              canceled       = 4
              OTHERS         = 5.
        ENDIF.

        IF NOT fm2 IS INITIAL.
          iname = fm2.
          CALL FUNCTION 'SAPSCRIPT_DELETE_GRAPHIC_BDS'
            EXPORTING
              i_object       = 'GRAPHICS'
              i_name         = iname
              i_id           = 'BMAP'
              i_btype        = 'BCOL'
              dialog         = ''
            EXCEPTIONS
              enqueue_failed = 1
              delete_failed  = 2
              not_found      = 3
              canceled       = 4
              OTHERS         = 5.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  "Fin cambio CII - 20100817

  PERFORM fehlermeldungen.

  PERFORM information.


*----------------------------------------------------------------------*
*  subroutines for check print and prenumbered checks                  *
*----------------------------------------------------------------------*
  INCLUDE zrffori01.

*----------------------------------------------------------------------*
*  subroutines for remittance advices                                  *
*----------------------------------------------------------------------*
  INCLUDE rffori06.

*----------------------------------------------------------------------*
*  subroutines for the payment summary list                            *
*----------------------------------------------------------------------*
  INCLUDE rffori07.

*----------------------------------------------------------------------*
*  international subroutines                                           *
*----------------------------------------------------------------------*
  INCLUDE rffori99.

*----------------------------------------------------------------------*
*  rutinas z                                                           *
*----------------------------------------------------------------------*
  INCLUDE zrffous_c_f_for_caratula.

  INCLUDE zrffous_c_f_for_voucherf01.

  INCLUDE zrffous_c_f_for_cheque.
