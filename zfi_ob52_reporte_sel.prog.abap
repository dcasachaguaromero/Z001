*&---------------------------------------------------------------------*
*&  Include           ZFI_OB52_REPORTE_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS : s_bukrs FOR wa_select-bukrs OBLIGATORY,
                 s_datum FOR wa_select-datum,
                 s_bname FOR wa_select-bname.
SELECTION-SCREEN SKIP.
PARAMETERS     : p_aprob AS CHECKBOX MODIF ID ver.
SELECTION-SCREEN END OF BLOCK block1.

INITIALIZATION.
  PERFORM autorizacion.

  CASE sy-tcode.
    WHEN 'Z_A_OB52'.
      SET TITLEBAR '0100' WITH 'Aprobar o Rechazar el proceso de Var. Periodo Contable'.
      p_aprob = gc_x.
    WHEN OTHERS.
      SET TITLEBAR '0100' WITH 'Reporte de Auditoria del proceso de Var. Periodo Contable'.
  ENDCASE.

AT SELECTION-SCREEN OUTPUT.
  IF sy-tcode EQ 'Z_R_OB52' OR sy-tcode EQ 'SE38'.
    LOOP AT SCREEN.
      CHECK screen-group1 EQ 'VER'.
      screen-active = 0.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
