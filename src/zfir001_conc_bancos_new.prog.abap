*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
REPORT  zfir001_conc_bancos_new
  NO STANDARD PAGE HEADING
    MESSAGE-ID zfi.
TABLES: payr, regup, t012k.
INCLUDE zfir001_conc_bancos_top.


*********** PARAMETROS ************************************************
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE text-001.
PARAMETERS:     p_bukrs LIKE t001-bukrs OBLIGATORY.    "Sociedad
SELECT-OPTIONS: s_hbkid FOR  t012-hbkid NO INTERVALS,  "Bco.Propio
                s_saknr FOR  skb1-saknr NO INTERVALS,  "Cta.Contable
                s_blart FOR  bsis-blart NO INTERVALS
                             DEFAULT 'ZR' NO-DISPLAY.  "Tipo Documto
PARAMETERS:
                p_budat LIKE sy-datum OBLIGATORY,      "Fecha
                p_pcta  LIKE skat-ktopl      DEFAULT 'B100' NO-DISPLAY,
                p_ledge TYPE faglflext-rldnr DEFAULT '0L'   NO-DISPLAY,
                p_motivo   AS CHECKBOX DEFAULT '',
                p_agenci   AS CHECKBOX DEFAULT ''.
SELECTION-SCREEN END OF BLOCK blk1.

PARAMETERS:
          s_vari LIKE disvariant-variant MEMORY ID pid,
          p_alv  AS CHECKBOX DEFAULT 'X'.


*********** AUTORIZACIONES ************************************************
AT SELECTION-SCREEN ON p_bukrs.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
           ID 'BUKRS' FIELD p_bukrs.
  IF sy-subrc NE 0.
    MESSAGE e004(zfi) WITH 'Sin autorización para Sociedad.' p_bukrs.
  ENDIF.

* ------------------------------------------------------ ALV variants
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_vari.

  PERFORM for_variant.
  PERFORM pai_of_selection_screen.


*********** INICIALIZACION ************************************************
INITIALIZATION.
  MOVE  sy-datum TO p_budat.
  PERFORM alv_initialization.

***********   PROCESO     ************************************************
START-OF-SELECTION.

  PERFORM select_param.
  PERFORM select_items_abiertos.

* Asigno las Descripciones de Cuentas a Caratula

*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES02 ECDK917080 *
SORT IT_CARATULA .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES02 ECDK917080 *
  LOOP AT it_caratula.
    wa_tabix = sy-tabix.
    SELECT SINGLE txt50 INTO it_caratula-txt50 FROM skat
        WHERE ktopl = p_pcta
          AND saknr = it_caratula-hkont
          AND spras = sy-langu.
    MODIFY it_caratula INDEX wa_tabix.
  ENDLOOP.


END-OF-SELECTION.


  SORT it_caratula BY  bukrs hkont .
  PERFORM lista_alv.

*&---------------------------------------------------------------------*
*&  Include           ZFIR001_CONC_BANCOS_INCLUDE
*&---------------------------------------------------------------------*
***
FORM select_items_abiertos .
  DATA:  fecha LIKE bsis-budat.

  REFRESH: it_bsis,
           it_bkpf, it_bseg, it_febko, it_febep.

  CLEAR:   it_bsis,
           it_bkpf, it_bseg, it_febko, it_febep.

  fecha = p_budat.
  fecha+6(2) = '01'.

  SELECT * FROM bsis  INTO TABLE it_bsis
           WHERE bukrs EQ p_bukrs
           AND   hkont IN s_saknr
           AND   budat LE p_budat.

  SELECT * FROM bsas APPENDING CORRESPONDING FIELDS OF TABLE it_bsis
             WHERE bukrs = p_bukrs
             AND   hkont IN s_saknr
             AND   augdt > p_budat
             AND   budat =< p_budat.

  wa_fec_proceso = p_budat.
  SORT it_bsis     BY bukrs gjahr belnr buzei.
  SORT it_skb1     BY bukrs saknr.
