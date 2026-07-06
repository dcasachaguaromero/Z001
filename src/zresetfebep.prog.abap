*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZRESETFEBEP
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZRESETFEBEP.
TABLES: febep, febko.

selection-screen  begin of block 1 with frame title text-177.
*SELECT-OPTIONS: S_ANWND FOR FEBKO-ANWND,
parameters:
                p_bukrs like febko-bukrs obligatory,                                  "note 620244
                p_hbkid like febko-hbkid obligatory,
                p_hktid like febko-hktid obligatory,
*                s_azdat for febko-azdat,
                p_aznum like febko-aznum obligatory,
                p_gjahr type gjahr OBLIGATORY,
                p_budat like febep-budat OBLIGATORY .
*                s_ktonr FOR febko-ktonr,
*                s_waers like febko-waers.

select-options : s_esnum for febep-esnum obligatory.

selection-screen  end of block 1.

data: wa_febep type febep,
      it_febep type STANDARD TABLE OF febep,
      it_febko TYPE STANDARD TABLE OF febko,
      wa_febko type febko.

data: gjahr_n(4) type n,
      aznum_n(5) type n,
      w_lines type i,
      w_azidt like febko-azidt,
      w_belnr like febep-belnr
      .

START-OF-SELECTION.
  move: p_gjahr to gjahr_n,
        p_aznum to aznum_n.

  concatenate gjahr_n aznum_n into w_azidt.
  select * from febko client specified into table it_febko
      where mandt = sy-mandt
            and anwnd = '0001'
            and azidt = w_azidt
            and aznum = p_aznum
            and bukrs = p_bukrs
            and hbkid = p_hbkid
            and hktid = p_hktid.

  DESCRIBE TABLE it_febko LINES w_lines.
  if w_lines = 1.
    LOOP AT it_febko into wa_febko.
        SELECT * from febep CLIENT SPECIFIED
         INTO TABLE it_febep
         where mandt = sy-mandt
            and kukey = wa_febko-kukey
            and esnum in s_esnum
            and belnr = ' '
            AND AK1BL = ' ' . "OR belnr = w_belnr ).

*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 19/12/2019 EY_DES04 ECDK917080 *
SORT IT_FEBEP .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 19/12/2019 EY_DES04 ECDK917080 *
        LOOP AT it_febep into wa_febep.
*            WA_FEBEP-eperl = ''.
*            WA_FEBEP-vb1ok = ''.
*            WA_FEBEP-vb2ok = ''.
*            WA_FEBEP-pipre = ''.
*            WA_FEBEP-belnr = ''.
*            WA_FEBEP-nbbln = ''.
            wa_febep-budat = p_budat.
            MODIFY it_febep INDEX sy-tabix FROM wa_febep.
        ENDLOOP.
*        wa_febko-dstat = ''.
*        wa_febko-vb1oK = ''.
*        wa_febko-vb2oK = ''.
*        wa_febko-kipre = ''.
*        MODIFY it_febko INDEX sy-tabix FROM wa_febko.
        update febep from table it_febep.
    ENDLOOP.
*    update febko from table it_febko.
  ENDIF.

*    Update FEBEP
*    SET
*      EPERL = ''
*      VB1OK = ''
*      VB2OK = ''
*      PIPRE = ''
*      BELNR = ''
*      NBBLN = ''
*    where KUKEY = p_kukey
*          AND ESNUM = p_esnum.
DESCRIBE TABLE it_febep LINES w_lines.
IF w_lines > 0.
  message text-001 type 'I'.
else.
  MESSAGE 'No se han actualizado valores' TYPE 'I'.
ENDIF.
