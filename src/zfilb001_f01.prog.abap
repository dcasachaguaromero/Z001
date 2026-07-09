*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFILB002_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_documents
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_documents .

  DATA: ls_bkpf   TYPE bkpf,
        ls_bseg   TYPE bseg,
        ls_bset   TYPE bset,
        ls_outtab TYPE ty_s_outtab,
        ls_outnul TYPE zfoliosnulos.

  DATA: ls_folnul LIKE zfoliosnulos OCCURS 0 WITH HEADER LINE.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM zfoliosnulos
*    INTO  TABLE ls_folnul
*   WHERE bukrs EQ p_bukrs
*     AND gjahr EQ p_gjahr
*     AND monat IN s_monat
*     AND blart IN gr_blart
*    .
*
* NEW CODE
  SELECT *
 FROM zfoliosnulos
    INTO  TABLE ls_folnul
   WHERE bukrs EQ p_bukrs
     AND gjahr EQ p_gjahr
     AND monat IN s_monat
     AND blart IN gr_blart
     ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM bkpf
*    INTO CORRESPONDING FIELDS OF TABLE gt_bkpf
*    WHERE bukrs EQ p_bukrs
*    AND gjahr EQ p_gjahr
*    AND belnr IN s_belnr
*    AND blart IN gr_blart
*    AND monat IN s_monat
*    AND xblnr IN s_xblnr
*    AND stblg EQ space.
*
* NEW CODE
  SELECT *
 FROM bkpf
    INTO CORRESPONDING FIELDS OF TABLE gt_bkpf
    WHERE bukrs EQ p_bukrs
    AND gjahr EQ p_gjahr
    AND belnr IN s_belnr
    AND blart IN gr_blart
    AND monat IN s_monat
    AND xblnr IN s_xblnr
    AND stblg EQ space ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  LOOP AT gt_bkpf INTO ls_bkpf .
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM bseg
*      INTO CORRESPONDING FIELDS OF TABLE gt_bseg
*      WHERE bukrs EQ ls_bkpf-bukrs
*      AND belnr EQ ls_bkpf-belnr
*      AND gjahr EQ ls_bkpf-gjahr
*      AND ( mwskz EQ 'D0' OR mwskz EQ 'D1' ).
*
* NEW CODE
    SELECT *
 FROM bseg
      INTO CORRESPONDING FIELDS OF TABLE gt_bseg
      WHERE bukrs EQ ls_bkpf-bukrs
      AND belnr EQ ls_bkpf-belnr
      AND gjahr EQ ls_bkpf-gjahr
      AND ( mwskz EQ 'D0' OR mwskz EQ 'D1' ) ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

************ SOLO PARA SACAR DATOS DEL DEUDOR
    SELECT * FROM bseg
    INTO CORRESPONDING FIELDS OF TABLE gt2_bseg
    WHERE bukrs EQ ls_bkpf-bukrs
    AND belnr EQ ls_bkpf-belnr
    AND gjahr EQ ls_bkpf-gjahr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
*AND KOART EQ 'D'.
    AND koart EQ 'D' ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *


    LOOP AT gt2_bseg INTO ls_bseg.

      PERFORM get_info_kna1
                  USING    ls_bseg
                  CHANGING ls_outtab.

    ENDLOOP.
***************************************************************

    SELECT * FROM bset
    INTO CORRESPONDING FIELDS OF TABLE gt_bset
    WHERE bukrs EQ ls_bkpf-bukrs
    AND belnr EQ ls_bkpf-belnr
    AND gjahr EQ ls_bkpf-gjahr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
    AND ( mwskz EQ 'D0' OR ( mwskz EQ 'D1' AND hwste NE 0 ) ) ORDER BY hwste ASCENDING.
*elimino cambio realizado por resq .. rodrigo pinto 24022020
*AND ( MWSKZ EQ 'D0' OR MWSKZ EQ 'D1' ) ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *

* ini - Waldo Alarcón - Visionone - 11-08-2020
    IF gt_bset[] IS INITIAL.
      READ TABLE gt_bseg INTO bseg INDEX 1.
      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING bseg TO ls_bset.
        CASE bseg-mwskz.
          WHEN 'D0'.
            ls_bset-hwbas = bseg-dmbtr.
            ls_bset-fwbas = bseg-wrbtr.
          WHEN OTHERS.
            ls_bset-hwste = bseg-dmbtr.
            ls_bset-fwste = bseg-wrbtr.
        ENDCASE.
        APPEND ls_bset TO gt_bset.
      ENDIF.
    ENDIF.
* fin - Waldo Alarcón - Visionone - 11-08-2020

    LOOP AT gt_bset INTO ls_bset.
      PERFORM determine_tax
                  USING
                     ls_bset
                     ls_bkpf
                  CHANGING
                     ls_outtab.
    ENDLOOP.

    IF gt_bset[] IS NOT INITIAL OR gt_bseg[] IS NOT INITIAL.
*****   SE ASIGNA XBLNR A
      MOVE  ls_bkpf-xblnr TO ls_outtab-xblnr2.
******************************************
      MOVE-CORRESPONDING ls_bkpf TO ls_outtab.
      COLLECT ls_outtab INTO   gt_outtab.
      CLEAR:ls_outtab-taxbash1,
            ls_outtab-taxbash2,
            ls_outtab-taxbash3,
            ls_outtab-taxbash4,
            ls_outtab-taxbash5,
            ls_outtab-sum_all .
    ENDIF.
  ENDLOOP.
*  se agregan los folios nulos.
  CLEAR ls_outtab.
  LOOP AT ls_folnul INTO ls_outnul.
    MOVE ls_outnul-bukrs  TO ls_outtab-bukrs.
    MOVE ls_outnul-gjahr  TO ls_outtab-gjahr.
    MOVE ls_outnul-xblnr  TO ls_outtab-xblnr.
    MOVE ls_outnul-xblnr  TO ls_outtab-xblnr2.
    MOVE ls_outnul-fecanu TO ls_outtab-bldat.
    MOVE 'Documento Nulo' TO ls_outtab-name1.
    MOVE '-' TO ls_outtab-stcd1.
*    MOVE '-' TO LS_OUTTAB-belnr.
*   MOVE  BLDAT    TYPE BLDAT,
    MOVE ls_outnul-blart TO ls_outtab-blart.
    MOVE 0      TO ls_outtab-taxbash1. " AFECTO
    MOVE 0      TO ls_outtab-taxbash2." EXENTO
    MOVE 0      TO ls_outtab-taxbash3." IVA
    MOVE 0      TO ls_outtab-sum_all." VALOR TOTAL
    MOVE 'CLP'  TO ls_outtab-waers. "MONEDA"
*    COLLECT  LS_OUTTAB INTO GT_OUTTAB.

    APPEND ls_outtab TO gt_outtab.
  ENDLOOP.

*****************INICIO CODIGO INGRESADO POR HERMAN***************
  LOOP AT gt_outtab INTO ls_outtab WHERE blart IN p_brtn_2
                                       OR blart IN p_brte_2.
    ls_outtab-taxbash1 = - ls_outtab-taxbash1.
    ls_outtab-taxbash2 = - ls_outtab-taxbash2.
    ls_outtab-taxbash3 = - ls_outtab-taxbash3.
    ls_outtab-taxbash4 = - ls_outtab-taxbash4.
    ls_outtab-taxbash5 = - ls_outtab-taxbash5.
    ls_outtab-sum_all = - ls_outtab-sum_all.

    MODIFY TABLE gt_outtab FROM ls_outtab
       TRANSPORTING taxbash1  taxbash2  taxbash3  taxbash4  taxbash5  sum_all.
  ENDLOOP.


*****************FIN CODIGO INGRESADO POR HERMAN***************

*  SORT gt_outtab BY blart bldat xblnr.
  SORT gt_outtab BY blart xblnr2.
