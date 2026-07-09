*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <23-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFI_Contabilizacion Ingresos Adelantados
*&
*&---------------------------------------------------------------------*
*&.
*&..
*&---------------------------------------------------------------------*
REPORT  zsd_contab_ingr_adel.

TABLES: vbrk, vbrp, konv, kna1.

DATA bdcdata TYPE STANDARD TABLE OF bdcdata.
DATA ls_bdc  LIKE LINE OF bdcdata.
DATA ctumode TYPE ctu_mode   VALUE 'N'.
DATA cupdate TYPE ctu_update VALUE 'S'.
DATA gv_icon TYPE c LENGTH 30.

DATA messtab TYPE STANDARD TABLE OF bdcmsgcoll.
CLASS lcl_handle_events DEFINITION DEFERRED.
DATA: gr_events TYPE REF TO lcl_handle_events.
DATA: columnas TYPE REF TO cl_salv_columns_table,
      columna TYPE REF TO cl_salv_column_table,
      gr_display TYPE REF TO cl_salv_display_settings.

*----------------------------------------------------------------------*
*       CLASS lcl_report DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_report DEFINITION.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_data,
           vbeln TYPE vbrk-vbeln ,
           bukrs TYPE vbrk-bukrs,
           fkart TYPE vbrk-fkart,
           fkdat TYPE vbrk-fkdat,
           rfbsk TYPE vbrk-rfbsk,
           ksto TYPE  vbrk-fksto,
           kvgr4 TYPE vbrp-kvgr4,
           kunrg TYPE vbrk-kunrg,
           rut   TYPE kna1-stcd1,
           name1 TYPE kna1-name1,
           knumv TYPE vbrk-knumv,
           xblnr TYPE vbrk-xblnr,
           bstkd TYPE vbkd-bstkd,
           kostl TYPE vbrp-kostl,
           posnr TYPE vbrp-posnr,
           prctr TYPE vbrp-prctr,
           zcuotas_fin TYPE vbrk-zcuotas_fin,
           zcuotas TYPE vbrk-zcuotas,
           znum_cuotas TYPE vbrk-znum_cuotas,
           cuota_contab  TYPE vbrk-zcuotas,
           kbetr TYPE konv-kbetr,
           waerk TYPE vbrk-waerk,
    END   OF ty_data .
    TYPES: BEGIN OF ty_res_cond_cta,
      kschl TYPE konv-kschl,
      newko TYPE rf05a-newko,
      newbs TYPE rf05a-newbs,
      kbetr TYPE konv-kbetr,
    END   OF ty_res_cond_cta .
    DATA t_res_cond_cta TYPE STANDARD TABLE OF ty_res_cond_cta.

    TYPES: BEGIN OF ty_cuotas,
                 cuota TYPE i,
                 fecha TYPE date,
                 valor TYPE konv-kbetr,
                 END   OF ty_cuotas .
    DATA t_out TYPE STANDARD TABLE OF zsdia001_est .
    DATA t_out_filt TYPE STANDARD TABLE OF zsdia001_est .
    DATA t_out_res TYPE STANDARD TABLE OF zsdia001_est .
    DATA t_cuotas TYPE STANDARD TABLE OF ty_cuotas.

    DATA wa_out LIKE LINE OF t_out.
    DATA o_alv TYPE REF TO cl_salv_table .
    DATA o_alv_d TYPE REF TO cl_salv_table .
    DATA: lx_msg TYPE REF TO cx_salv_msg.

    DATA t_data TYPE STANDARD TABLE OF ty_data.
    DATA wa_data LIKE LINE OF t_data.

    DATA ls_mess LIKE LINE OF messtab.
    DATA t_log TYPE STANDARD TABLE OF bdcmsgcoll.
    DATA gs_thead TYPE thead  .

    DATA t_lines TYPE STANDARD TABLE OF tline.
    DATA gs_lines LIKE LINE OF t_lines.
    DATA l_message TYPE bapi_msg.

    DATA t_konv TYPE STANDARD TABLE OF konv.
    DATA wa_konv LIKE LINE OF t_konv.

    TYPES: lv_icon TYPE c LENGTH 30,
           l_text  TYPE c LENGTH 70.

    METHODS:
      get_data,
      generate_output,
      display_detail,
      procesar_datos,
      call_transaction EXPORTING
          e_icon  TYPE lv_icon
          e_text  TYPE l_text
          e_exito TYPE boolean
          e_doccontab TYPE bkpf-belnr,
      display_log,
     refresh_table
      CHANGING
        co_alv TYPE REF TO cl_salv_table.

  PRIVATE SECTION.
    METHODS: set_pf_status.
    METHODS: set_hotspot_nombredoc
             CHANGING
                      co_alv   TYPE REF TO cl_salv_table
                      co_report TYPE REF TO lcl_report.

    METHODS:
      on_link_click
        FOR EVENT link_click OF cl_salv_events_table
          IMPORTING
            row
            column  .
    METHODS:
     set_display_setting
    CHANGING
      co_alv TYPE REF TO cl_salv_table.

