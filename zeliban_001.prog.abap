*&---------------------------------------------------------------------*
*& Report  ZELIBAN_001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZELIBAN_001.
tables:  febko,febep.
selection-screen  begin of block 1 with frame title text-b01.
SELECT-OPTIONS:
*s_azdat for febko-azdat,
                s_waers for febko-waers OBLIGATORY,
                s_bukrs for febko-bukrs OBLIGATORY,
                s_hbkid for febko-hbkid OBLIGATORY,
                s_hktid for febko-hktid OBLIGATORY,
                s_aznum for febko-aznum OBLIGATORY.
PARAMETERS: p_gjahr like febep-gjahr OBLIGATORY.
data: s_anwnd like febko-anwnd value '0001',
      R_KUKEY type range of febko-KUKEY,
      r_kukey_line like line of r_kukey,
      wa_febko LIKE febko,
      wa_febep like febep,
      wa_azidt like febko-azidt,
      d_where(1000) type c,
      w_bkpf type bkpf,
      w_flag(1) type c, " Flag to stop program
      l_febep type STANDARD TABLE OF febep WITH HEADER LINE.
* Variables Locales
DATA: lt_seltab TYPE STANDARD TABLE OF rsparams WITH HEADER LINE.
      CONSTANTS c_prog TYPE sy-repid
                       VALUE 'RFEBKA96'.


selection-screen  end of block 1.


************************************************************************
*        Start of Selection
************************************************************************
start-of-selection.
*  CONCATENATE ''' and NOT (eperl = ''' ''' or vb1ok = ''' ''' or vb2ok = ''' ''')' into d_where.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  select * from febko into wa_febko
*    where anwnd = s_anwnd
*          and aznum in s_aznum
*          and bukrs in s_bukrs
*          and waers in s_waers
*          and hbkid in s_hbkid.
*
* NEW CODE
  SELECT *
 from febko into wa_febko
    where anwnd = s_anwnd
          and aznum in s_aznum
          and bukrs in s_bukrs
          and waers in s_waers
          and hbkid in s_hbkid ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    CLEAR wa_febep.
    check wa_febko-azidt+0(4) = p_gjahr.
*    CONCATENATE 'kukey =  ''' wa_febko-kukey d_where  into d_where.
*    select SINGLE eperl from febep into wa_febep
*      where (d_where).
    CLEAR l_febep.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    select * from febep into table l_febep
*    where kukey = wa_febko-kukey.
*
* NEW CODE
    SELECT *
 from febep into table l_febep
    where kukey = wa_febko-kukey ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

    CLEAR w_flag.
    LOOP AT l_febep.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT * into w_bkpf from bkpf
*        where bukrs = wa_febko-bukrs
*              and ( belnr = l_febep-ak1bl or belnr = l_febep-belnr )
*              and gjahr = l_febep-gjahr.
*
* NEW CODE
      SELECT *
 into w_bkpf from bkpf
        where bukrs = wa_febko-bukrs
              and ( belnr = l_febep-ak1bl or belnr = l_febep-belnr )
              and gjahr = l_febep-gjahr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
          IF w_bkpf-stblg < 1.
            w_flag = 'X'.
            exit.
          ENDIF.
      ENDSELECT.
      IF w_flag = 'X'.
        exit.
      ENDIF.
    ENDLOOP.
    check not w_flag = 'X'.
    CLEAR lt_seltab.
    lt_seltab-selname = 'S_ANWND'.
    lt_seltab-sign    = 'I'.
    lt_seltab-option  = 'EQ'.
    lt_seltab-low     = wa_febko-anwnd.
    APPEND lt_seltab.
    CLEAR lt_seltab.
    lt_seltab-selname = 'S_KUKEY'.
    lt_seltab-sign    = 'I'.
    lt_seltab-option  = 'EQ'.
    lt_seltab-low     = wa_febko-kukey.
    APPEND lt_seltab.
  endselect.
*    S_KUKEY
* Si lt_seltab es inicial
  IF lt_seltab is initial.
    message text-003 type 'I'.
    stop.
    LEAVE TO TRANSACTION SY-TCODE.
  ENDIF.
  SUBMIT (c_prog) WITH SELECTION-TABLE lt_seltab
                                          AND RETURN.
