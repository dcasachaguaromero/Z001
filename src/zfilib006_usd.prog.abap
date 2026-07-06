*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*            Libro de retenciones localización Chile                   *
*----------------------------------------------------------------------*
* Nombre Prog.   : ZFILIB006                                           *
* Analista       : Roque Chévez   ( Alynea-MVC )                       *
* Programador    : Francisco Carreño Gallardo ( Alynea-MVC )           *
* Modificado por : Alvaro Vergara Madrid (Alynea-MVC)                  *
* Fecha          : 22/09/2008                                          *
* Objetivo       :                                                     *
*----------------------------------------------------------------------*

REPORT  zfilib006  MESSAGE-ID    icc_cl
                      NO STANDARD PAGE HEADING
                      LINE-SIZE 180.
*                      LINE-COUNT 65.
* TABLE  ***************************************************************
*----------------------------------------------------------------------*

TABLES:      bsak,                    " Vendor cleared items
             bkpf,                    " Posting documents
             bsik,                    " Vendor open items
             bseg,                    " documents
             lfa1,                    " Vendor data
             t001,                    " Company data
             t001z,                   " Add. company data
             tgsb,                    " Busi. area
             tgsbt,                   " Busi. area text
             t059z,                   " Withholding tax codes
             t059zt,                  " Withholding tax code texts
             t059o,                   " Off. name od withh. ax code
             t059p,                   " Withholding tax types
             t059u,                   " Withholding tax type texts
             t015m,
             j_1ainfmet,              " inflation method
             j_1ainft24,              " inflation indices
             j_1ainft04,              " time basis
             skeyreport,
             itcpo,                   " Sap-Script input interface
             itcpp,                   " Sap-Script output interface
             stxh,                    " sap-script texts
             with_item,               " Withholding tax data
             t003t,
             idcn_dotyt.

*----------------------------------------------------------------------*
* DATA *****************************************************************
*----------------------------------------------------------------------*
DATA :
       compytxt       LIKE    t001-butxt,      "Company code text
       qland          LIKE    t001-land1,      "Country code
       farm(1)        TYPE c  VALUE ' ',       "report: farmers
       work(1)        TYPE c  VALUE ' ',       "report: mines
       prof(1)        TYPE c  VALUE ' ',       "report: directors
       ful(1)         TYPE c VALUE ' ',        "report: full report
       ausl(1)        TYPE c VALUE ' ',        "report: foreign tax
       infmt          LIKE t001-infmt,         "inflation method
       periv          LIKE t001-periv,         "variants for period
       number(7)      TYPE n,                  " number for intervals
       ibas           LIKE j_1ainfmet-j_1atbeapp, "infl. basis
       tabix          LIKE sy-tabix,            " Table index
       rfo            LIKE rfopt2,              " disp. doc. new/old
       hlp1(10)       TYPE c,                   " Help fields for
       hlp1a(10)      TYPE c,                   " amount in SAP-script
       hlp2(10)       TYPE c,
       hlp22(10)      TYPE c,
       hlp3(10)       TYPE c,
       hlp3a(10)      TYPE c,
       iact           TYPE i,                            " F4 list or regular list
       found          TYPE    i.                "Any items found

DATA:        idate_desc(100).


DATA: todo(1) TYPE c,                    " zertificate to be printed
      wasum LIKE with_item-wt_qbshh,     " intermediate sums
*       wasum(10) type c,     " intermediate sums
      wasum2 LIKE with_item-wt_qbshh,    " intermediate sums
*       wasum2(10) type c,    " intermediate sums
      hlpstr(13) TYPE c,
      flag(1) TYPE c,
      adr LIKE addr1_val,                 " adress data
      waium LIKE with_item-wt_qbshh,      " intermediate sums
      waium2 LIKE with_item-wt_qbshh.     " intermediate sums

* ---------------------------------------------------------------------

CONTROLS: tabstrip TYPE TABSTRIP.

*----------------------------------------------------------------------*
* RECORDS **************************************************************
* record for sums/period
DATA: BEGIN OF periodsum OCCURS 0,
      witht LIKE with_item-witht,                " Wt tax type
      wt_withcd LIKE with_item-wt_withcd,        " Wt tax code
      lifnr LIKE lfa1-lifnr,                     " vendor number
      poper LIKE t009c-poper,                    " period
      dmbt2 LIKE bsik-dmbtr,                     " amount
      dmbt3 LIKE bsik-dmbtr,                     " amount to be cert.
      imbt2 LIKE bsik-dmbtr,                     " infl amount
      imbt3 LIKE bsik-dmbtr,                     " in amount to be cer.
      wt_qbsh2 LIKE with_item-wt_qbshh,          " tax amount
      wt_qbsh3 LIKE with_item-wt_qbshh,          " tax amount to be cer
      in_qbsh2 LIKE with_item-wt_qbshh,          " inf tax amount
      in_qbsh3 LIKE with_item-wt_qbshh,          " in amount to be cer
     END OF periodsum.
* help table
DATA: BEGIN OF actsum OCCURS 0,
       witht LIKE with_item-witht,
       lifnr LIKE bsik-lifnr,
       poper LIKE t009c-poper,
       wt_withcd LIKE with_item-wt_withcd,
       dmbtr LIKE bsik-dmbtr,
       imbtr LIKE bsik-dmbtr,
       wt_qbshh LIKE with_item-wt_qbshh,
       in_qbshh LIKE with_item-wt_qbshh,
       dmsum LIKE bsik-dmbtr,
       imsum LIKE bsik-dmbtr,
       tosum LIKE with_item-wt_qbshh,
       toium LIKE with_item-wt_qbshh,
      END OF actsum.

* table with SAP-script formulars
DATA: BEGIN OF scripttab OCCURS 0,
       tdname LIKE stxh-tdname,
       tdtitle LIKE stxh-tdtitle,
      END OF scripttab.

DATA:  wa_actsum LIKE actsum,                  " help field for actsum
       wa_oldsum LIKE actsum.                  " help field 2
* record for downloading data to file
DATA: BEGIN OF writerec OCCURS 0,
       rut(9) TYPE c,                             " UST-ID of company
       ano(4) TYPE n,                             " Year
       mes(2) TYPE n,                             " Month
       rutrep(9) TYPE c,                          " UST-ID of vendor
       pat(100) TYPE c,                           " Surname
       mat(40) TYPE c,                            " Blank
       nom(40) TYPE c,                            " First name
       honbr(11) TYPE n,                          " Honorar in period
       rethon(11) TYPE n,                         " WT on honbr
       parti(11) TYPE n,                          " participations
       retparti(11) TYPE n,                       " WT on parti
       cert(7) TYPE n,                            " Certificate number
     END OF writerec.
* ---------------------------------------------------------------------
* INTERNAL TABLES *****************************************************
* ---------------------------------------------------------------------
* Table with index data of highest posting dates/period
DATA: BEGIN OF indextab OCCURS 0,
        index LIKE sy-tabix,
      END OF indextab.

* Table with periods and texts involved
DATA: BEGIN OF periodtext OCCURS 0,
        poper LIKE t009c-poper,
        ltext LIKE t009c-ltext,
        len   TYPE i,
      END OF periodtext.
DATA: ltext TYPE i.

* internal table part_bsak -----------------------
DATA: BEGIN OF part_bsak OCCURS 0.
        INCLUDE STRUCTURE bsik.
DATA: END OF part_bsak.
DATA: BEGIN OF part_bsak2 OCCURS 0.
        INCLUDE STRUCTURE bsak.
DATA: END OF part_bsak2.

* internal table part_bsik -----------------------
DATA: BEGIN OF part_bsik OCCURS 0.
        INCLUDE STRUCTURE bsik.
DATA: END OF part_bsik.

* internal table part_work with al documents found
DATA: BEGIN OF part_work OCCURS 0,
*       bukrs     like   bsik-bukrs,
       blart LIKE bsik-blart,
       lifnr LIKE bsik-lifnr,
       gsber LIKE bsik-gsber,
       belnr LIKE bsik-belnr,
       gjahr LIKE bsik-gjahr,
       buzei LIKE bsik-buzei,
       umsks LIKE bsik-umsks,
       umskz LIKE bsik-umskz,
       bldat LIKE bsik-bldat,
       budat LIKE bsik-budat,
       shkzg LIKE bsik-shkzg,
       dmbtr LIKE bsak-dmbtr,
       dmbe2 LIKE bsak-dmbe2,
       sgtxt LIKE bsak-sgtxt,
       xblnr LIKE bsak-xblnr,
       augbl LIKE bsak-augbl,
       augdt LIKE bsak-augdt,
       zuonr LIKE bsak-zuonr,
*       stblg LIKE bsak-zuonr,
       cont_null TYPE i.

DATA:  END OF part_work.


* Table with vendor data
DATA: BEGIN OF vend_itab OCCURS 0,
       lifnr LIKE lfa1-lifnr,                " Vendor number
       name1 LIKE lfa1-name1,                " Vendor name 1
       name2 LIKE lfa1-name2,                " Vendor name 2
       stcd1 LIKE lfa1-stcd1,                " Tax-number
       stras LIKE lfa1-stras,                " Adress
       ort01 LIKE lfa1-ort01,                " City
       ort02 LIKE lfa1-ort02,                " City
       zertifikat(7) TYPE n,                 " Certificate number
       todo(1) TYPE c.                       " Certificate newprint poss