ENDFORM.                    " get_documents
*&---------------------------------------------------------------------*
*&      Form  fill_blart
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_blart .
  DATA:lr_balrt TYPE rng_blart.

  IF p_brte_1 IS NOT INITIAL.
    MOVE 'I' TO lr_balrt-sign.
    MOVE 'BT' TO lr_balrt-option.
    MOVE p_brte_1-low  TO lr_balrt-low.
    MOVE p_brte_1-high  TO lr_balrt-high.
    APPEND lr_balrt TO gr_blart.
    CLEAR lr_balrt.
  ENDIF.

  IF p_brte_2 IS NOT INITIAL.
    MOVE 'I' TO lr_balrt-sign.
    MOVE 'BT' TO lr_balrt-option.
    MOVE p_brte_2-low  TO lr_balrt-low.
    MOVE p_brte_2-high  TO lr_balrt-high.
    APPEND lr_balrt TO gr_blart.
    CLEAR lr_balrt.
  ENDIF.

  IF p_brte_3 IS NOT INITIAL.
    MOVE 'I' TO lr_balrt-sign.
    MOVE 'BT' TO lr_balrt-option.
    MOVE p_brte_3-low  TO lr_balrt-low.
    MOVE p_brte_3-high  TO lr_balrt-high.
    APPEND lr_balrt TO gr_blart.
    CLEAR lr_balrt.
  ENDIF.

  IF p_brte_4 IS NOT INITIAL.
    MOVE 'I' TO lr_balrt-sign.
    MOVE 'BT' TO lr_balrt-option.
    MOVE p_brte_4-low  TO lr_balrt-low.
    MOVE p_brte_4-high  TO lr_balrt-high.
    APPEND lr_balrt TO gr_blart.
    CLEAR lr_balrt.
  ENDIF.

*  IF p_brte_5 IS NOT INITIAL.
*    MOVE 'I' TO lr_balrt-sign.
*    MOVE 'EQ' TO lr_balrt-option.
*    MOVE p_brte_5  TO lr_balrt-low.
*    APPEND lr_balrt TO gr_blart.
*    CLEAR lr_balrt.
*  ENDIF.
*
*  IF p_brte_6 IS NOT INITIAL.
*    MOVE 'I' TO lr_balrt-sign.
*    MOVE 'EQ' TO lr_balrt-option.
*    MOVE p_brte_6  TO lr_balrt-low.
*    APPEND lr_balrt TO gr_blart.
*    CLEAR lr_balrt.
*  ENDIF.
*
*  IF p_brte_7 IS NOT INITIAL.
*    MOVE 'I' TO lr_balrt-sign.
*    MOVE 'EQ' TO lr_balrt-option.
*    MOVE p_brte_7  TO lr_balrt-low.
*    APPEND lr_balrt TO gr_blart.
*    CLEAR lr_balrt.
*  ENDIF.


  IF p_brtn_1 IS NOT INITIAL.
    MOVE 'I' TO lr_balrt-sign.
    MOVE 'BT' TO lr_balrt-option.
    MOVE p_brtn_1-low  TO lr_balrt-low.
    MOVE p_brtn_1-high  TO lr_balrt-high.
    APPEND lr_balrt TO gr_blart.
    CLEAR lr_balrt.
  ENDIF.

  IF p_brtn_2 IS NOT INITIAL.
    MOVE 'I' TO lr_balrt-sign.
    MOVE 'BT' TO lr_balrt-option.
    MOVE p_brtn_2-low  TO lr_balrt-low.
    MOVE p_brtn_2-high  TO lr_balrt-high.
    APPEND lr_balrt TO gr_blart.
    CLEAR lr_balrt.
  ENDIF.

  IF p_brtn_3 IS NOT INITIAL.
    MOVE 'I' TO lr_balrt-sign.
    MOVE 'BT' TO lr_balrt-option.
    MOVE p_brtn_3-low  TO lr_balrt-low.
    MOVE p_brtn_3-high  TO lr_balrt-high.
    APPEND lr_balrt TO gr_blart.
    CLEAR lr_balrt.
  ENDIF.

  IF p_brtn_4 IS NOT INITIAL.
    MOVE 'I' TO lr_balrt-sign.
    MOVE 'BT' TO lr_balrt-option.
    MOVE p_brtn_4-low  TO lr_balrt-low.
    MOVE p_brtn_4-high  TO lr_balrt-high.
    APPEND lr_balrt TO gr_blart.
    CLEAR lr_balrt.
  ENDIF.

*  IF p_brtn_5 IS NOT INITIAL.
*    MOVE 'I' TO lr_balrt-sign.
*    MOVE 'EQ' TO lr_balrt-option.
*    MOVE p_brtn_5  TO lr_balrt-low.
*    APPEND lr_balrt TO gr_blart.
*    CLEAR lr_balrt.
*  ENDIF.
*
*  IF p_brtn_6 IS NOT INITIAL.
*    MOVE 'I' TO lr_balrt-sign.
*    MOVE 'EQ' TO lr_balrt-option.
*    MOVE p_brtn_6  TO lr_balrt-low.
*    APPEND lr_balrt TO gr_blart.
*    CLEAR lr_balrt.
*  ENDIF.
*
*  IF p_brtn_7 IS NOT INITIAL.
*    MOVE 'I' TO lr_balrt-sign.
*    MOVE 'EQ' TO lr_balrt-option.
*    MOVE p_brtn_7  TO lr_balrt-low.
*    APPEND lr_balrt TO gr_blart.
*    CLEAR lr_balrt.
*  ENDIF.
*
*  IF p_brtn_8 IS NOT INITIAL.
*    MOVE 'I' TO lr_balrt-sign.
*    MOVE 'EQ' TO lr_balrt-option.
*    MOVE p_brtn_8  TO lr_balrt-low.
*    APPEND lr_balrt TO gr_blart.
*    CLEAR lr_balrt.
*  ENDIF.
*
*  IF p_brtn_9 IS NOT INITIAL.
*    MOVE 'I' TO lr_balrt-sign.
*    MOVE 'EQ' TO lr_balrt-option.
*    MOVE p_brtn_9  TO lr_balrt-low.
*    APPEND lr_balrt TO gr_blart.
*    CLEAR lr_balrt.
*  ENDIF.

ENDFORM.                    " fill_blart
*&---------------------------------------------------------------------*
*&      Form  INIT_BLART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_blart .

  REFRESH p_brte_1. "factura Electronica"
  MOVE 'I' TO p_brte_1-sign.
  MOVE 'BT' TO p_brte_1-option.
  MOVE 'G3'  TO p_brte_1-low.
  MOVE 'G4'  TO p_brte_1-high.
  APPEND p_brte_1.

  REFRESH p_brte_2. "NOTA DE CREDITO Electronica"
  MOVE 'I' TO p_brte_2-sign.
  MOVE 'BT' TO p_brte_2-option.
  MOVE 'J3'  TO p_brte_2-low.
  MOVE 'J4'  TO p_brte_2-high.
  APPEND p_brte_2.

  REFRESH p_brte_3. "NOTA DE DEBITO Electronica"

  MOVE 'I' TO p_brte_3-sign.
  MOVE 'BT' TO p_brte_3-option.
  MOVE 'L3'  TO p_brte_3-low.
  MOVE 'L4'  TO p_brte_3-high.
  APPEND p_brte_3.

  REFRESH p_brte_4. "boleta Electronica"

  MOVE 'I' TO p_brte_4-sign.
  MOVE 'BT' TO p_brte_4-option.
  MOVE 'O3'  TO p_brte_4-low.
  MOVE 'O4'  TO p_brte_4-high.
  APPEND p_brte_4.

