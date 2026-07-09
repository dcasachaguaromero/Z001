*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Modulpool         ZFIMDP005
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
PROGRAM  zfimdp005b MESSAGE-ID f5.
TABLES:
  bkpf,
  zinvfo,
  bseg,
  bsez,
  bsec,
  t001,
  *lfb1,
  *knb1,
  t004,
  zacgl_item,
  acgl_item_gen,bseu,
  *zacgl_item, t030b,
  tmodu,
  zacgl_item_tbctr,
  t005,
  t014,
  t043,
  t042,
  t043t,
  t003t,
  x001,
  t020,
  t003,
  t052,
  ttxd,
  bkp1,
  nriv,
  icurr,
  fin1_param,
  rf05a,
  rfopt,
  rfopt2,
  acgl_head,
  t074u,
  tbsl,
  tbslt,
  skb1,
  kna1,
  knb1,
  lfa1,
  lfb1,
  ska1,
  acc_kontext,
  tfbuf,
  t007a,
  acsplt,
  faede.

CONSTANTS: c_01 TYPE konp-kopos VALUE '01'."JOROZCO 08.01.2020


DATA: mbseg LIKE bseg,
      mbsec LIKE bsec,
      mbsed LIKE bsed,
      mbkpf LIKE bkpf.

DATA: lt_bkpf TYPE TABLE OF bkpf.                        "Note 390762
DATA: lt_bseg TYPE TABLE OF bseg.

DATA: pantalla1(1) TYPE c,
      pantalla2(1) TYPE c,
      pantalla3(1) TYPE c.

DATA:
  fstva     TYPE fstva,
  faus1     TYPE faus1,
  faus2     TYPE faus1,
  faus(140),
  fsttx     TYPE fsttx VALUE 'DDD',
  text1(70) VALUE '111'.
DATA: fstag LIKE skb1-fstag.

DATA: ds_name     LIKE rfpdo-rfbifile.

DATA: BEGIN OF zzacgl_item OCCURS 0.
        INCLUDE STRUCTURE zacgl_item_tbctr.
      DATA: END OF zzacgl_item.

TYPES: BEGIN OF t_table,
         state      LIKE zacgl_item_tbctr-state,
         bukrs      LIKE zacgl_item_tbctr-bukrs,
         shkzg      LIKE zacgl_item_tbctr-shkzg,
         mwskz      LIKE zacgl_item_tbctr-mwskz,
         wrbtr      LIKE zacgl_item_tbctr-wrbtr,
         valut      LIKE zacgl_item_tbctr-valut,
         zuonr      LIKE zacgl_item_tbctr-zuonr,
         sgtxt      LIKE zacgl_item_tbctr-sgtxt,
         kokrs      LIKE zacgl_item_tbctr-kokrs,
         kostl      LIKE zacgl_item_tbctr-kostl,
         aufnr      LIKE zacgl_item_tbctr-aufnr,
         anbwa      LIKE zacgl_item_tbctr-anbwa,
         hkont      LIKE zacgl_item_tbctr-hkont,
         prctr      LIKE zacgl_item_tbctr-prctr,
         konto_txt  LIKE zacgl_item_tbctr-konto_txt,
         zzprestac  LIKE zacgl_item_tbctr-zzprestac,
         zzunid_pro LIKE zacgl_item_tbctr-zzunid_pro,
         zzdesc_est LIKE zacgl_item_tbctr-zzdesc_est,
         zzmot_emis LIKE zacgl_item_tbctr-zzmot_emis,
         zzrut_terc LIKE zacgl_item_tbctr-zzrut_terc,
         zz_agencia LIKE zacgl_item_tbctr-zz_agencia,
         anln1      LIKE zacgl_item_tbctr-anln1,
         anln2      LIKE zacgl_item_tbctr-anln2,
         bschl      LIKE zacgl_item_tbctr-bschl,
         marksp     LIKE zacgl_item_tbctr-marksp,
       END OF t_table.

DATA: g_table_itab TYPE t_table OCCURS 0,
      g_table_wa   TYPE t_table. "work area
DATA:     g_table_copied.           "copy flag

DATA: g_check_level TYPE i VALUE 1.
DATA: g_no_message TYPE xfeld.


DATA: dynnr   LIKE tcobl-dynnr,    "Dynpronummer des Subscreens
      progn   LIKE sy-cprog,       "Name des Kontierungsblockmodulpools
      process LIKE cobl-process,   "RWIN-Prozeß
      event   LIKE cobl-event.     "RWIN-Zeitpunkt

DATA     i TYPE i.      " Laufindex etc.
CONTROLS: table   TYPE TABLEVIEW USING SCREEN 0100,
          tc_cols TYPE TABLEVIEW USING SCREEN 0100.
DATA tc_aaa TYPE cxtab_column.
DATA:  col TYPE cxtab_column.
DATA:     g_table_lines  LIKE sy-loopc.

DATA: zstatus_campo LIKE zstatus_campo OCCURS 0  WITH HEADER LINE.
DATA: i_errores LIKE bapiret2 OCCURS 0  WITH HEADER LINE.
DATA: p_error_p(1) TYPE c.

DATA: pp_index LIKE sy-tabix.
DATA: p_auto(1)    TYPE c VALUE 'X',
      p_popup(1)   TYPE c VALUE 'X',
      p_titulo(30) TYPE c VALUE 'Log. de Ejecución'.

INCLUDE zcontactfijo_b.
INCLUDE zfindtop001_b.
INCLUDE zfimdtop_b.
INCLUDE zmf05acom_b.
INCLUDE zmf05atop_enj_apar_b.
INCLUDE zmf05atop_enj_general_b.
INCLUDE zmrm_const_mrm_b.
INCLUDE zlfdcbf4d_b.
INCLUDE zfimdp006_b.
INCLUDE zfimdp007_b.
INCLUDE zfimdp008_b.
INCLUDE zfimdp009_b.
INCLUDE zfimdp_table_control_b.
*----------------------------------------------------------------------*
*  MODULE T_001_ACTIVE_TAB_SET OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE t_001_active_tab_set OUTPUT.
  t_001-activetab = g_t_001-pressed_tab.
  CASE g_t_001-pressed_tab.
    WHEN c_t_001-tab1.
      g_t_001-subscreen = '0101'.
    WHEN c_t_001-tab2.
      g_t_001-subscreen = '0102'.
    WHEN c_t_001-tab3.
      g_t_001-subscreen = '0103'.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                    "T_001_ACTIVE_TAB_SET OUTPUT

*----------------------------------------------------------------------*
*  MODULE T_001_ACTIVE_TAB_GET INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE t_001_active_tab_get INPUT.
  ook_code = sy-ucomm.
  CASE ook_code.
    WHEN c_t_001-tab1.
      g_t_001-pressed_tab = c_t_001-tab1.
    WHEN c_t_001-tab2.
      g_t_001-pressed_tab = c_t_001-tab2.
    WHEN c_t_001-tab3.
      g_t_001-pressed_tab = c_t_001-tab3.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.                    "T_001_ACTIVE_TAB_GET INPUT