DATA:  END OF vend_itab.


DATA: BEGIN OF total_table OCCURS 0,

*         BKPF

          xblnr      LIKE bsik-xblnr,
          belnr      LIKE bsik-belnr,
          wt_qsshh    LIKE with_item-wt_qsshh,  " wt base amount
          wt_qbshh    LIKE with_item-wt_qbshh,  " wt amount
          dmbtr       LIKE bsik-dmbtr,          " invoice amount
          dmbe2       LIKE bsik-dmbe2,
          qsatz(8),        "Tasa
          blart      LIKE bsik-blart,
          type_desc(27) TYPE   c,
          type_impuesto(27) TYPE   c,
          count         TYPE i,
          cont_e         TYPE i,
          cont_null         TYPE i,
          augbl LIKE bsik-augbl,
      END OF total_table.

*data: table_impuesto TYPE total_table.

DATA: BEGIN OF table_impuesto  OCCURS 0.
        INCLUDE STRUCTURE total_table.
DATA: END OF table_impuesto .

* table to merge all withholding tax codes
RANGES: s_codei FOR with_item-wt_withcd.

* internal table document header information --
DATA:  BEGIN OF int_bkpf OCCURS 0,
        bukrs LIKE bkpf-bukrs,               "company code
        belnr LIKE bkpf-belnr,               "document number
        gjahr LIKE bkpf-gjahr,               "year
        stblg LIKE bkpf-stblg,               "reversed doc. number
       END OF int_bkpf.


* internal table with all withholding tax types/codes selected
DATA: BEGIN OF code_inh OCCURS 0,
          witht      LIKE with_item-witht, " withholding tax type
          wtext      LIKE t059u-text40,    " withholding tax type text
          code_inh   LIKE t059z-wt_withcd, " withholding tax code
          qscod LIKE t059z-qscod,          " off. withholding tax code
          text40 LIKE t059o-text40,        " withholding tax code text
      END OF code_inh.


* structure for items listed with the ABAP list viewer
TYPES: BEGIN OF out,                                    " structure
            blart       LIKE bsik-blart,
*            blart       type   c,
            witht       LIKE  with_item-witht,    " withholdingt. type
            wt_withcd   LIKE  with_item-wt_withcd," withholdingt.code
            lifnr       LIKE lfa1-lifnr,          " vendor number
            poper       LIKE  t009b-poper,        " Period
            budat       LIKE  bsak-budat,         " posting date
            qscod       LIKE  t059z-qscod,        " off. with.t. code
            stcd1       LIKE lfa1-stcd1,          " RUT
            name1       LIKE lfa1-name1,          " vendor name
            name2       LIKE lfa1-name2,          " vendor name 2
            stras       LIKE lfa1-stras,          " DirecciÃ³n
            ort02(20),   "LIKE lfa1-otr02,          " City
            belnr       LIKE  with_item-belnr,    " document number
            sgtxt       LIKE  bsak-sgtxt,         " document text
            zuonr       LIKE  bseg-zuonr,         " assignment
            xblnr       LIKE  bsid-xblnr,         " ref. number
            gsber       LIKE  bsik-gsber,         " bus. area
            bldat       LIKE  bsak-bldat,         " invoice date
            gjahr       LIKE  with_item-gjahr,    " year
            buzei       LIKE  bsik-buzei,         " posting line
            umsks       LIKE  bsik-umsks,         " Debit/credit ind.
            umskz       LIKE  bsik-umskz,         " Special GL indicator
            dmbtr       LIKE bsik-dmbtr,          " invoice amount
            dmbe2       LIKE bsik-dmbe2,
            dmbt2       LIKE bsik-dmbtr,          "invoice amount/period
            dmbt3       LIKE bsik-dmbtr,          "inv am/per to certify
            wt_qsshh    LIKE with_item-wt_qsshh,  " wt base amount
            wt_qbshh    LIKE with_item-wt_qbshh,  " wt amount
            wt_qbsh2    LIKE with_item-wt_qbshh,  " wt amount/period
            wt_qbsh3    LIKE with_item-wt_qbshh,  " wt amount/period
                                                  " to certify
            qsatz     LIKE with_item-qsatz,        "Tasa
            infac       LIKE j_1ainft24-j_1aindpco,   " infl. factor
            imbtr       LIKE bsik-dmbtr,          " infl. corr. amount
            imbt2       LIKE bsik-dmbtr,          " infl. corr. amount
                                                  " per period
            imbt3       LIKE bsik-dmbtr,          " infl. corr. amount
                                                  " per period to certif
            in_qbshh    LIKE with_item-wt_qbshh,  " infl. corr. wt
            in_qbsh2    LIKE with_item-wt_qbshh,  " infl. corr. wt/per.
            in_qbsh3    LIKE with_item-wt_qbshh,  " infl. corr. wt/per.
                                                  " to certify
            waers       LIKE  t001-waers,         " currency
            augbl       LIKE bsak-augbl,          " cl. doc. number
            augdt       LIKE bsak-augdt,          " cl. doc. date
            box(1)      TYPE c,                   " box for entry
            alv_color(3) TYPE c,                  " Line color
            cont_null TYPE i,
            count       TYPE i,




END OF out.
************************************************************************
* Table with ALV line items
DATA: output_list TYPE out OCCURS 0 WITH HEADER LINE.

************************************************************************
DATA: wa_out TYPE out,                     " help structures for
      wa_out2 TYPE out.                    " ALV item list output_list

* Structure for ALV header table
TYPES: BEGIN OF header,
        witht     LIKE with_item-witht,       " withholding tax type
        wtext40   LIKE t059u-text40,          " withholding tax text
        wt_withcd LIKE  with_item-wt_withcd,  " withholdingt.code
        qscod     LIKE  t059z-qscod,          " off. with.t. code
        text40    LIKE  t059o-text40,         " with.t. name
        stcd1     LIKE lfa1-stcd1,            " RUT (Tax) number
        name1     LIKE lfa1-name1,            " vendor name
        name2     LIKE lfa1-name2,            " vendor name 2
        lifnr     LIKE lfa1-lifnr,            " vendor number
        stras     LIKE lfa1-stras,
        qsatz     LIKE with_item-qsatz,        "Tasa
* sums
        waers     LIKE t001-waers,            " currency
        dmbtr     LIKE bsik-dmbtr,            " Amount
        dmbe2     LIKE bsik-dmbe2,            " Usd
        wt_qbshh  LIKE with_item-wt_qbshh,    " Withholding tax
* sums
        alv_color(3) TYPE c,                  " Line color
        pm(1) TYPE c,                         " Field mark for det.
      END OF header.

* ALV header table
DATA: output_header_table TYPE header OCCURS 0 WITH HEADER LINE.
************************************************************************
* Internal table storing all combinations customer/tax data
* which were really selected
DATA: BEGIN OF usetab OCCURS 0,
        gsber LIKE tgsb-gsber,
        witht LIKE with_item-witht,
        wt_withcd LIKE with_item-wt_withcd,
        lifnr LIKE lfa1-lifnr,
       END OF usetab.

* Help variable to merge different selected values.
RANGES qsskzi FOR with_item-witht.

DATA: maxbdt LIKE bsik-budat.               " Latest posting date
DATA: zertifikat(7) TYPE c,                " Number of certificate
      actform LIKE t042e-wforn,
      sumsub LIKE sy-subrc.
DATA: oftext LIKE t059o-text40,
      usercmd LIKE sy-ucomm,                " user command screen 2000
      filename LIKE rlgrap-filename,        " filename screen 2000
      mess(150) TYPE c,                     "system message string
      gsberex(1) TYPE c,                    " bus. area present
      serverfeld(1) TYPE c,                 " checkbox: write to server

      qkz4 LIKE with_item-wt_withcd,
      qkz5 LIKE with_item-wt_withcd,
      qkz6 LIKE with_item-wt_withcd,
      s_qsskz2 LIKE with_item-witht,
      s_qsskz3 LIKE with_item-witht.
* Parametros eliminados
DATA: p_bas LIKE j_1ainfmet-j_1atbeapp,
      par_dat LIKE sy-datum,
      pform LIKE t042e-wforn,
      indx LIKE j_1ainft24-j_1aindx,
      full(1)  VALUE 'X',
      cert(1),
      p_vari   LIKE disvariant-variant.
DATA: p_cui(4)    TYPE n.

RANGES: s_augdt FOR bsak-augdt .

* ------------------------------------- List header (general)
DATA: BEGIN OF header_info,
       current_buk LIKE  t001-bukrs,
       current_btx LIKE  t001-butxt,
       date        LIKE  sy-datum,
       ruc(12)     TYPE  c,               " RUC number company code
       period      LIKE  bkpf-monat,
       name(20)    TYPE  c,
       date_desc(100),
      END OF header_info.