ENDCLASS.                    "lcl_report DEFINITION
*----------------------------------------------------------------------*
*       CLASS lcl_handle_events DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
       on_user_command FOR EVENT added_function OF cl_salv_events
                    IMPORTING e_salv_function.

ENDCLASS.                    "lcl_handle_events DEFINITION
*----------------------------------------------------------------------*


SELECTION-SCREEN: BEGIN OF BLOCK uno WITH FRAME TITLE text-001.
PARAMETERS: p_bukrs  TYPE vbrk-bukrs OBLIGATORY.
SELECT-OPTIONS: s_fkdat  FOR vbrk-fkdat ,
                s_fkart FOR vbrk-fkart OBLIGATORY NO INTERVALS,
                s_kvgr4 FOR vbrp-kvgr4 NO INTERVALS,
                s_kunrg FOR vbrk-kunrg ,
                s_vbeln FOR vbrk-vbeln.
PARAMETERS: p_repo TYPE  boolean AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN: END OF BLOCK uno.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN: BEGIN OF BLOCK dos WITH FRAME TITLE text-003.
PARAMETERS: p_budat TYPE bkpf-budat  OBLIGATORY,
            p_mode TYPE ctu_mode   DEFAULT 'N'.
SELECTION-SCREEN: END OF BLOCK dos.

INITIALIZATION.
  s_fkart-sign = 'I'.
  s_fkart-option = 'EQ'.
  s_fkart-low = 'ZFAC'.
  APPEND s_fkart.
  s_fkart-low = 'ZBOL'.
  APPEND s_fkart.
*-
  s_kvgr4-sign = 'I'.
  s_kvgr4-option = 'EQ'.
  s_kvgr4-low = '02'.
  APPEND s_kvgr4.
  s_kvgr4-low = '03'.
  APPEND s_kvgr4.
  s_kvgr4-low = '04'.
  APPEND s_kvgr4.

START-OF-SELECTION.
  DATA: lo_report TYPE REF TO lcl_report.
*
  CREATE OBJECT lo_report.
  lo_report->get_data( ).

  IF lo_report->t_data IS INITIAL.
    MESSAGE 'No existen registros para los parametros ingresados'(002) TYPE 'I'.
  ELSE.
    IF p_repo EQ abap_true.
      lo_report->generate_output( ).
    ELSE.
      lo_report->procesar_datos( ).
      IF lo_report->t_log IS NOT INITIAL.
        lo_report->display_log( ).
      ENDIF.
    ENDIF.
  ENDIF.
*----------------------------------------------------------------------*
*       CLASS lcl_report IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_user_command.
*
    CASE e_salv_function.
      WHEN 'CONTAB'.
        IF lo_report->t_out_res[] IS NOT INITIAL.
          lo_report->procesar_datos( ).
          IF lo_report->t_log IS NOT INITIAL.
            lo_report->display_log( ).
          ENDIF.
          CALL METHOD lo_report->refresh_table(
              CHANGING co_alv = lo_report->o_alv ).
        ENDIF.
      WHEN 'DETAIL'.
        lo_report->display_detail( ).
    ENDCASE.
  ENDMETHOD.                    "on_user_command
ENDCLASS.                    "lcl_handle_events IMPLEMENTATION
*----------------------------------------------------------------------*
*       CLASS lcl_report IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_report IMPLEMENTATION.

  METHOD get_data.
    DATA cont TYPE i.
    DATA l_index TYPE sy-tabix.
    DATA l_vbelv TYPE vbfa-vbelv.
    DATA l_fecha TYPE sy-datum.
    DATA l_sum TYPE bseg-dmbtr.
    DATA l_sum_fact TYPE bseg-dmbtr.
    DATA wa_cuotas LIKE LINE OF t_cuotas.
**--
    FIELD-SYMBOLS: <fs_data> LIKE LINE OF t_data.
*
    SELECT k~bukrs k~vbeln k~fkdat k~fkart k~fkdat
           k~zcuotas_fin k~knumv k~waerk k~kunrg
           k~zcuotas k~znum_cuotas p~kvgr4 p~posnr
           k~xblnr k~zcuotas_fin
      INTO CORRESPONDING FIELDS OF TABLE t_data
    FROM vbrk AS k INNER JOIN vbrp AS p
         ON  ( k~vbeln     EQ p~vbeln )
    WHERE
    k~bukrs EQ p_bukrs
    AND k~fkdat IN s_fkdat
    AND k~fkart IN s_fkart
    AND      k~rfbsk     EQ 'C'
    AND      k~fksto     NE 'X'
*  AND  ( k~zcuotas_fin EQ ' ' )
    AND k~vbeln IN s_vbeln
    AND      p~kvgr4 IN s_kvgr4.

    REFRESH: t_konv, t_cuotas. CLEAR: t_cuotas, t_konv.
    SORT t_data BY vbeln ASCENDING.
    LOOP AT t_data ASSIGNING <fs_data>.
      REFRESH: t_cuotas, t_konv.
      CLEAR: t_cuotas, t_konv.
      l_index = sy-tabix.
      CLEAR: <fs_data>-kbetr, l_sum.
