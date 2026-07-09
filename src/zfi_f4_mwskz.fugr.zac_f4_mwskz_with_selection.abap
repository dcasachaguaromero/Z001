*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
function ZAC_F4_MWSKZ_WITH_SELECTION.
*"--------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(I_KALSM) LIKE  T005-KALSM
*"     REFERENCE(I_MWSKZ) LIKE  T007AC-MWSKZ OPTIONAL
*"     REFERENCE(I_STBUK) LIKE  BSEG-STBUK DEFAULT SPACE
*"     REFERENCE(I_KOART) LIKE  BSEG-KOART DEFAULT 'K'
*"     REFERENCE(I_GLVOR) LIKE  BKPF-GLVOR
*"     REFERENCE(I_LSTML) LIKE  T007A-LSTML OPTIONAL
*"     VALUE(I_CONCT) LIKE  BOOLE STRUCTURE  BOOLE DEFAULT 'X'
*"  EXPORTING
*"     VALUE(E_MWSKZ) LIKE  T007AC-MWSKZ
*"--------------------------------------------------------------------
  tables: t007ac.
  data: mwskz like bseg-mwskz,
        rc    like sy-subrc,
        l_text like dd07t-ddtext.
Data:   l_xwia       like  bkpf-xusvr,                       "N850566
        l_t001z      LIKE  t001z,                            "N850566
        l_t007a      like  t007a,                            "N850566
        l_t001       like  t001.                             "N850566

RANGES: P_MWSKZ   FOR T007A-MWSKZ.


  P_MWSKZ-sign    =  'I'.
  P_MWSKZ-option  =  'EQ'.
  P_MWSKZ-low     = 'C0'.
  APPEND P_MWSKZ.

P_MWSKZ-sign    =  'I'.
  P_MWSKZ-option  =  'EQ'.
  P_MWSKZ-low     = 'C9'.
  APPEND P_MWSKZ.


P_MWSKZ-sign    =  'I'.
  P_MWSKZ-option  =  'EQ'.
  P_MWSKZ-low     = 'C7'.
  APPEND P_MWSKZ.


  refresh: fldtab, mwstab.
  perform fill_fieldnames using 'T007AC' 'MWSKZ'.
  perform fill_fieldnames using 'WBACTIONST' 'DESCRIPT'. "text60-field
* begin of note 850566
* If plants abroad active, I check if the cc-code itself shouldn't
* have a plant abroad. Then the List of taxcodes is limited to
* the taxcodes assigned to the company-codes country and taxcodes
* without cc-code.
  CALL FUNCTION 'CHECK_PLANTS_ABROAD_ACTIVE'
       EXPORTING
              i_bukrs       = i_stbuk
       IMPORTING
              e_fi_isactive = l_xwia.
  if l_xwia = 'X'.
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES01 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * from t001z into l_t001z
*                               where bukrs = i_stbuk and
*                                     party = 'PNOWIA'.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  from t001z into l_t001z
                               where bukrs = i_stbuk and
                                     party = 'PNOWIA' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    if sy-subrc = 0.
    else.
      clear l_t001z.
    endif.
    If l_t001z-paval = 'X'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      select single * from t001 into l_t001
*                   where bukrs  = i_stbuk.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  from t001 into l_t001
                   where bukrs  = i_stbuk ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      if sy-subrc = 0.
      else.
        Clear l_t001.
      endif.
    endif.
  endif.
* end of note 850566
*-------- Read table for possible tax indicators -----------------------
  rc = 4.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  select * from t007ac where kalsm = i_kalsm
*                  AND  MWSKZ IN P_MWSKZ.
*
* NEW CODE
  SELECT *
 from t007ac where kalsm = i_kalsm
                  AND  MWSKZ IN P_MWSKZ ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

*------------- MM: only KOART ' ' or 'K' allowed -----------------------
    if i_glvor = 'RMRP'.
      check t007ac-vorgg = space or t007ac-vorgg = 'MMIV'.

*------------- FI: depending on calling transaction --------------------
    else.
      if i_koart = 'K'.
        check ( t007ac-vorgg = space or t007ac-vorgg = 'FIAP' ).
      elseif i_koart ='D'.
        check ( t007ac-vorgg = space or t007ac-vorgg = 'FIAR' ).
      endif.
    endif.
* begin of note 850566
    If l_t001z-paval = 'X'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      select single * from t007a into l_t007a
*                   where kalsm = i_kalsm and
*                         mwskz = t007ac-mwskz.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  from t007a into l_t007a
                   where kalsm = i_kalsm and
                         mwskz = t007ac-mwskz ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      if sy-subrc = 0.
        if l_t007a-lstml = l_t001-land1  or
           l_t007a-lstml is initial.
        else.
          check 1 = 2.
        endif.
      else.
        check 1 = 2.
      endif.
    endif.
* end of note 850566
*-------------- I found one valid entry --------------------------------
    rc = 0.
    perform fill_mwstab using t007ac-mwskz.
    clear t007s-text1.

*-------- Texts for Indicators ---------------------------------------*
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES01 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    select single * from t007s
*      where spras  = sy-langu
*      and   kalsm  = i_kalsm
*      and   mwskz  = t007ac-mwskz.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  from t007s
      where spras  = sy-langu
      and   kalsm  = i_kalsm
      and   mwskz  = t007ac-mwskz ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    if sy-subrc <> 0.                                       "592914
    concatenate t007ac-mwskz '(' ')' into l_text separated by space.
    else.                                                    "592914
    l_text = t007s-text1.
    if not i_conct is initial.                              "Note498576
      perform concatenate using t007s-mwskz changing l_text.
    endif.                                                  "Note498576
    endif.                                                  "592914
    perform fill_mwstab using l_text.
  endselect.

*-------------- No possible tax indicators: display all indicators -----
  if rc ne 0.
* (del) data: loc_conct like boole value 'X'.               "Note498576
    call function 'ZFI_F4_MWSKZ'
      exporting
        i_kalsm = i_kalsm
        i_stbuk = i_stbuk
        i_lstml = i_lstml
* (del) i_conct = loc_conct                                 "Note498576
        i_conct = i_conct                                   "Note498576
        i_glvor = i_glvor
        i_gener = '1'                                      "note 424583
      importing
        e_mwskz = mwskz.
    if not mwskz is initial.
      e_mwskz = mwskz.
    endif.
  else.
    perform help_values_get using 'MWSKZ' space i_mwskz.
  endif.

endfunction.
