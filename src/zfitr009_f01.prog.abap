*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZPARTIDAS_ACREEDOR_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  select_data
*&---------------------------------------------------------------------*
* §1 to display the data, you first have to select it in some table
*----------------------------------------------------------------------*
FORM select_data.

  DATA: ti_reguh_aux LIKE STANDARD TABLE OF reguh WITH HEADER LINE,
        cont         TYPE i,
        a            LIKE sy-ucomm.

* Rescatamos Datos.
  IF p_hbkid IS INITIAL AND p_hktid IS INITIAL.
    SELECT DISTINCT
            rbetr
            rzawe
            lifnr
            empfg
            vblnr
            laufd
            laufi
            stcd1
            xvorl
            zstc1
            znme1
            zort1
            zstra
            name1
            ort01
            stras
            zbukr
            zbnkn
            zbnkl
            ubnkl
            zbkon
            absbu
            zaldt
            hbkid
            hktid
       FROM  reguh INTO CORRESPONDING FIELDS OF TABLE ti_reguh_aux
             WHERE  laufd      IN s_laufd
             AND    zbukr      = p_bukrs
             AND    xvorl      = ' '
             AND    rzawe in s_rzawe
*            AND    rzawe      = 'C'
             ORDER BY laufi  .
  ELSEIF p_hbkid IS NOT INITIAL AND p_hktid IS INITIAL.
    SELECT DISTINCT rbetr
            rzawe
            lifnr
            empfg
            vblnr
            laufd
            laufi
            stcd1
            xvorl
            zstc1
            znme1
            zort1
            zstra
            name1
            ort01
            stras
            zbukr
            zbnkn
            zbnkl
            ubnkl
            zbkon
            absbu
            zaldt
            hbkid
            hktid FROM  reguh INTO CORRESPONDING FIELDS OF TABLE ti_reguh_aux
             WHERE  laufd      IN s_laufd
             AND    zbukr      = p_bukrs
             AND    hbkid      = p_hbkid
             AND    xvorl      = ' '
             AND    rzawe in s_rzawe
*             AND    rzawe      = 'C'
             ORDER BY laufi .
  ELSEIF p_hktid IS NOT INITIAL.
    SELECT DISTINCT rbetr
            rzawe
            lifnr
            empfg
            vblnr
            laufd
            laufi
            stcd1
            xvorl
            zstc1
            znme1
            zort1
            zstra
            name1
            ort01
            stras
            zbukr
            zbnkn
            zbnkl
            ubnkl
            zbkon
            absbu
            zaldt
            hbkid
            hktid FROM  reguh INTO CORRESPONDING FIELDS OF TABLE ti_reguh_aux
             WHERE  laufd      IN s_laufd
             AND    zbukr      = p_bukrs
             AND    hbkid      EQ p_hbkid
              AND    hktid     EQ p_hktid
             AND    xvorl      = ' '
             AND    rzawe in s_rzawe
*             AND    rzawe      = 'C'
             ORDER BY laufi.
  ENDIF.
*  DELETE ADJACENT DUPLICATES FROM ti_reguh_aux COMPARING laufi.
  SORT ti_reguh_aux BY laufd laufi.
  CLEAR cont.

  REFRESH ti_reguh.
  ti_reguh[] = ti_reguh_aux[].

  LOOP AT ti_reguh_aux.

    CLEAR gs_outtab.
    MOVE-CORRESPONDING ti_reguh_aux TO gs_outtab.
    gs_outtab-estatus = 'CONTABILIZADO'.
    cont = cont + 1.
    AT END OF laufi.

      REFRESH tabla_00.
      PERFORM documentos USING gs_outtab-laufd gs_outtab-laufi.

* Procesamos Datos
      SORT tabla_00 BY rzawe lifnr empfg.   " via.pago/prov/recep.pago

      REFRESH reg_stder.

      LOOP AT tabla_00 INTO tabla_00.

        PERFORM arma_registro.

        tabla_00-rbetr = tabla_00-rbetr * 100.
        tabla_00-rbetr = ABS( tabla_00-rbetr ).

        reg_stder_aux-monto_docto = + tabla_00-rbetr.
        APPEND reg_stder_aux TO reg_stder.

      ENDLOOP.

      LOOP AT reg_stder.
        gs_outtab-monto_docto = gs_outtab-monto_docto + reg_stder-monto_docto.
      ENDLOOP.

      gs_outtab-cant = cont.
      CLEAR cont.

      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          percentage = sy-tabix
          text       = 'Procesando...'.

      APPEND gs_outtab TO gt_outtab.
    ENDAT.
  ENDLOOP.

ENDFORM.                    " select_data

*&---------------------------------------------------------------------*
*&      Form  PREPARO_SALIDA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM preparo_salida.

  DATA: rut(11)  TYPE c.
  DATA: largo(3) TYPE n.
  DATA: numero(10) TYPE n.

  REFRESH out_reg_stder.

 SORT reg_stder  BY zbukr  rut_prov .



* break carlos.
  LOOP AT reg_stder.
    AT NEW  zbukr .
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES01 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE paval INTO rut FROM t001z WHERE bukrs = reg_stder-zbukr
*                                   AND   party = 'TAXNR' .
*
* NEW CODE
      SELECT paval
      UP TO 1 ROWS  INTO rut FROM t001z WHERE bukrs = reg_stder-zbukr
                                   AND   party = 'TAXNR'  ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM t001 WHERE bukrs = reg_stder-zbukr.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM t001 WHERE bukrs = reg_stder-zbukr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      WRITE rut TO rut LEFT-JUSTIFIED.

      TRANSLATE  rut USING '- '.
      CONDENSE    rut NO-GAPS.

    ENDAT.
*    AT NEW  rut_prov .
    numero = numero + 1.
*    ENDAT.
    AT LAST.
      SUM.
      reg01-rut_emp = rut.
      reg01-num_reg = numero.
      reg01-monto_total_pago = reg_stder-monto_docto.
      reg01-tipo_servicio = '003001'.
*      IF v_resfon = 'CTACTE'.
*        reg01-fondos = 'CAT_CSH_CONTRACT_ACCOUNT'.
*      ELSE.
      reg01-fondos = 'CAT_CSH_CONTRACT_ACCOUNT'.

*      ENDIF.

