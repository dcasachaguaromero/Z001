*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <26-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
REPORT zfitr045_new NO STANDARD PAGE HEADING
                                   LINE-COUNT 60
                                   LINE-SIZE 132.
*
INCLUDE zbatchinput.
INCLUDE zfitr045_new2_top.
INCLUDE zfitr045_new2_sel.
INCLUDE zfitr045_new2_f01_CL03.
INCLUDE zfitr045_new2_001.
INCLUDE zfitr045_new2_002.

START-OF-SELECTION.

  CASE gc_x.
    WHEN p_opc1.
      PERFORM lee_datos.
      IF reg[] IS NOT INITIAL.
        PERFORM procesa_datos.
        PERFORM cuadratura.
      ENDIF.

      IF gt_outtab[] IS NOT INITIAL.
        CALL SCREEN 150.
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
                               gv_error.
      ENDIF.
    WHEN p_opc2.
      PERFORM datos_reporte.
      IF gt_salida[] IS NOT INITIAL.
        PERFORM mustra_datos.
      ELSE.
        MESSAGE i004(zfi) WITH 'No hay datos para la selección'.
      ENDIF.
  ENDCASE.

END-OF-SELECTION.
