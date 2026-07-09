*&---------------------------------------------------------------------*
*&  Include           ZSDPROCFAC_PAI
*&---------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       MODULE PAI INPUT                                              *
*---------------------------------------------------------------------*
MODULE PAI INPUT.

  SAVE_OK = OK_CODE.
  CLEAR OK_CODE.

  CASE SAVE_OK.
    WHEN 'SAVE'.
      PERFORM SAVE_DATA.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      PERFORM EXIT_PROGRAM.
    WHEN OTHERS.

  ENDCASE.

ENDMODULE.                    "pai INPUT