*
  LOOP AT it_bsis.
    SELECT SINGLE * FROM  bkpf
              WHERE bukrs  EQ it_bsis-bukrs
              AND   belnr  EQ it_bsis-belnr
              AND   gjahr  EQ it_bsis-gjahr.

    IF sy-subrc = 0.
      it_bsis-bktxt    = bkpf-bktxt.     "Texto Cabecera
      it_bsis-awkey    = bkpf-awkey.     "Clave Referencia
      it_bsis-usnam    = bkpf-usnam.     "Usuario
      it_bsis-stblg    = bkpf-stblg.     "N° Doc. Anulacion
      it_bsis-stjah    = bkpf-stjah.     "Ejercicio Doc. Anulacion
      it_bsis-stgrd    = bkpf-stgrd.     "Motivo Anulacion
      it_bsis-xref1_hd = bkpf-xref1_hd.  "Clave Ref Cab 1
      it_bsis-xref2_hd = bkpf-xref2_hd.  "Clave Ref Cab 2
    ENDIF.

    READ TABLE it_skb1 WITH KEY bukrs = bkpf-bukrs
                                         saknr = it_bsis-hkont
                                         BINARY SEARCH.
    IF sy-subrc = 0.
      it_bsis-hbkid = it_skb1-hbkid.  "Banco Propio
    ENDIF.

    IF bkpf-blart = 'ZP'.

      SELECT SINGLE * FROM  payr
                WHERE zbukr  EQ it_bsis-bukrs
                AND   vblnr  EQ it_bsis-belnr
                AND   gjahr  EQ it_bsis-gjahr.
    ELSE.
      chect_aux = it_bsis-zuonr.
      SELECT SINGLE * FROM t012k WHERE bukrs = it_bsis-bukrs
                                 AND   hbkid = it_bsis-hbkid.

      SELECT SINGLE * FROM  payr
           WHERE zbukr  EQ it_bsis-bukrs
           AND   hbkid  EQ it_bsis-hbkid
           AND   hktid  EQ t012k-hktid
  "         AND   rzawe  EQ 'C'
           AND   chect  EQ chect_aux.
    ENDIF.

    IF sy-subrc = 0.
      SELECT SINGLE stcd1 name1 INTO (it_bsis-stcd1, it_bsis-name1) FROM lfa1
                     WHERE lifnr  EQ payr-lifnr.

      it_bsis-chect = payr-chect.
      IF p_motivo  = 'X'.

*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *
        SELECT SINGLE  * FROM  regup WHERE laufd = payr-laufd
                                 AND   laufi = payr-laufi
                                 AND   xvorl = ''
                                 AND   zbukr = payr-zbukr
                                 AND   lifnr = payr-lifnr
                                 AND   kunnr = payr-kunnr
                                 AND   empfg = payr-empfg
                                 AND   vblnr = payr-vblnr.
        IF sy-subrc = 0.
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *
          SELECT SINGLE  * FROM  bseg WHERE bukrs  = regup-bukrs
                                     AND  belnr = regup-belnr
                                     AND  gjahr = regup-gjahr
                                     AND  buzei = regup-buzei.
          IF sy-subrc = 0.
            it_bsis-zzmot_emis = bseg-zzmot_emis.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF p_agenci  = 'X'.
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *
      SELECT SINGLE  * FROM  bseg WHERE bukrs  = it_bsis-bukrs
                                         AND  belnr = it_bsis-belnr
                                         AND  gjahr = it_bsis-gjahr
                                         AND  buzei = it_bsis-buzei.
      IF sy-subrc = 0.
        it_bsis-zz_agencia = bseg-zz_agencia.
      ENDIF.
    ENDIF.



    IF it_bsis-blart IN s_blart.
      it_bsis-sistema = 'SAP_BANCO'.
      it_bsis-usuario = it_bsis-usnam.
      it_bsis-movto   = 'B'.
    ELSE.
      it_bsis-sistema = 'SAP_CONTABILIDAD'.
      it_bsis-usuario = it_bsis-usnam.
      it_bsis-movto   = 'C'.
    ENDIF.

    it_bsis-estado   = 'A'.

    MODIFY it_bsis.
  ENDLOOP.

  SORT it_bsis       BY bukrs hkont gjahr belnr buzei.
  SORT it_caratula   BY bukrs hkont.

  LOOP AT it_bsis.

    IF it_bsis-shkzg = 'H'.
      it_bsis-wrbtr = it_bsis-wrbtr * -1.
    ENDIF.

    READ TABLE it_caratula WITH KEY bukrs = it_bsis-bukrs
                                    hkont = it_bsis-hkont.
    IF sy-subrc <> 0.
      CLEAR it_caratula.
      it_caratula-bukrs = it_bsis-bukrs.
      it_caratula-hkont = it_bsis-hkont.

      IF it_bsis-movto = 'B'.
        it_caratula-banco = it_bsis-wrbtr.
        it_caratula-conta = 0.
        it_caratula-saldo = it_bsis-wrbtr.
      ELSE.
        it_caratula-conta = it_bsis-wrbtr.
        it_caratula-banco = 0.
        it_caratula-saldo = it_bsis-wrbtr.
      ENDIF.

      IF  it_bsis-augbl IS INITIAL.
        IF it_bsis-movto = 'B'.
          it_caratula-banco_open = it_bsis-wrbtr.
          it_caratula-conta_open = 0.
          it_caratula-saldo_open = it_bsis-wrbtr.
        ELSE.
          it_caratula-conta_open = it_bsis-wrbtr.
          it_caratula-banco_open = 0.
          it_caratula-saldo_open = it_bsis-wrbtr.
        ENDIF.
      ENDIF.
      APPEND it_caratula.
    ELSE.

      IF it_bsis-movto = 'B'.
        it_caratula-banco = it_caratula-banco + it_bsis-wrbtr.
        it_caratula-saldo = it_caratula-banco + it_caratula-conta.
      ELSE.
        it_caratula-conta = it_caratula-conta + it_bsis-wrbtr.
        it_caratula-saldo = it_caratula-banco + it_caratula-conta.
      ENDIF.
      IF  it_bsis-augbl IS INITIAL.
        IF it_bsis-movto = 'B'.
          it_caratula-banco_open = it_caratula-banco_open + it_bsis-wrbtr.
          it_caratula-saldo_open = it_caratula-banco_open + it_caratula-conta_open.
        ELSE.
          it_caratula-conta_open = it_caratula-conta_open + it_bsis-wrbtr.
          it_caratula-saldo_open = it_caratula-banco_open + it_caratula-conta_open.
        ENDIF.
      ENDIF.

      MODIFY it_caratula INDEX sy-tabix.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " select_items_abiertos