*&---------------------------------------------------------------------*
*&      Module  SET_SOCIEDAD_FI  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_sociedad_fi OUTPUT.
  IF   zinvfo-bukrs EQ space.
    GET PARAMETER ID 'BUK' FIELD zinvfo-bukrs .
  ENDIF.

  IF zinvfo-bukrs EQ space.
    CALL FUNCTION 'DOCHEADER_COMP_CODE_WITH_POPUP'
      EXPORTING
        i_bukrs  = zinvfo-bukrs
        i_status = g_status
      IMPORTING
        e_bukrs  = bkpf-bukrs
      EXCEPTIONS
        canceled = 1
        OTHERS   = 2.
    SET PARAMETER ID 'BUK' FIELD bkpf-bukrs .
    zinvfo-bukrs = bkpf-bukrs.
  ELSE.
    SET PARAMETER ID 'BUK' FIELD zinvfo-bukrs .
  ENDIF.

  IF zinvfo-bukrs NE space.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE waers INTO   zinvfo-waers
*    FROM t001
*      WHERE bukrs = zinvfo-bukrs.
*
* NEW CODE
    SELECT waers
    UP TO 1 ROWS  INTO   zinvfo-waers
    FROM t001
      WHERE bukrs = zinvfo-bukrs ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *
*  FROM   t042
*    WHERE bukrs = zinvfo-bukrs.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
  FROM   t042
    WHERE bukrs = zinvfo-bukrs ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.

  IF zinvfo-blart EQ space.
*   zinvfo-blart = 'F1'.
*V1 RVY 25.04.2022
*
  zinvfo-blart = 'F3'.
*
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE ltext INTO  t003t-ltext
*       FROM t003t
*      WHERE spras  EQ  sy-langu
*       AND  blart  EQ  zinvfo-blart.
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

  IF zinvfo-mwskz EQ space.
    zinvfo-mwskz = 'C9'.
    zinvfo-xmwst = 'X'.
  ENDIF.

  IF zinvfo-bktxt EQ space.
    zinvfo-bktxt = 'Txt'.
  ENDIF.

  IF zinvfo-fdlev IS INITIAL.
    zinvfo-fdlev = 'F1'.
  ENDIF.
  bkpf-waers  = zinvfo-waers.

  IF zinvfo-lifnr NE space.

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
    ENDIF.
  ENDIF.
ENDMODULE.                 " SET_SOCIEDAD_FI  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DYNPRO_MODIFICATION_1100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE dynpro_modification_1100 OUTPUT.
  LOOP AT SCREEN.
    CASE screen-name.
      WHEN 'AMNT'.
        IF  bkpf-hwaer = bkpf-waers
        AND bkpf-hwae2 = space AND bkpf-hwae3 = space.
          screen-invisible = 1.
        ENDIF.
      WHEN 'WT  '.
        CALL FUNCTION 'FI_CHECK_EXTENDED_WT'
          EXPORTING
            i_bukrs              = bkpf-bukrs
          EXCEPTIONS
            component_not_active = 1
            not_found            = 2
            OTHERS               = 3.
        IF sy-subrc NE 0.
          READ TABLE xbseg WITH KEY koart = 'K'.
          IF sy-subrc NE 0
            OR xbseg-qsskz = space
            AND ( ts-activetab NE 'WT'                      "Note494030
            OR activetab NE space ) .                       "Note494030
            screen-invisible = 1.
          ENDIF.
        ENDIF.

      WHEN 'SPLT'.
        DESCRIBE TABLE splttab.                             "Note485043
        IF t001-xsplt IS INITIAL
        OR ( g_status EQ 4 AND sy-tfill LT 2 ).             "Note485043
          screen-invisible = 1.
        ENDIF.

      WHEN 'RF05A-BUSCS'.
        IF rfopte-xbcon = 'X'.
          screen-invisible = 1.
          screen-active = 0.
        ELSEIF g_document_exists EQ 'X' OR g_status EQ '4'. "Note485043
          screen-input = 0.
        ELSE.

          IF first_call IS INITIAL.
            IF  ( activetab NE space AND activetab NE 'MAIN' ).
              screen-input = 0.
            ELSEIF ts-activetab NE 'MAIN' AND activetab = space.
              screen-input = 0.
            ENDIF.
          ENDIF.
        ENDIF.

      WHEN 'RF05A-KSUCH' OR 'SEARCH'.
        IF rfopte-vsrch NE 'X'.
          screen-invisible = 1.
          screen-active    = 0.
          screen-input     = 0.
        ELSE.

          DESCRIBE TABLE xbseg LINES rf05a-anzbz.
          IF rf05a-anzbz > 0.
            screen-input = 0.
          ELSEIF rf05a-ksuch IS INITIAL.
            SET CURSOR FIELD 'RF05A-KSUCH'.
          ENDIF.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.

    IF screen-group2 = '800' AND no_balance = 'X'.
      screen-invisible = 1.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.
  CLEAR no_balance.

  IF rf05a-buscs EQ space.
    rf05a-buscs = 'R'.
  ENDIF.
ENDMODULE.                 " DYNPRO_MODIFICATION_1100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR  '0100'.
ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  ook_code = sy-ucomm.
  CASE ook_code.
    WHEN 'BACK'.
      SET SCREEN 0.
    WHEN 'CANCEL'.
      SET SCREEN 0.
    WHEN 'EXIT'.
      SET SCREEN 0.
    WHEN 'SOC_01'.
      PERFORM  comp_code_new.
      LEAVE TO TRANSACTION 'ZFITR006B'.
    WHEN 'SOC_02'.
      CLEAR: ook_code.
      CLEAR sy-ucomm.
      PERFORM  perfor_simular.
    WHEN 'FUN_001'.
      CLEAR: ook_code.
      CLEAR sy-ucomm.
      PERFORM mod_grid.
    WHEN  'SAVE'.
      CLEAR: ook_code.
      CLEAR sy-ucomm.
      PERFORM graba_doc.
    WHEN  'B03'.
      CLEAR: ook_code.
      CLEAR sy-ucomm.
      CALL TRANSACTION 'FB03'.
    WHEN  'EBR2'.
      CLEAR: ook_code.
      CLEAR sy-ucomm.
      CALL TRANSACTION 'FBR2'.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Form  COMP_CODE_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM comp_code_new .
  CLEAR bkpf.
  READ TABLE xbkpf INDEX 1.
  IF sy-subrc = 0.
    bkpf = xbkpf.
  ENDIF.
  CALL FUNCTION 'DOCHEADER_COMP_CODE_WITH_POPUP'
    EXPORTING
      i_bukrs  = bkpf-bukrs
      i_status = g_status
    IMPORTING
      e_bukrs  = bkpf-bukrs
    EXCEPTIONS
      canceled = 1
      OTHERS   = 2.
  IF sy-subrc   NE 0
  OR bkpf-bukrs EQ xbkpf-bukrs.
    EXIT.
  ENDIF.
  SET PARAMETER ID 'BUK' FIELD bkpf-bukrs.
  acc_kontext-bukrs = bkpf-bukrs.
*  PERFORM SAVE_CONTEXT.
*  PERFORM TREE_DELETE.
**  leave to transaction sy-tcode.      " note 360390
*  PERFORM TRANSAKTION_VERLASSEN.      " note 360390
ENDFORM.                    " COMP_CODE_NEW
*&---------------------------------------------------------------------*
*&      Form  SAVE_CONTEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_context.

  DATA: ls_acc_kontext LIKE acc_kontext.                    "Note401924
  DATA: lt_nodes     TYPE treev_nks WITH HEADER LINE,
        lt_aux_nodes TYPE treev_nks WITH HEADER LINE,
        width        TYPE i.