*      reg01-cheque(30) = v_numche.

      CONCATENATE  '1270469,' t001-butxt INTO reg01-descripcion.


      CONCATENATE  reg01-rut_emp
                   ','
                   reg01-num_reg
                    ','
                   reg01-monto_total_pago
                    ','
                   reg01-tipo_servicio
                    ','
                   reg01-fondos
                    ','
*                   reg01-cheque
*                    ','
                   reg01-descripcion INTO out_reg_stder-reg.
      APPEND out_reg_stder.
    ENDAT.
  ENDLOOP.


  LOOP AT reg_stder.
    reg02-rut_prv = reg_stder-rut_prov.
    reg02-nombre_prv = reg_stder-nombre.
    reg02-mail = ''.

*    reg02-medio_pago = reg_stder-mod_pago .
    reg02-medio_pago = 'CAT_CSH_VIRTUAL_OFFICE_CHECK' .
    reg02-tipo_cuenta_abo = reg_stder-tipo_cta .

    reg02-cod_banco = reg_stder-codigo_banco.
*    reg02-cod_banco = '027'.
    reg02-cuenta_abo = reg_stder-cuenta_abono.
    CONCATENATE sy-datum+6(2) '/' sy-datum+4(2) '/' sy-datum+0(4) INTO reg02-fecha_pago.
    reg02-reference =''.
    reg02-referenceid =''.
    reg02-tipo_cuenta_car = 'CAT_CSH_CCTE'.
    reg02-cuenta_car = reg_stder-chect.
    IF reg_stder-codigo_banco =  027.
      reg02-sucursal = '001'.
    ELSE.
      reg02-sucursal = ''.
    ENDIF.
    reg02-ref_cliente = '1270469'.
    reg02-sucursal = '001'.
*    IF reg02-detalle_pago IS INITIAL.
*      reg02-detalle_pago = reg_stder-num_docto.
*    ELSE.
*      CONCATENATE reg02-detalle_pago '-' reg_stder-num_docto INTO reg02-detalle_pago.
*    ENDIF.
    reg02-detalle_pago = 'Pago con Cheque'.
*    AT END OF  rut_prov .
*      SUM.
    reg02-monto_pago = reg_stder-monto_docto.


    CONCATENATE
    reg02-rut_prv
                  ','
    reg02-nombre_prv
                        ','
    reg02-mail
                        ','
    reg02-medio_pago
                        ','
    reg02-cod_banco
                        ','
*      reg02-tipo_cuenta_abo
                        ','
    reg02-cuenta_abo
                        ','
*      reg02-fecha_pago
                        ','
    reg02-reference
                        ','
    reg02-referenceid
                        ','
    reg02-monto_pago
                        ','
    reg02-tipo_cuenta_car
                        ','
    reg02-ref_cliente
                        ','
    reg02-sucursal
                        ','
    reg02-cuenta_car
                        ','
    reg02-detalle_pago

      INTO out_reg_stder-reg.
    APPEND out_reg_stder.
    CLEAR reg02.
*    ENDAT.
  ENDLOOP.

ENDFORM.                    " PREPARO_SALIDA

*---------------------------------------------------------------------*
*       CLASS lcl_handle_events DEFINITION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_double_click FOR EVENT double_click OF cl_salv_events_table
        IMPORTING row column,

    on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function,

      on_link_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.                    "lcl_handle_events DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_double_click.

    DATA: bdcdata_wa  TYPE bdcdata,
          bdcdata_tab TYPE TABLE OF bdcdata.

    DATA opt TYPE ctu_params.

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES01 ECDK917080 *
SORT GT_OUTTAB .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES01 ECDK917080 *
    READ TABLE gt_outtab INTO gs_outtab INDEX row.

    CLEAR bdcdata_wa.
    bdcdata_wa-program  = 'SAPF110O'.
    bdcdata_wa-dynpro   = '100'.
    bdcdata_wa-dynbegin = 'X'.
    APPEND bdcdata_wa TO bdcdata_tab.

    CLEAR bdcdata_wa.
    bdcdata_wa-fnam = 'REGUH-LAUFD'.
    CONCATENATE gs_outtab-laufd+6(2) gs_outtab-laufd+4(2) gs_outtab-laufd(4) INTO bdcdata_wa-fval.
    APPEND bdcdata_wa TO bdcdata_tab.

    CLEAR bdcdata_wa.
    bdcdata_wa-fnam = 'REGUH-LAUFI'.
    bdcdata_wa-fval = gs_outtab-laufi.
    APPEND bdcdata_wa TO bdcdata_tab.

    CLEAR bdcdata_wa.
    bdcdata_wa-fnam = 'REGUH-ZBUKR'.
    bdcdata_wa-fval = gs_outtab-zbukr.
    APPEND bdcdata_wa TO bdcdata_tab.

    CLEAR bdcdata_wa.
    bdcdata_wa-fnam = 'REGUH-ABSBU'.
    bdcdata_wa-fval = gs_outtab-absbu.
    APPEND bdcdata_wa TO bdcdata_tab.

    opt-dismode = 'E'.
    opt-defsize = 'X'.

    CALL TRANSACTION 'FBZ0' USING bdcdata_tab OPTIONS FROM opt.

  ENDMETHOD.                    "on_double_click

  METHOD on_user_command.

* Get the selection rows
    DATA: lr_selections TYPE REF TO cl_salv_selections.
    DATA: lt_rows       TYPE salv_t_row.
    DATA: ls_rows       TYPE i.
    DATA: message       TYPE string.
    DATA: rspar_tab1    TYPE TABLE OF rsparams,
          rspar_tab2    TYPE TABLE OF rsparams,
          rspar_line    LIKE LINE OF rspar_tab1.

    lr_selections = gr_table->get_selections( ).
    lt_rows = lr_selections->get_selected_rows( ).
    REFRESH itab.
    CASE e_salv_function.

*      Se ejecuta el boton de Detalle Nomina
      WHEN 'NOM1'.
        LOOP AT lt_rows INTO ls_rows.