*-    Obtenemos condiciones/valores factura
SELECT knumv kposn kschl kbetr INTO CORRESPONDING FIELDS OF TABLE t_konv
FROM konv WHERE knumv EQ <fs_data>-knumv
AND kposn EQ <fs_data>-posnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 23/12/2019 EY_DES02 ECDK917080 *
*AND kschl IN ('ZCUO', 'ZDC1', 'ZDC2', 'ZDC3', 'ZDC4', 'ZDC5', 'ZRE1').
AND KSCHL IN ( 'ZCUO' , 'ZDC1' , 'ZDC2' , 'ZDC3' , 'ZDC4' , 'ZDC5' , 'ZRE1' ) ORDER BY PRIMARY KEY .
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 23/12/2019 EY_DES02 ECDK917080 *
      LOOP AT t_konv INTO wa_konv WHERE knumv EQ <fs_data>-knumv.
        <fs_data>-kbetr = <fs_data>-kbetr + wa_konv-kbetr.
      ENDLOOP.
      cont = 1.
      CONCATENATE <fs_data>-fkdat(6) '01' INTO l_fecha.
      CALL FUNCTION 'SG_PS_GET_LAST_DAY_OF_MONTH'
        EXPORTING
          day_in            = l_fecha
        IMPORTING
          last_day_of_month = l_fecha
        EXCEPTIONS
          day_in_not_valid  = 1
          OTHERS            = 2.
      IF sy-subrc <> 0. ENDIF.
      WHILE  cont LE <fs_data>-znum_cuotas.
        wa_cuotas-cuota = cont.
        wa_cuotas-fecha = l_fecha.
        wa_cuotas-valor =  <fs_data>-kbetr .
        APPEND wa_cuotas TO t_cuotas.
        cont = cont + 1.
        ADD 1 TO l_fecha.
        CALL FUNCTION 'SG_PS_GET_LAST_DAY_OF_MONTH'
          EXPORTING
            day_in            = l_fecha
          IMPORTING
            last_day_of_month = l_fecha
          EXCEPTIONS
            day_in_not_valid  = 1
            OTHERS            = 2.
        IF sy-subrc <> 0. ENDIF.
        l_sum = l_sum + wa_cuotas-valor.
      ENDWHILE.

      READ TABLE t_cuotas INTO wa_cuotas WITH KEY fecha(6) = p_budat(6).
      IF sy-subrc EQ 0 AND sy-tabix GT 1 .
        <fs_data>-cuota_contab = sy-tabix.
*--     Validamos nro cuota a contabilizar vs/ cuotas ya contabilizadas
        IF NOT <fs_data>-cuota_contab GT <fs_data>-zcuotas AND
           NOT <fs_data>-zcuotas_fin IS INITIAL.
          CONTINUE.
        ELSE.
*--     Obtener nro contrato
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE vbelv INTO l_vbelv FROM vbfa WHERE vbeln   EQ <fs_data>-vbeln
*                                                       AND vbtyp_n EQ 'M'
*                                                       AND vbtyp_v EQ 'C'.
*
* NEW CODE
          SELECT vbelv
          UP TO 1 ROWS  INTO l_vbelv FROM vbfa WHERE vbeln   EQ <fs_data>-vbeln
                                                       AND vbtyp_n EQ 'M'
                                                       AND vbtyp_v EQ 'C' ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          IF sy-subrc EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*            SELECT SINGLE bstkd FROM vbkd INTO <fs_data>-bstkd WHERE vbeln EQ l_vbelv.
*
* NEW CODE
            SELECT bstkd
            UP TO 1 ROWS  FROM vbkd INTO <fs_data>-bstkd WHERE vbeln EQ l_vbelv ORDER BY PRIMARY KEY.

            ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          ENDIF.
*-      obtener centro costo/benefico(asume primera posicion)
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE prctr
*            FROM vbrp INTO CORRESPONDING FIELDS OF <fs_data>
*            WHERE vbeln EQ <fs_data>-vbeln.
*
* NEW CODE
          SELECT prctr
          UP TO 1 ROWS 
            FROM vbrp INTO CORRESPONDING FIELDS OF <fs_data>
            WHERE vbeln EQ <fs_data>-vbeln ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          <fs_data>-kostl = <fs_data>-prctr.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE stcd1 name1 INTO (<fs_data>-rut,<fs_data>-name1)
*            FROM kna1 WHERE kunnr = <fs_data>-kunrg.
*
* NEW CODE
          SELECT stcd1 name1
          UP TO 1 ROWS  INTO (<fs_data>-rut,<fs_data>-name1)
            FROM kna1 WHERE kunnr = <fs_data>-kunrg ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          MOVE-CORRESPONDING <fs_data> TO wa_out.
          MOVE-CORRESPONDING wa_cuotas TO wa_out.
          APPEND wa_out TO t_out.
          l_sum_fact = l_sum_fact + wa_out-valor.
        ENDIF.
      ELSE.
        DELETE t_konv WHERE knumv EQ <fs_data>-knumv.
      ENDIF.
      AT END OF vbeln.
        IF wa_out-vbeln IS NOT INITIAL.
          CLEAR gv_icon.
          PERFORM create_icon USING 2. " Amarillo
          wa_out-icon = gv_icon.
          MOVE l_sum_fact TO wa_out-valor.
          APPEND wa_out TO t_out_res.
          CLEAR : l_sum_fact, wa_out.
        ENDIF.
      ENDAT.
    ENDLOOP.

  ENDMETHOD.                    "get_data

  METHOD generate_output.
    DATA: lr_events TYPE REF TO cl_salv_events_table.
    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = o_alv
          CHANGING
            t_table      = t_out_res ).
      CATCH cx_salv_msg INTO lx_msg.
    ENDTRY.
    me->set_pf_status( ).

    CALL METHOD set_display_setting( CHANGING co_alv = o_alv ).
    lr_events = o_alv->get_event( ).
    CREATE OBJECT gr_events.
    SET HANDLER gr_events->on_user_command FOR lr_events.
