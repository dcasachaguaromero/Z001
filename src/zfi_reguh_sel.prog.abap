*&---------------------------------------------------------------------*
*&  Include           ZFI_REGUH_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS : s_bukrs  FOR wa_select-bukrs NO-EXTENSION NO INTERVALS
                                              OBLIGATORY,
                 s_laufd  for wa_select-laufd OBLIGATORY,
                 s_laufi  for wa_select-laufi.
SELECT-OPTIONS :  s_idpago FOR wa_select-identif_pago .
SELECTION-SCREEN END OF BLOCK block1.

INITIALIZATION.
  PERFORM autorizacion.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_laufd-low.
  PERFORM f4_laufd CHANGING s_laufd-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_laufd-high.
  PERFORM f4_laufd CHANGING s_laufd-high.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_laufi-low.
  PERFORM f4_laufi CHANGING s_laufi-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_laufi-high.
  PERFORM f4_laufi CHANGING s_laufi-high.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_laufd.
*  PERFORM f4_laufd CHANGING p_laufd
*                            p_laufi.
*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_laufi.
*  PERFORM f4_laufi CHANGING p_laufd
*                            p_laufi.