*ReSQ: No Need Of Change Internal Table GT_OUTTAB Already Sorted
          READ TABLE gt_outtab INTO gs_outtab INDEX ls_rows.
          APPEND gs_outtab TO itab.
        ENDLOOP.
        SORT itab BY laufd.

        rspar_line-selname = 'V_FECHA'.
        rspar_line-kind    = 'S'.
        rspar_line-sign    = 'I'.
        rspar_line-option  = 'EQ'.

        LOOP AT itab INTO gs_outtab.
          rspar_line-low      = gs_outtab-laufd.
          rspar_line-high     = gs_outtab-laufi.
          APPEND rspar_line TO rspar_tab1.
        ENDLOOP.

        CLEAR rspar_line.
        rspar_line-selname = 'V_NOMINA'.
        rspar_line-kind    = 'S'.
        rspar_line-sign    = 'I'.
        rspar_line-option  = 'EQ'.

        LOOP AT itab INTO gs_outtab WHERE estatus = 'PAGADO'.
          rspar_line-low    = gs_outtab-laufi.
          APPEND rspar_line TO rspar_tab1.
        ENDLOOP.

        SUBMIT zfipg004_varias_prop USING SELECTION-SCREEN '1100'
                       WITH SELECTION-TABLE rspar_tab1 AND RETURN.

*      Se ejecuta el boton de Resumen de Nomina
      WHEN 'NOM2'.
        LOOP AT lt_rows INTO ls_rows.
*ReSQ: No Need Of Change Internal Table GT_OUTTAB Already Sorted
          READ TABLE gt_outtab INTO gs_outtab INDEX ls_rows.
          APPEND gs_outtab TO itab.
        ENDLOOP.
        SORT itab BY laufd.

        rspar_line-selname = 'V_FECHA'.
        rspar_line-kind    = 'S'.
        rspar_line-sign    = 'I'.
        rspar_line-option  = 'EQ'.

        LOOP AT itab INTO gs_outtab.
          rspar_line-low      = gs_outtab-laufd.
          APPEND rspar_line TO rspar_tab1.
        ENDLOOP.

        CLEAR rspar_line.
        rspar_line-selname = 'V_NOMINA'.
        rspar_line-kind    = 'S'.
        rspar_line-sign    = 'I'.
        rspar_line-option  = 'EQ'.

        LOOP AT itab INTO gs_outtab WHERE estatus = 'PAGADO'..
          rspar_line-low    = gs_outtab-laufi.
          APPEND rspar_line TO rspar_tab1.
        ENDLOOP.

        SUBMIT zfipg005_varias_prop USING SELECTION-SCREEN '1100'
                       WITH SELECTION-TABLE rspar_tab1 AND RETURN.

*      Se ejecuta el boton de Generar Archivo
      WHEN 'ARCHIVO'.

        CALL FUNCTION 'F4_FILENAME'
          IMPORTING
            file_name = archivo.

        REFRESH tabla_00.
        LOOP AT lt_rows INTO ls_rows.

*ReSQ: No Need Of Change Internal Table GT_OUTTAB Already Sorted
          READ TABLE gt_outtab INTO gs_outtab INDEX ls_rows.

          PERFORM documentos USING gs_outtab-laufd
                                   gs_outtab-laufi.

        ENDLOOP.

*  *Procesamos Datos
        SORT tabla_00 BY rzawe lifnr empfg.   " via.pago/prov/recep.pago

        REFRESH reg_stder.
        LOOP AT tabla_00 INTO tabla_00.
          PERFORM arma_registro.
          tabla_00-rbetr = tabla_00-rbetr * 100.
          tabla_00-rbetr = ABS( tabla_00-rbetr ).

          reg_stder-monto_docto = + tabla_00-rbetr.
          APPEND reg_stder TO reg_stder.

        ENDLOOP.

        DESCRIBE TABLE tabla_00 LINES lins.
        IF lins <> 0.
          PERFORM preparo_salida.
          PERFORM bajar_archivo.
        ELSE.
          WRITE : /,/, 'No Existe Informacion Para Procesar....!!!!!!!!'.

        ENDIF.

    ENDCASE.

  ENDMETHOD.                    "on_user_command

  METHOD on_link_click.

*    READ TABLE gt_outtab INTO gr_outtab INDEX row.
*    SET PARAMETER ID: 'BLN' FIELD gr_outtab-belnr,
*                      'BUK' FIELD gr_outtab-bukrs,
*                      'GJR' FIELD gr_outtab-gjahr.
*
*    CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

    DATA: bdcdata_wa  TYPE bdcdata,
          bdcdata_tab TYPE TABLE OF bdcdata.

    DATA opt TYPE ctu_params.

*ReSQ: No Need Of Change Internal Table GT_OUTTAB Already Sorted
    READ TABLE gt_outtab INTO gs_outtab INDEX row.

    CASE column.
      WHEN 'LAUFD'.
        CLEAR bdcdata_wa.
        bdcdata_wa-program  = 'SAPF110O'.
        bdcdata_wa-dynpro   = '100'.
        bdcdata_wa-dynbegin = 'X'.
        APPEND bdcdata_wa TO bdcdata_tab.

        CLEAR bdcdata_wa.
        bdcdata_wa-fnam = 'REGUH-LAUFD'.
        CONCATENATE gs_outtab-laufd+6(2) gs_outtab-laufd+4(2) gs_outtab-laufd(4) INTO bdcdata_wa-fval.
        APPEND bdcdata_wa TO bdcdata_tab.

        CLEAR bdcdata_wa.
        bdcdata_wa-fnam = 'REGUH-LAUFI'.
        bdcdata_wa-fval = gs_outtab-laufi.
        APPEND bdcdata_wa TO bdcdata_tab.

        CLEAR bdcdata_wa.
        bdcdata_wa-fnam = 'REGUH-ZBUKR'.
        bdcdata_wa-fval = gs_outtab-zbukr.
        APPEND bdcdata_wa TO bdcdata_tab.

        CLEAR bdcdata_wa.
        bdcdata_wa-fnam = 'REGUH-ABSBU'.
        bdcdata_wa-fval = gs_outtab-absbu.
        APPEND bdcdata_wa TO bdcdata_tab.

        opt-dismode = 'E'.
        opt-defsize = 'X'.

        CALL TRANSACTION 'FBZ0' USING bdcdata_tab OPTIONS FROM opt.

      WHEN 'HBKID'.
        CLEAR r_rzawe[].
        CLEAR r_hktid[].
        CLEAR r_hbkid[].
        CLEAR r_zbukr[].

        IF gs_outtab-estatus EQ 'PAGADO'.
          CLEAR bdcdata_wa.
          bdcdata_wa-program  = 'RFCHKN10'.
          bdcdata_wa-dynpro   = '1000'.
          bdcdata_wa-dynbegin = 'X'.
          APPEND bdcdata_wa TO bdcdata_tab.

          CLEAR bdcdata_wa.
          bdcdata_wa-fnam = 'SEL_ZBUK-LOW'.
          bdcdata_wa-fval = gs_outtab-zbukr.
          APPEND bdcdata_wa TO bdcdata_tab.

          CLEAR bdcdata_wa.
          bdcdata_wa-fnam = 'SEL_HBKI-LOW'.
          bdcdata_wa-fval = gs_outtab-hbkid.
          APPEND bdcdata_wa TO bdcdata_tab.

          CLEAR bdcdata_wa.
          bdcdata_wa-fnam = 'SEL_HKTI-LOW'.
          bdcdata_wa-fval = gs_outtab-hktid.
          APPEND bdcdata_wa TO bdcdata_tab.

          CLEAR bdcdata_wa.
          bdcdata_wa-fnam = 'BDC_OKCODE'.
          bdcdata_wa-fval = '=ONLI'.
          APPEND bdcdata_wa TO bdcdata_tab.

          opt-dismode = 'E'.
          opt-defsize = 'X'.

