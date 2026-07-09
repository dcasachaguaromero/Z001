*&---------------------------------------------------------------------*
*& Report  ZFI_DOCTOS_SAZR
*&
*&---------------------------------------------------------------------*
*& Objtivo: Actualiza la tabla con documentos SA y ZR
*& Autor  : Ramon Vásquez
*& Fecha  : 04.07.2023
*&**********************************************************************
*& Modificaciones:
*&
*& Objetivo:
*&
*& Autor   : VisionOne
*& Fecha   : dd.mm.aaaa
*&---------------------------------------------------------------------*
REPORT zfi_doctos_sazr LINE-SIZE 1023.

INCLUDE zfidocsazr_top.
INCLUDE zfidocsazr_scr.
INCLUDE zfidocsazr_f01.

*--------------------------------------------------------------------*
* START-OF-SELECTION
*--------------------------------------------------------------------*
START-OF-SELECTION.

*  IF p_pa = true.
    PERFORM OBTENER_DOCTOS_CON_SA.
    PERFORM OBTENER_DOCTOS_CON_ZR.
*  ENDIF.

*--------------------------------------------------------------------*
* END-OF-SELECTION
*--------------------------------------------------------------------*
END-OF-SELECTION.
