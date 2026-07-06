*&---------------------------------------------------------------------*
*& Report ZFITR016
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfitr016.

INCLUDE zfitr016_top.
INCLUDE zfitr016_sel.
INCLUDE zfitr016_f01.

START-OF-SELECTION.
* Solo para procesos de JOB entre Lunes a Viernes
  IF sy-batch IS NOT INITIAL.
    CALL FUNCTION 'DATE_COMPUTE_DAY'
      EXPORTING
        date = sy-datum
      IMPORTING
        day  = gv_day.
    CHECK gv_day LE 5.
  ENDIF.

  PERFORM lee_datos_set.
  IF gr_proceso[] IS NOT INITIAL.
    CASE gc_x.
      WHEN p_proc.
        CASE gc_x.
          WHEN par_nom.
            IF par_di EQ gc_x .
              PERFORM verifica_datos USING par_di.
            ENDIF.
            PERFORM cargo_datos.
            IF gt_tabla_00[] IS NOT INITIAL.
              PERFORM llama_funcion TABLES gt_out_reg_bci
                                           gt_file.
              IF gt_file[] IS NOT INITIAL.
                CASE gc_x.
                  WHEN par_di.
                    PERFORM ws_carga_nomina       TABLES gt_file.
                  WHEN OTHERS.
                    PERFORM bajar_archivo TABLES gt_file.
                ENDCASE.
              ELSE.
              ENDIF.
            ENDIF.
          WHEN par_ren.
            IF sy-batch IS INITIAL.
              PERFORM verifica_datos        USING ' '.
              PERFORM ws_rendicion_nomina   .
            ELSE.
              PERFORM busca_datos_rendicion.
            ENDIF.
        ENDCASE.
      WHEN p_repo.
        PERFORM lee_datos.
    ENDCASE.

    IF par_tes IS INITIAL OR p_repo EQ gc_x OR par_ren EQ gc_x.
      PERFORM muestra_datos.
    ENDIF.
  ELSE.
    MESSAGE e899(fi) WITH 'Sin códigos de retorno SET "ZWS_BCI_PROCESOS"'.
  ENDIF.
