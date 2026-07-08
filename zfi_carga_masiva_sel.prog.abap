*&---------------------------------------------------------------------*
*&  Include           ZFI_CARGA_MASIVA_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_filepc LIKE rlgrap-filename MODIF ID a1 OBLIGATORY.
SELECTION-SCREEN SKIP.
PARAMETERS: p_opc1 RADIOBUTTON GROUP uno DEFAULT 'X',
            p_opc2 RADIOBUTTON GROUP uno.
SELECTION-SCREEN END   OF BLOCK bl2.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_filepc.
  PERFORM leer_pc CHANGING p_filepc.


AT SELECTION-SCREEN ON BLOCK bl2.
  IF p_filepc IS NOT INITIAL.
    PERFORM verifica_archivo USING p_filepc.
  ENDIF.
