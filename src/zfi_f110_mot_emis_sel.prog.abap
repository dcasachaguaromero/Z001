*&---------------------------------------------------------------------*
*&  Include           ZFI_F110_MOT_EMIS_SEL
*&---------------------------------------------------------------------*
SELECT-OPTIONS : s_bukrs FOR wa_salida-zbukr  MODIF ID pr0,
                 s_laufd FOR f110v-laufd      MODIF ID pr1,
                 s_laufi FOR f110v-laufi      MODIF ID pr2.
*
SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
PARAMETERS   p_mode TYPE ctu_mode DEFAULT 'N' NO-DISPLAY.
PARAMETERS   p_f110 TYPE xflag NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  PERFORM lee_memory_f110.

AT SELECTION-SCREEN ON BLOCK b1.
  PERFORM valida_seleccion.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_laufd-low.
  PERFORM help_laufd CHANGING s_laufd-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_laufd-high.
  PERFORM help_laufd CHANGING s_laufd-high.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_laufi-low.
  PERFORM help_laufi CHANGING s_laufi-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_laufi-high.
  PERFORM help_laufi CHANGING s_laufi-high.

AT SELECTION-SCREEN OUTPUT.
  IF p_f110 EQ gc_x.
    LOOP AT SCREEN.
      CHECK screen-group1(2) EQ 'PR'.
      screen-active   = 0.
      screen-required = 0.
      MODIFY SCREEN.
    ENDLOOP.
  ELSE.
    LOOP AT SCREEN.
      IF screen-name CS 'ZW_'.
        screen-active = 0.
      ENDIF.
      IF screen-group1 EQ 'PR1'.
        IF screen-name NE 'S_LAUFD-HIGH'.
          screen-required = 1.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