* We expect less than 10 entries for these tables, so a standard
* table instead of a sorted / hashed one is ok.

* Fill g_datar evaluated in exit module
  IF NOT sy-datar IS INITIAL.
    g_datar = sy-datar.
  ENDIF.

* Batch input: Tree option is ignored                       "Note401924
  IF sy-binpt = char_x.                                     "Note401924
    ls_acc_kontext = tfbuf-buffr.                           "Note401924
    acc_kontext-xtree = ls_acc_kontext-xtree.               "Note401924
    IF tfbuf-buffr = acc_kontext.                           "Note401924
      acc_kontext-xtree = char_x.                           "Note401924
      EXIT.                                                 "Note401924
    ENDIF.                                                  "Note401924
  ENDIF.                                                    "Note401924

* ----------------------------------------------------------------------
* Get expanded nodes of tree and save them (Note 486587)
* ----------------------------------------------------------------------
* Table lt_nodes: currently expanded nodes
  CALL FUNCTION 'ACC_CA_TREE_GET_EXPANDED_NODES'
    TABLES
      it_nodes = lt_nodes.

  SPLIT acc_kontext-expanded_nodes AT '.' INTO TABLE lt_aux_nodes.
* Table lt_aux_nodes: All nodes from old user context acc_kontext
  DELETE lt_aux_nodes INDEX 1.            " delete first row

  LOOP AT lt_aux_nodes.
    CONCATENATE '.' lt_aux_nodes INTO lt_aux_nodes.
    MODIFY lt_aux_nodes.
  ENDLOOP.

  LOOP AT lt_aux_nodes.
    READ TABLE node_table WITH KEY node_key = lt_aux_nodes.
    IF sy-subrc NE 0.
      APPEND lt_aux_nodes TO lt_nodes.
* Add all nodes from old user context to new context which do NOT
* appear in the currently displayed tree and therefore cannot be
* collapsed.
    ENDIF.
  ENDLOOP.

  CLEAR acc_kontext-expanded_nodes.

  LOOP AT lt_nodes.
    CONCATENATE lt_nodes acc_kontext-expanded_nodes INTO
    acc_kontext-expanded_nodes.
  ENDLOOP.

* ----------------------------------------------------------------------
* Get width of tree.
* ----------------------------------------------------------------------
  CALL FUNCTION 'ACC_CA_TREE_GET_WIDTH'                     "Note 575336
    IMPORTING
      e_docking_size = width.
  acc_kontext-tree_width = width.                        " type cast

* ------------------  Check OLD <> NEW ? -------------------------------
  CHECK tfbuf-buffr NE acc_kontext.
* --------- Write TFBUF (user context) data ----------------------------
  tfbuf-buffr = acc_kontext.
  tfbuf-datum = sy-datlo.
  MODIFY tfbuf.

  IF sy-binpt = char_x.                                     "Note401924
    acc_kontext-xtree = char_x.                             "Note401924
  ENDIF.                                                    "Note401924

ENDFORM.                               " SAVE_CONTEXT
*&---------------------------------------------------------------------*
*&      Form  TREE_INITIALIZE
*&---------------------------------------------------------------------*
*&      Form  TREE_DELETE
*&---------------------------------------------------------------------*
FORM tree_delete.
  CALL FUNCTION 'ACC_CA_TREE_DELETE'
    EXPORTING
      i_no_flush = 'X'.
ENDFORM.                               " TREE_DELETE
*-----------------------------------------------------------------------
*        FORM TRANSAKTION_VERLASSEN
*-----------------------------------------------------------------------
FORM transaktion_verlassen.
  DATA: l_tcvariant  LIKE shdtvciu-tcvariant,               "Note 330523
        l_xclientind,                                      "Note 330523
        l_rc         LIKE sy-subrc.                                "Note 330523
  IF  sy-binpt NE char_x
* (del) and ( sy-calld ne char_x or tcode = 'FBR2' ).       "ALRK237150
    AND sy-calld NE char_x.                                 "ALRK237150
    IF tcode = space.
      tcode = sy-tcode.
    ENDIF.
*    IF XWFLA = CHAR_X.
*      LEAVE.
*    ENDIF.
    CALL FUNCTION 'RS_HDSYS_GET_TC_VARIANT'                "Note 330523
      IMPORTING                                         "Note 330523
        tcvariant               = l_tcvariant        "Note 330523
        flag_client_independent = l_xclientind       "Note 330523
        rc                      = l_rc.              "Note 330523
    IF l_rc > 2.                                           "Note 330523
      LEAVE TO TRANSACTION tcode.
    ELSE.                                                  "Note 330523
      CALL FUNCTION 'RS_HDSYS_CALL_TC_VARIANT'             "Note 330523
        EXPORTING                                         "Note 330523
          tcode                     = tcode            "Note 330523
          variant                   = l_tcvariant      "Note 330523
          i_flag_client_independent = l_xclientind     "Note 330523
          call_mode                 = ' '              "Note 330523
          authority_check           = ' '              "Note 592165
        EXCEPTIONS                                        "Note 330523
          OTHERS                    = 0.               "Note 330523
      LEAVE TO TRANSACTION tcode.                          "Note 330523
    ENDIF.                                                 "Note 330523
  ELSE.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.
ENDFORM.                    "transaktion_verlassen
*&---------------------------------------------------------------------*
*&      Form  MOD_GRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM mod_grid .
  REFRESH: it_t001.
  CLEAR: it_t001.

  LOOP AT   g_table_itab
       INTO g_table_wa.
    MOVE-CORRESPONDING  g_table_wa TO it_t001.
    APPEND it_t001.
  ENDLOOP.

  DATA: p_index LIKE sy-tabix.


  IF rf05a-buscs NE space.
    LOOP AT it_t001.
      p_index = sy-tabix.
      MOVE: zinvfo-mwskz TO it_t001-mwskz.
      IF  rf05a-buscs = 'R'.
        MOVE: 'S'  TO it_t001-shkzg.
        MODIFY it_t001 INDEX p_index.
      ELSE.
        IF  rf05a-buscs = 'G'.
          MOVE: 'H'  TO it_t001-shkzg.
          MODIFY it_t001 INDEX p_index.
        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT it_t001.
      p_index = sy-tabix.
      MOVE-CORRESPONDING it_t001 TO g_table_wa.
      MODIFY g_table_itab  FROM g_table_wa  INDEX  p_index.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " MOD_GRID
*&---------------------------------------------------------------------*
*&      Form  PERFOR_SIMULAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM perfor_simular .
  DATA it_sumula TYPE zacgl_item OCCURS 100 WITH HEADER LINE.
  DATA e_a003 TYPE a003 OCCURS 100 WITH HEADER LINE.
  REFRESH: it_t001.
  CLEAR: it_t001.

