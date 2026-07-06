*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
FUNCTION ZFI_VENDOR_CHECK.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_STCD1) TYPE  STCD1
*"  EXPORTING
*"     REFERENCE(E_LIFNR) TYPE  LIFNR
*"  EXCEPTIONS
*"      VENDOR
*"----------------------------------------------------------------------
TABLES: VF_KRED.
data: begin of lm_kred occurs 10.
        include structure vf_kred.
data: end of lm_kred.
data w_sortl like lfa1-sortl.
DATA w_status_a.
data w_status_c.
w_sortl = i_stcd1.
REPLACE ALL OCCURRENCES OF '-' IN w_sortl WITH ''.
*------- Im lokalen Memory werden bis zu 8 Einträge gepuffert ----------
  LOOP AT LM_KRED INTO VF_KRED
                  WHERE SORTL = W_SORTL
                  AND STCD1 = I_STCD1
                  AND   BUKRS = I_BUKRS.
    MOVE VF_KRED-LIFNR TO E_LIFNR.
    EXIT.
  ENDLOOP.
  if sy-subrc ne 0.

      SELECT SINGLE * FROM LFA1 WHERE SORTL = W_SORTL
                                      AND STCD1 = I_STCD1.
      IF NOT SY-SUBRC IS INITIAL.
*        El acreedor no existe en registro maestro
        MESSAGE E104(F5) WITH I_STCD1 I_BUKRS RAISING VENDOR.
*        PERFORM crear_acreedor USING
      ELSE.
        MOVE LFA1-LIFNR TO E_LIFNR.

        CLEAR VF_KRED.
        MOVE-CORRESPONDING LFA1 TO VF_KRED.

        SELECT SINGLE * FROM VF_KRED WHERE  SORTL = W_SORTL
                                            AND STCD1 = I_STCD1
                                            AND   BUKRS = I_BUKRS.
        IF NOT SY-SUBRC IS INITIAL.
*          El acreedor no existe en la sociedad
*          MESSAGE E104(F5) WITH I_STCD1 I_BUKRS RAISING VENDOR.
          perform amplia_acreedor using I_BUKRS I_STCD1 CHANGING w_status_a.
        ELSE.
          MOVE VF_KRED-LIFNR TO E_LIFNR.
        ENDIF.
      ENDIF.


    append vf_kred to lm_kred.
    describe table lm_kred lines sy-tfill.
    if sy-tfill > 8.
*Begin of change: ReSQ Correction for DELETE on an unsorted Internal Table 19/12/2019 EY_DES01 ECDK917080 *
SORT LM_KRED .
*End of change: ReSQ Correction for DELETE on an unsorted Internal Table 19/12/2019 EY_DES01 ECDK917080 *
      delete lm_kred index 1.
    endif.
  endif.

ENDFUNCTION.