*&---------------------------------------------------------------------*
*&      Form  LISTA_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lista_alv .

  REFRESH: fieldcat.
  CLEAR: fieldcat, layout, print.

* ALV
* Definicion de parametros de layout
  layout-no_keyfix = ' '.
  layout-zebra = 'X'.
  layout-f2code = 'VER'.
  layout-colwidth_optimize = 'X'.

  wa_titulo = 'Resumen Conciliación Bancaria'.


  PERFORM f_asigna_fieldcat USING:
    'BUKRS'       'IT_CARATULA' ' ' ' '  '01' ' ' ' ' 'Sociedad' 'X' ' ' ' ' '10' ,
    'HKONT'       'IT_CARATULA' ' ' ' '  '01' ' ' ' ' 'Cuenta'  ' ' ' ' ' ' '20',
    'TXT50'       'IT_CARATULA' ' ' ' '  '02' ' ' ' ' 'Descripción_Cuenta'   ' ' ' ' ' ' '25',
    'BANCO'       'IT_CARATULA' ' ' ' '  '03' ' ' ' ' 'Bco. a F.Corte'      ' ' ' ' ' ' '25',
    'CONTA'       'IT_CARATULA' ' ' ' '  '04' ' ' ' ' 'Cont. a F.Corte'      ' ' ' ' ' ' '25',
    'SALDO'       'IT_CARATULA' ' ' ' '  '05' ' ' ' ' 'Total Gral. a F.Corte'      ' ' ' ' ' ' '25',
    'BANCO_OPEN'  'IT_CARATULA' ' ' ' '  '06' ' ' ' ' 'Bco. a F.Corte(Actual)'      ' ' ' ' ' ' '25',
    'CONTA_OPEN'  'IT_CARATULA' ' ' ' '  '07' ' ' ' ' 'Cont. a F.Corte(Actual)'      ' ' ' ' ' ' '25',
    'SALDO_OPEN'  'IT_CARATULA' ' ' ' '  '08' ' ' ' ' 'Total Gral. a F.Corte(Actual)'      ' ' ' ' ' ' '32'.



  print-no_print_listinfos = 'X'.
  print-no_print_selinfos  = 'X'.

  repid = sy-repid.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program          = repid
      i_callback_user_command     = g_user_command
      i_callback_pf_status_set    = 'SET_STATUS'
      i_callback_html_top_of_page = g_callback_html_top_of_page
      i_structure_name            = 'IT_CARATULA'
      i_grid_title                = wa_titulo
      is_layout                   = layout
      it_fieldcat                 = fieldcat[]
      is_print                    = print
    TABLES
      t_outtab                    = it_caratula
    EXCEPTIONS
      program_error               = 1
      OTHERS                      = 2.

  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.                    " LISTA_ALV