*************************************************+
  REFRESH p_brtn_1. "factura"
  MOVE 'I' TO p_brtn_1-sign.
  MOVE 'BT' TO p_brtn_1-option.
  MOVE 'G1'  TO p_brtn_1-low.
  MOVE 'G2'  TO p_brtn_1-high.
  APPEND p_brtn_1.

  REFRESH p_brtn_2. "nota de credito"
  MOVE 'I' TO p_brtn_2-sign.
  MOVE 'BT' TO p_brtn_2-option.
  MOVE 'J1'  TO p_brtn_2-low.
  MOVE 'J2'  TO p_brtn_2-high.
  APPEND p_brtn_2.


  REFRESH p_brtn_3. "nota de DEBITO"
  MOVE 'I' TO p_brtn_3-sign.
  MOVE 'BT' TO p_brtn_3-option.
  MOVE 'L1'  TO p_brtn_3-low.
  MOVE 'L2'  TO p_brtn_3-high.
  APPEND p_brtn_3.


  REFRESH p_brtn_4. "BOLETA
  MOVE 'I' TO p_brtn_4-sign.
  MOVE 'BT' TO p_brtn_4-option.
  MOVE 'O1'  TO p_brtn_4-low.
  MOVE 'O2'  TO p_brtn_4-high.
  APPEND p_brtn_4.


*  MOVE 'F1' TO  p_brtn_1.
*  MOVE 'F2' TO  p_brtn_2.
*  MOVE 'F5' TO  p_brtn_3.
*  MOVE 'I1' TO  p_brtn_4.

ENDFORM.                    " INIT_BLART
*&---------------------------------------------------------------------*
*&      Form  fieldcat_init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM fieldcat_init USING lt_fieldcat TYPE slis_t_fieldcat_alv
                          lt_fieldcat_100 TYPE lvc_t_fcat.
  DATA: ls_fieldcat     TYPE slis_fieldcat_alv,
        ls_fieldcat_100 TYPE lvc_s_fcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BLART'.
  ls_fieldcat-seltext_m = 'Cl Doc.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 6.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BLDAT'.
  ls_fieldcat-seltext_m = 'Fec. de Doc.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 12.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BELNR'.
  ls_fieldcat-seltext_m = 'Documento'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'XBLNR'.
  ls_fieldcat-seltext_m = 'Nro Fact.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
*  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STCD1'.
  ls_fieldcat-seltext_m = 'R.U.T'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 13.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'NAME1'.
  ls_fieldcat-seltext_m = 'Nombre'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 30.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BRSCH'.
  ls_fieldcat-seltext_m = 'Ramo'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 13.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TAXBASH2'.
  ls_fieldcat-seltext_m = 'Exento'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-do_sum    = 'X'.
  ls_fieldcat-cfieldname = 'WAERS'.
  ls_fieldcat-outputlen = 13.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TAXBASH1'.
  ls_fieldcat-seltext_m = 'Afecto'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-do_sum    = 'X'.
  ls_fieldcat-cfieldname = 'WAERS'.
  ls_fieldcat-outputlen = 13.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TAXBASH3'.
  ls_fieldcat-seltext_m = 'IVA'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-do_sum    = 'X'.
  ls_fieldcat-cfieldname = 'WAERS'.
  ls_fieldcat-outputlen = 13.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SUM_ALL'.
  ls_fieldcat-seltext_m = 'Valor Total'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-do_sum    = 'X'.
  ls_fieldcat-cfieldname = 'WAERS'.
  ls_fieldcat-outputlen = 13.
  APPEND ls_fieldcat TO lt_fieldcat.

*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'BUDAT'.
*  ls_fieldcat-seltext_m = 'Fec. de Doc.'.
*  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
*  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
*  ls_fieldcat-outputlen = 12.
*  APPEND ls_fieldcat TO lt_fieldcat.

*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'TAXBASH4'.
*  ls_fieldcat-seltext_m = 'IVA No Ret.'.
*  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
*  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
*  ls_fieldcat-do_sum    = 'X'.
*  ls_fieldcat-cfieldname = 'WAERS'.
*  ls_fieldcat-outputlen = 13.
*  APPEND ls_fieldcat TO lt_fieldcat.

*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'TAXBASH5'.
*  ls_fieldcat-seltext_m = 'Otros Imptos.'.
*  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
*  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
*  ls_fieldcat-do_sum    = 'X'.
*  ls_fieldcat-cfieldname = 'WAERS'.
*  ls_fieldcat-outputlen = 13.
*  APPEND ls_fieldcat TO lt_fieldcat.

*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname = 'WAERS'.
*  ls_fieldcat-seltext_m = 'Moneda'.
*  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
*  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
*  ls_fieldcat-outputlen = 6.
*  APPEND ls_fieldcat TO lt_fieldcat.

ENDFORM.                    "fieldcat_init
*&---------------------------------------------------------------------*
*&      Form  show_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM show_alv.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_buffer_active             = 'X'
      i_callback_program          = g_repid
      i_callback_user_command     = 'USER_COMMAND'
      i_callback_html_top_of_page = g_callback_html_top_of_page
      i_callback_pf_status_set    = 'SET_STATUS'
      is_layout                   = gs_layout
      it_sort                     = gt_sort[]
      it_fieldcat                 = gt_fieldcat[]
      is_variant                  = gs_variant
      i_html_height_top           = g_html_height_top
*     i_html_height_end           = 10
    TABLES
      t_outtab                    = gt_outtab.

ENDFORM.                    "show_alv
*&---------------------------------------------------------------------*
*&      Form  html_top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->DOCUMENT   text
*----------------------------------------------------------------------*
FORM html_top_of_page USING document
                            TYPE REF TO cl_dd_document.     "#EC CALLED

  DATA: l_title    TYPE sdydo_text_element,
        l_text     TYPE sdydo_text_element,
        l_font     TYPE sdydo_attribute VALUE '1',
        ls_zfigiro TYPE zfigiro,
        l_month    TYPE fcltx.


  CONCATENATE g_address_value-name1 ''
    INTO l_text SEPARATED BY space.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.

  l_text = 'Giro'.
  CALL METHOD document->new_line.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.

  LOOP AT gt_zfigiro INTO   ls_zfigiro.
    IF NOT ls_zfigiro-giro_1 IS INITIAL.

      MOVE  ls_zfigiro-giro_1 TO l_text.
*      TRANSLATE l_text TO LOWER CASE.
      CALL METHOD document->add_gap
        EXPORTING
          width = 10.
      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

    IF NOT  ls_zfigiro-giro_2 IS INITIAL.
      ADD 1 TO g_html_height_top .
      MOVE  ls_zfigiro-giro_2 TO l_text.
*      TRANSLATE l_text TO LOWER CASE.
      CALL METHOD document->new_line.
      CALL METHOD document->add_gap
        EXPORTING
          width = 19.

      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

    IF NOT ls_zfigiro-giro_3 IS INITIAL.
      ADD 1 TO g_html_height_top .
      MOVE  ls_zfigiro-giro_3 TO l_text.
*      TRANSLATE l_text TO LOWER CASE.
      CALL METHOD document->new_line.
      CALL METHOD document->add_gap
        EXPORTING
          width = 19.

      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

    IF NOT ls_zfigiro-giro_4 IS INITIAL.
      ADD 1 TO g_html_height_top .
      MOVE  ls_zfigiro-giro_4 TO l_text.
*      TRANSLATE l_text TO LOWER CASE.
      CALL METHOD document->new_line.
      CALL METHOD document->add_gap
        EXPORTING
          width = 19.

      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

    IF NOT ls_zfigiro-giro_5 IS INITIAL.
      ADD 1 TO g_html_height_top .
      MOVE  ls_zfigiro-giro_5 TO l_text.
*      TRANSLATE l_text TO LOWER CASE.
      CALL METHOD document->new_line.
      CALL METHOD document->add_gap
        EXPORTING
          width = 19.

      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

    IF NOT ls_zfigiro-giro_6 IS INITIAL.
      ADD 1 TO g_html_height_top .
      MOVE  ls_zfigiro-giro_6 TO l_text.
*      TRANSLATE l_text TO LOWER CASE.
      CALL METHOD document->new_line.
      CALL METHOD document->add_gap
        EXPORTING
          width = 19.

      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

  ENDLOOP.
