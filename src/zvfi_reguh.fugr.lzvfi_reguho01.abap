*----------------------------------------------------------------------*
***INCLUDE LZVFI_REGUHO01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  OCULTA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE oculta OUTPUT.
  DATA: coli        LIKE LINE OF tctrl_zvfi_reguh-cols,
        num_columna TYPE i.
*
** Suponiendo que quiero ocultar la primera columna
  num_columna = 0.
  DO 8 TIMES.
    ADD 1 TO num_columna.
    CASE num_columna.
      WHEN 1 OR 2 OR 4.
      WHEN OTHERS.
        READ TABLE tctrl_zvfi_reguh-cols INTO coli WITH KEY index = num_columna.
        MOVE 'X' TO coli-invisible.
        MODIFY   tctrl_zvfi_reguh-cols FROM coli INDEX num_columna.
    ENDCASE.
  ENDDO.

ENDMODULE.
