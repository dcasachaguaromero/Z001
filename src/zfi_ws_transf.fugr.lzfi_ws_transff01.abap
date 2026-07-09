*----------------------------------------------------------------------*
***INCLUDE LZFI_WS_TRANSFF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LEE_TEXTO_HEX
*&---------------------------------------------------------------------*
FORM lee_texto_hex  USING    p_text_hex
                     CHANGING p_gv_texto1.
  DATA : lv_xtext TYPE xstring.
*
  lv_xtext = p_text_hex.
  CALL FUNCTION 'HR_RU_CONVERT_HEX_TO_STRING'
    EXPORTING
      xstring = lv_xtext
    IMPORTING
      cstring = p_gv_texto1.
ENDFORM.