***        RUT
  l_text = 'Rut'.
  CALL METHOD document->new_line.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.

  MOVE g_paval TO l_text.
  CALL METHOD document->add_gap
    EXPORTING
      width = 11.

  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_fontsize = l_font.

***      Direccion
  l_text = 'Dirección'.
  CALL METHOD document->new_line.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.
  CONCATENATE g_address_value-street g_address_value-city1 INTO l_text SEPARATED BY space.
  CALL METHOD document->add_gap
    EXPORTING
      width = 0.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_fontsize = l_font.

  CALL METHOD document->new_line.
  l_title = 'Libro Legal de Ventas'.
  CALL METHOD document->add_gap
    EXPORTING
      width = 150.
  CALL METHOD document->add_text
    EXPORTING
      text          = l_title
      sap_style     = 'HEADING'
*     sap_fontsize  = l_font.
      sap_fontstyle = 'C'
      sap_emphasis  = 'C'.
  CALL METHOD document->new_line.
  PERFORM get_month
              USING
                 s_monat-low
              CHANGING
                 l_month.
  CONCATENATE l_month p_gjahr
    INTO l_text SEPARATED BY space.

  CALL METHOD document->add_gap
    EXPORTING
      width = 170.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.
ENDFORM.                    "html_top_of_page
*&---------------------------------------------------------------------*
*&      Form  get_month
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MONAT    text
*      -->P_MONTH    text
*----------------------------------------------------------------------*
FORM get_month USING p_monat TYPE monat
               CHANGING p_month     TYPE fcltx.

  DATA: lt_month_names TYPE TABLE OF t247,
        ls_month_names TYPE  t247,
        l_subrc        TYPE sy-subrc.
  CALL FUNCTION 'MONTH_NAMES_GET'
    EXPORTING
      language              = sy-langu
    IMPORTING
      return_code           = l_subrc
    TABLES
      month_names           = lt_month_names
    EXCEPTIONS
      month_names_not_found = 1
      OTHERS                = 2.
  IF l_subrc EQ 0.
    READ TABLE lt_month_names
     INTO ls_month_names
     WITH KEY mnr = p_monat.
    IF sy-subrc EQ 0.
      MOVE ls_month_names-ltx TO p_month .
    ENDIF.
  ENDIF.

ENDFORM.                   "html_top_of_page
*&---------------------------------------------------------------------*
*&      Form  get_info_lfa1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PS_BSEG    text
*      -->PS_OUTTAB  text
*----------------------------------------------------------------------*
FORM get_info_kna1 USING ps_bseg TYPE bseg
                   CHANGING ps_outtab TYPE ty_s_outtab.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE name1 stcd1 brsch
*    FROM kna1
*    INTO (ps_outtab-name1, ps_outtab-stcd1, ps_outtab-brsch)
*    WHERE kunnr EQ ps_bseg-kunnr.
*
* NEW CODE
  SELECT name1 stcd1 brsch
  UP TO 1 ROWS 
    FROM kna1
    INTO (ps_outtab-name1, ps_outtab-stcd1, ps_outtab-brsch)
    WHERE kunnr EQ ps_bseg-kunnr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

*      SELECT SINGLE name1 stcd1
*    FROM lfa1
*    INTO (ps_outtab-name1, ps_outtab-stcd1)
*    WHERE lifnr EQ ps_bseg-lifnr.


ENDFORM.                    " get_info_lfa1

*&---------------------------------------------------------------------*
*&      Form  determine_tax
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PS_BSET    text
*      -->PS_OUTTAB  text
*----------------------------------------------------------------------*
FORM determine_tax USING ps_bset TYPE bset
                         ps_bkpf TYPE bkpf
                    CHANGING ps_outtab TYPE ty_s_outtab.
  DATA ls_cl_doc TYPE ty_s_cl_doc.
  CASE ps_bset-mwskz.
    WHEN 'D0'.

      MOVE abs( ps_bset-hwbas ) TO ps_outtab-taxbash2. "EXENTO
*      CASE PS_BKPF-BLART.
*        WHEN 'F6' OR 'F5'.
*          LS_CL_DOC-DESCRIPCION = TEXT-023.
*          LS_CL_DOC-MONTO       = PS_BSET-HWBAS.
*          LS_CL_DOC-MONEDA      = PS_BKPF-WAERS.
*          LS_CL_DOC-CANTIDAD    = 1.
*          LS_CL_DOC-ORDEN       = 3.
*          COLLECT LS_CL_DOC INTO GT_CL_DOC.
*      ENDCASE.
    WHEN 'D1' .
      CASE ps_bset-hkont.
        WHEN 2012310001.
          MOVE abs( ps_bset-hwbas ) TO ps_outtab-taxbash1. "AFECCTO
          MOVE abs( ps_bset-hwste ) TO ps_outtab-taxbash3. "IVA
      ENDCASE.

*      CASE PS_BKPF-BLART.
*        WHEN 'F3' OR 'F4' OR 'N3' OR 'N4' OR 'D3' OR 'D4'.
*          GS_IVA_DOC_E-MONTO_CDC = GS_IVA_DOC_E-MONTO_CDC + PS_BSET-HWSTE.
*
*        WHEN 'F6' OR 'F5'.
*          LS_CL_DOC-DESCRIPCION = TEXT-021.
*          LS_CL_DOC-MONTO       = PS_BSET-HWBAS.
*          LS_CL_DOC-MONEDA      = PS_BKPF-WAERS.
*          LS_CL_DOC-CANTIDAD    = 1.
*          LS_CL_DOC-ORDEN       = 1.
*          COLLECT LS_CL_DOC INTO GT_CL_DOC.
*        WHEN 'F1' OR 'F3'.
*          LS_CL_DOC-DESCRIPCION = TEXT-024.
*          LS_CL_DOC-MONTO       = PS_BSET-HWSTE.
*          LS_CL_DOC-MONEDA      = PS_BKPF-WAERS.
*          LS_CL_DOC-CANTIDAD    = 1.
*          LS_CL_DOC-ORDEN       = 4.
*          COLLECT LS_CL_DOC INTO GT_CL_DOC.
*
*        WHEN 'F2' OR 'F4'.
*          LS_CL_DOC-DESCRIPCION = TEXT-025.
*          LS_CL_DOC-MONTO       = PS_BSET-HWSTE.
*          LS_CL_DOC-MONEDA      = PS_BKPF-WAERS.
*          LS_CL_DOC-CANTIDAD    = 1.
*          LS_CL_DOC-ORDEN       = 5.
*          COLLECT LS_CL_DOC INTO GT_CL_DOC.
*
*        WHEN 'N1' OR 'N2' OR 'N3' OR 'N4'.
*          LS_CL_DOC-DESCRIPCION = TEXT-026.
*          LS_CL_DOC-MONTO       = PS_BSET-HWSTE.
*          LS_CL_DOC-MONEDA      = PS_BKPF-WAERS.
*          LS_CL_DOC-CANTIDAD    = 1.
*          LS_CL_DOC-ORDEN       = 6.
*          COLLECT LS_CL_DOC INTO GT_CL_DOC.
*
*        WHEN 'D1' OR 'D2' OR 'D3' OR 'D4'.
*          LS_CL_DOC-DESCRIPCION = TEXT-027.
*          LS_CL_DOC-MONTO       = PS_BSET-HWSTE.
*          LS_CL_DOC-MONEDA      = PS_BKPF-WAERS.
*          LS_CL_DOC-CANTIDAD    = 1.
*          LS_CL_DOC-ORDEN       = 7.
*          COLLECT LS_CL_DOC INTO GT_CL_DOC.
*
*        WHEN 'I1'.
*          LS_CL_DOC-DESCRIPCION = TEXT-028.
*          LS_CL_DOC-MONTO       = PS_BSET-HWSTE.
*          LS_CL_DOC-MONEDA      = PS_BKPF-WAERS.
*          LS_CL_DOC-CANTIDAD    = 1.
*          LS_CL_DOC-ORDEN       = 8.
*          COLLECT LS_CL_DOC INTO GT_CL_DOC.
*
*        WHEN 'I2'.
*          LS_CL_DOC-DESCRIPCION = TEXT-029.
*          LS_CL_DOC-MONTO       = PS_BSET-HWSTE.
*          LS_CL_DOC-MONEDA      = PS_BKPF-WAERS.
*          LS_CL_DOC-CANTIDAD    = 1.
*          LS_CL_DOC-ORDEN       = 9.
*          COLLECT LS_CL_DOC INTO GT_CL_DOC.
*      ENDCASE.
*
*
*    WHEN 'C4'.
*      MOVE PS_BSET-HWBAS TO PS_OUTTAB-TAXBASH4. "IVA NO RECUPERADO
*      CASE PS_BKPF-BLART.
*        WHEN 'F6'.
*          GS_IVA_DOC_E-MONTO_SDC = GS_IVA_DOC_E-MONTO_SDC + PS_BSET-HWBAS.
*        WHEN 'I3'.
*          LS_CL_DOC-DESCRIPCION = TEXT-022.
*          LS_CL_DOC-MONTO       = PS_BSET-HWBAS.
*          LS_CL_DOC-MONEDA      = PS_BKPF-WAERS.
*          LS_CL_DOC-CANTIDAD    = 1.
*          LS_CL_DOC-ORDEN       = 2.
*          COLLECT LS_CL_DOC INTO GT_CL_DOC.
*      ENDCASE.
*    WHEN 'C7'.
*      MOVE PS_BSET-HWBAS TO PS_OUTTAB-TAXBASH5. "OTROS IMPTOS.
*      CASE PS_BKPF-BLART.
*        WHEN 'F1' OR 'F3' OR 'I1' OR 'N1' OR 'N3' OR 'D1' OR 'D3'.
*          LS_CL_DOC-DESCRIPCION = TEXT-030.
*          LS_CL_DOC-MONTO       = PS_BSET-HWBAS.
*          LS_CL_DOC-MONEDA      = PS_BKPF-WAERS.
*          LS_CL_DOC-CANTIDAD    = 1.
*          LS_CL_DOC-ORDEN       = 10.
*          COLLECT LS_CL_DOC INTO GT_CL_DOC.
*      ENDCASE.
  ENDCASE.

  ps_outtab-sum_all = ps_outtab-taxbash1 + ps_outtab-taxbash2 +
                      ps_outtab-taxbash3 + ps_outtab-taxbash4 +
                      ps_outtab-taxbash5.
