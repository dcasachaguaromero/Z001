*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFIPG001_200
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  REFRESH tab.
  MOVE 'ACTUA' TO tab-fcode.
  APPEND tab.
  MOVE 'CREA' TO tab-fcode.
  APPEND tab.

  IF accion <>  'M'.
    MOVE 'ELIM' TO tab-fcode.
    APPEND tab.
  ENDIF.

  SET PF-STATUS 'ZFIPG001' EXCLUDING tab.

ENDMODULE.                             " STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE sy-ucomm.
    WHEN 'CANC'.
      IF accion <> 'M'.
        PERFORM proceso.
      ENDIF.
      LEAVE  TO SCREEN 0.
    WHEN 'ELIM'.
      PERFORM elimino_base.
      IF resp = '1'.
        PERFORM proceso.
        LEAVE  TO SCREEN 0.
      ENDIF.
    WHEN 'GRABA'.
      IF accion <> 'M'.
        PERFORM ingreso_base.
      ELSE.
        PERFORM actualizo_base.
        LEAVE TO SCREEN 0.
      ENDIF.
  ENDCASE.

ENDMODULE.                             " USER_COMMAND_0200  INPUT

*---------------------------------------------------------------------*
*       MODULE PROTEJE_0200 OUTPUT                                    *
*---------------------------------------------------------------------*
MODULE proteje_0200 OUTPUT.

  DATA: x(1).

  x = '1'.

  LOOP AT SCREEN.
    IF screen-name = 'ZFIPG001_EST-BLART'.
      IF accion <>  'M'.
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.                             " PROTEJE  OUTPUT

*---------------------------------------------------------------------*
*       FORM INGRESO_bASE                                             *
*---------------------------------------------------------------------*
FORM ingreso_base.

  MOVE-CORRESPONDING zfipg001_est TO zfipg001.
  MOVE bukrs                          TO zfipg001-bukrs.
  INSERT zfipg001.

  CLEAR: zfipg001_est.

ENDFORM.                    "INGRESO_BASE

*---------------------------------------------------------------------*
*       FORM actualiza_BASE                                           *
*---------------------------------------------------------------------*
FORM actualizo_base.

  int_tabla-descr = zfipg001_est-descr.
  MODIFY int_tabla.

  zfipg001-descr = zfipg001_est-descr.
  MODIFY zfipg001.

ENDFORM.                    "ACTUALIZO_BASE

*---------------------------------------------------------------------*
*       FORM ELIMINO_BASE                                             *
*---------------------------------------------------------------------*
FORM elimino_base.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Confirmación '
      text_question         = 'Esta Seguro de Borrar Informacion?'
      default_button        = '2'
      display_cancel_button = 'X'
    IMPORTING
      answer                = resp.

  IF sy-subrc = 0 AND resp = '1'.
    DELETE FROM zfipg001 WHERE bukrs =  int_tabla-bukrs
                         AND   blart =  int_tabla-blart.
  ENDIF.

ENDFORM.                    "ELIMINO_BASE

*&---------------------------------------------------------------------*
*&      Module  VALIDO-PANTALLA2  INPUT
*&---------------------------------------------------------------------*
MODULE valido-pantalla_0200 INPUT.

  IF sy-ucomm <> 'CANC'.
    PERFORM valido_0200.
  ENDIF.

ENDMODULE.                             " VALIDO-PANTALLA2  INPUT

*---------------------------------------------------------------------*
*       FORM valido_2000
*---------------------------------------------------------------------*
FORM valido_0200.

  IF accion <> 'M'.
    IF zfipg001_est-blart IS INITIAL.
      MESSAGE e004(zfi) WITH 'Debe Ingresar Clase de Documento'.
    ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM zfipg001 WHERE bukrs =  bukrs
*                           AND   blart =  zfipg001_est-blart.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM zfipg001 WHERE bukrs =  bukrs
                           AND   blart =  zfipg001_est-blart ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc = 0.
      MESSAGE e004(zfi) WITH 'Clase de Documento ya Existe'.
    ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM t003 WHERE blart =  zfipg001_est-blart.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM t003 WHERE blart =  zfipg001_est-blart ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc <> 0.
      MESSAGE e004(zfi) WITH 'Clase de Documento no Existe'.
    ENDIF.

  ENDIF.

*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t003t WHERE   spras  = sy-langu
*                             AND    blart  = zfipg001_est-blart.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t003t WHERE   spras  = sy-langu
                             AND    blart  = zfipg001_est-blart ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01


  IF sy-subrc <> 0.
    t003t-ltext = '?????'.
  ENDIF.


  IF zfipg001_est-descr IS INITIAL.
    zfipg001_est-descr = t003t-ltext.
  ENDIF.

ENDFORM.                    "VALIDO_0200
