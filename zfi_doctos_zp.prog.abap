*&---------------------------------------------------------------------*
*& Report  ZFI_DOCTOS_ZP
*&
*&---------------------------------------------------------------------*
*& Objtivo: Actualiza la tabla con documentos ZP
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
REPORT zfi_doctos_zp LINE-SIZE 1023.

INCLUDE zfidoczp_top.
INCLUDE zfidoczp_scr.
INCLUDE zfidoczp_f01.

*--------------------------------------------------------------------*
* START-OF-SELECTION
*--------------------------------------------------------------------*
START-OF-SELECTION.

*  IF p_pa = true.
    PERFORM OBTENER_DOCTOS_ZP.
*  ENDIF.

*--------------------------------------------------------------------*
* END-OF-SELECTION
*--------------------------------------------------------------------*
END-OF-SELECTION.