ENDFORM.                    " DETERMINE_TAX

*&---------------------------------------------------------------------*
*&      Form  layout_init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RS_LAYOUT  text
*----------------------------------------------------------------------*
FORM layout_init USING rs_layout TYPE slis_layout_alv.

*  rs_layout-detail_popup      = 'X'.
  rs_layout-zebra = 'X'.
ENDFORM.                    "layout_init
*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE sy-ucomm
                      rs_selfield TYPE slis_selfield.       "#EC *
  DATA ls_outtab TYPE ty_s_outtab.

  CASE r_ucomm.
    WHEN '&F05'.
      SET SCREEN 0.
      LEAVE SCREEN.

    WHEN 'LINE'.
      CALL SCREEN 0100
        STARTING AT 20 1.
    WHEN 'DOWN'.

      PERFORM fill_file
                  USING
                     gt_outtab
                  CHANGING
                     gt_download.
      PERFORM fill_total
                  USING
                     gt_cl_doc
                  CHANGING
                     gt_download.


      PERFORM download_txt
                  USING
                     gt_download.

*
    WHEN '&IC1'.
      READ TABLE gt_outtab
        INTO ls_outtab
        INDEX rs_selfield-tabindex .
      CASE rs_selfield-fieldname.
        WHEN 'BELNR'.
          CHECK   rs_selfield-value IS NOT INITIAL.
          SET PARAMETER ID: 'BLN' FIELD ls_outtab-belnr,
                            'BUK' FIELD ls_outtab-bukrs,
                            'GJR' FIELD ls_outtab-gjahr.

          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDCASE.
  ENDCASE.
ENDFORM.                    "user_comma
*&---------------------------------------------------------------------*
*&      Form  set_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*----------------------------------------------------------------------*
FORM set_status  USING rt_extab TYPE slis_t_extab .         "#EC *
  SET PF-STATUS 'STATUS' EXCLUDING rt_extab.
ENDFORM.                    "set_statusnd
*&---------------------------------------------------------------------*
*&      Form  download_txt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LT_DOWNLOAD  text
*----------------------------------------------------------------------*
FORM download_txt USING lt_download TYPE ty_t_download.

  DATA: l_path TYPE string.


  CONCATENATE p_path '/libro_Ventas_' p_bukrs
              '_' sy-datum '_'
              sy-uzeit '.TXT' INTO l_path.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
*     WRITE_FIELD_SEPARATOR   = '  '
      filename                = l_path
      filetype                = 'ASC'
    TABLES
      data_tab                = lt_download
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.
  IF sy-subrc NE 0.
    MESSAGE 'Error al descargar  archivo.' TYPE 'S'.
  ELSE.
*    MOVE l_path TO p_path.
  ENDIF.


ENDFORM.                    "download_
*&---------------------------------------------------------------------*
*&      Form  value_request_path_down
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PATH     text
*----------------------------------------------------------------------*
FORM value_request_path_down  CHANGING p_path.

  DATA: l_path TYPE string.

  MOVE p_path TO l_path.

  CALL METHOD cl_gui_frontend_services=>directory_browse
    CHANGING
      selected_folder      = l_path
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

  MOVE l_path TO p_path.

ENDFORM.                    "value_request_path_down
*&---------------------------------------------------------------------*
*&      Form  fill_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->T_DOWNLOAD text
*----------------------------------------------------------------------*
FORM fill_header  CHANGING t_download TYPE ty_t_download.
  DATA: ls_download TYPE ty_s_download,
        l_date      TYPE char20,
        l_month     TYPE fcltx.
  PERFORM get_month
              USING
                 s_monat-low
              CHANGING
                 l_month.

  ls_download-data = space.
  APPEND ls_download TO t_download .CLEAR ls_download.
  ls_download-data = space.
  APPEND ls_download TO t_download .CLEAR ls_download.
  ls_download-data = space.
  APPEND ls_download TO t_download .CLEAR ls_download.
  ls_download-data = space.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data+3(20) = g_butxt.
  ls_download-data+80(25) = 'Libro Legal de Ventas'.
  APPEND ls_download TO t_download .CLEAR ls_download.

  CONCATENATE l_month p_gjahr
    INTO ls_download-data+84(20) SEPARATED BY space.
  APPEND ls_download TO t_download .
  CLEAR ls_download.
  ls_download-data = space.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data = c_line.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data+2(10)   = 'Clase Doc'.
  ls_download-data+15(10)  = 'Fec. Doc.'.
  ls_download-data+30(10)  = 'Nro. Doc.'.
  ls_download-data+50(15)  = 'Nro. Fact.'.
  ls_download-data+70(11)  = 'R.U.T'.
  ls_download-data+85(30)  = 'Nombre'.
  ls_download-data+125(11)  = 'Ramo'.
  ls_download-data+148(15)  = 'Exento'.
  ls_download-data+163(15) = 'Afecto'.
  ls_download-data+181(12)  = 'IVA'.
  ls_download-data+188(15) = 'Valor Total'.
*  ls_download-data+151(11) = 'Otros Imptos'.
*  ls_download-data+165(11) = 'Valor Total'.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data = c_line.
  APPEND ls_download TO t_download .CLEAR ls_download.