*    SET HANDLER lcl_handle_events=>on_user_command FOR lr_events.
    CALL METHOD set_hotspot_nombredoc
      CHANGING
        co_alv    = o_alv
        co_report = lo_report.

    columnas = o_alv->get_columns( ).
    columnas->set_optimize(  ).
    "
    TRY.
        columna ?= columnas->get_column( 'ICON' ).
        columna->set_alignment( if_salv_c_alignment=>centered ).
      CATCH cx_salv_not_found.
    ENDTRY.
    "
    TRY.
        columna ?= columnas->get_column( 'TEXT' ).
        columna->set_long_text( 'Observaciones' ).
        columna->set_short_text( 'Observ.' ).
        columna->set_medium_text( 'Observaciones' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    " Setear interior del ALV y titulo
    " Get the reference to the settings of the table
    gr_display = o_alv->get_display_settings( ).
    " Set the striped pattern (ZEBRA pattern)
    gr_display->set_striped_pattern( cl_salv_display_settings=>true ).
    " Set the heading
    " gr_display->set_list_header( 'Contabilización Ingresos por adelantado' ).
    " Remove horizontal lines of the grid
    gr_display->set_horizontal_lines( if_salv_c_bool_sap=>true ).
    " Remove vertical lines of the grid
    gr_display->set_vertical_lines( if_salv_c_bool_sap=>true ).
    "
    o_alv->display( ).
    "
  ENDMETHOD.                    "generate_output

  METHOD display_detail.
    DATA: lo_sels_tab TYPE REF TO cl_salv_selections.
    DATA: lt_row TYPE salv_t_row.
    DATA ls_row LIKE LINE OF lt_row.
    DATA l_count TYPE i.
    DATA l_vbeln TYPE vbeln.
    CLEAR t_out_filt.
    REFRESH t_out_filt.

    lo_sels_tab = o_alv->get_selections( ).
    lt_row = lo_sels_tab->get_selected_rows( ).

    l_count = LINES( lt_row ).
    IF NOT l_count = 1.
      MESSAGE  'Debe seleccionar una linea'(004) TYPE 'I'.
      EXIT.
    ENDIF.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 23/12/2019 EY_DES02 ECDK917080 *
SORT LT_ROW .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 23/12/2019 EY_DES02 ECDK917080 *
    READ TABLE lt_row  INTO ls_row INDEX 1.
    CHECK  sy-subrc EQ 0.

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 23/12/2019 EY_DES02 ECDK917080 *
SORT T_OUT .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 23/12/2019 EY_DES02 ECDK917080 *
    READ TABLE t_out  INTO wa_out INDEX ls_row.
    CHECK  sy-subrc EQ 0.
    l_vbeln = wa_out-vbeln.
    LOOP AT t_out INTO wa_out WHERE vbeln = l_vbeln.
      APPEND wa_out TO t_out_filt.
    ENDLOOP.
    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = o_alv_d
          CHANGING
            t_table      = t_out_filt ).
      CATCH cx_salv_msg INTO lx_msg.
    ENDTRY.
*    me->set_pf_status( ).
    CALL METHOD set_display_setting(
    CHANGING
     co_alv = o_alv_d ).
    o_alv_d->display( ).

  ENDMETHOD.                    "generate_output

  METHOD procesar_datos.

    DATA l_datac(10) TYPE c.
    DATA l_string TYPE string.
    DATA l_montcuo(16) TYPE c.

    DATA c_cta_ingadel TYPE rf05a-newko VALUE '2012710005'.
    DATA l_newko  TYPE rf05a-newko .
    DATA l_newbs  TYPE rf05a-newbs.
    " V1 - Ini - JSHANNON - 2017.10.25
    DATA l_icon  TYPE c LENGTH 30.
    DATA l_text  TYPE c LENGTH 70.
    DATA l_text_cc TYPE c LENGTH 10.
    DATA l_text_nc TYPE c LENGTH 10.
    DATA l_bktxt TYPE bktxt.
    DATA l_sgtxt TYPE bseg-sgtxt.
    " V1 - Fin - JSHANNON - 2017.10.25
    DATA l_belnr TYPE bkpf-belnr.
    DATA l_exito TYPE boolean.

    DATA l_index TYPE sy-tabix.
    DATA cont TYPE i.
    DATA ls_messtab LIKE LINE OF messtab.
    DATA ls_res_cond_cta LIKE LINE OF t_res_cond_cta.
