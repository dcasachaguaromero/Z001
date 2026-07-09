*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZBANREP_001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

INCLUDE ZBANREP_001TOP                          .    " global Data

* INCLUDE ZBANREP_001O01                          .  " PBO-Modules
* INCLUDE ZBANREP_001I01                          .  " PAI-Modules
* INCLUDE ZBANREP_001F01                          .  " FORM-Routines

data: w_bktxt type bkpf-bktxt.
**INS INI
data: it_bseg type STANDARD TABLE OF wabsef_type.
**INS FIN
select BUKRS BELNR GJAHR BUZEI from bseg
into CORRESPONDING FIELDS OF TABLE it_bseg
where bukrs eq p_bukrs
and gjahr eq p_gjahr
and belnr in s_belnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*and sgtxt eq ' '.
AND SGTXT EQ ' ' ORDER BY PRIMARY KEY .
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *

**mod ini
LOOP AT it_bseg INTO data(ls_bseg).
  CLEAR w_bktxt.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select SINGLE bktxt into w_bktxt
*      from bkpf
*      where bukrs = ls_bseg-bukrs
*            and gjahr = ls_bseg-gjahr
*            and belnr = ls_bseg-belnr.
*
* NEW CODE
  SELECT bktxt
  UP TO 1 ROWS  into w_bktxt
      from bkpf
      where bukrs = ls_bseg-bukrs
            and gjahr = ls_bseg-gjahr
            and belnr = ls_bseg-belnr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    move w_bktxt to ls_bseg-sgtxt.
    MODIFY it_bseg from ls_bseg.
ENDLOOP.

LOOP AT it_bseg into ls_bseg.
  UPDATE bseg set sgtxt = ls_bseg-sgtxt
    where bukrs = ls_bseg-bukrs
          and gjahr = ls_bseg-gjahr
          and belnr = ls_bseg-belnr
          and buzei eq ls_bseg-buzei.
ENDLOOP.
**mod fin
MESSAGE 'Los datos han sido actualizados' TYPE 'I'.
LEAVE PROGRAM.