*          CALL TRANSACTION 'FCHN' USING bdcdata_tab OPTIONS FROM opt .

          r_zbukr-option = 'EQ'.
          r_zbukr-sign   = 'I'.
          r_zbukr-low    = gs_outtab-zbukr.
          APPEND r_zbukr TO r_zbukr.

          r_hbkid-option = 'EQ'.
          r_hbkid-sign   = 'I'.
          r_hbkid-low    = gs_outtab-hbkid.
          APPEND r_hbkid TO r_hbkid.

          r_hktid-option = 'EQ'.
          r_hktid-sign   = 'I'.
          r_hktid-low    = gs_outtab-hktid.
          APPEND r_hktid TO r_hktid.

          SUBMIT rfchkn10 USING SELECTION-SCREEN '1000'
                           WITH sel_zbuk  IN r_zbukr
                           WITH sel_hbki  IN r_hbkid
                           WITH sel_hkti  IN r_hktid AND RETURN.

        ELSE.
          MESSAGE 'Propuesta No Pagada' TYPE 'W'.
        ENDIF.
      WHEN 'CANT'.

        IF gs_outtab-estatus EQ 'PAGADO'.

          CLEAR r_rzawe[].
          CLEAR r_hktid[].
          CLEAR r_hbkid[].
          CLEAR r_zbukr[].


          CLEAR bdcdata_wa.
          bdcdata_wa-program  = 'RFCHKN10'.
          bdcdata_wa-dynpro   = '1000'.
          bdcdata_wa-dynbegin = 'X'.
          APPEND bdcdata_wa TO bdcdata_tab.

          CLEAR bdcdata_wa.
          bdcdata_wa-fnam = 'SEL_ZBUK-LOW'.
          bdcdata_wa-fval = gs_outtab-zbukr.
          APPEND bdcdata_wa TO bdcdata_tab.

          CLEAR bdcdata_wa.
          bdcdata_wa-fnam = 'SEL_HBKI-LOW'.
          bdcdata_wa-fval = gs_outtab-hbkid.
          APPEND bdcdata_wa TO bdcdata_tab.

          CLEAR bdcdata_wa.
          bdcdata_wa-fnam = 'SEL_HKTI-LOW'.
          bdcdata_wa-fval = gs_outtab-hktid.
          APPEND bdcdata_wa TO bdcdata_tab.

          CLEAR bdcdata_wa.
          bdcdata_wa-fnam = 'BDC_OKCODE'.
          bdcdata_wa-fval = '=UCOMM2'.
          APPEND bdcdata_wa TO bdcdata_tab.

          CLEAR bdcdata_wa.
*          bdcdata_wa-program  = 'RFCHKN10                                0002%_SUBSCREEN_CHK'.
          bdcdata_wa-program  = 'RFCHKN10'."                                0002%_SUBSCREEN_CHK'.
          bdcdata_wa-dynpro   = '1000'.
          bdcdata_wa-dynbegin = 'X'.
          APPEND bdcdata_wa TO bdcdata_tab.

          CLEAR bdcdata_wa.
          bdcdata_wa-fnam = 'SEL_ZAWE-LOW'.
          bdcdata_wa-fval = 'C'.
          APPEND bdcdata_wa TO bdcdata_tab.

          CLEAR bdcdata_wa.
          bdcdata_wa-fnam = 'ZW_LAUFD'.
          CONCATENATE gs_outtab-laufd+6 gs_outtab-laufd+4(2) gs_outtab-laufd(4) INTO bdcdata_wa-fval.
          APPEND bdcdata_wa TO bdcdata_tab.

          CLEAR bdcdata_wa.
          bdcdata_wa-fnam = 'ZW_LAUFI'.
          bdcdata_wa-fval = gs_outtab-laufi.
          APPEND bdcdata_wa TO bdcdata_tab.

          CLEAR bdcdata_wa.
          bdcdata_wa-fnam = 'BDC_OKCODE'.
          bdcdata_wa-fval = '=ONLI'.
          APPEND bdcdata_wa TO bdcdata_tab.

          opt-dismode = 'E'.
          opt-defsize = 'X'.

