*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZFIMDP006 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  GET_FORM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_form INPUT.
*
  IF sy-ucomm NE 'BACK'
 AND sy-ucomm NE 'CANCEL'
   AND sy-ucomm NE 'EXIT'
   AND sy-ucomm NE 'SOC_01'
    AND sy-ucomm NE 'B03'
    AND sy-ucomm NE 'EBR2'.

* Validacion de acreedor
    DATA: es_lfb1 LIKE  lfb1.

    CALL FUNCTION 'LFB1_READ_SINGLE'
      EXPORTING
        id_lifnr            = zinvfo-lifnr
        id_bukrs            = zinvfo-bukrs
      IMPORTING
        es_lfb1             = es_lfb1
      EXCEPTIONS
        not_found           = 1
        input_not_specified = 2
        OTHERS              = 3.
    IF sy-subrc <> 0.
      MESSAGE e776.
    ELSE.

      LOOP AT SCREEN.
        IF screen-name = 'ZINVFO-LIFNR'.
          IF  screen-input = 1.

            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
      ENDLOOP.



      IF zinvfo-accnt IS INITIAL.
        zinvfo-accnt     =  zinvfo-lifnr.
      ENDIF.

      IF  zinvfo-fdgrp IS INITIAL.
        zinvfo-fdgrp     =  es_lfb1-frgrp.
      ENDIF.

      IF zinvfo-zterm IS INITIAL.
        zinvfo-zterm     =  es_lfb1-zterm.
      ENDIF.

      IF  zinvfo-hkont IS INITIAL.
        zinvfo-hkont     =  es_lfb1-akont.
      ENDIF.

      zinvfo-saknr      =  zinvfo-hkont.
    ENDIF.

    DATA: g_active_component(2) TYPE c,
          branch_holiday TYPE i.
    CALL FUNCTION 'J_1BSA_COMPONENT_ACTIVE'
      EXPORTING
        bukrs            = bkpf-bukrs
        component        = '**'
      IMPORTING
        active_component = g_active_component
      EXCEPTIONS
        OTHERS           = 1.
    IF sy-subrc = 0.
      IF g_active_component = 'BR' OR g_active_component = 'CA'.
        PERFORM bank_branch_check(saplj1az) USING branch_holiday.
      ENDIF.
    ENDIF.
* End of note

    MOVE-CORRESPONDING zinvfo TO bseg.

*------- EU triangular deal Hungary ? --------------------
    CASE zinvfo-xegdr_hu.
      WHEN 'B' OR 'C'.
        MOVE zinvfo-xegdr_hu TO bseg-xegdr.
    ENDCASE.

    MOVE-CORRESPONDING zinvfo TO bkpf.

    char = bsez-zterm.
    MOVE-CORRESPONDING zinvfo TO bsez.
    bsez-zterm = char.
* BSEZ-XMWST makes sense for down payments only
    CLEAR bsez-xmwst.
    MOVE-CORRESPONDING zinvfo TO bsec.
    CASE koart.
      WHEN 'K'.
        PERFORM kontolaenge_pruefen USING zinvfo-accnt.
        PERFORM alphaformat USING zinvfo-accnt bseg-lifnr.
      WHEN 'D'.
        PERFORM kontolaenge_pruefen USING zinvfo-accnt.
        PERFORM alphaformat USING zinvfo-accnt bseg-kunnr.
    ENDCASE.
    PERFORM invfo_accnt_format_change.
    IF     zinvfo-accnt NE invfo_old-accnt
    AND NOT invfo_old-accnt IS INITIAL.
      CLEAR no_checks.
    ENDIF.
    GET CURSOR FIELD cursor.
    CLEAR g_exit_command.


    DATA:pp_bschl TYPE bschl.

    IF rf05a-buscs EQ 'R'.
      pp_bschl = 40.
    ELSE.
      pp_bschl = 50.
    ENDIF.


    CLEAR: faus1, faus2, faus, zstatus_campo.
    REFRESH zstatus_campo.


    CALL FUNCTION 'FI_FIELD_SELECTION_DETERMINE'
      EXPORTING
        i_bukrs = zinvfo-bukrs
        i_saknr = zinvfo-hkont
        i_bschl = pp_bschl
      IMPORTING
        e_faus1 = faus1
        e_faus2 = faus2.
    faus = faus1.
    faus+90(50) = faus2.
    CALL FUNCTION 'ZREPARE_FIELD_SELECT_STRING'
      EXPORTING
        incoming_string = faus
        string_id       = 'SKB1-FAUS1 '
        text1           = text1
        text2           = fsttx
        xnodisp         = 'X'
        xchange         = space
      TABLES
        zstatus_campo   = zstatus_campo.
    IF zstatus_campo[] IS NOT INITIAL.

      LOOP AT SCREEN.
        CHECK screen-group4 = '001'.
        READ TABLE zstatus_campo WITH  KEY feldn = screen-name+7(10).
        IF sy-subrc EQ 0.
