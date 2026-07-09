*&---------------------------------------------------------------------*
*&  Include           ZFI_OB52_REPORTE_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'APROBAR'.
      PERFORM aprobar.
    WHEN 'RECHAZAR'.
      PERFORM rechazar.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  TC_ZT001B_CHANGE_FIELD_ATTR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_zt001b_change_field_attr OUTPUT.

*  IF wa_datos-mkoar    EQ wa_zt001b-mkoar AND
*     wa_datos-bkont    EQ wa_zt001b-bkont AND
*     wa_zt001b-aprobar EQ gc_x.
*    LOOP AT SCREEN.
*      screen-intensified = 1.
*      MODIFY SCREEN.
*    ENDLOOP.
*  ENDIF.

  DATA(lv_index2) = line_index( gt_tob52[ mkoar   = wa_zt001b-mkoar
                                          bkont   = wa_zt001b-bkont
                                          aprobar = gc_x ] ).
  IF lv_index2 GT 0.
    LOOP AT SCREEN.
      screen-intensified = 1.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  TC_T001B_CHANGE_FIELD_ATTR  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tc_t001b_change_field_attr OUTPUT.

*  IF wa_datos-mkoar EQ wa_t001b-mkoar AND
*     wa_datos-bkont EQ wa_t001b-bkont.
*    LOOP AT SCREEN.
*      screen-intensified = 1.
*      MODIFY SCREEN.
*    ENDLOOP.
*  ENDIF.

  DATA(lv_index) = line_index( gt_tob52[ mkoar   = wa_t001b-mkoar
                                         bkont   = wa_t001b-bkont
                                         aprobar = gc_x ] ).
  IF lv_index GT 0.
    LOOP AT SCREEN.
      screen-intensified = 1.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDMODULE.