*----------------------------------------------------------------------*
FORM lista_alv_2 .
*----------------------------------------------------------------------*

  REFRESH: fieldcat.
  CLEAR: fieldcat, layout, print.

* ALV
* Definicion de parametros de layout
  layout-no_keyfix = ' '.
  layout-zebra = 'X'.
  layout-f2code = 'VER'.
  layout-colwidth_optimize = 'X'.

  PERFORM asignar_campos.

  print-no_print_listinfos = 'X'.
  print-no_print_selinfos  = 'X'.

  repid = sy-repid.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program          = repid
      i_callback_user_command     = 'USER_COMMAND2'
      i_callback_html_top_of_page = g_callback_html_top_of_page
      i_structure_name            = 'IT_DETALLE'
      i_grid_title                = wa_titulo
      is_layout                   = layout
      it_fieldcat                 = fieldcat[]
      i_save                      = 'A'
      is_variant                  = g_variant
      is_print                    = print
    TABLES
      t_outtab                    = it_detalle
    EXCEPTIONS
      program_error               = 1
      OTHERS                      = 2.

  IF sy-subrc <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " LISTA_ALV_2
*&---------------------------------------------------------------------*
*&      Form  F_ASIGNA_FIELDCAT
*&---------------------------------------------------------------------*
FORM f_asigna_fieldcat USING x_field
                             x_tab
                             x_ref
                             x_ref_f
                             x_col_pos
                             x_hotspot
                             x_checkbox
                             x_seltext_l
                             x_key
                             x_no_out
                             x_do_sum
                             x_largo.

  DATA: v_yy_ant(4)   TYPE n.
  DATA: v_mm_ant(2)   TYPE n.

  fieldcat-fieldname     = x_field.
  fieldcat-tabname       = x_tab.
  fieldcat-ref_tabname   = x_ref.
  fieldcat-ref_fieldname = x_ref_f.
  fieldcat-col_pos       = x_col_pos.
  fieldcat-hotspot       = x_hotspot.
  fieldcat-checkbox      = x_checkbox.
  fieldcat-seltext_l     = x_seltext_l.
  fieldcat-key           = x_key.
  fieldcat-no_out        = x_no_out.
  fieldcat-do_sum        = x_do_sum.
  fieldcat-outputlen     = x_largo.

  IF x_field = 'BANCO'      OR x_field = 'CONTA'      OR x_field = 'SALDO'      OR
     x_field = 'BANCO_OPEN' OR x_field = 'CONTA_OPEN' OR x_field = 'SALDO_OPEN' OR
     x_field = 'DMBTR'      OR x_field = 'WRBTR'      OR x_field = 'MONTO'      OR
     x_field = 'MONTO_01'   OR x_field = 'MONTO_02'   OR x_field = 'MONTO_03'   OR
     x_field = 'MONTO_04'   OR x_field = 'MONTO_05'   OR x_field = 'MONTO_06'   OR
     x_field = 'MONTO_07'   OR x_field = 'MONTO_08'   OR x_field = 'MONTO_09'   OR
     x_field = 'MONTO_10'   OR x_field = 'MONTO_11'   OR x_field = 'MONTO_12'   OR
     x_field = 'MONTO_13'   OR x_field = 'MONTO_14'   OR x_field = 'MONTO_15'   OR
     x_field = 'MONTO_16'   OR x_field = 'MONTO_17'   OR x_field = 'MONTO_18'   OR
     x_field = 'MONTO_19'   OR x_field = 'MONTO_20'   OR x_field = 'MONTO_21'   OR
     x_field = 'MONTO_22'   OR x_field = 'MONTO_23'   OR x_field = 'MONTO_24'   OR
     x_field = 'SALDO_ANUAL'.

    fieldcat-currency      = 'CLP'.
    fieldcat-do_sum = c_x.

    IF  x_field = 'MONTO_01'   OR x_field = 'MONTO_02'   OR x_field = 'MONTO_03'   OR
        x_field = 'MONTO_04'   OR x_field = 'MONTO_05'   OR x_field = 'MONTO_06'   OR
        x_field = 'MONTO_07'   OR x_field = 'MONTO_08'   OR x_field = 'MONTO_09'   OR
        x_field = 'MONTO_10'   OR x_field = 'MONTO_11'   OR x_field = 'MONTO_12'   OR
        x_field = 'MONTO_13'   OR x_field = 'MONTO_14'   OR x_field = 'MONTO_15'   OR
        x_field = 'MONTO_16'   OR x_field = 'MONTO_17'   OR x_field = 'MONTO_18'   OR
        x_field = 'MONTO_19'   OR x_field = 'MONTO_20'   OR x_field = 'MONTO_21'   OR
        x_field = 'MONTO_22'   OR x_field = 'MONTO_23'   OR x_field = 'MONTO_24'.

      CASE x_field+6(2).
        WHEN '01' OR '02' OR '03' OR '04' OR '05' OR '06' OR
             '07' OR '08' OR '09' OR '10' OR '11' OR '12'.

          v_yy_ant = p_budat+0(4) - 1.
          CONCATENATE v_yy_ant x_field+6(2) INTO fieldcat-seltext_l SEPARATED BY '/'.

        WHEN '13' OR '14' OR '15' OR '16' OR '17' OR '18' OR
             '19' OR '20' OR '21' OR '22' OR '23' OR '24'.

          v_mm_ant = x_field+6(2).
          v_mm_ant = v_mm_ant - 12.
          CONCATENATE p_budat+0(4) v_mm_ant INTO fieldcat-seltext_l SEPARATED BY '/'.

      ENDCASE.
    ENDIF.

  ENDIF.

  IF x_field = 'BUKRS' OR x_field = 'HKONT' OR x_field = 'HBKID' OR x_field = 'TXT50'.
    fieldcat-key    = c_x.
  ENDIF.

  IF x_field = 'BELNR'.
    fieldcat-hotspot    = c_x.
  ENDIF.


  APPEND fieldcat.
  CLEAR fieldcat.