**-----------------------------------------------------------
    WRITE p_budat TO l_datac.

*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 23/12/2019 EY_DES02 ECDK917080 *
SORT T_OUT_RES .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 23/12/2019 EY_DES02 ECDK917080 *
    LOOP AT t_out_res INTO wa_out.
      l_index = sy-tabix.
      cont = wa_out-cuota_contab - wa_out-zcuotas.
      IF  cont  GT 1.
        ls_messtab-msgtyp = 'W'.
        ls_messtab-msgid = '00'.
        ls_messtab-msgnr = '001'.
        ls_messtab-msgv1 = text-005. "'Factura '.
        ls_messtab-msgv2 = wa_out-vbeln.
        ls_messtab-msgv3 = text-006. "' inconsistencia en Nº Cuotas'.
        APPEND ls_messtab TO t_log.
      ENDIF.
**-- Cabecera contable
      WRITE wa_out-cuota_contab TO l_text_cc NO-ZERO. CONDENSE l_text_cc.
      WRITE wa_out-znum_cuotas  TO l_text_nc NO-ZERO. CONDENSE l_text_nc.
      "
      l_bktxt = 'Pago cuotas'.
      WRITE wa_out-xblnr TO wa_out-xblnr NO-ZERO. CONDENSE wa_out-xblnr.
      "
      CONCATENATE 'Cuota' l_text_cc '/' l_text_nc 'de doc.' wa_out-xblnr
             INTO l_sgtxt SEPARATED BY space.
      "
      PERFORM bdc_dynpro      USING 'SAPMF05A'    '0100'.
      PERFORM bdc_field       USING 'BDC_CURSOR'  'RF05A-NEWKO'.
      PERFORM bdc_field       USING 'BDC_OKCODE'  '/00'.
      PERFORM bdc_field       USING 'BKPF-BLDAT'  l_datac.
      PERFORM bdc_field       USING 'BKPF-BLART'  'ZI'.
      PERFORM bdc_field       USING 'BKPF-BUKRS'  p_bukrs.
      PERFORM bdc_field       USING 'BKPF-BUDAT'  l_datac.
      PERFORM bdc_field       USING 'BKPF-MONAT'  p_budat+4(2).
      PERFORM bdc_field       USING 'BKPF-WAERS'  wa_out-waerk.
**--  Solo si no es la primera cuota asigna string cuota n /nn
      "IF l_index EQ 1.
      "  PERFORM bdc_field       USING 'BKPF-XBLNR'  wa_out-xblnr.
      "ELSE.
      PERFORM bdc_field       USING 'BKPF-XBLNR'  wa_out-xblnr.
      "ENDIF.
      PERFORM bdc_field       USING 'BKPF-BKTXT'  l_bktxt.
      PERFORM bdc_field       USING 'FS006-DOCID' '*'.
      PERFORM bdc_field       USING 'RF05A-NEWBS' '40'.
      PERFORM bdc_field       USING 'RF05A-NEWKO' c_cta_ingadel.
**--------------------------------------------------------
      WRITE wa_out-valor CURRENCY wa_out-waerk TO l_montcuo.

      PERFORM bdc_dynpro      USING 'SAPMF05A'    '0300'.
      PERFORM bdc_field       USING 'BDC_CURSOR'  'RF05A-NEWKO'.
      PERFORM bdc_field       USING 'BDC_OKCODE'  '/00'.
      PERFORM bdc_field       USING 'BSEG-WRBTR'  l_montcuo.
      PERFORM bdc_field       USING 'BSEG-MWSKZ'      'D0'.
      PERFORM bdc_field       USING 'BSEG-ZUONR'   wa_out-bstkd."'
      PERFORM bdc_field       USING 'BSEG-SGTXT'    l_sgtxt.
**--------------------------------------------------------
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE stcd1 INTO kna1-stcd1 FROM kna1 WHERE kunnr EQ wa_out-kunrg.
*
* NEW CODE
      SELECT stcd1
      UP TO 1 ROWS  INTO kna1-stcd1 FROM kna1 WHERE kunnr EQ wa_out-kunrg ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      PERFORM bdc_dynpro      USING 'SAPLKACB'        '0002'.
      PERFORM bdc_field       USING 'BDC_CURSOR'      'COBL-PRCTR'.
      PERFORM bdc_field       USING 'BDC_OKCODE'      '=ENTE'.
      PERFORM bdc_field       USING 'COBL-PRCTR'      wa_out-prctr.
      PERFORM bdc_field       USING 'COBL-ZZRUT_TERC' kna1-stcd1.
**-------------------------------------------------------
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE knumv INTO vbrk-knumv FROM vbrk WHERE vbeln EQ wa_out-vbeln.
*
* NEW CODE
      SELECT knumv
      UP TO 1 ROWS  INTO vbrk-knumv FROM vbrk WHERE vbeln EQ wa_out-vbeln ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

*-    Obtenemos condiciones/valores factura para resumir
      REFRESH : t_konv, t_res_cond_cta.
