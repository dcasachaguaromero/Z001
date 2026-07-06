*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZFITR040_037_0100 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  FILL_TABLA_CONTROL_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZFITR040_037_100 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET  PF-STATUS 'ZFITR040_037' .
  SET  TITLEBAR 'T01'.
ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

MODULE user_command_0100_exit INPUT.
  CASE sy-ucomm.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN '%EX' OR 'RW'.
      LEAVE PROGRAM.
  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                    "user_command_0100_exit INPUT
*----------------------------------------------------------------------*
*  MODULE USER_COMMAND_0100 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.

    WHEN 'SEL'.
      CLEAR sy-ucomm.
      PERFORM marco_todo_tabla.
    WHEN 'DSEL'.
      CLEAR sy-ucomm.
      PERFORM desmarco_todo_tabla.
    WHEN 'PROC'.
      PERFORM cargo_archivo_novedades.

*    WHEN 'ASCE'.
*      PERFORM ordeno_acendente.
*    WHEN 'DESC'.
*      PERFORM ordeno_decendente.
*    WHEN 'BUSC'.
*      PERFORM buscar.
  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                 " USER_COMMAND_0100  INPUT


*&---------------------------------------------------------------------*
*&      Form  buscar
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*FORM buscar.
*  IF buscar IS INITIAL.
*    int_tabla[] = int_tabla_aux[].
*  ELSE.
*    REFRESH int_tabla.
*    LOOP AT int_tabla_aux WHERE  archivo cs buscar .
*      MOVE int_tabla_aux TO int_tabla.
*      APPEND int_tabla.
*    ENDLOOP.
*  ENDIF.
*ENDFORM.                    "buscar
**&---------------------------------------------------------------------*
**&      Form  ORDENO_ACENDENTE
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*FORM ordeno_acendente.
*  DATA:  col TYPE cxtab_column.
*
**
*  LOOP AT tabla-cols INTO col.
*    IF col-selected = 'X'.
*      IF col-screen-name = 'ZFITR040_EST-ARCHIVO'.
*        SORT int_tabla BY archivo ASCENDING.
*      ELSE.
*        IF col-screen-name = 'ZFITR040_EST-FECHA'.
*          SORT int_tabla BY fecha ASCENDING.
*        ELSE.
*          IF col-screen-name = 'ZFITR040_EST-CORRE'.
*            SORT int_tabla BY corre ASCENDING.
*          ELSE.
*            IF col-screen-name = 'ZFITR040_EST-TAMANO'.
*              SORT int_tabla BY tamano ASCENDING.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.
*
*
*ENDFORM.                    "ORDENO_ACENDENTE
**&---------------------------------------------------------------------*
**&      Form  ORDENO_DECENDENTE
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*FORM ordeno_decendente.
*  DATA:  col TYPE cxtab_column.
*  LOOP AT tabla-cols INTO col.
*    IF col-selected = 'X'.
*      IF col-screen-name = 'ZFITR040_EST-ARCHIVO'.
*        SORT int_tabla BY archivo DESCENDING.
*      ELSE.
*        IF col-screen-name = 'ZFITR040_EST-FECHA'.
*          SORT int_tabla BY fecha DESCENDING.
*        ELSE.
*          IF col-screen-name = 'ZFITR040_EST-CORRE'.
*            SORT int_tabla BY corre DESCENDING.
*          ELSE.
*            IF col-screen-name = 'ZFITR040_EST-TAMANO'.
*              SORT int_tabla BY tamano DESCENDING.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.
*
*ENDFORM.                    "ORDENO_DECENDENTE
*&---------------------------------------------------------------------*
*&      Form  marco_todo_tabla
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM marco_todo_tabla .
  LOOP AT int_tabla.
    int_tabla-sel = 'X'.
    MODIFY int_tabla.
  ENDLOOP.

ENDFORM.                    " MARCO_TODO
*&---------------------------------------------------------------------*
*&      Form  DESMARCO_TODO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
**----------------------------------------------------------------------*
FORM desmarco_todo_tabla.
  LOOP AT int_tabla.
    int_tabla-sel = ''.
    MODIFY int_tabla.
  ENDLOOP.

ENDFORM.                    "desmarco_todo_tabla

*&---------------------------------------------------------------------*
*&      Module  FILL_TABLA_CONTROL_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_tabla_control_0100 OUTPUT.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES04 ECDK917080 *
SORT INT_TABLA .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES04 ECDK917080 *
  READ TABLE int_tabla INTO zfitr040_est INDEX tabla-current_line.

ENDMODULE.                 " FILL_TABLA_CONTROL_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  ACTUALIZA_GRILLA_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE actualiza_grilla_0100 INPUT.
*ReSQ: No Need Of Change Internal Table INT_TABLA Already Sorted
  MODIFY int_tabla FROM zfitr040_est INDEX tabla-current_line
      TRANSPORTING sel .


ENDMODULE.                 " ACTUALIZA_GRILLA_0100  INPUT
*&---------------------------------------------------------------------*
*&      Module  FILL_TABLA_CONTROL_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