*          CALL TRANSACTION 'FCHN' USING bdcdata_tab OPTIONS FROM opt.
          r_zbukr-option = 'EQ'.
          r_zbukr-sign   = 'I'.
          r_zbukr-low    = gs_outtab-zbukr.
          APPEND r_zbukr TO r_zbukr.

          r_hbkid-option = 'EQ'.
          r_hbkid-sign   = 'I'.
          r_hbkid-low    = gs_outtab-hbkid.
          APPEND r_hbkid TO r_hbkid.

          r_hktid-option = 'EQ'.
          r_hktid-sign   = 'I'.
          r_hktid-low    = gs_outtab-hktid.
          APPEND r_hktid TO r_hktid.


          r_rzawe-option = 'EQ'.
          r_rzawe-sign   = 'I'.
          r_rzawe-low    = 'C'.
          APPEND r_rzawe TO r_rzawe.

          CONCATENATE gs_outtab-laufd+6 gs_outtab-laufd+4(2) gs_outtab-laufd(4) INTO zw_laufd.

          SUBMIT rfchkn10 USING SELECTION-SCREEN '1000'
                           WITH sel_zbuk  IN r_zbukr
                           WITH sel_hbki  IN r_hbkid
                           WITH sel_hkti  IN r_hktid
                           WITH sel_zawe  IN r_rzawe
                           WITH zw_laufd  EQ gs_outtab-laufd
                           WITH zw_laufi  EQ gs_outtab-laufi AND RETURN.



        ELSE.
          MESSAGE 'Propuesta No Pagada' TYPE 'W'.
        ENDIF.
    ENDCASE.


  ENDMETHOD. "on_link_click

ENDCLASS.                    "lcl_handle_events IMPLEMENTATION


*&---------------------------------------------------------------------*
*&      Form  documentos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_LAUFD    text
*      -->I_LAUFI    text
*----------------------------------------------------------------------*
FORM documentos USING i_laufd i_laufi.

*           Rescatamos Datos.
*  SELECT    rbetr
*            rzawe
*            lifnr
*            empfg
*            vblnr
*            laufd
*            laufi
*            stcd1
*            xvorl
*            zstc1
*            znme1
*            zort1
*            zstra
*            name1
*            ort01
*            stras
*            zbukr
*            zbnkn
*            zbnkl
*            ubnkl
*            zbkon
*            absbu
*            zaldt
*            hbkid
*            hktid  FROM  reguh INTO CORRESPONDING FIELDS OF TABLE ti_reguh
*           WHERE  laufd      = i_laufd
*           AND    laufi      = i_laufi
*           AND    xvorl      = ' '
**                   AND    ubnkl      = '027'
*           AND  ( rzawe      = 'C' ). " OR rzawe = 'V' ).
*
*  IF sy-subrc = 0.
  LOOP AT ti_reguh INTO ti_reguh
    WHERE       laufd = i_laufd
         AND    laufi      = i_laufi
         AND    xvorl      = ' '
         AND  ( rzawe      IN  s_rzawe ).
*         AND  ( rzawe      = 'C' ).
    IF ( reguh-stcd1 IS INITIAL ) OR ( reguh-zstc1 IS INITIAL ).
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE stcd1 INTO reguh-stcd1
*        FROM lfa1 WHERE lifnr = ti_reguh-lifnr.
*
* NEW CODE
      SELECT stcd1
      UP TO 1 ROWS  INTO reguh-stcd1
        FROM lfa1 WHERE lifnr = ti_reguh-lifnr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    ENDIF.


    IF ( NOT reguh-stcd1 IS INITIAL ) OR ( NOT reguh-zstc1 IS INITIAL ).
      MOVE-CORRESPONDING ti_reguh TO tabla_00.

*  * revisamos si paga a un beneficiario alternativo
      IF tabla_00-stcd1 <> tabla_00-zstc1.
        tabla_00-stcd1 = tabla_00-zstc1.
        tabla_00-name1 = tabla_00-znme1.
        tabla_00-ort01 = tabla_00-zort1.
        tabla_00-stras = tabla_00-zstra.
      ENDIF.

      APPEND tabla_00 TO tabla_00.
    ENDIF.
  ENDLOOP.

*  ENDIF.
ENDFORM.                    "documentos

*&---------------------------------------------------------------------*
*&      Form  bajar_archivo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM bajar_archivo.
*-----------------*
  DATA : nombre_a  TYPE string.
  nombre_a = archivo.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = nombre_a
      filetype                = 'ASC'
      confirm_overwrite       = 'X'
    TABLES
      data_tab                = out_reg_stder
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



  IF sy-subrc <> 0.
    WRITE :/ 'error!!!!'  ,
           /  sy-msgv1 ,
           /  sy-msgv2 ,
           /  sy-msgv3 ,
           /  sy-msgv4 .

  ELSE.
    SKIP 2 .
    FORMAT COLOR 3 ON.
    WRITE : / 'Se genero archivo :', archivo.
    FORMAT COLOR 3 OFF.
  ENDIF.
*----------------------------------------------
ENDFORM.                    "bajar_archivo
*&---------------------------------------------------------------------*
*&      Form  display_fullscreen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_fullscreen .


*... §2 create an ALV table
*    §2.2 just create an instance and do not set LIST_DISPLAY for
*         displaying the data as a Fullscreen Grid
  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = gr_table
        CHANGING
          t_table      = gt_outtab ).
    CATCH cx_salv_msg.                                  "#EC NO_HANDLER
  ENDTRY.

*... §3 Functions
*... §3.1 activate ALV generic Functions
  DATA: lr_functions TYPE REF TO cl_salv_functions_list.

  DATA: lo_header  TYPE REF TO cl_salv_form_layout_grid,
      lo_h_label   TYPE REF TO cl_salv_form_label,
      lo_h_flow    TYPE REF TO cl_salv_form_layout_flow,
      gr_layout    TYPE REF TO cl_salv_layout,
      key          TYPE salv_s_layout_key,
      l_text       TYPE string,
      lr_columns   TYPE REF TO cl_salv_columns,
      lr_events    TYPE REF TO cl_salv_events_table,
      g_selections TYPE REF TO cl_salv_selections,
      g_display    TYPE REF TO cl_salv_display_settings,
      v_linea      TYPE i,
      v_fech_aux   TYPE string,
      lr_column TYPE REF TO cl_salv_column_table.

*   To create a Lable or Flow we have to specify the target
*     row and column number where we need to set up the output
*     text.
*   header object
  CREATE OBJECT lo_header.
*   information in Bold
  CONCATENATE g_address_value-name1 ''
    INTO l_text SEPARATED BY space.
  lo_h_label = lo_header->create_label( row = 1 column = 1 ).
  lo_h_label->set_text( l_text ).