* Valida Campo Abligatoio.
          IF zstatus_campo-xoblg EQ 'X'.
            PERFORM valida_campo_abligatorio USING screen-group1.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF zinvfo-xblnr EQ space.
      SET CURSOR FIELD 'ZINVFO-XBLNR'.
      MESSAGE e899 WITH 'Ingrese el Numero de Referencia'.
    ENDIF.

    IF  zinvfo-zzmot_emis  NE space.
      DATA: i_zzcod_unidad TYPE zmot_emis-zzmot_emis.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = zinvfo-zzmot_emis
        IMPORTING
          output = zinvfo-zzmot_emis.


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE  zzmot_emis FROM zmot_emis INTO  i_zzcod_unidad
*         WHERE zzmot_emis =  zinvfo-zzmot_emis
*        AND    bukrs     = zinvfo-bukrs.
*
* NEW CODE
      SELECT zzmot_emis
      UP TO 1 ROWS  FROM zmot_emis INTO  i_zzcod_unidad
         WHERE zzmot_emis =  zinvfo-zzmot_emis
        AND    bukrs     = zinvfo-bukrs ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc NE 0.
        SET CURSOR FIELD 'ZINVFO-ZZMOT_EMIS'.
        MESSAGE e004(z1) WITH zinvfo-zzmot_emis 'No Es Valido.'.
      ENDIF.
    ENDIF.

    IF   zinvfo-zzrut_terc NE space.
      DATA: a_zzcod_unidad TYPE lfa1-lifnr.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = zinvfo-zzrut_terc
        IMPORTING
          output = zinvfo-zzrut_terc.


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE  lifnr FROM lfb1 INTO  a_zzcod_unidad
*         WHERE lifnr =  zinvfo-zzrut_terc
*        AND    bukrs     = zinvfo-bukrs.
*
* NEW CODE
      SELECT lifnr
      UP TO 1 ROWS  FROM lfb1 INTO  a_zzcod_unidad
         WHERE lifnr =  zinvfo-zzrut_terc
        AND    bukrs     = zinvfo-bukrs ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc NE 0.
        SET CURSOR FIELD 'ZINVFO-ZZRUT_TERC'.
        MESSAGE e005(z1) WITH  zinvfo-zzrut_terc 'No Es Valido.'.
      ENDIF.
    ENDIF.

    IF zinvfo-zz_agencia  NE space.
      DATA: r_zzcod_unidad TYPE zagencia-zzcod_unidad.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = zinvfo-zz_agencia
        IMPORTING
          output = zinvfo-zz_agencia.


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE  zzcod_unidad FROM zagencia INTO  r_zzcod_unidad
*         WHERE zzcod_unidad = zinvfo-zz_agencia
*        AND    bukrs     = zinvfo-bukrs.
*
* NEW CODE
      SELECT zzcod_unidad
      UP TO 1 ROWS  FROM zagencia INTO  r_zzcod_unidad
         WHERE zzcod_unidad = zinvfo-zz_agencia
        AND    bukrs     = zinvfo-bukrs ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc NE 0.
        SET CURSOR FIELD 'ZINVFO-ZZ_AGENCIA'.
        MESSAGE e006(z1) WITH zinvfo-zz_agencia 'No Es Valido.'.
      ENDIF.
    ENDIF.

    DATA:  pvalsign     LIKE  setleaf-valsign,
         pvaloption   LIKE  setleaf-valoption,
         pvalfrom     LIKE  setleaf-valfrom,
         pvalto       LIKE  setleaf-valto.


    RANGES: pp_blart FOR bkpf-blart.
    REFRESH: pp_blart.
    CLEAR: pp_blart.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT  valsign valoption valfrom valto INTO (pvalsign, pvaloption, pvalfrom, pvalto)
*     FROM setleaf
*    WHERE setname EQ 'ZFABLART'.
*
* NEW CODE
    SELECT valsign valoption val
from valto INTO (pvalsign, pvaloption, pvalfrom, pvalto)
     FROM setleaf
    WHERE setname EQ 'ZFABLART' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      MOVE: pvalsign TO pp_blart-sign,
            pvaloption TO pp_blart-option,
            pvalfrom   TO pp_blart-low,
            pvalto     TO pp_blart-high.
      APPEND pp_blart.
      CLEAR:pvalsign, pvaloption, pvalfrom, pvalto, pp_blart.
    ENDSELECT.


    IF NOT  zinvfo-blart IN pp_blart.
      MESSAGE e015(z1) WITH  zinvfo-blart.

    ENDIF.

  ENDIF.
ENDMODULE.                 " GET_FORM  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_WAERS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_waers INPUT.

  IF sy-ucomm NE 'BACK'
  AND sy-ucomm NE 'CANCEL'
    AND sy-ucomm NE 'EXIT'
    AND sy-ucomm NE 'SOC_01'.

    IF zinvfo-waers IS INITIAL AND NOT
       ( okcode EQ '9%GB' OR
         okcode EQ '9%PD' )
       AND NOT bkpf-glvor = 'RMRP'.
      MESSAGE e129(f5a).
    ENDIF.

    IF bkpf-waers NE zinvfo-waers.
      CLEAR bkpf-txkrs.
    ENDIF.
    bkpf-waers = zinvfo-waers.
  ENDIF.
ENDMODULE.                 " GET_WAERS  INPUT

*&---------------------------------------------------------------------*
*&      Form  kontolaenge_pruefen                                      *
*&---------------------------------------------------------------------*
*&      Created by note 677439                                         *
*&---------------------------------------------------------------------*
FORM kontolaenge_pruefen USING p_konto.
  DATA: string1(60) TYPE c,
        string2(50) TYPE c.
  string1 = p_konto.
  IF p_konto NE string1(10).
    IF p_konto CO ' 0123456789'.
      PERFORM alphaformat(sapff001) USING p_konto string2(10).
      WHILE string1(1) = '0'.
        SHIFT string1.
        IF string1(10) = string2(10).
          EXIT.
        ENDIF.
      ENDWHILE.
      IF string1(10) NE string2(10).
        MESSAGE e543.
      ENDIF.
    ELSE.
      MESSAGE e543.
    ENDIF.
  ENDIF.
ENDFORM.                    "kontolaenge_pruefen

*&---------------------------------------------------------------------*
*&      Form  ALPHAFORMAT
*&---------------------------------------------------------------------*
FORM alphaformat USING a01-in
                       a01-out.
  CALL FUNCTION 'LINEITEM_ALPHAFORMAT'
    EXPORTING
      a01_in  = a01-in
    IMPORTING
      a01_out = a01-out.
ENDFORM.                               " ALPHAFORMAT
*&---------------------------------------------------------------------*
*&      Form  INVFO_ACCNT_FORMAT_CHANGE
*&---------------------------------------------------------------------*
*       Central routine for transforming INVFO-ACCNT to the same
*       Format than LIFNR/KUNNR
*----------------------------------------------------------------------*
FORM invfo_accnt_format_change.
  CASE koart.
    WHEN 'K'.
      zinvfo-accnt = bseg-lifnr.
      IF bkpf-glvor = glvor_rmrp.                          "Note 312829
        zinvfo-lifre = bseg-lifnr.                          "Note 312829
      ENDIF.                                               "Note 312829
    WHEN 'D'.
      zinvfo-accnt = bseg-kunnr.
  ENDCASE.
  zinvfo-filkd = bseg-filkd.                                "Note 337886