ENDFORM.                    " F_ASIGNA_FIELDCAT

*---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.
*---------------------------------------------------------------------*
* Nos aseguramos que no haya pinchado sobre una linea sin nada
  CHECK NOT rs_selfield-tabname IS INITIAL.

  CASE r_ucomm.
    WHEN 'VER'.
      READ TABLE it_caratula INDEX rs_selfield-tabindex.
      wa_bukrs = it_caratula-bukrs.
      wa_hkont = it_caratula-hkont.


      IF it_caratula-hkont IS INITIAL OR wa_hkont IS INITIAL.
        MESSAGE s004(zfi) WITH 'Cuenta no definida'.

      ELSEIF rs_selfield-fieldname <> 'SALDO' AND rs_selfield-fieldname <> 'SALDO_OPEN'.
        MESSAGE s004(zfi) WITH 'Debe seleccionar columnas Total_General'.

      ELSE.
        IF rs_selfield-fieldname = 'SALDO'.
          PERFORM busca_detalle_open USING '1' 'T'.
        ENDIF.
        IF rs_selfield-fieldname = 'SALDO_OPEN'.
          PERFORM busca_detalle_open USING '1' 'A'.
        ENDIF.
      ENDIF.
    WHEN 'DETALLE'.
      wa_bukrs = p_bukrs.
      PERFORM busca_detalle_open USING '0' 'T'.
    WHEN 'DETALLE2'.
      wa_bukrs = p_bukrs.
      PERFORM busca_detalle_open USING '0' 'A'.

    WHEN 'BACK'.
      REFRESH it_detalle.
      SET SCREEN 0.
      LEAVE SCREEN.

    WHEN OTHERS.
      REFRESH it_detalle.
      SET SCREEN 0.
      LEAVE SCREEN.

  ENDCASE.

ENDFORM.                    "user_command

*---------------------------------------------------------------------*
*       FORM USER_COMMAND2                            *
*---------------------------------------------------------------------*
* Definir rutina que responderá a los eventos en listado              *
*---------------------------------------------------------------------*
FORM user_command2 USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

* Nos aseguramos que no haya pinchado sobre una linea sin nada
  CHECK NOT rs_selfield-tabname IS INITIAL.

  CASE r_ucomm.
    WHEN 'VER' OR '&IC1'.
      READ TABLE it_detalle INDEX rs_selfield-tabindex.
      wa_bukrs = it_detalle-bukrs.
      wa_belnr = it_detalle-belnr.
      wa_gjahr = it_detalle-gjahr.

      IF wa_bukrs IS INITIAL OR wa_belnr IS INITIAL OR wa_gjahr IS INITIAL.
        MESSAGE e004(zfi) WITH 'Debe seleccionar un Comprobante'.
      ELSE.
        PERFORM ver_comprobante.
      ENDIF.

    WHEN 'BACK'.
      SET SCREEN 0.