*   information in tabular format
  lo_h_flow = lo_header->create_flow( row = 3  column = 1 ).
  lo_h_flow->create_text( text = 'Fecha:' ).

  CONCATENATE sy-datum+6 sy-datum+4(2) sy-datum(4) INTO l_text SEPARATED BY '/'.
  CONDENSE l_text.
  lo_h_flow = lo_header->create_flow( row = 3  column = 2 ).
  lo_h_flow->create_text( text = l_text ).

  lo_h_flow = lo_header->create_flow( row = 4  column = 1 ).
  lo_h_flow->create_text( text = 'Hora:' ).

  CONCATENATE sy-timlo(2) sy-timlo+2(2) sy-timlo+4(2) INTO l_text SEPARATED BY ':'.
  CONDENSE l_text.
  lo_h_flow = lo_header->create_flow( row = 4  column = 2 ).
  lo_h_flow->create_text( text = l_text ).

  lo_h_flow = lo_header->create_flow( row = 5  column = 1 ).
  lo_h_flow->create_text( text = 'Registros:' ).

  DESCRIBE TABLE gt_outtab LINES l_text.
  CONDENSE l_text.
  lo_h_flow = lo_header->create_flow( row = 5  column = 2 ).
  lo_h_flow->create_text( text = l_text ).

  lo_h_flow = lo_header->create_flow( row = 6  column = 1 ).
  lo_h_flow->create_text( text = 'Fecha Ejecución:' ).

  LOOP AT s_laufd.
    CONCATENATE s_laufd-low+6 '/' s_laufd-low+4(2) '/' s_laufd-low(4) INTO l_text.
    IF s_laufd-high IS NOT INITIAL.
      CONCATENATE s_laufd-high+6 '/' s_laufd-high+4(2) '/' s_laufd-high(4) INTO v_fech_aux.
      CONCATENATE l_text '-' v_fech_aux INTO l_text SEPARATED BY space.
    ENDIF.
    v_linea = sy-tabix + 5.
    CONDENSE l_text.
    lo_h_flow = lo_header->create_flow( row = v_linea  column = 2 ).
    lo_h_flow->create_text( text = l_text ).
  ENDLOOP.

  gr_table->set_top_of_list( lo_header ).

*  lr_functions = gr_table->get_functions( ).
*  lr_functions->set_all( abap_true ).

*... set the columns technical

  lr_columns = gr_table->get_columns( ).
*  lr_columns->set_optimize( abap_true ).

  lr_events = gr_table->get_event( ).
  CREATE OBJECT gr_handle_events.
*  SET HANDLER gr_handle_events->on_double_click FOR lr_events.
  SET HANDLER gr_handle_events->on_user_command FOR lr_events.
  SET HANDLER gr_handle_events->on_link_click   FOR lr_events.

  g_display = gr_table->get_display_settings( ).
  g_display->set_striped_pattern( cl_salv_display_settings=>true ).

*------------------------*
* Making ALV Interactive.
*------------------------*
  gr_table->set_screen_status(
              pfstatus      =  'SALV_TABLE_STANDARD'
              report        =  sy-repid
              set_functions = gr_table->c_functions_all ).

  gr_layout = gr_table->get_layout( ).
  key-report = sy-repid.
  gr_layout->set_key( key ).

  gr_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).

  g_selections = gr_table->get_selections(  ).
  g_selections->set_selection_mode( 2 ).

  TRY.
      lr_column ?= lr_columns->get_column( 'LAUFD' ). "<- columna objetivo
      lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).

      lr_column ?= lr_columns->get_column( 'HBKID' ). "<- columna objetivo
      lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).

      lr_column ?= lr_columns->get_column( 'CANT' ). "<- columna objetivo
      lr_column->set_cell_type( if_salv_c_cell_type=>hotspot ).

    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  PERFORM set_columns_technical USING lr_columns.

*... §4 display the table
  gr_table->display( ).

ENDFORM.                    " display_fullscreen


*&---------------------------------------------------------------------*
*&      Form  set_columns_technical
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_columns_technical USING ir_columns TYPE REF TO cl_salv_columns.

  DATA: lr_column TYPE REF TO cl_salv_column.

  TRY.
      lr_column = ir_columns->get_column( 'MANDT' ).
      lr_column->set_technical( if_salv_c_bool_sap=>true ).
    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.

  TRY.
      lr_column = ir_columns->get_column( 'ZBUKR' ).
      lr_column->set_short_text( 'Soc.' ).
      lr_column->set_medium_text( 'Sociedad' ).
      lr_column->set_optimized( 'X' ).
      lr_column->set_output_length( 10 ).

      lr_column = ir_columns->get_column( 'LAUFD' ).
      lr_column->set_optimized( 'X' ).
      lr_column->set_output_length( 15 ).

      lr_column = ir_columns->get_column( 'LAUFI' ).
      lr_column->set_optimized( 'X' ).
      lr_column->set_output_length( 15 ).

      lr_column = ir_columns->get_column( 'HBKID' ).
      lr_column->set_short_text( 'Banco' ).
      lr_column->set_medium_text( 'Banco' ).
      lr_column->set_long_text( 'Banco' ).
      lr_column->set_optimized( 'X' ).
      lr_column->set_output_length( 15 ).

      lr_column = ir_columns->get_column( 'HKTID' ).
      lr_column->set_optimized( 'X' ).
      lr_column->set_output_length( 15 ).

      lr_column = ir_columns->get_column( 'MONTO_DOCTO' ).
      lr_column->set_short_text( 'Monto' ).
      lr_column->set_optimized( 'X' ).
      lr_column->set_output_length( 15 ).

      lr_column = ir_columns->get_column( 'CANT' ).
      lr_column->set_short_text( 'C. Pagos' ).
      lr_column->set_medium_text( 'Cantidad de Pagos' ).
      lr_column->set_optimized( 'X' ).
      lr_column->set_output_length( 15 ).

      lr_column = ir_columns->get_column( 'ABSBU' ).
      lr_column->set_visible( abap_false ).

      lr_column = ir_columns->get_column( 'ESTATUS' ).
      lr_column->set_short_text( 'Estado' ).
      lr_column->set_medium_text( 'Estado' ).
      lr_column->set_optimized( 'X' ).
      lr_column->set_output_length( 14 ).

    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
  ENDTRY.


ENDFORM.                    " set_columns_technical(

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
  DATA : l_adrnr TYPE adrnr,
         l_address_selection TYPE addr1_sel,
         l_zgiro TYPE zfigiro.

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

ENDFORM.                    "get_description_bu