ENDFORM.                               " INVFO_ACCNT_FORMAT_CHANGE
*&---------------------------------------------------------------------*
*&      Module  CHECK_REINDAT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_reindat INPUT.
  CHECK: g_aktyp NE char_a.                                 "Note852939
*  IF  NOT ZINVFO-REINDAT IS INITIAL
*      AND ZINVFO-REINDAT < ZINVFO-BLDAT.
*    MESSAGE E266(F5A) WITH ZINVFO-REINDAT ZINVFO-BLDAT.
*  ENDIF.
ENDMODULE.                 " CHECK_REINDAT  INPUT
*&---------------------------------------------------------------------*
*&      Module  READ_COMP_CODE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE read_comp_code INPUT.
  IF sy-ucomm EQ 'BACK'
  OR sy-ucomm EQ 'CANCEL'
    OR sy-ucomm EQ 'EXIT'
    OR sy-ucomm EQ 'SOC_01'.
    CHECK g_aktyp NE 'A'.
    PERFORM read_company_code_info USING bseg-bukrs.
    PERFORM header_fields_set_from_ccode.
  ENDIF.
ENDMODULE.                 " READ_COMP_CODE  INPUT
*&---------------------------------------------------------------------*
*&      Form  READ_COMPANY_CODE_INFO
*&---------------------------------------------------------------------*
*       Read all information for company code
*----------------------------------------------------------------------*
FORM read_company_code_info
     USING value(p_bukrs) TYPE bukrs.
  CHECK NOT p_bukrs IS INITIAL.
  CALL FUNCTION 'COMPANY_CODE_READ'
    EXPORTING
      i_bukrs = p_bukrs
    IMPORTING
      e_t001  = t001
      e_t004  = t004
      e_t005  = t005
      e_t014  = t014
      e_t043  = t043
      e_t043t = t043t.
  CALL FUNCTION 'FI_CURRENCY_INFORMATION'
    EXPORTING
      i_bukrs = t001-bukrs
      i_land1 = t001-land1
      i_rcomp = t001-rcomp
    IMPORTING
      e_x001  = x001.
  SET PARAMETER ID 'BUK' FIELD t001-bukrs.
ENDFORM.                               " READ_COMPANY_CODE_INFO
*&---------------------------------------------------------------------*
*&      Form  HEADER_FIELDS_SET_FROM_CCODE
*&---------------------------------------------------------------------*
FORM header_fields_set_from_ccode.
  bkpf-hwaer = t001-waers.
  bkpf-fikrs = t001-fikrs.
ENDFORM.                    " HEADER_FIELDS_SET_FROM_CCODE
*&---------------------------------------------------------------------*
*&      Module  BLART_PRECHECK  INPUT
*&---------------------------------------------------------------------*
*       Change of document type
*----------------------------------------------------------------------*
MODULE blart_precheck INPUT.
  xdoct_chg = 'X'.
  IF sy-ucomm NE 'BACK'
   AND sy-ucomm NE 'CANCEL'
   AND sy-ucomm NE 'EXIT'
   AND sy-ucomm NE 'SOC_01'
    AND sy-ucomm NE 'B03'
    AND sy-ucomm NE 'EBR2'.
    PERFORM blart_precheck.
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE ltext INTO  t003t-ltext
*     FROM t003t
*    WHERE spras  EQ  sy-langu
*     AND  blart  EQ  zinvfo-blart.
*
* NEW CODE
    SELECT ltext
    UP TO 1 ROWS  INTO  t003t-ltext
     FROM t003t
    WHERE spras  EQ  sy-langu
     AND  blart  EQ  zinvfo-blart ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.
ENDMODULE.                             " BLART_PRECHECK  INPUT

*&---------------------------------------------------------------------*
*&      Form  BLART_PRECHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  Allow change of document type

*----------------------------------------------------------------------*
FORM blart_precheck.
  DATA: loc_rcode LIKE sy-subrc.
  DATA: t003_old  LIKE t003.
  CALL FUNCTION 'FI_DOCUMENT_TYPE_DATA'
    EXPORTING
      i_blart       = invfo_old-blart
      i_koart       = t020-koart
    IMPORTING
      e_t003        = t003_old
    EXCEPTIONS
      error_message = 1.   " Ignore Errors

  CALL FUNCTION 'FI_DOCUMENT_TYPE_DATA'
    EXPORTING
      i_blart = zinvfo-blart
      i_koart = t020-koart
    IMPORTING
      e_t003  = t003.
  CHECK t003 NE t003_old.

*------------- Differences in settings of doc type ? -------------------
  loc_rcode = 0.

*-------------- Negative postings --------------------------------------
  IF t003-xnegp NE t003_old-xnegp.
    loc_rcode = 4.
    CLEAR bseg-xnegp.
  ENDIF.

*----------------- Associated companies --------------------------------
  IF t003-xmges NE t003_old-xmges
  OR t003-xgsub NE t003_old-xgsub.
    loc_rcode = 4.
  ENDIF.

*------------ Reset company held in function group F014 if necessary ---
  IF  zinvfo-blart NE invfo_old-blart                       "Note748112
  AND NOT t003-xgsub IS INITIAL.                            "Note748112
    CALL FUNCTION 'ASSOCIATED_COMP_RESET'.                  "Note748112
  ENDIF.                                                    "Note748112

*----------- Cross Company switched off ? ------------------------------
  IF anzbz GE 2
  AND t003-xgsub      = space
  AND t003_old-xgsub  = 'X'.
    MESSAGE e124(f5a).
  ENDIF.

*--------------- Type of rate ------------------------------------------
  IF   t003_old-kurst NE t003-kurst
  AND  t003_old-kurst NE 'M'
  AND  t003-kurst     NE 'M'.
    loc_rcode = 4.
  ENDIF.
*------number range changed in pp postings------------------------------
  IF t003_old-numkr NE t003-numkr
  AND g_document_exists EQ 'X'.
    loc_rcode = 8.
  ENDIF.
*------------- Warning -------------------------------------------------
  IF loc_rcode = 4.
    MESSAGE w124(f5a).
  ELSEIF loc_rcode = 8.
    MESSAGE e143(f5a) WITH t003-blart t003_old-blart.
  ENDIF.

