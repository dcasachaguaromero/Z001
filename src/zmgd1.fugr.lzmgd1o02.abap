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
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    select single zmonto_capital into mara-zmonto_capital from mara where matnr EQ MARA-MATNR.
*
* NEW CODE
    SELECT zmonto_capital
    UP TO 1 ROWS  into mara-zmonto_capital from mara where matnr EQ MARA-MATNR ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  endif.

ENDMODULE.                 " GET_DATA  OUTPUT