* Se cambia tipo iva_prop   de konp-kbetr a  zacgl_item-wrbtr, HCD 04-01-2017
  DATA: total_pos       LIKE zacgl_item-wrbtr,
        total_pos_s     LIKE zacgl_item-wrbtr,
        total_pos_h     LIKE zacgl_item-wrbtr,
        total_iva       LIKE zacgl_item-wrbtr,
        total_iva_no_re LIKE zacgl_item-wrbtr,
        iva_prop        LIKE zacgl_item-wrbtr,
        iva             LIKE zacgl_item-wrbtr,
        "       iva_no_re       LIKE zacgl_item-wrbtr.
        iva_no_re(10)   TYPE p DECIMALS 4.

  DATA: vl_iva     LIKE zacgl_item-wrbtr,
        vl_iva_prp LIKE zacgl_item-wrbtr.

  DATA: t_bseg  TYPE bseg OCCURS 100 WITH HEADER LINE,
        t_bseg2 TYPE bseg OCCURS 100 WITH HEADER LINE,
        t_bkpf2 TYPE bkpf OCCURS 100 WITH HEADER LINE,
        t_bkpf  TYPE bkpf OCCURS 100 WITH HEADER LINE,
        t_erinf TYPE acerrlog OCCURS 100 WITH HEADER LINE.
  DATA: i_t020  LIKE t020.
  DATA: pos TYPE i VALUE 1.

  DATA: valor    TYPE bseg-wrbtr,
        tot_por  TYPE bseg-wrbtr,
        rest_por TYPE bseg-wrbtr.
  DATA: valor2    TYPE bseg-wrbtr,
        tot_por2  TYPE bseg-wrbtr,
        rest_por2 TYPE bseg-wrbtr.


  DATA: t_dif   TYPE bseg-wrbtr,
        t_debe  TYPE bseg-wrbtr,
        t_haber TYPE bseg-wrbtr,
        aa      LIKE sy-tabix.



  DATA: pe_i_konp TYPE  konp.

* Factura
  IF rf05a-buscs EQ 'R'.
    LOOP AT   g_table_itab
         INTO g_table_wa WHERE hkont NE space.
      MOVE-CORRESPONDING  g_table_wa TO it_t001.
      APPEND it_t001.
    ENDLOOP.



    CLEAR: total_pos_s.
    LOOP AT it_t001 WHERE hkont NE space AND  shkzg EQ 'S' AND mwskz EQ 'C9'.
      ADD it_t001-wrbtr TO total_pos_s.
      CLEAR: it_t001.
    ENDLOOP.


    CLEAR: total_pos_h.
    LOOP AT it_t001 WHERE hkont NE space AND  shkzg EQ 'H' AND mwskz EQ 'C9'.
      ADD it_t001-wrbtr TO total_pos_h.
      CLEAR: it_t001.
    ENDLOOP.


    total_pos = total_pos_s - total_pos_h.
    IF total_pos > 0.
      CALL FUNCTION 'RE_KTOSL_TO_MWSKZ_GET'
        EXPORTING
          i_mwskz                        = zinvfo-mwskz
          i_bukrs                        = zinvfo-bukrs
        TABLES
          e_a003                         = e_a003
        EXCEPTIONS
          no_mwskz_in_t001land           = 1
          no_ktosl_for_mwskz_in_t001land = 2
          t638s_t007b_inconsistency      = 3
          OTHERS                         = 4.
      IF sy-subrc = 0.
        READ TABLE e_a003 INDEX 1.
        IF sy-subrc EQ 0.
          CALL FUNCTION 'WV_KONP_GET'
            EXPORTING
              pi_knumh        = e_a003-knumh
              pi_kopos        = c_01         "JOROZCO 08.01.2020
              pi_kappl        = e_a003-kappl
              pi_kschl        = e_a003-kschl
            IMPORTING
              pe_i_konp       = pe_i_konp
            EXCEPTIONS
              no_record_found = 1
              OTHERS          = 2.
          IF sy-subrc = 0.
* Calcula IVA.
            iva = pe_i_konp-kbetr / 1000.
            total_iva = total_pos *  iva.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*            SELECT SINGLE iva_prop INTO  iva_prop
*                FROM zfiivaprp
*              WHERE  bukrs EQ zinvfo-bukrs
*              AND    fec_inico <= zinvfo-budat
*              AND    fec_fin  >= zinvfo-budat.
*
* NEW CODE
            SELECT iva_prop
            UP TO 1 ROWS  INTO  iva_prop
                FROM zfiivaprp
              WHERE  bukrs EQ zinvfo-bukrs
              AND    fec_inico <= zinvfo-budat
              AND    fec_fin  >= zinvfo-budat ORDER BY PRIMARY KEY.

            ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
            IF sy-subrc EQ 0.
              iva_no_re = iva_prop / 100.
*              TOTAL_IVA_NO_RE = TOTAL_IVA * IVA_NO_RE.
              total_iva_no_re = total_iva * iva_prop / 100.

            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.



    i_t020-tcode =  'FB60'.
    i_t020-koart =    'K'.
    i_t020-aktyp =    'H'.
    i_t020-dyncl =    'B'.
    i_t020-funcl =    ' '.
    i_t020-statu =    'ENJINV'.
    i_t020-gener =    '1'.


    MOVE-CORRESPONDING bkpf TO t_bkpf.
    APPEND t_bkpf.
* Posicion de Acreedor
    MOVE-CORRESPONDING zinvfo TO t_bseg.
    t_bseg-bschl = '31'.
    t_bseg-shkzg = 'H'.
    t_bseg-buzei = '1'.
    t_bseg-koart = 'K'.
    t_bseg-pswsl = zinvfo-waers.
    t_bseg-wrbtr =  t_bseg-wrbtr +  total_iva.
    t_bseg-dmbtr =  t_bseg-wrbtr.
    t_bseg-kokrs = 'BMSA'.
    APPEND t_bseg.
    CLEAR t_bseg.



* Posicion de  cuentas de mayor
    LOOP AT it_t001 WHERE hkont NE space.
      ADD 1 TO pos.
      MOVE-CORRESPONDING it_t001 TO t_bseg.
      IF   it_t001-shkzg = 'S'.
        IF total_pos_s > 0 AND it_t001-mwskz EQ 'C9'.
* Comentado por LSC 17.10.2011
*          it_t001-porcentaje  =  ( ( t_bseg-wrbtr * 100 ) / total_pos_s ).  ""
*
*          tot_por = it_t001-porcentaje + tot_por.
*          IF  tot_por > 100.               ""
*            rest_por  =  tot_por  - 100.  ""
*            it_t001-porcentaje =  it_t001-porcentaje - rest_por.
*            CLEAR: tot_por, rest_por.
*          ENDIF.
*          IF tot_por = '99.99'.
*            rest_por  =  100 - tot_por.  ""
*            it_t001-porcentaje =  it_t001-porcentaje + rest_por.
*            CLEAR: tot_por, rest_por.
*          ENDIF.
*
*          valor        =   total_iva_no_re * it_t001-porcentaje / 100. ""
*          t_bseg-wrbtr =  t_bseg-wrbtr +  valor.

          vl_iva = t_bseg-wrbtr * iva.
          vl_iva_prp = vl_iva * iva_no_re.
          t_bseg-wrbtr =  t_bseg-wrbtr +  vl_iva_prp.
        ENDIF.
      ELSE.
        IF   it_t001-shkzg = 'H' AND it_t001-mwskz EQ 'C9'.
          IF total_pos_s > 0.
