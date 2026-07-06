FUNCTION-POOL zfirfc003.                    "MESSAGE-ID ..
TABLES: t077d, nriv.

INCLUDE zbdcrecxy .
DATA: messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.


DATA:    lm_general_detail LIKE lfa1.
DATA:    lm_company_detail LIKE lfb1.
DATA:    lm_bank_detail    LIKE lfbk OCCURS 2 WITH HEADER LINE.


* Definicion de varibles Globales.
DATA: t_error TYPE sy-subrc.
DATA: t_ampli(1) TYPE c..

* Tabla de interna que registrara los errores de validacion de datos en las estructuras.
DATA: BEGIN OF ti_error_acre OCCURS 0.
        INCLUDE STRUCTURE zacreedor.
      DATA: END OF ti_error_acre.
* Tabla de interna que registrara los documentos a contabiliozar.
DATA: BEGIN OF ti_cont_acre OCCURS 0.
        INCLUDE STRUCTURE zacreedor.
        DATA: proc(1) TYPE c.
DATA: END OF ti_cont_acre.
DATA: BEGIN OF ti_bapi_acre OCCURS 0.
        INCLUDE STRUCTURE zacreedor.
      DATA: END OF ti_bapi_acre.


TABLES: lfa1,
        lfb1,
        lfc1,                         " Kred. Umsatzsegment allg.
        lfc3,                         " Kred. Umsatzsegment SHB
        lfas,                         " Steuercodes EG
        lfat,                         " Steuerkategorien
        lfbk,                         " Kred. Bankverbindungen
        lfb5,                         " Kred. Mahndaten
        lfbw,                         " Quellensteuer
        lfza,                         " Abweichende Zahlungsempfänger
        dd03l,
        tfmc.                         " Matchcode table

* BAPI1008   ---------------------------------------------------*
DATA: BEGIN OF hbapi1008,
        lifnr LIKE lfa1-lifnr,
        bukrs LIKE lfb1-bukrs,
      END   OF hbapi1008.

* BAPI1008_4 ---------------------------------------------------*
DATA: BEGIN OF hbapi1008_4,
        lifnr LIKE lfa1-lifnr,
        name1 LIKE lfa1-name1,
        name2 LIKE lfa1-name2,
        name3 LIKE lfa1-name3,
        name4 LIKE lfa1-name4,
        ort01 LIKE lfa1-ort01,
        ort02 LIKE lfa1-ort02,
        pfach LIKE lfa1-pfach,
        pstl2 LIKE lfa1-pstl2,
        pstlz LIKE lfa1-pstlz,
        regio LIKE lfa1-regio,
        stras LIKE lfa1-stras,
        land1 LIKE lfa1-land1,
        pfort LIKE lfa1-pfort,
        spras LIKE lfa1-spras,
      END   OF hbapi1008_4.

* BAPI1008_5 ---------------------------------------------------*
DATA: BEGIN OF hbapi1008_5,
        lifnr LIKE lfa1-lifnr,
        bukrs LIKE lfb1-bukrs,
        busab LIKE lfb1-busab,
        lnrze LIKE lfb1-lnrze,
        lnrzb LIKE lfb1-lnrzb,
        xverr LIKE lfb1-xverr,
        zterm LIKE lfb1-zterm,
        eikto LIKE lfb1-eikto,
        zsabe LIKE lfb1-zsabe,
        intad LIKE lfb1-intad,
        tlfxs LIKE lfb1-tlfxs,
      END   OF hbapi1008_5.

* BAPI1008_6 ---------------------------------------------------*
DATA: BEGIN OF hbapi1008_6,
        lifnr LIKE lfbk-lifnr,
        banks LIKE lfbk-banks,
        bankl LIKE lfbk-bankl,
        bankn LIKE lfbk-bankn,
        bkont LIKE lfbk-bkont,
        bvtyp LIKE lfbk-bvtyp,
        xezer LIKE lfbk-xezer,
        bkref LIKE lfbk-bkref,
      END   OF hbapi1008_6.

* Tables for BABI_CREDITOR_FIND
* Selected vendors for one key (line in the selopt_tab)
DATA: BEGIN OF one_key OCCURS 0,
        vendor_no  LIKE lfa1-lifnr,
        fieldvalue LIKE bapi1008_8-fieldvalue,
        comp_code  LIKE lfb1-bukrs,
      END OF one_key.