DATA: BEGIN OF output_list_null OCCURS 0.
        INCLUDE STRUCTURE output_list.
DATA: END OF output_list_null.

DATA: c1 TYPE i,
      c2 TYPE i.

DATA: v_tabix LIKE sy-tabix.

DATA: v_waers TYPE waers VALUE 'USD'.
*----------------------------------------------------------------------*
* SECTION SCREEN *******************************************************
*----------------------------------------------------------------------*

* ------------------------------------------------  general information

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK one WITH FRAME TITLE text-064.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (31) text-010 FOR FIELD s_compy.
*PARAMETERS      s_compy     LIKE t001-bukrs OBLIGATORY DEFAULT '0100'.
PARAMETERS      s_compy     LIKE t001-bukrs OBLIGATORY.
SELECTION-SCREEN END OF LINE.
SELECT-OPTIONS  s_busa       FOR bseg-gsber.
PARAMETERS:      s_year       LIKE bsak-gjahr OBLIGATORY
                                                DEFAULT sy-datum+0(4).

PARAMETERS:      s_month      LIKE bsak-monat OBLIGATORY
                                                DEFAULT sy-datum+4(2).
SELECT-OPTIONS  s_kred       FOR  bsak-lifnr.
SELECT-OPTIONS  s_belnr     FOR  bsak-belnr .
SELECT-OPTIONS  s_blart     FOR  bsak-blart OBLIGATORY.
*SELECT-OPTIONS  s_blart     FOR  IDCN_DOTYT-INVTP.

SELECTION-SCREEN END OF BLOCK one.


* block for professionals
SELECTION-SCREEN BEGIN OF SCREEN 1001 AS SUBSCREEN.
* SELECTION-SCREEN BEGIN OF BLOCK prof WITH FRAME TITLE TEXT-051.
*     block with withholding tax information
PARAMETERS: s_qsskz1 LIKE with_item-witht OBLIGATORY DEFAULT 'Q1'.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(33) text-099 FOR FIELD qkz3.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS: qkz3 LIKE with_item-wt_withcd OBLIGATORY DEFAULT 'B1'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(33) text-098 FOR FIELD qkz0.
SELECTION-SCREEN POSITION POS_LOW.
PARAMETERS: qkz0 LIKE with_item-wt_withcd OBLIGATORY DEFAULT 'B1'.
SELECTION-SCREEN END OF LINE.


SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(33) text-100 FOR FIELD p_def.
PARAMETERS: p_def AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF SCREEN 1001.

*selection-screen skip.
SELECTION-SCREEN BEGIN OF BLOCK wahl WITH FRAME TITLE text-065.
SELECTION-SCREEN BEGIN OF TABBED BLOCK tabs1 FOR 4 LINES.
SELECTION-SCREEN TAB (21) tab1 USER-COMMAND uco1
                 DEFAULT SCREEN 1001.

SELECTION-SCREEN END OF BLOCK tabs1.
SELECTION-SCREEN END OF BLOCK wahl.
* ----------------------------------------------------------------------
* SELEKTION SCREEN *****************************************************
* ----------------------------------------------------------------------
AT SELECTION-SCREEN.
*  abap list viewer

  CLEAR: farm, work, prof, ausl, ful.
  CASE sy-ucomm.
    WHEN 'UCO1'. tabs1-activetab(4) = 'UCO1'.
    WHEN 'UCO2'. tabs1-activetab(4) = 'UCO2'.
    WHEN 'UCO5'. tabs1-activetab(4) = 'UCO5'.
  ENDCASE.
  IF sy-ucomm NE 'UCO1' AND sy-ucomm NE 'UCO2' AND sy-ucomm NE
     'UCO3' AND sy-ucomm NE 'UCO4' AND sy-ucomm NE 'UCO5'.
    CASE tabs1-activetab(4).
      WHEN 'UCO1'. prof = 'X'.
      WHEN 'UCO5'.
        IF full = ' '.
          tabs1-dynnr = '1005'.
          tabs1-activetab = 'UCO5'.
          MESSAGE e029(icc_cl).
        ELSE.
          ful = 'X'.
        ENDIF.
*      when others. message e040(icc_cl).
    ENDCASE.
*  look if all data are present
    IF prof = 'X'.
      IF s_qsskz1 IS INITIAL.
        tabs1-dynnr = '1001'.
        tabs1-activetab = 'UCO1'.
        MESSAGE e025(icc_cl).
      ENDIF.
    ENDIF.


  ENDIF.

* form check
  IF actform NE space AND full <> 'X'.
    SELECT SINGLE * FROM stxh WHERE tdobject = 'FORM' AND
                                    tdname = actform  AND
                                    tdspras = sy-langu.
    IF sy-subrc <> 0.
      SELECT SINGLE * FROM stxh CLIENT SPECIFIED
                                   WHERE mandt = '000' AND
                                         tdobject = 'FORM' AND
                                         tdname = actform  AND
                                         tdspras = sy-langu.
      IF sy-subrc <> 0.
        MESSAGE e562(icc_cl) WITH actform.
      ENDIF.
    ENDIF.
  ENDIF.

*   check type codes
  PERFORM   check_type_code       USING     qland.



AT SELECTION-SCREEN ON BLOCK one.
*   authority check
*  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
*    ID 'BUKRS' FIELD s_compy
*    ID 'ACTVT' FIELD '01'.

  IF sy-subrc <> 0.
*--------'No authorization for company code &'------------------------
    MESSAGE e526(icc_tr) WITH s_compy.
  ENDIF.

*  information:  company code
  PERFORM   read_bukrs_data   CHANGING  compytxt
                                        qland infmt periv.

*   Read business area data.
*    PERFORM READ_GSBER_DATA.



INITIALIZATION.
* define tab-strip data
  tabs1-dynnr = '1001'.                  "first tabstrip screen active
  tabs1-activetab = 'UCO1'.              "set names of tabstrip screens
  tab1 = text-003.

  REFRESH s_blart.
  MOVE: 'B1' TO s_blart-low,
        'I'    TO s_blart-sign,
        'EQ'   TO s_blart-option.

  MOVE: 'B2' TO s_blart-high,
        'I'    TO s_blart-sign,
        'EQ'   TO s_blart-option.
  APPEND s_blart.

* initialization list viewer end -------------------

*----------------------------------------------------------------------*
* START OF SELECTION ***************************************************
*----------------------------------------------------------------------*
*START-OF-SELECTION.

START-OF-SELECTION.
*  IF p_def = 'X'.
*    PERFORM submit_report.
*  ENDIF.

  PERFORM year_period_to_date USING s_year s_month.

  PERFORM main_access_pay.

  SORT part_work   BY blart
*                      belnr
*                      gjahr
*                      buzei
                      .

*perform read_bsak.
  PERFORM   read_with_item_pay    USING  qland.

*  perform headbuild.
*----------------------------------------------------------------------*
* END OF SELECTION *****************************************************
*----------------------------------------------------------------------*

END-OF-SELECTION.




*  PERFORM DELETE_DOCTOS_ANULADOS.
  LOOP AT output_list WHERE cont_null = 1.
    v_tabix = sy-tabix.
    MOVE output_list  TO output_list_null.
    APPEND output_list_null.
*    DELETE output_list.

    output_list-dmbtr = 0.
    output_list-dmbe2 = 0.
    output_list-dmbt2  = 0.
    output_list-dmbt3  = 0.
    output_list-wt_qsshh  = 0.
    output_list-wt_qbshh  = 0.
    output_list-wt_qbsh2  = 0.
    output_list-wt_qbsh3 = 0.
    output_list-qsatz  = 0.
    output_list-infac  = 0.
    output_list-imbtr = 0.
    output_list-imbt2 = 0.
    output_list-imbt3  = 0.
    output_list-in_qbshh  = 0.
    output_list-in_qbsh2  = 0.
    output_list-in_qbsh3  = 0.
*    ADD 1 TO output_list-cont_null.
    output_list-name1 = '***DOCUMENTO NULO***'.
    MODIFY output_list INDEX v_tabix.
    CLEAR: output_list.
  ENDLOOP.

  SORT output_list BY witht wt_withcd lifnr poper budat belnr.
  DESCRIBE TABLE output_list LINES found.


  PERFORM delete_doctos_anulados.



  IF found = 0.
    MESSAGE s100.
  ELSE.
    PERFORM get_date_desc.

*    IF p_def = 'X'.
*      PERFORM write_header.
*    ELSE.
    PERFORM write_header_draft.
*    ENDIF.
    PERFORM write_line_header.

    PERFORM print_final.

    PERFORM resumen.
  ENDIF.

TOP-OF-PAGE.
**=====================================================================
*end-of-page.
**=====================================================================
*=====================================================================
AT LINE-SELECTION.
*=====================================================================
  PERFORM at_line_selection.


*TOP-OF-PAGE.

*  IF p_def = 'X'.
*    PERFORM write_header.
*  ELSE.
*    PERFORM WRITE_HEADER_DRAFT.
*  ENDIF.
*  PERFORM write_line_header.
*  perform resumen.
************************************************************************
*----------------------------------------------------------------------*
* FORM ROUTINES  *******************************************************
*----------------------------------------------------------------------*



