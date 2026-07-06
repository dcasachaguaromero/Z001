*----------------------------------------------------------------------*
***INCLUDE LZFI_WS_TRANSFO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  MUESTRA_TEXTO  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE muestra_texto OUTPUT.

  PERFORM lee_texto_hex  USING zfi_ws_transf-text_hex_4110
                         CHANGING gv_texto1.
  PERFORM lee_texto_hex USING zfi_ws_transf-text_hex_4103
                        CHANGING gv_texto2.


ENDMODULE.
