*&---------------------------------------------------------------------*
*& Report:                                                             *
*& Author: Waldo Alarcón                                               *
*& Description: Funcion para contabilziar documentos con distintas     *
*&              monedas, función es llamada desde PO                   *
*& Date: 21-12-2021                                                    *
*& Transport Number:                                                   *
*&---------------------------------------------------------------------*
FUNCTION ZFIRFC004_ANT.
*"--------------------------------------------------------------------
*"*"Interfase local
*"  TABLES
*"      TI_CABECERA STRUCTURE  ZCABECERA_ME
*"      TI_DETALLE STRUCTURE  ZDETALLE_ME
*"      TI_TLOGCABERR STRUCTURE  ZTLOGCABERR
*"      TI_TLOGDETERR STRUCTURE  ZTLOGDETERR
*"      TI_RESUMEN STRUCTURE  ZRESUMEN
*"      RETURN STRUCTURE  BAPIRET2
*"--------------------------------------------------------------------
*  Limpia Tablas Internas.
  perform limpia_tablas.

* Validación  datos de Cabecera y Posicion.
  DATA: pp_index LIKE sy-tabix.
  LOOP AT  ti_cabecera.
    CLEAR: return.
    PERFORM val_cab TABLES return
                   USING ti_cabecera
                 CHANGING  t_error.
    IF t_error EQ 0.
      SORT ti_cont_cab .
      LOOP AT ti_detalle WHERE zkey EQ ti_cabecera-zkey.
        CLEAR: return.
        PERFORM val_detalle TABLES return
                          USING  ti_detalle
                                 ti_cabecera
                       CHANGING  t_error.
        IF t_error EQ 0.
          MOVE-CORRESPONDING    ti_cabecera TO ti_cont_cab.
          READ TABLE ti_cont_cab WITH KEY zkey =  ti_cabecera-zkey.
          pp_index = sy-tabix.
          IF sy-subrc NE 0.
            APPEND ti_cont_cab.
          ELSE.
            MODIFY ti_cont_cab INDEX pp_index.
          ENDIF.
          MOVE-CORRESPONDING    ti_detalle TO ti_cont_det.
          APPEND ti_cont_det.
        ELSE.
          MOVE-CORRESPONDING  ti_detalle TO ti_error_det.
          APPEND ti_error_det.
          CLEAR: ti_error_det.
        ENDIF.
      ENDLOOP.
    ELSE.
      MOVE-CORRESPONDING  ti_cabecera TO ti_error_cab.
      APPEND ti_error_cab.
      CLEAR: ti_error_cab.
    ENDIF.
    CLEAR:  t_error.
  ENDLOOP.
  PERFORM proecesa_error TABLES    ti_error_cab
                                   ti_error_det
                                   ti_cont_cab
                                   ti_cont_det
                                   ti_tlogcaberr
                                   ti_tlogdeterr
                                   ti_resumen
                                   return
                                   ti_detalle.
  REFRESH: return.
  CLEAR:   return.
  DATA: cont_reg TYPE i.
  DESCRIBE TABLE ti_cont_cab LINES  cont_reg.
  IF cont_reg > 0.
*  Determinación de tipo de Contabilización.
    PERFORM dertmina_gl_ap_rr.
*  Contabilización de Documentos.
    SORT ti_cont_det BY zkey.
    DATA: contador(3) TYPE n.

    LOOP AT ti_cont_cab.
      CLEAR: contador.
      LOOP AT ti_cont_det WHERE zkey EQ ti_cont_cab-zkey.
        PERFORM contabilizacion.
        ADD 1 TO contador.
      ENDLOOP.
      PERFORM ejecuta_bapi TABLES  return
                                   ti_resumen
                           USING  contador.
      CLEAR: contador.
    ENDLOOP.
  ENDIF.
ENDFUNCTION.