********************************************************************
* ----------------------
* form storno
* ----------------------

FORM storno      TABLES      int_bkpf STRUCTURE int_bkpf
                 USING       wa STRUCTURE bsak s_compy
                 CHANGING    ok.

  DATA:  BEGIN OF wa_bkpf,
          bukrs LIKE bkpf-bukrs,
          belnr LIKE bkpf-belnr,
          gjahr LIKE bkpf-gjahr,
          stblg LIKE bkpf-stblg,
         END OF wa_bkpf.

  CLEAR: wa_bkpf.

  READ TABLE int_bkpf WITH KEY
                        bukrs       =  s_compy
                        belnr       =  wa-belnr
                        gjahr       =  wa-gjahr
       INTO wa_bkpf.

  IF sy-subrc <> 0.

    SELECT SINGLE * FROM  bkpf  INTO CORRESPONDING FIELDS OF
                    wa_bkpf
           WHERE  bukrs       =  s_compy
           AND    belnr       =  wa-belnr
           AND    gjahr       =  wa-gjahr.

    APPEND wa_bkpf TO int_bkpf.

  ENDIF.

*    the document mustnÂ´t be a reverse document
  IF NOT wa_bkpf-stblg IS INITIAL.

    ok = ' '.

  ENDIF.

ENDFORM.                    "STORNO

************************************************************************


* -----------------
* form main_access_pay
* -----------------

FORM main_access_pay.

  REFRESH:  part_bsik, part_bsak, part_work.
  DATA: ok(1) TYPE c.
  DATA: con_null TYPE i.
  DATA: sumsub LIKE sy-subrc.


* DATABASE ACCESS *****************************************************
***********************************************************************
*  SELECT    * FROM  bsak  INTO TABLE part_bsak
  SELECT    * FROM  bsik  INTO TABLE part_bsak
               WHERE  bukrs       =  s_compy
               AND    lifnr       IN s_kred
               AND    gjahr       =  s_year
               AND    monat       = s_month
               AND    gsber       IN s_busa
****               AND    augdt       IN s_augdt
               AND    blart       IN s_blart
               AND    belnr       IN s_belnr.
*               AND    BUDAT       IN S_BUDAT.
  sumsub = sy-subrc.
  SELECT    * FROM  bsak  INTO  TABLE part_bsak2
               WHERE  bukrs       =  s_compy
               AND    lifnr       IN s_kred
               AND    gjahr       =  s_year
               AND    monat       = s_month
               AND    gsber       IN s_busa
****               AND    augdt       IN s_augdt
               AND    blart       IN s_blart
               AND    belnr       IN s_belnr.
*                and    SHKZG       = 'S'.
*               AND    BUDAT       IN S_BUDAT.

***********************************************************************
* DATABASE ACCESS *****************************************************
* delete unnecessary entries in table part_bsak
  con_null = 0.
  LOOP AT part_bsak.

    ok = 'X'.
    IF part_bsak-belnr = part_bsak-augbl AND
       part_bsak-budat = part_bsak-augdt.
      ok = ' '.
    ENDIF.
*   look for reversal document
    PERFORM storno TABLES      int_bkpf
                   USING       part_bsak s_compy
                   CHANGING    ok.

    IF part_bsak-shkzg = 'H'.
      MULTIPLY part_bsak-dmbe2 BY -1.
*      MULTIPLY part_bsak-dmbtr BY -1.
    ENDIF.

*    copy to work table with document numbers.
    IF ok EQ 'X'.
      part_work-cont_null = 0.
      MOVE-CORRESPONDING part_bsak TO part_work.
      APPEND part_work.
    ELSE.
      part_work-cont_null = 1.
      MOVE-CORRESPONDING part_bsak TO part_work.
      APPEND part_work.
    ENDIF.
  ENDLOOP.
*  delete table part_bsak
*************+
  LOOP AT part_bsak2.
    ok = 'X'.
    IF part_bsak2-belnr = part_bsak2-augbl AND
       part_bsak2-budat = part_bsak2-augdt.
      ok = ' '.
    ENDIF.
*   look for reversal document
    PERFORM storno TABLES      int_bkpf
                   USING       part_bsak2 s_compy
                   CHANGING    ok.
    IF part_bsak2-shkzg = 'H'.
      MULTIPLY part_bsak2-dmbe2 BY -1.
*      MULTIPLY part_bsak2-dmbtr BY -1.
    ENDIF.

*    copy to work table with document numbers.
    IF ok EQ 'X'.
*      part_work-CONT_NULL = 0.
      MOVE-CORRESPONDING part_bsak2 TO part_work.
      APPEND part_work.
    ELSE.
      part_work-cont_null = 1.
      MOVE-CORRESPONDING part_bsak2 TO part_work.
      APPEND part_work.
    ENDIF.
    CLEAR:part_work.
  ENDLOOP.

*****************
  FREE part_bsak.

*perform read_bsak.
ENDFORM.                    "MAIN_ACCESS_PAY



** ---------------------------------------
** form read_bukrs_data
*+ ---------------------------------------

******************************************
* read additional company code information
******************************************

FORM   read_bukrs_data
                CHANGING  compytxt       LIKE  t001-butxt
                          qland          LIKE  t001-land1
                          infmt          LIKE  t001-infmt
                          periv          LIKE  t001-periv.

  DATA: adr_sele LIKE addr1_sel.



  CLEAR :  compytxt,
           qland.

  SELECT  SINGLE * FROM  t001
     WHERE  bukrs       = s_compy.

  IF sy-subrc = 0.
    MOVE  t001-butxt  TO  header_info-current_btx.
  ELSE.
    MESSAGE e551(icc_cl) WITH s_compy.
    SET CURSOR FIELD s_compy.
  ENDIF.

  MOVE  t001-land1  TO  qland.
  MOVE  t001-infmt  TO  infmt.
  MOVE  t001-periv  TO  periv.
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES02 ECDK917080 *
  SELECT SINGLE * FROM t001z WHERE bukrs = s_compy AND
                                   party = 'TAXNR'.
  IF sy-subrc <> 0.
    MESSAGE e552(icc_cl) WITH s_compy.
  ENDIF.

  header_info-ruc = t001z-paval.

* get adress data:
  adr_sele-addrnumber = t001-adrnr.
  CALL FUNCTION 'ADDR_GET'
       EXPORTING
            address_selection       = adr_sele
*           ADDRESS_GROUP           =
*           READ_SADR_ONLY          = ' '
*           READ_TEXTS              = ' '
       IMPORTING
            address_value           = adr
*           ADDRESS_ADDITIONAL_INFO =
*           RETURNCODE              =
*           ADDRESS_TEXT            =
*           SADR                    =
*      TABLES
*           ADDRESS_GROUPS          =
*           ERROR_TABLE             =
*           VERSIONS                =
       EXCEPTIONS
            parameter_error         = 1
            address_not_exist       = 2
            version_not_exist       = 3
            internal_error          = 4
            OTHERS                  = 5.

  IF sy-subrc <> 0.
*    message e069(01).
  ENDIF.

ENDFORM.                    "READ_BUKRS_DATA

************************************************************************

** ----------------------------------------
** form read_with_item_pay
** ----------------------------------------

FORM  read_with_item_pay  USING  qland LIKE t001-land1.

  DATA: buper LIKE t009b-poper,
       adjamo LIKE bseg-dmbtr,               " Inflation adjusted amount
        dmbtr(18) TYPE c,
        dmbt2  LIKE bseg-dmbtr,
        flag(1) TYPE c,
        wa_out TYPE out,                     " help structures for
        wa_out2 TYPE out,                    " ALV item list output_list
       wa_out3 TYPE out,                    " ALV item list output_list2
      rc(1) TYPE c,                        " flag indicating first entry
        gesjahr  LIKE t009b-bdatj.
  DATA: BEGIN OF wa_vend,
           name1 LIKE lfa1-name1,
           name2 LIKE lfa1-name2,
           lifnr LIKE lfa1-lifnr,
           stcd1 LIKE lfa1-stcd1.
  DATA:  END OF wa_vend.
  DATA: index LIKE sy-tabix.

  REFRESH: output_list.
  CLEAR: maxbdt.
  IF NOT par_dat IS INITIAL.
    maxbdt = par_dat.
  ENDIF.
* loop over all relevant entries in bsak, bsik
  LOOP AT part_work.

*  look for corresponding tax entries
    SELECT  * FROM  with_item  INTO CORRESPONDING FIELDS
              OF with_item
           WHERE  bukrs       = s_compy
           AND    belnr       = part_work-belnr
           AND    gjahr       = part_work-gjahr
           AND    buzei       = part_work-buzei
           AND    witht         IN qsskzi
           AND    wt_acco     = part_work-lifnr
           AND    wt_withcd     IN s_codei.
*           AND    wt_qbshh    NE '0.00'.
*  a tax entry has been found: read additional data
      IF sy-subrc = 0.
*  determine latest posting date only if not parameter value given
        IF part_work-budat GT maxbdt AND par_dat IS INITIAL.
          maxbdt = part_work-budat.
        ENDIF.
