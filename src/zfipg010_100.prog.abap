*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFIPG010_100
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  REFRESH tab.
  SET PF-STATUS 'ZFIPG010' EXCLUDING tab.
  SET TITLEBAR 'T01'.

ENDMODULE.                             " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100_exit INPUT.

  CASE sy-ucomm.
    WHEN 'BACK' OR '%EX'.
      LEAVE TO SCREEN 0.
    WHEN 'RW'.
      LEAVE PROGRAM.
  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                 " USER_COMMAND_0100_EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK' OR '%EX'.
      LEAVE TO SCREEN 0.
    WHEN 'DETA'.
      clear bsik-zfbdt.
      PERFORM carga_detalle.
      PERFORM proceso.
    WHEN 'EXCEL'.
      if int_tabla[] is initial.
        MESSAGE s012(zfi).
      else.
        PERFORM genera_excel.
      endif.
  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                             " USER_COMMAND_0100  INPUT

**   Lleno grilla con valores desde tabla
**----------------------------------------------------------------------
*&      Module  FILL_TABLE_CONTROL_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_table_control_0100 OUTPUT.

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
SORT INT_TABLA .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
  READ TABLE int_tabla INTO zfipg010_est INDEX tabla-current_line.

ENDMODULE.                 " FILL_TABLE_CONTROL_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  VALIDA-GRILLA_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE valida-grilla_0100 INPUT.

*ReSQ: No Need Of Change Internal Table INT_TABLA Already Sorted
  MODIFY int_tabla FROM zfipg010_est INDEX tabla-current_line
     TRANSPORTING sel.

ENDMODULE.                 " VALIDA-GRILLA_0100  INPUT

*&---------------------------------------------------------------------*
*&      Form  Carga_Detalle
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM carga_detalle.

  DATA : modi(1).

  accion = 'M'.
  CLEAR modi.

  LOOP AT int_tabla.

    IF int_tabla-sel = 'X'.
      CLEAR int_tabla-sel.
      MODIFY int_tabla.

      PERFORM llena_detalle USING int_tabla-lifnr.

      modi = 'X'.
    ENDIF.

  ENDLOOP.

  IF modi IS INITIAL.
    MESSAGE s010(zfi).
  ENDIF.

  accion = ''.

ENDFORM.                    "Carga_Detalle

*&---------------------------------------------------------------------*
*&      Form  Llena_Detalle
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LIFNR      text
*----------------------------------------------------------------------*
FORM llena_detalle USING lifnr LIKE lfa1-lifnr.

  CLEAR int_tabla1.
  REFRESH int_tabla1.

  LOOP AT tpago WHERE lifnr = lifnr.
    MOVE-CORRESPONDING tpago TO int_tabla1.
    APPEND int_tabla1.
  ENDLOOP.

  lfa1-name1 = int_tabla-name1.

  DESCRIBE TABLE int_tabla1 LINES fill2.
  SORT int_tabla1 BY lifnr zlsch.
  tabla1-lines = fill2.
  tabla1-top_line = 1.

  CLEAR : zzmot_emis_aux, hbkid_aux, zlsch_aux.

  CALL SCREEN 200.

ENDFORM.                    "PANTALLA_200

*&---------------------------------------------------------------------*
*&      Form  Genera_Excel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM genera_excel.

  REFRESH texcel.

  LOOP AT int_tabla.

    IF sy-tabix = 1.

      texcel-lifnr = 'Proveedor'.
      texcel-name1 = 'Nombre'.
      texcel-zlsch = 'Via de Pago'.
      texcel-docto_fac = 'N° Facturas'.
      texcel-monto_fac = 'Monto Facturas'.
      texcel-docto_nc = 'N° Notas de Crédito'.
      texcel-monto_nc = 'Monto Notas de Crédito'.

      APPEND texcel.
      CLEAR texcel.

    ENDIF.

    texcel-lifnr     = int_tabla-lifnr.
    texcel-name1     = int_tabla-name1.
    texcel-zlsch     = int_tabla-zlsch.
    texcel-docto_fac = int_tabla-docto_fac.
    texcel-monto_fac = int_tabla-monto_fac.
    texcel-docto_nc  = int_tabla-docto_nc.
    texcel-monto_nc  = int_tabla-monto_nc.

    WRITE int_tabla-monto_fac TO texcel-monto_fac CURRENCY t001-waers.
    WRITE int_tabla-monto_nc  TO texcel-monto_nc  CURRENCY t001-waers.

    APPEND texcel.

  ENDLOOP.

  CALL FUNCTION 'WS_EXCEL'
    TABLES
      data          = texcel
    EXCEPTIONS
      unknown_error = 1
      OTHERS        = 2.

ENDFORM.                    "Genera_Excel
