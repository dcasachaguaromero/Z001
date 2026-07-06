*&---------------------------------------------------------------------*
*&  Include           ZMM_CONTRATO_ME31K_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_file TYPE localfile OBLIGATORY,
            p_num  TYPE i DEFAULT 1.
SELECTION-SCREEN SKIP.
PARAMETERS: p_mode TYPE ctu_params-dismode DEFAULT 'N'.
SELECTION-SCREEN END OF BLOCK block1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM busqueda_archivo  CHANGING p_file.
