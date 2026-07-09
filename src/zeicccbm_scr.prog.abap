*&---------------------------------------------------------------------*
*&  Include           ZEICCCBM_SCR
*&---------------------------------------------------------------------*
*
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE text-001.
*SELECT-OPTIONS so_bukrs FOR bsid-bukrs OBLIGATORY NO INTERVALS NO-EXTENSION.
SELECT-OPTIONS so_bukrs FOR bsid-bukrs DEFAULT 'CL51' OBLIGATORY
                                      NO INTERVALS NO-EXTENSION.
SELECT-OPTIONS so_kunnr FOR bsid-kunnr.

PARAMETERS: p_pa RADIOBUTTON GROUP b1 DEFAULT 'X' USER-COMMAND cmd,
            p_pc RADIOBUTTON GROUP b1.

SELECTION-SCREEN END OF BLOCK a1.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-003.
PARAMETERS : p_feini TYPE bkpf-budat DEFAULT sy-datum MODIF ID a1,
             p_fefin TYPE bkpf-budat DEFAULT sy-datum MODIF ID a1.
SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 EQ 'A1'.
      IF p_pc EQ 'X'.
        screen-active = 1.

      ELSE.
        CLEAR p_pc.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