ENDFORM.                               " BLART_PRECHECK
*&---------------------------------------------------------------------*
*&      Module  ACCOUNT_PRECHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE account_precheck INPUT.
*display mode A
  CHECK g_aktyp NE 'A'.

  CHECK no_checks NE 'X'.
*----------PP
  CHECK g_status NE '2'.
*
*--------- From MM,account may not be filled ---------------------------
  IF zinvfo-accnt = space AND bkpf-glvor = 'RMRP'.
    EXIT.
  ENDIF.
  IF zinvfo-accnt IS INITIAL.
    MESSAGE e132.
  ENDIF.
ENDMODULE.                 " ACCOUNT_PRECHECK  INPUT
*&---------------------------------------------------------------------*
*&      Module  SET_GENERAL_TAX_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_general_tax_data INPUT.
  IF sy-ucomm NE 'BACK'
   AND sy-ucomm NE 'CANCEL'
   AND sy-ucomm NE 'EXIT'
   AND sy-ucomm NE 'SOC_01'
    AND sy-ucomm NE 'B03'
    AND sy-ucomm NE 'EBR2'.

    CHECK g_aktyp NE 'A'.

*------------ Spreadsheet for US-Taxes ---------------------------------
    CALL FUNCTION 'LINEITEM_READ_TTXD'
      EXPORTING
        i_kalsm = t005-kalsm
      IMPORTING
        e_ttxd  = ttxd.
    IF tax-bukrs = space.
      tax-bukrs = bseg-bukrs.
      tax-kalsm = t005-kalsm.
    ENDIF.
    IF bseg-bukrs NE tax-bukrs.
      bseg-stbuk = tax-bukrs.
    ENDIF.
  ENDIF.
ENDMODULE.                 " SET_GENERAL_TAX_DATA  INPUT
*&---------------------------------------------------------------------*
*&      Module  CC_NUMBER_CHECK  INPUT
*&---------------------------------------------------------------------*
MODULE cc_number_check INPUT.
  CHECK g_aktyp NE 'A'.
  CALL FUNCTION 'FI_COMMON_DOCUMENT_NUMBER_LOCK'
    EXPORTING
      i_bvorg = bkpf-bvorg.
ENDMODULE.                             " CC_NUMBER_CHECK  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_DATE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_date INPUT.
  IF sy-ucomm NE 'BACK'
   AND sy-ucomm NE 'CANCEL'
   AND sy-ucomm NE 'EXIT'
   AND sy-ucomm NE 'SOC_01'
    AND sy-ucomm NE 'B03'
    AND sy-ucomm NE 'EBR2'.

    CHECK g_aktyp NE 'A'.
    IF no_checks NE 'X'.                                    "note438819
      CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
        EXPORTING
          date   = zinvfo-bldat                          "#EC DOM_EQUAL
        EXCEPTIONS
          OTHERS = 99.
      IF sy-subrc <> 0.
        MESSAGE e114(f5).
      ENDIF.
    ENDIF.

*---------- Posting date will always be proposed -----------------------
    CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
      EXPORTING
        date   = zinvfo-budat                            "#EC DOM_EQUAL
      EXCEPTIONS
        OTHERS = 99.
    IF sy-subrc <> 0.
      MESSAGE e114(f5).
    ENDIF.

    CHECK bkpf-glvor = 'RMRP'.

    IF  NOT zinvfo-zfbdt IS INITIAL                         "Note679590
    AND ( ( zinvfo-budat NE space AND zinvfo-budat <> invfo_old-budat )
    OR  ( zinvfo-bldat NE space AND zinvfo-bldat <> invfo_old-bldat ) ).

      CALL FUNCTION 'CUSTOMIZED_MESSAGE'
        EXPORTING
          i_arbgb = 'F5A'
          i_dtype = char_-
          i_msgnr = '290'.

*------- For message cross reference ---------------------
      IF 1 = 2.
        MESSAGE w290(f5a).
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " CHECK_DATE  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_PERIOD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_period INPUT.
  IF sy-ucomm NE 'BACK'
   AND sy-ucomm NE 'CANCEL'
   AND sy-ucomm NE 'EXIT'
   AND sy-ucomm NE 'SOC_01'
    AND sy-ucomm NE 'B03'
    AND sy-ucomm NE 'EBR2'.

    CHECK g_aktyp NE 'A'.

    IF okcode = '9-PD'.
      g_softcheck = char_x.
    ELSE.
      CLEAR g_softcheck.
    ENDIF.
    CALL FUNCTION 'DOCHEADER_PERIOD_FIND_CHECK'
         EXPORTING
              i_bukrs     = bseg-bukrs
              i_bldat     = bkpf-bldat
              i_budat     = bkpf-budat
              i_softcheck = g_softcheck
*           I_KOART = '+'
*           I_HKONT = '+'
         IMPORTING
              e_gjahr     = bkpf-gjahr
              e_xrueb     = bkpf-xrueb
              e_currj     = bkp1-currj
         CHANGING
              c_monat     = bkpf-monat.

* update bseg-gjahr if postings in different gjahr
    IF  zinvfo-gjahr NE bkpf-gjahr
    AND g_document_exists = 'X'.
      IMPORT xwfla1 FROM MEMORY ID 'FIENJOYWF'.
      IF xwfla1 = 'X'.                 "workflow:
        MESSAGE e041(fp).              " not allowed
      ENDIF.
    ENDIF.
    bseg-gjahr = bkpf-gjahr.
    zinvfo-gjahr = bkpf-gjahr.
    zinvfo-monat = bkpf-monat.
  ENDIF.