*      CLEAR ok_code.
      LEAVE SCREEN.

    WHEN OTHERS.
      SET SCREEN 0.
*      CLEAR ok_code.
      LEAVE SCREEN.

  ENDCASE.

ENDFORM.                    "user_command2

*---------------------------------------------------------------------*
FORM user_command3  USING r_ucomm LIKE sy-ucomm
                          rs_selfield TYPE slis_selfield.
*---------------------------------------------------------------------*
* Nos aseguramos que no haya pinchado sobre una linea sin nada
  CHECK NOT rs_selfield-tabname IS INITIAL.

  CASE r_ucomm.
    WHEN 'VER'.

    WHEN 'BACK'.
      REFRESH it_detalle.
      SET SCREEN 0.
      LEAVE SCREEN.

    WHEN OTHERS.
      REFRESH it_detalle.
      SET SCREEN 0.
      LEAVE SCREEN.

  ENDCASE.


ENDFORM.                    "user_command3




*----------------------------------------------------------------------*
FORM busca_detalle_open USING    value(p_todo) value(p_opc).
*----------------------------------------------------------------------*

  DATA: txt50 LIKE  skat-txt50,
        hkont LIKE  bsis-hkont.

  REFRESH it_detalle .

  IF p_opc = 'T'.

    wa_titulo = 'Detalle Partidas Pendiente  a Fecha de Corte'.
  ELSE.
    wa_titulo = 'Detalle Partidas Pendientes a Fecha de corte (Actual.)'.
  ENDIF.

  IF p_todo = '0'.
    LOOP AT it_bsis WHERE bukrs  = wa_bukrs.
      IF hkont <> it_bsis-hkont.
        SELECT SINGLE txt50 INTO txt50 FROM skat
            WHERE ktopl = p_pcta
              AND saknr = it_bsis-hkont
              AND spras = sy-langu.
        hkont = it_bsis-hkont.
      ENDIF.

      IF p_opc = 'T' OR
         ( p_opc = 'A' AND it_bsis-augbl IS INITIAL ).

        CLEAR it_detalle.
        MOVE-CORRESPONDING it_bsis TO it_detalle.
        IF it_detalle-shkzg = 'H'.
          it_detalle-monto = it_detalle-dmbtr * -1.
        ELSE.
          it_detalle-monto = it_detalle-dmbtr.
        ENDIF.
        it_detalle-txt50 = txt50.
        APPEND it_detalle.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF p_todo = '1'.

    SELECT SINGLE txt50 INTO txt50 FROM skat
        WHERE ktopl = p_pcta
          AND saknr = wa_hkont
          AND spras = sy-langu.


    LOOP AT it_bsis WHERE bukrs  = wa_bukrs
                      AND hkont  = wa_hkont.

      IF p_opc = 'T' OR
         ( p_opc = 'A' AND it_bsis-augbl IS INITIAL ).

        CLEAR it_detalle.
        MOVE-CORRESPONDING it_bsis TO it_detalle.
        IF it_detalle-shkzg = 'H'.
          it_detalle-monto = it_detalle-dmbtr * -1.
        ELSE.
          it_detalle-monto = it_detalle-dmbtr.
        ENDIF.
        it_detalle-txt50 = txt50.
        APPEND it_detalle.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF p_alv IS INITIAL.
    PERFORM call_alv_2.
  ELSE.
    PERFORM lista_alv_2.
  ENDIF.

ENDFORM.                    "BUSCA_DETALLE_OPEN


*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  html_top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->DOCUMENT   text
*----------------------------------------------------------------------*
FORM html_top_of_page USING document
                            TYPE REF TO cl_dd_document.     "#EC CALLED

  DATA: l_title      TYPE sdydo_text_element,
          l_text       TYPE sdydo_text_element,
          l_font       TYPE sdydo_attribute VALUE '1',
          ls_zfigiro   TYPE zfigiro,
          l_month      TYPE fcltx.
*L1
  l_text = 'Sociedad:'.
  CALL METHOD document->new_line.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.

  CALL METHOD document->add_gap
    EXPORTING
      width = 8.

  SELECT SINGLE * FROM t001 WHERE bukrs = p_bukrs.
  CONCATENATE t001-butxt ' '
    INTO l_text SEPARATED BY space.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.
*L2
  l_text = 'Banco Propio:'.
  CALL METHOD document->new_line.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.

  CALL METHOD document->add_gap
    EXPORTING
      width = 8.

  IF wa_hbkid = '0'.
    CONCATENATE s_hbkid-low '' INTO l_text.
  ELSE.
    CONCATENATE '' '' INTO l_text.
  ENDIF.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_fontsize = l_font.

