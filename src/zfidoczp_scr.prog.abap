*&---------------------------------------------------------------------*
*&  Include           ZFIDOCZP_SCR
*&---------------------------------------------------------------------*
*
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE text-001.

SELECT-OPTIONS so_bukrs FOR bkpf-bukrs OBLIGATORY
                                       NO INTERVALS NO-EXTENSION.
SELECT-OPTIONS so_CPUDT FOR bkpf-CPUDT.

SELECTION-SCREEN END OF BLOCK a1.

AT SELECTION-SCREEN OUTPUT.