ENDMODULE.                 " GET_PERIOD  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_DOCUMENT_TYPE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_document_type INPUT.
  IF sy-ucomm NE 'BACK'
   AND sy-ucomm NE 'CANCEL'
   AND sy-ucomm NE 'EXIT'
   AND sy-ucomm NE 'SOC_01'
    AND sy-ucomm NE 'B03'
    AND sy-ucomm NE 'EBR2'.
    CHECK g_aktyp NE 'A'.
    IF sy-dyngr = 'MAIN'                                     "Note 337276
    OR sy-dyngr = 'DTMM'.                                    "Note 337276
      PERFORM doc_type_subst_at_buscs_change.
      PERFORM check_document_type.
      PERFORM read_number_range.
      IF bkpf-glvor NE glvor_rmrp                           "Note411315
      OR sy-dyngr = 'DTMM'.                                 "Note411315
        IF t003-brgru NE space.                             "Note437997
          PERFORM authority_document_type USING t003-brgru. "Note437997
        ENDIF.                                              "Note437997
      ELSE.                                                 "Note437997
        PERFORM authority_document_type USING space.        "Note437997
      ENDIF.                                                "Note411315
      PERFORM xsybl USING bkpf-blart.
    ENDIF.                                                   "Note 337276
    IF no_checks IS INITIAL.                                 "Note 327338

      CASE sy-dyngr.                                         "Note 337276
        WHEN 'DTMM'.                                         "Note 337276
          PERFORM manadatory_fields                          "Note 337276
            USING t003-xmtxt t003-xmref space 'X'.           "Note 337276
        WHEN 'MAIN'.                                         "Note 337276

          PERFORM manadatory_fields                          "Note 337276
            USING space t003-xmref 'X' space.                "Note 337276
        WHEN 'MORE'.                                         "Note 337276
          PERFORM manadatory_fields                          "Note 337276
            USING space t003-xmref space 'X'.                "Note 337276
        WHEN OTHERS.                                         "Note 337276
          PERFORM manadatory_fields                          "Note 337276
            USING space t003-xmref 'X' 'X'.                  "Note 337276
      ENDCASE.                                               "Note 337276
    ENDIF.                                                   "Note 327338
    IF sy-dyngr = 'MAIN'.                                    "Note 337276
      PERFORM cursor_set_on_action USING 'ZINVFO-BLART' CHANGING
        cursor.
*   Doc. type successfully changed:                         "Note624954
      invfo_old-blart = zinvfo-blart.                       "Note624954
    ENDIF.                                                   "Note 337276

    IF bkpf-glvor = glvor_rmrp
    AND bkpf-waers NE bkpf-hwaer
    AND zinvfo-blart NE invfo_old-blart.
      PERFORM set_currency_fields.
    ENDIF.
  ENDIF.
ENDMODULE.                 " CHECK_DOCUMENT_TYPE  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_DOCUMENT_NUMBER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_document_number INPUT.
  IF sy-ucomm NE 'BACK'
   AND sy-ucomm NE 'CANCEL'
   AND sy-ucomm NE 'EXIT'
   AND sy-ucomm NE 'SOC_01'
    AND sy-ucomm NE 'B03'
    AND sy-ucomm NE 'EBR2'.


    CHECK g_aktyp NE 'A'.

    CHECK: ( g_document_exists NE 'X' OR                     "Note 387920
            nriv-externind = 'X' ) AND                       "Note 387920
           ( no_checks IS INITIAL OR okcode = 'DOCT' ).      "Note 387920


    IF bkpf-glvor NE 'RMRP'.
      CHECK g_document_exists NE char_x OR                   "Note 393538
            bkpf-belnr NE g_org_belnr.                       "Note 393538
      CALL FUNCTION 'FI_DOCUMENT_NUMBER_CHECK'
        EXPORTING
          i_belnr                    = bkpf-belnr
          i_blart                    = bkpf-blart
          i_bukrs                    = bkpf-bukrs
          i_gjahr                    = bkpf-gjahr      "Note 355647
        EXCEPTIONS                                        "Note 355647
          external_number_assignment = 1               "Note 355647
          internal_number_assignment = 2               "Note 355647
          number_already_assigned    = 3               "Note 355647
          number_not_in_range        = 4               "Note 355647
          OTHERS                     = 5.              "Note 355647
      IF sy-subrc NE 0.                                      "Note 355647
        CASE sy-subrc.                                       "Note 387920
          WHEN '1'.                                          "Note 664972
            SET CURSOR FIELD 'ZINVFO-BELNR'.
            IF okcode NE 'DOCT'
            AND xdoct_chg IS INITIAL.
              LOOP AT SCREEN.                                "Note1020161
                CHECK: screen-name = 'ZINVFO-BELNR'.          "Note1020161
                IF screen-active = '1'.                      "Note1020161
                  MESSAGE e223 WITH sy-msgv1 sy-msgv2.       "Note1020161
                ENDIF.                                       "Note1020161
                EXIT.                                        "Note1020161
              ENDLOOP.                                       "Note1020161
            ELSE.
              CLEAR xdoct_chg.
            ENDIF.
          WHEN '2'.                                          "Note 387920
            CLEAR: zinvfo-belnr,                               "Note 387920
                   bkpf-belnr.                                "Note 387920
          WHEN OTHERS.                                       "Note 387920
            SET CURSOR FIELD 'ZINVFO-BELNR'.                   "Note 355647
            IF okcode NE 'DOCT'.                             "Note 387920
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno"Note 355647
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4."Note 355647
            ENDIF.                                            "Note 387920
        ENDCASE.                                            "Note 387920
      ENDIF.
    ELSE.
      CHECK g_document_exists IS INITIAL.                    "Note 387235
      CALL FUNCTION 'MRM_INVOICE_NUMBER_CHECK'
        EXPORTING
          i_belnr = bkpf-belnr
          i_gjahr = bkpf-gjahr
          i_tcode = 'MR1M'.
    ENDIF.
  ENDIF.
ENDMODULE.                 " CHECK_DOCUMENT_NUMBER  INPUT
*&---------------------------------------------------------------------*
*&      Module  OFF_NUMBER_GLOBAL_CHECK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE off_number_global_check INPUT.
  IF sy-ucomm NE 'BACK'
   AND sy-ucomm NE 'CANCEL'
   AND sy-ucomm NE 'EXIT'
   AND sy-ucomm NE 'SOC_01'
    AND sy-ucomm NE 'B03'
    AND sy-ucomm NE 'EBR2'.


    CHECK g_aktyp NE 'A'.