ENDFORM.                    "fill_header
*&---------------------------------------------------------------------*
*&      Form  fill_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->T_OUTTAB   text
*      -->T_DOWNLOAD text
*----------------------------------------------------------------------*
FORM fill_file USING t_outtab       TYPE  ty_t_outtab
               CHANGING t_download TYPE ty_t_download.
  DATA: ls_outtab     TYPE ty_s_outtab,
        ls_outtab_tot TYPE ty_s_outtab,
        ls_download   TYPE ty_s_download,
        l_saldo       TYPE dmbtr,
        l_blart       TYPE blart,
        l_num         TYPE i,
        l_mod         TYPE i.
  CLEAR: g_num.
  REFRESH t_download.
  PERFORM fill_header
              CHANGING
                 gt_download.

  LOOP AT t_outtab  INTO ls_outtab .

    ADD 1 TO g_num.
    IF g_num EQ 1.
***      Imprimir encabezado clase Doc.
      MOVE ls_outtab-blart TO l_blart.

      PERFORM get_blart_description
            USING
               l_blart
            CHANGING
               ls_download-data+2(38).
      APPEND ls_download TO t_download .CLEAR ls_download.
      ls_download-data = c_line.
      APPEND ls_download TO t_download .CLEAR ls_download.
      ADD 2 TO g_num.
    ENDIF.
***
***    Imprimir totales por clase de Doc.
    IF ls_outtab-blart NE l_blart .
      ls_download-data = c_line.
      APPEND ls_download TO t_download .CLEAR ls_download.

      ls_download-data+42(10) = 'Total'.
      PERFORM get_blart_description
                  USING
                     l_blart
                  CHANGING
                     ls_download-data+50(38).


      WRITE ls_outtab_tot-taxbash2 TO ls_download-data+140(15)  CURRENCY ls_outtab-waers.
      WRITE ls_outtab_tot-taxbash1 TO ls_download-data+155(15) CURRENCY ls_outtab-waers.
      WRITE ls_outtab_tot-taxbash3 TO ls_download-data+170(15) CURRENCY ls_outtab-waers.
*      WRITE ls_outtab_tot-taxbash4 TO ls_download-data+136(12) CURRENCY ls_outtab-waers.
*      WRITE ls_outtab_tot-taxbash5 TO ls_download-data+150(12) CURRENCY ls_outtab-waers.
      WRITE ls_outtab_tot-sum_all  TO ls_download-data+185(15) CURRENCY ls_outtab-waers.

      CLEAR ls_outtab_tot.
      APPEND ls_download TO t_download .
      CLEAR ls_download.
      ls_download-data = c_line.
      APPEND ls_download TO t_download .CLEAR ls_download.
      MOVE ls_outtab-blart TO l_blart.


      PERFORM get_blart_description
                            USING
                               l_blart
                            CHANGING
       ls_download-data+2(38).
      APPEND ls_download TO t_download .CLEAR ls_download.
      ls_download-data = c_line.
      APPEND ls_download TO t_download .CLEAR ls_download.
      ADD 4 TO g_num.
    ENDIF.
***
***    Imprimir Linea
    MOVE l_blart TO ls_download-data+2(10).
    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        date_internal            = ls_outtab-bldat
      IMPORTING
        date_external            = ls_download-data+15(10)
      EXCEPTIONS
        date_internal_is_invalid = 1
        OTHERS                   = 2.

*    ls_download-data+14(10)  = ls_outtab-xblnr.
*    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
*      EXPORTING
*        date_internal            = ls_outtab-budat
*      IMPORTING
*        date_external            = ls_download-data+26(10)
*      EXCEPTIONS
*        date_internal_is_invalid = 1
*        OTHERS                   = 2.


    ls_download-data+30(10)   = ls_outtab-belnr.
    ls_download-data+50(15)   = ls_outtab-xblnr.
    ls_download-data+70(11)   = ls_outtab-stcd1.
    ls_download-data+85(30)   = ls_outtab-name1.


    WRITE ls_outtab-brsch TO ls_download-data+125(12).
    WRITE ls_outtab-taxbash2 TO ls_download-data+140(15)  CURRENCY ls_outtab-waers.
    WRITE ls_outtab-taxbash1 TO ls_download-data+155(15) CURRENCY ls_outtab-waers.
    WRITE ls_outtab-taxbash3 TO ls_download-data+170(15) CURRENCY ls_outtab-waers.
*    WRITE ls_outtab-taxbash4 TO ls_download-data+136(12) CURRENCY ls_outtab-waers.
*    WRITE ls_outtab-taxbash5 TO ls_download-data+150(12) CURRENCY ls_outtab-waers.
    WRITE ls_outtab-sum_all  TO ls_download-data+185(15) CURRENCY ls_outtab-waers.
    APPEND ls_download TO t_download .
    CLEAR ls_download.
    ls_outtab_tot-taxbash1 =  ls_outtab_tot-taxbash1 + ls_outtab-taxbash1.
    ls_outtab_tot-taxbash2 =  ls_outtab_tot-taxbash2 + ls_outtab-taxbash2.
    ls_outtab_tot-taxbash3 =  ls_outtab_tot-taxbash3 + ls_outtab-taxbash3.
    ls_outtab_tot-taxbash4 =  ls_outtab_tot-taxbash4 + ls_outtab-taxbash4.
    ls_outtab_tot-taxbash5 =  ls_outtab_tot-taxbash5 + ls_outtab-taxbash5.
    ls_outtab_tot-sum_all  =  ls_outtab_tot-sum_all  + ls_outtab-sum_all.
***
    l_mod =  g_num MOD g_line.
*    AT LAST.
*      l_mod =  g_num MOD g_line.
*    ENDAT.
***   cada g_num Lines imprime pie y encabezado
    IF l_mod EQ 0.

      PERFORM fill_foot
                  CHANGING
                     gt_download.

      PERFORM fill_header
                  CHANGING
                     gt_download.

    ENDIF.

  ENDLOOP.

  IF ls_outtab_tot IS NOT INITIAL.
    ls_download-data = c_line.
    APPEND ls_download TO t_download .CLEAR ls_download.

    ls_download-data+42(10) = 'Total'.
    PERFORM get_blart_description
                USING
                   l_blart
                CHANGING
                   ls_download-data+50(38).

*       LS_DOWNLOAD-DATA+125(11)  = 'Ramo'.
*  LS_DOWNLOAD-DATA+140(11)  = 'Exento'.
*  LS_DOWNLOAD-DATA+155(11) = 'Afecto'.
*  LS_DOWNLOAD-DATA+170(9)  = 'IVA'.
*  LS_DOWNLOAD-DATA+185(11) = 'Valor Total'.


    WRITE ls_outtab_tot-taxbash2 TO ls_download-data+140(15)  CURRENCY ls_outtab-waers.
    WRITE ls_outtab_tot-taxbash1 TO ls_download-data+155(15) CURRENCY ls_outtab-waers.
    WRITE ls_outtab_tot-taxbash3 TO ls_download-data+170(15) CURRENCY ls_outtab-waers.
*    WRITE ls_outtab_tot-taxbash4 TO ls_download-data+136(12) CURRENCY ls_outtab-waers.
*    WRITE ls_outtab_tot-taxbash5 TO ls_download-data+150(12) CURRENCY ls_outtab-waers.
    WRITE ls_outtab_tot-sum_all  TO ls_download-data+185(15) CURRENCY ls_outtab-waers.
    CLEAR ls_outtab_tot.
    APPEND ls_download TO t_download .
    CLEAR ls_download.
    ls_download-data = c_line.
    APPEND ls_download TO t_download .CLEAR ls_download.
  ENDIF.
ENDFORM.                    "fill_file
*&---------------------------------------------------------------------*
*&      Form  fill_foot
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->T_DOWNLOAD text
*----------------------------------------------------------------------*
FORM fill_foot  CHANGING t_download TYPE ty_t_download.
  DATA: ls_download TYPE ty_s_download.

  ls_download-data = space.
  APPEND ls_download TO t_download .
  ls_download-data = space.
  APPEND ls_download TO t_download .


