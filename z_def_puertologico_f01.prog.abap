*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZWSPROXY_F01
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.


  REFRESH tab.
  MOVE 'GRABA' TO tab-fcode.
  APPEND tab.
  MOVE 'ELIM' TO tab-fcode.
  APPEND tab.
  MOVE 'CANCL' TO tab-fcode.
  APPEND tab.

  SET PF-STATUS 'ZWSPROXY' EXCLUDING tab.
  SET TITLEBAR 'T01'.

ENDMODULE.                             " STATUS_0100  OUTPUT
*----------------------------------------------------------------------*
*  MODULE USER_COMMAND_EXIT_0100 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE user_command_exit_0100 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK'.
      LEAVE PROGRAM.
    WHEN '%EX'.
      LEAVE PROGRAM.
    WHEN 'RW'.
      LEAVE PROGRAM.
  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                    "USER_COMMAND_EXIT_0100 INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK'.
      LEAVE PROGRAM.
    WHEN '%EX'.
      LEAVE PROGRAM.
    WHEN 'RW'.
      LEAVE PROGRAM.
    WHEN 'CREA'.
      PERFORM creacion.
    WHEN 'ACTU'.
      PERFORM actualizacion.
  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                             " USER_COMMAND_0100  INPUT

**&---------------------------------------------------------------------
**&      Module  FILL_TABLE_CONTROL  OUTPUT
**&---------------------------------------------------------------------
**   Lleno grilla con valores desde tabla
**----------------------------------------------------------------------

MODULE fill_table_control OUTPUT.

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
SORT INT_TABLA .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
  READ TABLE int_tabla INTO zws_puerto_est INDEX tabla-current_line.

ENDMODULE.                             " FILL_TABLE_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDA-GRILLA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE valida-grilla INPUT.

  IF sy-stepl = 1.
    LOOP AT int_tabla.
      CLEAR int_tabla-sel.
      MODIFY int_tabla.
    ENDLOOP.
  ENDIF.

*ReSQ: No Need Of Change Internal Table INT_TABLA Already Sorted
  MODIFY int_tabla FROM zws_puerto_est INDEX tabla-current_line
     TRANSPORTING sel.

ENDMODULE.                             " VALIDA-GRILLA  INPUT

*&---------------------------------------------------------------------*
*&      Module  LLENO-GRILLA  OUTPUT
*&---------------------------------------------------------------------*
* Lleno tabla con valores desde tabla ZCLPP_TURNOSMAQ
*----------------------------------------------------------------------*
MODULE lleno-grilla OUTPUT.

  IF swprimera IS INITIAL.
    PERFORM proceso.
    swprimera = 1.
  ENDIF.

ENDMODULE.                             " LLENO-GRILLA  OUTPUT

*---------------------------------------------------------------------*
*       FORM CREACION                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM creacion.

  CLEAR zws_puerto_est.
  CLEAR sy-ucomm.
  PERFORM pantalla_200.

ENDFORM.                    "CREACION
*---------------------------------------------------------------------*
*       FORM ACTUALIZACION                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM actualizacion.

  DATA : modi(1).

  accion = 'M'.
  CLEAR modi.

  LOOP AT int_tabla.
    IF int_tabla-sel = 'X'.
      CLEAR int_tabla-sel.
      MODIFY int_tabla.
      zws_puerto_est-sociedad   = int_tabla-sociedad.
      zws_puerto_est-programa   = int_tabla-programa.
      zws_puerto_est-puerto = int_tabla-puerto.
      zws_puerto_est-estado = int_tabla-estado.
      PERFORM pantalla_200.
      modi = 'X'.
    ENDIF.
  ENDLOOP.



  IF modi IS INITIAL.
    MESSAGE s001(zi) WITH 'Debe seleccionar una linea para modificar'.
  ENDIF.

  accion = ''.

ENDFORM.                    "ACTUALIZACION

*---------------------------------------------------------------------*
*       FORM PROCESO                                                  *
*---------------------------------------------------------------------*
FORM proceso.

  REFRESH int_tabla.
  CLEAR int_tabla.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM zws_puerto
*                WHERE sociedad = p_bukrs.
*
* NEW CODE
  SELECT *
 FROM zws_puerto
                WHERE sociedad = p_bukrs ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    MOVE-CORRESPONDING zws_puerto TO int_tabla.
    APPEND int_tabla.
  ENDSELECT.

  DESCRIBE TABLE int_tabla LINES fill.
  SORT int_tabla BY estado.
  tabla-lines = fill.

ENDFORM.                    "PROCESO

*---------------------------------------------------------------------*
*       FORM PANTALLA-200                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM pantalla_200.

  IF accion = 'M'.
    titulo  = 'MODIFICA/ELIMINA PUERTO WS'.
  ELSE.
    titulo  = 'INGRESO PUERTO WS'.
  ENDIF.

  CALL SCREEN 200 STARTING AT 20 05 ENDING AT 110 19.

ENDFORM.                    "PANTALLA_200