* Comentado por LSC 17.10.2011
*            it_t001-porcentaje2  =  ( ( t_bseg-wrbtr * 100 ) / total_pos_s ).
*            tot_por2 = it_t001-porcentaje2 + tot_por2.
*            IF tot_por2 > 100.
*              rest_por2  =  tot_por2  - 100.
*              it_t001-porcentaje2 =  it_t001-porcentaje2 - rest_por2.
*              CLEAR: tot_por, rest_por2.
*            ENDIF.
*
*            IF tot_por2 = '99.99'.
*              rest_por2  =  100 - tot_por.  ""
*              it_t001-porcentaje2 =  it_t001-porcentaje2 + rest_por2.
*              CLEAR: tot_por2, rest_por2.
*            ENDIF.
*
*            valor2        = total_iva_no_re * it_t001-porcentaje2 / 100.
*            t_bseg-wrbtr =  t_bseg-wrbtr +  valor2.

            vl_iva = t_bseg-wrbtr * iva.
            vl_iva_prp = vl_iva * iva_no_re.
            t_bseg-wrbtr =  t_bseg-wrbtr +  vl_iva_prp.
          ENDIF.
        ENDIF.
      ENDIF.

      t_bseg-buzei = pos.
      t_bseg-koart = 'S'.
      t_bseg-pswsl = zinvfo-waers.
      t_bseg-dmbtr =  t_bseg-wrbtr.
      t_bseg-gjahr = zinvfo-gjahr.
      t_bseg-sgtxt = zinvfo-sgtxt.            "Quintec mvm 26.07.2010
      APPEND t_bseg.
      CLEAR t_bseg.
    ENDLOOP.

    DESCRIBE TABLE t_bseg LINES aa.

    IF total_iva > 0.
* Pos iva Normal
      ADD 1 TO pos.
      t_bseg-bukrs = zinvfo-bukrs.
      t_bseg-bschl = '40'.
      t_bseg-hkont = '1013310004'.
      t_bseg-shkzg = 'S'.
      t_bseg-buzei = pos.
      t_bseg-koart = 'S'.
      t_bseg-pswsl = zinvfo-waers.
      t_bseg-dmbtr =  total_iva.
      t_bseg-wrbtr =  total_iva.
      t_bseg-kokrs = 'BMSA'.
      t_bseg-gjahr = zinvfo-gjahr.
      APPEND t_bseg.
      CLEAR t_bseg.
    ENDIF.

* Pos Iva Proporcional
    IF total_iva_no_re > 0.
      ADD 1 TO pos.
      t_bseg-bukrs = zinvfo-bukrs.
      t_bseg-bschl = '50'.
      t_bseg-hkont = '1013310005'.
      t_bseg-shkzg = 'H'.
      t_bseg-buzei = pos.
      t_bseg-koart = 'S'.
      t_bseg-pswsl = zinvfo-waers.
      t_bseg-wrbtr = total_iva_no_re - valor2.
      t_bseg-dmbtr = t_bseg-wrbtr.
      t_bseg-kokrs = 'BMSA'.
      t_bseg-gjahr = zinvfo-gjahr.
      APPEND t_bseg.
      CLEAR t_bseg.
    ENDIF.

    LOOP AT t_bseg.
      IF t_bseg-shkzg EQ 'S'.
        t_debe = t_debe + t_bseg-wrbtr.
      ELSE.
        t_haber = t_haber + t_bseg-wrbtr.
      ENDIF.
    ENDLOOP.

    t_dif = t_debe - t_haber.


*    LOOP AT t_bseg WHERE mwskz EQ 'C9'.
*      aa = sy-tabix.
*    ENDLOOP.

    READ TABLE t_bseg INDEX  aa.
    IF sy-subrc EQ 0.
      IF  t_dif > 0.
        IF t_bseg-shkzg = 'H'.
          t_bseg-wrbtr = t_bseg-wrbtr +  t_dif.   "Valor al haber esta en negativo, se le suma la diferencia positiva.
        ELSE.
          t_bseg-wrbtr = t_bseg-wrbtr -  t_dif.   "Valor al debe esta en positivo, se le resta la diferencia positiva.
        ENDIF.
      ELSE.
        IF  t_dif < 0.
          IF t_bseg-shkzg = 'H'.
            t_bseg-wrbtr = t_bseg-wrbtr + t_dif. "Valor al haber esta negativo, se le resta la diferencia negativa.
          ELSE.
            t_bseg-wrbtr = t_bseg-wrbtr -  t_dif. "Valor al debe esta positivo, se le suma la diferencia negativa.
          ENDIF.
        ENDIF.
      ENDIF.
      MODIFY t_bseg INDEX aa.

    ENDIF.

  ENDIF.

* Abonos

  IF rf05a-buscs EQ 'G'.
    LOOP AT   g_table_itab
         INTO g_table_wa WHERE hkont NE space.
      MOVE-CORRESPONDING  g_table_wa TO it_t001.
      APPEND it_t001.
    ENDLOOP.



    CLEAR: total_pos_s.
    LOOP AT it_t001 WHERE hkont NE space AND  shkzg EQ 'S' AND mwskz EQ 'C9'.
      ADD it_t001-wrbtr TO total_pos_s.
      CLEAR: it_t001.
    ENDLOOP.


    CLEAR: total_pos_h.
    LOOP AT it_t001 WHERE hkont NE space AND  shkzg EQ 'H' AND mwskz EQ 'C9'.
      ADD it_t001-wrbtr TO total_pos_h.
      CLEAR: it_t001.
    ENDLOOP.




    total_pos = total_pos_h - total_pos_s.
    IF total_pos > 0.
      CALL FUNCTION 'RE_KTOSL_TO_MWSKZ_GET'
        EXPORTING
          i_mwskz                        = zinvfo-mwskz
          i_bukrs                        = zinvfo-bukrs
        TABLES
          e_a003                         = e_a003
        EXCEPTIONS
          no_mwskz_in_t001land           = 1
          no_ktosl_for_mwskz_in_t001land = 2
          t638s_t007b_inconsistency      = 3
          OTHERS                         = 4.
      IF sy-subrc = 0.
        READ TABLE e_a003 INDEX 1.
        IF sy-subrc EQ 0.

          CALL FUNCTION 'WV_KONP_GET'
            EXPORTING
              pi_knumh        = e_a003-knumh
              pi_kopos        = c_01         "JOROZCO 08.01.2020
              pi_kappl        = e_a003-kappl
              pi_kschl        = e_a003-kschl
            IMPORTING
              pe_i_konp       = pe_i_konp
            EXCEPTIONS
              no_record_found = 1
              OTHERS          = 2.
          IF sy-subrc = 0.
* Calcula IVA.
            iva = pe_i_konp-kbetr / 1000.
            total_iva = total_pos *  iva.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*            SELECT SINGLE iva_prop INTO  iva_prop
*                FROM zfiivaprp
*              WHERE  bukrs EQ zinvfo-bukrs
*              AND    fec_inico <= zinvfo-budat
*              AND    fec_fin  >= zinvfo-budat.
*
* NEW CODE
            SELECT iva_prop
            UP TO 1 ROWS  INTO  iva_prop
                FROM zfiivaprp
              WHERE  bukrs EQ zinvfo-bukrs
              AND    fec_inico <= zinvfo-budat
              AND    fec_fin  >= zinvfo-budat ORDER BY PRIMARY KEY.

            ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
            IF sy-subrc EQ 0.
              iva_no_re = iva_prop / 100.
