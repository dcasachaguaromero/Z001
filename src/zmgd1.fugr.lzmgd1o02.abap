*----------------------------------------------------------------------*
***INCLUDE LZMGD1O02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  GET_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_DATA OUTPUT.

  if sy-tcode EQ 'MM03' or sy-tcode EQ 'MM02'.
    get parameter ID 'MAT' field MARA-MATNR.
    select single zmonto_capital into mara-zmonto_capital from mara where matnr EQ MARA-MATNR.
  endif.

ENDMODULE.                 " GET_DATA  OUTPUT
