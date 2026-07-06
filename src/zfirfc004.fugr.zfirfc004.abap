FUNCTION zfirfc004.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  TABLES
*"      TI_CABECERA STRUCTURE  ZCABECERA_ME
*"      TI_DETALLE STRUCTURE  ZDETALLE_ME_CT
*"      TI_TLOGCABERR STRUCTURE  ZTLOGCABERR
*"      TI_TLOGDETERR STRUCTURE  ZTLOGDETERR
*"      TI_RESUMEN STRUCTURE  ZRESUMEN
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& Function module: ZFIRFC004_CT                                                             *
*& Author: Waldo Alarcón / Carlos Nievas                                               *
*& Description: Se copia la función ZFIRFC004 para permitir la contabi-
*&              lización con 5 decimales.
*&              Este módulo de funciones es llamado desde PO
*& Date: 01-03-2023
*& Transport Number: ECDK923606
*&---------------------------------------------------------------------*

  DATA: ls_cont_det TYPE gty_cont_det_ct,
        ls_det_iva  TYPE gty_cont_det_ct,
        ls_lfbw     TYPE gty_lfbw.

  DATA: lt_lfbw TYPE gtt_lfbw.

  DATA: lv_index    TYPE sytabix,
        lv_cont_reg TYPE i,
        lv_contador TYPE n LENGTH 3.

  DATA  iv_msg_err  TYPE bapi_msg.

* Variables para el control de totales por documento.
  DATA: lv_wrbtr_tot TYPE decfloat34,
        lv_dmbtr_tot TYPE decfloat34.
  DATA: lv_wrbtr TYPE decfloat34,
        lv_dmbtr TYPE decfloat34.

* Limpia tablas internas.
  PERFORM limpia_tablas.

* Validación  datos de cabecera y posición
** 1
  LOOP AT  ti_cabecera.
    CLEAR: return.
    CLEAR lv_wrbtr_tot.
    CLEAR lv_dmbtr_tot.

    PERFORM val_cab TABLES return
                    USING ti_cabecera
                    CHANGING t_error.
    IF t_error = 0.
      SORT ti_cont_cab.
      LOOP AT ti_detalle WHERE zkey EQ ti_cabecera-zkey.
        CLEAR: return.
        PERFORM val_detalle_ct TABLES   return
                               USING    ti_detalle
                                        ti_cabecera
                               CHANGING t_error.
        IF t_error = 0.
          MOVE-CORRESPONDING ti_cabecera TO ti_cont_cab.
          READ TABLE ti_cont_cab WITH KEY zkey =  ti_cabecera-zkey.
          lv_index = sy-tabix.
          IF sy-subrc NE 0.
            APPEND ti_cont_cab.
          ELSE.
            MODIFY ti_cont_cab INDEX lv_index.
          ENDIF.
          MOVE-CORRESPONDING ti_detalle TO ti_cont_det_ct.
          APPEND ti_cont_det_ct.
        ELSE.
          MOVE-CORRESPONDING ti_detalle TO ti_error_det_ct.
          APPEND ti_error_det_ct.
          CLEAR: ti_error_det_ct.
        ENDIF.

*       Totaliza para validar cuadratura de comporobante
        MOVE ti_detalle-amt_doccur TO lv_dmbtr.
        MOVE ti_detalle-amt_doccur_me TO lv_wrbtr.

        ADD lv_dmbtr TO lv_dmbtr_tot.
        ADD lv_wrbtr TO lv_wrbtr_tot.
      ENDLOOP.
    ELSE.
      MOVE-CORRESPONDING  ti_cabecera TO ti_error_cab.
      APPEND ti_error_cab.
      CLEAR: ti_error_cab.
    ENDIF.

    PERFORM val_tot TABLES return
                    USING ti_cabecera
                          ti_detalle-currency
                          lv_dmbtr_tot
                          ti_detalle-currency_me
                          lv_wrbtr_tot
                    CHANGING t_error.
    IF t_error <> 0.

      MOVE-CORRESPONDING  ti_cabecera TO ti_error_cab.
      APPEND ti_error_cab.
      CLEAR: ti_error_cab.
    ENDIF.
    CLEAR:  t_error.
  ENDLOOP.
