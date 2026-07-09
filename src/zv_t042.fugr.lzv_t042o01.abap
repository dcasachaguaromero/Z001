*----------------------------------------------------------------------*
***INCLUDE LZV_T042O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  LEE_TEXTOS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE lee_textos OUTPUT.
  DATA: g_t001 LIKE t001.

  CASE sy-dynnr.
    WHEN '0010' OR '0020'.
      CALL FUNCTION 'FI_COMPANY_CODE_DATA'
        EXPORTING
          i_bukrs      = zv_t042-bukrs
        IMPORTING
          e_t001       = g_t001
        EXCEPTIONS
          system_error = 1
          OTHERS       = 2.
      IF sy-subrc EQ 0.
        zv_t042-butxt = g_t001-butxt.
      ENDIF.
*
      IF zv_t042-absbu IS NOT INITIAL.
        PERFORM t001_lesen USING zv_t042-absbu.
        IF sy-subrc NE 0.
          MESSAGE e001(f3) WITH zv_t042-absbu.
        ELSE.
          absbu_t = *t001-butxt.
        ENDIF.
      ENDIF.
    WHEN '0030'.
      IF zt042_user-username IS NOT INITIAL.
        SELECT SINGLE name_text INTO gv_name_text
               FROM usr21 INNER JOIN adrp
                   ON usr21~persnumber EQ adrp~persnumber
                   WHERE bname EQ zt042_user-username.
      ENDIF.

      IF zt042_user-absbu IS NOT INITIAL.
        PERFORM t001_lesen USING zt042_user-absbu.
        IF sy-subrc NE 0.
          MESSAGE e001(f3) WITH zt042_user-absbu.
        ELSE.
          absbu_t = *t001-butxt.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MODIFY_0020  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_0020 OUTPUT.
  IF t001-bukrs NE zv_t042-bukrs.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM t001 WHERE bukrs =  zv_t042-bukrs.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM t001 WHERE bukrs =  zv_t042-bukrs ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    CLEAR: zbukr_t, absbu_t.
  ENDIF.
*
  IF t005-land1 NE t001-land1.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM t005 WHERE land1 = t001-land1.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM t005 WHERE land1 = t001-land1 ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.
  IF  zv_t042-xbptr IS INITIAL
  AND t005-intca NE 'KR'
  AND t005-landk NE 'ROK'
  AND t005-intca NE 'AR'
  AND t005-landk NE 'RA'
  AND t005-intca NE 'BR'
  AND t005-landk NE 'BRA'.
    LOOP AT SCREEN.
      CHECK screen-name = 'ZV_T042-XBPTR'.
      screen-input = 0.
      screen-output = 0.
      screen-invisible = 1.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF zv_t042-bukrs NE space AND zbukr_t IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE butxt FROM t001 INTO zbukr_t
*                        WHERE bukrs EQ zv_t042-bukrs.
*
* NEW CODE
    SELECT butxt
    UP TO 1 ROWS  FROM t001 INTO zbukr_t
                        WHERE bukrs EQ zv_t042-bukrs ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.
  IF zv_t042-absbu NE space AND absbu_t IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE butxt FROM t001 INTO absbu_t
*                        WHERE bukrs EQ zv_t042-absbu.
*
* NEW CODE
    SELECT butxt
    UP TO 1 ROWS  FROM t001 INTO absbu_t
                        WHERE bukrs EQ zv_t042-absbu ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.

* check jumping in detail dynpro
  IF g_jump EQ space.
* to avoid jumping via push bottoms
    IMPORT g_jump FROM MEMORY ID '42_'.
    IF g_jump NE space.
      CLEAR g_jump.
      EXPORT g_jump TO MEMORY ID '42_'.
      g_jump = 'X'.
    ENDIF.
  ENDIF.
* activate navigation to BUKRS
  LOOP AT SCREEN.
    IF screen-name = 'PUSH2'.
      screen-active = 1.
      screen-input = 1.
      MODIFY SCREEN.
    ENDIF.
    IF screen-name = 'PUSH1'.
      IF g_jump NE space.
        screen-active = 0.
        screen-input = 0.
        MODIFY SCREEN.
      ELSE.
        screen-active = 1.
        screen-input = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  ELIMINA_BOTON  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE elimina_boton OUTPUT.
  excl_cua_funct-function = 'NEWL'.
  APPEND excl_cua_funct.
  excl_cua_funct-function = 'DELE'.
  APPEND excl_cua_funct.
  excl_cua_funct-function = 'ANZG'.
  APPEND excl_cua_funct.
  excl_cua_funct-function = 'KOPE'.
  APPEND excl_cua_funct.
  excl_cua_funct-function = 'ORGI'.
  APPEND excl_cua_funct.
  excl_cua_funct-function = 'MKAL'.
  APPEND excl_cua_funct.
  excl_cua_funct-function = 'MKBL'.
  APPEND excl_cua_funct.
  excl_cua_funct-function = 'MKLO'.
  APPEND excl_cua_funct.
ENDMODULE.
