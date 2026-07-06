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

INCLUDE zbatchinput.
* ini Waldo Alarcón - Visionone - 10-04-2020 - Ajustes de salida del reporte
INCLUDE zfitr045_new_top.
INCLUDE zfitr045_new_sel.
INCLUDE zfitr045_new_f01.
* fin Waldo Alarcón - Visionone - 10-04-2020 - Ajustes de salida del reporte

INCLUDE zfitr045_new_001.  "valores de dynpro 100
*INCLUDE zfitr011_new_001.
INCLUDE zfitr045_new_002.  "valores de dynpro 200
*INCLUDE zfitr011_new_002.

START-OF-SELECTION.

  PERFORM lee_datos.
  PERFORM procesa_datos.
  PERFORM cuadratura.

* ini Waldo Alarcón - Visionone - 10-04-2020 - Ajustes de salida del reporte
  IF p_proc EQ 'X'.
    CALL SCREEN 100.
  ELSE.
    CALL SCREEN 150.
  ENDIF.
* fin Waldo Alarcón - Visionone - 10-04-2020 - Ajustes de salida del reporte
*
  IF NOT observacion IS INITIAL.
    WRITE: /, 'Error en proceso : ',observacion.
  ENDIF.

END-OF-SELECTION.
