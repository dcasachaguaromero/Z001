*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*

FUNCTION ZFI_CHECK_SCVARIANT .
*"--------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_PROGNAME) LIKE  SHDSVCI-PROGNAME DEFAULT SPACE
*"     VALUE(I_DYNPRO) LIKE  SY-DYNNR DEFAULT '0000'
*"     VALUE(I_SCVARIANT) TYPE  SCVARIANT DEFAULT SPACE
*"  EXPORTING
*"     REFERENCE(I_SHDSVCI) TYPE  SHDSVCI
*"  EXCEPTIONS
*"      NOT_FOUND
*"--------------------------------------------------------------------
  DATA: L_DYNNR LIKE SHDSVCI-DYNPRO.

* Read variants from data base via function module, direct read from
* SHDSVCI would also do....

  L_DYNNR = I_DYNPRO.     " type cast
  CALL FUNCTION 'RS_HDSYS_VALUES_SC_VARIANT'
    EXPORTING
      I_PROGNAME = I_PROGNAME
      I_DYNPRO   = L_DYNNR
      I_LISTE    = SPACE
    TABLES
      E_SHDSVCI  = SHDSVCI_TAB
    EXCEPTIONS
      OTHERS     = 1.

  READ TABLE SHDSVCI_TAB WITH KEY SCVARIANT = I_SCVARIANT.
  IF SY-SUBRC NE '0'.
    MESSAGE E317(F5A) WITH I_SCVARIANT RAISING NOT_FOUND.
  ELSE.
    DELETE SHDSVCI_TAB WHERE SCVARIANT NE I_SCVARIANT.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
SORT SHDSVCI_TAB .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
    READ TABLE SHDSVCI_TAB INDEX 1 INTO I_SHDSVCI.
  ENDIF.

ENDFUNCTION.