*--proceed in case of pp as well ---------------------------------------
    CLEAR: fin1_param.
    MOVE-CORRESPONDING bkpf TO fin1_param.
    fin1_param-appli = 'F'.
    fin1_param-aktyp = 'H'.
    fin1_param-blgar = bkpf-blart.
    fin1_param-lifnr = bseg-lifnr.       " OSS Note 381101
    fin1_param-kunnr = bseg-kunnr.       " OSS Note 381101
    fin1_param-bupla = bseg-bupla.       " OSS Note 373831
    CALL FUNCTION 'OFF_NUMBER_GLOBAL_CHECK'
      EXPORTING
        i_fin1_param = fin1_param
        i_bkpf       = bkpf
      IMPORTING
        o_xblnr      = bkpf-xblnr
      EXCEPTIONS
        OTHERS       = 0.
  ENDIF.
ENDMODULE.                 " OFF_NUMBER_GLOBAL_CHECK  INPUT


*&---------------------------------------------------------------------*
*&      Form  DOC_TYPE_SUBST_AT_BUSCS_CHANGE
*&---------------------------------------------------------------------*
*       If business case was changed: doc type was transported early
*       in field blart_pai
*----------------------------------------------------------------------*
FORM doc_type_subst_at_buscs_change.
  CHECK blart_pai NE space.
  IF sy-ucomm NE 'DOCT' OR bkpf-blart IS INITIAL.
    bkpf-blart = blart_pai.
  ENDIF.
  CLEAR blart_pai.
ENDFORM.                               " DOC_TYPE_SUBST_AT_BUSCS_CHANGE

*&---------------------------------------------------------------------*
*&      Form  CHECK_DOCUMENT_TYPE
*&---------------------------------------------------------------------*
FORM check_document_type.
  DATA: dialog TYPE boole VALUE 'X'.


  CALL FUNCTION 'FI_DOCUMENT_TYPE_CHECK'
    EXPORTING
      i_blart  = bkpf-blart
      i_koart  = koart
      x_dialog = dialog
    EXCEPTIONS
      OTHERS   = 4.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
    WITH    sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  PERFORM read_t003 USING bkpf-blart koart.
  bkpf-xnetb = t003-xnetb.
ENDFORM.                               " CHECK_DOCUMENT_TYPE


*&---------------------------------------------------------------------*
*&      Form  READ_NUMBER_RANGE
*&---------------------------------------------------------------------*
FORM read_number_range.
  CLEAR nriv.

  CALL FUNCTION 'DOCHEADER_NUMBER_GET_INFO'
    EXPORTING
      i_numkr                = t003-numkr
      i_bukrs                = bkpf-bukrs
      i_gjahr                = bkpf-gjahr
    IMPORTING
      e_nriv                 = nriv
    EXCEPTIONS
      number_range_not_found = 1
      object_not_found       = 2
      OTHERS                 = 0.

  CASE sy-subrc.
    WHEN 01.
      MESSAGE e150 WITH bseg-bukrs t003-numkr bkpf-gjahr.
    WHEN 02.
      MESSAGE e157.
  ENDCASE.
ENDFORM.                               " READ_NUMBER_RANGE


*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_DOCUMENT_TYPE
*&---------------------------------------------------------------------*
* (del) form authority_document_type.
FORM authority_document_type
     USING value(p_brgru) LIKE t003-brgru.
* (del) check t003-brgru ne space.
  CALL FUNCTION 'DOCHEADER_AUTHORITY_CHECK'
       EXPORTING
            i_bukrs =  bseg-bukrs
            i_blart =  t003-blart
* (del)     i_brgru =  t003-brgru
            i_brgru =  p_brgru
*--PP-------------------------------------------------------------------
            i_status = g_status.
ENDFORM.                               " AUTHORITY_DOCUMENT_TYPE

*&---------------------------------------------------------------------*
*&      Form  XSYBL
*&---------------------------------------------------------------------*
*------- No system document types (are allowed only for batch input) ---
*----------------------------------------------------------------------*
FORM xsybl
     USING value(blart) TYPE blart.
* (del) if t003-xsybl = 'X'.
  IF t003-xsybl = char_x AND sy-binpt NE char_x.
    MESSAGE e310 WITH blart.
  ENDIF.
ENDFORM.                    " XSYBL


*&---------------------------------------------------------------------*
*&      Form  MANADATORY_FIELDS
*&---------------------------------------------------------------------*
FORM manadatory_fields
     USING value(xmtext) TYPE xfeld
           value(xmref) TYPE xfeld
* (del)                      no_message_xmtext.
           value(no_message_xmtext) TYPE xfeld
           value(no_message_xmref) TYPE xfeld.
* no message in case of pp documents status 2
  CHECK g_status NE '2'.
*Change of doc type on detail screen /MM
  IF sy-dynnr = 150.
*------- Doc. header text ---------------------------------------------
    IF  xmtext NE space
    AND bkpf-bktxt EQ space.
      SET CURSOR FIELD 'ZINVFO-BKTXT'.
      MESSAGE e480 WITH bkpf-blart text-018.
    ENDIF.
*------- Reference number ----------------------------------------------
    IF  xmref NE space
    AND bkpf-xblnr EQ space.
*--------doc type chained on MORE screen-------------------------------
      actab = 'MAIN'.
*      CURSOR = 'ZINVFO-XBLNR'.
      MESSAGE s480 WITH bkpf-blart text-017.
    ENDIF.
  ELSE.
*------- Reference number ----------------------------------------------
    IF  xmref NE space
    AND bkpf-xblnr EQ space.
*--------doc type chained on MORE screen-------------------------------
*------- Reference number may be missing when the user
*        posts in a parking transaction
      IF  no_message_xmref = 'X'
      AND sy-dyngr NE 'MAIN' .
*     and actab ne 'MAIN'.                  " Note 337995
        actab = 'MAIN'.
        cursor = 'ZINVFO-XBLNR'.
        MESSAGE s480 WITH bkpf-blart text-017.
      ELSE.
        SET CURSOR FIELD 'ZINVFO-XBLNR'.
        MESSAGE e480 WITH bkpf-blart text-017.
      ENDIF.
    ENDIF.