* --- get vendor data --------------------------------------------------
        READ TABLE vend_itab WITH KEY lifnr = with_item-wt_acco.

        IF sy-subrc <> 0.
*     no vendor information in internal table: read from database
          SELECT SINGLE * FROM lfa1
                 INTO CORRESPONDING FIELDS OF  vend_itab
                 WHERE  lifnr  = with_item-wt_acco.
          IF sy-subrc <> 0.
            MESSAGE e749(ei) WITH with_item-wt_acco.
          ELSE.
*         move-corresponding wa_vend to vend_itab.
            vend_itab-todo = ' '.
            APPEND vend_itab.
          ENDIF.
        ENDIF.


*----  get additional tax information ----------------------------------
        CLEAR: code_inh.
        READ TABLE code_inh WITH KEY witht = with_item-witht
                                     code_inh = with_item-wt_withcd.
        IF sy-subrc <> 0.
          MESSAGE e007(icc_cl) WITH with_item-wt_withcd.
        ENDIF.
* Build a line in output-list
        CLEAR output_list.
* Vendor data
        MOVE-CORRESPONDING vend_itab TO output_list.
* Tax data
        MOVE code_inh-witht    TO output_list-witht.
        MOVE code_inh-code_inh TO output_list-wt_withcd.
        MOVE code_inh-qscod    TO output_list-qscod.
* Document data
        MOVE part_work-gsber TO output_list-gsber.
        MOVE part_work-belnr TO output_list-belnr.
        MOVE part_work-sgtxt TO output_list-sgtxt.
        MOVE part_work-zuonr TO output_list-zuonr.
        MOVE part_work-xblnr TO output_list-xblnr.
        MOVE part_work-buzei TO output_list-buzei.
        MOVE part_work-umsks TO output_list-umsks.
        MOVE part_work-umskz TO output_list-umskz.
        MOVE part_work-bldat TO output_list-bldat.
        MOVE part_work-budat TO output_list-budat.
        MOVE part_work-gjahr TO output_list-gjahr.
        MOVE part_work-augbl TO output_list-augbl.
        MOVE part_work-augdt TO output_list-augdt.

        MOVE part_work-blart TO output_list-blart.

        MOVE part_work-budat+4(2) TO output_list-poper.
        MOVE part_work-cont_null TO output_list-cont_null.
*        MOVE part_work-dmbtr TO output_list-dmbtr.
        output_list-dmbtr =  with_item-wt_qbsh2 - with_item-wt_qssh2.
*        output_list-dmbtr = with_item-wt_qsshh - with_item-wt_qbshh.
        MOVE t001-waers TO output_list-waers.
        MOVE with_item-wt_qbshh TO dmbtr.

        MOVE with_item-wt_qbsh2 TO output_list-wt_qbshh.
        MOVE with_item-wt_qssh2 TO output_list-wt_qsshh.



        MOVE with_item-qsatz TO output_list-qsatz.

        output_list-count = 1.
*      deactivate box for full withholding tax report
        IF ful = 'X'.
          output_list-box = '1'.
        ENDIF.
        APPEND output_list.
      ENDIF.
    ENDSELECT.
  ENDLOOP.

* get inflation adjusted values
  IF NOT cert IS INITIAL.   "
    LOOP AT output_list.

* ---- get inflation adjusted amount value
      CALL FUNCTION 'J_1A_INFLATION_CALCULATION_FI'
           EXPORTING
                amount                      = output_list-dmbtr
                origin_tbep                 = ibas
                origin_date                 = output_list-budat
                final_tbep                  = ibas
                final_date                  = maxbdt
                specific_index              = indx
*cs              specific_version            = vers
           IMPORTING
               adj_amount                  = output_list-imbtr
      EXCEPTIONS
             time_base_data_not_found = 1
             exposure_date_not_found = 2
             index_definition_not_found = 3
             index_values_not_found = 4
             definitive_values_not_found = 5.

      IF sy-subrc <> 0.
*        message e445(icc_cl) with output_list-belnr.
      ELSE.
        output_list-infac = output_list-imbtr / output_list-dmbtr.
        output_list-in_qbshh = output_list-infac * output_list-wt_qbshh.
        MODIFY output_list TRANSPORTING infac in_qbshh imbtr.
      ENDIF.

    ENDLOOP.
  ENDIF.

* get sums per period and sums/period to be certified
*  sort for treatment of sums per tax/vendor/period

  SORT output_list BY witht wt_withcd lifnr poper budat belnr.

  REFRESH: periodsum.
  CLEAR: wa_out2.
  LOOP AT output_list.
    index = sy-tabix.
    PERFORM akku USING output_list
                       CHANGING wa_out2.

    AT END OF poper.
*   fill an entry of table with periodsums
      PERFORM recbuild USING wa_out2.
      indextab-index = index.
      APPEND indextab.
      CLEAR: wa_out2-dmbt2, wa_out2-dmbt3, wa_out2-imbt2, wa_out2-imbt3,
             wa_out2-wt_qbsh2, wa_out2-wt_qbsh3, wa_out2-in_qbsh2,
             wa_out2-in_qbsh3.

*    get period text.
      CALL FUNCTION 'GET_PERIOD_TEXTS_BASIS'
           EXPORTING
                i_spras                       = sy-langu
                i_periv                       = periv
                i_poper                       = output_list-poper
*                 I_BDATJ                       = S_YEAR
           IMPORTING
*                  E_KTEXT                       =
                e_ltext                       = periodtext-ltext
*                 E_T009C                       =
           EXCEPTIONS
                period_version_not_found      = 1
                period_texts_not_found        = 2
                period_version_year_dependent = 3
                version_not_year_dependent    = 4
                OTHERS                        = 5.
      IF sy-subrc <> 0.
        MESSAGE e123(icc_cl) WITH output_list-poper periv.
      ELSE.
        periodtext-len = STRLEN( output_list-poper ).
        periodtext-poper = output_list-poper.
        APPEND periodtext.
      ENDIF.
    ENDAT.
  ENDLOOP.

  LOOP AT periodsum.
*   find index in output_list: get line from indextab
    READ TABLE indextab INDEX sy-tabix.
    IF sy-subrc <> 0.
      MESSAGE e124(icc_cl) WITH 'indextab'.
    ENDIF.
*    the index is now indextab-index
    READ TABLE output_list INDEX indextab-index.
    IF sy-subrc <>  0.
      MESSAGE e124(icc_cl) WITH 'output_list'.
    ENDIF.

    output_list-dmbt2 = periodsum-dmbt2.
    output_list-imbt2 = periodsum-imbt2.
    output_list-wt_qbsh2 = periodsum-wt_qbsh2.
    output_list-in_qbsh2 = periodsum-in_qbsh2.
    output_list-dmbt3 = periodsum-dmbt3.
    output_list-imbt3 = periodsum-imbt3.
    output_list-wt_qbsh3 = periodsum-wt_qbsh3.
    output_list-in_qbsh3 = periodsum-in_qbsh3.
*     if thers an amount to be certified update table with
*     vendor data with flag todo = 'X'.
    IF NOT periodsum-dmbt3 IS INITIAL.
      READ TABLE vend_itab WITH KEY lifnr = periodsum-lifnr.
      IF sy-subrc <> 0.
        MESSAGE e021(icc_cl) WITH periodsum-lifnr.
      ENDIF.
      vend_itab-todo = 'X'.
      MODIFY vend_itab INDEX sy-tabix TRANSPORTING todo.
    ENDIF.


    MODIFY output_list INDEX indextab-index TRANSPORTING
           dmbt2 imbt2 wt_qbsh2 in_qbsh2 dmbt3 imbt3
           wt_qbsh3 in_qbsh3.
  ENDLOOP.

*  build table with AL header data
  PERFORM headbuild.


ENDFORM.                    "READ_WITH_ITEM_PAY
************************************************************************
* ----------------------
* form check_type_code
* ----------------------

******************************************************************
* are the selected withholding tax codes correct
******************************************************************

FORM check_type_code   USING     country  LIKE  t001-land1.
  DATA: text LIKE t059zt-text40,      " text help string
        hit(1) TYPE c.                 " help:  one selection successful

  REFRESH:   code_inh.

* merge different selection parameters to global selection field
* Block for professionals
*  get withholding tax type
  qsskzi-sign = 'I'.
  qsskzi-option = 'EQ'.
  qsskzi-low = s_qsskz1.
  APPEND qsskzi.
*  get withholding tax code
  CLEAR: s_codei.
  REFRESH: s_codei.
  s_codei-sign = 'I'.
  s_codei-option = 'EQ'.
  s_codei-low = qkz3.
  APPEND s_codei.
  s_codei-sign = 'I'.
  s_codei-option = 'EQ'.
  s_codei-low = qkz0.
  APPEND s_codei.

* ----------------------------------------------------------------------


  hit = ' '.
*   select all withholding tax types
  SELECT * FROM t059p WHERE land1 = country
                     AND   witht IN qsskzi.
    IF sy-subrc = 0.
