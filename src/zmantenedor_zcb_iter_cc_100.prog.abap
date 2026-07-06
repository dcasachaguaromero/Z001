*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFIPG001_100
*&---------------------------------------------------------------------*

MODULE status_0100 OUTPUT.

  REFRESH tab.
  MOVE 'GRABA' TO tab-fcode.
  APPEND tab.
  MOVE 'ELIM' TO tab-fcode.
  APPEND tab.
  MOVE 'CANC' TO tab-fcode.
  APPEND tab.

  SET  PF-STATUS 'ZFIPG001' EXCLUDING tab.
  SET  TITLEBAR 'T01'.

ENDMODULE.                             " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK' OR '%EX' OR 'RW'.
      LEAVE PROGRAM.
    WHEN 'CREA'.
      PERFORM creacion.
    WHEN 'ACTUA'.
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
  READ TABLE int_tabla INTO zcb_iter_cc_est INDEX tabla-current_line.

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
  MODIFY int_tabla FROM zcb_iter_cc_est INDEX tabla-current_line
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

  CLEAR: zcb_iter_cc_est-desde, zcb_iter_cc_est-orden, zcb_iter_cc_est-enabled.
  zcb_iter_cc_est-hktid = hktid.
  zcb_iter_cc_est-hbkid = hbkid.
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
      MOVE-CORRESPONDING int_tabla TO zcb_iter_cc_est.

      PERFORM pantalla_200.
      modi = 'X'.
    ENDIF.
  ENDLOOP.

  IF modi IS INITIAL.
    MESSAGE s004(zfi) WITH 'Debe Seleccionar una Linea para Modificar'.
  ENDIF.

  accion = ''.

ENDFORM.                    "ACTUALIZACION

*---------------------------------------------------------------------*
*       FORM PROCESO                                                  *
*---------------------------------------------------------------------*
FORM proceso.

  REFRESH int_tabla.
  CLEAR int_tabla.

  SELECT  a~bukrs
          a~hbkid
          a~hktid
          a~secuencia
          a~coditer
          a~orden
          a~enabled
          a~desde
          b~descrip
     FROM zcb_iter_cc AS a INNER JOIN zcb_iter AS b ON a~coditer = b~coditer
     INTO CORRESPONDING FIELDS OF TABLE int_tabla
     WHERE a~bukrs = bukrs AND
           a~hbkid = hbkid AND
           a~hktid = hktid.

  DESCRIBE TABLE int_tabla LINES fill.
*  SORT int_tabla BY blart.
  tabla-lines = fill.

ENDFORM.                    "PROCESO

*---------------------------------------------------------------------*
*       FORM PANTALLA-200                                             *
*---------------------------------------------------------------------*
FORM pantalla_200.

*  IF accion <> 'M'.
*    CLEAR t003t-ltext.
*  ENDIF.

  CALL SCREEN 200 STARTING AT 25 01 ENDING AT 120 15.

ENDFORM.                    "PANTALLA_200
