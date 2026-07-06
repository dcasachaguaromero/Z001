*&---------------------------------------------------------------------*
*& Report ZFITR046_NEW
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfitr046_new NO STANDARD PAGE HEADING
                                   LINE-COUNT 60
                                   LINE-SIZE 132.
*
INCLUDE zbatchinput.
INCLUDE zfitr046_new_top.
INCLUDE zfitr046_new_sel.
INCLUDE zfitr046_new_pbo.
INCLUDE zfitr046_new_pai.
INCLUDE zfitr046_new_f01.
*
START-OF-SELECTION.

  PERFORM lee_datos.

  IF reg[] IS NOT INITIAL.
    PERFORM procesa_datos.
    PERFORM cuadratura.

    IF gt_outtab[] IS NOT INITIAL.
      CALL SCREEN 100.
*
      IF NOT observacion IS INITIAL.
        WRITE: /, 'Error en proceso : ',observacion.
      ENDIF.
    ELSE.
      CONCATENATE 'Sociedad: ' bukrs ' Banco: ' ubnkl INTO gv_error
                                                   SEPARATED BY space.
      MESSAGE i004(zfi) WITH 'SE CANCELA, No hay datos sin procesar,'
                             gv_error ', Estado pago' p_estado.
    ENDIF.
  ENDIF.