SELECT knumv kposn kschl kbetr INTO CORRESPONDING FIELDS OF TABLE t_konv
FROM konv WHERE knumv EQ vbrk-knumv
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 23/12/2019 EY_DES02 ECDK917080 *
*AND kschl IN ('ZCUO', 'ZDC1', 'ZDC2', 'ZDC3', 'ZDC4', 'ZDC5', 'ZRE1').
AND KSCHL IN ( 'ZCUO' , 'ZDC1' , 'ZDC2' , 'ZDC3' , 'ZDC4' , 'ZDC5' , 'ZRE1' ) ORDER BY PRIMARY KEY .
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 23/12/2019 EY_DES02 ECDK917080 *

      LOOP AT t_konv INTO wa_konv WHERE knumv EQ vbrk-knumv
                              AND kbetr NE 0.
        ls_res_cond_cta-kschl  = wa_konv-kschl.

        CASE wa_konv-kschl.
          WHEN 'ZCUO'.
            ls_res_cond_cta-newko = '6114100001'.
            ls_res_cond_cta-newbs = '50'.
          WHEN 'ZDC1'.
            ls_res_cond_cta-newko = '6114100006'.
            ls_res_cond_cta-newbs = '40'.
          WHEN 'ZDC2'.
            ls_res_cond_cta-newko = '6114100002'.
            ls_res_cond_cta-newbs = '40'..
          WHEN 'ZDC3'.
            ls_res_cond_cta-newko = '6114100008'.
            ls_res_cond_cta-newbs = '40'.
          WHEN 'ZDC4'.
            ls_res_cond_cta-newko = '6114100004'.
            ls_res_cond_cta-newbs = '40'.
          WHEN 'ZDC5'.
            ls_res_cond_cta-newko = '6114100005'.
            ls_res_cond_cta-newbs = '40'.
          WHEN 'ZRE1'.
            " V1 - Ini - JSHANNON - 2017.10.25
            " Cuando el Valor de recargo es negativo se debe
            " controlar la clave de contabilizacion 40 Debe - 50 Haber
            ls_res_cond_cta-newko = '6114100002'.
            IF wa_konv-kbetr < 0.
              ls_res_cond_cta-newbs = '40'.
            ELSE.
              ls_res_cond_cta-newbs = '50'.
            ENDIF.
            " V1 - Fin - JSHANNON - 2017.10.25
        ENDCASE.
        ls_res_cond_cta-kbetr = wa_konv-kbetr.
        COLLECT  ls_res_cond_cta INTO t_res_cond_cta .
      ENDLOOP.

      LOOP AT t_res_cond_cta INTO ls_res_cond_cta WHERE kbetr NE 0.
        .
        PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'BSEG-ZUONR'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM bdc_field       USING 'BSEG-MWSKZ'
                                      'D0'.
        PERFORM bdc_field       USING 'BSEG-ZUONR'
                                      wa_out-bstkd.
        PERFORM bdc_field       USING 'RF05A-NEWBS'
                                      ls_res_cond_cta-newbs.
        PERFORM bdc_field       USING 'RF05A-NEWKO'
                                      ls_res_cond_cta-newko."
        PERFORM bdc_field       USING 'DKACB-FMORE'
                                      'X'.
**------------------------------------------------------------
        PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'COBL-PRCTR'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=ENTE'.
        PERFORM bdc_field       USING 'COBL-PRCTR'
                                      wa_out-prctr.
**------------------------------------------------------------
        IF ls_res_cond_cta-kbetr LE 0.
          ls_res_cond_cta-kbetr = ls_res_cond_cta-kbetr * -1.
        ENDIF.
        WRITE ls_res_cond_cta-kbetr CURRENCY wa_out-waerk TO l_montcuo.
        PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'RF05A-NEWKO'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '/00'.
        PERFORM bdc_field       USING 'BSEG-WRBTR'
                                      l_montcuo.
        PERFORM bdc_field       USING 'BSEG-MWSKZ'
                                      'D0'.
        PERFORM bdc_field       USING 'BSEG-ZUONR'
                                      wa_out-bstkd."'numero contrato'.
        PERFORM bdc_field       USING 'BSEG-SGTXT'
                                        l_sgtxt.
**--------------------------------------------------------------------
        PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'COBL-PRCTR'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=ENTE'.
        PERFORM bdc_field       USING 'COBL-PRCTR'
                                      wa_out-prctr.
        PERFORM bdc_field       USING 'COBL-KOSTL'
                                      wa_out-kostl.
        PERFORM bdc_field       USING 'COBL-ZZRUT_TERC'
                                      kna1-stcd1.
      ENDLOOP.
**-------------------------------------------------------
      PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'BSEG-WRBTR'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=BU'.
      PERFORM bdc_field       USING 'BSEG-MWSKZ'
                                    'D0'.
      PERFORM bdc_field       USING 'BSEG-ZUONR'
                                    wa_out-bstkd.
      PERFORM bdc_field       USING 'BSEG-SGTXT'
                                     l_sgtxt.
      PERFORM bdc_field       USING 'DKACB-FMORE'
                                    'X'.
