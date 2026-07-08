*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZCAMBIAOPE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZCAMBIAOPE.
tables: febep, febko.

selection-screen  begin of block 1 with frame title text-177.
*SELECT-OPTIONS: S_ANWND FOR FEBKO-ANWND,
parameters:
                p_bukrs like febko-bukrs obligatory,                                  "note 620244
                p_hbkid like febko-hbkid obligatory,
                p_hktid like febko-hktid obligatory,
*                s_azdat for febko-azdat,
                p_aznum like febko-aznum obligatory,
                p_gjahr type gjahr obligatory.
*                s_ktonr FOR febko-ktonr,
*                s_waers like febko-waers.

select-options : s_esnum for febep-esnum obligatory.

selection-screen  end of block 1.

data: wa_febep type febep,
      it_febep type standard table of febep,
      it_febko type standard table of febko with header line.

data: gjahr_n(4) type n,
      aznum_n(5) type n,
      w_lines type i,
      w_azidt like febko-azidt.

start-of-selection.
  move: p_gjahr to gjahr_n,
        p_aznum to aznum_n.

  concatenate gjahr_n aznum_n into w_azidt.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  select * from febko client specified into table it_febko
*      where mandt = sy-mandt
*            and anwnd = '0001'
*            and azidt = w_azidt
*            and aznum = p_aznum
*            and bukrs = p_bukrs
*            and hbkid = p_hbkid
*            and hktid = p_hktid.
*
* NEW CODE
  SELECT *
 from febko client specified into table it_febko
      where mandt = sy-mandt
            and anwnd = '0001'
            and azidt = w_azidt
            and aznum = p_aznum
            and bukrs = p_bukrs
            and hbkid = p_hbkid
            and hktid = p_hktid ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  describe table it_febko lines w_lines.
  if w_lines = 1.
    loop at it_febko.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*        select * from febep client specified
*         into table it_febep
*         where mandt = sy-mandt
*            and kukey = it_febko-kukey
*            and esnum in s_esnum
*            and  ( belnr IS NULL OR EPERL <> 'X' ).
*
* NEW CODE
        SELECT *
 from febep client specified
         into table it_febep
         where mandt = sy-mandt
            and kukey = it_febko-kukey
            and esnum in s_esnum
            and  ( belnr IS NULL OR EPERL <> 'X' ) ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 19/12/2019 EY_DES04 ECDK917080 *
SORT IT_FEBEP .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 19/12/2019 EY_DES04 ECDK917080 *
        loop at it_febep into wa_febep.
            wa_febep-INTAG = '11'.
            wa_febep-VGINT = 'ZZ02'.
            wa_febep-INFO1 = 'Sin anotación en el reg.cheq.'.
            wa_febep-INFO2 = 'Sin contab.'.
            modify it_febep index sy-tabix from wa_febep.
        endloop.
        BREAK-POINT.
        update febep from table it_febep.
    endloop.
  endif.

message text-001 type 'I'.