*L3
  l_text = 'Fecha Corte  Al:'.
  CALL METHOD document->new_line.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.

  CALL METHOD document->add_gap
    EXPORTING
      width = 8.

  CONCATENATE p_budat+6 p_budat+4(2) p_budat(4) INTO l_text SEPARATED BY '/'.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_fontsize = l_font.

ENDFORM.                    "html_top_of_page
*&---------------------------------------------------------------------*
*&      Form  SELECT_PARAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_param .

  REFRESH: it_caratula, it_proyeccion.
  CLEAR:   it_caratula, it_proyeccion,
           wa_bukrs, wa_hkont.

  IF NOT s_vari IS INITIAL.
    PERFORM pai_of_selection_screen.
  ENDIF.


  wa_hbkid = '0'.
  DESCRIBE TABLE s_hbkid LINES wa_contador.

  IF s_hbkid IS INITIAL AND wa_contador = 0.
    wa_hbkid = '1'.
    SELECT * FROM t012  INTO TABLE it_t012 WHERE bukrs EQ p_bukrs.
    REFRESH s_hbkid.
    LOOP AT it_t012.
      CLEAR s_hbkid.
      s_hbkid-sign   = 'I'.
      s_hbkid-option = 'EQ'.
      s_hbkid-low    = it_t012-hbkid.
      APPEND s_hbkid.
    ENDLOOP.
  ENDIF.

  SELECT * FROM skb1  INTO TABLE it_skb1 WHERE bukrs EQ p_bukrs AND hbkid IN s_hbkid.
  DESCRIBE TABLE s_saknr LINES wa_contador.
  CHECK wa_contador = 0.


  REFRESH s_saknr.
  LOOP AT it_skb1.
    CLEAR s_saknr.
    s_saknr-sign   = 'I'.
    s_saknr-option = 'EQ'.
    s_saknr-low    = it_skb1-saknr.
    APPEND s_saknr.
  ENDLOOP.

  DESCRIBE TABLE it_skb1 LINES wa_contador.
  IF wa_contador = 0.
    CLEAR s_saknr.
    s_saknr-sign   = 'I'.
    s_saknr-option = 'EQ'.
    s_saknr-low    = 'XXXX'.
    APPEND s_saknr.
  ENDIF.


ENDFORM.                    " SELECT_PARAM
*&---------------------------------------------------------------------*
*&      Form  VER_COMPROBANTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ver_comprobante .
  SET PARAMETER ID: 'GJR' FIELD wa_gjahr,
                    'BLN' FIELD wa_belnr,
                    'BUK' FIELD wa_bukrs.

  CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

ENDFORM.                    " VER_COMPROBANTE
*&---------------------------------------------------------------------*
*&      Form  DETERMINA_PERIODO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_BSIS_BUDAT  text
*----------------------------------------------------------------------*
FORM determina_periodo  USING p_budat
                              p_proye
                     CHANGING p_perio.

  IF p_budat+0(4) = p_proye+0(4).
    p_perio = p_budat+4(2) + 12.
  ELSEIF p_budat+0(4) < p_proye+0(4).
    p_perio = p_budat+4(2).
  ENDIF.