**-----------------------------------------------------
      PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
      PERFORM bdc_field       USING 'BDC_CURSOR'
                                    'COBL-PRCTR'.
      PERFORM bdc_field       USING 'BDC_OKCODE'
                                    '=ENTE'.
      PERFORM bdc_field       USING 'COBL-PRCTR'
                                    'CL51011201'.

      lo_report->call_transaction(
      IMPORTING  e_icon  = l_icon
                 e_text  = l_text
                 e_exito = l_exito
                 e_doccontab = l_belnr ).

      IF l_exito EQ abap_true.
        wa_out-belnr = l_belnr.
        wa_out-icon = l_icon.
        wa_out-text = l_text.
        MODIFY t_out_res FROM wa_out INDEX l_index TRANSPORTING icon belnr text.

        IF wa_out-cuota_contab EQ wa_out-znum_cuotas. "ultima cuota
          UPDATE vbrk
          SET zcuotas_fin = abap_true
              zcuotas = wa_out-cuota_contab
          WHERE vbeln EQ wa_out-vbeln.
          IF sy-subrc NE 0.
            ROLLBACK WORK.
          ELSE.
            COMMIT WORK.
          ENDIF.
        ELSE.
**-       Actualiza Nº de cuotas
          UPDATE vbrk
           SET zcuotas = wa_out-cuota_contab
          WHERE vbeln EQ wa_out-vbeln.
          IF sy-subrc NE 0.
            ROLLBACK WORK.
          ELSE.
            COMMIT WORK.
          ENDIF.
        ENDIF.
      ELSE.
        wa_out-belnr = l_belnr.
        wa_out-icon = l_icon.
        wa_out-text = l_text.
*ReSQ: No Need Of Change Internal Table T_OUT_RES Already Sorted
        MODIFY t_out_res FROM wa_out INDEX l_index TRANSPORTING icon belnr text.
      ENDIF.
      CLEAR wa_out.
    ENDLOOP.
  ENDMETHOD.                    "procesar_datos

  METHOD set_pf_status.

    o_alv->set_screen_status(
      pfstatus      =  'ZSALV_CONTAB_INGR'
      report        =  'ZSD_CONTAB_INGR_ADEL'
      set_functions = o_alv->c_functions_all ).

  ENDMETHOD.                    "SET_PF_STATUS

  METHOD set_hotspot_nombredoc.

    DATA: lo_cols_tab TYPE REF TO cl_salv_columns_table,
          lo_col_tab  TYPE REF TO cl_salv_column_table.
    DATA: lo_events TYPE REF TO cl_salv_events_table.

    lo_cols_tab = co_alv->get_columns( ).
*
    TRY.
        lo_col_tab ?= lo_cols_tab->get_column( 'VBELN' ).
      CATCH cx_salv_not_found.
    ENDTRY.
    TRY.
        CALL METHOD lo_col_tab->set_cell_type
          EXPORTING
            value = if_salv_c_cell_type=>hotspot.
        .
      CATCH cx_salv_data_error .
    ENDTRY.
*
    lo_events = o_alv->get_event( ).
*
    SET HANDLER co_report->on_link_click FOR lo_events.
*
  ENDMETHOD.                    "set_hotspot_nombredoc
  METHOD on_link_click.

*ReSQ: No Need Of Change Internal Table T_OUT Already Sorted
    READ TABLE t_out INTO wa_out INDEX row.
    IF wa_out-vbeln IS NOT INITIAL.
      SET PARAMETER ID: 'VF' FIELD wa_out-vbeln.
      CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDMETHOD.                    "on_link_click
  METHOD set_display_setting.
*
    DATA: lo_display TYPE REF TO cl_salv_display_settings.
    DATA: lo_cols_tab TYPE REF TO cl_salv_columns_table.

    lo_cols_tab = co_alv->get_columns( ).
    lo_cols_tab->set_optimize( abap_true ).
    lo_display = o_alv->get_display_settings( ).
    lo_display->set_striped_pattern( abap_true ).
*
  ENDMETHOD.                    "set_display_setting
  METHOD refresh_table.
    columnas->set_optimize(  ).
    co_alv->refresh( ).
*
  ENDMETHOD.                    "refresh_table
  METHOD  call_transaction.
    DATA ls_messtab LIKE LINE OF messtab.

    CLEAR: e_exito, e_doccontab, e_icon, e_text.

    CALL TRANSACTION 'FB01' USING bdcdata
                     MODE   p_mode "ctumode
                     UPDATE cupdate
                     MESSAGES INTO messtab.
