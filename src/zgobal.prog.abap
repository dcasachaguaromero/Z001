*&---------------------------------------------------------------------*
*&  Include           ZGOBAL
*&---------------------------------------------------------------------*
TABLES: *BNKA.
*&---------------------------------------------------------------------*
*&      Module  VAL_BKONT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VAL_BKONT INPUT.

  IF  ZFITR001-BKONT  EQ SPACE.
    SET CURSOR FIELD 'ZFITR001-BKONT' LINE SY-STEPL.
    MESSAGE E013(Z1).
  ENDIF.


  IF ZFITR001-BANKL  EQ SPACE.
    SET CURSOR FIELD 'ZFITR001-BANKL' LINE SY-STEPL.
    MESSAGE E014(Z1).
  ENDIF.
ENDMODULE.                 " VAL_BKONT  INPUT