*    get text string for withholding tax type
      CLEAR t059u.
      SELECT SINGLE * FROM t059u WHERE spras = sy-langu
                                 AND land1 = country
                                 AND witht = t059p-witht.
*    get all withholding tax codes for this type which
*    also fit to select-options
      SELECT * FROM t059z    WHERE land1      = country
                             AND   witht      = t059p-witht
                             AND   wt_withcd    IN s_codei.

        IF sy-subrc = 0.
          hit = 'X'.                  " One selection successful
          code_inh-witht = t059p-witht.        " Tax type
          code_inh-wtext = t059u-text40.       " Tax type text
          code_inh-code_inh = t059z-wt_withcd. " Tax code
          code_inh-qscod = t059z-qscod.        " Off.tax code

*    get name of withholding tax code
*    get official text
          SELECT SINGLE text40 FROM t059ot INTO text
                  WHERE  land1 = country
                  AND   wt_qscod = code_inh-qscod.
          IF sy-subrc = 0.
            code_inh-text40 = text.
            APPEND code_inh.
            oftext = text-104.
          ELSE.
*     try to get a not official text from t059zt
            SELECT SINGLE text40 FROM t059zt INTO text
                   WHERE land1 = country
                   AND   spras = sy-langu
                   AND   witht = code_inh-witht
                   AND   wt_withcd = code_inh-code_inh.
            IF sy-subrc = 0.
              code_inh-text40 = text.
              APPEND code_inh.
              oftext = text-105.
            ENDIF.
*   a text is present (maybe space)
          ENDIF.
*   tax code finished
        ENDIF.
      ENDSELECT.                " t059z selection
      IF sy-subrc <> 0.
        MESSAGE e020(icc_cl) WITH country t059p-witht.
      ENDIF.
    ENDIF.                   " A tax type has been found
  ENDSELECT.                                                " t059p
  IF sy-subrc <> 0.
**ins ini
*    MESSAGE e042(icc_cl) WITH country.
    MESSAGE e042(icc_cl) WITH country  qsskzi-low.
**ins fin
  ENDIF.

ENDFORM.                               " CHECK_TYPE_CODE


************************************************************************


************************************************************************
*&---------------------------------------------------------------------*
*&      Form  READ_GSBER_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GSBERTXT  text
*----------------------------------------------------------------------*
FORM read_gsber_data.
  CLEAR: tgsbt.
  IF NOT s_busa IS INITIAL.
    SELECT SINGLE * FROM tgsb
           WHERE gsber = s_busa.

    IF sy-subrc = 0.
      SELECT SINGLE * FROM tgsbt WHERE  spras = t001-spras
                                  AND    gsber = tgsb-gsber.

    ELSE.
      MESSAGE e660(62) WITH s_busa.
    ENDIF.
  ENDIF.
ENDFORM.                    " READ_GSBER_DATA
*&---------------------------------------------------------------------*
*&      Form  RECBUILD
*&---------------------------------------------------------------------*
*       build record writerec for I/O
*----------------------------------------------------------------------*
FORM recbuild USING wa_out TYPE out.
  CLEAR: periodsum.
  periodsum-witht = wa_out-witht.
  periodsum-wt_withcd = wa_out-wt_withcd.
  periodsum-poper = wa_out-poper.
  periodsum-lifnr = wa_out-lifnr.
  periodsum-dmbt2 = wa_out-dmbt2.
  periodsum-wt_qbsh2 = wa_out-wt_qbsh2.
  periodsum-imbt2 = wa_out-imbt2.
  periodsum-in_qbsh2 = wa_out-in_qbsh2.
  periodsum-dmbt3 = wa_out-dmbt3.
  periodsum-wt_qbsh3 = wa_out-wt_qbsh3.
  periodsum-imbt3 = wa_out-imbt3.
  periodsum-in_qbsh3 = wa_out-in_qbsh3.

  APPEND periodsum.

ENDFORM.                    " RECBUILD
*&---------------------------------------------------------------------*
*&      Form  HEADBUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM headbuild.
* look in table usetab for combination vendor/tax/bus. area
  REFRESH output_header_table.
  LOOP AT output_list.

    AT NEW lifnr.
      CLEAR output_header_table.
* get tax data
      READ TABLE code_inh WITH KEY witht = output_list-witht
                                code_inh = output_list-wt_withcd.
      IF sy-subrc <> 0.
        MESSAGE e007(icc_cl) WITH output_list-wt_withcd.
      ENDIF.
      output_header_table-witht = code_inh-witht.
      output_header_table-wtext40 = code_inh-wtext.
      output_header_table-wt_withcd = code_inh-code_inh.
      output_header_table-qscod = code_inh-qscod.
      output_header_table-text40 = code_inh-text40.
* get vendor data
      READ TABLE vend_itab WITH KEY lifnr = output_list-lifnr.
      IF sy-subrc <> 0.
        MESSAGE e021(icc_cl) WITH output_list-lifnr.
      ENDIF.
      output_header_table-stcd1 = vend_itab-stcd1.
      output_header_table-name1 = vend_itab-name1.
      output_header_table-name2 = vend_itab-name2.
      output_header_table-lifnr = vend_itab-lifnr.
      output_header_table-waers = t001-waers.
      CLEAR output_header_table-alv_color.
* create sums
      CLEAR: output_header_table-dmbtr, output_header_table-wt_qbshh.
      LOOP AT periodsum.
        IF periodsum-witht = output_header_table-witht AND
           periodsum-wt_withcd = output_header_table-wt_withcd AND
           periodsum-lifnr = output_header_table-lifnr.
          output_header_table-dmbtr =  output_header_table-dmbtr +
                          periodsum-dmbt2.
          output_header_table-wt_qbshh = output_header_table-wt_qbshh +
                          periodsum-imbt2.
        ENDIF.
      ENDLOOP.

      output_header_table-pm = 'X'.
      APPEND output_header_table.
    ENDAT.
  ENDLOOP.
  SORT output_header_table BY witht wt_withcd lifnr.
ENDFORM.                    " HEADBUILD

*&---------------------------------------------------------------------*
*&      Form  AKKU
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM akku USING wa_out TYPE out
          CHANGING wa_out2 TYPE out.

  DATA: dmbt2 LIKE bsik-dmbtr,
        fac TYPE p DECIMALS 2,
        wt_qbsh2    LIKE with_item-wt_qbshh,
        imbt2       LIKE bsik-dmbtr,
        in_qbsh2    LIKE with_item-wt_qbshh,
        dmbt3 LIKE bsik-dmbtr,
        wt_qbsh3    LIKE with_item-wt_qbshh,
        imbt3       LIKE bsik-dmbtr,
        in_qbsh3    LIKE with_item-wt_qbshh.

* save old values of wa_out2
  dmbt2 = wa_out2-dmbt2.
  wt_qbsh2 = wa_out2-wt_qbsh2.
  imbt2 = wa_out2-imbt2.
  in_qbsh2 = wa_out2-in_qbsh2.
  dmbt3 = wa_out2-dmbt3.
  wt_qbsh3 = wa_out2-wt_qbsh3.
  imbt3 = wa_out2-imbt3.
  in_qbsh3 = wa_out2-in_qbsh3.

* copy all other data from actual field wa_out.
  wa_out2 = wa_out.
  fac = '1.00' .
  wa_out2-dmbt2 = dmbt2 + fac * wa_out-dmbtr.
  wa_out2-wt_qbsh2 = wt_qbsh2 + fac * wa_out-wt_qbshh.
  wa_out2-imbt2 = imbt2 +  fac * wa_out-imbtr.
  wa_out2-in_qbsh2 = in_qbsh2 +  fac * wa_out-in_qbshh.

*   the same with all data still to be certified
  IF wa_out-zuonr NE space.
    fac = '0.00'.
  ENDIF.
  wa_out2-dmbt3 = dmbt3 + fac * wa_out-dmbtr.
  wa_out2-wt_qbsh3 = wt_qbsh3 + fac * wa_out-wt_qbshh.
  wa_out2-imbt3 = imbt3 +  fac * wa_out-imbtr.
  wa_out2-in_qbsh3 = in_qbsh3 +  fac * wa_out-in_qbshh.


ENDFORM.                    " AKKU
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit INPUT.
  SET SCREEN 0. LEAVE SCREEN.
ENDMODULE.                 " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Form  PRINT_FINAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print_final.
  DATA: wa TYPE out,
       count TYPE i,
       cont  TYPE i ,
       c_wt_qsshh(11),
       c_wt_qbshh(11),
       c_dmbtr(11),
       type_desc(27) TYPE   c,
       type_impuesto(27) TYPE c,
       tabix LIKE sy-tabix.

*  SORT output_list BY witht wt_withcd lifnr poper budat belnr.
  SORT output_list BY witht blart xblnr.

  DESCRIBE TABLE output_list LINES found.
  DATA: p_blart TYPE  bsik-blart.
  IF found = 0.
    WRITE: /70 text-420.
    EXIT.
  ENDIF.
*  SORT output_list   BY blart.

  cont = 0.
  LOOP AT output_list.

*hide: output_list-belnr.
    MOVE output_list TO wa.
    ADD 1 TO count.

