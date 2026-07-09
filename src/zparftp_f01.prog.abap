*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZPARFTP_F01
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.


  REFRESH tab.
  MOVE 'GRABA' TO tab-fcode.
  APPEND tab.
  MOVE 'ELIM' TO tab-fcode.
  APPEND tab.
  MOVE 'CANCL' TO tab-fcode.
  APPEND tab.

  SET PF-STATUS 'ZPARFTP' EXCLUDING tab.
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

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
SORT INT_TABLA .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
  READ TABLE int_tabla INTO ztparamftp_est INDEX tabla-current_line.

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
  MODIFY int_tabla FROM ztparamftp_est INDEX tabla-current_line
     TRANSPORTING sel.

ENDMODULE.                             " VALIDA-GRILLA  INPUT

*&---------------------------------------------------------------------*
*&      Module  LLENO-GRILLA  OUTPUT
*&---------------------------------------------------------------------*
* Lleno tabla con valores desde tabla ZTPARAMFTP
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

  CLEAR ztparamftp_est.
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
      ztparamftp_est-zbukr  = int_tabla-zbukr.
      ztparamftp_est-zprog  = int_tabla-zprog.
      ztparamftp_est-zruta = int_tabla-zruta.
      ztparamftp_est-zruta_respaldo = int_tabla-zruta_respaldo.
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
*  SELECT * FROM ztparamftp
*                WHERE zbukr = p_bukrs.
*
* NEW CODE
  SELECT *
 FROM ztparamftp
                WHERE zbukr = p_bukrs ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    MOVE-CORRESPONDING ztparamftp TO int_tabla.
    APPEND int_tabla.
  ENDSELECT.

  DESCRIBE TABLE int_tabla LINES fill.
  SORT int_tabla BY ZPROG.
  tabla-lines = fill.

ENDFORM.                    "PROCESO

*---------------------------------------------------------------------*
*       FORM PANTALLA-200                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM pantalla_200.

  IF accion = 'M'.
    titulo  = 'MODIFICA/ELIMINA PARAMETROS FTP'.
  ELSE.
    titulo  = 'INGRESO PARAMETROS FTP'.
  ENDIF.

  CALL SCREEN 200 STARTING AT 20 05 ENDING AT 110 19.

ENDFORM.                    "PANTALLA_200
