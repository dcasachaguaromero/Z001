*&---------------------------------------------------------------------*
*&  Include           ZAFTR0002_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK datos WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS : s_bukrs FOR wa_select-bukrs OBLIGATORY,
                 s_anln1 FOR wa_select-anln1,
                 s_anln2 FOR wa_select-anln2,
                 s_afabe FOR wa_select-afabe DEFAULT '01' no-DISPLAY,
                 s_bldat FOR wa_select-bldat,
                 s_ebeln FOR wa_select-ebeln.
SELECTION-SCREEN END OF BLOCK datos.
