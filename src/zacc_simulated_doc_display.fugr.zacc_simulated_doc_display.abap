*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
FUNCTION zacc_simulated_doc_display .
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(I_T020) LIKE  T020 STRUCTURE  T020 OPTIONAL
*"     VALUE(I_POSTING_FORBIDDEN) TYPE  XFELD OPTIONAL
*"     VALUE(I_DOCUMENT_EXISTS) TYPE  CHAR1 OPTIONAL
*"     VALUE(I_PARKING_FORBIDDEN) TYPE  CHAR1 OPTIONAL
*"     VALUE(TIP_SALIDA) TYPE  CHAR1
*"  EXPORTING
*"     VALUE(E_OKCODE) TYPE  C
*"     VALUE(E_INDEX) LIKE  SY-TABIX
*"  TABLES
*"      T_BKPF STRUCTURE  BKPF
*"      T_BSEG STRUCTURE  BSEG
*"      T_ERINF STRUCTURE  ACERRLOG
*"      T_BSET STRUCTURE  BSET OPTIONAL
*"      XXBSEG STRUCTURE  BSEG OPTIONAL
*"      XXBKPF STRUCTURE  BKPF
*"----------------------------------------------------------------------
*-------- Display of document in one Comp. Code ------------------------


  DATA: ret_code LIKE sy-subrc.                            "Note 328071

*-> BEG INS CNN 21.12.2015
* Exporta a memoria la ti t_bseg para ser leída por el user
* exit ZXAPCU05 del proyecto ZAM_MI
  IF sy-ucomm = 'SAVE'.
    DATA: wa_indx TYPE indx.

    EXPORT tab = t_bseg
      TO DATABASE indx(xy)
      FROM wa_indx
      CLIENT sy-mandt
      ID 'TABLE'.
  ENDIF.
*-> END INS CNN 21.12.2015

  t020 = i_t020.
  g_aktyp = t020-aktyp.                                    "Note 328071
  x_posting_forbidden = i_posting_forbidden.               "Note 308896
  x_parking_forbidden = i_parking_forbidden.                "Note502066
  GET PARAMETER ID 'FO2' FIELD rfopt2.                      "Note449741
  g_document_exists   = i_document_exists.                 "Note 361420
  terrinf[] = t_erinf[].
  REFRESH t_erinf.
  xbset[] = t_bset[].

  CLEAR: bkpf, bseg, xbseg.
  REFRESH xbseg.

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
SORT T_BKPF .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
  READ TABLE t_bkpf INDEX 1.
  bkpf = t_bkpf.
  xbkpf[] = t_bkpf[].
  xbkpf = bkpf.

  archbseg[] = t_bseg[].                                   " Note 565919

* Note 481737: Authority checks of note 328071 and 449741 moved to
* SAPMF05A
  LOOP AT t_bseg.
    MOVE-CORRESPONDING t_bseg TO xbseg.
    IF xbseg-shkzg = 'H'.
      PERFORM change_sign.
    ENDIF.
    PERFORM fill_ktext_konto_faedt.
    APPEND xbseg.
  ENDLOOP.

  IF tip_salida EQ 'X'.
*-- Variant already determined ? Maybe changed by user during first call
    PERFORM uebergabe_strukturen.
    PERFORM feldkatalog_bseg.
    PERFORM list_display.
    e_okcode = okcode.
    e_index  = index.
  ENDIF.
  IF  tip_salida EQ 'S'.
    LOOP  AT xbseg WHERE bukrs NE space.
      MOVE-CORRESPONDING xbseg  TO xxbseg.
      APPEND xxbseg.
    ENDLOOP.
    LOOP  AT xbkpf WHERE bukrs NE space.
      MOVE-CORRESPONDING xbkpf  TO xxbkpf.
      APPEND xxbkpf.
    ENDLOOP.



    e_okcode = okcode.
    e_index  = index.
  ENDIF.


ENDFUNCTION.
