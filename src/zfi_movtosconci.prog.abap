*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFI_MOVTOSCONCI
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZFI_MOVTOSCONCI.
TABLES: BKPF, FEBEP, T012K, FEBKO.

PARAMETERS: P_BUKRS LIKE FEBKO-BUKRS OBLIGATORY,
            P_HBKID LIKE FEBKO-HBKID OBLIGATORY,
            P_HKTID LIKE FEBKO-HKTID OBLIGATORY,
            p_gjahr like febep-gjahr OBLIGATORY.

types: begin of ty_data,
        kukey like febko-kukey,
        aznum like febko-aznum,
        belnr like febep-belnr,
        gjahr like febep-gjahr,
       end of ty_data.

data: wa_data type ty_data,
      t_data type STANDARD TABLE OF ty_data,
      w_hkont like t012k-hkont.

data: r_belnr type range of febep-belnr,  "range table
      wa_belnr like line of r_belnr.     "work area for range table

data: lt_seltab type standard table of rsparams with header line.
      constants c_prog type sy-repid
                       value 'ZMOVTOSCONTABLES'.


*wa_ebeln-sign   = 'I'.   "I = include, E = exclude
*wa_ebeln-option = 'EQ'.  "EQ, BT, NE ....
*wa_ebeln-low    = '12345678'.
**wa_ebeln-high   =    "not needed unless using the BT option
*append wa_ebeln to r_ebeln.


START-OF-SELECTION.

  lt_seltab-selname = 'P_BUKRS'.
  lt_seltab-sign    = 'I'.
  lt_seltab-option  = 'EQ'.
  lt_seltab-low     = p_bukrs.
  append lt_seltab.

  lt_seltab-selname = 'P_GJAHR'.
  lt_seltab-sign    = 'I'.
  lt_seltab-option  = 'EQ'.
  lt_seltab-low     = p_gjahr.
  append lt_seltab.

select a~kukey a~aznum b~belnr b~gjahr
    into CORRESPONDING FIELDS OF wa_data
    from febep as b inner join febko as a
                on b~kukey eq a~kukey
    where a~bukrs = p_bukrs
          and a~hbkid = p_hbkid
          and a~hktid = p_hktid
          and b~gjahr = p_gjahr.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * from bkpf
*      where bukrs = p_bukrs
*            and belnr = wa_data-belnr
*            and gjahr = wa_data-gjahr.
*
* NEW CODE
    SELECT *
 from bkpf
      where bukrs = p_bukrs
            and belnr = wa_data-belnr
            and gjahr = wa_data-gjahr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      IF bkpf-xreversal > 0.
          lt_seltab-selname = 'S_BELNR'.
          lt_seltab-sign    = 'I'.
          lt_seltab-option  = 'EQ'.
          lt_seltab-low     = wa_data-belnr.
          append lt_seltab.
      ELSE.
          wa_belnr-sign   = 'I'.   "I = include, E = exclude
          wa_belnr-option = 'EQ'.  "EQ, BT, NE ....
          wa_belnr-low    = wa_data-belnr.
*          *wa_ebeln-high   =    "not needed unless using the BT option
          append wa_belnr to r_belnr.
      ENDIF.
    ENDSELECT.
  ENDSELECT.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single hkont from t012k into w_hkont
*    where BUKRS = p_bukrs
*          and HBKID = p_hbkid
*          and HKTID = p_hktid.
*
* NEW CODE
  SELECT hkont
  UP TO 1 ROWS  from t012k into w_hkont
    where BUKRS = p_bukrs
          and HBKID = p_hbkid
          and HKTID = p_hktid ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

SELECT BELNR GJAHR
INTO CORRESPONDING FIELDS OF WA_DATA
from bseg
WHERE bukrs = p_bukrs
and gjahr = p_gjahr
and belnr not in r_belnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*and hkont = w_hkont.
AND HKONT = W_HKONT ORDER BY PRIMARY KEY .
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
          lt_seltab-selname = 'S_BELNR'.
          lt_seltab-sign    = 'I'.
          lt_seltab-option  = 'EQ'.
          lt_seltab-low     = wa_data-belnr.
          append lt_seltab.
  ENDSELECT.


  submit (c_prog) with selection-table lt_seltab
                                          and return.