** 1

  PERFORM procesa_error_ct TABLES ti_error_cab
                                  ti_error_det_ct
                                  ti_cont_cab
                                  ti_cont_det_ct
                                  ti_tlogcaberr
                                  ti_tlogdeterr
                                  ti_resumen
                                  return
                                  ti_detalle.
  REFRESH: return.
  CLEAR:   return.

  DESCRIBE TABLE ti_cont_cab LINES lv_cont_reg.
  IF lv_cont_reg > 0.

    DATA(lo_bdc) = NEW lcl_bdc( ).

*   Determinación de tipo de contabilización.
    PERFORM determina_tipo_cc.

*   Contabilización de Documentos.
    SORT ti_cont_det_ct BY zkey.

*   Verificar retenciones de proveedores
    CLEAR: lt_lfbw.
    PERFORM get_reten TABLES lt_lfbw.
    SORT lt_lfbw BY lifnr bukrs.

    CLEAR: lv_contador.

*   Recorre documento a dcumento
    LOOP AT ti_cont_cab.
      CLEAR: lv_contador, ls_det_iva.

*     Arma los datos de cabecera del call transaction
      PERFORM genera_cabecera CHANGING lo_bdc.

*     Busca si existe una posición de IVA -> Guarda la línea de IVA
      READ TABLE ti_cont_det_ct INTO ls_det_iva WITH KEY iva = abap_true.
      IF sy-subrc <> 0.
        CLEAR: ls_det_iva.
      ENDIF.

*     Recore el detalle para generar los apuntes
      LOOP AT ti_cont_det_ct INTO ls_cont_det WHERE zkey = ti_cont_cab-zkey.
*       Descarta los apuntes de IVA
        CHECK ls_cont_det-iva = abap_false.
        CLEAR: ls_lfbw.

        IF ls_cont_det-tipo = 'AP'.
          READ TABLE lt_lfbw INTO ls_lfbw
            WITH KEY lifnr = ls_cont_det-vendor_no
                     bukrs = ti_cont_cab-comp_code.
*        ELSE.
*          CLEAR: ls_lfbw.
        ENDIF.

        PERFORM genera_apunte USING ls_cont_det
                                    ls_det_iva
                                    ls_lfbw
                              CHANGING lo_bdc.
*       PERFORM contabilizacion.
        ADD 1 TO lv_contador.
      ENDLOOP.
      lo_bdc->add_field( EXPORTING iv_field = 'BDC_OKCODE' iv_value = '=BU' ).

*      PERFORM ejecuta_bapi TABLES  return
*                                   ti_resumen
*                           USING  lv_contador.
** RVY 10-10-2023
      IF ti_cont_cab-ACC_PRINCIPLE = ' '.
         PERFORM call_transaction TABLES return
                                         ti_resumen
                                   USING lv_contador
                                         lo_bdc
                                   CHANGING iv_msg_err.

         IF NOT iv_msg_err IS INITIAL.
            CLEAR: ti_error_cab.
            MOVE-CORRESPONDING  ti_cont_cab TO ti_error_cab.
            APPEND ti_error_cab.
            CLEAR: ti_error_cab.
         ELSE.
            IF ti_cont_cab-area_contab   NE space.
               Perform MODIFICAR-DOCUMENTO Tables   ti_resumen
                                          CHANGING lo_bdc.
            Endif.
         endif.
      else.
         PERFORM call_transaction_LG TABLES return
                                            ti_resumen
                                     USING lv_contador
                                            lo_bdc
                                     CHANGING iv_msg_err.

         IF NOT iv_msg_err IS INITIAL.
            CLEAR: ti_error_cab.
            MOVE-CORRESPONDING  ti_cont_cab TO ti_error_cab.
            APPEND ti_error_cab.
            CLEAR: ti_error_cab.
         ELSE.
            IF ti_cont_cab-area_contab   NE space.
               Perform MODIFICAR-DOCUMENTO Tables   ti_resumen
                                        CHANGING lo_bdc.
            Endif.
         endif.
      endif.
*V1 FIN RVY 07-06-2023
      CLEAR: lv_contador.
    ENDLOOP.
  ENDIF.

ENDFUNCTION.
