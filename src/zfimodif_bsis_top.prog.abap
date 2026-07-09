*&---------------------------------------------------------------------*
*& Include ZFIMODIF_BSIS_TOP               Report ZFIMODIF_BSIS
*&
*&---------------------------------------------------------------------*

REPORT   zfimodif_bsis.

TABLES: bsis.

TYPES: BEGIN OF wreg_bsis,
         bukrs LIKE bsis-bukrs,
         hkont LIKE bsis-hkont,
         gjahr LIKE bsis-gjahr,
         belnr LIKE bsis-belnr,
         buzei LIKE bsis-buzei,
         xopvw LIKE bsis-xopvw,
       END OF wreg_bsis.

DATA: it_bsis TYPE STANDARD TABLE OF wreg_bsis WITH HEADER LINE.

DATA: w_bukrs LIKE skb1-bukrs.
DATA: w_saknr LIKE skb1-saknr.
DATA: w_xopvw LIKE skb1-xopvw.

PARAMETERS: p_bukrs LIKE bsis-bukrs,
            p_gjahr LIKE bsis-gjahr,
            p_hkont LIKE bsis-hkont.

AT SELECTION-SCREEN.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
           ID 'BUKRS' FIELD p_bukrs
           ID 'ACTVT' FIELD '03'.
  IF sy-subrc <> 0.
    MESSAGE e398(00) WITH TEXT-e01 p_bukrs space space.
  ENDIF.
