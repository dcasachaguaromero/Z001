*&---------------------------------------------------------------------*
*&  Include           ZMMR_STOCK_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS : s_matnr FOR wa_select-matnr,
                 s_mtart FOR wa_select-mtart,
                 s_werks FOR wa_select-werks OBLIGATORY,
                 s_lgort FOR wa_select-lgort,
                 s_charg FOR wa_select-charg MATCHCODE OBJECT mch1.
SELECTION-SCREEN SKIP.
SELECT-OPTIONS : s_licha FOR wa_select-licha,
                 s_marca FOR wa_select-atwrt,
                 s_fabri FOR wa_select-atwrt,
                 s_serie FOR wa_select-atwrt.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE TEXT-002.
PARAMETERS: pt_seneg  TYPE  am07m-seneg      DEFAULT   ' '.
PARAMETERS: pt_xmchb  TYPE  am07m-mb52_xmchb DEFAULT   'X'.
PARAMETERS: pt_noze   TYPE  rmmmb-kznul      DEFAULT   'X'.
PARAMETERS: pt_noval  TYPE  am07m-mb52_noval DEFAULT   ' '.
SELECTION-SCREEN END   OF BLOCK bl3.
SELECTION-SCREEN END   OF BLOCK bl2.