*    IF wa-wt_qsshh < 0.
    MULTIPLY wa-wt_qsshh BY -1.
*    ENDIF.

*    IF wa-wt_qbshh < 0.
    MULTIPLY wa-wt_qbshh BY -1.
*    ENDIF.

*    IF wa-dmbtr < 0.
    MULTIPLY wa-dmbtr BY -1.
*    ENDIF.

*    WRITE: wa-wt_qsshh TO c_wt_qsshh CURRENCY t001-waers,
*           wa-wt_qbshh TO c_wt_qbshh CURRENCY t001-waers,
*           wa-dmbtr    TO c_dmbtr    CURRENCY t001-waers.

    WRITE: wa-wt_qsshh TO c_wt_qsshh NO-SIGN CURRENCY v_waers,
           wa-wt_qbshh TO c_wt_qbshh NO-SIGN CURRENCY v_waers,
           wa-dmbtr    TO c_dmbtr    NO-SIGN CURRENCY v_waers.


    CLEAR: type_desc,type_impuesto.
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES02 ECDK917080 *
    SELECT SINGLE  ltext FROM t003t INTO type_desc
     WHERE spras = 'S'
     AND   blart = wa-blart.

    SELECT SINGLE text40 FROM t059u INTO type_impuesto
    WHERE spras = 'S'
    AND  land1  = 'CL'
    AND witht   = wa-witht.

*    IF output_list-AUGBL IS NOT INITIAL.
*      cont = cont + 1.
*    ENDIF.

    ON CHANGE OF output_list-blart.
      SKIP.
      WRITE: /1 type_desc.
      ULINE.

    ENDON.


    WRITE: /'', wa-budat UNDER text-401,
                wa-bldat UNDER text-398,
                wa-name1 UNDER text-402,
                wa-stcd1(12) UNDER text-403,
*                wa-stras UNDER text-410,
*                wa-ort02 UNDER text-412,
                wa-xblnr UNDER text-404,
                wa-belnr UNDER text-405,
                wa-wt_qsshh NO-SIGN CURRENCY v_waers UNDER text-406,
*                wa-wt_qsshh CURRENCY t001-waers UNDER text-406,
**                c_wt_qsshh  UNDER text-406,
*                wa-qsatz  DECIMALS 0   UNDER text-411,
                wa-wt_qbshh NO-SIGN CURRENCY v_waers UNDER text-407,
*                wa-wt_qbshh CURRENCY t001-waers UNDER text-407,
**                c_wt_qbshh  UNDER text-407,
                wa-dmbtr    CURRENCY v_waers NO-SIGN UNDER text-408.
*                wa-dmbtr    CURRENCY t001-waers UNDER text-408.
**                c_dmbtr  UNDER text-408.
    tabix = sy-tabix.

    HIDE: output_list-belnr.
    CLEAR output_list-belnr.

    AT END OF blart.


      SUM.
      ULINE.

*    IF wa-wt_qsshh < 0.
      MULTIPLY wa-wt_qsshh BY -1.
*    ENDIF.

*    IF wa-wt_qbshh < 0.
      MULTIPLY wa-wt_qbshh BY -1.
*    ENDIF.

*    IF wa-dmbtr < 0.
      MULTIPLY wa-dmbtr BY -1.
*    ENDIF.


      MOVE: output_list-count TO total_table-count,
            output_list-cont_null TO total_table-cont_null,
            type_impuesto TO total_table-type_impuesto,
            type_desc TO total_table-type_desc,
            output_list-wt_qsshh TO total_table-wt_qsshh,
            output_list-dmbtr TO total_table-dmbtr,
            output_list-wt_qbshh  TO total_table-wt_qbshh,
            output_list-xblnr  TO total_table-xblnr,
            output_list-belnr TO total_table-belnr,
            output_list-blart TO total_table-blart,
            wa-qsatz TO total_table-qsatz.
*            cont TO total_table-cont
      .

      COLLECT total_table.

      WRITE: /'', text-799 UNDER text-404, type_desc UNDER text-398,
*                 output_list-wt_qsshh  CURRENCY t001-waers UNDER text-406,
**                c_wt_qsshh  UNDER text-406,
*                 output_list-wt_qbshh  CURRENCY t001-waers  UNDER text-407,
*                 output_list-dmbtr     CURRENCY t001-waers  DECIMALS 0   UNDER text-408.
                 output_list-wt_qsshh  CURRENCY v_waers NO-SIGN UNDER text-406,
*                c_wt_qsshh  UNDER text-406,
                 output_list-wt_qbshh  CURRENCY v_waers  NO-SIGN UNDER text-407,
                 output_list-dmbtr     CURRENCY v_waers  NO-SIGN UNDER text-408.

      SKIP.
*uline.
*        *      endif.
      CLEAR cont.
*
      NEW-PAGE.
      IF tabix NE found.

*        IF p_def = 'X'.
*          PERFORM write_header.
*        ELSE.
        PERFORM write_header_draft.
*        ENDIF.
        PERFORM write_line_header.

      ENDIF.
    ENDAT.
  ENDLOOP.

  SORT output_list_null BY blart .

  LOOP AT output_list_null WHERE blart = 'B1'.
    c1 = 1 + c1.
  ENDLOOP.

  LOOP AT output_list_null WHERE blart = 'B2'.
    c2 = 1 + c2.
  ENDLOOP.

ENDFORM.                    " PRINT_FINAL
*&---------------------------------------------------------------------*
*&      Form  WRITE_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_header.

  SKIP 8.  "Preprinted header.

  ADD 1 TO p_cui.
  WRITE: / ' ', 88 text-c01, 145 text-c03, p_cui.
*  WRITE: / ' ', 145 text-c03, p_cui.

  SELECT SINGLE * FROM t015m WHERE spras = sy-langu
                        AND monum = s_month.
*  SKIP.
*  WRITE: / ' ', 82 t015m-monam, s_year.
  WRITE: / ' ', 88 idate_desc.
  WRITE: / ' ', 88 'Moneda: USD'.
*  WRITE: / ' ', 88 'Moneda: CLP'.
  ULINE.



ENDFORM.                    " WRITE_HEADER
*&---------------------------------------------------------------------*
*&      Form  WRITE_LINE_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_line_header.

  WRITE: /1  text-405, "num doc
          15 text-403, "RUT
          28 text-402, "Nombre.
          65 text-404, "Boleta
          81 text-398, "Fecha de referencia
          100  text-401, "Fecha de doc
          115 text-406, "Base
*          120 text-411, "Tas
          136 text-407, "Impuesto
          160 text-408. "Total
  ULINE.
  SKIP.


ENDFORM.                    " WRITE_LINE_HEADER
*&---------------------------------------------------------------------*
*&      Form  GET_DATE_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_date_desc .
  DATA: last_date LIKE bkpf-budat,
        last_day(02).

  CONCATENATE s_year s_month '01' INTO last_date.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = last_date
    IMPORTING
      last_day_of_month = last_date.
*   EXCEPTIONS
*     DAY_IN_NO_DATE          = 1
*     OTHERS                  = 2

  last_day = last_date+6(2).
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES02 ECDK917080 *
  SELECT SINGLE * FROM t015m WHERE spras = sy-langu
                          AND monum = s_month.
  .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    CONCATENATE t015m-monam text-d02 s_year INTO idate_desc
             SEPARATED BY ' '.

*   concatenate text-d01 t015m-monam text-d02 s_year
*               text-d03 last_day text-d02 t015m-monam text-d02
*               s_year into idate_desc
*               separated by ' '.

  ENDIF.


ENDFORM.                    " GET_DATE_DESC
*&---------------------------------------------------------------------*
*&      Form  WRITE_HEADER_DRAFT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_header_draft .
  SKIP 2.  "Preprinted header.

*  write: /1 text-t01, header_info-current_btx,
*         /1 text-t02, header_info-ruc.

*------------------------------------------------------------
*------------------------------------------------------------

  DATA: v_mon LIKE bkpf-waers VALUE 'CLP'.
  DATA: ti_repleg LIKE zrepleg OCCURS 0 WITH HEADER LINE.
  DATA: v_nomsoc TYPE butxt.
  DATA: v_lineas TYPE i.

*Filtramos a que usuario solo ingrese una sociedad.
*  CLEAR v_lineas.
*  DESCRIBE TABLE s_compy LINES v_lineas.
*  IF   s_compy IS NOT INITIAL. " OR v_lineas > 1.
*    SET CURSOR FIELD 'S_COMPY'.
*    MESSAGE w100(zfcj) WITH 'Debe ingresar solo una Sociedad' .
*  ENDIF.

*Imprime datos adicionales.
  CALL FUNCTION 'ZFILIBLEG'
    EXPORTING
      p_bukrs   = s_compy
    IMPORTING
      nomsoc    = v_nomsoc
    TABLES
      ti_repleg = ti_repleg.

  READ TABLE ti_repleg WITH KEY sociedad = s_compy.

  IF sy-subrc = 0.
    WRITE: / ' ', 03 text-c10 , 20 v_nomsoc.
    WRITE: / ' ', 03 text-c11 , 20 ti_repleg-rutsoc.
    WRITE: / ' ', 03 text-c12 , 20 ti_repleg-direccion.
    WRITE: / ' ', 03 text-c13 , 20 ti_repleg-nomreplegal.
  ENDIF.
