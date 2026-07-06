*&---------------------------------------------------------------------*
*& Modulpool         ZSUBBAS01
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

PROGRAM  ZSUBBAS01.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
 IF SY-TCODE = 'FV63' OR SY-TCODE = 'MIR4'.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'INVFO-ZZMOT_EMIS' or
         SCREEN-NAME = 'INVFO-ZZRUT_TERC' or
         SCREEN-NAME = 'INVFO-ZZ_AGENCIA'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " STATUS_0100  OUTPUT
