*&---------------------------------------------------------------------*
*&  Include           ZFICH003_F01
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.


  REFRESH TAB.
  MOVE 'GRABA' TO TAB-FCODE.
  APPEND TAB.
  MOVE 'ELIM' TO TAB-FCODE.
  APPEND TAB.
  MOVE 'CANCL' TO TAB-FCODE.
  APPEND TAB.

  SET PF-STATUS 'ZFICH003' EXCLUDING TAB.
  SET TITLEBAR 'T01'.

ENDMODULE.                             " STATUS_0100  OUTPUT
MODULE USER_COMMAND_EXIT_0100 INPUT.

  CASE SY-UCOMM.
    WHEN 'BACK'.
      LEAVE PROGRAM.
    WHEN '%EX'.
      LEAVE PROGRAM.
    WHEN 'RW'.
      LEAVE PROGRAM.
     ENDCASE.

  CLEAR SY-UCOMM.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE SY-UCOMM.
    WHEN 'BACK'.
      LEAVE PROGRAM.
    WHEN '%EX'.
      LEAVE PROGRAM.
    WHEN 'RW'.
      LEAVE PROGRAM.
    WHEN 'CREA'.
      PERFORM CREACION.
    WHEN 'ACTU'.
      PERFORM ACTUALIZACION.
    ENDCASE.

  CLEAR SY-UCOMM.

ENDMODULE.                             " USER_COMMAND_0100  INPUT

**&---------------------------------------------------------------------
**&      Module  FILL_TABLE_CONTROL  OUTPUT
**&---------------------------------------------------------------------
**   Lleno grilla con valores desde tabla
**----------------------------------------------------------------------

MODULE FILL_TABLE_CONTROL OUTPUT.

  READ TABLE INT_TABLA INTO ZFICH002_EST INDEX TABLA-CURRENT_LINE.

ENDMODULE.                             " FILL_TABLE_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDA-GRILLA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VALIDA-GRILLA INPUT.

  IF SY-STEPL = 1.
    LOOP AT INT_TABLA.
      CLEAR INT_TABLA-SEL.
      MODIFY INT_TABLA.
    ENDLOOP.
  ENDIF.

  MODIFY INT_TABLA FROM ZFICH002_EST INDEX TABLA-CURRENT_LINE
     TRANSPORTING SEL.

ENDMODULE.                             " VALIDA-GRILLA  INPUT

*&---------------------------------------------------------------------*
*&      Module  LLENO-GRILLA  OUTPUT
*&---------------------------------------------------------------------*
* Lleno tabla con valores desde tabla ZCLPP_TURNOSMAQ
*----------------------------------------------------------------------*
MODULE LLENO-GRILLA OUTPUT.

  IF SWPRIMERA IS INITIAL.
    PERFORM PROCESO.
    SWPRIMERA = 1.
  ENDIF.

ENDMODULE.                             " LLENO-GRILLA  OUTPUT

*---------------------------------------------------------------------*
*       FORM CREACION                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM CREACION.

  CLEAR ZFICH002_EST.
  CLEAR SY-UCOMM.
  PERFORM PANTALLA_200.

ENDFORM.
*---------------------------------------------------------------------*
*       FORM ACTUALIZACION                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM ACTUALIZACION.

  DATA : MODI(1).

  ACCION = 'M'.
  CLEAR MODI.

  LOOP AT INT_TABLA.
    IF INT_TABLA-SEL = 'X'.
      CLEAR INT_TABLA-SEL.
      MODIFY INT_TABLA.
      ZFICH002_EST-ESTADO   = INT_TABLA-ESTADO.
      ZFICH002_EST-DESCRI   = INT_TABLA-DESCRI.
      ZFICH002_EST-TIPO_EST = INT_TABLA-TIPO_EST.
      ZFICH002_EST-SHKZG    = INT_TABLA-SHKZG.
      PERFORM PANTALLA_200.
      MODI = 'X'.
    ENDIF.
  ENDLOOP.



  IF MODI IS INITIAL.
    MESSAGE S001(ZI) WITH 'Debe seleccionar una linea para modificar'.
  ENDIF.

  ACCION = ''.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM PROCESO                                                  *
*---------------------------------------------------------------------*
FORM PROCESO.

  REFRESH INT_TABLA.
  CLEAR INT_TABLA.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM ZFICH002
*                WHERE bukrs = p_bukrs.
*
* NEW CODE
  SELECT *
 FROM ZFICH002
                WHERE bukrs = p_bukrs ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    MOVE-CORRESPONDING ZFICH002 TO INT_TABLA.
    APPEND INT_TABLA.
  ENDSELECT.

  DESCRIBE TABLE INT_TABLA LINES FILL.
  SORT INT_TABLA BY estado.
  TABLA-LINES = FILL.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM PANTALLA-200                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM PANTALLA_200.

  IF ACCION = 'M'.
    TITULO  = 'MODIFICA/ELIMINA ESTADO DE CHEQUE'.
  ELSE.
    TITULO  = 'INGRESO ESTADO DE CHEQUE'.
  ENDIF.

  CALL SCREEN 200 STARTING AT 20 05 ENDING AT 110 17.

ENDFORM.