*-----------------------------------------------------------
*-----------------------------------------------------------
  SKIP 4.


  ADD 1 TO p_cui.
  WRITE: / ' ', 88 text-c01,
               145 text-c02, sy-datum DD/MM/YY.
  WRITE: / ' ', 88 idate_desc, 145 text-c03, p_cui.
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES02 ECDK917080 *
  SELECT SINGLE * FROM t015m WHERE spras = sy-langu
                        AND monum = s_month.
*  SKIP.
*  WRITE: / ' ', 82 t015m-monam, s_year.
*  WRITE: / ' ', 85 idate_desc.
  WRITE: / ' ', 88 'Moneda: USD'.
*  WRITE: / ' ', 88 'Moneda: CLP'.
  SKIP 2.
  ULINE.


ENDFORM.                    " WRITE_HEADER_DRAFT
*&---------------------------------------------------------------------*
*&      Form  year_period_to_date
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_S_YEAR  text
*      -->P_S_MONTH  text
*      <--P_S_AUGDT  text
*----------------------------------------------------------------------*
FORM year_period_to_date  USING    p_year
                                   p_month.

  DATA: x_augdt LIKE bsak-augdt,
        y_augdt LIKE bsak-augdt.


  CONCATENATE p_year p_month '01' INTO x_augdt.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = x_augdt
    IMPORTING
      last_day_of_month = y_augdt.
* EXCEPTIONS
*   DAY_IN_NO_DATE          = 1
*   OTHERS                  = 2.


  MOVE: x_augdt TO s_augdt-low,
        y_augdt TO s_augdt-high,
        'I'     TO s_augdt-sign,
        'BT'    TO s_augdt-option.
  APPEND s_augdt.




ENDFORM.                    " year_period_to_date

*&---------------------------------------------------------------------*
*&      Form  resumen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM resumen .
  DATA: v_tabix LIKE sy-tabix.

*  IF p_def = 'X'.
*    PERFORM write_header.
*  ELSE.
  PERFORM write_header_draft.
*  ENDIF.

*  Summary
  SKIP 2.
*  uline at /1.
  WRITE: /'', text-811 UNDER text-404.

  SORT total_table .
  SKIP .
  ULINE AT /1(148).


  WRITE: /1 '|', text-332 , '|', text-331, '|', text-330, '|',
                text-406 CENTERED, '|', text-407 CENTERED, '|',
                text-408 CENTERED, '|'.

  DATA: iexport(27)  TYPE c.

  LOOP AT total_table.
    v_tabix = sy-tabix.
    IF total_table-cont_null > 0.
      total_table-count = total_table-count - total_table-cont_null.
      MODIFY total_table INDEX v_tabix.
    ENDIF.
  ENDLOOP.

  LOOP AT total_table.

    IF sy-tabix = 1.
      ULINE AT /1(148).
    ENDIF.
***DOC NULOS.
*    IF total_table-blart = 'B1'.
*      total_table-cont = c1.
*    ELSEIF total_table-blart = 'B2'.
*      total_table-cont = c2.
*    ENDIF.
***
    WRITE:/1 '|',  total_table-type_desc,'|',

*    write:/1 '|',   total_table-blart, '                        ', '|',
        total_table-cont_null, '          ' , '|',
        total_table-count,'          ', '|',
*        total_table-wt_qsshh CURRENCY t001-waers, '|',
*        total_table-wt_qbshh CURRENCY t001-waers, '|',
*        total_table-dmbtr CURRENCY t001-waers, '|'.

        total_table-wt_qsshh CURRENCY v_waers NO-SIGN, '|',
        total_table-wt_qbshh CURRENCY v_waers NO-SIGN , '|',
        total_table-dmbtr    CURRENCY v_waers NO-SIGN, '|'.

    AT LAST.
      SUM.
*      clear:  total_table-type_desc.
      iexport = text-809.

      ULINE AT /1(148).
      WRITE: /1 '|',  iexport, '|',
        total_table-cont_null,  '          ' , '|',
        total_table-count,'          ', '|',
*        total_table-wt_qsshh CURRENCY t001-waers, '|',
*        total_table-wt_qbshh CURRENCY t001-waers, '|',
*        total_table-dmbtr    CURRENCY t001-waers, '|'.

        total_table-wt_qsshh CURRENCY v_waers NO-SIGN, '|',
        total_table-wt_qbshh CURRENCY v_waers NO-SIGN, '|',
        total_table-dmbtr    CURRENCY v_waers NO-SIGN, '|'.
    ENDAT.

  ENDLOOP.

  ULINE AT /1(148).

**resumen por tipo de impuesto
*  skip 2.
*  new-page.
*
*  IF p_def = 'X'.
*    PERFORM write_header.
*  ELSE.
*    PERFORM WRITE_HEADER_DRAFT.
*  ENDIF.
*
**  uline at /1.
*  write: /'', text-808 under text-404.
*
*  sort total_table.
*  skip .
*  uline at /1(133).
*
*  write: /1 '|', text-332 , '|', text-333 , '|', text-411, '|', text-334, '|',
*                text-335 centered, '|'." text-407 centered, '|'.
*
*
*  loop at total_table.
*
*
*    if SY-TABIX = 1.
*      uline at /1(133).
*    endif.
*    total_table-qsatz = total_table-qsatz / 1.
*    write:/1 '|',  total_table-type_desc,'|',
*        total_table-type_impuesto,'|',
*        total_table-qsatz currency t001-waers,'            ','|',
*        total_table-wt_qsshh currency t001-waers, '|',
*        total_table-wt_qbshh currency t001-waers, '|'.
*  endloop.
*
*  uline at /1(133).


ENDFORM.                    " resumen



*&---------------------------------------------------------------------*
*&      Form  read_bsak
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM read_bsak .


  LOOP AT part_bsak2.
    CLEAR output_list.
    MOVE-CORRESPONDING part_bsak2 TO output_list.
    output_list-dmbtr = 0.
*    output_list-WRBTR = 0.

    APPEND output_list.
  ENDLOOP.
ENDFORM.                    " read_bsak


*&---------------------------------------------------------------------*
*&      Form  AT_LINE_SELECTION
*&---------------------------------------------------------------------*
FORM at_line_selection.
  IF NOT output_list-belnr IS INITIAL.
    SET PARAMETER ID 'BLN' FIELD output_list-belnr.
    SET PARAMETER ID 'BUK' FIELD s_compy.
    SET PARAMETER ID 'GJR' FIELD s_year.
    CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
  ENDIF.
  CLEAR output_list-belnr.
ENDFORM.                    " AT_LINE_SELECTION
*&---------------------------------------------------------------------*
*&      Form  DELETE_DOCTOS_ANULADOS
*&---------------------------------------------------------------------*

FORM delete_doctos_anulados .

**-------- Anulacion con MR8M ------------------------------*
*  LOOP AT output_list." WHERE AWTYP EQ 'VBRK'.
*
*    SELECT SINGLE * FROM bkpf WHERE "BUKRS EQ output_list-BUKRS AND
*                                    BELNR EQ output_list-BELNR AND
*                                    GJAHR EQ output_list-GJAHR.
*    IF SY-SUBRC EQ 0 AND
*       NOT bkpf-STBLG IS INITIAL AND
*       NOT bkpf-GJAHR IS INITIAL.
*
**      MOVE   PART_WORK TO PART_WORK_NULL.
**      PART_WORK_NULL-COUNT2 = 1.
**      PART_WORK_NULL-COUNT = 0.
**      APPEND PART_WORK_NULL.
**      DELETE output_list.
*    ENDIF.
*    CLEAR PART_WORK_NULL.
*  ENDLOOP.


ENDFORM.                    " DELETE_DOCTOS_ANULADOS
*&---------------------------------------------------------------------*
*&      Form  submit_report
*&---------------------------------------------------------------------*
FORM submit_report .
  SUBMIT zfilib006_leg
          WITH p_def EQ p_def
          WITH qkz0 EQ qkz0
          WITH qkz3 EQ qkz3
          WITH s_belnr IN s_belnr
          WITH s_blart IN s_blart
          WITH s_busa IN s_busa
          WITH s_compy EQ s_compy
          WITH s_kred IN s_kred
          WITH s_month EQ s_month
          WITH s_qsskz1 EQ s_qsskz1
          WITH s_year EQ s_year
          AND RETURN.

  SUBMIT zfilib006
            WITH p_def EQ p_def
            WITH qkz0 EQ qkz0
            WITH qkz3 EQ qkz3
            WITH s_belnr IN s_belnr
            WITH s_blart IN s_blart
            WITH s_busa IN s_busa
            WITH s_compy EQ s_compy
            WITH s_kred IN s_kred
            WITH s_month EQ s_month
            WITH s_qsskz1 EQ s_qsskz1
            WITH s_year EQ s_year
            VIA SELECTION-SCREEN.

ENDFORM.                    " submit_report