ENDFORM.                    "fill_foot
*&---------------------------------------------------------------------*
*&      Form  get_description_bukrs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BUKRS    text
*      -->P_BUTXT    text
*----------------------------------------------------------------------*
FORM get_description_bukrs USING p_bukrs TYPE bukrs
                           CHANGING p_butxt TYPE butxt.
  DATA : l_adrnr             TYPE adrnr,
         l_address_selection TYPE addr1_sel,
         l_zgiro             TYPE zfigiro.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE butxt adrnr
*    FROM t001
*    INTO (p_butxt, l_adrnr)
*    WHERE bukrs EQ p_bukrs
*    AND spras EQ sy-langu.
*
* NEW CODE
  SELECT butxt adrnr
  UP TO 1 ROWS 
    FROM t001
    INTO (p_butxt, l_adrnr)
    WHERE bukrs EQ p_bukrs
    AND spras EQ sy-langu ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  MOVE l_adrnr TO  l_address_selection-addrnumber.

  CALL FUNCTION 'ADDR_GET'
    EXPORTING
      address_selection = l_address_selection
    IMPORTING
      address_value     = g_address_value
    EXCEPTIONS
      parameter_error   = 1
      address_not_exist = 2
      version_not_exist = 3
      internal_error    = 4
      OTHERS            = 5.

*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE paval
*    FROM t001z
*    INTO g_paval
*    WHERE bukrs EQ p_bukrs
*    AND party EQ 'TAXNR' .
*
* NEW CODE
  SELECT paval
  UP TO 1 ROWS 
    FROM t001z
    INTO g_paval
    WHERE bukrs EQ p_bukrs
    AND party EQ 'TAXNR'  ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM zfigiro
*    INTO TABLE gt_zfigiro
*    WHERE bukrs = p_bukrs.
*
* NEW CODE
  SELECT *
 FROM zfigiro
    INTO TABLE gt_zfigiro
    WHERE bukrs = p_bukrs ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  IF sy-subrc EQ 0.
    READ TABLE gt_zfigiro INTO l_zgiro INDEX 1.
    IF sy-subrc EQ 0.
      IF l_zgiro-giro_1 IS NOT INITIAL.
        ADD 1 TO g_html_height_top.
      ENDIF.
      IF l_zgiro-giro_2 IS NOT INITIAL.
        ADD 1 TO g_html_height_top.
      ENDIF.
      IF l_zgiro-giro_3 IS NOT INITIAL.
        ADD 1 TO g_html_height_top.
      ENDIF.
      IF l_zgiro-giro_4 IS NOT INITIAL.
        ADD 1 TO g_html_height_top.
      ENDIF.
      IF l_zgiro-giro_5 IS NOT INITIAL.
        ADD 1 TO g_html_height_top.
      ENDIF.
      IF l_zgiro-giro_6 IS NOT INITIAL.
        ADD 1 TO g_html_height_top.
      ENDIF.
      IF l_zgiro-giro_7 IS NOT INITIAL.
        ADD 1 TO g_html_height_top.
      ENDIF.

    ENDIF.
  ENDIF.
ENDFORM.                    "get_description_bu
*&---------------------------------------------------------------------*
*&      Form  fill_total
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->T_CL_DOC   text
*      -->T_DOWNLOAD text
*----------------------------------------------------------------------*
FORM fill_total USING t_cl_doc TYPE ty_t_cl_doc
                CHANGING t_download TYPE ty_t_download.
  DATA: ls_download TYPE ty_s_download,
        ls_cl_doc   TYPE ty_s_cl_doc.

  ls_download-data = space.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data = space.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data = space.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data+40(35)   = 'Resumen Libro Legal de ventas'.
  APPEND ls_download TO t_download .CLEAR ls_download.

  CLEAR ls_download.
  ls_download-data = c_line_2.
  APPEND ls_download TO t_download .CLEAR ls_download.
* resumen
* Clase documento  doc. Vigentes  Doc. Nulos  Exento  Afecto  Iva  Total

  ls_download-data+2(20)   = 'Clase de Doc'.
  ls_download-data+30(10)  = 'Doc. Vig'.
  ls_download-data+45(10)  = 'Doc. Nul'.
  ls_download-data+65(11)  = 'Exento'.
  ls_download-data+80(11) = 'Afecto'.
  ls_download-data+100(9)  = 'IVA'.
  ls_download-data+110(11) = 'Valor Total'.
  APPEND ls_download TO t_download .CLEAR ls_download.
  CLEAR ls_download.
  ls_download-data = c_line_2.
  APPEND ls_download TO t_download .CLEAR ls_download.

  PERFORM genera_resumen_libro.
  PERFORM gresumen CHANGING t_download.

ENDFORM.                    "fill_total
*&---------------------------------------------------------------------*
*&      Form  get_blart_description
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_blart_description  USING p_blart TYPE blart
      CHANGING p_ltext TYPE char38.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT  SINGLE ltext FROM t003t
*    INTO p_ltext
*    WHERE spras EQ sy-langu
*    AND blart EQ p_blart..
*
* NEW CODE
  SELECT ltext
  UP TO 1 ROWS  FROM t003t
    INTO p_ltext
    WHERE spras EQ sy-langu
    AND blart EQ p_blart ORDER BY PRIMARY KEY..

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
ENDFORM.                    " get_blart_description
*&---------------------------------------------------------------------*
*&      Form  init_global_values.
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_global_values .
  DATA: ls_cl_doc   TYPE ty_s_cl_doc,
        ls_download TYPE ty_s_download.
  opt-dynnr = '1001'.
  opt-activetab = 'USER1'.
  tab1 = TEXT-200.
  tab2 = TEXT-210.
  tab3 = TEXT-220.
  g_repid = sy-repid.
  gs_iva_doc_e-descripcion = TEXT-020.

  ls_cl_doc-descripcion = TEXT-021.
  ls_cl_doc-moneda     = 'CLP'.
  ls_cl_doc-orden      = 1.
  APPEND ls_cl_doc  TO gt_cl_doc.CLEAR ls_cl_doc.

  ls_cl_doc-descripcion = TEXT-022.
  ls_cl_doc-moneda     = 'CLP'.
  ls_cl_doc-orden      = 2.
  APPEND ls_cl_doc  TO gt_cl_doc.CLEAR ls_cl_doc.
  ls_cl_doc-descripcion = TEXT-023.
  ls_cl_doc-moneda     = 'CLP'.
  ls_cl_doc-orden      = 3.
  APPEND ls_cl_doc  TO gt_cl_doc.CLEAR ls_cl_doc.

  ls_cl_doc-descripcion = TEXT-024.
  ls_cl_doc-moneda     = 'CLP'.
  ls_cl_doc-orden      = 4.
  APPEND ls_cl_doc  TO gt_cl_doc.CLEAR ls_cl_doc.

  ls_cl_doc-descripcion = TEXT-025.
  ls_cl_doc-moneda     = 'CLP'.
  ls_cl_doc-orden      = 5.
  APPEND ls_cl_doc  TO gt_cl_doc.CLEAR ls_cl_doc.

  ls_cl_doc-descripcion = TEXT-026.
  ls_cl_doc-moneda     = 'CLP'.
  ls_cl_doc-orden      = 6.
  APPEND ls_cl_doc  TO gt_cl_doc.CLEAR ls_cl_doc.

  ls_cl_doc-descripcion = TEXT-027.
  ls_cl_doc-moneda     = 'CLP'.
  ls_cl_doc-orden      = 7.
  APPEND ls_cl_doc  TO gt_cl_doc.CLEAR ls_cl_doc.

  ls_cl_doc-descripcion = TEXT-028.
  ls_cl_doc-moneda     = 'CLP'.
  ls_cl_doc-orden      = 8.
  APPEND ls_cl_doc  TO gt_cl_doc.CLEAR ls_cl_doc.

  ls_cl_doc-descripcion = TEXT-029.
  ls_cl_doc-moneda     = 'CLP'.
  ls_cl_doc-orden      = 9.
  APPEND ls_cl_doc  TO gt_cl_doc.CLEAR ls_cl_doc.

  ls_cl_doc-descripcion = TEXT-030.
  ls_cl_doc-moneda     = 'CLP'.
  ls_cl_doc-orden      = 10.
  APPEND ls_cl_doc  TO gt_cl_doc.CLEAR ls_cl_doc.
  PERFORM init_blart.