ENDFORM.                    " DETERMINA_PERIODO
*&---------------------------------------------------------------------*
*&      Form  ASIGNAR_CAMPOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM asignar_campos .
  PERFORM f_asigna_fieldcat USING:
    'BUKRS'      'IT_DETALLE' ' ' ' '  '01' ' ' ' ' 'Soc' ' ' ' ' ' ' '4' ,
    'HKONT'      'IT_DETALLE' ' ' ' '  '02' ' ' ' ' 'Cuenta' ' ' ' ' ' ' '10' ,
    'TXT50'      'IT_DETALLE' ' ' ' '  '03' ' ' ' ' 'Descripcion' ' ' ' ' ' ' '30' ,
    'HBKID'      'IT_DETALLE' ' ' ' '  '04' ' ' ' ' 'Banco'  ' ' ' ' ' ' '5' ,
    'GJAHR'      'IT_DETALLE' ' ' ' '  '05' ' ' ' ' 'Ejerc'  ' ' ' ' ' ' '5',
    'BELNR'      'IT_DETALLE' ' ' ' '  '06' ' ' ' ' 'N°Compr' ' ' ' ' ' ' '10' ,
    'BUZEI'      'IT_DETALLE' ' ' ' '  '07' ' ' ' ' 'Po' ' ' ' ' ' ' '3' ,
    'BUDAT'      'IT_DETALLE' ' ' ' '  '08' ' ' ' ' 'Fec_Contab' ' ' ' ' ' ' '10' ,
    'WAERS'      'IT_DETALLE' ' ' ' '  '09' ' ' ' ' 'Moneda'  ' ' ' ' ' ' '5' ,
    'XBLNR'      'IT_DETALLE' ' ' ' '  '10' ' ' ' ' 'Referencia' ' ' ' ' ' ' '16' ,
    'BLART'      'IT_DETALLE' ' ' ' '  '11' ' ' ' ' 'TD' ' ' ' ' ' ' '2' ,
    'BSCHL'      'IT_DETALLE' ' ' ' '  '12' ' ' ' ' 'Cl'  ' ' ' ' ' ' '2' ,
    'MONTO'      'IT_DETALLE' ' ' ' '  '13' ' ' ' ' 'Monto'  ' ' ' ' ' ' '35' ,
    'SGTXT'      'IT_DETALLE' ' ' ' '  '14' ' ' ' ' 'TextoExplicativo'  ' ' ' ' ' ' '30' ,
    'ZUONR'      'IT_DETALLE' ' ' ' '  '15' ' ' ' ' 'N°Asignac'  ' ' ' ' ' ' '18' ,
    'AWKEY'      'IT_DETALLE' ' ' ' '  '16' ' ' ' ' 'ClaveRef'  ' ' ' ' ' ' '20',
    'USNAM'      'IT_DETALLE' ' ' ' '  '17' ' ' ' ' 'Usuario' ' ' ' ' ' ' '12' ,
    'AUGDT'      'IT_DETALLE' ' ' ' '  '18' ' ' ' ' 'FecComp'  ' ' ' ' ' ' '10' ,
    'AUGBL'      'IT_DETALLE' ' ' ' '  '19' ' ' ' ' 'DocComp'  ' ' ' ' ' ' '10' ,
    'STBLG'      'IT_DETALLE' ' ' ' '  '20' ' ' ' ' 'Nro_Doc_Anul'      ' ' ' ' ' ' '20' ,
    'STJAH'      'IT_DETALLE' ' ' ' '  '21' ' ' ' ' 'Ejerc_Doc_Anul'      ' ' ' ' ' ' '10' ,
    'STGRD'      'IT_DETALLE' ' ' ' '  '22' ' ' ' ' 'Motivo_Anul'      ' ' ' ' ' ' '10' ,
    'XREF1_HD'   'IT_DETALLE' ' ' ' '  '23' ' ' ' ' 'ClRefC1' ' ' ' ' ' ' '20' ,
    'XREF2_HD'   'IT_DETALLE' ' ' ' '  '24' ' ' ' ' 'ClRefC2' ' ' ' ' ' ' '20' ,
    'TEXTS'      'IT_DETALLE' ' ' ' '  '25' ' ' ' ' 'Texto'      ' ' ' ' ' ' '4' ,
    'CHECT'      'IT_DETALLE' ' ' ' '  '26' ' ' ' ' 'N°Ch'      ' ' ' ' ' ' '13' ,
    'STCD1'      'IT_DETALLE' ' ' ' '  '27' ' ' ' ' 'RUT'      ' ' ' ' ' ' '13' ,
    'NAME1'      'IT_DETALLE' ' ' ' '  '28' ' ' ' ' 'Nombre'      ' ' ' ' ' ' '30' .


  IF p_motivo = 'X'.
    PERFORM f_asigna_fieldcat USING 'ZZMOT_EMIS' 'IT_DETALLE' ' ' ' '  '27' ' ' ' ' 'MotivoEmis'      ' ' ' ' ' ' '10' .
  ENDIF.

  IF p_agenci = 'X'.
    PERFORM f_asigna_fieldcat USING 'ZZ_AGENCIA' 'IT_DETALLE' ' ' ' '  '28' ' ' ' ' 'Agencia'      ' ' ' ' ' ' '10' .
  ENDIF.
ENDFORM.                    " ASIGNAR_CAMPOS






INCLUDE zfir001_conc_bancos_alv.
*&---------------------------------------------------------------------*
*&      Form  BUSCA_DETALLE_OPEN1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1410   text
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  BUSCA_DETALLE_OPEN1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1413   text
*      -->P_1414   text
*----------------------------------------------------------------------*