*&---------------------------------------------------------------------*
*&      Form  arma_registro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM arma_registro.
*--------------------*
  CLEAR   : reg_stder, t_items, reg_stder_aux.
  REFRESH : t_doctos, t_doctos[], t_items[].

  reg_stder-zbukr = tabla_00-zbukr.

  TRANSLATE tabla_00-stcd1 USING '- ' .
  CONDENSE  tabla_00-stcd1 NO-GAPS    .

* Se ajusta Rut a la Izquierda.
  WRITE tabla_00-stcd1 TO reg_stder-rut_prov LEFT-JUSTIFIED.

  TRANSLATE   tabla_00-zbnkn USING '- '.
  CONDENSE    tabla_00-zbnkn NO-GAPS.
  CONDENSE    tabla_00-zbnkl NO-GAPS.

  reg_stder-nombre           =  tabla_00-znme1.
  reg_stder-codigo_banco     =  tabla_00-ubnkl.
  reg_stder-cuenta_abono     =  tabla_00-zbnkn.

  CLEAR reg_stder-tipo_cta.

  reg_stder-mod_pago  = 'CAT_CSH_TRANSFER'.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE clave INTO p_clave
*                FROM zfitr001
*                WHERE   bankl = '027'
*                AND     bkont = tabla_00-zbkon.
*
* NEW CODE
  SELECT clave
  UP TO 1 ROWS  INTO p_clave
                FROM zfitr001
                WHERE   bankl = '027'
                AND     bkont = tabla_00-zbkon ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc EQ 0.
    CONDENSE p_clave NO-GAPS.
    reg_stder-tipo_cta = p_clave.
  ENDIF.
  IF reg_stder-tipo_cta IS INITIAL.
    reg_stder-tipo_cta = 'CAT_CSH_CCTE'.
  ENDIF.

  acreedor = tabla_00-lifnr.

****Es multisociedad?

  IF tabla_00-zbukr <> tabla_00-absbu.  " Soc_pagadora y Soc.emisora
*** buscamos ejercicio del docto de pago
*    SELECT SINGLE * FROM  bseg
*                    WHERE bukrs   = tabla_00-zbukr
*                    AND   belnr   = tabla_00-vblnr
*                    AND   zfbdt   = tabla_00-zaldt
*                    AND   koart   = 'K'.
*
*    IF sy-subrc = 0.
*      eje_pago = bseg-gjahr.
*    ENDIF.
*
*
******
*    SELECT SINGLE * FROM  bkpf
*           WHERE  bukrs  = tabla_00-zbukr
*           AND    belnr  = tabla_00-vblnr
*           AND    gjahr  = eje_pago.
*
*    CALL FUNCTION 'GET_CLEARED_ITEMS'
*      EXPORTING
*        i_belnr                = tabla_00-vblnr  " doc depago
*        i_bukrs                = tabla_00-zbukr  " soc pagadora
*        i_gjahr                = bkpf-gjahr
*        i_bvorg                = bkpf-bvorg
*      TABLES
*        t_items                = t_items
*      EXCEPTIONS
*        not_found              = 1
*        error_cleared_accounts = 2
*        OTHERS                 = 3.
*
*    IF sy-subrc <> 0.
*
*    ENDIF.
*
*    LOOP AT t_items.
*      IF t_items-augbl = t_items-belnr.
*        DELETE  t_items INDEX sy-tabix.
*      ELSE.
*        soc_pago = t_items-bukrs.
*        doc_pago = t_items-augbl.
*        PERFORM paga_sociedad.
*      ENDIF.
*    ENDLOOP.

  ELSE.

*** buscamos ejercicio del docto de pago
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES01 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE gjahr FROM  bseg INTO eje_pago
*              WHERE   bukrs   = tabla_00-zbukr
*              AND     belnr   = tabla_00-vblnr
*              AND     zfbdt   = tabla_00-zaldt              " ff 150306
*              AND     koart   = 'K'.
*
* NEW CODE
    SELECT gjahr
    UP TO 1 ROWS  FROM  bseg INTO eje_pago
              WHERE   bukrs   = tabla_00-zbukr
              AND     belnr   = tabla_00-vblnr
              AND     zfbdt   = tabla_00-zaldt              " ff 150306
              AND     koart   = 'K' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  ENDIF.

*  CLEAR: gs_outtab-hbkid, gs_outtab-hktid. -- 5 modificado abril 2011
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE chect hbkid hktid FROM  payr INTO (reg_stder-chect, gs_outtab-hbkid, gs_outtab-hktid)
*  WHERE  zbukr  = tabla_00-zbukr AND
**         rzawe  = 'C' AND
*         laufd  = tabla_00-laufd AND
*         laufi  = tabla_00-laufi AND
*         vblnr  = tabla_00-vblnr AND
*         hktid  = tabla_00-hktid AND
*         hbkid  = tabla_00-hbkid .
*
* NEW CODE
  SELECT chect hbkid hktid
  UP TO 1 ROWS  FROM  payr INTO (reg_stder-chect, gs_outtab-hbkid, gs_outtab-hktid)
  WHERE  zbukr  = tabla_00-zbukr AND
*         rzawe  = 'C' AND
         laufd  = tabla_00-laufd AND
         laufi  = tabla_00-laufi AND
         vblnr  = tabla_00-vblnr AND
         hktid  = tabla_00-hktid AND
         hbkid  = tabla_00-hbkid  ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc = 0.
    gs_outtab-estatus = 'PAGADO'.
  ENDIF.

****

ENDFORM.                    "arma_registro

*&---------------------------------------------------------------------*
*&      Form  paga_sociedad
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM paga_sociedad.
*-----------------*

*  SELECT  * FROM bsak CLIENT SPECIFIED
*          WHERE mandt   = sy-mandt
*            AND  bukrs  = soc_pago    " soc.pagadora
*            AND  augbl  = doc_pago    " Núm. doc.
*            AND  lifnr  = acreedor
*            AND  auggj  = eje_pago.   " ff 02.03.06
*
*    CHECK bsak-augbl <>  bsak-belnr.
*    MOVE-CORRESPONDING bsak TO t_doctos.
*
*    SELECT SINGLE chect FROM  payr INTO t_doctos-chect
*      WHERE  zbukr  = bsak-bukrs AND
*             vblnr  = bsak-augbl AND
*             gjahr  = bsak-auggj.
*
*    APPEND t_doctos.
*  ENDSELECT.
*
*  PERFORM distribucion.