*------- Doc. header text ---------------------------------------------
    IF  xmtext NE space
    AND bkpf-bktxt EQ space.
      IF no_message_xmtext = 'X'
*--------doc type chained on MORE screen-------------------------------
         AND sy-dyngr NE 'MORE'.
        actab = 'MORE'.
        cursor = 'ZINVFO-BKTXT'.
        MESSAGE s480 WITH bkpf-blart text-018.
      ELSE.
        SET CURSOR FIELD 'ZINVFO-BKTXT'.
        MESSAGE e480 WITH bkpf-blart text-018.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                               " MANADATORY_FIELDS

*&---------------------------------------------------------------------*
*&      Form  CURSOR_SET_ON_ACTION
*&---------------------------------------------------------------------*
*   Central routine for setting CURSOR to this field if it was changed
*   Form should be used whenever a list box triggers PAI
*----------------------------------------------------------------------*
FORM cursor_set_on_action USING
    fname TYPE c CHANGING curs TYPE c.
  FIELD-SYMBOLS: <fold> TYPE simple, <fnew> TYPE simple.
  DATA: string1(61),
        string2(30).
  ASSIGN (fname) TO <fnew>.
  SPLIT fname AT '-' INTO string2 string1.
  CONCATENATE string2 '_OLD-' string1 INTO string1.
  ASSIGN (string1) TO <fold>.
  IF <fold> NE <fnew>.
    curs = fname.
  ENDIF.
ENDFORM.                               " CURSOR_SET_ON_ACTION
*&---------------------------------------------------------------------*
*&      Form  READ_T003
*&---------------------------------------------------------------------*
FORM read_t003
     USING value(blart) TYPE blart
           value(p_koart) TYPE koart.
  CALL FUNCTION 'FI_DOCUMENT_TYPE_DATA'
    EXPORTING
      i_blart = blart
    IMPORTING
      e_t003  = t003
      e_ltext = t003t-ltext.
ENDFORM.                                                    " READ_T003

*&---------------------------------------------------------------------*
*&      Form  SET_CURRECY_FIELDS
*&---------------------------------------------------------------------*
FORM set_currency_fields.

  DATA: loc_dialog.
  DATA: l_bldat LIKE bkpf-bldat.                            "Note517382
  DATA: old_wwert TYPE wwert_d.

* KURS2/3 can't be entered manually, new derivation on change of WAERS
*(del)  bkpf-kurs2 = 0.                                     "Note799505
*(del)  bkpf-kurs3 = 0.                                     "Note799505
  IF g_document_exists IS INITIAL.                          "Note954376
    bkpf-kurs2 = 0.                                         "Note954376
    bkpf-kurs3 = 0.                                         "Note954376
  ENDIF.                                                    "Note954376

  old_wwert = bkpf-wwert.

*---- Warning only on amount screen: Rate can be changed here ----------
  IF sy-dyngr = 'AMNT' OR sy-dyngr = 'DTMM'.                "Note418591
    loc_dialog = 'X'.
  ELSE.
* Note 575249: Determine translation date via BADI
    IF  zinvfo-budat NE invfo_old-budat
          OR zinvfo-bldat NE invfo_old-bldat
          AND NOT bkpf-wwert IS INITIAL.
      READ TABLE tacscr WITH KEY fname = 'KURSF'.
      IF sy-subrc NE 0   " always in FB60/FV60, as they don't use TACSCR
      OR tacscr-input NE '0'. " = 0 when YDRSEG is filled in MIRO
        CLEAR: zinvfo-wwert, bkpf-wwert.
      ENDIF.
    ENDIF.

    CLEAR loc_dialog.
  ENDIF.

* BADI FI_TRANS_DATE_DERIVE depends on BLART. Regard change of BLART for
* derivation of WWERT - special treatment only necessary in MIRO because
* different tabs are concerned (Note 885976)
  IF bkpf-glvor = glvor_rmrp
  AND zinvfo-blart NE invfo_old-blart
  AND zinvfo-kursf EQ invfo_old-kursf                       "Note971125
  AND bkpf-waers NE bkpf-hwaer.
    READ TABLE tacscr WITH KEY fname = 'KURSF'.
    IF tacscr-input NE '0'.                        "Rate not fixed in PO
      CLEAR: bkpf-wwert, zinvfo-wwert.
    ELSE.                                          "Rate fixed in PO
      EXIT.
    ENDIF.
  ENDIF.

* Reset KURSF, if WWERT or BUDAT has been changed          "Note 306333
* Dependencies: BUDAT -> WWERT -> KURSF -> DMBTR           ".....
* Must not happen, if rate fixed in purchase order
  IF invfo_old-waers NE zinvfo-waers OR
     invfo_old-wwert NE zinvfo-wwert.
    IF bkpf-glvor = 'RMRP'.                                 "Note799505
      IF tacscr-fname NE 'KURSF'.
        READ TABLE tacscr WITH KEY fname = 'KURSF'.
      ENDIF.
      IF tacscr-fname NE 'KURSF' OR tacscr-input NE '0'.
        CLEAR bkpf-kursf.
      ENDIF.
    ELSE.                                                   "Note799505
      CLEAR: bkpf-kursf, bkpf-kurs2, bkpf-kurs3.            "Note799505
    ENDIF.                                                  "Note799505
  ENDIF.

* Conversion date was changed: reset amount in local currency
  IF 1 EQ 1
* Conversion date changed and DMBTR not entered manually
  AND ( zinvfo-budat NE invfo_old-budat OR                  "Note754825
        zinvfo-bldat NE invfo_old-bldat AND                 "Note754825
        bseg-hwmet EQ space )                               "Note754825
* WWERT changed                                             "Note754825
  OR  ( zinvfo-wwert NE invfo_old-wwert AND                 "Note754825
        zinvfo-budat EQ invfo_old-budat AND                 "Note754825
        zinvfo-bldat EQ invfo_old-bldat ).                  "Note754825
    bseg-dmbtr = 0.
    bseg-mwsts = 0.                                         "Note322611
    bseg-sknto = 0.                                         "Note511688
  ENDIF.