* Selected field
DATA: BEGIN OF tab_field OCCURS 1,
        vendor_no LIKE dd03l-fieldname,
        field     LIKE dd03l-fieldname,
        comp_code LIKE dd03l-fieldname,
      END OF tab_field.


* WHERE-Statement
DATA: BEGIN OF tab_where OCCURS 1,
        code(106),
      END OF tab_where.

*ABLES:  T001,
*        BSEG,
*        BSEC,
*        BSED,
*        BSIK,
*        BSAK.

*ANGES:  BSTAT FOR BSIK-BSTAT.

*ATA:    BEGIN OF INTFIELDS,
*          XZAHL LIKE BSIK-XZAHL,
*          UMSKS LIKE BSIK-UMSKS,
*          XCPDD LIKE BSIK-XCPDD,
*        END   OF INTFIELDS.

*ATA:    BEGIN OF XLINEITEMS OCCURS 10.
*          INCLUDE STRUCTURE BAPI1008_2.
*          INCLUDE STRUCTURE INTFIELDS.
*ATA:    END   OF XLINEITEMS.

*ATA:    BEGIN OF SALDO OCCURS 10,
*          UMSKZ LIKE BAPI1008_3-UMSKZ,
*          WAERS LIKE BAPI1008_3-WAERS,
*          SALFW LIKE RF140-SALDO,
*          HWAER LIKE BAPI1008_3-HWAER,
*          SALHW LIKE RF140-SALDO,
*        END   OF SALDO.

* ------ Local Memory --------------------------------------------------
*DATA:    LM_GENERAL_DETAIL LIKE HBAPI1008_4.
*DATA:    LM_COMPANY_DETAIL LIKE HBAPI1008_5.
*DATA:    LM_BANK_DETAIL    LIKE HBAPI1008_6 OCCURS 2 WITH HEADER LINE.

* ------ Berechtigungsprüfungen ----------------------------------------
DATA: BEGIN OF auth,
        actvt LIKE tactz-actvt VALUE '03',
      END   OF auth.

* ------ Messages ------------------------------------------------------
DATA: BEGIN OF message,
        msgty LIKE sy-msgty,
        msgid LIKE sy-msgid,
        msgno LIKE sy-msgno,
        msgv1 LIKE sy-msgv1,
        msgv2 LIKE sy-msgv2,
        msgv3 LIKE sy-msgv3,
        msgv4 LIKE sy-msgv4,
      END OF message.

* ------ Einzelfelder --------------------------------------------------
DATA: gjahr        LIKE bkpf-gjahr,
      haben(10),
      monat        LIKE bkpf-monat,
      perioden(32) TYPE c
                     VALUE ' 1 2 3 4 5 6 7 8 910111213141516',
      rcode        LIKE sy-subrc,
      hrcode       LIKE bapiuid-rcode,
*        HRCODE         LIKE BAPIRFI-RCODE,
      refe1(10),
      refe2(10),
      soll(10),
      umnns        LIKE knc1-um01s,
      umnnh        LIKE knc1-um01h,
      umsatz(10).


* Data for BAPI_CREDITOR_FIND
DATA: offset         LIKE sy-fdpos, "for the WHERE-Statement
      count          LIKE sy-tmaxl, "current number of selected vendors
      vendor_cnt     LIKE sy-tmaxl, "total number of selected vendors
      xccode(1)                , "field COMPANY CODE in the table?
      xlike(1)                , "placeholder in use?
      fieldvalue     LIKE bapi1008_8-fieldvalue, "helpfield for placeholder
      h_return       LIKE bapireturn1,
      line_error(1)  TYPE n, " 0   no errors in the RESULT_TAB line
      " 1   error in the RESULT_TAB line
      table_error(1) TYPE n, " 0   no errors in the RESULT_TAB table
      " 1   error in the RESULT_TAB table
      table_warng(1) TYPE n. " 0   no warning in the RESULT_TAB table
" 1   warning in the RESULT_TAB table


*ATA:    CHAR_X     TYPE C VALUE 'X'.
*ATA:    LINECOUNT TYPE I.

* ------ Feldsymbole  --------------------------------------------------
FIELD-SYMBOLS:
  <s>,
  <h>,
  <u>.
