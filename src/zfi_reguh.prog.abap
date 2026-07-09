REPORT zfi_reguh.
*&---------------------------------------------------------------------*
*& Report: ZFI_REGUH                                                   *
*& Author: WALDO ALARCON   (VISIONONE)                                 *
*& Description: AJUSTE DE CAMPOS Z DE LA TABLA REGUH                   *
*&                                                                     *
*& Date: 18-04-2022                                                    *
*& MODIFICACIONES:                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

INCLUDE zfi_reguh_top.
INCLUDE zfi_reguh_sel.
INCLUDE zfi_reguh_f01.

START-OF-SELECTION.
  PERFORM prepara_datos.