**- verifica documento creado
    READ TABLE messtab INTO ls_messtab WITH KEY msgtyp = 'S'
                                                msgid = 'F5'
                                                msgnr = '312'.

    IF sy-subrc EQ 0.
      APPEND ls_messtab TO t_log.
      " V1 - Ini - JSHANNON - 2017.10.25
      CLEAR: e_icon, gv_icon.
      PERFORM create_icon USING 3. " Verde
      e_icon = gv_icon.
      "
      MESSAGE ID ls_messtab-msgid
         TYPE ls_messtab-msgtyp
       NUMBER ls_messtab-msgnr
         INTO e_text
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      " V1 - Fin - JSHANNON - 2017.10.25
      e_exito = abap_true.
      e_doccontab = ls_messtab-msgv1.
    ELSE.
      " V1 - Ini - JSHANNON - 2017.10.25
      CLEAR: e_icon, gv_icon.
      PERFORM create_icon USING 1. " Rojo
      e_icon = gv_icon.
      " V1 - Fin - JSHANNON - 2017.10.25

      e_exito = abap_false.
      " V1 - Ini - JSHANNON - 2017.10.25
      READ TABLE messtab INTO ls_messtab WITH KEY msgtyp = 'E'.
      IF sy-subrc = 4.
        READ TABLE messtab INTO ls_messtab WITH KEY msgtyp = 'S'.
      ENDIF.
      MESSAGE ID ls_messtab-msgid
         TYPE ls_messtab-msgtyp
       NUMBER ls_messtab-msgnr
         INTO e_text
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      "LOOP AT  messtab INTO ls_messtab . "WHERE msgtyp  EQ 'E' OR
      "  "    msgtyp EQ 'C'.
      "  APPEND ls_messtab TO t_log.
      "ENDLOOP.
      " V1 - Fin - JSHANNON - 2017.10.25
    ENDIF.
    FREE messtab.
    FREE bdcdata.
  ENDMETHOD.                    "call_transaction

  METHOD display_log.
    EXIT.
    DATA: lf_obj        TYPE balobj_d,
          lf_subobj     TYPE balsubobj,
          ls_header     TYPE balhdri,
          lf_log_handle TYPE balloghndl,
          lf_log_number TYPE balognr,
          lt_msg        TYPE balmi_tab,
          ls_msg        TYPE balmi,
          lt_lognum     TYPE TABLE OF balnri,
          ls_lognum     TYPE balnri.
*
    lf_obj     = 'ZFI_LOG'.
    lf_subobj  = 'Z02'.

    ls_header-object     = lf_obj.
    ls_header-subobject  = lf_subobj.
    ls_header-aldate     = sy-datum.
    ls_header-altime     = sy-uzeit.
    ls_header-aluser     = sy-uname.
    ls_header-aldate_del = sy-datum + 1.
*

    CALL FUNCTION 'APPL_LOG_WRITE_HEADER'
      EXPORTING
        header              = ls_header
      IMPORTING
        e_log_handle        = lf_log_handle
      EXCEPTIONS
        object_not_found    = 1
        subobject_not_found = 2
        error               = 3
        OTHERS              = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL FUNCTION 'BAL_DB_LOGNUMBER_GET'
      EXPORTING
        i_client                 = sy-mandt
        i_log_handle             = lf_log_handle
      IMPORTING
        e_lognumber              = lf_log_number
      EXCEPTIONS
        log_not_found            = 1
        lognumber_already_exists = 2
        numbering_error          = 3
        OTHERS                   = 4.
*
    REFRESH lt_msg.
    LOOP AT t_log INTO ls_mess.
      CLEAR ls_msg.
      MOVE-CORRESPONDING  ls_mess TO ls_msg."MSGV1 MSGV1
      MOVE: ls_mess-msgtyp TO ls_msg-msgty,
            ls_mess-msgnr TO ls_msg-msgno.
      APPEND ls_msg TO lt_msg.
    ENDLOOP.

    CALL FUNCTION 'APPL_LOG_WRITE_MESSAGES'
      EXPORTING
        object              = lf_obj
        subobject           = lf_subobj
        log_handle          = lf_log_handle
      TABLES
        messages            = lt_msg
      EXCEPTIONS
        object_not_found    = 1
        subobject_not_found = 2
        OTHERS              = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'.
    CLEAR t_log.
    FREE t_log.
  ENDMETHOD.                    "display_log
ENDCLASS.                    "lcl_report IMPLEMENTATION


*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR ls_bdc.
  ls_bdc-program  = program.
  ls_bdc-dynpro   = dynpro.
  ls_bdc-dynbegin = 'X'.
  APPEND ls_bdc TO bdcdata.
ENDFORM.                    "BDC_DYNPRO

*----------------------------------------------------------------------*
*        Insert field                                                  *
*--------- -------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  CLEAR ls_bdc.
  ls_bdc-fnam = fnam.
  ls_bdc-fval = fval.
  APPEND ls_bdc TO bdcdata.
ENDFORM.                    "BDC_FIELD

*&---------------------------------------------------------------------*
*&      Form  Create_Icon
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->WA_OUT     text
*      -->ACCION     text
*----------------------------------------------------------------------*
FORM create_icon USING accion TYPE i.

  DATA name TYPE icon-name.
  DATA info(20).

  CASE accion.
    WHEN 1.
      name = 'ICON_LED_RED'.
      info = text-m01. " Documento no contabilizado
    WHEN 2.
      name = 'ICON_LED_YELLOW'.
      info = text-t02. " Documento Pendiente
    WHEN 3.
      name = 'ICON_LED_GREEN'.
      info = text-t03. " Documento contabilizado
  ENDCASE.

  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name                  = name
      info                  = info
      add_stdinf            = space
    IMPORTING
      RESULT                = gv_icon
    EXCEPTIONS
      icon_not_found        = 1
      outputfield_too_short = 2
      OTHERS                = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    "Create_Icon
