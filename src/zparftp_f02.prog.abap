*&---------------------------------------------------------------------*
*&  Include           ZPARFTP_F02
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  REFRESH tab.
  MOVE 'ACTU' TO tab-fcode.
  APPEND tab.
  MOVE 'CREA' TO tab-fcode.
  APPEND tab.

  IF accion <>  'M'.
    MOVE 'ELIM' TO tab-fcode.
    APPEND tab.
  ENDIF.

  SET PF-STATUS 'ZPARFTP' EXCLUDING tab.

ENDMODULE.                             " STATUS_0200  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_exit_0200 INPUT.

  CASE sy-ucomm.
    WHEN 'CANCL'.

      PERFORM proceso.

      LEAVE  TO SCREEN 0.
  ENDCASE.

ENDMODULE.                    "user_command_EXIT_0200 INPUT
*----------------------------------------------------------------------*
*  MODULE user_command_0200 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE sy-ucomm.
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
        PERFORM proceso.
        LEAVE TO SCREEN 0.
      ENDIF.
  ENDCASE.

ENDMODULE.                             " USER_COMMAND_0200  INPUT

*---------------------------------------------------------------------*
*       MODULE PROTEJE_0200 OUTPUT                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE proteje_0200 OUTPUT.

  DATA: x(1).

  x = '1'.

  LOOP AT SCREEN.
    IF screen-name = 'ZTPARAMFTP_EST-ZPROG'.
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
*       ........                                                      *
*---------------------------------------------------------------------*
FORM ingreso_base.
  MOVE   p_bukrs                  TO ztparamftp_est-zbukr.
  MOVE-CORRESPONDING ztparamftp_est TO ztparamftp.

  INSERT ztparamftp.

  CLEAR ztparamftp_est.
  MOVE p_bukrs                     TO ztparamftp_est-zbukr.

ENDFORM.                    "ingreso_base

*---------------------------------------------------------------------*
*       FORM actualiza_BASE                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM actualizo_base.

  int_tabla-zprog     = ztparamftp_est-zprog.

  int_tabla-zruta     = ztparamftp_est-zruta.
  int_tabla-zruta_respaldo    = ztparamftp_est-zruta_respaldo.

  MODIFY int_tabla.

  MOVE-CORRESPONDING ztparamftp_est       TO ztparamftp.

  MODIFY ztparamftp.

ENDFORM.                    "actualizo_base

*---------------------------------------------------------------------*
*       FORM ELIMINO_BASE                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM elimino_base .

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Confirmacion '
      text_question         = 'Esta seguro de borrar esta informacion?'
      default_button        = '2'
      display_cancel_button = 'X'
    IMPORTING
      answer                = resp.

  IF sy-subrc = 0 AND resp = '1'.
    DELETE  FROM ztparamftp WHERE zbukr = int_tabla-zbukr
                              AND zprog = int_tabla-zprog.

  ENDIF.

ENDFORM.                    "elimino_base

*&---------------------------------------------------------------------*
*&      Module  VALIDO-PANTALLA2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE valido-pantalla_0200 INPUT.

  IF sy-ucomm <> 'CANC'.
    PERFORM valido_0200.
  ENDIF.

ENDMODULE.                             " VALIDO-PANTALLA2  INPUT
*---------------------------------------------------------------------*
*       FORM valido_2000
*
*---------------------------------------------------------------------*
FORM valido_0200.

  MOVE p_bukrs                     TO ztparamftp_est-zbukr.

  IF accion <> 'M'.
    IF ztparamftp_est-zprog IS INITIAL.
      MESSAGE e004(zfi) WITH 'Debe ingresar Nombre de Programa'.
    ENDIF.


    SELECT * FROM ztparamftp WHERE zbukr = ztparamftp_est-zbukr
                             AND zprog = ztparamftp_est-zprog.

    ENDSELECT.
    IF sy-subrc = 0.
      MESSAGE e004(zfi) WITH 'Programa  ya Existe para esta sociedad '.
    ENDIF.

  ENDIF.



  IF ztparamftp_est-zruta IS INITIAL.
    MESSAGE e004(zfi) WITH 'Debe Ingresar Ruta Origen de Archivos'.
  ENDIF.

  IF ztparamftp_est-zruta_respaldo IS INITIAL.
    MESSAGE e004(zfi) WITH 'Debe Ingresar Ruta Respado  '.
  ENDIF.

ENDFORM.                    "valido_0200