* No document date entered yet - use posting date instead   "Note517382
  IF bkpf-bldat IS INITIAL.                                 "Note517382
    l_bldat = bkpf-budat.                                   "Note517382
  ELSE.                                                     "Note517382
    l_bldat = bkpf-bldat.                                   "Note517382
  ENDIF.                                                    "Note517382

  CALL FUNCTION 'FI_CURRENCY_CHECK'
    EXPORTING
      i_bldat  = l_bldat                                    "Note517382
      i_budat  = bkpf-budat
      i_bukrs  = bkpf-bukrs
      i_blart  = bkpf-blart
      i_kurs2  = bkpf-kurs2
      i_kurs3  = bkpf-kurs3
      i_kursf  = bkpf-kursf
      i_waers  = bkpf-waers
      x_dialog = loc_dialog
      i_wwert  = bkpf-wwert
    IMPORTING
      e_kurs2  = bkpf-kurs2
      e_kurs3  = bkpf-kurs3
      e_kursf  = bkpf-kursf
      e_wwert  = bkpf-wwert.

* Issue I-Message on change of translation date:           (Note 575249)
  IF bkpf-hwaer NE bkpf-waers.
    IF bkpf-wwert NE old_wwert.
      IF old_wwert IS INITIAL.
*        message i378(f5a) with bkpf-wwert.
      ELSE.
        MESSAGE i377(f5a) WITH old_wwert bkpf-wwert.
        IF bkpf-glvor = glvor_rmrp                          "Note885976
        AND zinvfo-blart NE invfo_old-blart.                "Note885976
          PERFORM calculate_amounts.                        "Note885976
        ENDIF.                                              "Note885976
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                               " SET_CURRECY_FIELDS
*&---------------------------------------------------------------------*
*&      Form  CALCULATE_AMOUNTS
*&---------------------------------------------------------------------*
*       Currency amounts are recalculated iff equal to zero
*       and corresponding currencies are used
*----------------------------------------------------------------------*
FORM calculate_amounts.
  MOVE-CORRESPONDING bkpf TO icurr.
  MOVE-CORRESPONDING bseg TO icurr.
  icurr-kurst = t003-kurst.
  CALL FUNCTION 'FI_CURRENCIES_CONVERT'
    EXPORTING
      i_icurr       = icurr
    IMPORTING
      e_icurr       = icurr
    EXCEPTIONS
      error_message = 1.                                    "Note517382
  IF  sy-subrc = 1                                          "Note517382
  AND no_checks IS INITIAL.                                 "Note517382
    MESSAGE ID sy-msgid                                     "Note517382
            TYPE sy-msgty                                   "Note517382
            NUMBER sy-msgno                                 "Note517382
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.       "Note517382
  ENDIF.                                                    "Note517382
  MOVE-CORRESPONDING icurr TO bseg.
ENDFORM.                               " CALCULATE_AMOUNTS
*&---------------------------------------------------------------------*
*&      Module  SET_FEC  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_fec OUTPUT.

  IF zinvfo-zfbdt IS INITIAL.
    DATA: zdart LIKE t052-zterm,
          ztag1 LIKE t052-ztag1.

    bseg-zterm = zinvfo-zterm.
    bsez-zterm = zinvfo-zterm.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE zdart ztag1 INTO (zdart, ztag1)
*      FROM t052
*    WHERE zterm  =  zinvfo-zterm.
*
* NEW CODE
    SELECT zdart ztag1
    UP TO 1 ROWS  INTO (zdart, ztag1)
      FROM t052
    WHERE zterm  =  zinvfo-zterm ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF zdart EQ 'B'.
      zinvfo-zfbdt = zinvfo-bldat.
    ELSE.
      zinvfo-zfbdt = zinvfo-budat.
    ENDIF.

    bseg-zfbdt  =    zinvfo-zfbdt.
    bkpf-bldat    =    zinvfo-bldat.
*    bseg-sgtxt    =  zinvfo-sgtxt.     "Quintec mvm 26.07.2010
    zinvfo-zbd1t  = ztag1.
    PERFORM baselinedate_check.
    zinvfo-netdt =  bseg-zfbdt + ztag1.
  ENDIF.
ENDMODULE.                 " SET_FEC  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  payment_cond_due_date
*&---------------------------------------------------------------------*
*       determine due date and send warnng if NETDT < BUDAT
*----------------------------------------------------------------------*
FORM payment_cond_due_date USING
     value(no_warning) TYPE xfeld.
  STATICS: warning_sent.
  DATA: old_netdt LIKE faede-netdt.                      "Note 565953

  CHECK NOT bseg-zfbdt IS INITIAL.                          "P00K009405
  faede-shkzg = bseg-shkzg.
  faede-koart = koart.
  faede-zfbdt = bseg-zfbdt.
  faede-zbd1t = bseg-zbd1t.
  faede-zbd2t = bseg-zbd2t.
  faede-zbd3t = bseg-zbd3t.
  faede-rebzg = bseg-rebzg.
  faede-rebzt = bseg-rebzt.
  faede-bldat = bkpf-bldat.
  CALL FUNCTION 'DETERMINE_DUE_DATE'
    EXPORTING
      i_faede = faede
    IMPORTING
      e_faede = faede
    EXCEPTIONS
      OTHERS  = 1.
  old_netdt = zinvfo-netdt.                               "Note 565953
  zinvfo-netdt = faede-netdt.
  IF zinvfo-netdt NE old_netdt.                           "Note 565953
*     Due date changed: sent warning.                      "Note 565953
    warning_sent = space.                                "Note 565953
  ENDIF.                                                 "Note 565953
  CHECK no_warning = space AND warning_sent = space.
  CHECK: xderive IS INITIAL.                                "Note653053
  IF faede-netdt < sy-datlo
     AND sy-subrc = 0
     AND g_status NE '4'.                                   "Note485043
    IF 1 = 2. MESSAGE w149 WITH ''. ENDIF.
    WRITE faede-netdt TO char(10) DD/MM/YYYY.
    CALL FUNCTION 'CUSTOMIZED_MESSAGE'
      EXPORTING
        i_arbgb = 'F5'
        i_dtype = 'W'
        i_msgnr = '149'
        i_var01 = char(10).
    warning_sent = 'X'.
  ENDIF.
ENDFORM.                             " payment_cond_due_date
