*&---------------------------------------------------------------------*
*&  Include           ZFI_BANCO_ACREEDOR_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_file TYPE  rlgrap-filename.
SELECTION-SCREEN END OF BLOCK block1.

INITIALIZATION.
  PERFORM autorizacion.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
    PERFORM lee_archivo CHANGING p_file.