*              TOTAL_IVA_NO_RE = TOTAL_IVA * IVA_NO_RE.
              total_iva_no_re = total_iva * iva_prop / 100.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.




    i_t020-tcode =  'FB60'.
    i_t020-koart =    'K'.
    i_t020-aktyp =    'H'.
    i_t020-dyncl =    'B'.
    i_t020-funcl =    ' '.
    i_t020-statu =    'ENJINV'.
    i_t020-gener =    '1'.


    MOVE-CORRESPONDING bkpf TO t_bkpf.
    APPEND t_bkpf.
* Posicion de Acreedor
    MOVE-CORRESPONDING zinvfo TO t_bseg.

* LSC 14.10.2011 - Se comenta la linea en la cual asigna clave de contbl. 31, ya que lo correcto es
*                  que se asigne clave 21 que corresponde a un abono al Acreedor
*    t_bseg-bschl = '31'.
    t_bseg-bschl = '21'.
* Fin LSC 14.10.2011

    t_bseg-shkzg = 'S'.
    t_bseg-buzei = '1'.
    t_bseg-koart = 'K'.
    t_bseg-pswsl = zinvfo-waers.
    t_bseg-wrbtr =  t_bseg-wrbtr +  total_iva.
    t_bseg-dmbtr =  t_bseg-wrbtr.
    t_bseg-kokrs = 'BMSA'.
    APPEND t_bseg.
    CLEAR t_bseg.


* Posicion de  cuentas de mayor
    LOOP AT it_t001 WHERE hkont NE space.
      ADD 1 TO pos.
      MOVE-CORRESPONDING it_t001 TO t_bseg.
      IF   it_t001-shkzg = 'H'.
        IF total_pos_h > 0 AND it_t001-mwskz EQ 'C9'.

          vl_iva = t_bseg-wrbtr * iva.
          vl_iva_prp = vl_iva * iva_no_re.
          t_bseg-wrbtr =  t_bseg-wrbtr +  vl_iva_prp.
        ENDIF.
      ELSE.
        IF   it_t001-shkzg = 'S' AND it_t001-mwskz EQ 'C9'.
          IF total_pos_s > 0.

            vl_iva = t_bseg-wrbtr * iva.
            vl_iva_prp = vl_iva * iva_no_re.
            t_bseg-wrbtr =  t_bseg-wrbtr +  vl_iva_prp.
          ENDIF.
        ENDIF.
      ENDIF.

      t_bseg-buzei = pos.
      t_bseg-koart = 'S'.
      t_bseg-pswsl = zinvfo-waers.
      t_bseg-dmbtr =  t_bseg-wrbtr.
      t_bseg-gjahr = zinvfo-gjahr.
      t_bseg-sgtxt = zinvfo-sgtxt.            "Quintec mvm 26.07.2010
      APPEND t_bseg.
      CLEAR t_bseg.
    ENDLOOP.

    IF total_iva > 0.
* Pos iva Normal
      ADD 1 TO pos.
      t_bseg-bukrs = zinvfo-bukrs.
      t_bseg-bschl = '50'.
      t_bseg-hkont = '1013310004'.
      t_bseg-shkzg = 'H'.
      t_bseg-buzei = pos.
      t_bseg-koart = 'S'.
      t_bseg-pswsl = zinvfo-waers.
      t_bseg-dmbtr =  total_iva.
      t_bseg-wrbtr =  total_iva.
      t_bseg-kokrs = 'BMSA'.
      t_bseg-gjahr = zinvfo-gjahr.
      APPEND t_bseg.
      CLEAR t_bseg.
    ENDIF.

* Pos Iva Proporcional
    IF total_iva_no_re > 0.
      ADD 1 TO pos.
      t_bseg-bukrs = zinvfo-bukrs.
      t_bseg-bschl = '40'.
      t_bseg-hkont = '1013310005'.
      t_bseg-shkzg = 'S'.
      t_bseg-buzei = pos.
      t_bseg-koart = 'S'.
      t_bseg-pswsl = zinvfo-waers.
      t_bseg-wrbtr = total_iva_no_re - valor2.
      t_bseg-dmbtr = t_bseg-wrbtr.
      t_bseg-kokrs = 'BMSA'.
      t_bseg-gjahr = zinvfo-gjahr.
      APPEND t_bseg.
      CLEAR t_bseg.
    ENDIF.

    LOOP AT t_bseg.
      IF t_bseg-shkzg EQ 'S'.
        t_debe = t_debe + t_bseg-wrbtr.
      ELSE.
        t_haber = t_haber + t_bseg-wrbtr.
      ENDIF.
    ENDLOOP.

    t_dif = t_debe - t_haber.

    LOOP AT t_bseg WHERE mwskz EQ 'C9'.
      aa = sy-tabix.
    ENDLOOP.

    READ TABLE t_bseg INDEX  aa.
*    IF SY-SUBRC EQ 0.
*      IF  T_DIF > 0.
*        T_BSEG-WRBTR = T_BSEG-WRBTR +  T_DIF.
*      ELSE.
*        IF  T_DIF < 0.
*          T_BSEG-WRBTR = T_BSEG-WRBTR -  T_DIF.
*        ENDIF.
*      ENDIF.
*      MODIFY T_BSEG INDEX AA.
*    ENDIF.
    IF sy-subrc EQ 0.
      IF  t_dif > 0.
        IF t_bseg-shkzg = 'H'.
          t_bseg-wrbtr = t_bseg-wrbtr +  t_dif.   "Valor al haber esta en negativo, se le suma la diferencia positiva.
        ELSE.
          t_bseg-wrbtr = t_bseg-wrbtr -  t_dif.   "Valor al debe esta en positivo, se le resta la diferencia positiva.
        ENDIF.
      ELSE.
        IF  t_dif < 0.
          IF t_bseg-shkzg = 'H'.
            t_bseg-wrbtr = t_bseg-wrbtr +  t_dif. "Valor al haber esta negativo, se le resta la diferencia negativa.
          ELSE.
            t_bseg-wrbtr = t_bseg-wrbtr -  t_dif. "Valor al debe esta positivo, se le suma la diferencia negativa.
          ENDIF.
        ENDIF.
      ENDIF.
      MODIFY t_bseg INDEX aa.

    ENDIF.
  ENDIF.

  CALL FUNCTION 'CALCULATE_TAX_DOCUMENT'
    EXPORTING
      i_bukrs                   = zinvfo-bukrs
    TABLES
      t_bkpf                    = t_bkpf
      t_bseg                    = t_bseg
    EXCEPTIONS
      error_calculate_discountb = 04
      user_exit                 = 16.
  IF sy-subrc =  0.

    CALL FUNCTION 'ZACC_SIMULATED_DOC_DISPLAY'
      EXPORTING
        i_t020     = i_t020
        tip_salida = 'X'
      TABLES
        t_bkpf     = t_bkpf
        t_bseg     = t_bseg
        t_erinf    = t_erinf
        xxbseg     = t_bseg2
        xxbkpf     = t_bkpf2.
  ENDIF.
ENDFORM.                    " PERFOR_SIMULAR
*&---------------------------------------------------------------------*
*&      Form  MOD_IVA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM mod_iva .
  REFRESH: it_t001.