ENDFORM.                    "paga_sociedad


*&---------------------------------------------------------------------*
*&      Form  distribucion
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM distribucion.
*----------------*
*  DATA cont TYPE i.
*
*  SORT t_doctos BY dmbtr.
*
*  LOOP AT t_doctos.
**invertimos los signos para que el giro quede positivo !!!!!
*    IF t_doctos-shkzg = 'S'.    "Invertimos los signos.....
*      t_doctos-dmbtr = t_doctos-dmbtr * -1.
*    ENDIF.
*    t_doctos-dmbtr = t_doctos-dmbtr * 100.
*    t_doctos-dmbtr = ABS( t_doctos-dmbtr ).
*
*    SELECT SINGLE * FROM  bkpf
*         WHERE  bukrs  = t_doctos-bukrs
*         AND    belnr  = t_doctos-belnr
*         AND    gjahr  = t_doctos-gjahr.
*
*    IF sy-subrc = 0 AND bkpf-xblnr IS NOT INITIAL.
*      CONDENSE bkpf-xblnr NO-GAPS.
*      num_doc = bkpf-xblnr.
*    ENDIF.
*    reg_stder-num_docto      = num_doc.
*    IF t_doctos-shkzg = 'S'.
*      t_doctos-dmbtr =   t_doctos-dmbtr * -1.
*      reg_stder-signo_docto   = '-'.
*    ELSE.
*      reg_stder-signo_docto  = '+'.
*    ENDIF.
*    reg_stder-monto_docto   = t_doctos-dmbtr.
*    reg_stder-chect = t_doctos-chect.
*    APPEND reg_stder.
*  ENDLOOP.
*
*  CLEAR: reg_stder_aux, reg_stder, cont.
*  LOOP AT reg_stder WHERE chect = t_doctos-chect.
*    IF cont IS INITIAL.
*      MOVE-CORRESPONDING reg_stder TO reg_stder_aux.
*      reg_stder_aux-monto_docto = 0.
*      cont = + 1.
*    ENDIF.
*    reg_stder_aux-monto_docto = reg_stder_aux-monto_docto + reg_stder-monto_docto.
*  ENDLOOP.
*
*  DELETE reg_stder WHERE chect = reg_stder_aux-chect.
*
*  APPEND reg_stder_aux TO reg_stder.

ENDFORM.                               " LLENA_ESTRUCTURA
*&---------------------------------------------------------------------*
*&      Module  MODULE_MATCH1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM module_match1.
  DATA:  dyfields LIKE dynpread OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF list_of_fields1 OCCURS 10,
  fieldname LIKE dd03l-fieldname,
  END OF list_of_fields1.

  DATA : indice1 LIKE sy-tabix,
  fieldname1 LIKE dd03l-fieldname,
  fields1 LIKE help_value OCCURS 10 WITH HEADER LINE,
  shrinkfields1 LIKE dynpread OCCURS 0 WITH HEADER LINE,
  dynpfields1 LIKE dynpread OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF ti_cta_cte OCCURS 0,
  bukrs LIKE t012k-bukrs,
  hbkid LIKE t012k-hbkid,
  hktid LIKE t012k-hktid,
  END OF ti_cta_cte.

  REFRESH: dyfields, list_of_fields1,fields1, shrinkfields1,dynpfields1.

  dyfields-fieldname = 'P_BUKRS'.
  APPEND dyfields.
  dyfields-fieldname = 'P_HBKID'.
  APPEND dyfields.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = sy-cprog
      dynumb     = sy-dynnr
    TABLES
      dynpfields = dyfields.

  IF sy-subrc = 0.
    READ TABLE dyfields WITH KEY fieldname = 'P_BUKRS'.
    IF sy-subrc EQ 0.
      p_bukrs = dyfields-fieldvalue.
    ENDIF.
    READ TABLE dyfields WITH KEY fieldname = 'P_HBKID'.
    IF sy-subrc EQ 0.
      p_hbkid = dyfields-fieldvalue.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = dyfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.
  IF sy-subrc <> 0.
  ENDIF.

* FCV - 21.04.2010
  TRANSLATE p_bukrs TO UPPER CASE.
  TRANSLATE p_hbkid TO UPPER CASE.
* fin FCV - 21.04.2010
**mod ini
  SELECT bukrs hbkid hktid
    INTO CORRESPONDING FIELDS OF TABLE ti_cta_cte
    FROM t012k
    WHERE bukrs EQ p_bukrs
      AND hbkid EQ p_hbkid
    ORDER BY bukrs hbkid hktid.
**mod fin
  list_of_fields1-fieldname = 'T012K-BUKRS'.
  APPEND list_of_fields1.
  list_of_fields1-fieldname = 'T012K-HBKID'.
  APPEND list_of_fields1.
  list_of_fields1-fieldname = 'T012K-HKTID'.
  APPEND list_of_fields1.

  fieldname1 = 'HKTID'.

  CALL FUNCTION 'TRANSFER_NAMES_TO_FIELDS'
    EXPORTING
      selectfield        = fieldname1
    TABLES
      fields             = fields1
      namelist           = list_of_fields1
    EXCEPTIONS
      wrong_format_given = 01.


  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      selectfield                  = fieldname1
      titel                        = 'Cuenta Corriente'
      use_user_selections          = 'S'
    IMPORTING
      ind                          = indice1
    TABLES
      fields                       = fields1
      full_table                   = ti_cta_cte
      user_sel_fields              = shrinkfields1
    EXCEPTIONS
      full_table_empty             = 01
      no_tablestructure_given      = 02
      no_tablefields_in_dictionary = 03
      more_than_one_selectfield    = 04
      no_electfield                = 05.
  IF sy-subrc = 0.
    READ TABLE ti_cta_cte INDEX indice1.
    MOVE ti_cta_cte-hktid TO p_hktid.

    SET PARAMETER ID '01' FIELD  ti_cta_cte-bukrs.
    SET PARAMETER ID '02' FIELD  ti_cta_cte-hbkid.
    SET PARAMETER ID '03' FIELD  ti_cta_cte-hktid.
  ENDIF.
ENDFORM. " MODULE_MATCH1  INPUT
