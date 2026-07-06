*&---------------------------------------------------------------------*
*& Report ZFITR046_NEW2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfitr046_new NO STANDARD PAGE HEADING
                                   LINE-COUNT 60
                                   LINE-SIZE 132.
*
INCLUDE zbatchinput.
INCLUDE zfitr046_new2_top.
INCLUDE zfitr046_new2_sel.
INCLUDE zfitr046_new2_pbo.
INCLUDE zfitr046_new2_pai.
INCLUDE zfitr046_new2_f01.
*
START-OF-SELECTION.

  CASE gc_x.
    WHEN p_opc1.
      PERFORM lee_datos.
      IF reg[] IS NOT INITIAL.
        PERFORM procesa_datos.
        PERFORM cuadratura.
      ENDIF.

      IF gt_outtab[] IS NOT INITIAL.
        CALL SCREEN 100.
*
        IF gt_salida[] IS NOT INITIAL.
          MODIFY ztfi_log_pago FROM TABLE gt_salida.
          PERFORM mustra_datos.
        ELSE.
          MESSAGE i004(zfi) WITH 'No se procesarón datos'.
        ENDIF.
      ELSE.
        CONCATENATE 'Sociedad: ' bukrs ' Banco: ' ubnkl INTO gv_error
                                                     SEPARATED BY space.
        MESSAGE i004(zfi) WITH 'SE CANCELA, No hay datos sin procesar,'
                               gv_error ', Estado pago' p_estado.
      ENDIF.
    WHEN p_opc2.
      PERFORM datos_reporte.
      IF gt_salida[] IS NOT INITIAL.
        PERFORM mustra_datos.
      ELSE.
        MESSAGE i004(zfi) WITH 'No hay datos para la selección'.
      ENDIF.
  ENDCASE.