*  IT_T001[] = G_TABLE_ITAB[].
  DATA: p_index LIKE sy-tabix.


  LOOP AT it_t001.
    p_index = sy-tabix.
    MOVE: zinvfo-mwskz TO it_t001-mwskz.
    MODIFY it_t001 INDEX p_index.
  ENDLOOP.

  REFRESH: t_salida.
  t_salida[] =  it_t001[].

  DATA: fila TYPE lvc_s_row,
        colu TYPE lvc_s_col.
  CALL METHOD r_alv_grid->get_current_cell
    IMPORTING
      es_row_id = fila
      es_col_id = colu.

*  CALL METHOD R_ALV_GRID->REFRESH_TABLE_DISPLAY.
*
*  CALL METHOD R_ALV_GRID->SET_CURRENT_CELL_VIA_ID
*    EXPORTING
*      IS_ROW_ID    = FILA
*      IS_COLUMN_ID = COLU.
ENDFORM.                    " MOD_IVA

*----------------------------------------------------------------------*
*  MODULE TABLE_INIT OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE table_init OUTPUT.
  IF g_table_copied IS INITIAL.
    SELECT * FROM zacgl_item_tbctr
       INTO CORRESPONDING FIELDS
       OF TABLE g_table_itab.
    g_table_copied = 'X'.
    REFRESH CONTROL 'TABLE' FROM SCREEN '0100'.
  ENDIF.
ENDMODULE.                    "TABLE_INIT OUTPUT
*----------------------------------------------------------------------*
*  MODULE TABLE_GET_LINES OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE table_get_lines OUTPUT.
  g_table_lines = sy-loopc.
  IF g_table_itab IS INITIAL.
    initial_line = 'X'.
  ELSE.
    CLEAR initial_line.
  ENDIF.

  IF initial_line EQ 'X'.
*    PERFORM INIT_LINE.
    IF g_table_wa-bukrs EQ space.
      IF zinvfo-bukrs IS INITIAL.
        g_table_wa-bukrs = bkpf-bukrs.
        IF g_ausbk IS INITIAL.           "auslösender Buchungskreis
          g_ausbk = bkpf-bukrs.
        ENDIF.
      ELSE.
        g_table_wa-bukrs = zinvfo-bukrs.
        g_ausbk =  zinvfo-bukrs.
      ENDIF.
    ENDIF.

    IF g_table_wa-shkzg IS INITIAL.
      IF koart = 'K'.
        g_table_wa-shkzg  = 'S'.
      ELSE.
        g_table_wa-shkzg  = 'H'.
      ENDIF.
    ENDIF.

    IF g_table_wa-hkont IS INITIAL.
      IF zinvfo-mwskz NE '**'.
        g_table_wa-mwskz  = zinvfo-mwskz.
      ENDIF.
    ENDIF.

    IF g_table_wa-zzrut_terc  EQ space.
      g_table_wa-zzrut_terc  =   zinvfo-lifnr.
    ENDIF.

    IF NOT  g_table_wa-bukrs IS INITIAL
        AND NOT g_table_wa-hkont  IS INITIAL.
      CALL FUNCTION 'READ_ACCOUNT_TEXT'
        EXPORTING
          i_ccode  = g_table_wa-bukrs
          i_glacc  = g_table_wa-hkont
        IMPORTING
          e_gltext = g_table_wa-konto_txt.
    ENDIF.
  ELSE.
    IF g_table_wa-bukrs EQ space.
      IF zinvfo-bukrs IS INITIAL.
        g_table_wa-bukrs = bkpf-bukrs.
        IF g_ausbk IS INITIAL.           "auslösender Buchungskreis
          g_ausbk = bkpf-bukrs.
        ENDIF.
      ELSE.
        g_table_wa-bukrs = zinvfo-bukrs.
        g_ausbk =  zinvfo-bukrs.
      ENDIF.
    ENDIF.

    IF g_table_wa-shkzg IS INITIAL.
      IF koart = 'K'.
        g_table_wa-shkzg  = 'S'.
      ELSE.
        g_table_wa-shkzg  = 'H'.
      ENDIF.
    ENDIF.

    IF g_table_wa-hkont IS INITIAL.
      IF zinvfo-mwskz NE '**'.
        g_table_wa-mwskz  = zinvfo-mwskz.
      ENDIF.
    ENDIF.


    IF NOT  g_table_wa-bukrs IS INITIAL
        AND NOT g_table_wa-hkont  IS INITIAL.
      CALL FUNCTION 'READ_ACCOUNT_TEXT'
        EXPORTING
          i_ccode  = g_table_wa-bukrs
          i_glacc  = g_table_wa-hkont
        IMPORTING
          e_gltext = g_table_wa-konto_txt.
    ENDIF.

  ENDIF.
  id_fin_company = zinvfo-bukrs.

  CALL FUNCTION 'CON_FIN_GET_KOKRS_FROM_COMPANY'
    EXPORTING
      id_fin_company = id_fin_company
    IMPORTING
      ed_kokrs       = g_table_wa-kokrs.
** Modificado por L_FOUBERT 13.09.2013 Campos de texto automatico
  IF g_table_wa-hkont IS NOT INITIAL.
    g_table_wa-sgtxt = zinvfo-sgtxt.
    g_table_wa-zuonr = zinvfo-xblnr.
  ELSE.
    CLEAR: g_table_wa-sgtxt, g_table_wa-zuonr.
  ENDIF.

** END L_FOUBERT 13.09.2013 Campos de texto automatico
  MOVE-CORRESPONDING g_table_wa TO zacgl_item_tbctr.
  PERFORM get_field.
ENDMODULE.                    "TABLE_GET_LINES OUTPUT


*----------------------------------------------------------------------*
*  MODULE TABLE_MODIFY INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE table_modify INPUT.

  IF zacgl_item_tbctr-bukrs EQ space.
    zacgl_item_tbctr-bukrs = zinvfo-bukrs.
    id_fin_company = zacgl_item_tbctr-bukrs.

    CALL FUNCTION 'CON_FIN_GET_KOKRS_FROM_COMPANY'
      EXPORTING
        id_fin_company = id_fin_company
      IMPORTING
        ed_kokrs       = zacgl_item_tbctr-kokrs.
  ENDIF.

  MOVE-CORRESPONDING zacgl_item_tbctr TO g_table_wa.

  IF zacgl_item_tbctr-hkont NE space.
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        info   = TEXT-e14
        name   = 'ICON_CHECKED'
      IMPORTING
        result = g_table_wa-state.
  ENDIF.

  IF zacgl_item_tbctr-aufnr NE space.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE prctr INTO g_table_wa-prctr
*               FROM coas
*               WHERE aufnr EQ zacgl_item_tbctr-aufnr.
*
* NEW CODE
    SELECT prctr
    UP TO 1 ROWS  INTO g_table_wa-prctr
               FROM coas
               WHERE aufnr EQ zacgl_item_tbctr-aufnr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.

  IF zacgl_item_tbctr-zzrut_terc  EQ space.
    g_table_wa-zzrut_terc  =   zinvfo-lifnr.
  ENDIF.



  IF zacgl_item_tbctr-kostl NE space.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE prctr INTO g_table_wa-prctr
*               FROM csks
*               WHERE kostl EQ zacgl_item_tbctr-kostl.
*
* NEW CODE
    SELECT prctr
    UP TO 1 ROWS  INTO g_table_wa-prctr
               FROM csks
               WHERE kostl EQ zacgl_item_tbctr-kostl ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.