ENDFORM.                    " init_global_values.
*&---------------------------------------------------------------------*
*&      Form  GENERA_RESUMEN_LIBRO
*&---------------------------------------------------------------------*
*       Genera tabla (tresumen) con el resumen
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM genera_resumen_libro .

  DATA: l_prim     TYPE i.

  DATA : l_blart TYPE blart.
  DATA: ls_outtab TYPE ty_s_outtab.


*TI_RESUMEN
  CLEAR l_blart.
  CLEAR l_prim.
  LOOP AT gt_outtab  INTO ls_outtab .
    IF l_prim = 0.
      l_prim = 1.
      MOVE ls_outtab-blart TO l_blart.
      PERFORM get_blart_description
                USING
                   l_blart
                CHANGING
                   desbl.
      IF ls_outtab-belnr IS INITIAL.
*        NULOS
        t_cnulo    = t_cnulo + 1.
      ELSE.
*       VIGENTES
        t_cvige    = t_cvige + 1.
      ENDIF.


      t_taxbash1 = t_taxbash1 + ls_outtab-taxbash1. " AFECTO
      t_taxbash2 = t_taxbash2 + ls_outtab-taxbash2. " EXENTO
      t_taxbash3 = t_taxbash3 + ls_outtab-taxbash3 . " IVA
      t_sum_all  = t_taxbash1 + t_taxbash2 + t_taxbash3.  " TOTAL

    ELSE. "
      IF ls_outtab-blart EQ l_blart. " SUMA
        PERFORM get_blart_description USING l_blart CHANGING desbl.
        IF ls_outtab-belnr IS INITIAL.
*        NULOS
          t_cnulo    = t_cnulo + 1.
        ELSE.
*        VIGENTES
          t_cvige    = t_cvige + 1.
        ENDIF.
        t_taxbash1 = t_taxbash1 + ls_outtab-taxbash1. " AFECTO
        t_taxbash2 = t_taxbash2 + ls_outtab-taxbash2. " EXENTO
        t_taxbash3 = t_taxbash3 + ls_outtab-taxbash3 . " IVA
        t_sum_all  = ( t_taxbash1 + t_taxbash2 + t_taxbash3 ).  " TOTAL

      ELSE. " TOTALES
        MOVE l_blart TO ti_resumen-blart.
        MOVE desbl   TO ti_resumen-desbl.
        MOVE t_cvige TO ti_resumen-cvige.
        MOVE t_cnulo TO ti_resumen-cnulo.
        MOVE t_taxbash1 TO ti_resumen-taxbash1.
        MOVE t_taxbash2 TO ti_resumen-taxbash2.
        MOVE t_taxbash3 TO ti_resumen-taxbash3.
        MOVE t_sum_all  TO ti_resumen-sum_all.
        APPEND ti_resumen.
        PERFORM clean_v.
        PERFORM get_blart_description USING l_blart CHANGING desbl.
        IF ls_outtab-belnr IS INITIAL.
*        NULOS
          t_cnulo    = t_cnulo + 1.
        ELSE.
*        VIGENTES
          t_cvige    = t_cvige + 1.
        ENDIF.
        t_taxbash1 = t_taxbash1 + ls_outtab-taxbash1. " AFECTO
        t_taxbash2 = t_taxbash2 + ls_outtab-taxbash2. " EXENTO
        t_taxbash3 = t_taxbash3 + ls_outtab-taxbash3 . " IVA
        t_sum_all  = ( t_taxbash1 + t_taxbash2 + t_taxbash3 ).  " TOTAL
      ENDIF.
    ENDIF.
    MOVE ls_outtab-blart TO l_blart.
  ENDLOOP.

  PERFORM get_blart_description USING l_blart CHANGING desbl.
  MOVE l_blart TO ti_resumen-blart.
  MOVE desbl   TO ti_resumen-desbl.
  MOVE t_cvige TO ti_resumen-cvige.
  MOVE t_cnulo TO ti_resumen-cnulo.
  MOVE t_taxbash1 TO ti_resumen-taxbash1.
  MOVE t_taxbash2 TO ti_resumen-taxbash2.
  MOVE t_taxbash3 TO ti_resumen-taxbash3.
  MOVE t_sum_all  TO ti_resumen-sum_all.
  APPEND ti_resumen.



ENDFORM.                    " GENERA_RESUMEN_LIBRO
*&---------------------------------------------------------------------*
*&      Form  CLEAN_V
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clean_v .

  CLEAR t_cvige.
  CLEAR t_cnulo.
  CLEAR t_taxbash1.
  CLEAR t_taxbash2.
  CLEAR t_taxbash3.
  CLEAR t_sum_all.

ENDFORM.                    " CLEAN_V
*&---------------------------------------------------------------------*
*&      Form  GRESUMEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM gresumen CHANGING t_download TYPE ty_t_download.
  DATA: ls_download TYPE ty_s_download.

  DATA :t_cvige    LIKE ti_resumen-cvige,
        t_cnulo    LIKE ti_resumen-cnulo,
        t_taxbash2 LIKE ti_resumen-taxbash2,
        t_taxbash1 LIKE ti_resumen-taxbash1,
        t_taxbash3 LIKE ti_resumen-taxbash3,
        t_sum_all  LIKE ti_resumen-sum_all.

* ls_download-data = c_line_2.
*    APPEND ls_download TO t_download .CLEAR ls_download.

  LOOP AT ti_resumen.
    ls_download-data+2(20)   = ti_resumen-desbl.
    ls_download-data+29(10)  = ti_resumen-cvige.
    ls_download-data+44(10)  = ti_resumen-cnulo.
    WRITE ti_resumen-taxbash2 TO ls_download-data+61(11) CURRENCY 'CLP'.
    WRITE ti_resumen-taxbash1 TO ls_download-data+76(11) CURRENCY 'CLP'.
    WRITE ti_resumen-taxbash3 TO ls_download-data+96(9)  CURRENCY 'CLP' .
    WRITE ti_resumen-sum_all TO  ls_download-data+111(11)  CURRENCY 'CLP' .

    t_cvige    = t_cvige + ti_resumen-cvige.
    t_cnulo    = t_cnulo + ti_resumen-cnulo.
    t_taxbash2 = t_taxbash2 + ti_resumen-taxbash2.
    t_taxbash1 = t_taxbash1 + ti_resumen-taxbash1.
    t_taxbash3 = t_taxbash3 + ti_resumen-taxbash3.
    t_sum_all  = t_sum_all  + ti_resumen-sum_all.

    APPEND ls_download TO t_download .CLEAR ls_download.
    CLEAR ls_download.
    ls_download-data = c_line_2.
    APPEND ls_download TO t_download .CLEAR ls_download.

  ENDLOOP.

* Total

  ls_download-data+29(10)  = t_cvige.
  ls_download-data+44(10)  = t_cnulo.
  WRITE t_taxbash2 TO ls_download-data+61(11) CURRENCY 'CLP'  .
  WRITE t_taxbash1 TO ls_download-data+76(11) CURRENCY 'CLP' .
  WRITE t_taxbash3 TO ls_download-data+96(9) CURRENCY 'CLP' .
  WRITE  t_sum_all TO ls_download-data+111(11) CURRENCY 'CLP' .
  APPEND ls_download TO t_download .CLEAR ls_download.
  CLEAR ls_download.
  ls_download-data = c_line_2.
  APPEND ls_download TO t_download .CLEAR ls_download.


ENDFORM.                    " GRESUMEN