*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES02 ECDK917080 *
*  SORT g_table_itab . "JOROZCO 28.01.2020
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES02 ECDK917080 *
  MODIFY g_table_itab
    FROM g_table_wa
    INDEX table-current_line.
  IF sy-subrc NE 0.
    APPEND g_table_wa TO g_table_itab.
  ENDIF.
ENDMODULE.                    "TABLE_MODIFY INPUT


*----------------------------------------------------------------------*
*  MODULE TABLE_USER_COMMAND INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE table_user_command INPUT.
  ook_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TABLE'
                              'G_TABLE_ITAB'
                              'MARKSP'
*                              'FLAG'
                     CHANGING ook_code.
  sy-ucomm = ook_code.
ENDMODULE.                    "TABLE_USER_COMMAND INPUT

*----------------------------------------------------------------------*
*   INCLUDE TABLECONTROL_FORMS                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC                                               *
*&---------------------------------------------------------------------*
FORM user_ok_tc USING    p_tc_name TYPE dynfnam
                         p_table_name
                         p_mark_name
                CHANGING p_ok      LIKE sy-ucomm.

  DATA: l_ok     TYPE sy-ucomm,
        l_offset TYPE i.

  SEARCH p_ok FOR p_tc_name.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.
  l_offset = strlen( p_tc_name ) + 1.
  l_ok = p_ok+l_offset.
  CASE l_ok.
    WHEN 'INSR'.                      "insert row
      PERFORM fcode_insert_row USING    p_tc_name
                                        p_table_name.
      CLEAR p_ok.

    WHEN 'DELE'.                      "delete row
      PERFORM fcode_delete_row USING    p_tc_name
                                        p_table_name
                                        p_mark_name.
      CLEAR p_ok.

    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM compute_scrolling_in_tc USING p_tc_name
                                            l_ok.
      CLEAR p_ok.
*     WHEN 'L--'.                       "total left
*       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
*
*     WHEN 'L-'.                        "column left
*       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
*
*     WHEN 'R+'.                        "column right
*       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
*
*     WHEN 'R++'.                       "total right
*       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
*
    WHEN 'MARK'.                      "mark all filled lines
      PERFORM fcode_tc_mark_lines USING p_tc_name
                                        p_table_name
                                        p_mark_name   .
      CLEAR p_ok.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM fcode_tc_demark_lines USING p_tc_name
                                          p_table_name
                                          p_mark_name .
      CLEAR p_ok.

*     WHEN 'SASCEND'   OR
*          'SDESCEND'.                  "sort column
*       PERFORM FCODE_SORT_TC USING P_TC_NAME
*                                   l_ok.

  ENDCASE.

ENDFORM.                              " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_INSERT_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_insert_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name             .

  DATA l_lines_name       LIKE feld-name.
  DATA l_selline          LIKE sy-stepl.
  DATA l_lastline         TYPE i.
  DATA l_line             TYPE i.
  DATA l_table_name       LIKE feld-name.
  FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
  FIELD-SYMBOLS <table>              TYPE STANDARD TABLE.
  FIELD-SYMBOLS <lines>              TYPE i.

  ASSIGN (p_tc_name) TO <tc>.

  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_lines_name.
  ASSIGN (l_lines_name) TO <lines>.

  GET CURSOR LINE l_selline.
  IF sy-subrc <> 0.                   " append line to table
    l_selline = <tc>-lines + 1.
    IF l_selline > <lines>.
      <tc>-top_line = l_selline - <lines> + 1 .
    ELSE.
      <tc>-top_line = 1.
    ENDIF.
  ELSE.                               " insert line into table
    l_selline = <tc>-top_line + l_selline - 1.
    l_lastline = <tc>-top_line + <lines> - 1.
  ENDIF.
  l_line = l_selline - <tc>-top_line + 1.

  INSERT INITIAL LINE INTO <table> INDEX l_selline.
  <tc>-lines = <tc>-lines + 1.
  SET CURSOR LINE l_line.

ENDFORM.                              " FCODE_INSERT_ROW

*&---------------------------------------------------------------------*
*&      Form  FCODE_DELETE_ROW                                         *
*&---------------------------------------------------------------------*
FORM fcode_delete_row
              USING    p_tc_name           TYPE dynfnam
                       p_table_name
                       p_mark_name   .

  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.

  ASSIGN (p_tc_name) TO <tc>.

  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

  DESCRIBE TABLE <table> LINES <tc>-lines.

  LOOP AT <table> ASSIGNING <wa>.
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.
    IF <mark_field> = 'X'.
      DELETE <table> INDEX syst-tabix.
      IF sy-subrc = 0.
        <tc>-lines = <tc>-lines - 1.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                              " FCODE_DELETE_ROW

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*      -->P_OK       ok code
*----------------------------------------------------------------------*
FORM compute_scrolling_in_tc USING    p_tc_name
                                      p_ok.
  DATA l_tc_new_top_line     TYPE i.
  DATA l_tc_name             LIKE feld-name.
  DATA l_tc_lines_name       LIKE feld-name.
  DATA l_tc_field_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <lines>      TYPE i.

  ASSIGN (p_tc_name) TO <tc>.
  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
  ASSIGN (l_tc_lines_name) TO <lines>.


  IF <tc>-lines = 0.
    l_tc_new_top_line = 1.
  ELSE.
    CALL FUNCTION 'SCROLLING_IN_TABLE'
      EXPORTING
        entry_act      = <tc>-top_line
        entry_from     = 1
        entry_to       = <tc>-lines
        last_page_full = 'X'
        loops          = <lines>
        ok_code        = p_ok
        overlapping    = 'X'
      IMPORTING
        entry_new      = l_tc_new_top_line
      EXCEPTIONS
*       NO_ENTRY_OR_PAGE_ACT  = 01
*       NO_ENTRY_TO    = 02
*       NO_OK_CODE_OR_PAGE_GO = 03
        OTHERS         = 0.
  ENDIF.

  GET CURSOR FIELD l_tc_field_name
             AREA  l_tc_name.

  IF syst-subrc = 0.
    IF l_tc_name = p_tc_name.
      SET CURSOR FIELD l_tc_field_name LINE 1.
    ENDIF.
  ENDIF.

  <tc>-top_line = l_tc_new_top_line.
ENDFORM.                              " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
*       marks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_mark_lines USING p_tc_name
                               p_table_name
                               p_mark_name.
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.

  ASSIGN (p_tc_name) TO <tc>.

  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

  LOOP AT <table> ASSIGNING <wa>.

    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = 'X'.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
*       demarks all TableControl lines
*----------------------------------------------------------------------*
*      -->P_TC_NAME  name of tablecontrol
*----------------------------------------------------------------------*
FORM fcode_tc_demark_lines USING p_tc_name
                                 p_table_name
                                 p_mark_name .
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.

  ASSIGN (p_tc_name) TO <tc>.

  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

  LOOP AT <table> ASSIGNING <wa>.

    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = space.
  ENDLOOP.
ENDFORM.                                          "fcode_tc_mark_lines

INCLUDE zfimdp010_b.

INCLUDE zactivo_foijo_b.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0110 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.
  zinvfo-zuonr = zinvfo-xblnr.

ENDMODULE.                 " STATUS_0110  OUTPUT
