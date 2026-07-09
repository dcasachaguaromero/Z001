*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   Weiterverarbeitung der Daten des Bankdaten-Zwischenspeichers       *
*                                                                      *
* ak250399 introduced check for cost-relevance of G/L-accounts         *
* ak140499 added filling of field AVIP-ABWKA (in addition to           *
*          AVIP-ABWKO)                                                 *
* ak220499 additional correction for AVIP-ABWKA                        *
* ak030899 applied note 115846                                         *
* ak090899 moved selection from T001 to event AT NEW FEBKO-KUKEY       *
* ak241199 replaced form CHECK_IF_COST_RELEVANT by form                *
*          FTPOST_FIELDSELECT                                          *
* ak201299 corrections to FTPOST_FIELDSELECT                           *
* ak020200 Allow specific application of BDC-fields to                 *
*          posting-area / line.                                        *
* ak090300 Applied note 206022.                                        *
* ak280400 Applied note 0178633.                                       *
* fk020801 1. New possibility of FB05-selection via worklist           *
*             (a set of G/L-accounts instead of a single G/L-account)  *
*          2. No automatical clearing if sel-criterium is WRBTR only   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report RFEBBU00_ALV                                                *
*&---------------------------------------------------------------------*
* Title       : Post Bank Statement/Check Deposit List
*----------------------------------------------------------------------*
* Change history of ALV Development
* Program description: Display the list of Annual Tax Return
* Author: Nagaraju Vootla (C5053248)
* DATE : 24/03/2004
* Short description of the program:
*      This report displays an Hierarchic sequential ALV with append ALV
* FM's Used 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
*           'REUSE_ALV_LIST_DISPLAY',
*----------------------------------------------------------------------*

*>>*<<**>>*<<**>>*<<**>>*<<**>>*<<**>>*<<**>>*<<**>>*<<**>>*<<*
* Change history of ALV Development after Walldorf Review & Suggestions
* Program description: RFEBBU00_ALV
* Author: Kedar Shinde (C5056171)
* Date  : 24/06/2004
* Description of Changes Made after review :
*    1. Modification to display more than 1 bank statement
*    2. Adjusted batch heading size as per list
*    3. Additon of comment "Test Run" in header during "NO POSTING"
*    4. Additon of following field to structure
*       'FAGL_ACC_S_RFEBBU00_ALV'
*            a.  BANKL
*            b.  KTONR
*            c.  AZNUM
* Date  : 02/07/2004
* Description of Changes Made after review :
*    1. Corrected Text Elements for column heading for fields
*       "Total Debit" and "Total Credit"
*    2. Added Field "KUKEY" to structure FAGL_ACC_S_RFEBBU00_ALV_STATIS
*    3. Modification to display "Total Acount Statistics"
*>>*<<**>>*<<**>>*<<**>>*<<**>>*<<**>>*<<**>>*<<**>>*<<**>>*<<*
*---------------------------------------------------------------------*
* Change history of ALV Development after Walldorf Review & Suggestions
* Program description: Sales documents with periodic billing: Update
*                      dates
* Author: Rahul S. Godbole (C5056169)
* Date  : 24.05.04
* Description of Changes Made after review
* 1) changes to modify program for displaying multiple lockboxes.
*    -subroutine sort_info_alv added.
*    -event after_line_output added.
*    -modifications to top_of_page subroutine.
*    -end_of_list event removed.
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
* Change history of ALV Development after Walldorf Review & Suggestions
* Program description: Sales documents with periodic billing: Update
*                      dates
* Author: Rahul S. Godbole (C5056169)
* Date  : 01.06.04
* Description of Changes Made after review
* 1) changes to modify program for displaying multiple lockboxes.
*    -Column Check Status and Doc. no. added.
*    -Column Messages added for Error messages.
*    -Column Advice added.
*    -Hierarchical List for Lockbox Totals
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
* Change history of ALV Development after Walldorf Review & Suggestions
* Program description: Sales documents with periodic billing: Update
*                      dates
* Author: Rahul S. Godbole (C5056169)
* Date  : 015.07.04
* Description of Changes Made after review
* 1) Output Length of Col 'Check Status' reduced.
* 2) Modifications to display appropriate error messages.
*---------------------------------------------------------------------*
REPORT rfebbu00 MESSAGE-ID fb
                LINE-SIZE 132
                NO STANDARD PAGE HEADING.                   "#EC *

*---------------------------------------------------------------*
*  Include Common Data                                          *
*---------------------------------------------------------------*
INCLUDE rfebbu03.

DATA: BEGIN OF t_header OCCURS 100,    "loans
         name(10),                     "loans
         text(132),                    "loans
      END OF t_header.                 "loans

DATA:  b-spoolnr LIKE sy-sponr.        "loans

DATA: BEGIN OF t_footer OCCURS 100,    "loans
         name(10),                     "loans
         text(132),                    "loans
      END OF t_footer.                 "loans

DATA:
  flag_prot_trea,                      "loans
  l_selvon LIKE febcl-selvon VALUE 'FEB_2_STO_LASTSCHR2'.   "loans



DATA:   ikofi-bukr1 LIKE febko-bukrs,                       "31H-HP
        ikofi-bukr2 LIKE febko-bukrs.                       "31H-HP

DATA:   augst_avis(1)   TYPE n.
*                        Values    AUGST_AVIS = 1  -> APPLIED
*                                  AUGST_AVIS = 2  -> ON ACCOUNT
*                                  AUGST_AVIS = 3  -> PARTIALLY APPLIED
DATA:   bkpf_komk_ok(1) TYPE c.
DATA:   bseg_komk_h_ok TYPE c.
DATA:   bseg_komk_s_ok TYPE c.
DATA:   item_cnt     TYPE i.           " Zählt die Buchungszeilen
DATA:   komk(1)      TYPE c.           " Komprimierung an
DATA:   komkb(1)     TYPE c.           " per batch               "46a
DATA:   komk_s-kwbtr LIKE febep-kwbtr.
DATA:   komk_h-kwbtr LIKE febep-kwbtr.
DATA:   komk_s-fwbtr LIKE febep-fwbtr. "INSERT - mpEURO
DATA:   komk_h-fwbtr LIKE febep-fwbtr. "INSERT - mpEURO
DATA:   x_apa_def(1) TYPE c.           "INSERT - mpEURO
DATA:   alt_sakn1 LIKE ikofi-sakn1,    "INSERT - mpEURO
        alt_sakn2 LIKE ikofi-sakn2.    "INSERT - mpEURO
DATA:   char_zuonr LIKE febep-zuonr.   "INSERT - mpEURO
DATA:   BEGIN OF const_zuonr,          "INSERT - mpEURO
        kukey LIKE febep-kukey,        "INSERT - mpEURO
        esnum LIKE febep-esnum,        "INSERT - mpEURO
        kwaer LIKE febep-kwaer,        "INSERT - mpEURO
        END OF const_zuonr.            "INSERT - mpEURO
DATA:   current_bukrs LIKE febko-bukrs,"INSERT - mpEURO
        current_anwnd LIKE febko-anwnd,"INSERT - mpEURO
        current_efart LIKE febko-efart."INSERT - mpEURO
DATA:   BEGIN OF local_table OCCURS 1, "INSERT - mpEURO
        bukrs LIKE febko-bukrs,        "INSERT - mpEURO
        waers LIKE febko-waers,        "INSERT - mpEURO
        END OF local_table.            "INSERT - mpEURO
DATA:   esnum(5)     TYPE c.
DATA:   vgext        LIKE febep-vgext.
DATA:   kwbtr        LIKE febep-kwbtr.
DATA:   blank(1)     TYPE c VALUE ' '.

DATA:   BEGIN OF ex_kukey OCCURS 10,
          kukey LIKE febko-kukey,
        END OF ex_kukey.

DATA:   BEGIN OF ftpost OCCURS 100.
        INCLUDE STRUCTURE ftpost.
DATA:   END OF ftpost.

*  Daten für Komprimierte Haben-Zeile
DATA:   BEGIN OF ft_komk_h OCCURS 10.
        INCLUDE STRUCTURE ftpost.
DATA:   END OF ft_komk_h.

*  Daten für Komprimierte Soll-Zeile
DATA:   BEGIN OF ft_komk_s OCCURS 10.
        INCLUDE STRUCTURE ftpost.
DATA:   END OF ft_komk_s.

DATA:   BEGIN OF ftclear OCCURS 20.
        INCLUDE STRUCTURE ftclear.
DATA:   END OF ftclear.


DATA:   BEGIN OF fttax OCCURS 0.
        INCLUDE STRUCTURE fttax.
DATA:   END OF fttax.

DATA:   fvalue LIKE ftpost-fval.


DATA:   BEGIN OF febep_ok OCCURS 200,
          kukey LIKE febep-kukey,
          esnum LIKE febep-esnum,
          vb1ok LIKE febep-vb1ok,
          vb2ok LIKE febep-vb2ok,
          belnr LIKE febep-belnr,
        END OF febep_ok.

*------- Messages from Lockbox-Posting ---------------------------------
DATA:    BEGIN OF lbmsg OCCURS 100,
           mandt LIKE febep-mandt,
           kukey LIKE febep-kukey,
           esnum LIKE febep-esnum,
           msnum(1)   TYPE n,
           text(120)  TYPE c,
        END OF lbmsg.



DATA:   BEGIN OF vb_error OCCURS 10,
          anwnd LIKE febvw-anwnd,
          absnd LIKE febvw-absnd,
          azidt LIKE febvw-azidt,
          buber(01)  TYPE c,
          ktonr LIKE febko-ktonr,
          aznum LIKE febko-aznum,
          applk LIKE febep-b1app,
          esnum LIKE febep-esnum,
          zeile(100) TYPE c,
        END OF vb_error.

DATA:   BEGIN OF statist OCCURS 10,
          buber(01)  TYPE c,
          anwnd LIKE febko-anwnd,
          absnd LIKE febko-absnd,
          azidt LIKE febko-azidt,
          kukey LIKE febko-kukey,
          ktonr LIKE febko-ktonr,
          group LIKE apqi-groupid,
          grpnr LIKE febep-grpnr,
          aznum LIKE febko-aznum,
          applk LIKE febep-b1app,
          trans TYPE i,
          fb01  TYPE i,
          fb05  TYPE i,
          avise TYPE i,
          akont TYPE i,
          notpo TYPE i,
          error TYPE i,
          summe TYPE i,
          sumso LIKE febko-sumso,
          sumha LIKE febko-sumha,
          waers LIKE febko-waers,
        END OF statist.


* verbuchte Einzelposten, für Komprimierung
DATA:   BEGIN OF vbkep OCCURS 50,
          kukey LIKE febep-kukey,
          esnum LIKE febep-esnum,
        END OF vbkep.

DATA:   BEGIN OF xt033f OCCURS 0.
        INCLUDE STRUCTURE t033f.
DATA:   END OF xt033f.


DATA:   BEGIN OF xblntab  OCCURS 2.
        INCLUDE STRUCTURE blntab.
DATA:   END OF xblntab.

DATA:   BEGIN OF xskat  OCCURS 6.
        INCLUDE STRUCTURE skat.
DATA:   END OF xskat.

*-----------------------------------------------------------------------
*       Fields
*-----------------------------------------------------------------------
DATA:   subrc        LIKE sy-subrc,
        msgid        LIKE sy-msgid,
        msgty        LIKE sy-msgty,
        msgno        LIKE sy-msgno,
        msgv1        LIKE sy-msgv1,
        msgv2        LIKE sy-msgv2,
        msgv3        LIKE sy-msgv3,
        msgv4        LIKE sy-msgv4,
        msgtxt       like balmt-msgtxt.                    "hw818056

DATA:    ad_bereich   LIKE ikofi-eigr2,
         ad_kwaer     LIKE ikofi-komo2,
         ad_vgint     LIKE ikofi-eigr1,
         all_vb1ok(1) TYPE c,          " Alle EP verbucht
         all_vb2ok(1) TYPE c,          " Alle EP verbucht
         auglv        LIKE t041a-auglv," Ausgleichsvorgang
         augbl        LIKE rf05r-augbl." Ausgleichsbelegn

DATA:    belns        LIKE rf05a-belns," Belnr zu storn. Belg
         bereich(01)  TYPE c,          " Buchungsbereich
         bername(20)  TYPE c,          " Name d Bubereichs
         bktxt        LIKE bkpf-bktxt, " Belegkopftext
         buchen(01)   TYPE c,          " Flag Buchen
         do_fi(01)    TYPE c,          " Flag FI Buchungen durchfuehren
         buzei(03)    TYPE n.          " Buchungszeile

DATA:    char10(10)   TYPE c,          " Textfeld
         char16(16)   TYPE c,          " Textfeld
         char20(20)   TYPE c,          " Textfeld
         char50(50)   TYPE c,          " Textfeld
         char60(60)   TYPE c,          " Textfeld
         char80(80)   TYPE c,          " Textfeld
         char132(132) TYPE c,          " Textfeld
         char140(140) TYPE c,          " Textfeld
         char300(300) TYPE c.          " Textfeld

DATA:    datum        LIKE sy-datum,
         difffw(7)           TYPE p,   " Differenz beim Aus-
         diffhw(7)           TYPE p.   " gleich FW / HW

DATA:    ex_funct(1)  TYPE c.          "Externer Funktionsbaust
DATA:    fdis_arch(1) TYPE c.          " Dispo Avise archiviert

DATA:    idx_lbmsg       TYPE i.

DATA:    mappe        LIKE apqi-groupid.

DATA:    open(01)     TYPE c.

DATA:    printflag(1) TYPE c.          " 1=Buchprot 2=Fehl

DATA:    sgtxt        LIKE bseg-sgtxt. " Segmenttext

DATA:    tcode               LIKE sy-tcode,   " Transaktions-Code
         tfill_error         TYPE i,   " Zeilen in VB_ERROR
         tfill_skukey        TYPE i,   " Zeilen in S_KUKEY
         tfill_sesnum        TYPE i,   " Zeilen in S_ESNUM
         tfill_xt033f        TYPE i.   " Zeilen in XT033F

DATA:    usnam        LIKE sy-uname.

DATA:    vozpm(1)     TYPE c.          " Vorzeichen +/-

DATA:    wrbtr(17)    TYPE c.          " Betrag f Protoko

DATA:    xakon, g_clear_on_account.                         "hw638124
DATA:    x_error_handling(1) TYPE c.   "FB05 posting on account flag
DATA:    tmp_zuonr LIKE febep-zuonr.   "OnAccount Bank Entry fill

DATA:    xtrwpr(1)    TYPE c,                               "hw462052
         h_trwpr      TYPE trwpr.                           "hw462052
DATA:    l_fv781 LIKE t100c-msgts.                          "hw630615
DATA:    g_tbsl type standard table of tbsl.                "hw801501
data:    g_open_fi_item_header(1).                          "hw818056

* for returns:
DATA:  BEGIN OF postab OCCURS 50,
         xauth(1)      TYPE c,
         xhell(1)      TYPE c.
        INCLUDE STRUCTURE rfpos.
INCLUDE rfeposc9.
DATA:    xbkpf(1)      TYPE c,
         xbseg(1)      TYPE c,
         xbsec(1)      TYPE c,
         xbsed(1)      TYPE c,
         xpayr(1)      TYPE c,
         xbsegc(1)     TYPE c,
         xbsbv(1)      TYPE c,
         xmod(1)       TYPE c,
       END OF postab.

DATA: BEGIN OF docs_structure,
        belnr TYPE bkpf-belnr,
        gjahr TYPE bkpf-gjahr,
        bukrs TYPE bkpf-bukrs,
        buzei TYPE bseg-buzei,
        status TYPE c,
        mansp TYPE t028z-mansp,
        zahls TYPE t028z-zahls,
        zlsch TYPE t028z-zlsch,
        zlsch_delete TYPE t028z-zlsch_delete,
      END OF docs_structure.
* end for returns
*DATA:
*  CRC_FLAG(1) TYPE C.          "flag: true if G/L-account cost-relevant

*-----------------------------------------------------------------------
*       Konstanten
*-----------------------------------------------------------------------
DATA:    true         TYPE c VALUE '0',
         false        TYPE c VALUE '8'.

*eject
*-----------------------------------------------------------------------
*       FIELD-GROUPS:
*-----------------------------------------------------------------------
FIELD-GROUPS:
         header, ex_febko, ex_febep, ex_febcl.

INSERT   febko-kukey
         febep-grpnr
         febep-fwaer                   "INSERT - mpEURO
         febep-vgint
         febep-kfmod                               "HW802665
         febep-batch                                        "46a
         febep-bvdat                                        "30D
         febep-valut
         febep-esnum
         febcl-csnum  INTO header.

INSERT   febko        INTO ex_febko.
INSERT   febep        INTO ex_febep.
INSERT   febcl        INTO ex_febcl.
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
TYPE-POOLS: slis.
DATA: gt_fb01_1 TYPE STANDARD TABLE OF fagl_acc_s_rfebbu00_alv.
DATA: gt_statis TYPE STANDARD TABLE OF fagl_acc_s_rfebbu00_alv_statis.
DATA: gt_header TYPE STANDARD TABLE OF fagl_acc_s_rfebbu00_alv_head.
DATA: gv_repid TYPE sy-repid,               "Report field
      gv_ctr(3) TYPE i VALUE 1,
      gv_kukey TYPE febep-kukey.

DATA:gc_tol_form1 TYPE slis_formname VALUE 'TOP_OF_PAGE_ONE'.
"top of page 1
DATA:gc_tol_form2 TYPE slis_formname VALUE 'TOP_OF_PAGE_TWO'.
"top of page 2
DATA:gc_end_list1 TYPE slis_formname VALUE 'END_OF_ALV_LIST'.
"top of page 2
CONSTANTS: gc_str   TYPE dd02l-tabname VALUE
                        'FAGL_ACC_S_RFEBBU00_ALV',"Structure
           gc_str2  TYPE dd02l-tabname VALUE
                        'FAGL_ACC_S_RFEBBU00_ALV_HEAD',"Structure
           gc_strs  TYPE dd02l-tabname VALUE
                        'FAGL_ACC_S_RFEBBU00_ALV_STATIS',"Structure
           gc_chk   TYPE char01 VALUE 'X', "Check field
           gc_y     TYPE char01 VALUE 'Y', "CHECK  FIELD
           gc_1h TYPE  slis_tabname VALUE '1H',
           gc_1l TYPE  slis_tabname VALUE '1L',
           gc_s TYPE c VALUE 'S',
           gc_m TYPE c VALUE 'M'.

DATA:gc_top_of_page_hier TYPE slis_formname VALUE 'TOP_OF_PAGE_HIER'.

************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************

************************************************************************
***    Begin of ALV Conversion                   C5053309
************************************************************************
*TYPES : begin of g_output_type.
*        include sturcture febep.
*TYPES : lv_lckbox(3) type n,
*        end of g_output_type.

*start changes after review C5053099 24 Jun 2004.

*DATA: gt_outtab3 TYPE STANDARD TABLE OF g_output_type,
*      gs_outtab TYPE g_output_type,
*DATA: gt_outtab3 TYPE STANDARD TABLE OF febep WITH HEADER LINE,
*      gs_outtab LIKE febep,
*       gs_outtab_next LIKE febep,
DATA: gt_outtab3 TYPE STANDARD TABLE OF FIN_RFEBBU0001_ALV
                                         WITH HEADER LINE,
      gs_outtab TYPE FIN_RFEBBU0001_ALV,
      gs_outtab_next TYPE FIN_RFEBBU0001_ALV.

DATA: gt_header1 type standard table of febko,
      gs_header1 type febko,
      gt_item1  type standard table of FIN_RFEBBU0002_ALV,
      gs_item1   type  FIN_RFEBBU0002_ALV,
*end changes after review C5053099 24 Jun 2004.
      gt_sort TYPE slis_t_sortinfo_alv,
      gv_text(132)  TYPE c,
      gv_text1(132) TYPE c,
      gv_text2(132) TYPE c,
      gv_text3(132) TYPE c,
      gv_text4(132) TYPE c,
      gv_text5(132) TYPE c,
      gv_text6(132) TYPE c.
*********************
DATA:
       GT_FIELDCAT_ASSIGN TYPE SLIS_T_FIELDCAT_ALV,
       GT_EVENTTAB_ALV TYPE SLIS_T_EVENT,
       GT_EVENTTAB_ASSIGN TYPE SLIS_T_EVENT,
       GS_LAYOUT_ASSIGN   TYPE SLIS_LAYOUT_ALV,
       GS_LAYOUT TYPE SLIS_LAYOUT_ALV.


*************************
*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
DATA: gs_header TYPE fagl_acc_s_rfebbu00_alv_head.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*

************************************************************************
***    End of ALV Conversion                     C5053309
************************************************************************

*-----------------------------------------------------------------------
*       Parameters
*-----------------------------------------------------------------------
PARAMETERS:     anwnd   LIKE febko-anwnd.
SELECT-OPTIONS: s_kukey FOR  febko-kukey,
                s_esnum FOR  febep-esnum.
PARAMETERS:     r_csnum LIKE febcl-csnum NO-DISPLAY.   "<<< ADVICE SPLIT
PARAMETERS:     buber(1)     TYPE c,                        "A, 1, 2
                bnkgroup     LIKE apqi-groupid,
                nebgroup     LIKE apqi-groupid,
                mregel(1)    TYPE c,   " Regel für Mappenname
                userexit     TYPE c.
*               SELFD        LIKE RFPDO1-FEBSELFD. "SELFIELD für VwZweck
*               SELFDLEN     LIKE RFPDO1-FEBSELFDL. "Länge SELFD
*SELECT-OPTIONS: S_FILTER FOR BKPF-XBLNR.        " Nummernbereich SELFD
SELECT-OPTIONS: s_filter FOR num10.    " Nummernbereich SELFD
SELECT-OPTIONS: t_filter FOR chr16.    " Nummernbereich SELFD
PARAMETERS:     pa_bdart     LIKE febpdo-bdart,
                pa_bdanz     LIKE febpdo-bdanz.
PARAMETERS:     function(1)  TYPE c,   "B oder C
                mode(1)      TYPE c DEFAULT 'N',      "A, E, N
                pa_efart     LIKE febko-efart,
                p_bupro(1)   TYPE c,   "Buchungsprotokoll
                p_statik(1)  TYPE c,   "Statistik
                pa_lsepa(1)  TYPE c,   "Statistik
                p_xfifo(1)     TYPE c,
                pa_xakon(1)     TYPE c DEFAULT ' ',
*               VALUT_ON: Valuta-Datum kontieren
                valut_on(1)  TYPE c DEFAULT 'X',
                testl(1)     TYPE c,   "Testlauf
                execpri     LIKE rfpdo1-febeinles
                            DEFAULT space NO-DISPLAY.
PARAMETERS:     p_xnoadv TYPE xnoadvice_eb DEFAULT ' ' NO-DISPLAY.

*eject
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
*  Initialization                                                      *
INITIALIZATION.
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
  gv_repid = sy-repid.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
*---------------------------------------------------------------------*
*       START-OF-SELECTION.                                           *
*---------------------------------------------------------------------*
START-OF-SELECTION.
  IF function IS INITIAL.
    function = 'B'.
  ENDIF.

  IF mode IS INITIAL.
    mode = 'N'.
  ENDIF.
  PERFORM set_print_parameters.

*-------- Initialize Protokoll Treasury
  PERFORM init_prot_trea.              "loans
*-------- Initialize fields and tables --------------------------------
  PERFORM initialisierung.

* check if status update is done in update task             "hw462052

*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM  trwpr INTO h_trwpr                  "hw462052
*         WHERE  process   = 'BELEG'                         "hw462052
*         AND    event     = 'POST'                          "hw462052
*         AND    subno     = '410'                           "hw462052
*         AND    function  = 'FIBL_UPDATE_STMT_LINE'.        
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM  trwpr INTO h_trwpr                  "hw462052
         WHERE  process   = 'BELEG'                         "hw462052
         AND    event     = 'POST'                          "hw462052
         AND    subno     = '410'                           "hw462052
         AND    function  = 'FIBL_UPDATE_STMT_LINE' ORDER BY PRIMARY KEY.        

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01"hw462052
  IF sy-subrc = 0.                                          "hw462052
    xtrwpr = 'X'.                                           "hw462052
  ELSE.                                                     "hw462052
    CLEAR xtrwpr.                                           "hw462052
  ENDIF.                                                    "hw462052

* check if zero amounts shall be excepted from posting      "hw630615
  CALL FUNCTION 'READ_CUSTOMIZED_MESSAGE'                   "hw630615
    EXPORTING
      i_arbgb       = 'FV'
      i_dtype       = '-'
      i_msgnr       = '781'
    IMPORTING
      e_msgty       = l_fv781.

*-------- Interpretation of single items, not when Lockbox -------------
  IF anwnd NE '0003'.
    PERFORM einzelposten_interpretieren.
  ENDIF.

*-------- read and extract Bank Data Buffer ----------------------------
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM febko INTO TABLE xfebko WHERE anwnd = anwnd
*                                        AND kukey IN s_kukey.
*
* NEW CODE
  SELECT *
 FROM febko INTO TABLE xfebko WHERE anwnd = anwnd
                                        AND kukey IN s_kukey ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  LOOP AT xfebko.
    CLEAR febko.
    febko = xfebko.

*--------  AUTHORITY-CHECK---------------------------------------------
    AUTHORITY-CHECK OBJECT 'F_FEBB_BUK'
             ID 'BUKRS' FIELD febko-bukrs
             ID 'ACTVT' FIELD actvt_aen.
    IF sy-subrc = 0.
      CLEAR skb1.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM skb1 WHERE bukrs = febko-bukrs
*                                AND   saknr = febko-hkont.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM skb1 WHERE bukrs = febko-bukrs
                                AND   saknr = febko-hkont ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF NOT skb1-begru IS INITIAL.
        AUTHORITY-CHECK OBJECT 'F_BKPF_BES'
                 ID 'BRGRU' FIELD skb1-begru
                 ID 'ACTVT' FIELD actvt_erz.
        IF sy-subrc NE 0.
          MESSAGE s208(fv) WITH skb1-begru febko-hkont.     "mp40c
          CONTINUE.
        ENDIF.
      ENDIF.
    ELSE.
      MESSAGE s629(fv) WITH 'F_FEBB_BUK' febko-bukrs.         "n1127582
      CONTINUE.
    ENDIF.


    IF pa_efart = 'E'.
*     nur electronische  Kontoauszüge
      CHECK febko-efart = pa_efart.
    ENDIF.

    IF buber = 'A'.
      CHECK febko-astat CN '89'.
      CHECK febko-vb1ok = ' ' OR febko-vb2ok = ' '.
    ELSEIF buber = '1'.
      CHECK febko-vb1ok NE 'X'.
    ELSEIF buber = '2'.
      CHECK febko-vb2ok NE 'X'.
    ENDIF.

    DESCRIBE TABLE s_esnum LINES tfill_sesnum.
    IF tfill_sesnum = 0.
*------- Sperren der Tabellen FEBKO -----------------------------------
      CALL FUNCTION 'ENQUEUE_E_FEBKO'
        EXPORTING
          anwnd          = febko-anwnd
          absnd          = febko-absnd
          azidt          = febko-azidt
          emkey          = febko-emkey
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2.
      IF sy-subrc = 1.
        MESSAGE e780 WITH 'FEBKO' febko-anwnd febko-absnd febko-azidt.
      ELSEIF sy-subrc = 2.
        MESSAGE e781 WITH 'FEBKO' febko-anwnd febko-absnd febko-azidt.
      ENDIF.
    ENDIF.

*   FEBVW lesen und Sätze in XFEBVW speichern für Protokollausgabe
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM febvw INTO xfebvw WHERE anwnd = febko-anwnd
*                                             AND absnd = febko-absnd
*                                             AND azidt = febko-azidt.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM febvw INTO xfebvw WHERE anwnd = febko-anwnd
                                             AND absnd = febko-absnd
                                             AND azidt = febko-azidt ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc = 0.
      APPEND xfebvw.
    ENDIF.


*    SELECT SINGLE * FROM T001 WHERE BUKRS = FEBKO-BUKRS.      "ak090899
*    IF SY-SUBRC NE 0.                                         "ak090899
*      MESSAGE E750 WITH 'T001' FEBKO-BUKRS.                   "ak090899
*    ENDIF.                                                    "ak090899
*    FEBKO-KTOPL = T001-KTOPL.                                 "ak090899

*   Clear: Extract Schlüsselfelder
    CLEAR: febep-grpnr,
           febep-fwaer,                "INSERT - mpEURO
           febep-vgint,
           febep-kfmod,                                     "HW802665
           febep-batch,                                     "46a
           febep-bvdat,                                     "30D
           febep-valut,
           febep-esnum,
           febcl-csnum.

    EXTRACT ex_febko.


* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM febep INTO TABLE xfebep WHERE kukey =  febko-kukey
*                                          AND esnum IN s_esnum.
*
* NEW CODE
    SELECT *
 FROM febep INTO TABLE xfebep WHERE kukey =  febko-kukey
                                          AND esnum IN s_esnum ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    LOOP AT xfebep.
      CLEAR febep.
      febep = xfebep.

      IF l_fv781 <> '-' AND febep-kwbtr = 0.                "hw630615
        febep-vb1ok = 'X'.                                  "hw630615
        febep-belnr = '-'.                                  "hw630615
        febep-vb2ok = 'X'.                                  "hw630615
        febep-nbbln = '-'.                                  "hw630615
        febep-sdoc2 = '-'.                                  "hw630615
        MODIFY febep.                                       "hw630615
      ENDIF.                                                "hw630615

      IF buber = 'A'.
        CHECK febep-eperl = ' '.
        CHECK febep-vb1ok = ' ' OR febep-vb2ok = ' '.
      ELSEIF buber = '1'.
        CHECK febep-vb1ok NE 'X'.
      ELSEIF buber = '2'.
        CHECK febep-vb2ok NE 'X'.
      ENDIF.
      IF febep-b1err = 'C' OR febep-b2err = 'C'.            "hw662494
        msgid = 'FB'.                                       "hw662494
        msgno = '092'.                                      "hw662494
        msgv2 = '00002810'.                                 "hw662494
        CLEAR: msgv1, msgv3, msgv4.                         "hw662494
        IF function = 'C' AND p_bupro = 'X'.                "hw662494
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*          perform write_item_header using febep ' '.        "hw662494
*          perform druck_message.                            "hw662494
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
          PERFORM write_item_header USING febep ' '
                                    CHANGING gt_fb01_1.
          PERFORM druck_message CHANGING gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
        ENDIF.                                              "hw662494
        CONTINUE.                                           "hw662494
      ENDIF.                                                "hw662494
      IF febep-b1err = '2' OR febep-b2err = '2'.            "hw662494
        msgid = 'FB'.                                       "hw662494
        msgno = '093'.                                      "hw662494
        msgv2 = '00002810'.                                 "hw662494
        CLEAR: msgv1, msgv3, msgv4.                         "hw662494
        IF function = 'C' AND p_bupro = 'X'.                "hw662494
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*          perform write_item_header using febep ' '.
*          perform druck_message.                            "hw662494
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
          PERFORM write_item_header USING febep ' '
                                    CHANGING gt_fb01_1.
          PERFORM druck_message CHANGING gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
        ENDIF.                                              "hw662494
        CONTINUE.                                           "hw662494
      ENDIF.                                                "hw662494

*   Brazil, Boecker 11052000--------------------------------------------
*   check for brazilian cc
      CALL FUNCTION 'J_1BSA_COMPONENT_ACTIVE'
        EXPORTING
          bukrs                = febko-bukrs
          component            = 'BR'
        EXCEPTIONS
          component_not_active = 01.
      IF sy-subrc NE 0.
* Standard countries:
* zero amt transaction: set flag to 'not-to-be-posted'
        IF febep-kwbtr = 0.                                 "46A TT
          febep-vb1ok = 'X'.                                "46A TT
          febep-belnr = '-'.                                "46A TT
          febep-vb2ok = 'X'.                                "46A TT
          febep-nbbln = '-'.                                "46A TT
        ENDIF.                                              "46A TT
        MODIFY febep.                                       "46A TT

      ENDIF.

      IF tfill_sesnum > 0.
*------- Sperren der Tabellen FEBKO -----------------------------------
        CALL FUNCTION 'ENQUEUE_E_FEBKO'
          EXPORTING
            anwnd          = febko-anwnd
            absnd          = febko-absnd
            azidt          = febko-azidt
            emkey          = febko-emkey
            esnum          = febep-esnum
          EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2.
        IF sy-subrc = 1.
          MESSAGE e780 WITH 'FEBKO' febko-anwnd febko-absnd febko-azidt.
        ELSEIF sy-subrc = 2.
          MESSAGE e781 WITH 'FEBKO' febko-anwnd febko-absnd febko-azidt.
        ENDIF.
      ENDIF.
*       für maschinelles Ausgleichen
      IF febep-zuonr CO ' 0'.          "For Bank and Clrng Docs
        febep-zuonr+0(8) = febep-kukey.
        febep-zuonr+8(5) = febep-esnum.
      ENDIF.

*      Bildung der Referenzbelegnummer
      IF febep-xblnr IS INITIAL.
        febep-xblnr+0(5)  = febko-hbkid.
        febep-xblnr+5(5)  = febko-hktid.
        febep-xblnr+10(2) = febko-azdat+2(2).
        febep-xblnr+12(3) = febko-aznum+2(3).
      ENDIF.


      CLEAR febcl-csnum.

      IF febko-anwnd <> '0003'.                             "46a
        CLEAR febep-batch.                                  "46a
      ENDIF.                                                "46a

      EXTRACT ex_febep.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT * FROM febcl INTO TABLE xfebcl
*                            WHERE kukey = febko-kukey
*                            AND esnum = febep-esnum.
*
* NEW CODE
      SELECT *
 FROM febcl INTO TABLE xfebcl
                            WHERE kukey = febko-kukey
                            AND esnum = febep-esnum ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
*       xfebcl = febcl.                                      "mp45B
*       append xfebcl.                                       "mp45B
*     endselect.                                             "mp45B

*     es werden nur sinnvolle FEBCL-Zeilen extrahiert
      DESCRIBE TABLE xfebcl LINES tfill_xfebcl.
      LOOP AT xfebcl.
        IF ( xfebcl-selfd = 'VERTN' ) OR                "loans
           ( xfebcl-selvon = l_selvon ).                "loans

          flag_trea = '1'.             "loans
          IF febko-efart = 'M'.                               "n1012136
            p_bupro = 'X'.                                    "n1012136
          ENDIF.                                              "n1012136

        ENDIF.                         "loans
        febcl = xfebcl.
        IF febcl-agkon = space.
*         ausgesternt, da es sich um eine FB05 auf Sachkonten handeln
*         könnte. Das Konto Kommt dann aus ACCOUNT_DETERMINATION
*         IF FEBCL-SELFD = 'BELNR'.
          EXTRACT ex_febcl.
*         ENDIF.
        ELSE.
*       account of item to be cleared is determined
          IF ( febcl-selfd = 'VERTN' ) OR                 "loans
             ( febcl-selvon = l_selvon ).                 "loans
            flag_prot_trea = '1'.      "loans
          ENDIF.                       "loans
          IF febcl-selfd = space.
*           no clearing information for item provided
            IF tfill_xfebcl = 1.
*           exactly one account -> clear item with amount
              febcl-selfd  = 'WRBTR'.
*             amount entry will be overwritten depending on
*             posting area if necessary
              IF febep-fwbtr IS INITIAL.                    "31I-HP
                febcl-selvon = febep-kwbtr.
              ELSE.                                         "31I-HP
                febcl-selvon = febep-fwbtr.                 "31I-HP
              ENDIF.                                        "31I-HP
              EXTRACT ex_febcl.
            else.                                          "hw644631
              if febcl-koart <> space.                     "hw644631
                extract ex_febcl.                          "hw644631
              endif.                                       "hw644631
            ENDIF.
          ELSE.
            EXTRACT ex_febcl.
          ENDIF.
        ENDIF.
      ENDLOOP.
      REFRESH xfebcl.
      CLEAR   xfebcl.
    ENDLOOP.
    REFRESH xfebep.                                         "mp45B
    CLEAR xfebep.                                           "mp45B
  ENDLOOP.
  REFRESH xfebko.                                           "mp45B
  CLEAR xfebko.                                             "mp45B

*eject
*---------------------------------------------------------------------*
*       START-OF-SELECTION.                                           *
*---------------------------------------------------------------------*
END-OF-SELECTION.

* Extract sortieren
  SORT.
* Parameter initialisieren
  datum = '00000000'.
  usnam = sy-uname.
  open  = false.

  IF pa_lsepa = 'X'.
    bhdgd-separ   = 'X'.
    bhdgd-domai   = 'LSEPW_EB'.
    bhdgd-werte   = '1'.
    bhdgd-grpin   = '1'.
    PERFORM new-section(rsbtchh0).
  ENDIF.

* Extract verbuchen
  CASE buber.
    WHEN 'A'.
      COMMIT WORK.
      bereich = '1'.
      bername = text-011.
      PERFORM display_process_status USING text-080.
      PERFORM loop_extract CHANGING gt_fb01_1.

      COMMIT WORK.
      bereich = '2'.
      bername = text-012.
      PERFORM display_process_status USING text-081.
      PERFORM loop_extract CHANGING gt_fb01_1.

    WHEN '1'.
      COMMIT WORK.
      bereich = '1'.
      bername = text-011.
      PERFORM display_process_status USING text-080.
      PERFORM loop_extract CHANGING gt_fb01_1.

    WHEN '2'.
      COMMIT WORK.
      bereich = '2'.
      bername = text-012.
      PERFORM display_process_status USING text-081.
      PERFORM loop_extract CHANGING gt_fb01_1.

  ENDCASE.

  COMMIT WORK.
* Lastschriftrückläufer Darlehen
  IF flag_trea = '1'.                  "loans
    CALL FUNCTION 'STORNO_LASTSCHRIFT'."#EC EXISTS
  ENDIF.                               "loans

* Status setzen für jeden verarbeiteten Kukey
  IF testl NE 'X'.
    PERFORM update_febko_status.
  ENDIF.

* Verarbeitungsstatistik ausdrucken
  IF p_statik = 'X'.
    PERFORM druck_statistik CHANGING gt_statis.
*    SORT GT_STATIS BY BERNAME BANKL KTONR.
  ENDIF.
* write lines to spool-file
* PERFORM close_print_parameters.                      "31H

  PERFORM display_process_status USING text-082.

* Alle Sperreinträge wieder zurücknehmen
  CALL FUNCTION 'DEQUEUE_ALL'.
* Treasury-Protokoll ausgeben
*  IF  flag_trea = '1'                "loans
*   OR flag_immo = '1'.               " real estate note 521801
  IF flag_immo = '1'.                "note 1012136
    PERFORM print_prot_trea.         "loans
  ENDIF.                             "loans
*eject
  MOVE sy-linsz    TO bhdgd-lines.

* IF not anwnd = '0003'.
    IF p_bupro = 'X'.
      PERFORM display_fb01_list1 USING gt_fb01_1.
    ENDIF.
    IF P_STATIK = 'X'.
      PERFORM display_fb01_list2 USING gt_statis.
    ENDIF.
* ENDIF.

*--------------------------------------------------------------*
*  Seitenanfangsverarbeitung                                   *
*--------------------------------------------------------------*
TOP-OF-PAGE.
*  CASE anwnd.
*    WHEN '0001'.
*      PERFORM top_of_page.
*    WHEN '0002'.
*      PERFORM top_of_page.
*    WHEN '0003'.
*      PERFORM top_of_page_lockbox.
*  ENDCASE.



*eject
***********************************************************************
*       Perform Routinen                                              *
***********************************************************************

*---------------------------------------------------------------------*
*       FORM ABSCHLUSS_KOMPRIMIERUNG.
*---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form abschluss_komprimierung.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM abschluss_komprimierung CHANGING xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
* if not komk_s-kwbtr is initial.               "DELETE - mpEURO
  IF ( NOT komk_s-kwbtr IS INITIAL )   "INSERT - mpEURO
  OR ( NOT komk_s-fwbtr IS INITIAL ).  "INSERT - mpEURO

    IF  ( NOT komk_s-kwbtr IS INITIAL )"INSERT - mpEURO
    AND ( NOT komk_s-fwbtr IS INITIAL ).          "INSERT - mpEURO
*    both amounts given -> error
      MESSAGE e772(fv).                "INSERT - mpEURO
    ENDIF.                             "INSERT - mpEURO

    ftpost-stype = 'P'.
    ftpost-count = ftpost-count + 1.

    IF NOT komk_s-kwbtr IS INITIAL.    "INSERT - mpEURO
      WRITE KOMK_S-KWBTR  TO FVALUE(15) CURRENCY FEBEP-KWAER.
    ELSE.                              "INSERT - mpEURO
      WRITE KOMK_S-FWBTR  TO FVALUE(15) CURRENCY FEBEP-FWAER.
    ENDIF.                             "INSERT - mpEURO
    CONDENSE fvalue.
    PERFORM ft_komk_s_field USING 'BSEG-WRBTR' fvalue.  "BetrBelegWähr
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    perform druck_buzei using ikofi-bsch1 ikofi-sakn1 'S'.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    PERFORM druck_buzei USING ikofi-bsch1 ikofi-sakn1 'S'
                        CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
    LOOP AT ft_komk_s.
      ftpost-fnam = ft_komk_s-fnam.
      ftpost-fval = ft_komk_s-fval.
      APPEND ftpost.
    ENDLOOP.
    REFRESH ft_komk_s.
    CLEAR komk_s-kwbtr.
    CLEAR komk_s-fwbtr.                "INSERT - mpEURO
  ENDIF.

* if not komk_h-kwbtr is initial.               "DELETE - mpEURO
  IF ( NOT komk_h-kwbtr IS INITIAL )   "INSERT - mpEURO
  OR ( NOT komk_h-fwbtr IS INITIAL ).  "INSERT - mpEURO

    IF  ( NOT komk_h-kwbtr IS INITIAL )"INSERT - mpEURO
    AND ( NOT komk_h-fwbtr IS INITIAL ).          "INSERT - mpEURO
*    both amounts given -> error
      MESSAGE e772(fv).                "INSERT - mpEURO
    ENDIF.                             "INSERT - mpEURO

    ftpost-stype = 'P'.
    ftpost-count = ftpost-count + 1.

    IF NOT komk_h-kwbtr IS INITIAL.    "INSERT - mpEURO
      WRITE KOMK_H-KWBTR  TO FVALUE(15) CURRENCY FEBEP-KWAER.
    ELSE.                              "INSERT - mpEURO
      WRITE KOMK_H-FWBTR  TO FVALUE(15) CURRENCY FEBEP-FWAER.
    ENDIF.                             "INSERT - mpEURO

    CONDENSE fvalue.
    PERFORM ft_komk_h_field USING 'BSEG-WRBTR' fvalue.  "BetrBelegWähr
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    perform druck_buzei using ikofi-bsch2 ikofi-sakn2 'H'.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    PERFORM druck_buzei USING ikofi-bsch2 ikofi-sakn2 'H'
                        CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************

    LOOP AT ft_komk_h.
      ftpost-fnam = ft_komk_h-fnam.
      ftpost-fval = ft_komk_h-fval.
      APPEND ftpost.
    ENDLOOP.
    REFRESH ft_komk_h.
    CLEAR komk_h-kwbtr.
    CLEAR komk_h-fwbtr.                "INSERT - mpEURO
  ENDIF.
ENDFORM.                    "ABSCHLUSS_KOMPRIMIERUNG


*---------------------------------------------------------------------*
*       FORM ACCOUNT_DETERMINATION.
*---------------------------------------------------------------------*
FORM account_determination.
  DATA: i_kfmod LIKE ikofi-komo1.
  DATA save_sy_sub_rc LIKE sy-subrc.                       "note 388094

  CLEAR: ikofi.
  CLEAR: ikofi-bukr1,                                       "31H-HP
         ikofi-bukr2.                                       "31H-HP

  i_kfmod = febep-kfmod.
  ad_vgint   = febep-vgint.
  ad_bereich = bereich.
* account determination depends solely on account currency
  ad_kwaer   = febep-kwaer.            "ok - mpEURO

* determine if alternate posting area is defined -> x_apa_def
  PERFORM determine_altern_posting_area USING ad_vgint  "INSERT - mpEURO
                                              ad_bereich"INSERT - mpEURO
                                              ad_kwaer  "INSERT - mpEURO
                                              x_apa_def "INSERT - mpEURO
                                              alt_sakn1 "INSERT - mpEURO
                                              alt_sakn2."INSERT - mpEURO

* x_apa_def = 'X' disables allocation number access on interim account

  CALL FUNCTION 'ACCOUNT_DETERMINATION'
    EXPORTING
      i_anwnd            = '0001'
      i_eigr1            = ad_vgint
      i_eigr2            = ad_bereich
      i_eigr3            = '  '
      i_eigr4            = '  '
      i_fpart            = ' '
      i_komo1            = i_kfmod
      i_komo2            = ad_kwaer
      i_ktopl            = febko-ktopl
      i_sakin            = febko-hkont
      i_sakinb           = febko-hkont                      "mp45A
    IMPORTING
      e_ikofi            = ikofi
    EXCEPTIONS
      input_missing      = 1
      input_wrong        = 2
      schema_not_found   = 4
      replace_impossible = 5.

  save_sy_sub_rc = sy-subrc.                               "note 388094

  IF sy-subrc = 0.
    IF x_apa_def = 'X'.
      PERFORM check_posting_rules_consistent USING ikofi-sakn1
                                                   ikofi-sakn2
                                                   alt_sakn1
                                                   alt_sakn2.
*     determine if dynamic accounts are to be considered   "mo051101
      IF bereich = '2' AND
        ( ikofi-ktos1 = '\DYNAMIC\' OR ikofi-ktos2 = '\DYNAMIC\' )
        AND NOT febep-belnr IS INITIAL AND
        ( ikofi-attr2 GE 4 AND ikofi-attr2 LE 8 ).
        PERFORM get_dynamic_account USING ikofi-sakn1
                                          ikofi-sakn2.
      ENDIF.
    ENDIF.
  ENDIF.

  IF x_apa_def = 'X'.                                      "note 388094
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM  t012o                            "note 388094
*           WHERE  bukrs   = febko-bukrs                    "note 388094
*           AND    hbkid   = febko-hbkid.                   
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM  t012o                            "note 388094
           WHERE  bukrs   = febko-bukrs                    "note 388094
           AND    hbkid   = febko-hbkid ORDER BY PRIMARY KEY.                   

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01"note 388094
    IF sy-subrc = 0.                                       "note 388094
      CLEAR x_apa_def.                                     "note 388094
    ENDIF.                                                 "note 388094
  ENDIF.                                                   "note 388094
  sy-subrc = save_sy_sub_rc.                               "note 388094

ENDFORM.                    "ACCOUNT_DETERMINATION

*---------------------------------------------------------------------*
*       FORM APPEND_STATIST.
*---------------------------------------------------------------------*
FORM append_statist.
  IF statist-notpo > 0
  OR statist-fb01  > 0
  OR statist-fb05  > 0
  OR statist-error > 0
  OR statist-akont > 0.
    statist-trans = statist-fb01  + statist-fb05 + statist-akont.
    statist-summe = statist-trans + statist-notpo + statist-error.
    IF statist-trans = 0.
      statist-group = space.
    ENDIF.
    APPEND statist.
    CLEAR  statist.
  ENDIF.
ENDFORM.                    "APPEND_STATIST

*---------------------------------------------------------------------*
*       FORM BELEGKOPF.                                               *
*---------------------------------------------------------------------*
FORM belegkopf USING fb05_flag.
  DATA: febep_key LIKE febepawobj.
  DATA: c_awtyp_febep LIKE acchd-awtyp VALUE 'FEBEP'.
  DATA: l_xblnr TYPE bkpf-xblnr.                            "hw507108

* komk ne ' ' only allowed for FB01 (-> no exit for FB05)
  IF komk NE space AND bkpf_komk_ok = true.
    EXIT.
  ENDIF.

  ftpost-stype = 'K'.
  ftpost-count = '1'.
* WRITE FEBKO-AZDAT TO FVALUE DD/MM/YYYY.                       "30D
  IF febep-bvdat IS INITIAL.                                "30D
    WRITE febko-azdat TO fvalue DD/MM/YYYY.                 "30D
  ELSE.                                                     "30D
    WRITE febep-bvdat TO fvalue DD/MM/YYYY.                 "30D
  ENDIF.                                                    "30D
  PERFORM ftpost_field USING 'BKPF-BLDAT' fvalue.         "Belegdatum

  PERFORM ftpost_field USING 'BKPF-BLART' ikofi-attr1.    "Belegart

  IF ( NOT ikofi-bukr1 IS INITIAL ) AND                     "note 310298
     ( ikofi-bukr1 <> febko-bukrs ).                        "note 310298
    PERFORM ftpost_field USING 'BKPF-BUKRS' ikofi-bukr1.    "note 310298
    CLEAR ikofi-bukr1.                                      "note 310298
    ikofi-bukr2 = febko-bukrs.                              "note 310298
  ELSE.                                                     "note 310298
    PERFORM ftpost_field USING 'BKPF-BUKRS' febko-bukrs.    "note 310298
  ENDIF.                                                    "note 310298

  IF febep-budat IS INITIAL.
    WRITE sy-datum    TO fvalue DD/MM/YYYY.
  ELSE.
    WRITE febep-budat TO fvalue DD/MM/YYYY.
  ENDIF.
  PERFORM ftpost_field USING 'BKPF-BUDAT' fvalue.         "Buchungsdatum

* if febep-fwaer is initial.                         "DELETE - mpEURO
  IF febep-fwaer IS INITIAL OR bereich = '1' .       "INSERT - mpEURO
*   no original transaction currency provided or posting area = 1.
    PERFORM ftpost_field USING 'BKPF-WAERS' febep-kwaer.   "ok - mpEURO
  ELSE.
*   original transaction currency provided and posting area = 2.
    PERFORM ftpost_field USING 'BKPF-WAERS' febep-fwaer.
  ENDIF.

  IF febep-kwaer <> t001-waers OR
    ( bereich = '2' AND febep-fwaer is not initial ).           "n886178
*    account currency not company code currency OR
*    original transaction currency provided and posting area = 2.
    IF NOT febep-kursf IS INITIAL.     "CHECK - mpEURO
      WRITE febep-kursf TO char10 LEFT-JUSTIFIED.
      PERFORM ftpost_field USING 'BKPF-KURSF' char10.
      CLEAR char10.
    ENDIF.
  ENDIF.                               "INSERT - mpEURO

  IF NOT febep-xblnr IS INITIAL.
*  AND komk = space.                                    "45A
    IF komk = space OR febko-anwnd = '0002'.                "45A
      IF komk <> space.                                     "45A
        PERFORM ftpost_field USING 'BKPF-XBLNR'             "45A
                                   febko-emkey. "Group  "45A
      ELSE.                                                 "45A
        PERFORM ftpost_field USING 'BKPF-XBLNR' febep-xblnr.  "Referenz
      ENDIF.                                                "45A
    ENDIF.                                                  "45A
  ENDIF.

  IF komk = 'X' AND febko-anwnd = '0001'.                   "hw507108
    l_xblnr+0(5) = febko-hbkid.                             "hw507108
    l_xblnr+5(5) = febko-hktid.                             "hw507108
    l_xblnr+10(2) = febko-azdat+2(2).                       "hw507108
    l_xblnr+12(3) = febko-aznum+2(3).                       "hw507108
    PERFORM ftpost_field USING 'BKPF-XBLNR' l_xblnr.        "hw507108
  ENDIF.                                                    "hw507108

  bktxt+0(8) = febep-kukey.
  bktxt+8(5) = febep-esnum.
  PERFORM ftpost_field USING 'BKPF-BKTXT' bktxt.          "Belegkopftext

  IF fb05_flag = 'X'.
    PERFORM segmenttext_to_ftpost USING sgtxt.
    IF NOT sgtxt IS INITIAL.
      PERFORM ftpost_field USING 'RF05A-AUGTX' sgtxt.  "Clearing Text
    ENDIF.
  ENDIF.

* perform ftpost_field using 'BKPF-AWTYP' c_awtyp_febep.  "hw660882
* clear febep_key.                                        "beleg
* febep_key-kukey = febep-kukey.
* if bereich = '2'.
*   febep_key-esnum = febep-esnum.
* endif.
* perform ftpost_field using 'BKPF-AWKEY' febep_key.

  ftpost-count = 0.

  bkpf_komk_ok = true.
ENDFORM.                    "BELEGKOPF

*eject
*---------------------------------------------------------------------*
*  FORM BETRAEGE_TO_FTPOST.                                           *
*---------------------------------------------------------------------*
FORM betraege_to_ftpost.
  DATA: subrc LIKE sy-subrc.           "INSERT - mpEURO

* on-account clearing must exit now to leave amount field blank
  IF  g_clear_on_account = 'C'.                             "hw638124
    EXIT.                                                   "45b
  ENDIF.                                                    "45b

* if febep-fwbtr is initial.                           "DELETE - mpEURO
  IF febep-fwbtr IS INITIAL OR bereich = '1'.          "INSERT - mpEURO
*   no original transaction currency provided or posting area = 1.
    WRITE febep-kwbtr TO fvalue(15) CURRENCY febep-kwaer.  "note 310292
    CONDENSE fvalue.
    PERFORM ftpost_field USING 'BSEG-WRBTR' fvalue.       "BetrBelegWähr
    wrbtr = fvalue.
  ELSE.
*   original transaction currency provided and posting area = 2.
    WRITE febep-fwbtr TO fvalue(15) CURRENCY febep-fwaer.  "note 310292
    CONDENSE fvalue.
    PERFORM ftpost_field USING 'BSEG-WRBTR' fvalue.       "BelegWährBtrg
    wrbtr = fvalue.

*   manual statement allows input of local amount
*   if account currency = local currency
    IF current_anwnd = '0001' AND
       current_efart = 'M'    AND
       current_bukrs NE space AND
       febep-fwaer NE febep-kwaer.

      IF ikofi-bukr1 IS INITIAL AND ikofi-bukr2 IS INITIAL.
*       no intercompany posting allowed
        PERFORM check_local_currency USING current_bukrs
                                           febep-kwaer
                                           subrc.
        IF subrc = 0.
*        account currency = local currency
          WRITE febep-kwbtr TO fvalue CURRENCY febep-kwaer.
          CONDENSE fvalue.
          PERFORM ftpost_field USING 'BSEG-DMBTR' fvalue.
        ELSE.
*         local currency will be determined by fxrates
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "BETRAEGE_TO_FTPOST

*eject
*---------------------------------------------------------------------*
*  FORM BETRAEGE_KOMK_HABEN.                                          *
*---------------------------------------------------------------------*
*  Beträge für Haben-Buchung komprimieren                             *
*---------------------------------------------------------------------*
FORM betraege_komk_haben.
* if febep-fwbtr is initial.                           "DELETE - mpEURO
  IF febep-fwbtr IS INITIAL OR bereich = '1'.          "INSERT - mpEURO
*   no original transaction currency provided or posting area = 1.
    komk_h-kwbtr = komk_h-kwbtr + febep-kwbtr.
  ELSE.
*   original transaction currency provided and posting area = 2.
    komk_h-fwbtr = komk_h-fwbtr + febep-fwbtr.         "INSERT - mpEURO

  ENDIF.
ENDFORM.                    "BETRAEGE_KOMK_HABEN

*eject
*---------------------------------------------------------------------*
*  FORM BETRAEGE_KOMK_SOLL.                                           *
*---------------------------------------------------------------------*
*  Beträge für Soll-Buchung komprimieren                              *
*---------------------------------------------------------------------*
FORM betraege_komk_soll.
* if febep-fwbtr is initial.                           "DELETE - mpEURO
  IF febep-fwbtr IS INITIAL OR bereich = '1'.          "INSERT - mpEURO
*   no original transaction currency provided or posting area = 1.
    komk_s-kwbtr = komk_s-kwbtr + febep-kwbtr.
  ELSE.
*   original transaction currency provided and posting area = 2.
    komk_s-fwbtr = komk_s-fwbtr + febep-fwbtr.         "INSERT - mpEURO
  ENDIF.
ENDFORM.                    "BETRAEGE_KOMK_SOLL

*eject
*---------------------------------------------------------------------*
*       FORM BUCHUNGSSTOFF_BESCHAFFEN.                                *
*---------------------------------------------------------------------*
*       Ermittlung der Kontonummer über T033G                         *
*---------------------------------------------------------------------*
FORM buchungsstoff_beschaffen.
  CHECK komk = space.
  buchen = false.
  CLEAR g_clear_on_account.                                 "hw638124

  CASE anwnd.
    WHEN 0003.
      PERFORM lockbox_account_determination.
    WHEN OTHERS.
      PERFORM init_account_determination.
  ENDCASE.

ENDFORM.                    "BUCHUNGSSTOFF_BESCHAFFEN

*eject
*---------------------------------------------------------------------*
*       FORM  FEBCL_ACCOUNT_DETERMINATION.                            *
*---------------------------------------------------------------------*
*       Diese Routine wird bei FB01 aufgerufen, wenn ein Konto nicht  *
*       über die Kontenfindung gefunden wird, das heißt, wenn in der  *
*       Kontenfindung kein Kontosymbol angegeben wurde.               *
*       Dies ist bei Buchungsart '2' (Buchen Personenkonto im Soll)   *
*       und '3' (Buchen Personenkonto im Haben) immer der Fall        *
*       Das Personenkonto kann nicht über die Kontenfindung           *
*       bestimmt werden. Dann muß das Konto über die FEBCL angegeben  *
*       werden. Hierfür ist ein Eintrag in der FEBCL mit der richtigen*
*       Kontoart und der Kontonummer notwendig.                       *
*       Bei Buchungsart '1' (Buchen Sachkonto) kann dies nur durch    *
*       direkte Eingabe des Kontos beim manuellen Kontoauszug         *
*       geschehen. Auch hier ist ein FEBCL mit Kontoart und Konto-    *
*       nummer erforderlich.                                          *
*---------------------------------------------------------------------*
FORM febcl_account_determination.
* Konto im Soll
  CLEAR xfebcl.                                             "30D
  IF ikofi-sakn1 IS INITIAL.
    IF febep-avkon IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM tbsl WHERE bschl = ikofi-bsch1.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM tbsl WHERE bschl = ikofi-bsch1 ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc NE 0.
        EXIT.
      ENDIF.
      LOOP AT xfebcl WHERE koart = tbsl-koart.
        EXIT.
      ENDLOOP.
      IF sy-subrc = 0
      AND NOT xfebcl-agkon IS INITIAL.
        ikofi-sakn1 = xfebcl-agkon.
        ikofi-bukr1 = xfebcl-agbuk.                         "31H-HP
      ELSE.
*     Dummy-Kontonummer
        ikofi-sakn1 = '*'.             "mp45B - 122594
*       ikofi-sakn1 = '=*'.            "mp45B - 122594
      ENDIF.
    ELSE.
      ikofi-sakn1 = febep-avkon.
    ENDIF.
  ENDIF.
* Konto im Haben                                          "30D
  CLEAR xfebcl.
  IF ikofi-sakn2 IS INITIAL.
    IF febep-avkon IS INITIAL.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM tbsl WHERE bschl = ikofi-bsch2.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM tbsl WHERE bschl = ikofi-bsch2 ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc NE 0.
        EXIT.
      ENDIF.
      LOOP AT xfebcl WHERE koart = tbsl-koart.
        EXIT.
      ENDLOOP.
      IF sy-subrc = 0
      AND NOT xfebcl-agkon IS INITIAL.                      "30D
        ikofi-sakn2 = xfebcl-agkon.
        ikofi-bukr2 = xfebcl-agbuk.                         "31H-HP
      ELSE.
*     Dummy-Kontonummer
        ikofi-sakn2 = '*'.             "mp45B - 122594
*       ikofi-sakn2 = '=*'.            "mp45B - 122594
      ENDIF.
    ELSE.                                                   "
      ikofi-sakn2 = febep-avkon.                            "
    ENDIF.                                                  "
  ENDIF.
ENDFORM.                    "FEBCL_ACCOUNT_DETERMINATION
*eject
*---------------------------------------------------------------------*
*       FORM DRUCK_BUZEI USING BSCHL SAKNR.                           *
*---------------------------------------------------------------------*
*       Protokoll Zeile 1 bei FB01 und FB05                           *
*---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form druck_buzei  using bschl saknr komk_p.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM druck_buzei  USING bschl saknr komk_p
                  CHANGING xt_fb01 LIKE gt_fb01_1.
  DATA: ls_fb01 TYPE fagl_acc_s_rfebbu00_alv.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************

  DATA: amount LIKE febep-kwbtr.       "INSERT - mpEURO
  DATA: currency LIKE febep-kwaer.     "INSERT - mpEURO


  CASE komk_p.
    WHEN ' '.
      esnum = febep-esnum.
      vgext = febep-vgext.
*     kwbtr = febep-kwbtr.                             "DELETE - mpEURO
      IF febep-fwbtr IS INITIAL OR bereich = '1'.      "INSERT - mpEURO
*        no original transaction currency provided or posting area = 1.
        amount = febep-kwbtr.          "INSERT - mpEURO
        currency = febep-kwaer.        "INSERT - mpEURO
      ELSE.                            "INSERT - mpEURO
*        original transaction currency provided and posting area = 2.
        amount = febep-fwbtr.          "INSERT - mpEURO
        currency = febep-fwaer.        "INSERT - mpEURO
      ENDIF.                           "INSERT - mpEURO
    WHEN 'S'.
      esnum = space.
      vgext = text-020.
*     kwbtr = komk_s-kwbtr.                            "DELETE - mpEURO
      IF febep-fwbtr IS INITIAL OR bereich = '1'.      "INSERT - mpEURO
*        no original transaction currency provided or posting area = 1.
        amount = komk_s-kwbtr.         "INSERT - mpEURO
        currency = febep-kwaer.        "INSERT - mpEURO
      ELSE.                            "INSERT - mpEURO
*        original transaction currency provided and posting area = 2.
        amount = komk_s-fwbtr.         "INSERT - mpEUR
        currency = febep-fwaer.        "INSERT - mpEURO
      ENDIF.                           "INSERT - mpEURO
    WHEN 'H'.
      esnum = space.
      vgext = text-020.
*     kwbtr = komk_h-kwbtr.                            "DELETE - mpEURO
      IF febep-fwbtr IS INITIAL OR bereich = '1'.      "INSERT - mpEURO
*        no original transaction currency provided or posting area = 1.
        amount = komk_h-kwbtr.         "INSERT - mpEURO
        currency = febep-kwaer.        "INSERT - mpEURO
      ELSE.                            "INSERT - mpEURO
*        original transaction currency provided and posting area = 2.
        amount = komk_h-fwbtr.         "INSERT - mpEURO
        currency = febep-fwaer.        "INSERT - mpEURO
      ENDIF.                           "INSERT - mpEURO

  ENDCASE.

  buzei = ftpost-count.
* BUZEI = 1.
  clear xskat.                                             "hw801501
  if tbsl-bschl <> bschl.                                  "hw801501
    read table g_tbsl into tbsl with key bschl = bschl.    "hw801501
    if sy-subrc <> 0.                                      "hw801501

*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      select single * from tbsl where bschl = bschl.       
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  from tbsl where bschl = bschl ORDER BY PRIMARY KEY.       

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01"hw801501
      append tbsl to g_tbsl.                               "hw801501
    endif.                                                 "hw801501
  endif.                                                   "hw801501
* tbsl sollte in der Routine febcl_account_determination   "hw801501
* gesetzt sein, falls es sich um Personenkonten handelt    "hw801501
  if tbsl-koart = 'S'.                                     "hw801501
    PERFORM xskat_lesen USING saknr.                       "hw801501
  endif.                                                   "hw801501
  IF p_bupro = 'X'.
    IF buzei = 1 and g_open_fi_item_header = space.        "hw818056
      RESERVE 5 LINES.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*      write: /01 sy-vline, 02 sy-uline(130), 132 sy-vline.
*      write: /01     sy-vline,
*              02(05) esnum,
*              08(04) febep-vgint,
*              14(20) vgext,
*              35(04) tcode,
*              41(03) buzei,
*              45(02) ikofi-attr1,      " Belegart
*              48(02) bschl,
*              51(10) saknr,
*              62(20) xskat-txt20,
**          83(03) febep-kwaer,                      "DELETE - mpEURO
*              83(03) currency,         "INSERT - mpEURO
**          88(16) kwbtr currency febep-kwaer,        "DELETE - mpEURO
*              88(16) amount currency currency,      "INSERT -mpEURO
*              132    sy-vline.
*    else.
*      write: /01     sy-vline,
*              02(05) esnum,
*              14(20) vgext,
*              41(03) buzei,
*              45(02) ikofi-attr1,
*              48(02) bschl,
*              51(10) saknr,
*              62(20) xskat-txt20,
**         83(03) febep-kwaer,                       "DELETE - mpEURO
*              83(03) currency,         "INSERT - mpEURO
**         88(16) kwbtr currency febep-kwaer,        "DELETE - mpEURO
*              88(16) amount currency currency,      "INSERT -mpEURO
*              132    sy-vline.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
      CLEAR ls_fb01.
      ls_fb01-esnum       = esnum.
      ls_fb01-vgint      = febep-vgint.
      ls_fb01-vgext      = vgext.
      ls_fb01-tcode      = tcode.
      ls_fb01-buzei      = buzei.
      ls_fb01-blart      = ikofi-attr1.
      ls_fb01-bschl      = bschl.
      ls_fb01-saknr      = saknr.
      ls_fb01-txt20      = xskat-txt20.
      ls_fb01-currency   = currency.
      ls_fb01-amount     = amount.
      ls_fb01-bername    = bername.

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
      ls_fb01-bankl     = gs_header-bankl.
      ls_fb01-ktonr     = gs_header-ktonr.
      ls_fb01-aznum     = gs_header-aznum.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*
      ls_fb01-kukey     = febko-kukey.                "n853370
      ls_fb01-mappe     = mappe.

      APPEND ls_fb01 TO xt_fb01.
    ELSE.
      CLEAR ls_fb01.
      ls_fb01-esnum      = esnum.                            "n948646
      ls_fb01-vgext      = vgext.                            "n948646
      ls_fb01-buzei      = buzei.
      ls_fb01-bschl      = bschl.
      ls_fb01-saknr      = saknr.
      ls_fb01-txt20      = xskat-txt20.
      ls_fb01-currency   = currency.
      ls_fb01-amount     = amount.
      ls_fb01-bername    = bername.

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
      ls_fb01-bankl     = gs_header-bankl.
      ls_fb01-ktonr     = gs_header-ktonr.
      ls_fb01-aznum     = gs_header-aznum.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*
      ls_fb01-kukey     = febko-kukey.                "n853370
      ls_fb01-mappe     = mappe.

      APPEND ls_fb01 TO xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
    ENDIF.
  ENDIF.
ENDFORM.                    "DRUCK_BUZEI

*eject
*---------------------------------------------------------------------*
*       FORM DRUCK_KEINE-BUCHUNG                                      *
*---------------------------------------------------------------------*
*       Protokoll Zeile,falls für den Buchungsbereich keine           *
*       Regel definiert ist. Also keine Buchung gemacht werden soll   *
*---------------------------------------------------------------------*
FORM druck_keine-buchung.
  DATA: buprotext(80) TYPE c.
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
  DATA: ls_fb01 TYPE fagl_acc_s_rfebbu00_alv.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  IF p_bupro = 'X'.
    RESERVE 3 LINES.
*    uline.
    buprotext = text-016.
    REPLACE '&' WITH bername INTO buprotext.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    write: /01     sy-vline,
*            02(05) febep-esnum,
*            08(04) febep-vgint,
*            14(27) febep-vgext,
*            35(80) buprotext,
*            132    sy-vline.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    CLEAR ls_fb01.
    ls_fb01-buzei = buzei.
    ls_fb01-vgint = ikofi-attr1.
    ls_fb01-vgext = ftclear-agkon.
    ls_fb01-msg = xskat-txt20.

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
    ls_fb01-bername  = gs_header-bername.
    ls_fb01-bankl  = gs_header-bankl.
    ls_fb01-ktonr  = gs_header-ktonr.
    ls_fb01-aznum  = gs_header-aznum.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*

    APPEND ls_fb01 TO gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  ENDIF.
ENDFORM.                    "DRUCK_KEINE-BUCHUNG

*eject
*---------------------------------------------------------------------*
*       FORM DRUCK_BUZEI_FTCLEAR.                                     *
*---------------------------------------------------------------------*
*       Protokoll bei FB05 FTCLEAR-Zeilen                             *
*---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form druck_buzei_ftclear using saknr.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM druck_buzei_ftclear USING saknr
                         CHANGING xt_fb01 LIKE gt_fb01_1.
  DATA: ls_fb01 TYPE fagl_acc_s_rfebbu00_alv.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  DATA: amount LIKE febep-kwbtr.
  DATA: currency LIKE febep-kwaer.     "INSERT - mpEURO
  CLEAR: amount.
  buzei = buzei + 1.
  CLEAR xskat.
  IF ftclear-agkoa = 'S'.
    PERFORM xskat_lesen USING ftclear-agkon.
  ENDIF.
  IF p_bupro = 'X'.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    write: /01     sy-vline,
*            41(03) buzei,
*            45(02) ikofi-attr1,
*            51(10) ftclear-agkon,
*            62(20) xskat-txt20,
*            104(05) ftclear-selfd.
*    if ftclear-selfd eq 'WRBTR'.
*      if febep-fwbtr is initial or bereich = '1'.   "INSERT -mpEURO
**     no original transaction currency provided or posting area = 1.
*        currency = febep-kwaer.
*      else.
**     original transaction currency provided and posting area = 2.
*        currency = febep-fwaer.        "INSERT - mpEURO
*      endif.
*      amount = ftclear-selvon.
**     write: 110(20) amount currency febep-kwaer.  "DELETE - mpEURO
*      write: 110(20) amount currency currency.     "INSERT - mpEURO
*    else.
*      write: 110(20) ftclear-selvon.
*    endif.
*    write: 132     sy-vline.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    CLEAR ls_fb01.
    ls_fb01-buzei = buzei.
*    ls_fb01-blart = ikofi-attr1.
    ls_fb01-saknr = ftclear-agkon.
    ls_fb01-txt20 = xskat-txt20.
    ls_fb01-selfd = ftclear-selfd.
    IF ftclear-selfd EQ 'WRBTR'.
      IF febep-fwbtr IS INITIAL OR bereich = '1'.
        currency = febep-kwaer.
      ELSE.
        currency = febep-fwaer.
      ENDIF.
      amount = ftclear-selvon.
      ls_fb01-amount = amount.
      ls_fb01-currency = currency.                          "n875861
    ELSE.
      ls_fb01-selvon = ftclear-selvon.
    ENDIF.
    ls_fb01-bername    = bername.

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
    ls_fb01-bankl  = gs_header-bankl.
    ls_fb01-ktonr  = gs_header-ktonr.
    ls_fb01-aznum  = gs_header-aznum.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*
    ls_fb01-kukey     = febko-kukey.                "n853370
    ls_fb01-mappe     = mappe.

    APPEND ls_fb01 TO xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  ENDIF.
ENDFORM.                    "DRUCK_BUZEI_FTCLEAR

*eject
*---------------------------------------------------------------------*
*       FORM DRUCK_FBRA_ZEILE.
*---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form druck_fbra_zeile.
*  if p_bupro = 'X'.
*    reserve 6 lines.
*    write: /01 sy-vline, 02 sy-uline(130), 132 sy-vline.
*    char80 = text-035.
*    replace '&' with augbl into char80.
*    write: /01     sy-vline,
*            02(05) febep-esnum,
*            08(04) febep-vgint,
*            14(20) febep-vgext,
*            35(04) tcode,
*            41(80) char80,
*            132    sy-vline.
*  endif.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM druck_fbra_zeile CHANGING xt_fb01 LIKE gt_fb01_1.
  DATA: ls_fb01 TYPE fagl_acc_s_rfebbu00_alv.
  IF p_bupro = 'X'.
    char80 = text-035.
    REPLACE '&' WITH augbl INTO char80.
    CLEAR ls_fb01.
    ls_fb01-esnum  = febep-esnum.
    ls_fb01-vgint = febep-vgint.
    ls_fb01-vgext = febep-vgext.
    ls_fb01-tcode = tcode.
    ls_fb01-msg   = char80.
    ls_fb01-bername    = bername.

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
    ls_fb01-bankl  = gs_header-bankl.
    ls_fb01-ktonr  = gs_header-ktonr.
    ls_fb01-aznum  = gs_header-aznum.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*
    ls_fb01-kukey     = febko-kukey.                "n853370
    ls_fb01-mappe     = mappe.

    APPEND ls_fb01 TO xt_fb01.
  ENDIF.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
ENDFORM.                    "DRUCK_FBRA_ZEILE
*eject
*---------------------------------------------------------------------*
*       FORM DRUCK_FB08_ZEILE.
*---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form druck_fb08_zeile.
*  if p_bupro = 'X'.
**   RESERVE 6 LINES.
**   WRITE: /01 SY-VLINE, 02 SY-ULINE(130), 132 SY-VLINE.
*    char80 = text-036.
*    replace '&' with belns into char80.
*    write: /01     sy-vline,
*            02(05) febep-esnum,
*            08(04) febep-vgint,
*            14(20) febep-vgext,
*            35(04) tcode,
*            41(80) char80,
*            132    sy-vline.
*  endif.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM druck_fb08_zeile CHANGING xt_fb01 LIKE gt_fb01_1.
  DATA: ls_fb01 TYPE fagl_acc_s_rfebbu00_alv.
  IF p_bupro = 'X'.
    char80 = text-036.
    REPLACE '&' WITH belns INTO char80.
    CLEAR ls_fb01.
    ls_fb01-esnum  = febep-esnum.
    ls_fb01-vgint = febep-vgint.
    ls_fb01-vgext = febep-vgext.
    ls_fb01-tcode = tcode.
    ls_fb01-msg   = char80.
    ls_fb01-bername    = bername.

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
    ls_fb01-bankl  = gs_header-bankl.
    ls_fb01-ktonr  = gs_header-ktonr.
    ls_fb01-aznum  = gs_header-aznum.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*
    ls_fb01-kukey     = febko-kukey.                "n853370
    ls_fb01-mappe     = mappe.

    APPEND ls_fb01 TO xt_fb01.
  ENDIF.
ENDFORM.                    "DRUCK_FB08_ZEILE
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
*eject
*---------------------------------------------------------------------*
*       FORM DRUCK_FEHLERPROTOKOLL.
*---------------------------------------------------------------------*
FORM druck_fehlerprotokoll CHANGING xt_fb01 LIKE gt_fb01_1.
  DATA: ls_fb01 TYPE fagl_acc_s_rfebbu00_alv.

  DESCRIBE TABLE vb_error LINES tfill_error.
  IF tfill_error > 0.
*   Printflag setzen 'E' = Errorprotokoll
    printflag = 'E'.

    PERFORM header_data CHANGING gt_header.     "n885796

    SORT vb_error.
    LOOP AT vb_error.
      AT NEW buber.
        NEW-PAGE.
      ENDAT.

      CLEAR ls_fb01.
      ls_fb01-esnum       = vb_error-esnum.
      ls_fb01-msg        = vb_error-zeile.
      ls_fb01-bername    = bername.

      ls_fb01-bankl  = gs_header-bankl.
      ls_fb01-ktonr  = gs_header-ktonr.
      ls_fb01-aznum  = gs_header-aznum.

      ls_fb01-kukey     = febko-kukey.                "n853370
      ls_fb01-mappe     = mappe.

      APPEND ls_fb01 TO xt_fb01.

      AT END OF buber.
*       NEW-PAGE.
      ENDAT.
    ENDLOOP.
    REFRESH vb_error.
  ELSE.
    IF  function = 'C'
        AND p_bupro  = 'X'.
    ENDIF.
  ENDIF.
ENDFORM.                    "DRUCK_FEHLERPROTOKOLL


*eject
*---------------------------------------------------------------------*
*       FORM DRUCK_STATISTIK.
*---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form druck_statistik.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM druck_statistik CHANGING xt_statis LIKE gt_statis.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  CASE anwnd.
    WHEN '0001'.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*      perform statistik.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
      PERFORM statistik CHANGING xt_statis.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
    WHEN '0002'.
*      perform statistik.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
      PERFORM statistik CHANGING xt_statis.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
    WHEN '0003'.
      PERFORM lockbox_statistik.
  ENDCASE.
ENDFORM.                    "DRUCK_STATISTIK

*eject
*---------------------------------------------------------------------*
*       FORM LOCKBOX_STATISTIK.
*---------------------------------------------------------------------*
*       Lockbox-Statistik
*---------------------------------------------------------------------*
FORM lockbox_statistik.                "CHECK - mpEURO
  DATA: totl_cnt TYPE i.
  DATA: appl_cnt TYPE i.
  DATA: papl_cnt TYPE i.
  DATA: poac_cnt TYPE i.
  DATA: unid_cnt TYPE i.
  DATA: totl_sum  LIKE febep-kwbtr.
  DATA: appl_sum  LIKE febep-kwbtr.
  DATA: papl_sum  LIKE febep-kwbtr.
  DATA: poac_sum  LIKE febep-kwbtr.
  DATA: unid_sum  LIKE febep-kwbtr.
  DATA: totl_txt(5) TYPE c.
  DATA: appl_txt(5) TYPE c.
  DATA: papl_txt(5) TYPE c.
  DATA: poac_txt(5) TYPE c.
  DATA: unid_txt(5) TYPE c.
  DATA: outesnum TYPE i.               "40a numeric
  FORMAT RESET.

  DATA: lv_text(20) TYPE c,lv_text1(20) TYPE c,
        lv_cnt(3) TYPE i VALUE 0.
  SORT lbmsg.
  LOOP AT s_kukey.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM febko WHERE kukey = s_kukey-low.
*
* NEW CODE
    SELECT *
 FROM febko WHERE kukey = s_kukey-low ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    ENDSELECT.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM febep INTO TABLE xfebep
*           WHERE kukey = s_kukey-low.
*
* NEW CODE
    SELECT *
 FROM febep INTO TABLE xfebep
           WHERE kukey = s_kukey-low ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    IF sy-subrc = 0.
      NEW-PAGE.
      CLEAR:  totl_cnt,  totl_sum,  totl_txt,
              appl_cnt,  appl_sum,  appl_txt,
              papl_cnt,  papl_sum,  papl_txt,
              poac_cnt,  poac_sum,  poac_txt,
              unid_cnt,  unid_sum,  unid_txt.

      LOOP AT xfebep.
        outesnum = xfebep-esnum.       "drop zeros
************************************************************************
***    Begin of ALV Conversion                   C5053309
************************************************************************
        lv_text = xfebep-esnum.
*        write: /01     sy-vline,
*                03(13) xfebep-chect,
*                18(10) xfebep-avkon,
*                30(16) xfebep-kwbtr    "CHECK - mpEURO
*                       currency xfebep-kwaer,  "CHECK - mpEURO
*                47(10) xfebep-belnr,
*                58(10) xfebep-nbbln,
*                69(10) xfebep-akbln.
        MOVE-CORRESPONDING xfebep TO gs_outtab.
        IF NOT xfebep-nbbln IS INITIAL.
          IF xfebep-estat = '3'.
*--------- Partially Applied ----------------------------    -----
            papl_sum = papl_sum + xfebep-kwbtr. "CHECK - mpEURO
            papl_cnt = papl_cnt + 1.
*            write: 80(15) text-l36.
*            write: 95(5)  outesnum,                         "40a
*                  100(3)  xfebep-batch.                     "40a
            MOVE  text-l36 TO gs_outtab-sgtxt.
            CONCATENATE text-l36 lv_text xfebep-batch INTO gv_text
                                                    SEPARATED BY space.
          ELSE.
*--------- Applied --------------------------------------    -----
            appl_sum = appl_sum + xfebep-kwbtr. "CHECK - mpEURO
            appl_cnt = appl_cnt + 1.
*            write: 80(15) text-l30.
*            write: 95(5)  outesnum,                         "40a
*                  100(3)  xfebep-batch.                     "40a
            MOVE  text-l30 TO gs_outtab-sgtxt.

            CONCATENATE text-l36 lv_text xfebep-batch INTO gv_text
                                                    SEPARATED BY space.
          ENDIF.
        ELSEIF NOT xfebep-akbln IS INITIAL.
*--------- On Account -----------------------------------    -----
          poac_sum = poac_sum + xfebep-kwbtr. "CHECK - mpEURO
          poac_cnt = poac_cnt + 1.
*          write: 80(15) text-l34,
**                95(5)  xfebep-esnum,                "40a
*                 95(5)  outesnum,                           "40a
*                100(3)  xfebep-batch,                       "40a
*                104(10) xfebep-avkon,
*                115(16) xfebep-avsid.
          MOVE  text-l34 TO gs_outtab-sgtxt.
          move  xfebep-avsid to gs_outtab-avsid.
        ELSE.
*--------- Unprocessed ----------------------------------    -----
          FORMAT COLOR COL_NEGATIVE.
          unid_sum = unid_sum + xfebep-kwbtr. "CHECK - mpEURO
          unid_cnt = unid_cnt + 1.
*          write: 80(15) text-l32,
***               96(07) TEXT-L33,
**                96(4)  xfebep-esnum,                "40a
*                 95(5)  outesnum,                           "40a
*                100(3)  xfebep-batch,                       "40a
*                104(10) xfebep-avkon,
*                115(16) xfebep-avsid.
*          format reset.
          MOVE  text-l32 TO gs_outtab-sgtxt.
          move  xfebep-avsid to gs_outtab-avsid.
        ENDIF.

        concatenate gs_outtab-AVKON gs_outtab-AVSID
        into gs_outtab-ADVICE separated by space.
*        write:  132     sy-vline.
        lv_cnt = 1.
        loop at lbmsg where kukey =  gs_outtab-kukey
                      and   esnum =  gs_outtab-esnum.
          if lv_cnt > 1.
            clear gs_outtab.
          endif.
          gs_outtab-kukey = lbmsg-kukey.
          gs_outtab-esnum = lbmsg-esnum.
          gs_outtab-messages = lbmsg-text.
          lv_cnt = lv_cnt + 1.
          APPEND gs_outtab TO gt_outtab3.
        endloop.
        if sy-subrc <> 0.
* no messages for that check, so we have to write it without message
          append gs_outtab to gt_outtab3.
        endif.
*        PERFORM write_lbmsg_lines.
      ENDLOOP.



*     TOTL_CNT  =  APPL_CNT + POAC_CNT + UNID_CNT.
*     TOTL_SUM  =  APPL_SUM + POAC_SUM + UNID_SUM.
      totl_cnt  =  appl_cnt + poac_cnt + unid_cnt + papl_cnt.
      totl_sum  =  appl_sum + poac_sum + unid_sum + papl_sum.
      totl_txt  =  totl_cnt.
      appl_txt  =  appl_cnt.
      papl_txt  =  papl_cnt.
      poac_txt  =  poac_cnt.
      unid_txt  =  unid_cnt.
*      uline.

*      write:  /1 sy-vline,
*              11 text-l01.
*
*      write:  65 text-l03,
*              73(07) text-l10,
*             132 sy-vline.
      CONCATENATE text-l01 text-l03 INTO gv_text1 SEPARATED BY space.

*      write:  /1 sy-vline,
*               2 text-l04.
*      write:  11  febko-azdat dd/mm/yyyy,
*              35(15) text-l30,
*              50 appl_sum currency xfebep-kwaer,      "CHECK - mpEURO
*              73 appl_txt,
*             132 sy-vline.
      MOVE : appl_sum TO lv_text.
      CONCATENATE text-l04 febko-azdat text-l30 lv_text appl_txt
                                      INTO gv_text2 SEPARATED BY space.

*      write:  /1 sy-vline,
*               2 'Lockbox:'(l09).
*      write:  11  febko-azidt+0(7),
*              35(15) text-l36,
**             35(15) TEXT-L34,
**             50 POAC_SUM CURRENCY XFEBEP-KWAER,
**             73 POAC_TXT,
*              50 papl_sum currency xfebep-kwaer, "CHECK - mpEURO
*              73 papl_txt,
*             132 sy-vline.
      MOVE : poac_sum TO lv_text,
             papl_txt TO lv_text1.
      CONCATENATE 'Lockbox:'(l09) febko-azidt+0(7) text-l36 text-l34
   lv_text poac_txt lv_text1 papl_txt INTO gv_text3 SEPARATED BY space.


*      write:  /1 sy-vline,
*              35(15) text-l34,
*              50 poac_sum currency xfebep-kwaer, "CHECK - mpEURO
*              73 poac_txt,
*             132 sy-vline.
      MOVE : poac_sum TO lv_text.
      CONCATENATE text-l34 lv_text poac_txt INTO gv_text4
                                             SEPARATED BY space.

      unid_cnt =  unid_cnt.
*      write:  /1 sy-vline,
*              35(15) text-l32,
*              50 unid_sum currency xfebep-kwaer, "CHECK - mpEURO
*              73 unid_txt,
*             132 sy-vline.
      MOVE : unid_sum TO lv_text1.
      CONCATENATE text-l32 lv_text1 unid_txt INTO gv_text5
                                             SEPARATED BY space.

*      write: /1 sy-vline,
*              35(15) text-l35,
*              50 totl_sum currency xfebep-kwaer, "CHECK - mpEURO
*              73 totl_txt,
*             132 sy-vline.
      MOVE : totl_sum TO lv_text.
      CONCATENATE text-l35 lv_text totl_txt INTO gv_text6 SEPARATED
                                                           BY space.
    ENDIF.

*    uline.
  ENDLOOP.

** Routine for ALV display
  PERFORM display_list.
************************************************************************
***    End of ALV Conversion                   C5053309
************************************************************************


ENDFORM.                    "LOCKBOX_STATISTIK

*eject
*---------------------------------------------------------------------*
*       FORM STATISTIK.
*---------------------------------------------------------------------*
*       Statistik für Kontoauszug und Scheckeinreicher
*---------------------------------------------------------------------*
FORM statistik CHANGING xt_statis LIKE gt_statis.
  DATA: ls_statis TYPE fagl_acc_s_rfebbu00_alv_statis.
  DATA: s_waers  LIKE febko-waers.
  printflag = 'S'.
  NEW-PAGE.
  SORT statist.

  LOOP AT statist.
    AT NEW buber.
      IF statist-buber = '1'.
        ls_statis-bername = text-011.
      ELSE.
        ls_statis-bername = text-012.
      ENDIF.
    ENDAT.

    LOOP AT xfebvw WHERE anwnd = statist-anwnd
                     AND absnd = statist-absnd
                     AND azidt = statist-azidt.
      EXIT.
    ENDLOOP.

    IF function = 'C'.
      CLEAR statist-group.
    ENDIF.
    ls_statis-bankl    = xfebvw-bankl.
    ls_statis-ktonr    = statist-ktonr.
    ls_statis-groupid  = statist-group.
    ls_statis-grpnr    = statist-grpnr.
    ls_statis-fb01     = statist-fb01.
    ls_statis-fb05     = statist-fb05.
    ls_statis-akont    = statist-akont.
    ls_statis-notpo    = statist-notpo.
    ls_statis-error    = statist-error.
    ls_statis-summe    = statist-summe.
    ls_statis-sumso    = statist-sumso.
    ls_statis-sumha    = statist-sumha.
    ls_statis-kukey    = statist-kukey.
    ls_statis-waers    = statist-waers.
    APPEND ls_statis TO xt_statis.
  ENDLOOP.

ENDFORM.                    "STATISTIK

*eject
*---------------------------------------------------------------------*
*       FORM EINZELPOSTEN_INTERPRETIEREN.
*---------------------------------------------------------------------*
FORM einzelposten_interpretieren.
*   SELFIELD = SELFD.
*   SELLEN   = SELFDLEN.
*   UEXIT    = USEREXIT.                                     "30D
  bdart    = pa_bdart.
  IF  pa_bdart = '2'
  AND pa_bdanz IS INITIAL.
    bdanz = 100.
  ELSE.
    bdanz = pa_bdanz.
  ENDIF.
  REFRESH filter.
*   Filtertabelle aufbauen für die gültigen Nummernbereiche
  LOOP AT s_filter.
    filter = s_filter.
    APPEND filter.
  ENDLOOP.
  REFRESH tfilter.
*   Filtertabelle aufbauen für die gültigen Nummernbereiche
  LOOP AT t_filter.
    tfilter = t_filter.
    APPEND tfilter.
  ENDLOOP.

*   Kukeytabelle  aufbauen
  LOOP AT s_kukey.
    MOVE-CORRESPONDING s_kukey TO r_kukey.
    APPEND r_kukey.
  ENDLOOP.

*   Auswertung und Interpretation der Einzelposten
  PERFORM einzelposten_auswerten(ZFI_RFEBBU10) USING testl.
ENDFORM.                    "EINZELPOSTEN_INTERPRETIEREN



*eject
*----------------------------------------------------------------------*
*       FORM FB01_BSEG.                                                *
*----------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form fb01_bseg.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM fb01_bseg CHANGING xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  DATA: overrule_compression_s.        "INSERT - mpEURO
  DATA: overrule_compression_h.        "INSERT - mpEURO


  ftpost-stype = 'P'.

*  IF ( NOT FEBEP-KOSTL IS INITIAL ) OR ( NOT FEBEP-PRCTR IS INITIAL ).
*    PERFORM CHECK_IF_COST_RELEVANT USING IKOFI-SAKN1 CRC_FLAG.
*  ENDIF.

* Soll-Zeile
  CASE ikofi-komk1.
    WHEN ' '.
      item_cnt = item_cnt + 1.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*      perform fb01_bseg_soll.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
      PERFORM fb01_bseg_soll CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
    WHEN 'B'.
      item_cnt = item_cnt + 1.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*      perform fb01_bseg_soll.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
      PERFORM fb01_bseg_soll CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
    WHEN 'X'.
      IF febep-fwaer IS INITIAL        "INSERT - mpEURO
      OR febep-fwaer = febep-kwaer.    "CHECK - mpEURO  "INSERT - mpEURO
*     no original transaction currency or equal to account currency
        PERFORM fb01_bseg_soll_komk_x.
      ELSE.
        IF bereich = '1' AND febep-epvoz = 'H'.         "INSERT - mpEURO
*       incmng pymt - compress debit side of area 1 in FEBEP-KWAER ok
          PERFORM fb01_bseg_soll_komk_x.
        ELSEIF bereich = '2' AND febep-epvoz = 'S'.     "INSERT - mpEURO
*       incmng pymt - compress credit side of area 2 in FEBEP-FWAER ok
          PERFORM fb01_bseg_soll_komk_x.               "INSERT - mpEURO
        ELSE.
*       all other cases no compression on interim account allowed
          overrule_compression_s = 'X'."INSERT - mpEURO
          item_cnt = item_cnt + 1.     "INSERT - mpEURO
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*      perform fb01_bseg_soll.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
          PERFORM fb01_bseg_soll CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
        ENDIF.                         "INSERT - mpEURO
      ENDIF.                           "INSERT - mpEURO
    WHEN OTHERS.
  ENDCASE.

*  IF ( NOT FEBEP-KOSTL IS INITIAL ) OR ( NOT FEBEP-PRCTR IS INITIAL ).
*    PERFORM CHECK_IF_COST_RELEVANT USING IKOFI-SAKN2 CRC_FLAG.
*  ENDIF.

* Haben-Zeile
  CASE ikofi-komk2.
    WHEN ' '.
      item_cnt = item_cnt + 1.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*      perform fb01_bseg_haben.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
      PERFORM fb01_bseg_haben CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
    WHEN 'B'.
      item_cnt = item_cnt + 1.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*      perform fb01_bseg_haben.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
      PERFORM fb01_bseg_haben CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
    WHEN 'X'.
      IF febep-fwaer IS INITIAL        "INSERT - mpEURO
      OR febep-fwaer = febep-kwaer.    "CHECK - mpEURO  "INSERT - mpEURO
*     no original transaction currency or equal to account currency
        PERFORM fb01_bseg_haben_komk_x.
      ELSE.
        IF bereich = '1' AND febep-epvoz = 'S'.         "INSERT - mpEURO
*       outgng pymt - compress credit side of area 1 in FEBEP-KWAER ok
          PERFORM fb01_bseg_haben_komk_x.
        ELSEIF bereich = '2' AND febep-epvoz = 'H'.     "INSERT - mpEURO
*       incmng pymt - compress debit side of area 2 in FEBEP-FWAER ok
          PERFORM fb01_bseg_haben_komk_x.              "INSERT - mpEURO
        ELSE.
*       all other cases no compression on interim account allowed
          overrule_compression_h = 'X'."INSERT - mpEURO
          item_cnt = item_cnt + 1.     "INSERT - mpEURO
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*      perform fb01_bseg_haben.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
          PERFORM fb01_bseg_haben CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
        ENDIF.                         "INSERT - mpEURO
      ENDIF.                           "INSERT - mpEURO
    WHEN '2'.
    WHEN OTHERS.
  ENDCASE.

* Verbuchungsflag bei komprimierten Buchungen
  IF ( ikofi-komk1 = 'X' AND overrule_compression_s = ' ' )   "mpEURO
  OR ( ikofi-komk2 = 'X' AND overrule_compression_h = ' ' ).  "mpEURO
    vbkep-kukey = febep-kukey.
    vbkep-esnum = febep-esnum.
    APPEND vbkep.
  ENDIF.

* clear compression flag if all compression is overruled.
  IF ( ( ikofi-komk1 = 'X' AND overrule_compression_s = 'X' )   "mpEURO
         AND ikofi-komk2 = ' ' )       "INSERT - mpEURO
  OR                                   "INSERT - mpEURO
     ( ( ikofi-komk2 = 'X' AND overrule_compression_h = 'X' )   "mpEURO
         AND ikofi-komk1 = ' ' ).      "INSERT - mpEURO
*    no compression at all - do immediate posting (-> KOMK = ' ')
*    no perform abschluß_komprmierung necessary (only FTPOST entries)
    CLEAR: komk.                       "INSERT - mpEURO
  ENDIF.                               "INSERT - mpEURO

* generate line items for differences between account and original
* transaction currency (Euro Currencies only)

* if not (    ( febep-fwaer is initial or febep-fwbtr is initial )
*          or   febep-kwaer = febep-fwaer
*          or   bereich = '2'  ).
* OCMT provided and OCMT currency ne account currency and
* posting area 1
*    perform check_euro_currencies using febep-fwaer
*                                        febep-kwaer
*                                        rate_fixed
*                                        subrc.

*   if subrc = 0 and not rate_fixed is initial.
*      only EURO currencies involved and customizing ok
*      perform check_amounts using febep-fwaer         "INSERT - mpEUR
*                                  febep-fwbtr         "INSERT - mpEUR
*                                  febep-kwaer         "INSERT - mpEUR
*                                  febep-kwbtr         "INSERT - mpEUR
*                                  delta_kwbtr         "INSERT - mpEUR
*                                  subrc.              "INSERT - mpEUR
*      if subrc ne 0.
*         difference occurred in calculation of account currency amount
*         reasons: implicit charges, rounding and/or summing procedure
*         perform euro_diff_acc_determination using euro_diff_ikofi
*                                                   subrc.
*         if subrc = 0.
*            account determination successful
*            perform check_ikofi using euro_diff_ikofi
*                                      febep-epvoz
*                                      delta_kwbtr
*                                      subrc.
*            if subrc = 0.
*               IKOfi_check successful -> generate line items
*                perform generate_line_items using euro_diff_ikofi
*                                                  febep-epvoz
*                                                  delta_kwbtr
*                                                  subrc.

*            endif.
*         endif.
*      endif.
*   else.
*      error in currency conversion or at least one NON EURO currency
*      involved -> do nothing -> manual processing on interim account
*   endif.
* endif.
ENDFORM.                                                    "FB01_BSEG

*eject
*---------------------------------------------------------------------*
*       FORM FB01_BSEG_SOLL.                                          *
*---------------------------------------------------------------------*
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM fb01_bseg_soll CHANGING xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form fb01_bseg_soll.
************************************************************************
***    End of comment                            C5053248
************************************************************************
  ftpost-count = ftpost-count + 1.
  PERFORM ftpost_field USING 'BSEG-BSCHL' ikofi-bsch1.    "Buchungsschlü

  PERFORM ftpost_field USING 'BSEG-HKONT' ikofi-sakn1.    "Sachkonto 1

  IF NOT ikofi-bukr1 IS INITIAL.                            "31H-HP
    PERFORM ftpost_field USING 'RF05A-NEWBK' ikofi-bukr1. "BUKRS 31H-HP
  ENDIF.                                                    "31H-HP

  IF NOT ikofi-shbk1 IS INITIAL.
    PERFORM ftpost_field USING 'RF05A-NEWUM' ikofi-shbk1. "Sonderhaupbkz
  ENDIF.

  PERFORM betraege_to_ftpost.          "Beträge

  IF NOT febep-valut IS INITIAL
*  AND ikofi-attr2 NE '2'                               "45A
  AND valut_on  = 'X'.
    WRITE febep-valut TO fvalue DD/MM/YYYY.
    IF ikofi-attr2 NE '2'.                                  "45A
      PERFORM ftpost_field USING 'BSEG-VALUT' fvalue.   "Valutadatum
    ELSE.                                                   "45A
      PERFORM ftpost_field USING 'BSEG-ZFBDT' fvalue.       "45A
    ENDIF.                                                  "45A
  ENDIF.

  IF ( bereich = 1 AND febep-epvoz = 'S' AND            "INSERT - mpEURO
       x_apa_def = 'X' AND febep-fwaer NE febep-kwaer ) "INSERT - mpEURO
     OR                                "INSERT - mpEURO
     ( bereich = 2 AND febep-epvoz = 'H' AND            "INSERT - mpEURO
       x_apa_def = 'X' AND febep-fwaer NE febep-kwaer )."INSERT - mpEURO
*   allocation number fixed on interim account
    MOVE const_zuonr TO char_zuonr.    "INSERT - mpEURO
    PERFORM ftpost_field USING 'BSEG-ZUONR' char_zuonr. "INSERT - mpEURO
  ELSE.                                "INSERT - mpEURO
    IF NOT febep-zuonr IS INITIAL.
      PERFORM ftpost_field USING 'BSEG-ZUONR' febep-zuonr.  "Zordnungsnr
    ENDIF.
  ENDIF.                               "INSERT - mpEURO

  PERFORM segmenttext_to_ftpost USING sgtxt.
  IF NOT sgtxt IS INITIAL.
    PERFORM ftpost_field USING 'BSEG-SGTXT' sgtxt.  "Text
  ENDIF.

  IF NOT febep-gsber IS INITIAL.
    IF ikofi-attr2 = '2'.
      PERFORM ftpost_field USING 'BSEG-GSBER' febep-gsber.
    ELSE.
      PERFORM ftpost_field USING 'COBL-GSBER' febep-gsber.    "Geschäfts
    ENDIF.
  ENDIF.

  IF NOT febep-kostl IS INITIAL        " AND CRC_FLAG = TRUE
  AND ikofi-attr2 NE '2'.
    PERFORM ftpost_field USING 'COBL-KOSTL' febep-kostl.    "Kostenstell
  ENDIF.

  IF NOT febep-prctr IS INITIAL        " AND CRC_FLAG = TRUE
  AND ikofi-attr2 NE '2'.
    PERFORM ftpost_field USING 'COBL-PRCTR' febep-prctr.    "ProfitCtr
  ENDIF.

  IF NOT febep-kidno IS INITIAL
  AND ikofi-attr2 EQ '2'.
    PERFORM ftpost_field USING 'BSEG-KIDNO' febep-kidno.   "Zahlungsref
  ENDIF.

  IF NOT febep-mansp IS INITIAL
  AND ikofi-attr2 EQ '2'.
    PERFORM ftpost_field USING 'BSEG-MANSP' febep-mansp.   "Mahnsperre
  ENDIF.

  IF ikofi-attr2 NE '2'.
    PERFORM additional_fields USING 'S'.     "User fields 1 - 3
  ELSE.
    PERFORM additional_fields USING 'D'.     "User fields 1 - 3
  ENDIF.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*  perform druck_buzei using ikofi-bsch1 ikofi-sakn1 blank.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
  PERFORM druck_buzei USING ikofi-bsch1 ikofi-sakn1 blank
                       CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
ENDFORM.                    "FB01_BSEG_SOLL
*eject
*---------------------------------------------------------------------*
*       FORM FB01_BSEG_HABEN_KOMK_X.                                  *
*---------------------------------------------------------------------*
*       Komprmierung der Haben-Zeile                                  *
*---------------------------------------------------------------------*
FORM fb01_bseg_haben_komk_x.
* FTPOST-COUNT = FTPOST-COUNT + 1.
  PERFORM betraege_komk_haben.         "Beträge

  IF bseg_komk_h_ok = true.
    EXIT.
  ENDIF.

  PERFORM ft_komk_h_field USING 'BSEG-BSCHL' ikofi-bsch2.   "BSCHL

  PERFORM ft_komk_h_field USING 'BSEG-HKONT' ikofi-sakn2. "Sachkonto 2

  IF NOT ikofi-shbk2 IS INITIAL.
    PERFORM ftpost_field USING 'RF05A-NEWUM' ikofi-shbk2. "Sonderhaupbkz
  ENDIF.


  IF NOT febep-valut IS INITIAL
*  AND ikofi-attr2 NE '3'                                 "45A
  AND valut_on  = 'X'.
    WRITE febep-valut TO fvalue DD/MM/YYYY.
    IF ikofi-attr2 NE '3'.                                  "45A
      PERFORM ft_komk_h_field USING 'BSEG-VALUT' fvalue.  "Valutadatum
    ELSE.                                                   "45A
      PERFORM ft_komk_h_field USING 'BSEG-ZFBDT' fvalue.    "45A
    ENDIF.                                                  "45A
  ENDIF.

  IF NOT febep-zuonr IS INITIAL.
*   if compress fill allocation field with kukey
    PERFORM ft_komk_h_field USING 'BSEG-ZUONR' febep-kukey. "Zordnungsnr
  ENDIF.

* PERFORM SEGMENTTEXT_TO_FTPOST.
  IF NOT febep-gsber IS INITIAL.
    IF ikofi-attr2 = '3'.
      PERFORM ft_komk_h_field USING 'BSEG-GSBER' febep-gsber.
    ELSE.
      PERFORM ft_komk_h_field USING 'COBL-GSBER' febep-gsber.
    ENDIF.
  ENDIF.

  IF NOT febep-kostl IS INITIAL        " AND CRC_FLAG = TRUE
  AND ikofi-attr2 NE '3'.
    PERFORM ft_komk_h_field USING 'COBL-KOSTL' febep-kostl.    "Kostenst
  ENDIF.

  IF NOT febep-prctr IS INITIAL        "AND CRC_FLAG = TRUE
  AND ikofi-attr2 NE '3'.
    PERFORM ft_komk_h_field USING 'COBL-PRCTR' febep-prctr.
  ENDIF.

  IF ikofi-attr2 NE '3'.
    PERFORM additional_fields_komk_h.  "User fields 1 - 3
  ENDIF.

  bseg_komk_h_ok = true.
ENDFORM.                    "FB01_BSEG_HABEN_KOMK_X

*eject
*---------------------------------------------------------------------*
*       FORM FB01_BSEG_SOLL_KOMK_X.                                   *
*---------------------------------------------------------------------*
*       Komprmierung der Soll-Zeile                                   *
*---------------------------------------------------------------------*
FORM fb01_bseg_soll_komk_x.
* FTPOST-COUNT = FTPOST-COUNT + 1.
  PERFORM betraege_komk_soll.          "Beträge

  IF bseg_komk_s_ok = true.
    EXIT.
  ENDIF.

  PERFORM ft_komk_s_field USING 'BSEG-BSCHL' ikofi-bsch1.   "BSCHL

  PERFORM ft_komk_s_field USING 'BSEG-HKONT' ikofi-sakn1. "Sachkonto 1

  IF NOT ikofi-shbk1 IS INITIAL.
    PERFORM ftpost_field USING 'RF05A-NEWUM' ikofi-shbk1. "Sonderhaupbkz
  ENDIF.


  IF NOT febep-valut IS INITIAL
*  AND ikofi-attr2 NE '2'                                 "45A
  AND valut_on  = 'X'.
    WRITE febep-valut TO fvalue DD/MM/YYYY.
    IF ikofi-attr2 NE '2'.                                  "45A
      PERFORM ft_komk_s_field USING 'BSEG-VALUT' fvalue.  "Valutadatum
    ELSE.                                                   "45A
      PERFORM ft_komk_s_field USING 'BSEG-ZFBDT' fvalue.    "45A
    ENDIF.                                                  "45A
  ENDIF.

  IF NOT febep-zuonr IS INITIAL.
*   if compress fill allocation field with kukey
    IF anwnd = '0003' AND komkb = 'X'.                      "46a
*    for lockbox batch compression, append batch number to zuonr
      CLEAR tmp_zuonr.                                      "46a
      CONCATENATE febep-kukey febep-batch INTO tmp_zuonr.   "46a
      PERFORM ft_komk_s_field USING 'BSEG-ZUONR' tmp_zuonr. "46a
    ELSE.                                                   "46a
      PERFORM ft_komk_s_field USING 'BSEG-ZUONR' febep-kukey. "Zordnungsnr
    ENDIF.                                                  "46a
  ENDIF.

* PERFORM SEGMENTTEXT_TO_FTPOST.

  IF NOT febep-gsber IS INITIAL.
    IF ikofi-attr2 = '2'.
      PERFORM ft_komk_s_field USING 'BSEG-GSBER' febep-gsber.
    ELSE.
      PERFORM ft_komk_s_field USING 'COBL-GSBER' febep-gsber.
    ENDIF.
  ENDIF.

  IF NOT febep-kostl IS INITIAL        "AND CRC_FLAG = TRUE
  AND ikofi-attr2 NE '2'.
    PERFORM ft_komk_s_field USING 'COBL-KOSTL' febep-kostl.
  ENDIF.

  IF NOT febep-prctr IS INITIAL        "AND CRC_FLAG = TRUE
  AND ikofi-attr2 NE '2'.
    PERFORM ft_komk_s_field USING 'COBL-PRCTR' febep-prctr.    "ProfitCt
  ENDIF.

  IF ikofi-attr2 NE '2'.
    PERFORM additional_fields_komk_s.  "User fields 1 - 3
  ENDIF.

  bseg_komk_s_ok = true.
ENDFORM.                    "FB01_BSEG_SOLL_KOMK_X

*eject
*---------------------------------------------------------------------*
*       FORM FB01_BELEGSEGMENT_HABEN.                                 *
*---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form fb01_bseg_haben.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM fb01_bseg_haben CHANGING xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  ftpost-count = ftpost-count + 1.

  PERFORM ftpost_field USING 'BSEG-BSCHL' ikofi-bsch2.    "Buchungsschlü
  PERFORM ftpost_field USING 'BSEG-HKONT' ikofi-sakn2.    "Sachkonto 2

  IF NOT ikofi-bukr2 IS INITIAL.                            "31H-HP
    PERFORM ftpost_field USING 'RF05A-NEWBK' ikofi-bukr2. "BUKRS 31H-HP
  ENDIF.                                                    "31H-HP

  IF NOT ikofi-shbk2 IS INITIAL.
    PERFORM ftpost_field USING 'RF05A-NEWUM' ikofi-shbk2. "Sonderhaupbkz
  ENDIF.


  PERFORM betraege_to_ftpost.          "Beträge

  IF NOT febep-valut IS INITIAL
*  AND ikofi-attr2 NE '3'                               "45A
  AND valut_on  = 'X'.
    WRITE febep-valut TO fvalue DD/MM/YYYY.
    IF ikofi-attr2 NE '3'.                                  "45A
      PERFORM ftpost_field USING 'BSEG-VALUT' fvalue.   "Valutadatum
    ELSE.                                                   "45A
      PERFORM ftpost_field USING 'BSEG-ZFBDT' fvalue.       "45A
    ENDIF.                                                  "45A
  ENDIF.

  IF ( bereich = 1 AND febep-epvoz = 'H' AND            "INSERT - mpEURO
       x_apa_def = 'X' AND febep-fwaer NE febep-kwaer ) "INSERT - mpEURO
     OR                                "INSERT - mpEURO
     ( bereich = 2 AND febep-epvoz = 'S' AND            "INSERT - mpEURO
       x_apa_def = 'X' AND febep-fwaer NE febep-kwaer )."INSERT - mpEURO
*    allocation number fixed on interim account
    MOVE const_zuonr TO char_zuonr.    "INSERT - mpEURO
    PERFORM ftpost_field USING 'BSEG-ZUONR' char_zuonr. "INSERT - mpEURO
  ELSE.                                "INSERT - mpEURO
    IF NOT febep-zuonr IS INITIAL.
      PERFORM ftpost_field USING 'BSEG-ZUONR' febep-zuonr.  "Zordnungsnr
    ENDIF.
  ENDIF.                               "INSERT - mpEURO

  PERFORM segmenttext_to_ftpost USING sgtxt.
  IF NOT sgtxt IS INITIAL.
    PERFORM ftpost_field USING 'BSEG-SGTXT' sgtxt.  "Text
  ENDIF.

  IF NOT febep-gsber IS INITIAL.
    IF ikofi-attr2 = '3'.
      PERFORM ftpost_field USING 'BSEG-GSBER' febep-gsber.
    ELSE.
      PERFORM ftpost_field USING 'COBL-GSBER' febep-gsber.    "Geschäfts
    ENDIF.
  ENDIF.

  IF NOT febep-kostl IS INITIAL        "AND CRC_FLAG = TRUE
  AND ikofi-attr2 NE '3'.
    PERFORM ftpost_field USING 'COBL-KOSTL' febep-kostl.    "Kostenstell
  ENDIF.

  IF NOT febep-prctr IS INITIAL        "AND CRC_FLAG = TRUE
  AND ikofi-attr2 NE '3'.
    PERFORM ftpost_field USING 'COBL-PRCTR' febep-prctr.    "ProfitCtr
  ENDIF.

  IF NOT febep-kidno IS INITIAL
  AND ikofi-attr2 EQ '3'.
    PERFORM ftpost_field USING 'BSEG-KIDNO' febep-kidno.   "Zahlungsref
  ENDIF.

  IF NOT febep-mansp IS INITIAL
  AND ikofi-attr2 EQ '3'.
    PERFORM ftpost_field USING 'BSEG-MANSP' febep-mansp.   "Mahnsperre
  ENDIF.

  IF ikofi-attr2 NE '3'.
    PERFORM additional_fields USING 'S'.     "User fields 1 - 3
  ELSE.
    PERFORM additional_fields USING 'D'.     "User fields 1 - 3
  ENDIF.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*  perform druck_buzei using ikofi-bsch2 ikofi-sakn2 blank.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
  PERFORM druck_buzei USING ikofi-bsch2 ikofi-sakn2 blank
                      CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
ENDFORM.                    "FB01_BSEG_HABEN

*eject
*---------------------------------------------------------------------*
*       FORM FB01_POSTING.                                            *
*---------------------------------------------------------------------*
*form fb01_posting.
FORM fb01_posting CHANGING xt_fb01 LIKE gt_fb01_1.
  PERFORM belegkopf USING ' '.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*  perform fb01_bseg .
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
  PERFORM fb01_bseg CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  IF komk = space.
*------- keine Komprimierung ------------------------------------------
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    perform fb01_posting_aufrufen.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    PERFORM fb01_posting_aufrufen CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  ENDIF.

  IF  komk NE space
  AND item_cnt > 900.
*------- Bei Komprimierung Belegzeilenüberlauf verhindern -------------
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    perform abschluss_komprimierung.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    PERFORM abschluss_komprimierung CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    perform fb01_posting_aufrufen.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    PERFORM fb01_posting_aufrufen CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  ENDIF.

ENDFORM.                    "FB01_POSTING

*eject
*---------------------------------------------------------------------*
*       FORM FB01_POSTING_AUFRUFEN.                                   *
*---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form  fb01_posting_aufrufen.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM  fb01_posting_aufrufen CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  CLEAR: subrc, msgid, msgty, msgno, msgv1, msgv2, msgv3, msgv4.

  IF open = false.
    PERFORM posting_interface_start.
  ENDIF.

  LOOP AT xfebcl WHERE kukey = febep-kukey
                   AND esnum = febep-esnum.
    PERFORM append_xfebcl_to_ftclear.                       "30D
  ENDLOOP.

* Aufruf eines externen Funktionsbausteins, falls notwendig
  PERFORM check_call_external_function.

  PERFORM ftpost_fieldselect TABLES ftpost
                             USING  febep
                                    febko.
  IF testl NE 'X'.
    IF xtrwpr = 'X' AND function = 'C'.                     "hw426052
      EXPORT bereich                                        "hw426052
             febep-kukey                                    "hw426052
             febep-esnum                                    "hw426052
             komk                                           "hw426052
             xakon                                          "hw426052
             r_csnum                                        "hw426052
             vbkep                                          "hw426052
             xfebcl                                         "hw426052
             TO MEMORY ID 'FEBA_POST'.                      "hw426052
    ENDIF.                                                  "hw426052
    CALL FUNCTION 'POSTING_INTERFACE_DOCUMENT'
      EXPORTING
        i_tcode  = tcode
      IMPORTING
        e_subrc  = subrc
        e_msgid  = msgid
        e_msgty  = msgty
        e_msgno  = msgno
        e_msgv1  = msgv1
        e_msgv2  = msgv2
        e_msgv3  = msgv3
        e_msgv4  = msgv4
      TABLES
        t_ftpost = ftpost
        t_fttax  = fttax
        t_blntab = xblntab.

    IF xtrwpr = 'X' AND function = 'C'.                        "n972881
      FREE MEMORY ID 'FEBA_POST'.                              "n972881
    ENDIF.                                                     "n972881

  ELSE.
*   beim Testlauf erfolgreiche Buchung simulieren
    subrc = 0.
  ENDIF.

  IF subrc = 0.
    IF xakon = 'X'.
      statist-akont = statist-akont + 1.
    ELSE.
      statist-fb01  = statist-fb01  + 1.
    ENDIF.
    PERFORM update_febep_status.
  ELSE.
    statist-error = statist-error + 1.
  ENDIF.

*----- Print Message if Call Trans and Posting Log (never for Lockbox)--
  IF  function = 'C'
  AND p_bupro  = 'X'.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*          perform druck_message.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    PERFORM druck_message CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  ENDIF.

*----- Save Message for Lockbox Posting Log ---------------------------
  IF anwnd = '0003'                                         "
  AND bereich NE '2'.                                       "30D
    PERFORM save_message_for_lbox_log USING bereich.        "
  ENDIF.                                                    "

*   Nach Buchung Komprimierungsflags wieder auf FALSE setzen
  bkpf_komk_ok   = false.
  bseg_komk_s_ok = false.
  bseg_komk_h_ok = false.
  CLEAR item_cnt.
  CLEAR ikofi.
  CLEAR komk.                          "compression
  CLEAR komkb.                                              "46a
  REFRESH: vbkep.                                           "45A
  CLEAR:   vbkep.                                           "45A

  REFRESH: ftpost.
  CLEAR:   ftpost.
  REFRESH: ftclear.                                         "
  CLEAR:   ftclear.                                         "
  REFRESH: xblntab.
  CLEAR:   xblntab.
  CLEAR:   xakon.
ENDFORM.                    "FB01_POSTING_AUFRUFEN

*eject
*---------------------------------------------------------------------*
*       FORM FB05_BELEGSEGMENT.                                       *
*---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form fb05_belegsegment.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM fb05_belegsegment CHANGING xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  DATA: i_akbln LIKE febep-akbln,      "<<< HP
        xavik LIKE avik,
        avsid LIKE avik-avsid.

  ftpost-stype = 'P'.
  ftpost-count = '1'.

  CLEAR i_akbln.                       "<<< HP
  IF febep-vb2ba <> 'S'. "Split                           "<<< HP
    i_akbln = febep-akbln.             "<<< HP
  ELSE.                                "<<< HP
    LOOP AT xfebcl WHERE kukey = febep-kukey AND          "<<< HP
                         esnum = febep-esnum AND          "<<< HP
                         csnum = r_csnum AND              "<<< HP
                         selfd = 'AVSID'.                 "<<< HP
      i_akbln = xfebcl-selbis+10.      "<<< HP
      avsid = xfebcl-selvon.           "<<< HP
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM avik INTO xavik                "<<< HP
*                     WHERE  bukrs  = febko-bukrs          "<<< HP
*                     AND    koart  = xfebcl-koart         "<<< HP
*                     AND    konto  = xfebcl-agkon         "<<< HP
*                     AND    avsid  = avsid.               
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM avik INTO xavik                "<<< HP
                     WHERE  bukrs  = febko-bukrs          "<<< HP
                     AND    koart  = xfebcl-koart         "<<< HP
                     AND    konto  = xfebcl-agkon         "<<< HP
                     AND    avsid  = avsid ORDER BY PRIMARY KEY.               

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01"<<< HP
      if xavik-waers = febep-kwaer.                  "hw809145
        febep-kwbtr = xavik-rwbtr.
      endif.
      if xavik-waers = febep-fwaer.
        febep-fwbtr = xavik-rwbtr.
      endif.
    ENDLOOP.                           "<<< HP
  ENDIF.                               "<<< HP

  IF bereich = '1' AND NOT febep-ak1bl IS INITIAL.          "hw638124
    i_akbln = febep-ak1bl.                                  "hw638124
  ENDIF.                                                    "hw638124

  CASE ikofi-attr2.
    WHEN '4'.
*     Ausziffern Sachkonto im Soll
      IF febep-avsid IS INITIAL.
*       if (  anwnd = '0001'          "bankstatement        "note 452579
*         and p_xnoadv = 'X'                                "note 452579
*         and bereich = '2'           "posting area 2       "note 452579
*         and not i_akbln is initial )"was posted onaccount "note 452579
        IF g_clear_on_account = 'C'.                        "hw638124
          PERFORM fb05_ftclear_sako USING ikofi-sakn1
                                    CHANGING xt_fb01.
          PERFORM add_on_acc_doc_to_ftclear USING i_akbln 'S'
                                                ikofi-sakn1 "hw750835
                                            CHANGING xt_fb01.
        ELSE.                                               "note 452579
          PERFORM fb05_ftpost_haben CHANGING xt_fb01.
          IF g_clear_on_account = 'P'.                      "hw638124
            PERFORM add_on_acc_doc_to_ftclear USING i_akbln 'S'
                                                ikofi-sakn1 "hw750835
                                              CHANGING xt_fb01.
          ELSE.                                             "hw638124
            PERFORM fb05_ftclear_sako USING ikofi-sakn1
                                      CHANGING xt_fb01.
          ENDIF.                                            "hw638124
        ENDIF.                                              "note 452579
      ELSE.
        IF i_akbln IS INITIAL.         "<<< HP
          PERFORM fb05_ftpost_haben CHANGING xt_fb01.
        ENDIF.
        PERFORM fb05_ftclear_avis CHANGING xt_fb01.
      ENDIF.
    WHEN '5'.
*     Ausziffern Sachkonto im Haben
      IF febep-avsid IS INITIAL.
*       if    anwnd = '0001'          "bankstatement        "note 452579
*         and p_xnoadv = 'X'                                "note 452579
*         and bereich = '2'           "posting area 2       "note 452579
*         and not i_akbln is initial. "was posted onaccount "note 452579
        IF g_clear_on_account = 'C'.                        "hw638124
          PERFORM fb05_ftclear_sako USING ikofi-sakn2
                                    CHANGING xt_fb01.
          PERFORM add_on_acc_doc_to_ftclear USING i_akbln 'S'
                                              ikofi-sakn2   "hw750835
                                            CHANGING xt_fb01.
        ELSE.                                               "note 452579
          PERFORM fb05_ftpost_soll CHANGING xt_fb01.
          IF g_clear_on_account = 'P'.                      "hw638124
            PERFORM add_on_acc_doc_to_ftclear USING i_akbln 'S'
                                              ikofi-sakn2   "hw750835
                                              CHANGING xt_fb01.
          ELSE.                                             "hw638124
            PERFORM fb05_ftclear_sako USING ikofi-sakn2
                                      CHANGING xt_fb01.
          ENDIF.                                            "hw638124
        ENDIF.                                              "note 452579
      ELSE.
        IF i_akbln IS INITIAL.         "<<< HP
          PERFORM fb05_ftpost_soll CHANGING xt_fb01.
        ENDIF.
        PERFORM fb05_ftclear_avis CHANGING xt_fb01.
      ENDIF.
    WHEN '7'.
*   Personenkonto ausziffern im Soll (Kreditor)
      IF febep-avsid IS INITIAL.
*       if    anwnd = '0001'          "bankstatement        "note 452579
*         and p_xnoadv = 'X'                                "note 452579
*         and bereich = '2'           "posting area 2       "note 452579
*         and not i_akbln is initial. "was posted onaccount "note 452579
        IF g_clear_on_account = 'C'.                        "hw638124
          PERFORM fb05_ftclear_kredi CHANGING xt_fb01.
          PERFORM add_on_acc_doc_to_ftclear USING i_akbln 'K'
                                                      ' '   "hw750835
                                            CHANGING xt_fb01.
        ELSE.                                               "note 452579
          PERFORM fb05_ftpost_haben CHANGING xt_fb01.
          IF g_clear_on_account = 'P'.                      "hw638124
            PERFORM add_on_acc_doc_to_ftclear USING i_akbln 'K'
                                                       ' '  "hw750835
                                              CHANGING xt_fb01.
          ELSE.                                             "hw638124
            PERFORM fb05_ftclear_kredi CHANGING xt_fb01.
          ENDIF.                                            "hw638124
        ENDIF.                                              "note 452579
      ELSE.
        IF i_akbln IS INITIAL.         "<<< HP
          PERFORM fb05_ftpost_haben CHANGING xt_fb01.
        ENDIF.
        PERFORM fb05_ftclear_avis CHANGING xt_fb01.
      ENDIF.
    WHEN '8'.
*   Debitor ausziffern im Haben
      IF febep-avsid IS INITIAL.
*       if    anwnd = '0001'          "bankstatement        "note 452579
*         and p_xnoadv = 'X'                                "note 452579
*         and bereich = '2'           "posting area 2       "note 452579
*         and not i_akbln is initial. "was posted onaccount "note 452579
        IF g_clear_on_account = 'C'.                        "hw638124
          PERFORM fb05_ftclear_debi CHANGING xt_fb01.
          PERFORM add_on_acc_doc_to_ftclear USING i_akbln 'D'
                                                       ' '  "hw750835
                                            CHANGING xt_fb01.
        ELSE.                                               "note 452579
          PERFORM fb05_ftpost_soll CHANGING xt_fb01.
          IF g_clear_on_account = 'P'.                      "hw638124
            PERFORM add_on_acc_doc_to_ftclear USING i_akbln 'D'
                                                       ' '  "hw750835
                                              CHANGING xt_fb01.
          ELSE.                                             "hw638124
            PERFORM fb05_ftclear_debi CHANGING xt_fb01.
          ENDIF.                                            "hw638124
        ENDIF.                                              "note 452579
      ELSE.
        IF i_akbln IS INITIAL.         "<<< HP
          PERFORM fb05_ftpost_soll CHANGING xt_fb01.
        ENDIF.
        PERFORM fb05_ftclear_avis CHANGING xt_fb01.
      ENDIF.
    WHEN OTHERS.
*     diese Buchungsart wird zur Zeit noch nicht unterstützt
      MESSAGE e782 WITH ikofi-attr2 ad_vgint ad_bereich.
  ENDCASE.
ENDFORM.                    "FB05_BELEGSEGMENT

*eject
*---------------------------------------------------------------------*
*       FORM FB05_FTCLEAR_AVIS.                                       *
*---------------------------------------------------------------------*
*       Clearing-Daten für Auszifferung über Avis                     *
*---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form fb05_ftclear_avis.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM fb05_ftclear_avis CHANGING xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  CLEAR ftclear.

  IF xfebcl-agbuk IS INITIAL.
    ftclear-agbuk = febko-bukrs.
  ELSE.
    ftclear-agbuk = xfebcl-agbuk.
  ENDIF.

  ftclear-xnops  = 'X'.
  IF febko-anwnd = '0003' AND febep-posag <> 'X'.           "hw640076
    ftclear-agums = febep-posag.                            "hw640076
  ELSEIF ikofi-attr2 EQ '7'.
    ftclear-agums = ikofi-shbk1.
  ELSEIF ikofi-attr2 EQ '8'.
    ftclear-agums = ikofi-shbk2.
  ENDIF.                                                    "hw640076

  ftclear-agkoa  = febep-avkoa.
  ftclear-agkon  = febep-avkon.
  IF febep-vb2ba <> 'S'.               "<<< HP
    ftclear-avsid  = febep-avsid.
  ELSE.                                "<<< HP
    LOOP AT xfebcl WHERE kukey = febep-kukey AND    "<<< HP
                         esnum = febep-esnum AND    "<<< HP
                         csnum = r_csnum.           "<<< HP
      ftclear-avsid = xfebcl-selvon.   "<<< HP
    ENDLOOP.                           "<<< HP
  ENDIF.                               "<<< HP

  APPEND ftclear.
  LOOP AT xfebcl WHERE kukey = febep-kukey                  "hw591845
                   AND esnum = febep-esnum                  "hw591845
                   AND selfd = 'FB'.                        "hw591845
    PERFORM append_xfebcl_to_ftclear.                       "hw591845
  ENDLOOP.                                                  "hw591845

************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*  perform druck_avis_ftclear.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
  PERFORM druck_avis_ftclear CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
ENDFORM.                    "FB05_FTCLEAR_AVIS

*eject
*---------------------------------------------------------------------*
*       FORM FB05_FTCLEAR_DEBI.                                       *
*---------------------------------------------------------------------*
*       Clearing-Daten für Auszifferung von Debitoren                 *
*       Daten stammen auf FEBCL                                       *
*---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form fb05_ftclear_debi.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM fb05_ftclear_debi CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
*   check for entries with XFEBCL-SELFD = 'WRBTR'
*    -> one entry only
*    -> amount for clearing depending on posting area (FWBTR or KWBTR)
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*  perform check_wrbtr_entries using febep-kukey       "INSERT - mpEURO
*                                    febep-esnum.      "INSERT - mpEURO
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
  PERFORM check_wrbtr_entries USING febep-kukey
                                    febep-esnum
                              CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  LOOP AT xfebcl WHERE kukey = febep-kukey
                   AND esnum = febep-esnum.
    PERFORM append_xfebcl_to_ftclear.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    perform druck_buzei_ftclear using ftclear-agkon.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    PERFORM druck_buzei_ftclear USING ftclear-agkon
                                CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  ENDLOOP.

ENDFORM.                    "FB05_FTCLEAR_DEBI


*eject
*---------------------------------------------------------------------*
*       FORM FB05_FTCLEAR_KREDI.                                      *
*---------------------------------------------------------------------*
*       Clearing-Daten für Auszifferung von Kreditoren                *
*       Daten stammen auf FEBCL                                       *
*---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form fb05_ftclear_kredi.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM fb05_ftclear_kredi CHANGING xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
* check for entries with XFEBCL-SELFD = 'WRBTR'
*  -> one entry only
*  -> amount for clearing depending on posting area (FWBTR or KWBTR)
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*  perform check_wrbtr_entries using febep-kukey      "INSERT - mpEURO
*                                    febep-esnum.     "INSERT - mpEURO
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
  PERFORM check_wrbtr_entries USING febep-kukey
                                    febep-esnum
                              CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  LOOP AT xfebcl WHERE kukey = febep-kukey
                   AND esnum = febep-esnum.
    PERFORM append_xfebcl_to_ftclear.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    perform druck_buzei_ftclear using ftclear-agkon.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    PERFORM druck_buzei_ftclear USING ftclear-agkon
                                CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  ENDLOOP.
ENDFORM.                    "FB05_FTCLEAR_KREDI


*eject
*---------------------------------------------------------------------*
*       FORM FB05_FTCLEAR_SAKO.                                       *
*---------------------------------------------------------------------*
*       Ausgeziffert wird auf Sachkonkto                              *
*        SAKNR = IKOFI-SAKN1 -> Auszifferung auf Sollseite            *
*        SAKNR = IKOFI-SAKN2 -> Auszifferung auf Habenseite           *
*---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form fb05_ftclear_sako using saknr.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM fb05_ftclear_sako USING saknr
                       CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  DATA l_feb_only TYPE c.
* for on-account clearing, transfer on-account doc to xfebcl.
* voided                                                   "hw638124
* if ( ( pa_xakon = 'X' ) or ( pa_xakon = 'A' ) )           "45b
*      and ( bereich = '1' ) and                            "45b
*  not febep-ak1bl is initial.                              "45b
*   clear xfebcl.                                           "45b
*   move-corresponding febep to xfebcl.                     "45b
*   ftclear-agkoa  = 'S'.                                   "45b
*   ftclear-agkon  = saknr.                                 "45b
*   xfebcl-selfd   = 'BELNR'.                               "45b
*   xfebcl-selvon  = febep-ak1bl.                           "45b
*   append xfebcl.                                          "45b
* endif.                                                    "45b
  DESCRIBE TABLE xfebcl LINES tfill_xfebcl.

  IF tfill_xfebcl > 0.
    l_feb_only = 'X'.
    LOOP AT xfebcl.
      IF NOT ( xfebcl-selfd = 'FB' AND xfebcl-selvon CS 'FEB_' ).
        CLEAR l_feb_only.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF tfill_xfebcl = 0 OR l_feb_only = 'X'.
*   Keine Einträge in XFEBCL -> Selection nach WRBTR
    CLEAR ftclear.
    IF xfebcl-agbuk IS INITIAL.
      ftclear-agbuk = febko-bukrs.
    ELSE.
      ftclear-agbuk = xfebcl-agbuk.
    ENDIF.
    ftclear-agkoa  = 'S'.
    ftclear-agkon  = saknr.
    ftclear-xnops  = 'X'.
    ftclear-selfd  = 'WRBTR'.
    IF febep-fwbtr IS INITIAL OR bereich = '1'.        "INSERT - mpEURO
*   no original transaction currency provided or posting area = 1.
      ftclear-selvon =  febep-kwbtr.
    ELSE.                              "INSERT - mpEURO
*   original transaction currency provided and posting area = 2.
      ftclear-selvon =  febep-fwbtr.   "INSERT - mpEURO
    ENDIF.                             "INSERT - mpEURO
    CONDENSE ftclear-selvon NO-GAPS.
    APPEND ftclear.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    perform druck_buzei_ftclear using ftclear-agkon.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    PERFORM druck_buzei_ftclear USING ftclear-agkon
                                CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  ENDIF.
  IF tfill_xfebcl > 0.
*   clearing information in FEBCL available.

*   check for entries with XFEBCL-SELFD = 'WRBTR'
*    -> one entry only
*    -> amount for clearing depending on posting area (FWBTR or KWBTR)
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*   perform check_wrbtr_entries using febep-kukey       "INSERT - mpEURO
*                                     febep-esnum.      "INSERT - mpEURO
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    PERFORM check_wrbtr_entries USING febep-kukey
                                      febep-esnum
                                CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
    LOOP AT xfebcl.
      CLEAR ftclear.
*--------- Ausgleichsbuchungskreis setzen ------------------------------
      IF xfebcl-agbuk IS INITIAL.
        ftclear-agbuk = febko-bukrs.
      ELSE.
        ftclear-agbuk = xfebcl-agbuk.
      ENDIF.

*--------- falls keine Sonderhauptbuchkennzeichen -> XNOPS setzen ------
      IF xfebcl-agums IS INITIAL.
        ftclear-xnops = 'X'.
      ELSE.
        ftclear-agums = xfebcl-agums.
      ENDIF.

      IF xfebcl-selfd = 'REFNO'.                           "note 206022
        PERFORM append_refno_docs USING xfebcl-selvon.     "note 206022
      ELSE.                                                "note 206022
*-------- Konto aus Account_Determination, falls nicht angegeben -------
* Es kann sein, daß in IDENTIFY_BUSINESS_PARTNER ein Kreditoren- oder
* ein Debitorenkonto gefunden wurde. Dieses macht hier aber keinen
* Sinn und daher wird in solch einem Fall SAKNR verwendet.
        IF xfebcl-agkon IS INITIAL OR xfebcl-koart NE 'S'.
          ftclear-agkon  = saknr.
        ELSE.
          ftclear-agkon  = xfebcl-agkon.
        ENDIF.
*-------- bei Ausgleich auf Sachkonto AGKOA immer 'S' ------------------
        ftclear-agkoa  = 'S'.
        ftclear-xfifo  = xfebcl-xfifo.
        ftclear-selfd  = xfebcl-selfd.
        ftclear-selvon = xfebcl-selvon.
        ftclear-selbis = xfebcl-selbis.
        APPEND ftclear.
      ENDIF.                                               "note 206022
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*      perform druck_buzei_ftclear using ftclear-agkon.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
      PERFORM druck_buzei_ftclear USING ftclear-agkon
                                  CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
    ENDLOOP.
  ENDIF.
ENDFORM.                    "FB05_FTCLEAR_SAKO

*eject
*---------------------------------------------------------------------*
*       FORM FB05_FTPOST_HABEN.                                       *
*---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form fb05_ftpost_haben.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM fb05_ftpost_haben CHANGING xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************


*  IF ( NOT FEBEP-KOSTL IS INITIAL ) OR ( NOT FEBEP-PRCTR IS INITIAL ).
*    PERFORM CHECK_IF_COST_RELEVANT USING IKOFI-SAKN2 CRC_FLAG.
*  ENDIF.

* Buchungszeile 1
  PERFORM ftpost_field USING 'BSEG-BSCHL' ikofi-bsch2.    "Buchungssch
  PERFORM ftpost_field USING 'BSEG-HKONT' ikofi-sakn2.    "Sachkonto

  PERFORM betraege_to_ftpost.

  IF NOT febep-valut IS INITIAL
  AND valut_on  = 'X'.
    WRITE febep-valut TO fvalue DD/MM/YYYY.
    PERFORM ftpost_field USING 'BSEG-VALUT' fvalue.         "Valutadatum
  ENDIF.

  IF ( bereich = 1 AND febep-epvoz = 'H' AND            "INSERT - mpEURO
       x_apa_def = 'X' AND febep-fwaer NE febep-kwaer ) "INSERT - mpEURO
     OR                                "INSERT - mpEURO
     ( bereich = 2 AND febep-epvoz = 'S' AND            "INSERT - mpEURO
       x_apa_def = 'X' AND febep-fwaer NE febep-kwaer )."INSERT - mpEURO
*    allocation number fixed on interim account
    MOVE const_zuonr TO char_zuonr.    "INSERT - mpEURO
    PERFORM ftpost_field USING 'BSEG-ZUONR' char_zuonr. "INSERT - mpEURO
  ELSE.                                "INSERT - mpEURO
    IF NOT febep-zuonr IS INITIAL.
      PERFORM ftpost_field USING 'BSEG-ZUONR' febep-zuonr.  "Zordnungsnr
    ENDIF.
  ENDIF.                               "INSERT - mpEURO

  PERFORM segmenttext_to_ftpost USING sgtxt.
  IF NOT sgtxt IS INITIAL.
    PERFORM ftpost_field USING 'BSEG-SGTXT' sgtxt.  "Text
  ENDIF.

  IF NOT febep-gsber IS INITIAL.
    PERFORM ftpost_field USING 'COBL-GSBER' febep-gsber.    "Geschäftsbe
  ENDIF.

  IF NOT febep-kostl IS INITIAL.       "AND CRC_FLAG = TRUE.
    PERFORM ftpost_field USING 'COBL-KOSTL' febep-kostl.    "Kostenstell
  ENDIF.

  IF NOT febep-prctr IS INITIAL.       "AND CRC_FLAG = TRUE.
    PERFORM ftpost_field USING 'COBL-PRCTR' febep-prctr.    "ProfitCtr
  ENDIF.

  PERFORM additional_fields USING 'S'. "User fields 1 - 3
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*  perform druck_buzei using ikofi-bsch2 ikofi-sakn2 blank.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
  PERFORM druck_buzei USING ikofi-bsch2 ikofi-sakn2 blank
                      CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  IF febep-fwbtr IS INITIAL OR         "INSERT - mpEURO
     febep-fwaer = febep-kwaer OR      "INSERT - mpEURO
     bereich = 1.                      "INSERT - mpEURO
*    no original transaction currency provided or posting area = 1.
*    Spesen nur in Bankbuchung und/oder Kontenwährung erlaubt

    IF NOT febep-spesk IS INITIAL.
*   Neue Buchungszeile,            HP 4.5A
*   New posting line,              HP 4.5A
      ftpost-count = ftpost-count + 1.
      PERFORM fb05_ftpost_spesen.

      IF NOT febep-gsber IS INITIAL.
        PERFORM ftpost_field USING 'COBL-GSBER' febep-gsber.  "Geschäftsbe
      ENDIF.

      IF NOT febep-kostl IS INITIAL.   "AND CRC_FLAG = TRUE.
        PERFORM ftpost_field USING 'COBL-KOSTL' febep-kostl.  "Kostenstell
      ENDIF.

      IF NOT febep-prctr IS INITIAL.   "AND CRC_FLAG = TRUE.
        PERFORM ftpost_field USING 'COBL-PRCTR' febep-prctr.    "ProfitCtr
      ENDIF.

      PERFORM additional_fields USING 'S'.     "User fields 1 - 3

    ENDIF.
  ENDIF.                               "INSERT - mpEURO

ENDFORM.                    "FB05_FTPOST_HABEN

*eject
*---------------------------------------------------------------------*
*       FORM FB05_FTPOST_SOLL.                                        *
*---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form fb05_ftpost_soll.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM fb05_ftpost_soll CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
*  IF ( NOT FEBEP-KOSTL IS INITIAL ) OR ( NOT FEBEP-PRCTR IS INITIAL ).
*    PERFORM CHECK_IF_COST_RELEVANT USING IKOFI-SAKN1 CRC_FLAG.
*  ENDIF.

* Buchungszeile 1
  PERFORM ftpost_field USING 'BSEG-BSCHL' ikofi-bsch1.    "Buchungssch
  PERFORM ftpost_field USING 'BSEG-HKONT' ikofi-sakn1.    "Sachkonto

  PERFORM betraege_to_ftpost.

  IF NOT febep-valut IS INITIAL
  AND valut_on  = 'X'.
    WRITE febep-valut TO fvalue DD/MM/YYYY.
    PERFORM ftpost_field USING 'BSEG-VALUT' fvalue.         "Valutadatum
  ENDIF.

  IF ( bereich = 1 AND febep-epvoz = 'S' AND            "INSERT - mpEURO
       x_apa_def = 'X' AND febep-fwaer NE febep-kwaer ) "INSERT - mpEURO
     OR                                "INSERT - mpEURO
     ( bereich = 2 AND febep-epvoz = 'H' AND            "INSERT - mpEURO
       x_apa_def = 'X' AND febep-fwaer NE febep-kwaer )."INSERT - mpEURO
*    allocation number fixed on interim account
    MOVE const_zuonr TO char_zuonr.    "INSERT - mpEURO
    PERFORM ftpost_field USING 'BSEG-ZUONR' char_zuonr. "INSERT - mpEURO
  ELSE.                                "INSERT - mpEURO
    IF NOT febep-zuonr IS INITIAL.
      PERFORM ftpost_field USING 'BSEG-ZUONR' febep-zuonr.  "Zordnungsnr
    ENDIF.
  ENDIF.                               "INSERT - mpEURO

*  if not febep-zuonr is initial.                       "DELETE - mpEURO
*   if febko-anwnd = '0003'.           "For Lockbox
*     tmp_zuonr = febep-zuonr.         "Allocation Text on Bank Entry
*     clear febep-zuonr.               "for S/L posting
*     febep-zuonr+0(8) = febko-azidt.
*     febep-zuonr+9(3) = febep-batch.
*     febep-zuonr+13(5) = febep-esnum.
*     perform ftpost_field using 'BSEG-ZUONR' febep-zuonr.  "Zordnungsnr
*     clear febep-zuonr.
*     febep-zuonr = tmp_zuonr.
*   else.
*    perform ftpost_field using 'BSEG-ZUONR' febep-zuonr"DELETE - mpEURO
*   endif.
*  endif.                                               "DELETE - mpEURO

  PERFORM segmenttext_to_ftpost USING sgtxt.
  IF NOT sgtxt IS INITIAL.
    PERFORM ftpost_field USING 'BSEG-SGTXT' sgtxt.  "Text
  ENDIF.

  IF NOT febep-gsber IS INITIAL.
    PERFORM ftpost_field USING 'COBL-GSBER' febep-gsber.    "Geschäftsbe
  ENDIF.

  IF NOT febep-kostl IS INITIAL.       " AND CRC_FLAG = TRUE.
    PERFORM ftpost_field USING 'COBL-KOSTL' febep-kostl.    "Kostenstell
  ENDIF.

  IF NOT febep-prctr IS INITIAL.       " AND CRC_FLAG = TRUE.
    PERFORM ftpost_field USING 'COBL-PRCTR' febep-prctr.    "ProfitCtr
  ENDIF.

  PERFORM additional_fields USING 'S'. "User fields 1 - 3
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*  perform druck_buzei using ikofi-bsch1 ikofi-sakn1 blank.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
  PERFORM druck_buzei USING ikofi-bsch1 ikofi-sakn1 blank
                      CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  IF febep-fwbtr IS INITIAL OR         "INSERT - mpEURO
     febep-fwaer = febep-kwaer OR      "INSERT - mpEURO
     bereich = 1.                      "INSERT - mpEURO
*    no original transaction currency provided or posting area = 1.
*    Spesen nur in Bankbuchung und/oder Kontenwährung erlaubt

    IF NOT febep-spesk IS INITIAL.     "Bankspesen
*    Neue Buchungszeile,            M. Depner, 270597, 4.0A
*    New posting line,              M. Depner, 270597, 4.0A
      ftpost-count = ftpost-count + 1.
      PERFORM fb05_ftpost_spesen.

      IF NOT febep-gsber IS INITIAL.
        PERFORM ftpost_field USING 'COBL-GSBER' febep-gsber.  "Geschäftsbe
      ENDIF.

      IF NOT febep-kostl IS INITIAL.   " AND CRC_FLAG = TRUE.
        PERFORM ftpost_field USING 'COBL-KOSTL' febep-kostl.  "Kostenstell
      ENDIF.

      IF NOT febep-prctr IS INITIAL.   " AND CRC_FLAG = TRUE.
        PERFORM ftpost_field USING 'COBL-PRCTR' febep-prctr.    "ProfitCtr
      ENDIF.

      PERFORM additional_fields USING 'S'.     "User fields 1 - 3

    ENDIF.

  ENDIF.                               "INSERT - mpEURO

  IF febep-fwbtr IS INITIAL OR         "INSERT - mpEURO
     febep-fwaer = febep-kwaer OR      "INSERT - mpEURO
     bereich = 1.                      "INSERT - mpEURO
*    no original transaction currency provided or posting area = 1.
*    Zinsen/gebühren nur in Bankbuchung und/oder Kontenwährung erlaubt

* Überfälligkeitszinsen/-gebühren, M. Depner, 270597, 4.0A
* Interest/Penalty on arrears,     M. Depner, 270597, 4.0A
    IF NOT febep-arrsk IS INITIAL.
      ftpost-count = ftpost-count + 1.
      PERFORM fb05_ftpost_interest_haben.

      IF NOT febep-gsber IS INITIAL.
        PERFORM ftpost_field USING 'COBL-GSBER' febep-gsber.  "Geschäftsbe
      ENDIF.

      IF NOT febep-kostl IS INITIAL.   " AND CRC_FLAG = TRUE.
        PERFORM ftpost_field USING 'COBL-KOSTL' febep-kostl.  "Kostenstell
      ENDIF.

      IF NOT febep-prctr IS INITIAL.   " AND CRC_FLAG = TRUE.
        PERFORM ftpost_field USING 'COBL-PRCTR' febep-prctr.    "ProfitCtr
      ENDIF.

      PERFORM additional_fields USING 'S'.     "User fields 1 - 3

    ENDIF.
  ENDIF.                               "INSERT - mpEURO

ENDFORM.                    "FB05_FTPOST_SOLL

*---------------------------------------------------------------------*
*       FORM FB05_FTPOST_SPESEN.
*---------------------------------------------------------------------*
FORM fb05_ftpost_spesen.
* Spesenkonto aus T030 besorgen.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM t030 WHERE ktopl = febko-ktopl
*                       AND ktosl = 'BSP'.
*
* NEW CODE
  SELECT *
 FROM t030 WHERE ktopl = febko-ktopl
                       AND ktosl = 'BSP' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE i785 WITH febko-ktopl 'BSP'.
  ENDIF.

*  IF ( NOT FEBEP-KOSTL IS INITIAL ) OR ( NOT FEBEP-PRCTR IS INITIAL ).
*    PERFORM CHECK_IF_COST_RELEVANT USING T030-KONTS CRC_FLAG.
*  ENDIF.

  PERFORM ftpost_field USING 'BSEG-BSCHL' '40'.           "Buchungssch
  PERFORM ftpost_field USING 'BSEG-HKONT' t030-konts.     "Spesenkonto

* expenses only considered for posting area                "ok - mpEURO
* or no transaction currency provided                      "ok - mpEURO
  WRITE febep-spesk TO fvalue CURRENCY febep-kwaer.        "ok - mpEURO
  CONDENSE fvalue.
  PERFORM ftpost_field USING 'BSEG-WRBTR' fvalue.       "BetrBelegWähr
*   WRBTR = FVALUE.

ENDFORM.                    "FB05_FTPOST_SPESEN


*eject
*---------------------------------------------------------------------*
*       FORM FB05_POSTING.                                            *
*---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form fb05_posting.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM fb05_posting CHANGING xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  CLEAR auglv.
  IF ( ( NOT febep-ak1bl IS INITIAL                         "hw638124
       AND febep-belnr IS INITIAL )                         "hw638124
    OR ( NOT febep-akbln IS INITIAL                         "hw638124
         AND febep-nbbln IS INITIAL ) )                     "hw638124
    AND febep-avsid IS INITIAL.                             "hw638124
    IF NOT febep-avkon IS INITIAL                           "hw638124
       AND ( ( febep-epvoz = 'H' AND                        "hw638124
               NOT ikofi-sakn2 IS INITIAL AND               "hw638124
               ikofi-sakn2 <> febep-avkon )                 "hw638124
          OR ( febep-epvoz = 'S' AND                        "hw638124
               NOT ikofi-sakn1 IS INITIAL AND               "hw638124
               ikofi-sakn1 <> febep-avkon ) ).              "hw638124
      g_clear_on_account = 'P'.                             "hw638124
* post and clear                                           "hw638124
    ELSE.                                                   "hw638124
      g_clear_on_account = 'C'.                             "hw638124
* clear only                                               "hw638124
    ENDIF.                                                  "hw638124
  ENDIF.                                                    "hw638124
  IF NOT febep-epvoz IS INITIAL.
    IF febep-epvoz = 'H'.
      auglv = 'EINGZAHL'.
    ELSE.
      auglv = 'AUSGZAHL'.
    ENDIF.
  ELSE.
    CASE febep-vozei.
      WHEN 'C'.
        auglv = 'EINGZAHL'.
      WHEN 'D'.
        auglv = 'AUSGZAHL'.
      WHEN 'RC'.
        auglv = 'AUSGZAHL'.
      WHEN 'RD'.
        auglv = 'EINGZAHL'.
    ENDCASE.
  ENDIF.
  IF febep-avsid = space.              "<<
    PERFORM belegkopf USING 'X'.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    perform fb05_belegsegment.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    PERFORM fb05_belegsegment CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
    x_error_handling = space.          "On Account status flag
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    perform fb05_posting_aufrufen using 'X'.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    PERFORM fb05_posting_aufrufen USING 'X'
                                  CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  ELSE.
    IF febep-vb2ba = 'S'.
      LOOP AT xfebcl WHERE kukey = febep-kukey AND        "<<< HP
                           esnum = febep-esnum AND        "<<< HP
                           selfd = 'AVSID'     AND        "<<< HP
                           selbis(10) = space.            "<<< HP
        r_csnum = xfebcl-csnum.        "<<< HP
        PERFORM belegkopf USING 'X'.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*        perform fb05_belegsegment.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
        PERFORM fb05_belegsegment CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
        x_error_handling = space.      "On Account status flag
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*        perform fb05_posting_aufrufen using ' '.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
        PERFORM fb05_posting_aufrufen USING ' '
                                      CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
      ENDLOOP.
    ELSE.
      CLEAR r_csnum.
      PERFORM belegkopf USING 'X'.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*      perform fb05_belegsegment.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
      PERFORM fb05_belegsegment CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
      x_error_handling = space.        "On Account status flag
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*      perform fb05_posting_aufrufen using 'X'.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
      PERFORM fb05_posting_aufrufen USING 'X'
                                    CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
    ENDIF.
  ENDIF.

ENDFORM.                    "FB05_POSTING

*eject
*--------------------------------------------------------------------*
*  FORM FB05_POSTING_AUFRUFEN.                                       *
*--------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form fb05_posting_aufrufen using xinit.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM fb05_posting_aufrufen USING xinit
                           CHANGING xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  IF open = false.
    PERFORM posting_interface_start.
  ENDIF.

* worklist                                                     "fk020801
  PERFORM worklist_to_ftclear.

* no automatical clearing                                      "fk020801
  PERFORM check_noclear.

* Aufruf eines externen Funktionsbausteins, falls notwendig
  PERFORM check_call_external_function.
* BREAK HAFNER.

  PERFORM ftpost_fieldselect TABLES ftpost
                             USING  febep
                                    febko.

  DATA: b-lines TYPE p.                "loans

  IF testl NE 'X'.

    DESCRIBE TABLE ftpost LINES b-lines.                    "loans
    IF b-lines > 0.                    "loans
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*      perform posting_interface_clearing.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
      PERFORM posting_interface_clearing CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
    ELSE.                              "loans
      sy-subrc = 0.                    "loans
    ENDIF.                             "loans

  ELSE.
*   bei Testlauf erfolgreiche Verbuchung simulieren
    subrc = 0.
  ENDIF.

  IF subrc = 0.
    IF (  x_error_handling = 'X'  ).                        "45b
      statist-akont = statist-akont + 1.                    "45b
    ELSE.                                                   "45b
      statist-fb05 = statist-fb05 + 1.
    ENDIF.
  ELSE.
    IF x_error_handling NE 'X'.        "FB05 for on-account
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*      perform fb05_error_handling.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
      PERFORM fb05_error_handling CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
    ELSE.                                                   "45b
      statist-error = statist-error + 1.                    "45b
    ENDIF.
  ENDIF.

* Initialisierungen nach Aufruf der Verbuchung
  IF xinit = 'X'.
    bkpf_komk_ok   = false.
    bseg_komk_s_ok = false.
    bseg_komk_h_ok = false.
    CLEAR ikofi.
    CLEAR komk.                        "Compression
    REFRESH: vbkep.                                         "45A
    CLEAR:   vbkep.                                         "45A
  ENDIF.
  REFRESH: ftpost, ftclear.
  CLEAR:   ftpost, ftclear.
  REFRESH: xblntab.
  CLEAR:   xblntab.
ENDFORM.                    "FB05_POSTING_AUFRUFEN

*eject
*----------------------------------------------------------
*  Buchungsschnittstelle: Feld hinzufügen
*----------------------------------------------------------
FORM ftpost_field  USING fnam fval.

  CLEAR: ftpost-fnam, ftpost-fval.
  ftpost-fnam     = fnam.
  ftpost-fval     = fval.
  APPEND ftpost.

ENDFORM.                    "FTPOST_FIELD


*--------------------------------------------------------------------*
*  Feld hinzufügen für komprimierte Haben Zeile                      *
*--------------------------------------------------------------------*
FORM ft_komk_h_field  USING fnam fval.

  CLEAR: ft_komk_h-fnam, ft_komk_h-fval.
  ft_komk_h-fnam  = fnam.
  ft_komk_h-fval  = fval.
  APPEND ft_komk_h.

ENDFORM.                    "FT_KOMK_H_FIELD


*--------------------------------------------------------------------*
*  Feld hinzufügen für komprimierte Soll  Zeile                      *
*--------------------------------------------------------------------*
FORM ft_komk_s_field  USING fnam fval.

  CLEAR: ft_komk_s-fnam, ft_komk_s-fval.
  ft_komk_s-fnam  = fnam.
  ft_komk_s-fval  = fval.
  APPEND ft_komk_s.

ENDFORM.                    "FT_KOMK_S_FIELD

*eject
*---------------------------------------------------------------------*
*       FORM FBRA_POSTING.
*---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form fbra_posting.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM fbra_posting CHANGING xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  LOOP AT xfebcl WHERE selfd = 'AUGBL'
                    OR selfd = 'BELNR'.

    augbl = xfebcl-selvon.
    belns = xfebcl-selvon.

    SELECT * FROM bkpf                 "Depner, 270597
      WHERE bukrs = febko-bukrs        "Depner, 270597
      AND   belnr = xfebcl-selvon      "Depner, 270597
      ORDER BY PRIMARY KEY.            "last clearing document
    ENDSELECT.                         "Depner, 270597

    EXIT.
  ENDLOOP.

  IF sy-subrc = 0 OR mode = 'A' OR mode = 'E'.                 "n1321162
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    perform fbra_posting_aufrufen.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    PERFORM fbra_posting_aufrufen CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  ELSE.
    CLEAR vb_error.
    vb_error-anwnd = febko-anwnd.
    vb_error-absnd = febko-absnd.
    vb_error-azidt = febko-azidt.
    vb_error-ktonr = febko-ktonr.
    vb_error-aznum = febko-aznum.
    vb_error-esnum = febep-esnum.
    vb_error-buber = bereich.
    vb_error-zeile = text-034.
    APPEND vb_error.
    statist-error = statist-error + 1.
  ENDIF.

ENDFORM.                    "FBRA_POSTING

*eject
*---------------------------------------------------------------------*
*       FORM FBRA_POSTING_AUFRUFEN.
*---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form fbra_posting_aufrufen.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM fbra_posting_aufrufen CHANGING xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  CLEAR: subrc, msgid, msgty, msgno, msgv1, msgv2, msgv3, msgv4."45B

  IF open = false.
    PERFORM posting_interface_start.
  ENDIF.

  IF testl NE 'X'.
    IF function = 'B'                 "batch input, Depner 270597
      OR mode = 'A' OR mode = 'E'.                             "n1321162

*--------------------------- start of note 313962 ---------------------
* For batch input, check if there is withholding tax in
* the original document. If so, disallow the posting
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM bseg
*         WHERE bukrs = febko-bukrs                          "hw313962
*         AND belnr = bkpf-belnr                             "hw313962
*         AND gjahr = bkpf-gjahr                             "hw313962
*         AND qsshb <> 0.                                    
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM bseg
         WHERE bukrs = febko-bukrs                          "hw313962
         AND belnr = bkpf-belnr                             "hw313962
         AND gjahr = bkpf-gjahr                             "hw313962
         AND qsshb <> 0 ORDER BY PRIMARY KEY.                                    

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01"hw313962
      IF sy-subrc = 0.                                      "hw313962
        CLEAR vb_error.                                     "hw313962
        vb_error-anwnd = febko-anwnd.                       "hw313962
        vb_error-absnd = febko-absnd.                       "hw313962
        vb_error-azidt = febko-azidt.                       "hw313962
        vb_error-ktonr = febko-ktonr.                       "hw313962
        vb_error-aznum = febko-aznum.                       "hw313962
        vb_error-esnum = febep-esnum.                       "hw313962
        vb_error-buber = bereich.                           "hw313962
        vb_error-zeile = text-090.                          "hw313962
        APPEND vb_error.                                    "hw313962
        statist-error = statist-error + 1.                  "hw313962
        EXIT.                                               "hw313962
      ENDIF.                                                "hw313962
*----------------------------end of note 313962-----------------------

      tcode = 'FBRA'.
      CALL FUNCTION 'POSTING_INTERFACE_RESET_CLEAR'
        EXPORTING
          i_tcode                  = tcode
          i_augbl                  = augbl
          i_bukrs                  = febko-bukrs
          i_gjahr                  = bkpf-gjahr
        IMPORTING
          e_subrc                  = subrc
          e_msgid                  = msgid
          e_msgty                  = msgty
          e_msgno                  = msgno
          e_msgv1                  = msgv1
          e_msgv2                  = msgv2
          e_msgv3                  = msgv3
          e_msgv4                  = msgv4
        EXCEPTIONS
          transaction_code_invalid = 1.
      IF sy-subrc NE 0.
        MESSAGE e776 WITH tcode.
      ENDIF.
      IF subrc = '0'.
*       Protokollzeile drucken und weitermachen mit Storno
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*        perform druck_fbra_zeile.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
        PERFORM druck_fbra_zeile CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
        tcode = 'FB08'.
        CALL FUNCTION 'POSTING_INTERFACE_REVERSE_DOC'
          EXPORTING
            i_tcode                  = tcode
            i_belns                  = belns
            i_bukrs                  = febko-bukrs
            i_stgrd                  = ikofi-stgrd
          IMPORTING
            e_subrc                  = subrc
            e_msgid                  = msgid
            e_msgty                  = msgty
            e_msgno                  = msgno
            e_msgv1                  = msgv1
            e_msgv2                  = msgv2
            e_msgv3                  = msgv3
            e_msgv4                  = msgv4
          TABLES
            t_blntab                 = xblntab
          EXCEPTIONS
            transaction_code_invalid = 1.
        IF sy-subrc NE 0.
          MESSAGE e776 WITH tcode.
        ENDIF.
        IF subrc = '0'.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*          perform druck_fb08_zeile.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
          PERFORM druck_fb08_zeile CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
*         VB_BELNR  = XBLNTAB-BELNR.
*         VB_OK     = 'X'.
          statist-fb01  = statist-fb01  + 1.
          PERFORM update_febep_status.
        ELSE.
          MESSAGE ID msgid  TYPE msgty  NUMBER msgno
                     WITH msgv1 msgv2 msgv3 msgv4.
          statist-error = statist-error + 1.
        ENDIF.
      ELSE.
        MESSAGE ID msgid  TYPE msgty  NUMBER msgno
                   WITH msgv1 msgv2 msgv3 msgv4.
        statist-error = statist-error + 1.
      ENDIF.
    ELSE.                              "call transaction
      IF xtrwpr = 'X' AND function = 'C'.                   "hw426052
        EXPORT bereich                                      "hw426052
               febep-kukey                                  "hw426052
               febep-esnum                                  "hw426052
               komk                                         "hw426052
               xakon                                        "hw426052
               r_csnum                                      "hw426052
               vbkep                                        "hw426052
               xfebcl                                       "hw426052
               TO MEMORY ID 'FEBA_POST'.                    "hw426052
      ENDIF.                                                "hw426052
      CALL FUNCTION 'J_1B_FBRA_POSTING_AUFRUFEN'
        EXPORTING
          i_augbl           = bkpf-belnr
          i_bukrs           = bkpf-bukrs
          i_gjahr           = bkpf-gjahr
          i_stgrd           = ikofi-stgrd
        EXCEPTIONS
          not_possible_fbra = 1
          not_possible_fb08 = 2.

      subrc = sy-subrc.                                          "n972881
      IF xtrwpr = 'X' AND function = 'C'.                        "n972881
        FREE MEMORY ID 'FEBA_POST'.                              "n972881
      ENDIF.                                                     "n972881

      IF subrc <> 0.                                             "n972881
        IF p_bupro = 'X'.
          IF subrc = 1.                                          "n972881
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*            perform druck_fbra_zeile.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
            PERFORM druck_fbra_zeile CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
          ELSEIF subrc = 2.                                      "n972881
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*            perform druck_fb08_zeile.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
            PERFORM druck_fb08_zeile CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
          ENDIF.
          msgid = sy-msgid.
          msgno = sy-msgno.
          msgv1 = sy-msgv1.
          msgv2 = sy-msgv2.
          msgv3 = sy-msgv3.
          msgv4 = sy-msgv4.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*          perform druck_message.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
          PERFORM druck_message CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
        ENDIF.
        statist-error = statist-error + 1.
      ELSE.
        msgid = sy-msgid.                                   "45B
        msgno = sy-msgno.                                   "45B
        msgv1 = sy-msgv1.                                   "45B
        msgv2 = sy-msgv2.                                   "45B
        msgv3 = sy-msgv3.                                   "45B
        msgv4 = sy-msgv4.                                   "45B
        IF p_bupro = 'X'.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*          perform druck_fbra_zeile.
*          perform druck_fb08_zeile.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
          PERFORM druck_fbra_zeile CHANGING xt_fb01.
          PERFORM druck_fb08_zeile CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
          statist-fb01  = statist-fb01  + 1.
        ENDIF.                                              "45B
        PERFORM update_febep_status.
*       ENDIF.                                                    "45B
      ENDIF.
    ENDIF.
  ELSE.
*   beim Testlauf erfolgreiche Buchung simulieren
    sy-subrc = 0.
  ENDIF.
* Initialisation - new with 4.6A
  bkpf_komk_ok   = false.
  bseg_komk_s_ok = false.
  bseg_komk_h_ok = false.
  CLEAR ikofi.
  CLEAR komk.
  REFRESH: vbkep.
  CLEAR:   vbkep.
  REFRESH: ftpost, ftclear.
  CLEAR:   ftpost, ftclear.
  REFRESH: xblntab.
  CLEAR:   xblntab.
ENDFORM.                    "FBRA_POSTING_AUFRUFEN


*eject
*---------------------------------------------------------------------*
*       FORM GENERATE_NEW_MAPPENNAME.
*---------------------------------------------------------------------*
FORM generate_new_mappenname.
  DATA:  mappenname(15) TYPE c.

* Fall a): Mappennamen werden als Parameter übergeben
  IF ( bereich = '1' AND bnkgroup NE space )
  OR ( bereich = '2' AND nebgroup NE  space ).
*   teilweise Generierung des Mappennamens
    IF bereich = '1'.
      mappenname+3 = bnkgroup.
    ELSE.
      mappenname = nebgroup.
      IF NOT febep-grpnr IS INITIAL.
        mappenname+0(2)  = febep-grpnr.
        mappenname+2(1)  = '-'.
      ENDIF.
    ENDIF.
    CONDENSE mappenname NO-GAPS.
    mappe = mappenname.

*   Mappenname ist gebildet, GENERATE_NEW_MAPPENNAME verlassen
    EXIT.
  ENDIF.

* Fall b): Mappennamen werden nicht übergeben
  IF ( bereich = '1' AND febko-grp01 = space )
  OR ( bereich = '2' AND febko-grp02 = space ).
*   vollständige Generierung des Mappennamens
*     alles ok. Mappenname bilden
    CASE mregel.
      WHEN '1'.
*         Mappenname bilden aus HBKID, HKTID, GRPNR
        IF bereich = '2'.
          mappenname+0(1)  = '/'.
        ENDIF.
        mappenname+1(2)  = febep-grpnr.
        mappenname+3(5)  = febko-hbkid.
        mappenname+8(1)  = '-'.
        mappenname+9(5)  = febko-hktid.

      WHEN '2'.
*         Mappenname bilden aus HBKID, AZNUM, GRPNR
        IF bereich = '2'.
          mappenname+0(1)  = '/'.
        ENDIF.
        mappenname+1(2)  = febep-grpnr.
        mappenname+3(5)  = febko-hbkid.
        mappenname+8(1)  = '-'.
        mappenname+9(3)  = febko-aznum+2(3).

      WHEN '3'.
*       Bildung aus grpnr, BUKRS, HBKID, AZNUM,
        IF bereich = '2'.
          mappenname+0(1)  = '/'.
        ENDIF.
        IF febep-grpnr IS INITIAL.
          mappenname+1(4)  = febko-bukrs.
          mappenname+5(4)  = febko-hbkid+0(4).
          mappenname+9(3)  = febko-aznum+2(3).
        ELSE.
          mappenname+1(2)  = febep-grpnr.
          mappenname+3(4)  = febko-bukrs.                   "QHA960307
          mappenname+7(3)  = febko-hbkid+0(3).              "QHA960307
          mappenname+10(2) = febko-aznum+3(2).              "QHA960307
*           MAPPENNAME+2(4)  = FEBKO-BUKRS.        "QHA960307
*           MAPPENNAME+3(3)  = FEBKO-HBKID+0(3).   "QHA960307
*           MAPPENNAME+9(3)  = FEBKO-AZNUM+3(2).   "QHA960307
        ENDIF.
      WHEN '4'.
*         Mappenname bilden aus 5-byte GRPNR, HBKID, und AZDAT(4)
        IF bereich = '2'.
          mappenname+0(1)  = '/'.
        ENDIF.
        mappenname+1(2)  = febep-grpnr.
        mappenname+3(5)  = febko-hbkid.
        mappenname+8(4)  = febko-azdat+4.
      WHEN '9'.
*         Mappenname bilden aus 3-byte HBKID, 2-byte HKTID,
*                               3-byte AZNUM, 2-byte GRPNR.
        IF bereich = '1'.
          mappenname+0(3)  = febko-hbkid.
          mappenname+3(1)  = '-'.
          mappenname+4(2)  = febko-hktid.
          mappenname+6(3)  = febko-aznum+2(3).
          mappenname+9(1)  = '-'.
          mappenname+10(2) = febep-grpnr.
        ELSEIF bereich = '2'.
          mappenname+0(1)  = '/'.
          mappenname+1(3)  = febko-hbkid.
          mappenname+4(2)  = febko-hktid.
          mappenname+6(3)  = febko-aznum+2(3).
          mappenname+9(1)  = '-'.
          mappenname+10(2) = febep-grpnr.
        ENDIF.
    ENDCASE.

    CONDENSE mappenname NO-GAPS.
    mappe = mappenname.
*   Mappenname ist gebildet, GENERATE_NEW_MAPPENNAME verlassen
    EXIT.
  ENDIF.

* Fall c): Mappennamen werden über FEBKO übergeben
*   teilweise Generierung des Mappennamens für Nebenbuchhaltung
  IF bereich = '1'.
    mappenname = febko-grp01.
  ELSE.
    mappenname+3 = febko-grp02.
    IF NOT febep-grpnr IS INITIAL.
      mappenname+0(2)  = febep-grpnr.
      mappenname+2(1)  = '-'.
    ENDIF.
  ENDIF.
  CONDENSE mappenname NO-GAPS.
  mappe = mappenname.
ENDFORM.                    "GENERATE_NEW_MAPPENNAME

*eject
*---------------------------------------------------------------------*
*       FORM INITIALISIERUNG.
*---------------------------------------------------------------------*
FORM initialisierung.
  DESCRIBE TABLE s_kukey LINES tfill_skukey.
* IF TFILL_SKUKEY = 0.
*   S_KUKEY-SIGN   = 'I'.
*   S_KUKEY-OPTION = 'BT'.
*   S_KUKEY-LOW    = 0.
*   S_KUKEY-HIGH   = 99999999.
*   APPEND S_KUKEY.
* ENDIF.

  DESCRIBE TABLE s_esnum LINES tfill_sesnum.
  IF tfill_sesnum > 0.
    IF tfill_skukey = 1.
      LOOP AT s_kukey. ENDLOOP.
      IF s_kukey-sign   NE 'I'
      OR s_kukey-option NE 'EQ'.
        MESSAGE e603(fv).
      ENDIF.
    ELSE.
      MESSAGE e603(fv).
    ENDIF.
  ENDIF.

ENDFORM.                    "INITIALISIERUNG


*eject
*---------------------------------------------------------------------*
*       FORM LOOP_EXTRACT.
*---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form loop_extract.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM loop_extract CHANGING xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  DATA: exit TYPE c.                   "mp - 131981
* Extract abarbeiten
  LOOP.

    AT NEW febko-kukey.
*     Protokoll neue Seite Überschrift
      printflag = 'P'.
      NEW-PAGE.
*     Flag, ob Dispo-Avise archiviert wurden auf False setzen
      fdis_arch = false.
      current_bukrs = febko-bukrs.     "INSERT - mpEURO
      current_anwnd = febko-anwnd.     "INSERT - mpEURO
      current_efart = febko-efart.     "INSERT - mpEURO

*-- read company-code data for each new statement - mainly for printing
*-- G/L account text
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM t001 WHERE bukrs = febko-bukrs.  
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM t001 WHERE bukrs = febko-bukrs ORDER BY PRIMARY KEY.  

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01"ak090899
      IF sy-subrc NE 0.                                     "ak090899
        MESSAGE e750 WITH 'T001' febko-bukrs.               "ak090899
      ENDIF.                                                "ak090899
*-- re-read chart of accounts in case it's not yet filled by the
*-- format when reading-in the file
      febko-ktopl = t001-ktopl.                             "ak090899

* get worklist + flag noclear from customizing                "fk020801
      CLEAR: worklist, worklist_items[], noclear.
      PERFORM get_worklist_and_noclear
                             USING febko
                             CHANGING worklist
                                      worklist_items
                                      noclear.
    ENDAT.

    AT NEW febep-grpnr.
*     CHECK NOT FEBEP-ESNUM = 0.
*     CHECK     FEBCL-CSNUM = 0.

*     neue Seite für Protokoll
      NEW-PAGE.

*    falls Mappe offen ist -> schließen und Statistik der Mappe merken
      IF open = true.
*     IF OPEN = TRUE AND BEREICH = '2'.
        PERFORM posting_interface_end.
      ENDIF.
*     Statistik alte Zeile beenden und in interner Tabelle sichern
      PERFORM append_statist.

*     Neuer Mappenname generieren, geöffnet wird nur wenn gebucht wird
      PERFORM generate_new_mappenname.

*     Statistik Neue Zeile anfangen
      statist-buber = bereich.
      statist-anwnd = febko-anwnd.
      statist-absnd = febko-absnd.
      statist-azidt = febko-azidt.
      statist-kukey = febko-kukey.
      statist-ktonr = febko-ktonr.
      statist-group = mappe.
      statist-grpnr = febep-grpnr.
      statist-aznum = febko-aznum.
      statist-waers = febko-waers.
    ENDAT.

    AT NEW febep-batch.                                     "46a
*     Komprimierung erfolgt auf batch                         "46a
      IF  febep-esnum NE 0                                  "46a
      AND febcl-csnum = 0.                                  "46a
        PERFORM check_if_komprimierung.                     "46a
      ENDIF.                                                "46a
    ENDAT.                                                  "46a

    AT NEW febep-valut.
      IF ( bereich = 1 AND febep-b1std <> 'X' ) OR          "FI
         ( bereich = 2 AND febep-b2std <> 'X' ).
*     Einzelposten mit identischen KUKEY, GRPNR, FWAER, VGINT, BVDAT,
*     VALUT werden komprimiert, falls VGINT entsprechend gecustomized.
        IF  febep-esnum NE 0
        AND febcl-csnum = 0.
          PERFORM check_if_komprimierung.
        ENDIF.
      ENDIF.
    ENDAT.

*   Neuer Einzelposten
    IF febep-esnum NE 0 AND febcl-csnum = 0.
      REFRESH xfebcl.
      CLEAR   xfebcl.
      ex_funct = false.
      IF febep-epvoz = 'H'
      OR febep-vozei = 'C'
      OR febep-vozei = 'RD'.
*       Buchhaltungssicht
        statist-sumso = statist-sumso + febep-kwbtr.
      ELSE.
        statist-sumha = statist-sumha + febep-kwbtr.
      ENDIF.
*     for automatic clearing on interim account
      const_zuonr-kukey = febep-kukey. "INSERT - mpEURO
      const_zuonr-esnum = febep-esnum. "INSERT - mpEURO
      const_zuonr-kwaer = febep-kwaer. "INSERT - mpEURO
    ENDIF.


*   alle Clearingsätze in XFEBCL speichern
    IF febcl-csnum NE 0.
      xfebcl = febcl.
      APPEND xfebcl.
    ENDIF.


*   Ende des Einzelpostens
    AT END OF febep-esnum.
      IF febep-esnum NE 0.
*------- Application posting  ----------------------------------------
        clear g_open_fi_item_header.                       "hw818056
        PERFORM open_fi_posting USING testl
                                CHANGING xt_fb01.
*------- FI posting --------------------------------------------------
        IF ( bereich = 1 AND febep-b1std <> 'X' ) OR        "FI
           ( bereich = 2 AND febep-b2std <> 'X' ).
*------- Einzelposten verbuchen        --------------------------------

          exit = false.                "mp - 131981
          IF bereich = '1'.
*           CHECK FEBEP-VB1OK = SPACE.                     "mp - 131981
            IF febep-vb1ok NE space.   "mp - 131981
              statist-notpo = statist-notpo + 1.          "mp - 131981
              exit = true.             "mp - 131981
            ENDIF.                     "mp - 131981
          ELSEIF bereich = '2'.
*           CHECK FEBEP-VB2OK = SPACE.                     "mp - 131981
            IF febep-vb2ok NE space.   "mp - 131981
              statist-notpo = statist-notpo + 1.          "mp - 131981
              exit = true.             "mp - 131981
            ENDIF.                     "mp - 131981
          ENDIF.
          IF exit = false.             "mo - 314943
*--------Process Returns                                       FK051201
            PERFORM process_returns TABLES xfebcl
                                      USING febko
                                            bereich
                                            mode
                                   CHANGING febep
                                            exit
                                            xt_fb01.
            IF exit = false.
              PERFORM buchungsstoff_beschaffen.

*       Brazil, FB02, Depner 10.07.97 ----------------------------------
              CALL FUNCTION 'J_1BSA_COMPONENT_ACTIVE'
                EXPORTING
                  bukrs                = febko-bukrs
                  component            = 'BR'
                EXCEPTIONS
                  component_not_active = 01.
              IF sy-subrc = 0.
                IF bereich = '2'.        "Only subledger
                  IF febep-pform = '11'.
                    IF open = false.
                      PERFORM posting_interface_start.
                    ENDIF.
                    PERFORM fb02_changing CHANGING xt_fb01.
                  ENDIF.
                ENDIF.
              ENDIF.
*        End Brazil ----------------------------------------------------

              IF buchen = true.
*-------- fill header data for posting log (ALV conversion)
                PERFORM header_data CHANGING gt_header.              "n853370
*------- FEBRE nachlesen und iin XFEBRE füllen ------------------------
                PERFORM fill_xfebre.                          "
*------- Finanzdispo Avise archivieren?? ------------------------------
                PERFORM check_dispo_avise_archivieren.
*  ------- Aufruf der Verbuchung in Abhängigkeit von der Buchungsart
                CASE ikofi-attr2.
                  WHEN '1'.
                    tcode = 'FB01'.
                    PERFORM fb01_posting CHANGING xt_fb01.
                  WHEN '2'.
                    tcode = 'FB01'.
                    PERFORM fb01_posting CHANGING xt_fb01.
                  WHEN '3'.
                    tcode = 'FB01'.
                    PERFORM fb01_posting CHANGING xt_fb01.
                  WHEN '4'.
                    tcode = 'FB05'.
                    PERFORM fb05_posting CHANGING xt_fb01.
                  WHEN '5'.
                    tcode = 'FB05'.
                    PERFORM fb05_posting CHANGING xt_fb01.
                  WHEN '7'.
                    tcode = 'FB05'.
                    PERFORM fb05_posting CHANGING xt_fb01.
                  WHEN '8'.
                    tcode = 'FB05'.
                    PERFORM fb05_posting CHANGING xt_fb01.
                  WHEN '9'.
                    PERFORM fbra_posting CHANGING xt_fb01.
                ENDCASE.
              ENDIF.

*         commit work aktivieren, falls zeitüberschreitungen vorkommen
*         COMMIT WORK.
            ENDIF.
          ENDIF.
        ENDIF.                         "mo - 314943
      ENDIF.
    ENDAT.

*   Ende Komprimierung
    AT END OF febep-valut.                                  "46a
      IF febko-anwnd <> '0003'.                             "hw596087
* no compression for value date in the lockbox case        "hw596087
        IF febep-esnum GT 0            "INSERT -mpEURO
              AND exit = false         "correct note 314943
              AND komk = 'X'.          "INSERT -mpEURO
*     if febep-esnum gt 0                           "delete -mpEURO
*     and (    ikofi-komk1 ne space       "delete -mpEURO note 574997
*           or ikofi-komk2 ne space ) .   "delete -mpEURO note 574997
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*          perform abschluss_komprimierung.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
          PERFORM abschluss_komprimierung CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*          perform fb01_posting_aufrufen.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
          PERFORM fb01_posting_aufrufen CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
        ENDIF.
      ENDIF.                                                "46a
    ENDAT.

*   End compression per batch   (only lockbox case)            "46a
    AT END OF febep-batch.                                  "46a
      IF komkb = 'X'.                                       "46a
        IF febep-esnum GT 0                                 "46a
        AND exit = false                    "correct note 314943
        AND (    ikofi-komk1 NE space                       "46a
              OR ikofi-komk2 NE space ) .                   "46a
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*          perform abschluss_komprimierung.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
          PERFORM abschluss_komprimierung CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*          perform fb01_posting_aufrufen.                    "46a
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
          PERFORM fb01_posting_aufrufen CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
        ENDIF.                                              "46a
      ENDIF.                                                "46a
    ENDAT.                                                  "46a

*   Ende des Kontoauszugs
    AT END OF febko-kukey.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*      perform druck_fehlerprotokoll.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
      PERFORM druck_fehlerprotokoll CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
* compression per lockbox, i.e. account
      if komk = 'X' and febko-anwnd = '0003'
                    and exit = false
                    and komkb ne 'X'.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*        perform abschluss_komprimierung.           "note 574997
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
        PERFORM abschluss_komprimierung CHANGING xt_fb01. "note 574997
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*        perform fb01_posting_aufrufen.             "note 574997
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
        PERFORM fb01_posting_aufrufen CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
      ENDIF.                                        "note 574997
    ENDAT.

*   Ende der Loopverarbeitung
    AT LAST.
*     Statistik letzte Zeile beenden und in interner Tabelle sichern
      PERFORM append_statist.
    ENDAT.

  ENDLOOP.

* Mappe schließen
  IF open = true.
    PERFORM posting_interface_end.
  ENDIF.

* FEBEP_OK sortieren für den Bereich 2
  IF bereich = '1'.
    SORT febep_ok.
  ENDIF.

ENDFORM.                    "LOOP_EXTRACT

*eject
*---------------------------------------------------------------------*
*       FORM POSTING_INTERFACE_END.
*---------------------------------------------------------------------*
FORM posting_interface_end.
* Buchungsschnittstelle schließen
  IF testl NE 'X'.
    CALL FUNCTION 'POSTING_INTERFACE_END'.
  ENDIF.
  open = false.

ENDFORM.                    "POSTING_INTERFACE_END


*---------------------------------------------------------------------*
*       FORM POSTING_INTERFACE_START.
*---------------------------------------------------------------------*
FORM posting_interface_start.

  DATA: l_keep LIKE febko-xkep1.                            "hw495571
  IF bereich = '1'.                                         "hw495571
    l_keep = febko-xkep1.                                   "hw495571
  ELSE.                                                     "hw495571
    l_keep = febko-xkep2.                                   "hw495571
  ENDIF.                                                    "hw495571
* Interne Buchungsschnittstelle initialisieren
  IF testl NE 'X'.
    CALL FUNCTION 'POSTING_INTERFACE_START'
      EXPORTING
        i_function = function
        i_group    = mappe
        i_holddate = datum
        i_keep     = l_keep                                 "hw495571
        i_mode     = mode
        i_user     = usnam.
  ENDIF.
  open = true.

ENDFORM.                    "POSTING_INTERFACE_START

*eject
*--------------------------------------------------------------
*       FORM SEGMENTTEXT_TO_FTPOST.
*--------------------------------------------------------------
*       Segmenttext füllen mit Verwendungszweck 1 und 2
*--------------------------------------------------------------
FORM segmenttext_to_ftpost USING sgtxt.
  DATA: len TYPE i.

  CLEAR: sgtxt, char140.
  IF febep-sgtxt IS INITIAL.
    IF febko-anwnd <> '0002'.                               "31I-HP
      IF NOT febep-chect IS INITIAL.                        "31H-HP
        char140 = febep-chect.                              "31H-HP
        sgtxt   = febep-chect.                              "31H-HP
      ENDIF.                                                "31H-HP
    ENDIF.                                                  "31I-HP
    LOOP AT xfebre.
      len = STRLEN( char140 ).
      IF len > 50.
        EXIT.
      ENDIF.
      len = len + 1.
      WRITE xfebre-vwezw TO char140+len.
      CONDENSE char140.
      MOVE char140 TO sgtxt.
    ENDLOOP.
  ELSE.
    sgtxt = febep-sgtxt.
  ENDIF.

* IF NOT sgtxt IS INITIAL.                                 "45A
*   PERFORM ftpost_field USING 'BSEG-SGTXT' sgtxt.         "45A
* ENDIF.                                                   "45A
ENDFORM.                    "SEGMENTTEXT_TO_FTPOST



*eject
*---------------------------------------------------------------------*
*       FORM UPDATE_FEBKO_STATUS.
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
FORM update_febko_status.
  LOOP.
    AT NEW febko-kukey.
*     ALLE EXTRAHIERTEN KUKEY IN EX_KUKEY SICHERN
      ex_kukey-kukey = febko-kukey.
      APPEND ex_kukey.
    ENDAT.
  ENDLOOP.

  LOOP AT ex_kukey.
    IF xtrwpr = 'X' AND function = 'C'.                     "hw426052
      CALL FUNCTION 'UPDATE_FEBKO_VB_STATUS'                "hw426052
      IN UPDATE TASK                                        "hw426052
      EXPORTING                                             "hw426052
        i_kukey            = ex_kukey-kukey                 "hw426052
      EXCEPTIONS                                            "hw426052
        kukey_not_in_febko = 1                              "hw426052
        OTHERS             = 2.                             "hw426052
    ELSE.                                                   "hw426052
      CALL FUNCTION 'UPDATE_FEBKO_VB_STATUS'
        EXPORTING
          i_kukey            = ex_kukey-kukey
        EXCEPTIONS
          kukey_not_in_febko = 1
          OTHERS             = 2.
    ENDIF.                                                  "hw426052

*   SELECT * FROM FEBKO WHERE KUKEY = EX_KUKEY-KUKEY.
*     ALL_VB1OK = TRUE.
*     ALL_VB2OK = TRUE.

*     REFRESH XFEBEP.
*     SELECT * FROM FEBEP INTO TABLE XFEBEP
*                         WHERE KUKEY = FEBKO-KUKEY
*                           AND EPERL = ' '.

*     LOOP AT XFEBEP.
*       IF XFEBEP-VB1OK NE 'X'.
*         ALL_VB1OK = FALSE.
*       ENDIF.
*       IF XFEBEP-VB2OK NE 'X'.
*         ALL_VB2OK = FALSE.
*       ENDIF.
*       IF XFEBEP-VB1OK = 'X' AND XFEBEP-VB2OK = 'X'.
*         UPDATE FEBEP SET   EPERL = 'X'
*                      WHERE KUKEY = XFEBEP-KUKEY
*                        AND ESNUM = XFEBEP-ESNUM.
*       ENDIF.
*     ENDLOOP.

*     IF ALL_VB1OK = TRUE.
*     alles was im Bereich 1 zu buchen war, wurde gebucht
*       FEBKO-VB1OK = 'X'.
*     ENDIF.
*     IF ALL_VB2OK = TRUE.
*     alles was im Bereich 2 zu buchen war, wurde gebucht
*       FEBKO-VB2OK = 'X'.
*     ENDIF.

*     IF FEBKO-VB1OK = 'X' AND FEBKO-VB2OK = 'X'.
*     Auszug wurde komplett bearbeitet
*       FEBKO-ASTAT = '8'.
*     ELSE.
*     Auszug unvollständig verbucht
*       FEBKO-ASTAT = '7'.
*     ENDIF.
*     UPDATE FEBKO SET   ASTAT = FEBKO-ASTAT
*                        VB1OK = FEBKO-VB1OK
*                        VB2OK = FEBKO-VB2OK
*                  WHERE KUKEY = FEBKO-KUKEY.

*   ENDSELECT.
  ENDLOOP.

  COMMIT WORK.

ENDFORM.                    "UPDATE_FEBKO_STATUS


*eject
*--------------------------------------------------------------------*
*   FORM XSKAT_LESEN USING SAKNR.
*--------------------------------------------------------------------*
*   XSKAT lesen für die Protokollausgabe (Bezeichnung des Sachkontos)*
*--------------------------------------------------------------------*
FORM xskat_lesen USING saknr.
*------- Tabelle XSKAT lesen: (1. interne Tabelle, 2. Transp-Tabelle) --
  LOOP AT xskat WHERE spras = t001-spras
                  AND ktopl = febko-ktopl                   "hw380877
                  AND saknr = saknr.
    EXIT.
  ENDLOOP.
  IF sy-subrc NE 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM skat WHERE spras = t001-spras
*                                AND ktopl = febko-ktopl     "hw380877
*                                AND saknr = saknr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM skat WHERE spras = t001-spras
                                AND ktopl = febko-ktopl     "hw380877
                                AND saknr = saknr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc = 0.
      xskat = skat.
      APPEND xskat.
    ELSE.
      CLEAR xskat.
    ENDIF.
  ENDIF.
ENDFORM.                    "XSKAT_LESEN

*eject
*&---------------------------------------------------------------------*
*&      Form  POSTING_INTERFACE_CLEARING
*&---------------------------------------------------------------------*
*       Aufruf des Funktionsbaustein                                   *
*----------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form posting_interface_clearing.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM posting_interface_clearing CHANGING xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  CLEAR: subrc, msgid, msgty, msgno, msgv1, msgv2, msgv3, msgv4.

  IF xtrwpr = 'X' AND function = 'C'.                       "hw426052
    EXPORT bereich                                          "hw426052
           febep-kukey                                      "hw426052
           febep-esnum                                      "hw426052
           komk                                             "hw426052
           xakon                                            "hw426052
           r_csnum                                          "hw426052
           vbkep                                            "hw426052
           xfebcl                                           "hw426052
           TO MEMORY ID 'FEBA_POST'.                        "hw426052
  ENDIF.                                                    "hw426052

  IF function = 'C'.                                        "hw606667
    EXPORT febep-kukey                                      "hw607667
           febep-esnum                                      "hw607667
           TO MEMORY ID 'FEBEP_KEY'.                        "hw607667
  ENDIF.                                                    "hw607667

  CALL FUNCTION 'POSTING_INTERFACE_CLEARING'
    EXPORTING
      i_auglv   = auglv
      i_tcode   = tcode
    IMPORTING
      e_subrc   = subrc
      e_msgid   = msgid
      e_msgty   = msgty
      e_msgno   = msgno
      e_msgv1   = msgv1
      e_msgv2   = msgv2
      e_msgv3   = msgv3
      e_msgv4   = msgv4
    TABLES
      t_ftpost  = ftpost
      t_ftclear = ftclear
      t_fttax   = fttax
      t_blntab  = xblntab.

  IF xtrwpr = 'X' AND function = 'C'.                        "n972881
    FREE MEMORY ID 'FEBA_POST'.                              "n972881
  ENDIF.                                                     "n972881


  IF subrc = 0.
    IMPORT augst_avis FROM MEMORY ID 'FI_AUGST_AVIS'.
    IF NOT sy-subrc IS INITIAL.                            "note 356935
      CLEAR augst_avis.                                    "note 356935
    ELSE.                                                  "note 356935
      FREE MEMORY ID 'FI_AUGST_AVIS'.                      "note 356935
    ENDIF.                                                 "note 356935
    IF augst_avis = 2.
      xakon = 'X'.
      IF r_csnum IS INITIAL.           "<<< HP
        febep-akbln = xblntab-belnr.
      ELSE.                            "<<< HP
        LOOP AT xfebcl WHERE kukey = febep-kukey AND    "<<< HP
                             esnum = febep-esnum AND    "<<< HP
                             csnum = r_csnum.           "<<< HP
          xfebcl-selbis+10 = xblntab-belnr.             "<<< HP
          MODIFY xfebcl.               "<<< HP
        ENDLOOP.                       "<<< HP
      ENDIF.                           "<<< HP
      IF febep-pform = '12'.           "<<< HP
        CLEAR xakon.                   "Set Document no.     "<<< HP
        PERFORM delete_remadv.         "Delete Advice        "<<< HP
      ELSE.                            "<<< HP
        PERFORM add_on_acc_doc_to_remadv.
      ENDIF.                           "<<< HP
    ENDIF.
    PERFORM update_febep_status.
  ELSE.
    IMPORT difffw FROM MEMORY ID 'FI_DIFFFW'.
  ENDIF.

*----- Print Message if Call Trans and Posting Log (never for Lockbox)--
  IF  function = 'C'
  AND p_bupro  = 'X'.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*          perform druck_message.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    PERFORM druck_message CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  ENDIF.

*----- Save Message for Lockbox Posting Log ---------------------------
  IF anwnd = '0003'.                                        "
    PERFORM save_message_for_lbox_log USING bereich.        "
  ENDIF.                                                    "
  CLEAR xakon.                                              "hw503037
ENDFORM.                               " POSTING_INTERFACE_CLEARING


*eject
*&---------------------------------------------------------------------*
*&      Form  CHECK_CALL_EXTERNAL_FUNCTION
*&---------------------------------------------------------------------*
*  Vor Aufruf der Buchungsschnittstelle erfolgt eventuell noch ein
*  Aufruf eines Funktionsbausteins einer anderen Anwendung, um z.B.
*  nur best. offene Posten eines Beleges zu selektieren und evtl.
*  eine Teilzahlung zu generieren.
*  Aufruf erfolgt, wenn mit dem aus dem Userexit übergebenen
*  Funktionsbausteinnamen.
*  (SELFD = 'FB', SELVON = Funktionsbausteinname)
*----------------------------------------------------------------------*
FORM check_call_external_function.
  DATA: fb_name LIKE ftclear-selvon.

  DATA: ref_to_badi TYPE REF TO if_ex_feb_badi.
  DATA: lt_ftpost TYPE STANDARD TABLE OF ftpost,            "note 641010
        lt_ftclear TYPE STANDARD TABLE OF ftclear,          "note 641010
        lt_fttax TYPE STANDARD TABLE OF fttax,              "note 641010
        lt_febre TYPE STANDARD TABLE OF febre,              "note 641010
        lt_febcl TYPE STANDARD TABLE OF febcl.              "note 641010

* init BADI
  IF ref_to_badi IS INITIAL.
    CALL METHOD cl_exithandler=>get_instance
      EXPORTING
        exit_name              = 'FEB_BADI'                 "hw561859
        null_instance_accepted = 'X'                        "hw561859
      CHANGING
        instance               = ref_to_badi.
  ENDIF.

* call BADI
  IF NOT ref_to_badi IS INITIAL.                            "hw561859
    lt_ftpost[]  = ftpost[].                                "note 641010
    lt_ftclear[] = ftclear[].                               "note 641010
    lt_fttax[]   = fttax[].                                 "note 641010
    lt_febre[]   = xfebre[].                                "note 641010
    lt_febcl[]   = xfebcl[].                                "note 641010
    CALL METHOD ref_to_badi->change_posting_data
      EXPORTING
        i_auglv   = auglv
        i_tcode   = tcode
        i_febko   = febko
        i_febep   = febep
        i_ikofi   = ikofi
      IMPORTING
        e_subrc   = subrc
        e_msgid   = msgid
        e_msgty   = msgty
        e_msgno   = msgno
        e_msgv1   = msgv1
        e_msgv2   = msgv2
        e_msgv3   = msgv3
        e_msgv4   = msgv4
      CHANGING
        t_ftpost  = lt_ftpost[]                             "note 641010
        t_ftclear = lt_ftclear[]                            "note 641010
        t_fttax   = lt_fttax[]                              "note 641010
        t_febre   = lt_febre[]                              "note 641010
        t_febcl   = lt_febcl[].                             "note 641010
    ftpost[]  = lt_ftpost[].                                "note 641010
    ftclear[] = lt_ftclear[].                               "note 641010
    fttax[]   = lt_fttax[].                                 "note 641010
    xfebre[]  = lt_febre[].                                 "note 641010
    xfebcl[]  = lt_febcl[].                                 "note 641010
  ENDIF.                                                    "hw561859

  LOOP AT ftclear WHERE selfd = 'FB'.
    fb_name = ftclear-selvon.
    CHECK NOT fb_name IS INITIAL.

*   Funktionsb nur aufrufen, wenn Namenskonvention und Bereich stimmt
    IF bereich = '1'.
      CHECK fb_name CS 'FEB_1_'.
    ENDIF.
    IF bereich = '2'.
      CHECK fb_name CS 'FEB_2_'.
    ENDIF.

*   Spezialkennzeichen von manuellem Kontoauszug eliminieren

    IF ftclear-agkoa = 'Z'.
      CLEAR ftclear-agkoa.
      CLEAR ftclear-agkon.
      MODIFY ftclear.
    ENDIF.

    LOOP AT xfebcl WHERE selfd = 'FB'.
      CHECK xfebcl-koart = 'Z'.
      CLEAR xfebcl-koart.
      CLEAR xfebcl-agkon.
      MODIFY xfebcl.
    ENDLOOP.

    ex_funct = true.

*   fremden Funktionsbaustein aufrufen
    CALL FUNCTION fb_name
      EXPORTING
        i_auglv   = auglv
        i_tcode   = tcode
        i_febko   = febko
        i_febep   = febep
      IMPORTING
        e_subrc   = subrc
        e_msgid   = msgid
        e_msgty   = msgty
        e_msgno   = msgno
        e_msgv1   = msgv1
        e_msgv2   = msgv2
        e_msgv3   = msgv3
        e_msgv4   = msgv4
      TABLES
        t_ftpost  = ftpost
        t_ftclear = ftclear
        t_fttax   = fttax
        t_febre   = xfebre
        t_febcl   = xfebcl.
    EXIT.
  ENDLOOP.

  delete ftclear where selfd = 'FB'.                       "hw757054

ENDFORM.                               " CHECK_CALL_EXTERNAL_FUNCTION


*eject
*&---------------------------------------------------------------------*
*&      Form  UPDATE_STAUTS_FEBEP
*&---------------------------------------------------------------------*
*       FEBEP-Status Felder updaten                                    *
*       falls Batch Input -> BELNR = '*'                               *
*----------------------------------------------------------------------*
FORM update_febep_status.
  DATA: new_selbis LIKE febcl-selbis,
        vb2ok      LIKE febep-vb2ok,
        l_awkey    TYPE awkey.                              "hw462052

* CHECK NOT XBLNTAB-BELNR IS INITIAL.
  IF xblntab-belnr IS INITIAL
  AND function = 'C'.
*-------- call transaction mode: if F5 261 clearing without posting ---
    IF msgid = 'F5'
    AND msgno = '261'
    AND NOT msgv1 IS INITIAL.
      xblntab-belnr = msgv1.
*-------- call transaction mode: F5 312 document posted with no. ---
    ELSEIF msgid = 'F5'                                     "45B
    AND msgno = '312'                                       "45B
    AND NOT msgv1 IS INITIAL.                               "45B
      xblntab-belnr = msgv1.                                "45B
    ELSE.
*------- nothing to Update -------------------------------------------
      EXIT.
    ENDIF.
* endif.                                   "Intercompany Doc begin
* if xblntab-belnr is initial
  ELSEIF xblntab-belnr IS INITIAL
  AND function = 'B'.
*------- Wenn Batch-Input und keine Belegnummer -> '*'  ---------------
    xblntab-belnr = '*'.
*  endif.
  ELSE.                 "only position xblntab if not already re-filled
    CLEAR xblntab.
    READ TABLE xblntab WITH KEY bukrs = febko-bukrs.
    IF sy-subrc <> 0.                                       "hw594015
      LOOP AT xblntab WHERE belnr <> space.                 "hw594015
        EXIT.                                               "hw594015
      ENDLOOP.                                              "hw594015
    ENDIF.                                                  "hw594015
  ENDIF.                               "end Intercompany


  CHECK testl NE 'X'.

* rest of the coding now in update function module          "hw462052

  l_awkey(10)   = xblntab-belnr.                            "hw462052
  l_awkey+10(4) = febko-bukrs.                              "hw462052
  l_awkey+14(4) = xblntab-gjahr.                            "hw462052

  IF xtrwpr = 'X' AND function = 'C'.                       "hw462052
* update function called by RW interface in update task     "hw462052
  ELSE.                                                     "hw462052
    CALL FUNCTION 'UPDATE_FEBEP_VB_STATUS'                  "hw462052
      EXPORTING                                             "hw462052
        i_awkey        = l_awkey                            "hw462052
        i_posting_area = bereich                            "hw462052
        i_kukey        = febep-kukey                        "hw462052
        i_esnum        = febep-esnum                        "hw462052
        i_komk         = komk                               "hw462052
        i_xakon        = xakon                              "hw462052
        i_rcsnum       = r_csnum                            "hw462052
        i_augst_avis   = augst_avis                         "hw462052
      TABLES                                                "hw462052
        i_vbkep        = vbkep                              "hw462052
        i_xfebcl       = xfebcl.                            "hw462052
  ENDIF.                                                    "hw462052

* at last, fill header line fields which are read for advice creation
  IF komk = ' ' AND xakon = 'X'.                            "hw462052
    IF bereich = '1'.                                       "hw462052
      febep-ak1bl = xblntab-belnr.                          "hw462052
    ELSE.                                                   "hw462052
      febep-akbln = xblntab-belnr.                          "hw462052
    ENDIF.                                                  "hw462052
  ENDIF.                                                    "hw462052
*
** if ikofi-komk1 = 'X'                        "DELETE - mpEURO
** or ikofi-komk2 = 'X'.                       "DELETE - mpEURO
** Important: compression must be not overruled (-> check komk)
*  IF KOMK = 'X'.                       "INSERT - mpEURO
**-------- Compression -------------------------------------------------
*    IF BEREICH = '1'.
*      LOOP AT VBKEP.
*        UPDATE FEBEP SET   VB1OK = 'X'
*                           BELNR = XBLNTAB-BELNR
*                           GJAHR = XBLNTAB-GJAHR
*                     WHERE KUKEY = VBKEP-KUKEY
*                       AND ESNUM = VBKEP-ESNUM.
*      ENDLOOP.
*    ELSE.
*      LOOP AT VBKEP.
*        UPDATE FEBEP SET   VB2OK = 'X'
*                           NBBLN = XBLNTAB-BELNR
*                           GJAHR = XBLNTAB-GJAHR
*                     WHERE KUKEY = VBKEP-KUKEY
*                       AND ESNUM = VBKEP-ESNUM.
*      ENDLOOP.
*    ENDIF.
*  ELSE.
**-------- No Compression ---------------------------------------------
*    IF BEREICH = '1'.
*      IF XAKON = 'X'.
**       update febep set   akbln = xblntab-belnr
*        UPDATE FEBEP SET   AK1BL = XBLNTAB-BELNR
*                           GJAHR = XBLNTAB-GJAHR
*                           ESTAT = AUGST_AVIS
*                           INFO2 = TEXT-025
*                     WHERE KUKEY = FEBEP-KUKEY
*                       AND ESNUM = FEBEP-ESNUM.
*        FEBEP-AK1BL = XBLNTAB-BELNR.
*
*      ELSE.
*        UPDATE FEBEP SET VB1OK = 'X'
*                         BELNR = XBLNTAB-BELNR
*                         GJAHR = XBLNTAB-GJAHR
*                   WHERE KUKEY = FEBEP-KUKEY
*                     AND ESNUM = FEBEP-ESNUM.
*      ENDIF.
*    ELSE.
*      IF XAKON = 'X'.
*        IF R_CSNUM IS INITIAL.         "<<< HP
*          UPDATE FEBEP SET   AKBLN = XBLNTAB-BELNR   "Change
*                             GJAHR = XBLNTAB-GJAHR
*                             ESTAT = AUGST_AVIS
*                             INFO2 = TEXT-025
*                       WHERE KUKEY = FEBEP-KUKEY
*                         AND ESNUM = FEBEP-ESNUM.
*          FEBEP-AKBLN = XBLNTAB-BELNR.
*        ELSE.                          "<<< HP
*          LOOP AT XFEBCL WHERE KUKEY = FEBEP-KUKEY AND    "<<< HP
*                               ESNUM = FEBEP-ESNUM AND    "<<< HP
*                               CSNUM = R_CSNUM.           "<<< HP
*            CLEAR NEW_SELBIS.          "<<< HP
*            NEW_SELBIS+10 = XBLNTAB-BELNR.                "<<< HP
*            UPDATE FEBCL SET SELBIS = NEW_SELBIS          "<<< HP
*                       WHERE KUKEY = XFEBCL-KUKEY         "<<< HP
*                         AND ESNUM = XFEBCL-ESNUM         "<<< HP
*                         AND CSNUM = XFEBCL-CSNUM.        "<<< HP
*          ENDLOOP.                     "<<< HP
*        ENDIF.                         "<<< HP
*      ELSE.
*        IF R_CSNUM IS INITIAL.         "<<< HP
*          UPDATE FEBEP SET   VB2OK = 'X'
*                             NBBLN = XBLNTAB-BELNR
*                             GJAHR = XBLNTAB-GJAHR
*                             ESTAT = AUGST_AVIS
*                       WHERE KUKEY = FEBEP-KUKEY
*                         AND ESNUM = FEBEP-ESNUM.
*        ELSE.                          "<<< HP
*          LOOP AT XFEBCL WHERE KUKEY = FEBEP-KUKEY AND    "<<< HP
*                               ESNUM = FEBEP-ESNUM AND    "<<< HP
*                               CSNUM = R_CSNUM.           "<<< HP
*            NEW_SELBIS = XFEBCL-SELBIS."<<< HP
*            NEW_SELBIS(10) = XBLNTAB-BELNR.               "<<< HP
*            UPDATE FEBCL SET SELBIS = NEW_SELBIS          "<<< HP
*                       WHERE KUKEY = XFEBCL-KUKEY         "<<< HP
*                         AND ESNUM = XFEBCL-ESNUM         "<<< HP
*                         AND CSNUM = XFEBCL-CSNUM.        "<<< HP
*            XFEBCL-SELBIS = NEW_SELBIS."<<< HP
*            MODIFY XFEBCL.             "<<< HP
*          ENDLOOP.                     "<<< HP
*          VB2OK = 'X'.                 "<<< HP
*          LOOP AT XFEBCL WHERE KUKEY = FEBEP-KUKEY AND    "<<< HP
*                               ESNUM = FEBEP-ESNUM AND    "<<< HP
*                               CSNUM <> R_CSNUM.          "<<< HP
*            IF XFEBCL-SELBIS(10) = SPACE.                 "<<< HP
*              CLEAR VB2OK.             "<<< HP
*            ENDIF.                     "<<< HP
*          ENDLOOP.                     "<<< HP
*          IF VB2OK = 'X'.              "<<< HP
*            UPDATE FEBEP SET   VB2OK = 'X'                "<<< HP
*                         NBBLN = XBLNTAB-BELNR            "<<< HP
*                         GJAHR = XBLNTAB-GJAHR            "<<< HP
*                         ESTAT = AUGST_AVIS               "<<< HP
*                   WHERE KUKEY = FEBEP-KUKEY              "<<< HP
*                     AND ESNUM = FEBEP-ESNUM.             "<<< HP
*          ENDIF.                       "<<< HP
*        ENDIF.                         "<<< HP
*
*      ENDIF.
*    ENDIF.
*  ENDIF.

  febep-gjahr = xblntab-gjahr.

* alles clearen
  REFRESH: vbkep.
  CLEAR:   vbkep.
  CLEAR:   augst_avis.
  CLEAR:   xakon.
ENDFORM.                               " UPDATE_STAUTS_FEBEP


*eject
*&---------------------------------------------------------------------*
*&      Form  UPDATE_STAUTS_FEBEP_NOT_POST.
*&---------------------------------------------------------------------*
*       Diese Routine wird dann aufgerufen, wenn nichts gebucht        *
*       werden soll (Kein Buchungsschema angelegt)                     *
*       VBnOK wird auf 'X' gesetzt, Belegnr-Felder bleiben initial     *
*----------------------------------------------------------------------*
FORM update_febep_status_not_post.
  DATA:  l_belnr LIKE bkpf-belnr VALUE '-'.

  CHECK testl NE 'X'.

  IF bereich = '1'.
    UPDATE febep SET   vb1ok = 'X'
                       belnr = l_belnr
                 WHERE kukey = febep-kukey
                   AND esnum = febep-esnum.

  ELSE.

*   Brazil, Depner 19.08.97 --------------------------------------------
    CALL FUNCTION 'J_1BSA_COMPONENT_ACTIVE'
      EXPORTING
        bukrs                = febko-bukrs
        component            = 'BR'
      EXCEPTIONS
        component_not_active = 01.
    IF sy-subrc = 0.
      l_belnr = febep-belnr.
    ENDIF.
*   End Brazil ---------------------------------------------------------

    UPDATE febep SET   vb2ok = 'X'
                       nbbln = l_belnr
                 WHERE kukey = febep-kukey
                   AND esnum = febep-esnum.
  ENDIF.

* alles clearen
  REFRESH: vbkep.
  CLEAR:   vbkep.
ENDFORM.                               " UPDATE_STAUTS_FEBEP

*eject
*&---------------------------------------------------------------------*
*&      Form  AVIS_ERZEUGEN
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form avis_erzeugen.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM avis_erzeugen CHANGING xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  DATA: avsrt LIKE avik-avsrt VALUE '02'.
  DATA: amount LIKE febep-kwbtr.                            "31I-HP
  DATA: pyord_sel(1) TYPE c.         "no advice if selection with pyord
  DATA l_account TYPE febep-avkon.                          "note 452579

  CLEAR: amount.                                            "31I-HP
  CLEAR: pyord_sel.

*------- Falls AVSID initial wurde noch kein Avis erzeugt -----------
  CHECK febep-avsid IS INITIAL.
* check bereich = '2'.                 "advice only for area 2
  IF bereich = '1'.                    "Post-on-account bank S/L
    CHECK NOT ikofi-bscak IS INITIAL.  "Post-on-account bank S/L
  ENDIF.                               "Post-on-account bank S/L
  CHECK febko-anwnd NE '0002'.         " nicht bei Scheckeinreicher
  CHECK ex_funct = false.              " kein externer FB im Spiel

*------- AVKON darf nicht initial sein -------------------------------
* first identified account will be set (customer, vendor, or GL)
  IF febep-avkon IS INITIAL.
    LOOP AT ftclear WHERE NOT agkon IS INITIAL.
      febep-avkon = ftclear-agkon.
      febep-avkoa = ftclear-agkoa.
      EXIT.
    ENDLOOP.
  ENDIF.

*   However, the clearing data may not identify the account
**  identify the customer from the febcl documents
*
  IF febep-avkon IS INITIAL.
    febep-avkon = '*'.
  ENDIF.

  IF bereich = '1' OR                  "Post-on-account bank S/L
     ikofi-bscak IS INITIAL.           "Post-on-account bank S/L
*    FEBEP-AVKON = '*'.
  ELSE .                               "Post-on-account bank S/L
*  determine the account for on-account posting and store in ftclear
    CLEAR ftclear.
    LOOP AT ftclear.
      IF NOT ftclear-agkon IS INITIAL.
*     identification is complete for item
      ELSEIF NOT ftclear-selfd  EQ 'BELNR'
                    AND   NOT ftclear-selvon IS INITIAL
                    AND       ftclear-agkoa = 'D'.
*     identification might occur by reference document number
      ELSE.
*     identify by document number
*reak-point.
        CLEAR bseg.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*        SELECT * FROM bkpf WHERE bukrs = febko-bukrs
*                            AND belnr = ftclear-selvon.
*
* NEW CODE
        SELECT *
 FROM bkpf WHERE bukrs = febko-bukrs
                            AND belnr = ftclear-selvon ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*          SELECT * FROM bseg WHERE bukrs = bkpf-bukrs
*                             AND belnr = bkpf-belnr
*                             AND gjahr = bkpf-gjahr
*                             AND augbl = space
*                             AND koart = ftclear-agkoa.
*
* NEW CODE
          SELECT *
 FROM bseg WHERE bukrs = bkpf-bukrs
                             AND belnr = bkpf-belnr
                             AND gjahr = bkpf-gjahr
                             AND augbl = space
                             AND koart = ftclear-agkoa ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
*                           or koart = 'K' ).
            ftclear-agkon = bseg-kunnr.
            MODIFY ftclear.
            EXIT.
          ENDSELECT.
        ENDSELECT.
      ENDIF.
    ENDLOOP.
  ENDIF.                               "posting area 2 only
*   now set the target customer to be the first found
  IF febep-avkon = '*'.
    LOOP AT ftclear WHERE NOT agkon IS INITIAL.
      febep-avkon = ftclear-agkon.
      febep-avkoa = ftclear-agkoa.
      EXIT.
    ENDLOOP.
  ENDIF.                               "if febep-avkon is initial

**  end of enhancment to identify the customer from the febcl data
*
  IF febep-avkoa IS INITIAL.
    LOOP AT ftclear WHERE NOT agkoa IS INITIAL.
      febep-avkoa = ftclear-agkoa.
      EXIT.
    ENDLOOP.
  ENDIF.
  IF febep-avkoa IS INITIAL.
    febep-avkoa = 'D'.
  ENDIF.

*------- Aviskopf fuellen ---------------------------------------------
  CLEAR avik.
  CLEAR avip.

  avik-mandt       = sy-mandt.
  avik-bukrs       = febko-bukrs.
  avik-koart       = febep-avkoa.
  avik-konto       = febep-avkon.
  avik-avsid+0(2)  = avsrt.
  avik-avsid+2(8)  = febep-kukey.
  avik-avsid+10(5) = febep-esnum.
  IF febep-fwbtr IS INITIAL OR bereich = 1.             "INSERT - mpEURO
*    no original transaction currency provided or posting area = 1.
    avik-waers       = febep-kwaer.    "ok -mpEURO
    IF febep-epvoz = 'S'.                                   "31I-HP
      avik-rwbtr     = febep-kwbtr * -1.                    "31I-HP
    ELSE.                                                   "31I-HP
      avik-rwbtr     = febep-kwbtr.
    ENDIF.                                                  "31I-HP
  ELSE.                                "INSERT - mpEURO
*   original transaction currency provided and posting area = 2.
    avik-waers = febep-fwaer .         "INSERT - mpEURO
    IF febep-epvoz = 'S'.              "INSERT - mpEURO
      avik-rwbtr     = febep-fwbtr * -1.              "INSERT - mpEURO
    ELSE.                              "INSERT - mpEURO
      avik-rwbtr     = febep-fwbtr.    "INSERT - mpEURO
    ENDIF.                             "INSERT - mpEURO
  ENDIF.                               "INSERT - mpEURO
  avik-avtxt       = text-048.
  avik-avsrt       = avsrt.
  avik-tcode       = tcode.

  LOOP AT ftclear.
*   H_FTCLEAR = FTCLEAR.


    avip-mandt      = avik-mandt.
    avip-bukrs      = avik-bukrs.
    avip-koart      = avik-koart.
    avip-konto      = avik-konto.
    avip-avsid      = avik-avsid.
    avip-avspo      = sy-tabix.
    IF NOT ftclear-agkon IS INITIAL
    AND ftclear-agkon NE febep-avkon.                       "31I-HP
*   and ftclear-agkon ne febep-knrza.            "31I-HP
      avip-abwko = ftclear-agkon.                           "31I-HP
*     AVIP-ABWKO = FTCLEAR-AGKON.
    ENDIF.
    IF NOT ftclear-agkoa IS INITIAL
    AND ftclear-agkoa NE febep-avkoa.
      avip-abwka = ftclear-agkoa.
    ENDIF.
    IF NOT ftclear-agbuk IS INITIAL                         "ak030899
       AND ftclear-agbuk NE febko-bukrs.                    "ak030899
      avip-abwbu = ftclear-agbuk.                           "ak030899
    ENDIF.                                                  "ak030899

    IF NOT ftclear-agbuk IS INITIAL                         "p99 qc 1
       AND ftclear-agbuk NE febko-bukrs.
      avip-abwbu = ftclear-agbuk.
    ENDIF.
    avip-sfeld      = ftclear-selfd.
*   AVIP-SWERT      = FTCLEAR-SELVON.
    CASE ftclear-selfd.
      WHEN 'BELNR'.
        avip-belnr = ftclear-selvon.
      WHEN 'XBLNR'.
        avip-xblnr = ftclear-selvon.
      WHEN 'BUDAT'.
        avip-sdate = ftclear-selvon.
      WHEN 'BLDAT'.
        avip-sdate = ftclear-selvon.
      WHEN 'PYORD'.
        pyord_sel = 'X'.
        EXIT.                          "loop
      WHEN 'KIDNO'.
        avip-kidno = ftclear-selvon.
      WHEN 'WRBTR'.
        IF febep-fwbtr IS INITIAL OR bereich = 1.       "INSERT - mpEURO
*       no original transaction currency provided or posting area = 1.
          ftclear-selvon =  febep-kwbtr.               "INSERT - mpEURO
          CONDENSE ftclear-selvon NO-GAPS.             "INSERT - mpEURO
        ELSE.
          ftclear-selvon =  febep-fwbtr.                "INSERT - mpEURO
          CONDENSE ftclear-selvon NO-GAPS.              "INSERT - mpEURO
        ENDIF.                         "INSERT - mpEURO
        IF febep-epvoz = 'S'.                               "31I-HP
          amount = ftclear-selvon * -1.                     "31I-HP
        ELSE.                                               "31I-HP
          amount = ftclear-selvon.                          "31I-HP
        ENDIF.                                              "31I-HP
        avip-scurr = amount.                                "31I-HP
        avip-wrbtr = amount.                                "31I-HP
*       avip-scurr = ftclear-selvon.              "31I-HP
*       avip-wrbtr = ftclear-selvon.              "31I-HP
      WHEN 'ZUONR'.                                 "n859156
        avip-zuonr = ftclear-selvon.
      WHEN OTHERS.
    ENDCASE.

    xavip = avip.
    APPEND xavip.
    CLEAR avip.

    AT LAST.
      IF NOT febep-akbln IS INITIAL.
*       Avispostition für die Akonto-Buchung
        avip-mandt      = avik-mandt.
        avip-bukrs      = avik-bukrs.
        avip-koart      = avik-koart.
        avip-konto      = avik-konto.
        avip-avsid      = avik-avsid.
        avip-avspo      = sy-tabix + 1.
        avip-abwko      = febep-avkon.
        avip-sfeld      = 'BELNR'.
        avip-swert      = febep-akbln.
        avip-belnr      = febep-akbln.
*       AVIP-WRBTR      = FEBEP-KWBTR.

        xavip = avip.
        APPEND xavip.
        CLEAR avip.

      ENDIF.                           "not febep-akbln is initial
    ENDAT.
  ENDLOOP.

* Posting on-account
* The advice header customer is the on-account customer
* One posting area attempt, not for area 2 if area 1 is filled
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM febep INTO xfebep WHERE
*     kukey = febep-kukey AND
*     esnum = febep-esnum.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM febep INTO xfebep WHERE
     kukey = febep-kukey AND
     esnum = febep-esnum ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF NOT ikofi-bscak IS INITIAL AND
             NOT avik-konto = '*' AND
             NOT avik-konto CA '=' AND
                 xfebep-ak1bl IS INITIAL.                   "45b/slk
*                 febep-ak1bl is initial.             "45b/slk

    tcode = 'FB05'.                    "on-account uses FB05
    xakon = 'X'.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    perform fb05_bseg_akonto_haben.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    PERFORM fb05_bseg_akonto_haben CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
    CLEAR ftclear.                     "from lockbox err/hndl
    REFRESH ftclear.
    x_error_handling = 'X'.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    perform fb05_posting_aufrufen using 'X'.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    PERFORM fb05_posting_aufrufen USING 'X'
                                  CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
*   append advice information if posting is sucessful
    IF ( ( bereich = '1' ) AND ( NOT febep-ak1bl IS INITIAL ) ) OR
       ( ( bereich = '2' ) AND ( NOT febep-akbln IS INITIAL ) ) .
*     Avispostition für die Akonto-Buchung
      avip-mandt      = avik-mandt.
      avip-bukrs      = avik-bukrs.
      avip-koart      = avik-koart.
      avip-konto      = avik-konto.
      avip-avsid      = avik-avsid.
* Note that customer posting is first customer identified
      avip-avspo      = xavip-avspo + 1.
      avip-abwko      = febep-avkon.
      avip-sfeld      = 'BELNR'.
      IF  bereich = '1'.
        avip-swert      = febep-ak1bl.                      "45b/slk
        avip-belnr      = febep-ak1bl.                      "45b/slk
      ELSE.                            "berich = '2'
        avip-swert      = febep-akbln.                      "45b/slk
        avip-belnr      = febep-akbln.                      "45b/slk
      ENDIF.
*           AVIP-WRBTR      = FEBEP-KWBTR.

      xavip = avip.
      APPEND xavip.
      CLEAR avip.
    ENDIF.                             "not febep-avkoa is initial
  ENDIF.                               "on-account posting

*reak-point.
* Disable Advice Creation area 1
  IF bereich = '1'.
    pyord_sel = 'X'.
  ENDIF.

* Disable Advice if not advice items exist
* READ TABLE XAVIP.
  READ TABLE xavip INDEX 1.
  IF sy-subrc NE 0.
    pyord_sel = 'X'.
  ENDIF.

*  end on-account enhancements
  IF pyord_sel <> 'X'.
    IF p_xnoadv IS INITIAL OR anwnd <> '0001'.              "note 452579
      rfradc-titl1 = text-019.
      rfradc-text1 = text-019.
      rfradc-xdark = 'X'.
      rfradc-xintn = 'X'.

      CALL FUNCTION 'REMADV_INSERT'
        EXPORTING
          i_avik            = avik
          i_rfradc          = rfradc
        IMPORTING
          e_rfradc          = rfradc
        TABLES
          t_avip            = xavip
          t_avir            = xavir
        EXCEPTIONS
          error             = 01
          no_number_entered = 02.

      CALL FUNCTION 'REMADV_SAVE_DB_ALL'
        EXPORTING
          i_dialog_update = 'X'.

      CLEAR:   xmesg, rc.
      REFRESH: xmesg.
      CALL FUNCTION 'MESSAGES_GIVE'
        TABLES
          t_mesg = xmesg.
      LOOP AT xmesg.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*        perform druck_avis_fehler.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
        PERFORM druck_avis_fehler CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
      ENDLOOP.
      LOOP AT xmesg WHERE msgty CA 'EA'.
        rc = 4.
      ENDLOOP.
      IF rc = 0.
        statist-avise = statist-avise + 1.
        febep-avkoa      = avik-koart.
        febep-avkon      = avik-konto.
        febep-avsid      = avik-avsid.
        UPDATE febep SET   avsid = avik-avsid
                           avkon = avik-konto
                           avkoa = avik-koart
                     WHERE kukey = febep-kukey
                       AND esnum = febep-esnum.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*        perform druck_avis_erzeugt.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
        PERFORM druck_avis_erzeugt CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
      ENDIF.
    ELSE. "no advice, but save the found data in FEBEP      "note 452579
      CLEAR l_account.                                      "note 452579
      IF avik-konto NE '*'.                                 "note 452579
        l_account = avik-konto.                             "note 452579
      ENDIF.                                                "note 452579
      UPDATE febep SET   avkon = l_account                  "note 452579
                         avkoa = avik-koart                 "note 452579
                   WHERE kukey = febep-kukey                "note 452579
                     AND esnum = febep-esnum.               "note 452579
    ENDIF.                                                  "note 452579
  ENDIF.

  REFRESH xavip.
  REFRESH xavir.
ENDFORM.                               " AVIS_ERZEUGEN

*eject
*---------------------------------------------------------------------*
*       FORM FB05_BSEG_akonto_haben.                                  *
*---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form fb05_bseg_akonto_haben.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM fb05_bseg_akonto_haben CHANGING xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  DATA: ftpost_lines TYPE i.

  IF NOT t049a-bsdbh IS INITIAL.
    bschl = t049a-bsdbh.
  ELSEIF xakon = 'X' AND               "on-account
         NOT ikofi-bscak IS INITIAL.
    bschl = ikofi-bscak.
  ELSE.
    bschl = '15'.
  ENDIF.

  DESCRIBE TABLE ftpost LINES ftpost_lines.
  READ TABLE ftpost INDEX ftpost_lines.
  ftpost-count = ftpost-count + 1.
  ftpost-stype = 'P'.

  PERFORM ftpost_field USING 'BSEG-BSCHL' bschl.          "Buchungsschlü

  PERFORM ftpost_field USING 'BSEG-HKONT' febep-avkon.    "Debitor

  WRITE febep-valut TO fvalue DD/MM/YYYY.
  IF febep-avkoa = 'S'.                "on-account
    PERFORM ftpost_field USING 'BSEG-VALUT' fvalue.      "on-account
  ELSE.                                "on-account
    PERFORM ftpost_field USING 'BSEG-ZFBDT' fvalue.      "Zahlfristbasis
  ENDIF.                               "on-account

  PERFORM betraege_to_ftpost.          "Beträge

* failed fb05 -> no allocation has to be forced by system
  IF NOT febep-zuonr IS INITIAL.
    PERFORM ftpost_field USING 'BSEG-ZUONR' febep-zuonr.  "OK - mpEURO
  ENDIF.

  PERFORM segmenttext_to_ftpost USING sgtxt.
  IF NOT sgtxt IS INITIAL.
    PERFORM ftpost_field USING 'BSEG-SGTXT' sgtxt.        "Text
  ENDIF.

  IF NOT febep-gsber IS INITIAL.
    IF ikofi-attr2 = '3' OR ikofi-attr2 = '8' OR
       ikofi-attr2 = '7' OR ikofi-attr2 = '2'.             "hw849894
      PERFORM ftpost_field USING 'BSEG-GSBER' febep-gsber.
    ELSE.
      PERFORM ftpost_field USING 'COBL-GSBER' febep-gsber. "Geschäfts
    ENDIF.
  ENDIF.

*Kontierungsblock nur bei Sachkonten                       "hw358959
  IF NOT febep-prctr IS INITIAL AND ikofi-attr2 NE '8'.     "hw358959
    PERFORM ftpost_field USING 'COBL-PRCTR' febep-prctr.    "hw358959
  ENDIF.                                                    "hw358959

  IF NOT febep-kostl IS INITIAL AND ikofi-attr2 NE '8'.     "hw358959
    PERFORM ftpost_field USING 'COBL-KOSTL' febep-kostl.    "hw358959
  ENDIF.                                                    "hw358959
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*  perform druck_akonto.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
  PERFORM druck_akonto CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
ENDFORM.                    "FB05_BSEG_AKONTO_HABEN

*&---------------------------------------------------------------------*
*&      Form  FB05_ERROR_HANDLING
*&---------------------------------------------------------------------*
*       Routine wird aufgerufen, wenn FB05 nicht gebucht werden konnte *
*       - FB05 erneut mit XFIFO                                        *
*       - Akonto-Buchung und Avis erzeugen                             *
*       - oder nur Avis erzeugen                                       *
*----------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form fb05_error_handling.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM fb05_error_handling CHANGING xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  IF  febko-anwnd = '0003'
  AND NOT febep-avkon IS INITIAL
  AND NOT febep-avkon+0(1) = '*'.
*------- nur bei Lockbox, falls Kunde identifizert werden konnte -------
*------- Mißbrauch von TXTVV zur Übergabe des Algorithmus        -------
    postalgo = febep-txtvv+1(3).
    CASE postalgo.
      WHEN '001'.
*     akonto-buchung
        IF febep-akbln IS INITIAL.
*         perform fb01_bseg_akonto_haben.
*         tcode = 'FB01'.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*          perform fb05_bseg_akonto_haben.         "Perform on account
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
          PERFORM fb05_bseg_akonto_haben CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
          tcode = 'FB05'.                                   "via FB05
          xakon = 'X'.
          CLEAR ftclear.
          REFRESH ftclear.
          LOOP AT xfebcl WHERE kukey = febep-kukey          "hw592531
                 AND esnum = febep-esnum                    "hw592531
                 AND selfd = 'FB'.                          "hw592531
            PERFORM append_xfebcl_to_ftclear.               "hw592531
          ENDLOOP.                                          "hw592531
          x_error_handling = 'X'.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*          perform fb05_posting_aufrufen using 'X'.  "end modifications
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
          PERFORM fb05_posting_aufrufen USING 'X'
                                        CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
*         perform fb01_posting_aufrufen.
          PERFORM add_on_acc_doc_to_remadv.
        ENDIF.
      WHEN '002'.
*     zahlungsdifferenz verbuchen
        PERFORM generate_difference_line_item.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*        perform posting_interface_clearing.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
        PERFORM posting_interface_clearing CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
      WHEN '003'.
        PERFORM fb05_xfifo.
*     nach alter verteilen
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*        perform posting_interface_clearing.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
        PERFORM posting_interface_clearing CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
      WHEN OTHERS.
        statist-error = statist-error + 1.
    ENDCASE.
    PERFORM save_message_for_lbox_log USING 3.
  ELSE.
    statist-error = statist-error + 1.
  ENDIF.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*  perform avis_erzeugen.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
  PERFORM avis_erzeugen CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
ENDFORM.                               " FB05_ERROR_HANDLING



*eject
*&---------------------------------------------------------------------*
*&      Form  DRUCK_MESSAGE.
*&---------------------------------------------------------------------*
*       Druck die Message vom Posting_Interface ins Protokoll          *
*----------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form druck_message.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM druck_message CHANGING xt_fb01 LIKE gt_fb01_1.
  field-symbols: <ls_fb01> TYPE fagl_acc_s_rfebbu00_alv.
  DATA: lv_index TYPE sy-tabix.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  CLEAR char10.
  CLEAR char300.
  CLEAR t100.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t100
*          WHERE sprsl = sy-langu
*            AND arbgb = msgid
*            AND msgnr = msgno.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t100
          WHERE sprsl = sy-langu
            AND arbgb = msgid
            AND msgnr = msgno ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF subrc NE 0.
    if not msgtxt is initial.                              "hw818056
      msgid = 'FB'.                                        "hw818056
      msgno = '420'.                                       "hw818056
      msgv1 = msgtxt.                                      "hw818056
      CLEAR: msgv2, msgv3, msgv4.                          "hw818056
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM t100                            "hw818056
*              WHERE sprsl = sy-langu                       "hw818056
*                AND arbgb = msgid                          "hw818056
*                AND msgnr = msgno.                         
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM t100                            "hw818056
              WHERE sprsl = sy-langu                       "hw818056
                AND arbgb = msgid                          "hw818056
                AND msgnr = msgno ORDER BY PRIMARY KEY.                         

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01"hw818056
    else.                                                  "hw818056
      char300 = text-112.
      REPLACE '&' WITH msgid INTO char300.
      REPLACE '&' WITH msgno INTO char300.
      CONDENSE char300.
      char10 = text-113.
    endif.                                                 "hw818056
  ENDIF.

  char300+30   = t100-text.
  REPLACE '&1'   WITH '&'   INTO char300.
  REPLACE '&2'   WITH '&'   INTO char300.
  REPLACE '&3'   WITH '&'   INTO char300.
  REPLACE '&4'   WITH '&'   INTO char300.
  REPLACE '&V1&' WITH '&'   INTO char300.
  REPLACE '&V2&' WITH '&'   INTO char300.
  REPLACE '&V3&' WITH '&'   INTO char300.
  REPLACE '&V4&' WITH '&'   INTO char300.
  REPLACE '&v1&' WITH '&'   INTO char300.
  REPLACE '&v2&' WITH '&'   INTO char300.
  REPLACE '&v3&' WITH '&'   INTO char300.
  REPLACE '&v4&' WITH '&'   INTO char300.
  REPLACE '&' WITH msgv1 INTO char300.
  REPLACE '&' WITH msgv2 INTO char300.
  REPLACE '&' WITH msgv3 INTO char300.
  REPLACE '&' WITH msgv4 INTO char300.
  CONDENSE char300.
***********************************************************************
*    Begin of comment                           C5053248
***********************************************************************
*  write: /01      sy-vline,
*          04(8)   char10,
*          14(110) char300,
*          132     sy-vline.
***********************************************************************
**    End of comment                            C5053248
***********************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
  CLEAR lv_index.
  DESCRIBE TABLE xt_fb01 LINES lv_index.
  IF lv_index ne 0.
    READ TABLE xt_fb01 assigning <ls_fb01> INDEX lv_index.
    if not <ls_fb01>-msg is initial.
      append initial line to xt_fb01 assigning <ls_fb01>.
      <ls_fb01>-bername   = gs_header-bername.             "n937482
      <ls_fb01>-bankl     = gs_header-bankl.
      <ls_fb01>-ktonr     = gs_header-ktonr.
      <ls_fb01>-aznum     = gs_header-aznum.
      <ls_fb01>-mappe     = gs_header-mappe.
    endif.
    CONCATENATE char10 char300 INTO <ls_fb01>-msg SEPARATED BY space.
  ELSE.
    append initial line to xt_fb01 assigning <ls_fb01>.
    <ls_fb01>-bername   = gs_header-bername.             "n937482
    <ls_fb01>-bankl     = gs_header-bankl.
    <ls_fb01>-ktonr     = gs_header-ktonr.
    <ls_fb01>-aznum     = gs_header-aznum.
    <ls_fb01>-mappe     = gs_header-mappe.
    CONCATENATE char10 char300 INTO <ls_fb01>-msg SEPARATED BY space.
    <ls_fb01>-kukey     = febep-kukey.
    <ls_fb01>-esnum     = febep-esnum.
    <ls_fb01>-vgint     = febep-vgint.
    <ls_fb01>-vgext     = febep-vgext.
    <ls_fb01>-currency  = febep-kwaer.
    <ls_fb01>-amount    = febep-kwbtr.
  ENDIF.

************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
ENDFORM.                               " WRITE_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  DRUCK_AKONTO
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form druck_akonto.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM druck_akonto CHANGING xt_fb01 LIKE gt_fb01_1.
  DATA: lv_index TYPE sy-tabix.
  DATA: ls_fb01 TYPE fagl_acc_s_rfebbu00_alv.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  DATA: char5(5) TYPE c.               "INSERT - mpEURO
  DATA: char27(27) TYPE c.             "INSERT - mpEURO

  IF p_bupro = 'X'.
    char132 = text-110.
*   replace '&' with febep-knrza into char132.      "Want on-accnt cust
    REPLACE '&' WITH febep-avkon INTO char132.
*   replace '&' with '15'        into char132.
    REPLACE '&' WITH  bschl      INTO char132.
    CONDENSE char132.                  "INSERT - mpEURO

    IF febep-fwbtr IS INITIAL OR bereich = '1'.         "INSERT - mpEURO
*   no original transaction currency provided or posting area = 1.
      WRITE febep-kwbtr TO char20 CURRENCY febep-kwaer.    "ok - mpEURO
      char5 = febep-kwaer.             "INSERT - mpEURO
      CONCATENATE char5 char20 INTO char27             "INSERT - mpEURO
                               SEPARATED BY space.     "INSERT - mpEURO
    ELSE.
*   original transaction currency provided and posting area = 2.
      WRITE febep-fwbtr TO char20 CURRENCY febep-fwaer."INSERT - mpEURO
      char5 = febep-fwaer.             "INSERT - mpEURO
      CONCATENATE char5 char20 INTO char27             "INSERT - mpEURO
                               SEPARATED BY space.     "INSERT - mpEURO
    ENDIF.                             "INSERT - mpEURO

    REPLACE '&' WITH char27      INTO char132.
    CONDENSE char132.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    write: /01      sy-vline,
*            14(110) char132,
*            132     sy-vline.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    CLEAR lv_index.
    DESCRIBE TABLE xt_fb01 LINES lv_index.
    READ TABLE xt_fb01 INTO ls_fb01 INDEX lv_index.
    MOVE char132 TO ls_fb01-msg.
*Start changes after review C5056169 19 Jul 2004
*    MODIFY xt_fb01 FROM ls_fb01 INDEX lv_index.
    Append ls_fb01 to xt_fb01.
*End changes after review C5056169 19 Jul 2004
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  ENDIF.

ENDFORM.                               " DRUCK_AKONTO

*&---------------------------------------------------------------------*
*&      Form  DRUCK_AVIS_ERZEUGT
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form druck_avis_erzeugt.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM druck_avis_erzeugt CHANGING xt_fb01 LIKE gt_fb01_1.
  DATA: ls_fb01 TYPE fagl_acc_s_rfebbu00_alv.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  IF p_bupro = 'X'.
    char132 = text-111.
    REPLACE '&' WITH avik-koart INTO char132.
    REPLACE '&' WITH avik-konto INTO char132.
    REPLACE '&' WITH avik-avsid INTO char132.
    CONDENSE char132.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    write: /01      sy-vline,
*            14(110) char132,
*            132     sy-vline.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    CLEAR ls_fb01.
    ls_fb01-msg       = char132.
    ls_fb01-bername   = bername.

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
    ls_fb01-bankl  = gs_header-bankl.
    ls_fb01-ktonr  = gs_header-ktonr.
    ls_fb01-aznum  = gs_header-aznum.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*
    ls_fb01-kukey     = febko-kukey.                "n853370
    ls_fb01-mappe     = mappe.

    APPEND ls_fb01 TO xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  ENDIF.
ENDFORM.                               " DRUCK_AVIS_ERZEUGT

*&---------------------------------------------------------------------*
*&      Form  DRUCK_AVIS_FTCLEAR
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
FORM druck_avis_ftclear CHANGING xt_fb01 LIKE gt_fb01_1.
  DATA: ls_fb01 TYPE fagl_acc_s_rfebbu00_alv.
  DATA: lv_index TYPE sy-tabix.

  IF p_bupro = 'X'.

    CLEAR lv_index.
    IF lv_index ne 0.                                       "n956279
      DESCRIBE TABLE xt_fb01 LINES lv_index.
      READ TABLE xt_fb01 INTO ls_fb01 INDEX lv_index.
      CONCATENATE febep-avkon text-114  febep-avsid
                    INTO ls_fb01-msg SEPARATED BY space.
    endif.

    IF lv_index eq 0.                                       "n937482
      ls_fb01-bername   = gs_header-bername.
      ls_fb01-bankl     = gs_header-bankl.
      ls_fb01-ktonr     = gs_header-ktonr.
      ls_fb01-aznum     = gs_header-aznum.
      ls_fb01-mappe     = gs_header-mappe.

      ls_fb01-kukey     = febep-kukey.
      ls_fb01-esnum     = febep-esnum.
      ls_fb01-vgint     = febep-vgint.
      ls_fb01-vgext     = febep-vgext.
      ls_fb01-currency  = febep-kwaer.
      ls_fb01-amount    = febep-kwbtr.

      APPEND ls_fb01 to xt_fb01.
    ELSE.
      MODIFY xt_fb01 FROM ls_fb01 INDEX lv_index.
    ENDIF.
  ENDIF.
ENDFORM.                               " DRUCK_AVIS_FTCLEAR

*eject
*&---------------------------------------------------------------------*
*&      Form  INIT_ACCOUNT_DETERMINATION
*&---------------------------------------------------------------------*
*       Kontenfindung für alle Anwendungen außer Lockbox               *
*----------------------------------------------------------------------*
FORM init_account_determination.
  PERFORM check_vgint.

  IF NOT febep-vgint IS INITIAL.
    PERFORM account_determination.
    CASE sy-subrc.
      WHEN 0.
*         alles ok.
        buchen = true.
        IF ikofi-komk1 NE space        "compression
           OR ikofi-komk2 NE space.
          komk = 'X'.
        ENDIF.
        IF (    ikofi-attr2 = '1'
             OR ikofi-attr2 = '2'
             OR ikofi-attr2 = '3' )
        AND (   ikofi-sakn1 IS INITIAL
             OR ikofi-sakn2 IS INITIAL ).
*           Konto wird nicht über Kontenfindung gefunden, sondern über
*           FEBCL
          PERFORM febcl_account_determination.
        ENDIF.
* to clear an on_account posting, must alter accnt determination
* voided                                                   "hw638124
*        if pa_xakon = 'X'                                   "45b
*          and bereich = '1'.                                "45b
*          if febep-epvoz = 'H'.                             "45b
*            ikofi-sakn1 = ikofi-sakn2.                      "45b
*          else.                                             "45b
*            ikofi-sakn2 = ikofi-sakn1.                      "45b
*          endif.                                            "45b
*        endif.                                              "45b

      WHEN 1.
        CLEAR vb_error.
        vb_error-anwnd = febko-anwnd.
        vb_error-absnd = febko-absnd.
        vb_error-azidt = febko-azidt.
        vb_error-ktonr = febko-ktonr.
        vb_error-aznum = febko-aznum.
        vb_error-esnum = febep-esnum.
        vb_error-buber = bereich.
        vb_error-zeile = text-030.
        APPEND vb_error.
        statist-error = statist-error + 1.
      WHEN 2.
        CLEAR vb_error.
        vb_error-anwnd = febko-anwnd.
        vb_error-absnd = febko-absnd.
        vb_error-azidt = febko-azidt.
        vb_error-ktonr = febko-ktonr.
        vb_error-aznum = febko-aznum.
        vb_error-esnum = febep-esnum.
        vb_error-buber = bereich.
        vb_error-zeile = text-031.
        APPEND vb_error.
        statist-error = statist-error + 1.
        MESSAGE i766 WITH febep-kukey febep-esnum.
      WHEN 4.
*         Zum Vorgang x im Bereich y soll nichts gebucht werden
*-------- Einzelposten auf verbucht setzen --------------------------
        PERFORM nothing_to_post.
      WHEN 5.
*         Kontosymbol konnte nicht ersetzt werden
        CLEAR vb_error.
        vb_error-anwnd = febko-anwnd.
        vb_error-absnd = febko-absnd.
        vb_error-azidt = febko-azidt.
        vb_error-ktonr = febko-ktonr.
        vb_error-aznum = febko-aznum.
        vb_error-esnum = febep-esnum.
        vb_error-buber = bereich.
        vb_error-zeile = text-032.
        REPLACE '&' WITH febep-vgint INTO vb_error-zeile.
        APPEND vb_error.
        statist-error = statist-error + 1.

      WHEN OTHERS.
        statist-error = statist-error + 1.
        MESSAGE i768 WITH febep-kukey  febep-esnum.
    ENDCASE.
  ELSE.
*      Buchung nicht ausführbar, da in T028G kein Eintrag
    CLEAR vb_error.
    vb_error-anwnd = febko-anwnd.
    vb_error-absnd = febko-absnd.
    vb_error-azidt = febko-azidt.
    vb_error-ktonr = febko-ktonr.
    vb_error-aznum = febko-aznum.
    vb_error-esnum = febep-esnum.
    vb_error-buber = bereich.
    vb_error-zeile = text-033.
    REPLACE '&' WITH febko-vgtyp INTO vb_error-zeile.
    REPLACE '&' WITH febep-vgext INTO vb_error-zeile.
    REPLACE '&' WITH vozpm       INTO vb_error-zeile.
    APPEND vb_error.
    statist-error = statist-error + 1.
  ENDIF.
ENDFORM.                               " INIT_ACCOUNT_DETERMINATION

*eject
*&---------------------------------------------------------------------*
*&      Form  LOCKBOX_ACCOUNT_DETERMINATION
*&---------------------------------------------------------------------*
*       Kontenfindung für Lockbox
*       Struktur IKOFI füllen zur Simulation der normalen Kontenfindung
**---------------------------------------------------------------------*
FORM lockbox_account_determination.
  DATA: desti LIKE flb05-dh006.
  DATA: orign LIKE flb05-dh007.

  desti = febko-absnd+0(10).
  orign = febko-absnd+11(10).


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t049a WHERE desti = desti
*                               AND orign = orign.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t049a WHERE desti = desti
                               AND orign = orign ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc NE 0.
    MESSAGE a601(fv) WITH desti orign.
  ENDIF.

  IF NOT febko-bktoa IS INITIAL.                            "46b
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM t049b WHERE verfa = febko-bktoa
*                                 AND formt = febko-vgtyp.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM t049b WHERE verfa = febko-bktoa
                                 AND formt = febko-vgtyp ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM t049b WHERE verfa = 'LOCKBOX'
*                                 AND formt = febko-vgtyp.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM t049b WHERE verfa = 'LOCKBOX'
                                 AND formt = febko-vgtyp ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.

  CLEAR ikofi.
  CASE bereich.
    WHEN '1'.
      IF t049b-fb01b = 'X'.
        ikofi-bsch1 = t049a-bssks.     " Buchungsschlüssel Soll
        ikofi-sakn1 = t049a-bkkto.     " Sachkonto Soll
        ikofi-bsch2 = t049a-bsskh.     " Buchungsschlüssel Habe
        ikofi-sakn2 = t049a-sekto.     " Sachkonto Haben
        ikofi-attr1 = t049a-babnk.     " Belegart BankBuchung
        ikofi-attr2 = '1'.             "Buchen Sachkonto Soll
        buchen      = true.
        IF t049b-fb1kz = '2'.
*         Komprimierung der Bankzeile
          ikofi-komk1 = 'X'.
          komk        = 'X'.
        ELSEIF t049b-fb1kz = '3'.                           "46a
*         Compression per batch                      "46a
          ikofi-komk1 = 'X'.                                "46a
          komk        = 'X'.                                "46a
          komkb       = 'X'.                                "46a
        ENDIF.
      ELSE.
        PERFORM nothing_to_post.
      ENDIF.
    WHEN '2'.
      IF t049b-fb05b = 'X'.
        ikofi-bsch1 = t049a-bssks.     " Buchungsschlüssel Soll
        ikofi-sakn1 = t049a-sekto.     " Sachkonto Soll
        ikofi-attr1 = t049a-badeb.     " Belegart DebiBuchung
        ikofi-attr2 = '8'.             "Buchen Sachkonto Soll
        buchen      = true.
        CLEAR xakon.                   "clear on-account flag
      ELSE.
        PERFORM nothing_to_post.
      ENDIF.
  ENDCASE.


*     IKOFI-ATTR1.    "Belegart
*     IKOFI-ATTR2.    "Buchungsart
*     IKOFI-SAKN1     " Sachkonto Soll
*     IKOFI-BSCH1.    " Buchungsschlüssel Soll
*     IKOFI-SAKN2     " Sachkonto Haben
*     IKOFI-BSCH2.    " Buchungsschlüssel Haben
ENDFORM.                               " LOCKBOX_ACCOUNT_DETERMINATION


*eject
*&---------------------------------------------------------------------*
*&      Form  DRUCK_AVIS_FEHLER
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*form druck_avis_fehler.
*  write: /01      sy-vline,
*          14(110) xmesg,
*          132     sy-vline.
FORM druck_avis_fehler CHANGING xt_fb01 LIKE gt_fb01_1.
  DATA: ls_fb01 TYPE fagl_acc_s_rfebbu00_alv.
  DATA: lv_index TYPE sy-tabix.
  CLEAR lv_index.
  DESCRIBE TABLE xt_fb01 LINES lv_index.
  READ TABLE xt_fb01 INTO ls_fb01 INDEX lv_index.
  ls_fb01-msg = xmesg.
  IF lv_index eq 0.                                       "n937482
    ls_fb01-bername   = gs_header-bername.
    ls_fb01-bankl     = gs_header-bankl.
    ls_fb01-ktonr     = gs_header-ktonr.
    ls_fb01-aznum     = gs_header-aznum.
    ls_fb01-mappe     = gs_header-mappe.

    ls_fb01-kukey     = febep-kukey.
    ls_fb01-esnum     = febep-esnum.
    ls_fb01-vgint     = febep-vgint.
    ls_fb01-vgext     = febep-vgext.
    ls_fb01-currency  = febep-kwaer.
    ls_fb01-amount    = febep-kwbtr.

    APPEND ls_fb01 to xt_fb01.
  ELSE.
    MODIFY xt_fb01 FROM ls_fb01 INDEX lv_index.
  ENDIF.

ENDFORM.                               " DRUCK_AVIS_FEHLER

*eject
*&---------------------------------------------------------------------*
*&      Form  FB05_XFIFO
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
FORM fb05_xfifo.
  LOOP AT ftclear WHERE NOT agkon IS INITIAL.
    ftclear-xfifo = 'X'.
    CLEAR ftclear-avsid.
    MODIFY ftclear.
    EXIT.
  ENDLOOP.

  LOOP AT ftclear WHERE xfifo IS INITIAL.
    DELETE ftclear.
  ENDLOOP.
ENDFORM.                               " FB05_XFIFO

*&---------------------------------------------------------------------*
*&      Form  NOTHING_TO_POST
*&---------------------------------------------------------------------*
*       Routine wird dann aufgerufen, wenn nichts gebucht werden soll  *
*----------------------------------------------------------------------*
FORM nothing_to_post.
  CLEAR xblntab.
  PERFORM update_febep_status_not_post.
  statist-notpo = statist-notpo + 1.
ENDFORM.                               " NOTHING_TO_POST


*eject
*&---------------------------------------------------------------------*
*&      Form  FINANZDISPO_AVISE_ARCHIVIEREN
*&---------------------------------------------------------------------*
*       Falls Avise für die Finanzdisposition erzeugt wurden.          *
*       müssen diese wieder archiviert werden                          *
*       Deshalb wird dann wenn die Buchungen für die Bankbuchhaltung   *
*       erzeugt werden am Begin der Mappe die Transaktion FF/3         *
*       vorangestellt.                                                 *
*       Die Routine wird unter folgenden Bedingungen durchlaufen:      *
*        - Batch Input                                                 *
*        - Bereich = 1 (Bankbuchhaltung)                               *
*        - nur einmal pro Kontoauszug (Kukey)                          *
*        - es wurden Finanzdispoavise erzeugt                          *
*----------------------------------------------------------------------*
FORM check_dispo_avise_archivieren.
  DATA: austg(10) TYPE c.


  CHECK febko-xfdis = 'X'.
  CHECK function    = 'B'.
  CHECK bereich     = '1'.
  CHECK fdis_arch   = false.

  IF open = false.
    PERFORM posting_interface_start.
  ENDIF.

  PERFORM bdc_dynpro USING 'SAPMF40F' '0100'.
  PERFORM bdc_field  USING 'T012K-BUKRS' febko-bukrs.
  PERFORM bdc_field  USING 'FDES-DSART'  febko-dsart.
  PERFORM bdc_field  USING 'T012K-HBKID' febko-hbkid.
  PERFORM bdc_field  USING 'T012K-HKTID' febko-hktid.
  PERFORM bdc_field  USING 'FDES-AUSNR'  febko-aznum.
*  WRITE FEBKO-AZNUM TO AUSTG DD/MM/YYYY.            "delete note 178633
  WRITE febko-azdat TO austg DD/MM/YYYY.             "insert note 178633
  PERFORM bdc_field  USING 'FDES-AUSTG'  austg.

  CALL FUNCTION 'BDC_INSERT'
    EXPORTING
      tcode     = 'FF/3'
    TABLES
      dynprotab = bdcdata.
  REFRESH bdcdata.
  fdis_arch   = true.
ENDFORM.                               " FINANZDISPO_AVISE_ARCHIVIEREN


*eject
*---------------------------------------------------------------*
*  Batchinput: Start neues Dynpro                               *
*---------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.

  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.

ENDFORM.                    "BDC_DYNPRO

*---------------------------------------------------------------*
*  Batchinput: Feld hinzufügen                                  *
*---------------------------------------------------------------*
FORM bdc_field  USING fnam fval.

  CLEAR bdcdata.
  bdcdata-fnam     = fnam.
  bdcdata-fval     = fval.
  APPEND bdcdata.

ENDFORM.                    "BDC_FIELD

*eject
*&---------------------------------------------------------------------*
*&      Form  CHECK_VGINT
*&---------------------------------------------------------------------*
*       Prüfen, ob vgint vorhanden ist, falls nicht wird               *
*       T028G nochmal nachgelesen und FEBEP-VGINT gefüllt
*----------------------------------------------------------------------*
FORM check_vgint.
  IF febep-vgint IS INITIAL.
*     erneuter Versuch den Internern Vorgang aus T028G zu lesen
    IF febep-epvoz = 'H'
    OR febep-vozei = 'C'
    OR febep-vozei = 'RD'.
      vozpm = '+'.
    ELSE.
      vozpm = '-'.
    ENDIF.

    CALL FUNCTION 'GET_POSTING_RULE'
         EXPORTING
*             I_VORGC         =
*             I_BUTXT         =
*             I_TEXTS         =
              i_vozpm         = vozpm
              i_vgtyp         = febko-vgtyp
              i_vgext         = febep-vgext
*             I_USING_DEFAULT = 'X'
         IMPORTING
              e_vgext         = febep-vgext
              e_vgint         = febep-vgint
              e_intag         = febep-intag
*             E_VGSAP         =
*             E_PFORM         =
*             E_USING_DEFAULT =
         EXCEPTIONS
              not_found       = 1
              input_wrong     = 2
              OTHERS          = 3.
    IF sy-subrc <> 0.
    ENDIF.
  ELSE.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM t028d WHERE vgint = febep-vgint.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM t028d WHERE vgint = febep-vgint ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc NE 0.
      MESSAGE e750 WITH 'T028D' febep-vgint.
    ENDIF.
  ENDIF.

ENDFORM.                               " CHECK_VGINT

*&---------------------------------------------------------------------*
*&      Form  CHECK_IF_KOMPRIMIERUNG
*&---------------------------------------------------------------------*
*       Kontenfindung anstoßen, um herauszufinden, ob komprimiert      *
*       wird, falls ja XKOMP = 'X' setzen
*----------------------------------------------------------------------*
FORM check_if_komprimierung.

  komk  = space.
  komkb = space.                                            "46a
  CASE anwnd.
    WHEN 0003.
      PERFORM lockbox_account_determination.
    WHEN OTHERS.
      PERFORM check_vgint.
      PERFORM account_determination.
  ENDCASE.
  IF sy-subrc = 0.
    buchen = true.

    IF ikofi-komk1 NE space
    OR ikofi-komk2 NE space.
      komk  = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                               " CHECK_IF_KOMPRIMIERUNG

*&---------------------------------------------------------------------*
*&      Form  ADD_ON_ACC_DOC_TO_REMADV
*&---------------------------------------------------------------------*
*       add the document number from the posting on account            *
*       to the remittance advice                                       *
*----------------------------------------------------------------------*
FORM add_on_acc_doc_to_remadv.
  DATA: i_xacon LIKE avip-xacon VALUE 'X'.
  DATA: i_wrbtr LIKE avip-wrbtr.
  DATA: i_akbln LIKE avip-belnr.       "<<< HP
  DATA: i_avsid LIKE avik-avsid.       "<<< HP

  IF r_csnum IS INITIAL.               "<<< HP
    i_akbln = febep-akbln.             "<<< HP
    i_avsid = febep-avsid.             "<<< HP
  ELSE.                                "<<< HP
    LOOP AT xfebcl WHERE kukey = febep-kukey AND                "<<< HP
                         esnum = febep-esnum AND                "<<< HP
                         csnum = r_csnum.                       "<<< HP
      i_akbln = xfebcl-selbis+10.      "<<< HP
      i_avsid = xfebcl-selvon.         "<<< HP
    ENDLOOP.                           "<<< HP
  ENDIF.                               "<<< HP


* CHECK NOT FEBEP-AKBLN IS INITIAL.                    "<<< HP
  CHECK NOT i_akbln IS INITIAL.        "<<< HP
  CHECK NOT i_avsid IS INITIAL.                             "hw453251

* total sum of advice positions were posted on account
  REFRESH xavip.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM avik
*                WHERE bukrs = febko-bukrs
*                  AND koart = febep-avkoa
*                  AND konto = febep-avkon
**                 AND AVSID = FEBEP-AVSID.            "<<< HP
*                  AND avsid = i_avsid. 
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM avik
                WHERE bukrs = febko-bukrs
                  AND koart = febep-avkoa
                  AND konto = febep-avkon
*                 AND AVSID = FEBEP-AVSID.            "<<< HP
                  AND avsid = i_avsid ORDER BY PRIMARY KEY. 

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01"<<< HP

  IF febep-fwaer IS INITIAL OR bereich = '1' .          "INSERT - mpEURO
*   no original transaction currency provided or posting area = 1.
    i_wrbtr = febep-kwbtr.             "INSERT - mpEURO
  ELSE.                                "INSERT - mpEURO
*   original transaction currency provided and posting area = 2.
    i_wrbtr = febep-fwbtr.             "INSERT - mpEURO
  ENDIF.                               "INSERT - mpEURO

  IF febep-epvoz = 'H'.                "INSERT - mpEURO
* incmg payment was posted on account (credit posting)
* added corresponding position amount in advice must be negative
    IF i_wrbtr > 0.                    "INSERT - mpEURO
      i_wrbtr = i_wrbtr * -1.          "INSERT - mpEURO
    ENDIF.                             "INSERT - mpEURO
  ELSE.                                "INSERT - mpEURO
* outgng paymnt/direct debit was posted on account (debit posting)
* added corresponding position amount in advice must be positive
    i_wrbtr = ABS( i_wrbtr ).          "INSERT - mpEURO
  ENDIF.                               "INSERT - mpEURO

  CALL FUNCTION 'REMADV_APPEND_POSITION'
       EXPORTING
            i_avik       = avik
*           I_BELNR      = FEBEP-AKBLN                  "<<< HP
            i_belnr      = i_akbln     "<<< HP
            i_xacon      = i_xacon
            i_wrbtr      = i_wrbtr
       EXCEPTIONS
            locked       = 01
            no_authority = 02.

* IF SY-SUBRC NE 0.
*   WRITE: 'error at REMADV_APPEND_POSITION'.
* ELSE.
*   WRITE: 'successful REMADV_APPEND_POSITION'.
* ENDIF.

  CALL FUNCTION 'REMADV_SAVE_DB_ALL'
    EXPORTING
      i_dialog_update = 'X'.


ENDFORM.                               " ADD_ON_ACC_DOC_TO_REMADV

*eject
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE.
*&---------------------------------------------------------------------*
*       Top-of-page für Kontoauzug und Scheckreinreicher       *
*----------------------------------------------------------------------*
*form top_of_page.
**
*  if p_bupro = 'X'.
*    if printflag = 'P'.
***     Felder für Batch-Heading füllen
*      move space to        bhdgd-line1.
*      move space to        bhdgd-line2.
*      move febko-bukrs to  bhdgd-bukrs.
*      move sy-uname to     bhdgd-uname.
*      move sy-repid to     bhdgd-repid.
*      case anwnd.
*        when '0001'.
*          move text-007 to bhdgd-line1.
*        when '0002'.
*          move text-008 to bhdgd-line1.
*        when '0003'.
*          move text-009 to bhdgd-line1.
*        when others.
*          move sy-title to bhdgd-line1.
*      endcase.
*      if function = 'C'.
*        move text-038      to bhdgd-line2.
*      else.
*        move text-039 to char132.
*        replace '&' with mappe into char132.
*        move char132+0(50) to bhdgd-line2.
*      endif.
*      bhdgd-inifl = '0'.
**     Batch-Heading-Routine aufrufen
*      perform batch-heading(rsbtchh0).
*      write: /01 sy-vline, 02 sy-uline(130), 132 sy-vline.
*
*
*      if testl = 'X'.
*        write: /1 sy-vline, 2(130) text-102, 132 sy-vline.
*        write: /1 sy-vline, 2(130) text-103, 132 sy-vline.
*        write: /1 sy-vline, 2(130) text-102, 132 sy-vline.
*      endif.
*
*      if bereich = '1'.
*        write: /1    sy-vline,
*                2(8) text-010,
*               11(25) text-011,
*               132   sy-vline.
*      elseif bereich = '2'.
*        write: /1    sy-vline,
*                2(8) text-010,
*               11(25) text-012,
*               132   sy-vline.
*      endif.
*
*      loop at xfebvw where anwnd = febko-anwnd
*                       and absnd = febko-absnd
*                       and azidt = febko-azidt.
*        exit.
*      endloop.
*      write: /1     sy-vline,
*              2(08) text-013,
*             11(15) xfebvw-bankl,
*             35(60) xfebvw-banka,                           "46A TT
*             132    sy-vline.
*      write: /1     sy-vline,
*              2(08) text-014,
*             11(18) febko-ktonr,                            "46A TT
*             35(10) text-015,                               "46A TT
*             46(05) febko-aznum,                            "46A TT
*             62(14) text-017,                               "46A TT
*             77(08) febko-kukey,                            "46A TT
*             132    sy-vline.
*      write: /01 sy-vline, 02 sy-uline(130), 132 sy-vline.
*      write: /1 sy-vline, 2(130) text-003, 132 sy-vline.
*    elseif printflag = 'E'.
**   Fehlerprotokoll
**     Felder für Batch-Heading füllen
*      move space to        bhdgd-line1.
*      move space to        bhdgd-line2.
*      move febko-bukrs to  bhdgd-bukrs.
*      move sy-uname to     bhdgd-uname.
*      move sy-repid to     bhdgd-repid.
*      if anwnd = '0001'.
*        move text-007 to bhdgd-line1.
*      elseif anwnd = '0002'.
*        move text-008 to bhdgd-line1.
*      else.
*        move sy-title to bhdgd-line1.
*      endif.
*      move text-040 to bhdgd-line2.
*      bhdgd-inifl = '0'.
**     Batch-Heading-Routine aufrufen
*      perform batch-heading(rsbtchh0).
*      write: /01 sy-vline, 02 sy-uline(130), 132 sy-vline.
*
*      if testl = 'X'.
*        write: /1 sy-vline, 2(130) text-102, 132 sy-vline.
*        write: /1 sy-vline, 2(130) text-103, 132 sy-vline.
*        write: /1 sy-vline, 2(130) text-102, 132 sy-vline.
*      endif.
*
*      if bereich = '1'.
*        write: /1    sy-vline,
*                2(8) text-010,
*               11(25) text-011,
*               132   sy-vline.
*      elseif bereich = '2'.
*        write: /1    sy-vline,
*                2(8) text-010,
*               11(25) text-012,
*               132   sy-vline.
*      endif.
*      loop at xfebvw where anwnd = vb_error-anwnd
*                       and absnd = vb_error-absnd
*                       and azidt = vb_error-azidt.
*        exit.
*      endloop.
*      write: /1    sy-vline,
*              2(08) text-013,
*             11(15) xfebvw-bankl,
*             35(60) xfebvw-banka,                           "46A TT
*            132     sy-vline.
*      write: /1    sy-vline,
*              2(08) text-014,
*             11(18) vb_error-ktonr,                         "46A TT
*             35(10) text-015,                               "46A TT
*             46(15) vb_error-aznum,                         "46A TT
*            132     sy-vline.
*      write: /01 sy-vline, 02 sy-uline(130), 132 sy-vline.
*      write: /1 sy-vline, 2 text-006, 132 sy-vline.
*      write: /01 sy-vline, 02 sy-uline(130), 132 sy-vline.
*    endif.
*
*  endif.
*
*  if printflag = 'S' and p_statik = 'X'.
** Seitenkopf für Statistik
**   Felder für Batch-Heading füllen
*    move space to        bhdgd-line1.
*    move space to        bhdgd-line2.
*    move febko-bukrs to  bhdgd-bukrs.
*    move sy-uname to     bhdgd-uname.
*    move sy-repid to     bhdgd-repid.
*    case anwnd.
*      when '0001'.
*        move text-007 to bhdgd-line1.
*      when '0002'.
*        move text-008 to bhdgd-line1.
*      when '0003'.
*        move text-009 to bhdgd-line1.
*      when others.
*        move sy-title to bhdgd-line1.
*    endcase.
*    move text-041 to bhdgd-line2.
*    bhdgd-inifl = '0'.
**   Batch-Heading-Routine aufrufen
*    perform batch-heading(rsbtchh0).
*
*    if testl = 'X'.
*      write: /1 sy-vline, 2(130) text-102, 132 sy-vline.
*      write: /1 sy-vline, 2(130) text-103, 132 sy-vline.
*      write: /1 sy-vline, 2(130) text-102, 132 sy-vline.
*    endif.
*
*    write: /01 sy-vline, 02 sy-uline(130), 132 sy-vline.
*    write: /1 sy-vline, 2 text-046, 132 sy-vline.
**    WRITE: /1 SY-VLINE, 2 TEXT-047, 132 SY-VLINE.   "46C 165736
*    write: /01 sy-vline, 02 sy-uline(130), 132 sy-vline.
*  endif.
*  if printflag = 'L'.
**   Verarbeitungsprotokoll Darlehen
**   Felder für Seitenkopf füllen
*    bhdgd-uname = sy-uname.
*    bhdgd-repid = sy-repid.
*    bhdgd-line1 = text-007.
*    bhdgd-line2 = text-070.
*    bhdgd-inifl = '0'.
**   bhdgd-start_pagno = 1.
**   Batch-Heading-Routine für Seitenkopf aufrufen
*    perform batch-heading(rsbtchh0).
*    write: /001 sy-uline(132).
*    write: /001 sy-vline,
*            003 text-200,
*            022 sy-vline,
*            027 text-205,
*            065 sy-vline,
*            067 text-201,
*            086 sy-vline,
*            088 text-202,
*            132 sy-vline.
*    write: /001 sy-vline,
*            003 text-203,
*            022 sy-vline,
*            027 text-206,
*            065 sy-vline,
*            067 text-204,
*            086 sy-vline,
*            132 sy-vline.
*    write: /01 sy-uline(132).
*  endif.
*endform.                    "TOP_OF_PAGE
*


*eject
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE.
*&---------------------------------------------------------------------*
*       Top-of-page für Lockbox                                        *
*----------------------------------------------------------------------*
FORM top_of_page_lockbox.
**---- Perform Batch Heading Routine -----------------------------------
  bhdgd-bukrs = febko-bukrs.
  bhdgd-uname = sy-uname.
  bhdgd-repid = sy-repid.
  char16      = text-l09.
  bhdgd-line1 = char16(8).
  bhdgd-line2 = text-l02.
  bhdgd-inifl = '0'.
*  perform batch-heading(rsbtchh0).
**  uline.
*  write: /01     sy-vline,
*          02(12) text-l11,
*          15(10) febko-absnd+0(10),
*          30(07) text-l12,
*          39(10) febko-absnd+11(10),
*          51(08) text-l09,
*          61(08) febko-azidt+0(07),
*          68(11) text-l13,
*          81(08) febko-azdat dd/mm/yy,
*          91(13) text-l15,
*         106     febko-kukey,
*         132     sy-vline.
**  uline.
*
*  write: /01     sy-vline,
*          03(13) text-l16,
*          18(10) text-l17,
*          30(16) text-l19,
*          47(10) text-l18,
*          58(10) text-l20,
*          69(10) text-l21,
*          94(09) text-l25,
*         104(07) text-l33,
*         132     sy-vline.
**  uline.
*
ENDFORM.                    "TOP_OF_PAGE_LOCKBOX
*&---------------------------------------------------------------------*
*&      Form  SAVE_MESSAGE_FOR_LBOX_LOG
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
FORM save_message_for_lbox_log USING msnum.
  CHECK NOT subrc IS INITIAL.
  CLEAR lbmsg.
  lbmsg-mandt = sy-mandt.
  lbmsg-kukey = febep-kukey.
  lbmsg-esnum = febep-esnum.
  lbmsg-msnum = msnum.
  CLEAR char10.
  CLEAR char300.
  CLEAR t100.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t100
*          WHERE sprsl = sy-langu
*            AND arbgb = msgid
*            AND msgnr = msgno.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t100
          WHERE sprsl = sy-langu
            AND arbgb = msgid
            AND msgnr = msgno ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF subrc NE 0.
    char300 = text-112.
    REPLACE '&' WITH msgid INTO char300.
    REPLACE '&' WITH msgno INTO char300.
    CONDENSE char300.
    char10 = text-113.
  ENDIF.

  char300+30   = t100-text.

  REPLACE '&1'   WITH '&'   INTO char300.
  REPLACE '&2'   WITH '&'   INTO char300.
  REPLACE '&3'   WITH '&'   INTO char300.
  REPLACE '&4'   WITH '&'   INTO char300.
  REPLACE '&V1&' WITH '&'   INTO char300.
  REPLACE '&V2&' WITH '&'   INTO char300.
  REPLACE '&V3&' WITH '&'   INTO char300.
  REPLACE '&V4&' WITH '&'   INTO char300.
  REPLACE '&v1&' WITH '&'   INTO char300.
  REPLACE '&v2&' WITH '&'   INTO char300.
  REPLACE '&v3&' WITH '&'   INTO char300.
  REPLACE '&v4&' WITH '&'   INTO char300.

  REPLACE '&' WITH msgv1 INTO char300.
  REPLACE '&' WITH msgv2 INTO char300.
  REPLACE '&' WITH msgv3 INTO char300.
  REPLACE '&' WITH msgv4 INTO char300.
  CONDENSE char300.

  CASE msnum.
    WHEN 1.
      SHIFT char300 RIGHT BY 30 PLACES.
      char300+0(29) = text-116.
      CONDENSE char300.
      lbmsg-text = char300.
    WHEN 2.
      SHIFT char300 RIGHT BY 30 PLACES.
      char300+0(29) = text-117.
      CONDENSE char300.
      lbmsg-text = char300.
    WHEN 3.
      SHIFT char300 RIGHT BY 30 PLACES.
      char300+0(29) = text-115.
      REPLACE '&' WITH postalgo INTO char300.
      CONDENSE char300.
      lbmsg-text = char300.
    WHEN OTHERS.
      lbmsg-text = char300.
  ENDCASE.
  APPEND lbmsg.

ENDFORM.                               " SAVE_MESSAGE_FOR_LBOX_LOG
*&---------------------------------------------------------------------*
*&      Form  WRITE_LBMSG_LINES
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
** start changes after review C5056169 01.06.2004
*FORM write_lbmsg_lines.
************************************************************************
*
****    End of comment                            C5053248
************************************************************************
*
************************************************************************
*
****    Begin of ALV Conversion                   C5053248
************************************************************************
*
**form write_lbmsg_lines CHANGING XT_FB01.
************************************************************************
*
****    End of ALV Conversion                     C5053248
************************************************************************
*
*  READ TABLE lbmsg WITH KEY xfebep(16) BINARY SEARCH.
*  idx_lbmsg = sy-tabix.
*  DO.
*    READ TABLE lbmsg INDEX idx_lbmsg.
*    IF lbmsg(16) = xfebep(16) AND sy-subrc = 0.
**      FORMAT COLOR COL_NEGATIVE.
**      WRITE: /1      sy-vline,
**             18(110) lbmsg-text,
**            132      sy-vline.
**      FORMAT RESET.
*      idx_lbmsg = idx_lbmsg + 1.
*    ELSE.
*      EXIT.
*    ENDIF.
*  ENDDO.
*ENDFORM.                               " WRITE_LBMSG_LINES
* end changes after review C5056169 01.06.2004


*eject
*&---------------------------------------------------------------------*
*&      Form  FILL_XFEBRE                          new with 30C
*&---------------------------------------------------------------------*
*       FEBRE nachlesen und in XFEBRE füllen                           *
*----------------------------------------------------------------------*
FORM fill_xfebre.
  REFRESH xfebre.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM febre INTO TABLE xfebre
*                      WHERE kukey = febko-kukey
*                      AND   esnum = febep-esnum.
*
* NEW CODE
  SELECT *
 FROM febre INTO TABLE xfebre
                      WHERE kukey = febko-kukey
                      AND   esnum = febep-esnum ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

ENDFORM.                               " FILL_XFEBRE

*eject
*&---------------------------------------------------------------------*
*&      Form  GENERATE_DIFFERENCE_LINE_ITEM
*&---------------------------------------------------------------------*
*       add line item with the difference amount in FTPOST             *
*----------------------------------------------------------------------*
FORM generate_difference_line_item.
  DATA: diff_txt(16) TYPE c.

  IF difffw > 0.
*     Überzahlung
    IF NOT t049a-bsdbh IS INITIAL.
      bschl = t049a-bsdbh.
    ELSE.
      bschl = '15'.
    ENDIF.
    diff_txt = text-l23.
  ELSE.
*     Unterzahlung
    difffw = difffw * -1.
    diff_txt = text-l22.
    IF NOT t049a-bsdbh IS INITIAL.
      bschl = t049a-bsdbs.
    ELSE.
      bschl = '06'.
    ENDIF.
  ENDIF.
  ftpost-stype = 'P'.
  ftpost-count = '2'.

  WRITE difffw TO char16 CURRENCY febko-waers.
  CONDENSE char16 NO-GAPS.
  PERFORM ftpost_field  USING 'RF05A-NEWBS' bschl.
  PERFORM ftpost_field  USING 'RF05A-NEWKO' febep-avkon.
  PERFORM ftpost_field  USING 'BSEG-WRBTR' char16.
  PERFORM ftpost_field  USING 'BSEG-SKFBT' char16.
  char50(25) = text-l24.
  char50+25  = diff_txt.
  PERFORM ftpost_field  USING 'BSEG-SGTXT' char50.

  IF NOT febep-gsber IS INITIAL.
    PERFORM ftpost_field USING 'BSEG-GSBER' febep-gsber.    "Geschäftsbe
  ENDIF.

ENDFORM.                               " GENERATE_DIFFERENCE_LINE_ITEM

*eject
*&---------------------------------------------------------------------*
*&      Form  SET_PRINT_PARAMETERS
*&---------------------------------------------------------------------*
*       set print parameters if program runs in batch                  *
*----------------------------------------------------------------------*
FORM set_print_parameters.
  DATA: list_name LIKE pri_params-plist.

  CHECK execpri = 'X'.
  CLEAR pri_key.
  pri_key-repid = sy-repid.
  LOOP AT s_kukey.
    pri_key-kukey = s_kukey-low.
    EXIT.
  ENDLOOP.

  IMPORT pri_param arc_param FROM MEMORY ID pri_key.

  list_name = sy-repid.
  CALL FUNCTION 'GET_PRINT_PARAMETERS'
    EXPORTING
      no_dialog              = 'X'
      in_archive_parameters  = arc_param
      in_parameters          = pri_param
      list_name              = list_name
      mode                   = 'BATCH'
    IMPORTING
      out_archive_parameters = arc_param
      out_parameters         = pri_param.

  NEW-PAGE  PRINT ON  PARAMETERS pri_param
                      ARCHIVE PARAMETERS arc_param
                      NO DIALOG.
ENDFORM.                               " SET_PRINT_PARAMETERS

*eject
*&---------------------------------------------------------------------*
*&      Form  CLOSE_PRINT_PARAMETERS
*&---------------------------------------------------------------------*
*       write log to spool if batch run                                *
*----------------------------------------------------------------------*
FORM close_print_parameters.
  CHECK execpri = 'X'.

  NEW-PAGE  PRINT OFF.
  MESSAGE s640(fv) WITH sy-spono.
ENDFORM.                               " CLOSE_PRINT_PARAMETERS

*&---------------------------------------------------------------------*
*&      Form  APPEND_XFEBCL_TO_FTCLEAR
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
FORM append_xfebcl_to_ftclear.
  CLEAR ftclear.

*--------- Ausgleichsbuchungskreis setzen ------------------------------
  IF xfebcl-agbuk IS INITIAL.
    ftclear-agbuk = febko-bukrs.
  ELSE.
    ftclear-agbuk = xfebcl-agbuk.
  ENDIF.

*--------- falls keine Sonderhauptbuchkennzeichen -> XNOPS setzen ------
* if xfebcl-agums is initial.
*   ftclear-xnops = 'X'.
* else.
*   ftclear-agums = xfebcl-agums.
* endif.

  IF NOT xfebcl-agums IS INITIAL.      "40a Spec Ledgr
    ftclear-agums = xfebcl-agums.
*  elseif not ikofi-shbk1 is initial.
*    ftclear-agums = ikofi-shbk1.
  ELSEIF ( ( xfebcl-koart = 'D' ) AND ( NOT ikofi-shbk2 IS INITIAL ) ) .
    ftclear-agums = ikofi-shbk2.
  ELSEIF ( ( xfebcl-koart = 'K' ) AND                       "45B
           ( NOT ikofi-shbk1 IS INITIAL ) ) .               "45B
    ftclear-agums = ikofi-shbk1.                            "45B
  ELSE.
    ftclear-xnops = 'X'.
  ENDIF.

*-- check for dta-reference number entry
  IF xfebcl-selfd = 'REFNO'.                               "note 206022
    PERFORM append_refno_docs USING xfebcl-selvon.         "note 206022
*-- bail out
  ELSE.                                                    "note 206022
    ftclear-agkoa  = xfebcl-koart.
    ftclear-agkon  = xfebcl-agkon.
    ftclear-xfifo  = xfebcl-xfifo.
    ftclear-selfd  = xfebcl-selfd.
    ftclear-selvon = xfebcl-selvon.
    ftclear-selbis = xfebcl-selbis.
    APPEND ftclear.
  ENDIF.                                                   "note 206022
ENDFORM.                               " APPEND_XFEBCL_TO_FTCLEAR

*&---------------------------------------------------------------------*
*&      Form  CHECK_TESTLAUF
*&---------------------------------------------------------------------*
*       Weitergabe Status Testlauf: Aufruf durch Anwendungen           *
*----------------------------------------------------------------------*
FORM check_testlauf CHANGING value(testlauf).               "#EC CALLED
  testlauf = testl.
ENDFORM.                               " CHECK_TESTLAUF

*&---------------------------------------------------------------------*
*&      Form  FB05_FTPOST_INTEREST_HABEN
*&---------------------------------------------------------------------*
*       Posts interest/penalty payments on arrears
*----------------------------------------------------------------------*
FORM fb05_ftpost_interest_haben.

* Interest indicator from KNB1
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM knb1 WHERE kunnr = febep-avkon
*                              AND bukrs = febko-bukrs.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM knb1 WHERE kunnr = febep-avkon
                              AND bukrs = febko-bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  CHECK sy-subrc = 0.

* ACCOUNT DETERMINATION FROM T033F
  CLEAR ikofi.
  MOVE:   '0002'           TO ikofi-anwnd,
          '1000'           TO ikofi-eigr1,
           febko-bukrs     TO ikofi-eigr2,
           knb1-vzskz      TO ikofi-eigr3.

  IF febep-gsber NE space.
    MOVE   febep-gsber     TO ikofi-eigr4.
  ELSE.
    MOVE   space           TO ikofi-eigr4.
  ENDIF.

  MOVE:    febko-waers     TO ikofi-komo1,
           space           TO ikofi-komo2,
           febko-ktopl     TO ikofi-ktopl,
           space           TO ikofi-sakin.

  CALL FUNCTION 'ACCOUNT_DETERMINATION'
    EXPORTING
      i_anwnd            = ikofi-anwnd
      i_eigr1            = ikofi-eigr1
      i_eigr2            = ikofi-eigr2
      i_eigr3            = ikofi-eigr3
      i_eigr4            = ikofi-eigr4
      i_fpart            = ikofi-fpart
      i_komo1            = ikofi-komo1
      i_komo2            = ikofi-komo2
      i_ktopl            = ikofi-ktopl
      i_sakin            = ikofi-sakin
      i_sakinb           = ikofi-sakin                      "mp45A
    IMPORTING
      e_ikofi            = ikofi
    EXCEPTIONS
      input_missing      = 1
      input_wrong        = 2
      replace_impossible = 3
      rule_not_defined   = 4
      schema_not_found   = 5.

  IF sy-subrc NE 0.
    MESSAGE i857 WITH febko-ktopl.
  ENDIF.

*  IF ( NOT FEBEP-KOSTL IS INITIAL ) OR ( NOT FEBEP-PRCTR IS INITIAL ).
*    PERFORM CHECK_IF_COST_RELEVANT USING IKOFI-SAKN2 CRC_FLAG.
*  ENDIF.

* BSCH2 and SAKN2 because of 'HABEN'
  PERFORM ftpost_field USING 'BSEG-BSCHL' ikofi-bsch2.    "Buchungssch
  PERFORM ftpost_field USING 'BSEG-HKONT' ikofi-sakn2.    "Interestacc

* Interest/Penalty for overdue are only posted in account currency.
* -> posting area 1 or febep-fwbtr initial
  WRITE febep-arrsk TO fvalue CURRENCY febep-kwaer.     "ok - mpEURO
  CONDENSE fvalue.
  PERFORM ftpost_field USING 'BSEG-WRBTR' fvalue.         "BetrBelegWä
* WRBTR = FVALUE.
*eject
ENDFORM.                               " FB05_FTPOST_INTEREST_HABEN
*&---------------------------------------------------------------------*
*&      Form  INIT_PROT_TREA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_prot_trea.
  CLEAR t_header.REFRESH t_header.
  CLEAR t_footer.REFRESH t_footer.
  flag_prot_trea = '0'.
  CALL FUNCTION 'PROTOCOL_INIT'
       EXPORTING
            protocol_columns_per_page = '100'
*           protocol_dataset = 'SAPV01'
*           protocol_expiration = e03
            protocol_lines_per_page = '60'
            protocol_name = 'EKA'
            protocol_output_channel = 'S'
       TABLES
            protocol_footer = t_footer
            protocol_header = t_header.
ENDFORM.                               " INIT_PROT_TREA
*&---------------------------------------------------------------------*
*&      Form  FB02_CHANGING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form fb02_changing.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM fb02_changing CHANGING xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  DATA:
  pdocnum    LIKE febep-belnr,
  pcompany   LIKE febep-avkon,
  pyear      LIKE febep-gjahr,
  pline      LIKE bseg-buzei,
  pxrf1      LIKE bseg-xref1,
  pxrf2      LIKE bseg-xref2,
  pdupl      LIKE bseg-xref3,
  pbank      LIKE febko-hbkid.


*----------------------------------------------------------------------*
*  Assign search data and data to be changes                           *
*----------------------------------------------------------------------*

*  Update of document number
  febep-belnr = febep-pnota.

*  Search
  pdocnum  = febep-belnr.
  pcompany = febko-bukrs.
  pyear    = febep-gjahr.
  pline    = febep-xblnr+6(3).
*  Can PLINE be a line item number ?
  IF pline = 0 .                                            "120779
    pline = 1.                         "Default
  ENDIF.

*  Change
  pbank      = febko-hbkid.
  pxrf1(7)   = febep-kukey+1(7).
  pxrf1+7(5) = febep-esnum.
  pxrf2(5)   = febep-sgtxt(5).
* PDUPL      = FEBEP-CHECT.   " KIDNO transfers correctly the value
  pdupl      = febep-kidno.   " to REF3 (Boleto Number)

*----------------------------------------------------------------------*
*  fill BDC table                                                      *
*----------------------------------------------------------------------*

  PERFORM create_fb02 USING pdocnum pcompany pyear pline
                         pbank pxrf1 pxrf2 pdupl.



*----------------------------------------------------------------------*
*  Print into protocoll                                                *
*----------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*  perform print_fb02_line.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
  PERFORM print_fb02_line CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
*----------------------------------------------------------------------*
*  close BDC/call transaction                                          *
*----------------------------------------------------------------------*

  IF function EQ 'C'.

*----------------------------------------------------------------------*
*  call transaction FB02                                               *
*----------------------------------------------------------------------*
    mode = 'N'.
    CALL TRANSACTION 'FB02' USING  bdcdata
                            MODE   mode
                            UPDATE 'S'.

    IF sy-subrc NE 0.

      msgid = sy-msgid.
      msgno = sy-msgno.
      msgv1 = sy-msgv1.
      msgv2 = sy-msgv2.
      msgv3 = sy-msgv3.
      msgv4 = sy-msgv4.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*          perform druck_message.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
      PERFORM druck_message CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
      UPDATE febep SET vb2ok = space
                 WHERE kukey = febep-kukey
                   AND esnum = febep-esnum.
    ENDIF.

  ELSE.

*----------------------------------------------------------------------*
*  create batch input session                                          *
*----------------------------------------------------------------------*
*  insert transaction into BDC session                                 *
    CALL FUNCTION 'BDC_INSERT'
      EXPORTING
        tcode     = 'FB02'
      TABLES
        dynprotab = bdcdata
      EXCEPTIONS
        OTHERS    = 4.

  ENDIF.

ENDFORM.                               " FB02_CHANGING

*eject
*---------------------------------------------------------------------*
*       FORM CREATE_FB02                                              *
*---------------------------------------------------------------------*
*       fills batch input tables with FB02 data to change             *
*       line text and reference number 1                              *
*---------------------------------------------------------------------*
*  -->  DOCNUM        document number                                 *
*  -->  COMPANY       company                                         *
*  -->  YEAR          year                                            *
*  -->  LINE          document line                                   *
*  -->  PZAWE         used payment method                             *
*  -->  PBANK         used house bank                                 *
*  -->  PXRF1         Kukey(7) + Esnum(5)                             *
*  -->  PDUPL         Duplicata number from Bank                       *
*---------------------------------------------------------------------*
FORM create_fb02 USING docnum company year line
                       hbkid xref1 xref2 dupln.

  TABLES:
          t019w,                       "accounting window selection
          t019.                        "Accounting screen selection

  DATA:  field_name LIKE bdcdata-fnam. "field name

* For BUVAR
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t001 WHERE bukrs = company.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t001 WHERE bukrs = company ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  REFRESH bdcdata.                     "Depner, 9.1.


* Note 859618
  DATA:
  temp_umskz LIKE febcl-agums.
  CONSTANTS:
  splind LIKE bseg-umskz VALUE 'I'.

  TYPES : BEGIN OF typ_febep_zuonr,
            kukey  LIKE febep-kukey,
            esnum  LIKE febep-esnum,
            umskz LIKE bseg-umskz,
          END OF typ_febep_zuonr.
  DATA : struc_febep_zuonr TYPE typ_febep_zuonr.


* Note 859618
* Downpayment processing
  struc_febep_zuonr = febep-zuonr.
  TEMP_umskz = febep-zuonr+17(1).

* Note 966438
* In case of Vendor Operations, the screens should be picked up considering
* normal ZKOK/ZKOD and NOT ZKOX.
* The call to ZKOX is done on the basis of struc_febep_zuonr-umskz if it
* is filled. But as we want ZKOD/ZKOK, we are clearing struc_febep_zuonr-umskz
  if temp_umskz = splind.
    clear struc_febep_zuonr-umskz.
  endif.
* Note 966438


*... fill selection screen of FB02 ....................................*

  PERFORM bdc_start_dynpro USING 'SAPMF05L' '0100'.
  PERFORM bdc_add_field USING 'RF05L-BELNR' docnum.
  PERFORM bdc_add_field USING 'RF05L-BUKRS' company.
  PERFORM bdc_add_field USING 'RF05L-GJAHR' year.
*  perform bdc_add_field using 'RF05L-XBLNR' space.

  PERFORM bdc_add_field USING 'BDC_OKCODE' '   '.

*... goto selected line ...............................................*

  PERFORM bdc_start_dynpro USING 'SAPMF05L' '0700'.
  field_name = 'RF05L-ANZDT(XXX)'.
  field_name+12(3) = line.
  PERFORM bdc_add_field USING 'BDC_CURSOR' field_name.
  PERFORM bdc_add_field USING 'BDC_OKCODE' '/02'.

*... change **** ......................................................*
  PERFORM dynpro_determine_br USING febep-avkoa struc_febep_zuonr-umskz .
  PERFORM bdc_start_dynpro USING 'SAPMF05L' t019-dynnr.

  PERFORM bdc_add_field USING 'BDC_OKCODE' '/08'.   "jump to 'more data'

*... change reference key .............................................*

* determine dynpro number of popup screen

  CASE febep-avkoa.
    WHEN 'K'.
      IF struc_febep_zuonr-umskz IS INITIAL.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM t019w WHERE mpool = 'SAPMF05L'
*                                 AND buvar = t001-buvar
*                                 AND winfk = 'ZKOK'.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM t019w WHERE mpool = 'SAPMF05L'
                                 AND buvar = t001-buvar
                                 AND winfk = 'ZKOK' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc <> 0.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM t019w WHERE mpool = 'SAPMF05L'
*                                   AND buvar = space
*                                   AND winfk = 'ZKOK'.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM t019w WHERE mpool = 'SAPMF05L'
                                   AND buvar = space
                                   AND winfk = 'ZKOK' ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
            ENDIF.
      ELSE.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*             SELECT SINGLE * FROM t019w WHERE mpool = 'SAPMF05L'
*                                 AND buvar = t001-buvar
*                                 AND winfk = 'ZKOX'.
*
* NEW CODE
             SELECT *
             UP TO 1 ROWS  FROM t019w WHERE mpool = 'SAPMF05L'
                                 AND buvar = t001-buvar
                                 AND winfk = 'ZKOX' ORDER BY PRIMARY KEY.

             ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
            IF sy-subrc <> 0.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*            SELECT SINGLE * FROM t019w WHERE mpool = 'SAPMF05L'
*                                   AND buvar = space
*                                   AND winfk = 'ZKOX'.
*
* NEW CODE
            SELECT *
            UP TO 1 ROWS  FROM t019w WHERE mpool = 'SAPMF05L'
                                   AND buvar = space
                                   AND winfk = 'ZKOX' ORDER BY PRIMARY KEY.

            ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
            ENDIF.
      ENDIF.
         WHEN 'D'.
     IF struc_febep_zuonr-umskz IS INITIAL.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*           SELECT SINGLE * FROM t019w WHERE mpool = 'SAPMF05L'
*                                AND buvar = t001-buvar
*                                AND winfk = 'ZKOD'.
*
* NEW CODE
           SELECT *
           UP TO 1 ROWS  FROM t019w WHERE mpool = 'SAPMF05L'
                                AND buvar = t001-buvar
                                AND winfk = 'ZKOD' ORDER BY PRIMARY KEY.

           ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
           IF sy-subrc <> 0.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*           SELECT SINGLE * FROM t019w WHERE mpool = 'SAPMF05L'
*                                  AND buvar = space
*                                  AND winfk = 'ZKOD'.
*
* NEW CODE
           SELECT *
           UP TO 1 ROWS  FROM t019w WHERE mpool = 'SAPMF05L'
                                  AND buvar = space
                                  AND winfk = 'ZKOD' ORDER BY PRIMARY KEY.

           ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
           ENDIF.
     ELSE.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*            SELECT SINGLE * FROM t019w WHERE mpool = 'SAPMF05L'
*                                AND buvar = t001-buvar
*                                AND winfk = 'ZKOX'.
*
* NEW CODE
            SELECT *
            UP TO 1 ROWS  FROM t019w WHERE mpool = 'SAPMF05L'
                                AND buvar = t001-buvar
                                AND winfk = 'ZKOX' ORDER BY PRIMARY KEY.

            ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
           IF sy-subrc <> 0.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*           SELECT SINGLE * FROM t019w WHERE mpool = 'SAPMF05L'
*                                  AND buvar = space
*                                  AND winfk = 'ZKOX'.
*
* NEW CODE
           SELECT *
           UP TO 1 ROWS  FROM t019w WHERE mpool = 'SAPMF05L'
                                  AND buvar = space
                                  AND winfk = 'ZKOX' ORDER BY PRIMARY KEY.

           ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
           ENDIF.
     ENDIF.
   WHEN 'S'.
     IF struc_febep_zuonr-umskz IS INITIAL.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*           SELECT SINGLE * FROM t019w WHERE mpool = 'SAPMF05L'
*                                AND buvar = t001-buvar
*                                AND winfk = 'ZKOS'.
*
* NEW CODE
           SELECT *
           UP TO 1 ROWS  FROM t019w WHERE mpool = 'SAPMF05L'
                                AND buvar = t001-buvar
                                AND winfk = 'ZKOS' ORDER BY PRIMARY KEY.

           ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
           IF sy-subrc <> 0.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*           SELECT SINGLE * FROM t019w WHERE mpool = 'SAPMF05L'
*                                  AND buvar = space
*                                  AND winfk = 'ZKOS'.
*
* NEW CODE
           SELECT *
           UP TO 1 ROWS  FROM t019w WHERE mpool = 'SAPMF05L'
                                  AND buvar = space
                                  AND winfk = 'ZKOS' ORDER BY PRIMARY KEY.

           ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
           ENDIF.
  ELSE.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM t019w WHERE mpool = 'SAPMF05L'
*                                 AND buvar = t001-buvar
*                                 AND winfk = 'ZKOD'.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM t019w WHERE mpool = 'SAPMF05L'
                                 AND buvar = t001-buvar
                                 AND winfk = 'ZKOD' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc <> 0.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM t019w WHERE mpool = 'SAPMF05L'
*                                   AND buvar = space
*                                   AND winfk = 'ZKOD'.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM t019w WHERE mpool = 'SAPMF05L'
                                   AND buvar = space
                                   AND winfk = 'ZKOD' ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    ENDIF.
      ENDIF.

  ENDCASE.

  PERFORM bdc_start_dynpro USING 'SAPMF05L' t019w-winnr.
  PERFORM bdc_add_field USING 'BSEG-XREF1' xref1.
  PERFORM bdc_add_field USING 'BSEG-XREF2' xref2.
  PERFORM bdc_add_field USING 'BSEG-XREF3' dupln.
  PERFORM bdc_add_field USING 'BSEG-HBKID' hbkid.

*... update document ..................................................*

  PERFORM bdc_start_dynpro USING 'SAPMF05L' t019-dynnr. "noch gleich
  PERFORM bdc_add_field USING 'BDC_OKCODE' '/11'.

ENDFORM.                    "CREATE_FB02

*---------------------------------------------------------------------*
*       FORM BDC_START_DYNPRO                                         *
*---------------------------------------------------------------------*
*       initializes BDC_TABLE for next dynpro                         *
*---------------------------------------------------------------------*
*  -->  PROGRAM   name of program                                     *
*  -->  DYNPRO    dynpro number                                       *
*---------------------------------------------------------------------*
FORM bdc_start_dynpro USING program
                            dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.                    "BDC_START_DYNPRO

*---------------------------------------------------------------------*
*       FORM BDC_ADD_FIELD                                            *
*---------------------------------------------------------------------*
*       adds a new field to BDC_TABLE                                 *
*---------------------------------------------------------------------*
*  -->  FNAME     name of field                                       *
*  -->  FVALUE    value of field                                      *
*---------------------------------------------------------------------*
FORM bdc_add_field USING fname
                         fvalue.
  CLEAR bdcdata.
  bdcdata-fnam = fname.
  bdcdata-fval = fvalue.
  APPEND bdcdata.
ENDFORM.                    "BDC_ADD_FIELD

*eject
*---------------------------------------------------------------------*
FORM dynpro_determine USING p_avkoa.

  t019-dyncl = 'A'.
  t019-koart = p_avkoa.
  t019-umskz = bseg-umsks.           "n1020581
  t019-buvar = t001-buvar.

  READ TABLE t019.
  IF sy-subrc NE 0.
    t019-buvar = space.
    READ TABLE t019.
    IF sy-subrc NE 0.
      MESSAGE ID 'F5' TYPE 'I' NUMBER '100' WITH 'T019' t019(4).
    ENDIF.
  ENDIF.
ENDFORM.                    "DYNPRO_DETERMINE

*&---------------------------------------------------------------------*
*&      Form  PRINT_FB02_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form print_fb02_line.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM print_fb02_line CHANGING xt_fb01 LIKE gt_fb01_1.
  DATA: ls_fb01 TYPE fagl_acc_s_rfebbu00_alv.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  IF p_bupro = 'X'.
*   RESERVE 6 LINES.
*   WRITE: /01 SY-VLINE, 02 SY-ULINE(130), 132 SY-VLINE.
    char80 = text-049.
    REPLACE '&' WITH febep-belnr      INTO char80.
    REPLACE '&' WITH febep-xblnr+6(3) INTO char80.
    REPLACE '&' WITH febep-chect      INTO char80.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    write: /01     sy-vline,
*            02(05) febep-esnum,
*            08(04) febep-vgint,
*            14(20) febep-vgext,
*            35(04) 'FB02',
*            41(80) char80,
*            132    sy-vline.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    CLEAR ls_fb01.
    ls_fb01-esnum       = febep-esnum.
    ls_fb01-vgint      = febep-vgint.
    ls_fb01-vgext      = febep-vgext.
    ls_fb01-tcode      = 'FB02'.
    ls_fb01-msg        = char80.
    ls_fb01-bername    = bername.

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
    ls_fb01-bankl  = gs_header-bankl.
    ls_fb01-ktonr  = gs_header-ktonr.
    ls_fb01-aznum  = gs_header-aznum.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*
    ls_fb01-kukey     = febko-kukey.                "n853370
    ls_fb01-mappe     = mappe.

    APPEND ls_fb01 TO xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  ENDIF.

ENDFORM.                               " PRINT_FB02_LINE
*&---------------------------------------------------------------------*
*&      Form  ADDITIONAL_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM additional_fields USING koart.
  DATA:                                                     "ak020200
      xcnt LIKE febep-fkoa1 VALUE '0'.

*-- allow specific application of BDC-fields to posting-area / line
  IF bereich = '2'.
    xcnt = 1.
  ENDIF.

  IF ftpost-count = '002'.
    xcnt = xcnt + 2.
  ENDIF.

  IF febep-fkoa1 = xcnt.
    PERFORM ftpost_field USING febep-fnam1 febep-fval1.
  ENDIF.

  IF febep-fkoa2 = xcnt.
    PERFORM ftpost_field USING febep-fnam2 febep-fval2.
  ENDIF.

  IF febep-fkoa3 = xcnt.
    PERFORM ftpost_field USING febep-fnam3 febep-fval3.
  ENDIF.

  IF koart = 'S'.
    IF NOT febep-fval1 IS INITIAL AND  "Usr field 1
       NOT febep-fnam1 IS INITIAL AND
         ( febep-fkoa1 IS INITIAL OR
           febep-fkoa1 =  'S' ).
      PERFORM ftpost_field USING febep-fnam1 febep-fval1.
    ENDIF.

    IF NOT febep-fval2 IS INITIAL AND  "Usr field 2
       NOT febep-fnam2 IS INITIAL AND
         ( febep-fkoa2 IS INITIAL OR
           febep-fkoa2 =  'S' ).
      PERFORM ftpost_field USING febep-fnam2 febep-fval2.
    ENDIF.

    IF NOT febep-fval3 IS INITIAL AND  "Usr field 3
       NOT febep-fnam3 IS INITIAL AND
         ( febep-fkoa3 IS INITIAL OR
           febep-fkoa3 =  'S' ).
      PERFORM ftpost_field USING febep-fnam3 febep-fval3.
    ENDIF.
  ELSE.
    IF NOT febep-fval1 IS INITIAL AND  "Usr field 1
       NOT febep-fnam1 IS INITIAL AND
         ( febep-fkoa1 = 'D' OR
           febep-fkoa1 = 'K' ).
      PERFORM ftpost_field USING febep-fnam1 febep-fval1.
    ENDIF.

    IF NOT febep-fval2 IS INITIAL AND  "Usr field 2
       NOT febep-fnam2 IS INITIAL AND
         ( febep-fkoa2 = 'D' OR
           febep-fkoa2 = 'K' ).
      PERFORM ftpost_field USING febep-fnam2 febep-fval2.
    ENDIF.

    IF NOT febep-fval3 IS INITIAL AND  "Usr field 3
       NOT febep-fnam3 IS INITIAL AND
         ( febep-fkoa3 = 'D' OR
           febep-fkoa3 = 'K' ).
      PERFORM ftpost_field USING febep-fnam3 febep-fval3.
    ENDIF.
  ENDIF.

ENDFORM.                               " ADDITIONAL_FIELDS

*&---------------------------------------------------------------------*
*&      Form  ADDITIONAL_FIELDS_KOMK_S
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM additional_fields_komk_s.
  DATA:
  xcnt LIKE febep-fkoa1 VALUE '0'.                          "ak020200

*-- allow specific application of BDC-fields to posting-area / line
  IF bereich = '2'.
    xcnt = 1.
  ENDIF.

  IF ftpost-count = '002'.
    xcnt = xcnt + 2.
  ENDIF.

  IF febep-fkoa1 = xcnt.
    PERFORM ftpost_field USING febep-fnam1 febep-fval1.
  ENDIF.

  IF febep-fkoa2 = xcnt.
    PERFORM ftpost_field USING febep-fnam2 febep-fval2.
  ENDIF.

  IF febep-fkoa3 = xcnt.
    PERFORM ftpost_field USING febep-fnam3 febep-fval3.
  ENDIF.

  IF NOT febep-fval1 IS INITIAL AND    "Usr field 1
     NOT febep-fnam1 IS INITIAL AND
       ( febep-fkoa1 IS INITIAL OR
         febep-fkoa1 = 'S' ).
    PERFORM ft_komk_s_field USING febep-fnam1 febep-fval1.
  ENDIF.

  IF NOT febep-fval2 IS INITIAL AND    "Usr field 2
     NOT febep-fnam2 IS INITIAL AND
       ( febep-fkoa2 IS INITIAL OR
         febep-fkoa2 = 'S' ).
    PERFORM ft_komk_s_field USING febep-fnam2 febep-fval2.
  ENDIF.

  IF NOT febep-fval3 IS INITIAL AND    "Usr field 3
     NOT febep-fnam3 IS INITIAL AND
       ( febep-fkoa3 IS INITIAL OR
         febep-fkoa3 = 'S' ).
    PERFORM ft_komk_s_field USING febep-fnam3 febep-fval3.
  ENDIF.

ENDFORM.                               " ADDITIONAL_FIELDS_KOMK_S

*&---------------------------------------------------------------------*
*&      Form  ADDITIONAL_FIELDS_KOMK_H
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM additional_fields_komk_h.

  IF NOT febep-fval1 IS INITIAL AND    "Usr field 1
     NOT febep-fnam1 IS INITIAL AND
       ( febep-fkoa1 IS INITIAL OR
         febep-fkoa1 = 'S' ).
    PERFORM ft_komk_h_field USING febep-fnam1 febep-fval1.
  ENDIF.

  IF NOT febep-fval2 IS INITIAL AND    "Usr field 2
     NOT febep-fnam2 IS INITIAL AND
       ( febep-fkoa2 IS INITIAL OR
         febep-fkoa2 = 'S' ).
    PERFORM ft_komk_h_field USING febep-fnam2 febep-fval2.
  ENDIF.

  IF NOT febep-fval3 IS INITIAL AND    "Usr field 3
     NOT febep-fnam3 IS INITIAL AND
       ( febep-fkoa3 IS INITIAL OR
         febep-fkoa3 = 'S' ).
    PERFORM ft_komk_h_field USING febep-fnam3 febep-fval3.
  ENDIF.

ENDFORM.                               " ADDITIONAL_FIELDS_KOMK_H
*&---------------------------------------------------------------------*
*&      Form  PRINT_PROT_TREA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print_prot_trea.
* Seitenkopfsteuerung für Verarbeitungsprotokoll Darlehen aktivieren
  printflag = 'L'.
  IF pa_lsepa = 'X'.
*   Listseparation entsprechend Tabelle TLSEP anstoßen
    bhdgd-separ   = 'X'.
    bhdgd-domai   = 'LSEPW_EB'.
    bhdgd-grpin   = '3'.
    bhdgd-werte   = '3'.
    PERFORM new-section(rsbtchh0).
  ENDIF.
  NEW-PAGE.
  CALL FUNCTION 'PROTOCOL_SHOW'
    EXPORTING
      protocol_channel = 'O'
      protocol_name    = 'EKA'
    IMPORTING
      protocol_spono   = b-spoolnr.
ENDFORM.                               " PRINT_PROT_TREA
*&---------------------------------------------------------------------*
*&      Form  OPEN_FI_POSTING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form open_fi_posting using testrun type xflag.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM open_fi_posting USING testrun TYPE xflag
                     CHANGING xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  DATA: febko_ext    TYPE febkoxt_bf,
        febep_ext    TYPE febepxt_bf,
        febko_int    TYPE febkoin_bf,
        febep_int    TYPE febepin_bf.
  DATA: update_flag  TYPE boole_d,
        applk        TYPE applk_bf.
  DATA: febdoc       TYPE febdoc_bf OCCURS 0 WITH HEADER LINE.
  DATA: xmessages    TYPE balmt OCCURS 0 WITH HEADER LINE.
  DATA: message_lines LIKE sy-tabix.
  DATA: message_text LIKE sy-lisel.
  DATA: ret_code     LIKE sy-subrc.

  CHECK testl NE 'X'.
  CHECK ( bereich = '1' AND febep-b1err <> 'OK' )           "hw534210
     OR ( bereich = '2' AND febep-b2err <> 'OK' ).          "hw534210

  IF bereich = 1.
    CHECK NOT febep-b1app IS INITIAL.
    applk = febep-b1app.
  ELSE.
    CHECK NOT febep-b2app IS INITIAL.
    applk = febep-b2app.
  ENDIF.
  CLEAR: febko_ext, febep_ext, febko_int, febep_int.
  MOVE-CORRESPONDING febko TO: febko_int, febko_ext.
  MOVE-CORRESPONDING febep TO: febep_int, febep_ext.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM febvw WHERE anwnd = febko-anwnd AND "note 333419
*                                   absnd = febko-absnd AND "note 333419
*                                   azidt = febko-azidt.    
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM febvw WHERE anwnd = febko-anwnd AND "note 333419
                                   absnd = febko-absnd AND "note 333419
                                   azidt = febko-azidt ORDER BY PRIMARY KEY.    

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01"note 333419
  "note 333419
  IF sy-subrc IS INITIAL.                                  "note 333419
    MOVE-CORRESPONDING febvw TO: febko_ext.                "note 333419
  ENDIF.                                                   "note 333419

  PERFORM fill_xfebre.

   IF xtrwpr = 'X' AND function = 'C'.                         "hw853371
        EXPORT bereich                                         "hw853371
               febep-kukey                                     "hw853371
               febep-esnum                                     "hw853371
               komk                                            "hw853371
               xakon                                           "hw853371
               r_csnum                                         "hw853371
               vbkep                                           "hw853371
               xfebcl                                          "hw853371
               TO MEMORY ID 'FEBA_POST'.                       "hw853371
   ENDIF.                                                      "hw853371

  CALL FUNCTION 'OPEN_FI_PERFORM_00002810_P'
    EXPORTING
      i_febko_ext         = febko_ext
      i_febep_ext         = febep_ext
      i_febko_int         = febko_int
      i_febep_int         = febep_int
      i_applk             = applk
      i_posting_area      = bereich
      i_function          = function
      i_mode              = mode
      i_testrun           = testrun
    TABLES
      t_febre             = xfebre
      t_febcl             = xfebcl
      e_febdoc            = febdoc
      e_messages          = xmessages
    EXCEPTIONS
      nothing_active      = 1
      posting_error       = 2
      communication_error = 3
      too_many_functions  = 4
      OTHERS              = 5.
  ret_code = sy-subrc.

  IF xtrwpr = 'X' AND function = 'C'.                        "n972881
    FREE MEMORY ID 'FEBA_POST'.                              "n972881
  ENDIF.                                                     "n972881

  DESCRIBE TABLE xmessages LINES message_lines.
  read table xmessages with key                              "1074854
                      msgty = 'E' transporting no fields.    "1074854
  IF ret_code <> 0 OR sy-subrc eq 0.                         "1074854
    IF p_bupro = 'X'.
      PERFORM header_data CHANGING gt_header.                  "n1006705
      PERFORM write_item_header USING febep applk
                                CHANGING xt_fb01.
      g_open_fi_item_header = 'X'.                          "hw818056
    ENDIF.                                                  "hw531667
    IF ret_code = 1.
      EXIT.                                                 "note 530865
*----- Print Message if Call Trans and Posting Log (never for Lockbox)--
*      MSGID = 'FB'.
*      MSGNO = '090'.
*      MSGV1 = APPLK.
*      CLEAR: MSGV2, MSGV3, MSGV4.
*      IF  FUNCTION = 'C'
*      AND P_BUPRO  = 'X'.
*        PERFORM DRUCK_MESSAGE.
*      ENDIF.
*----- Save Message for Lockbox Posting Log ---------------------------
*      IF ANWND = '0003'                                     "
*      AND BEREICH NE '2'.                                   "30D
*        PERFORM SAVE_MESSAGE_FOR_LBOX_LOG USING BEREICH.    "
*      ENDIF.                                                "
    ELSEIF ret_code = 2 AND message_lines = 0.
*----- Print Message if Call Trans and Posting Log (never for Lockbox)--
      msgid = 'FB'.
      msgno = '091'.
      msgv1 = applk.
      msgv2 = bereich.
      CLEAR: msgv3, msgv4.
      IF  function = 'C'
      AND p_bupro  = 'X'.
        PERFORM druck_message CHANGING xt_fb01.
      ENDIF.
*----- Save Message for Lockbox Posting Log ---------------------------
      IF anwnd = '0003'                                     "
      AND bereich NE '2'.                                   "30D
        PERFORM save_message_for_lbox_log USING bereich.    "
      ENDIF.                                                "
    ELSEIF ret_code = 3.
*----- Print Message if Call Trans and Posting Log (never for Lockbox)--
      msgid = 'FB'.
      msgno = '092'.
      msgv1 = applk.
      msgv2 = '00002810'.
      CLEAR: msgv3, msgv4.
      IF  function = 'C'
      AND p_bupro  = 'X'.
        PERFORM druck_message CHANGING xt_fb01.
      ENDIF.
*----- Save Message for Lockbox Posting Log ---------------------------
      IF anwnd = '0003'                                     "
      AND bereich NE '2'.                                   "30D
        PERFORM save_message_for_lbox_log USING bereich.    "
      ENDIF.                                                "
    ELSEIF ret_code = 4.
*----- Print Message if Call Trans and Posting Log (never for Lockbox)--
      msgid = 'FB'.
      msgno = '093'.
      msgv1 = applk.
      msgv2 = '00002810'.
      CLEAR: msgv3, msgv4.
      IF  function = 'C'
      AND p_bupro  = 'X'.
        PERFORM druck_message CHANGING xt_fb01.
      ENDIF.
*----- Save Message for Lockbox Posting Log ---------------------------
      IF anwnd = '0003'                                     "
      AND bereich NE '2'.                                   "30D
        PERFORM save_message_for_lbox_log USING bereich.    "
      ENDIF.                                                "
    ELSEIF ret_code = 5.
*----- Print Message if Call Trans and Posting Log (never for Lockbox)--
      msgid = 'FB'.
      msgno = '094'.
      msgv1 = applk.
      msgv2 = '00002810'.
      CLEAR: msgv3, msgv4.
      IF  function = 'C'
      AND p_bupro  = 'X'.
        PERFORM druck_message CHANGING xt_fb01.
      ENDIF.
*----- Save Message for Lockbox Posting Log ---------------------------
      IF anwnd = '0003'                                     "
      AND bereich NE '2'.                                   "30D
        PERFORM save_message_for_lbox_log USING bereich.    "
      ENDIF.                                                "
    ELSE.
      Perform loop_xmessages tables xmessages               "1074854
                             changing xt_fb01.              "1074854
    ENDIF.

    statist-error = statist-error + 1.
    IF bereich = '1' AND ( ret_code = 2 OR ret_code = 3     "hw534210
                           or message_lines > 0 ).          "hw815768
      febep-b1std = 'X'.                                    "hw534210
    ENDIF.                                                  "hw534210
    IF bereich = '2' AND ( ret_code = 2 OR ret_code = 3     "hw534210
                           or message_lines > 0 ).          "hw815768
      febep-b2std = 'X'.                                    "hw534210
    ENDIF.                                                  "hw534210
  ELSE.
*-- posting ok --

    IF bereich = '1'.
      IF febep-b1std = 'X'.                                 "hw534210
        febep-vb1ok = 'X'.                                  "hw534210
        febep-belnr = '*'.                                  "hw534210
      ELSE.                                                 "hw534210
        CLEAR febep-vb1ok.                                  "hw534210
        CLEAR febep-belnr.                                  "hw534210
      ENDIF.                                                "hw534210
      febep-b1err = 'OK'.                                   "hw534210
      READ TABLE febdoc INDEX 1.
      IF sy-subrc <> 0.
        CLEAR febdoc.
      ENDIF.
      UPDATE febep SET   vb1ok = febep-vb1ok                "hw534210
                         belnr = febep-belnr                "hw534210
                         b1doc = febdoc-docno
                         b1typ = febdoc-doctype
                         b1err = febep-b1err                "hw534210
                   WHERE kukey = febep-kukey
                     AND esnum = febep-esnum.
    ELSE.
      IF febep-b2std = 'X'.                                 "hw534210
        febep-vb2ok = 'X'.                                  "hw534210
        febep-nbbln = '*'.                                  "hw534210
      ELSE.                                                 "hw534210
        CLEAR febep-vb2ok.                                  "hw534210
        CLEAR febep-nbbln.                                  "hw534210
      ENDIF.                                                "hw534210
      febep-b2err = 'OK'.                                   "hw534210
      READ TABLE febdoc INDEX 1.
      IF sy-subrc <> 0.
        CLEAR febdoc.
      ENDIF.
      UPDATE febep SET   vb2ok = febep-vb2ok                "hw534210
*                         belnr = '*'      "note 497818
                         nbbln = febep-nbbln                "hw534210
                         b2doc = febdoc-docno
                         b2typ = febdoc-doctype
                         b2err = febep-b2err                "hw534210
                   WHERE kukey = febep-kukey
                     AND esnum = febep-esnum.
    ENDIF.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    perform write_open_fi_doc using febep        applk
*                                    febdoc-docno febdoc-doctype.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    PERFORM header_data CHANGING gt_header.                    "n1006705
    PERFORM write_open_fi_doc USING febep        applk
                                    febdoc-docno febdoc-doctype
                              CHANGING xt_fb01.

    Perform loop_xmessages tables xmessages                    "n1118126
                           changing xt_fb01.                   "n1118126

************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  ENDIF.
ENDFORM.                               " OPEN_FI_POSTING
*&---------------------------------------------------------------------*
*&      Form  WRITE_OPEN_FI_DOC
*&---------------------------------------------------------------------*
*form write_open_fi_doc using febep   structure febep
*                             applk   type applk_bf
*                             docno   type doc_number
*                             doctype type awtyp.
*
*  if p_bupro = 'X'.
*    reserve 3 lines.
**    uline.
*    write: /01     sy-vline,
*            02(05) febep-esnum,
*            08(04) febep-vgint,
*            14(27) febep-vgext,
*            83(03) febep-kwaer,        "ok - mpEURO
*            88(16) febep-kwbtr currency febep-kwaer.      "ok - mpEURO
*
*    if not febep-fwbtr is initial.     "INSERT - mpEURO
*      write: 106(01) '(',              "INSERT - mpEURO
*             107(03) febep-fwaer,      "INSERT - mpEURO
*             112(16) febep-fwbtr currency febep-fwaer, "INSERT - mpEURO
*             130(01) ')'.              "INSERT - mpEURO
*    endif.                             "INSERT - mpEURO
*
*    write:  132    sy-vline.
*    char132 = text-126.
*    replace '&' with docno into char132.
*    replace '&' with doctype into char132.
*    replace '&' with applk into char132.
*    condense char132.
*    write: /01      sy-vline,
*            14(110) char132,
*            132     sy-vline.
*  endif.
************************************************************************
FORM write_open_fi_doc USING febep   STRUCTURE febep
                             applk   TYPE applk_bf
                             docno   TYPE doc_number
                             doctype TYPE awtyp
                       CHANGING xt_fb01 LIKE gt_fb01_1.
  DATA: ls_fb01 TYPE fagl_acc_s_rfebbu00_alv.
  DATA: lv_index TYPE sy-tabix.
  CLEAR ls_fb01.
  ls_fb01-esnum       = febep-esnum.
  ls_fb01-vgint      = febep-vgint.
  ls_fb01-vgext      = febep-vgext.
  ls_fb01-currency   = febep-kwaer.
  ls_fb01-amount     = febep-kwbtr.
  ls_fb01-bername    = bername.

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
  ls_fb01-bankl      = gs_header-bankl.
  ls_fb01-ktonr = gs_header-ktonr.
  ls_fb01-aznum = gs_header-aznum.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*
  ls_fb01-kukey     = febko-kukey.                "n853370
  ls_fb01-mappe     = mappe.

  APPEND ls_fb01 TO xt_fb01.
  IF NOT febep-fwbtr IS INITIAL.
    ls_fb01-currency   = febep-kwaer.
    ls_fb01-amount     = febep-kwbtr.
    ls_fb01-bername    = bername.
  ENDIF.

  CLEAR lv_index.
  DESCRIBE TABLE xt_fb01 LINES lv_index.
  READ TABLE xt_fb01 INTO ls_fb01 INDEX lv_index.
  char132 = text-126.
  REPLACE '&' WITH docno INTO char132.
  REPLACE '&' WITH doctype INTO char132.
  REPLACE '&' WITH applk INTO char132.
  CONDENSE char132.
  ls_fb01-msg = char132.

  MODIFY xt_fb01 FROM ls_fb01 INDEX lv_index.

ENDFORM.                               " WRITE_OPEN_FI_DOC
*&---------------------------------------------------------------------*
*&      Form  CHECK_WRBTR_ENTRIES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_KUKEY  text
*      -->P_ESNUM  text
*----------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form check_wrbtr_entries using    p_kukey
*                                  p_esnum.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM check_wrbtr_entries USING    p_kukey
                                  p_esnum
                         CHANGING xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  DATA: wrbtr_hits TYPE i.
  DATA: l_kwbtr TYPE febep-kwbtr.                           "HW373882

  CLEAR l_kwbtr.                                            "HW373882
  LOOP AT xfebcl WHERE kukey = p_kukey
                 AND esnum = p_esnum
                 AND selfd = 'WRBTR'.

    wrbtr_hits = wrbtr_hits + 1.

    IF febep-fwaer IS INITIAL OR bereich = '1'.
*      no original transaction currency provided or posting area = 1.
      IF ( febko-efart = 'M' AND febko-anwnd = '0002' )     "HW373882
        OR febep-vb2ba = 'U'.                               "hw559499
        l_kwbtr = l_kwbtr + xfebcl-selvon.                  "HW373882
      ELSE.                                                 "HW373882
        xfebcl-selvon = febep-kwbtr.
      ENDIF.                                                "HW373882
    ELSE.
*      original transaction currency provided and posting area = 2.
      xfebcl-selvon = febep-fwbtr.
    ENDIF.

    MODIFY xfebcl.

  ENDLOOP.

  IF ( febko-efart = 'M' AND febko-anwnd = '0002' )         "HW373882
        OR febep-vb2ba = 'U'.                               "hw559499
    IF l_kwbtr = febep-kwbtr.                               "HW373882
      wrbtr_hits = 1.                                       "HW373882
    ELSE.                                                   "HW373882
      wrbtr_hits = 2.                                       "HW373882
    ENDIF.                                                  "HW373882
  ENDIF.                                                    "HW373882

  IF wrbtr_hits GT 1.
*    more than 1 entries with 'WRBTR' in XFEBCL -> delete all
    DELETE xfebcl WHERE kukey = p_kukey
                    AND esnum = p_esnum
                    AND selfd = 'WRBTR'.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    perform druck_info_xfebcl_delete using wrbtr_hits.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    PERFORM druck_info_xfebcl_delete USING wrbtr_hits
                                     CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  ENDIF.

ENDFORM.                               " CHECK_WRBTR_ENTRIES
*&---------------------------------------------------------------------*
*&      Form  DRUCK_INFO_XFEBCL_DELETE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WRBTR_HITS  text
*----------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form druck_info_xfebcl_delete using    p_wrbtr_hits.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM druck_info_xfebcl_delete USING p_wrbtr_hits
                              CHANGING xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  IF p_bupro = 'X'.
    msgid = 'FB'.
    msgno = '085'.
    CLEAR: msgv1, msgv2, msgv3, msgv4.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*          perform druck_message.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    PERFORM druck_message CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  ENDIF.

ENDFORM.                               " DRUCK_INFO_XFEBCL_DELETE
*&---------------------------------------------------------------------*
*&      Form  DETERMINE_ALTERN_POSTING_AREA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_AD_VGINT  text
*      -->P_AD_BEREICH  text
*      -->P_AD_KWAER  text
*      -->P_X_APA_DEF  text
*----------------------------------------------------------------------*
FORM determine_altern_posting_area USING    p_ad_vgint
                                            p_ad_bereich
                                            p_ad_kwaer
                                            p_x_apa_def
                                            p_alt_sakn1
                                            p_alt_sakn2.

  DATA:    alt_bereich   LIKE ikofi-eigr2,
           i_kfmod LIKE ikofi-komo1.

  IF p_ad_bereich = '1'.
    alt_bereich = '2'.
  ELSEIF p_ad_bereich = '2'.
    alt_bereich = '1'.
  ELSE.
    EXIT.
  ENDIF.

  i_kfmod = febep-kfmod.

  CALL FUNCTION 'ACCOUNT_DETERMINATION'
    EXPORTING
      i_anwnd            = '0001'
      i_eigr1            = p_ad_vgint
      i_eigr2            = alt_bereich
      i_eigr3            = '  '
      i_eigr4            = '  '
      i_fpart            = ' '
      i_komo1            = i_kfmod
      i_komo2            = p_ad_kwaer
      i_ktopl            = febko-ktopl
      i_sakin            = febko-hkont
      i_sakinb           = febko-hkont                      "mp45A
    IMPORTING
      e_ikofi            = ikofi
    EXCEPTIONS
      input_missing      = 1
      input_wrong        = 2
      schema_not_found   = 4
      replace_impossible = 5.

  CASE sy-subrc.
    WHEN 0.
*       alternate posting area defined
      p_x_apa_def = 'X'.
      p_alt_sakn1 = ikofi-sakn1.
      p_alt_sakn2 = ikofi-sakn2.
    WHEN 4.
*       only one posting area defined
      CLEAR: p_x_apa_def.
  ENDCASE.

  CLEAR: ikofi.

ENDFORM.                               " DETERMINE_ALTERN_POSTING_AREA
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_PROCESS_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEXT_011  text
*----------------------------------------------------------------------*
FORM display_process_status USING    p_text.

  IF sy-batch NE 'X'.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        text = p_text.

  ENDIF.

ENDFORM.                               " DISPLAY_PROCESS_STATUS
*&---------------------------------------------------------------------*
*&      Form  CHECK_POSTING_RULES_CONSISTENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IKOFI_SAKN1  text
*      -->P_IKOFI_SAKN2  text
*      -->P_ALT_SAKN1  text
*      -->P_ALT_SAKN2  text
*----------------------------------------------------------------------*
FORM check_posting_rules_consistent USING    p_ikofi_sakn1
                                             p_ikofi_sakn2
                                             p_alt_sakn1
                                             p_alt_sakn2.

  IF p_ikofi_sakn1 NE p_alt_sakn2 AND
     p_ikofi_sakn2 NE p_alt_sakn1.
*       common interim account for posting area 1+2 not defined
    MESSAGE s086 WITH p_ikofi_sakn1
                      p_ikofi_sakn2
                      p_alt_sakn1
                      p_alt_sakn2.
  ENDIF.


ENDFORM.                               " CHECK_POSTING_RULES_CONSISTENT

*---------------------------------------------------------------------*
*  FORM get_dynamic_account
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
*  -->  P_IKOFI_SAKN1
*  -->  P_IKOFI_SAKN2
*  -->  P_ALT_SAKN1
*  -->  P_ALT_SAKN2
*---------------------------------------------------------------------*
FORM get_dynamic_account            USING    p_ikofi_sakn1
                                             p_ikofi_sakn2.
  TABLES: t038.
  DATA: l_bseg TYPE bseg.
  IF ikofi-attr2 = 4 OR ikofi-attr2 = 7.
* dynamic account is on credit side
    IF ikofi-ktos2 = '\DYNAMIC\'.
* take the area one document's debit side as the account
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM bseg INTO l_bseg
*                            WHERE bukrs = febko-bukrs
*                              AND belnr = febep-belnr
*                              AND shkzg = 'S'.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM bseg INTO l_bseg
                            WHERE bukrs = febko-bukrs
                              AND belnr = febep-belnr
                              AND shkzg = 'S' ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc = 0.
* final check: is this a bank subaccount?
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM t038
*          WHERE selek = l_bseg-hkont.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM t038
          WHERE selek = l_bseg-hkont ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc = 0.
          ikofi-sakn2 = l_bseg-hkont.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
* dynamic account is on debit side
    IF ikofi-ktos1 = '\DYNAMIC\'.
* take the area one document's crebit side as the account
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM bseg INTO l_bseg
*                            WHERE bukrs = febko-bukrs
*                              AND belnr = febep-belnr
*                              AND shkzg = 'H'.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM bseg INTO l_bseg
                            WHERE bukrs = febko-bukrs
                              AND belnr = febep-belnr
                              AND shkzg = 'H' ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc = 0.
* final check: is this a bank subaccount?
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM t038
*          WHERE selek = l_bseg-hkont.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM t038
          WHERE selek = l_bseg-hkont ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc = 0.
          ikofi-sakn1 = l_bseg-hkont.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "get_dynamic_account

*&---------------------------------------------------------------------*
*&      Form  CHECK_CURRENCY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CURRENT_BUKRS  text
*      -->P_KWAER  text
*      -->P_SUBRC  text
*----------------------------------------------------------------------*
FORM check_local_currency USING    p_bukrs
                                   p_kwaer
                                   p_subrc.

  DATA: p_t001 LIKE t001.

  p_subrc = 1.
  READ TABLE local_table WITH KEY bukrs = p_bukrs.
  IF sy-subrc = 0.
    IF local_table-waers = p_kwaer.
      p_subrc = 0.
    ENDIF.
  ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM t001 INTO p_t001
*                              WHERE bukrs = p_bukrs.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM t001 INTO p_t001
                              WHERE bukrs = p_bukrs ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc = 0.
      local_table-bukrs = p_t001-bukrs.
      local_table-waers = p_t001-waers.
      APPEND local_table.
      IF p_t001-waers = p_kwaer.
        p_subrc = 0.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                               " CHECK_CURRENCY

*----------------------------------------------------------------------*
* FORM CHECK_IF_COST_RELEVANT                                          *
*                                                                      *
* Checks if account is cost-relevant.                                  *
*                                                                      *
* import:                                                              *
*   BAC_SAKNR - G/L account number                                     *
* export:                                                              *
*   BAC_XBILK - Flag for cost-relevance                                *
*----------------------------------------------------------------------*
*FORM CHECK_IF_COST_RELEVANT USING CRC_SAKNR CRC_FLAG.
*
*TABLES:
*  TKA02.
*
*DATA:
*
*  XCSKBV LIKE CSKBV,
*  XKOKRS LIKE TKA02-KOKRS.
*
*STATICS:  BEGIN OF XTKA02 OCCURS 0.
*            INCLUDE STRUCTURE TKA02.
*STATICS:  END OF XTKA02.
*
*STATICS:  BEGIN OF XKSTAR OCCURS 0,
*            KOKRS LIKE TKA02-KOKRS,
*            KSTAR LIKE CSKB-KSTAR,
*            FLAG  TYPE C.
*STATICS:  END OF XKSTAR.
*
*
*  READ TABLE XTKA02 WITH KEY BUKRS = FEBKO-BUKRS.
*
*  IF SY-SUBRC <> 0.
**-- we just ignore the business area in table TKA02 - should be ok
*    SELECT SINGLE KOKRS FROM  TKA02 INTO XKOKRS
*                        WHERE BUKRS = FEBKO-BUKRS.
*    IF SY-SUBRC <> 0.
*      MESSAGE E593 WITH FEBKO-BUKRS.
*    ENDIF.
*
*    XTKA02-BUKRS = FEBKO-BUKRS.
*    XTKA02-KOKRS = XKOKRS.
*    APPEND XTKA02.
*
*  ENDIF.
*
*  READ TABLE XKSTAR WITH KEY KSTAR = CRC_SAKNR
*                             KOKRS = XTKA02-KOKRS.
*
*
*  IF SY-SUBRC <> 0.
*
*    CALL FUNCTION 'RK_KSTAR_CHECK'
*      EXPORTING
*        DATUM  = SY-DATUM
*        KOKRS  = XTKA02-KOKRS
*        KSTAR  = CRC_SAKNR
*      IMPORTING
*        V_CSKB = XCSKBV
*      EXCEPTIONS
*        KSTAR_NOT_ALLOWED = 1
*        KSTAR_NOT_FOUND   = 2
*        KSTAR_NOT_PRIMARY = 3
*        OTHERS            = 4.
*
**-- only catch not_found, other error-conditions should
**-- result in error-message on dynpro to inform user
*    IF SY-SUBRC = 2 OR XCSKBV-KATYP = '90'.
*      CRC_FLAG = FALSE.
*    ELSE.
*      CRC_FLAG = TRUE.
*    ENDIF.
*
*    XKSTAR-KOKRS = XTKA02-KOKRS.
*    XKSTAR-KSTAR = CRC_SAKNR.
*    XKSTAR-FLAG  = CRC_FLAG.
*    APPEND XKSTAR.
*  ELSE.
*    CRC_FLAG = XKSTAR-FLAG.
*  ENDIF.
*
*ENDFORM.                                        "CHECK_IF_COST_RELEVANT

*----------------------------------------------------------------------*
* FORM FTPOST_FIELDSELECT                                              *
*                                                                      *
*----------------------------------------------------------------------*
FORM ftpost_fieldselect TABLES t_ftpost STRUCTURE ftpost
                        USING  i_febep  LIKE      febep
                               i_febko  LIKE      febko.

  TABLES:
    tmodu.

  STATICS:
    tcashed TYPE c,
*-- local buffer
    BEGIN OF xtmodu OCCURS 0,
      feldn LIKE tmodu-feldn,
      modif LIKE tmodu-modif,
    END OF xtmodu,

    BEGIN OF xfslbu OCCURS 0,
      bukrs LIKE febko-bukrs,
      bschl LIKE bseg-bschl,
      koart LIKE tbsl-koart,
      hkont LIKE bseg-hkont,
      akont LIKE vf_kred-akont,
      faus1 LIKE tbsl-faus1,
      faus2 LIKE tbsl-faus2,
    END OF xfslbu.

  DATA:
    xbschl        LIKE bseg-bschl,
    xhkont        LIKE bseg-hkont,
    xvf_debi      LIKE vf_debi,
    xvf_kred      LIKE vf_kred,
    xkunnr        LIKE knb1-kunnr,
    xlifnr        LIKE lfb1-lifnr,
    xkoart        LIKE tbsl-koart,
    xakont        LIKE vf_kred-akont,
    xcount        LIKE ftpost-count,
    n             LIKE tmodu-modif,
    c500(500)     TYPE c,
    xtbsl         LIKE tbsl,
    dynpronr      LIKE TSTC-DYPNO.                             "n1062244

  IF tcashed IS INITIAL.
*-- fill local buffer
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM tmodu WHERE fauna = 'T156B-FAUSW'
*                        AND   tabnm = 'COBL'
*                        AND   koart = space
*                        AND   umsks = space.
*
* NEW CODE
    SELECT *
 FROM tmodu WHERE fauna = 'T156B-FAUSW'
                        AND   tabnm = 'COBL'
                        AND   koart = space
                        AND   umsks = space ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      MOVE-CORRESPONDING tmodu TO xtmodu.
      APPEND xtmodu.
    ENDSELECT.
    tcashed = 'X'.
  ENDIF.

  DO.

    clear xfslbu.                                "851113
    clear: xbschl, xkoart, xhkont, xakont.

    xfslbu-bukrs = i_febko-bukrs.

    IF ( sy-index = 1 ) AND ( NOT ikofi-bukr1 IS INITIAL ).
      xfslbu-bukrs = ikofi-bukr1.
    ENDIF.

    IF ( sy-index = 2 ) AND ( NOT ikofi-bukr2 IS INITIAL ).
      xfslbu-bukrs = ikofi-bukr2.
    ENDIF.

    xcount = sy-index.
    READ TABLE t_ftpost WITH KEY stype = 'P'
                                 count = xcount
                                 fnam  = 'BSEG-BSCHL'.
    IF NOT sy-subrc IS INITIAL.
*-- exit do-loop
      EXIT.
    ENDIF.
    xbschl = t_ftpost-fval.
    READ TABLE t_ftpost WITH KEY stype = 'P'
                                 count = xcount
                                 fnam  = 'BSEG-HKONT'.
    IF NOT sy-subrc IS INITIAL.
*-- exit do-loop
      EXIT.
    ENDIF.

    XHKONT = T_FTPOST-FVAL.                          "851113
    xfslbu-bschl = xbschl.

*-- XKOART determined by XBSCHL
    READ TABLE xfslbu WITH KEY bukrs = i_febko-bukrs
                               bschl = xbschl.

    IF NOT sy-subrc IS INITIAL.

      xfslbu-hkont = '-'.
      xfslbu-koart = '-'.
      xfslbu-akont = '-'.
      CLEAR xfslbu-faus1.
      CLEAR xfslbu-faus2.

      CALL FUNCTION 'FI_POSTING_KEY_CHECK'
        EXPORTING
          i_bschl      = xbschl
          x_bschl_only = 'X'
        EXCEPTIONS
          OTHERS       = 1.

      IF NOT sy-subrc IS INITIAL.
        APPEND xfslbu.
*-- continue with next do-loop
        CONTINUE.
      ENDIF.

      CALL FUNCTION 'FI_POSTING_KEY_DATA'
        EXPORTING
          i_bschl      = xbschl
          x_bschl_only = 'X'
        IMPORTING
          e_tbsl       = xtbsl
        EXCEPTIONS
          OTHERS       = 1.

      IF (     ( NOT xtbsl-koart = 'S' )
           AND ( NOT xtbsl-koart = 'D' )
           AND ( NOT xtbsl-koart = 'K' ) )
         OR  ( NOT sy-subrc IS INITIAL ).
*-- this one not a recognized account - skip it
        APPEND xfslbu.
*-- continue with next do-loop
        CONTINUE.
      ENDIF.
      XKOART = XTBSL-KOART.
    ELSE.
      XKOART = xfslbu-koart.
    ENDIF.

*-- XAKONT determined by BSCHL, XHKONT
    READ TABLE XFSLBU WITH KEY BUKRS = I_FEBKO-BUKRS        "851113
                               BSCHL = XBSCHL
                               KOART = XKOART
                               HKONT = XHKONT.
    IF NOT SY-SUBRC IS INITIAL.
      IF XKOART = 'D'.
*-- this one not a G/L - account - determine reconciliation account
        xkunnr = t_ftpost-fval.
        CALL FUNCTION 'FI_CUSTOMER_DATA'
          EXPORTING
            i_bukrs = i_febko-bukrs
            i_kunnr = xkunnr
          IMPORTING
            e_debi  = xvf_debi
          EXCEPTIONS
            OTHERS  = 1.

        IF sy-subrc IS INITIAL AND ( NOT xvf_debi-akont IS INITIAL ).
          xakont = xvf_debi-akont.
        ENDIF.

      ELSEIF XKOART = 'K'.
        xlifnr = t_ftpost-fval.
        CALL FUNCTION 'FI_VENDOR_DATA'
          EXPORTING
            i_bukrs = i_febko-bukrs
            i_lifnr = xlifnr
          IMPORTING
            e_kred  = xvf_kred
          EXCEPTIONS
            OTHERS  = 1.

        IF sy-subrc IS INITIAL AND ( NOT xvf_kred-akont IS INITIAL ).
          xakont = xvf_kred-akont.
        ENDIF.
      ELSE.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = xhkont
        IMPORTING
          output = xhkont.
      xakont = xhkont.
    ENDIF.
    ELSE.                                                "851113
      XAKONT = XFSLBU-AKONT.
    ENDIF.

*-- FAUSL determined by BUKRS, XBSCHL, XAKONT
    READ TABLE XFSLBU WITH KEY BUKRS = I_FEBKO-BUKRS     "851113
                               BSCHL = XBSCHL
                               KOART = XKOART
                               AKONT = XAKONT.
    IF NOT sy-subrc IS INITIAL.
      xfslbu-hkont = xhkont.
      xfslbu-koart = xkoart.
      xfslbu-akont = xakont.

*-- unfortunately FI_FIELD_SELECTION_DETERMINE doesn't handle
*-- exceptions explicitely - therefore check before call
      CALL FUNCTION 'FI_GL_ACCOUNT_DATA'
        EXPORTING
          i_bukrs = xfslbu-bukrs
          i_saknr = xfslbu-akont
        EXCEPTIONS
          OTHERS  = 1.

      IF NOT sy-subrc IS INITIAL.
        EXIT.
      ENDIF.

      CALL FUNCTION 'FI_FIELD_SELECTION_DETERMINE'
        EXPORTING
          i_bschl     = xbschl
          i_bukrs     = xfslbu-bukrs
          i_saknr     = xfslbu-akont
        IMPORTING
          e_faus1     = xfslbu-faus1
          e_faus2     = xfslbu-faus2
        EXCEPTIONS
          customizing = 1
          OTHERS      = 2.
      IF NOT sy-subrc IS INITIAL.
        EXIT.
      ENDIF.
      APPEND xfslbu.
    ENDIF.

*-- following loop is skipped for koart = 'D' - t_ftpost doesn't contain
*-- any cost-relevant lines (i.e. COBL ) in this case
    LOOP AT t_ftpost WHERE   stype   = 'P'
                       AND   count   = xcount
                       AND ( fnam(5) = 'COBL-' OR
                             fnam    = 'BSEG-GSBER' OR
                             fnam    = 'BSEG-VALUT' ).

      IF t_ftpost-fnam = 'BSEG-VALUT'.

        CALL FUNCTION 'NEXT_DYNPRO_SEARCH'               "start n1062244
          EXPORTING
            I_BSCHL        = xbschl
*           I_BSTAT        = ' '
            I_BUKRS        = xfslbu-bukrs
*           I_MWART        = ' '
*           I_MWSKZB       = ' '
*           I_MWSKZS       = ' '
            I_TCODE        = tcode
            I_UMSKZ        = ' '
*           I_BUZID        = ' '
            I_WINFK        = ' '
*           I_KTOSL        = ' '
          IMPORTING
            E_DYNNRA       = dynpronr
*           E_MPOOL        =
*           E_WINNRZ       =
          EXCEPTIONS
*           BSCHL_NF       = 1
*           BUKRS_NF       = 2
*           DYNNR_NF       = 3
*           NO_BSCHL       = 4
*           NO_BUKRS       = 5
*           NO_TCODE       = 6
*           TCODD_NF       = 7
*           TCODM_NF       = 8
*           WINNR_NF       = 9
            OTHERS         = 10
                  .
        IF SY-SUBRC = 0.
           IF dynpronr = 0301 OR dynpronr = 0302.
             DELETE t_ftpost WHERE stype = 'P'
                        AND   count = xcount
                        AND   fnam  = t_ftpost-fnam.
             CONTINUE.
           ELSE.
             n = 6.
           ENDIF.
        ELSE.                                              "end n1062244
          n = 6.
        ENDIF.

      ELSE.
        READ TABLE xtmodu WITH KEY feldn = t_ftpost-fnam+5.
        IF NOT sy-subrc IS INITIAL.
          EXIT.
        ENDIF.
        n = xtmodu-modif.
      ENDIF.
      c500    = xfslbu-faus1.
      c500+90 = xfslbu-faus2.                                    "871210
      n = n - 1.
      SHIFT c500 BY n PLACES.
      IF c500(1) = '-'.
        DELETE t_ftpost WHERE stype = 'P'
                        AND   count = xcount
                        AND   fnam  = t_ftpost-fnam.
      ENDIF.
    ENDLOOP.
  ENDDO.

ENDFORM.                               "FTPOST_FIELDSELECT

*----------------------------------------------------------------------*
* FORM DELETE_REMADV                                                   *
*                                                                      *
*----------------------------------------------------------------------*
FORM delete_remadv.
  DATA: xavik   LIKE avik.

  CLEAR xavik.
  IF r_csnum IS INITIAL.
    xavik-avsid = febep-avsid.
  ELSE.
    LOOP AT xfebcl WHERE kukey = febep-kukey AND
                         esnum = febep-esnum AND
                         csnum = r_csnum.
      xavik-avsid = xfebcl-selvon.
    ENDLOOP.
  ENDIF.

  xavik-konto = febep-avkon.
  xavik-koart = febep-avkoa.
  xavik-bukrs = febko-bukrs.
  CHECK NOT xavik-avsid IS INITIAL.
  CHECK NOT xavik-konto IS INITIAL.
  CHECK NOT xavik-koart IS INITIAL.
  CHECK NOT xavik-bukrs IS INITIAL.

*-- Delete Advice --
  CALL FUNCTION 'REMADV_DELETE'
    EXPORTING
      i_avik          = xavik
      i_popup         = ' '
      i_without_check = 'X'
    EXCEPTIONS
      cancel          = 1
      ko              = 2
      not_allowed     = 3
      ok              = 4
      OTHERS          = 5.

  CALL FUNCTION 'REMADV_SAVE_DB_ALL'
    EXPORTING
      i_dialog_update = 'X'.

ENDFORM.                               " DELETE_REMADV

*----------------------------------------------------------------------*
* Form  APPEND_REFNO_DOCS                                              *
*                                                                      *
* Note 206022                                                          *
*----------------------------------------------------------------------*
FORM append_refno_docs USING selvon LIKE febcl-selvon.

  DATA:
    refno(10) TYPE n.

  DATA: BEGIN OF dta_belege OCCURS 50.
          INCLUDE STRUCTURE dta_belege.
  DATA: END OF dta_belege.

*  CLEAR FTCLEAR.

  refno = selvon.

  CALL FUNCTION 'GET_DOCUMENTS'
    EXPORTING
      i_belege     = 'X'
      i_refno      = refno
      i_regut      = space
    TABLES
      tab_belege   = dta_belege
    EXCEPTIONS
      no_documents = 01
      no_regut     = 02
      wrong_number = 03.

  IF sy-subrc IS INITIAL.
    LOOP AT dta_belege.
      IF dta_belege-pyord IS INITIAL.
        ftclear-selfd  = 'BELNR'.
        ftclear-selvon = dta_belege-belnr.
        ftclear-selvon+10(4) = dta_belege-gjahr.            "hw380697
        ftclear-agkon  = dta_belege-ubhkt.
      ELSE.
        ftclear-selfd  = 'PYORD'.
        ftclear-selvon = dta_belege-pyord.
        CLEAR ftclear-agkon.
      ENDIF.
      ftclear-agbuk  = dta_belege-bukrs.
      ftclear-agkoa  = 'S'.
      APPEND ftclear.
    ENDLOOP.
  ENDIF.

*-- for posting protocol
  ftclear-selfd  = 'REFNO'.
  ftclear-selvon = refno.

ENDFORM.                               " APPEND_REFNO_DOCS

*&---------------------------------------------------------------------*
*&      Form  add_on_acc_doc_to_ftclear                     "note 452579
*&---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form add_on_acc_doc_to_ftclear                            "note 452579
*             using u_akbln like febep-akbln
*                   u_avkoa like febep-avkoa.                "hw638124
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM add_on_acc_doc_to_ftclear
             USING u_akbln LIKE febep-akbln
                   u_avkoa LIKE febep-avkoa
                   u_saknr like ikofi-sakn1                 "hw750835
             CHANGING xt_fb01 LIKE gt_fb01_1.
  DATA: wa_ftclear TYPE ftclear, l_avkoa LIKE febep-avkoa,  "hw638124
        l_avkon like febep-avkon.                           "hw750835

  IF NOT febep-avkoa IS INITIAL                             "hw638124
    and ( g_clear_on_account <> 'C' or u_avkoa <> 'S' ).    "hw750835
    l_avkoa = febep-avkoa.                                  "hw638124
  ELSE.                                                     "hw638124
    l_avkoa = u_avkoa.                                      "hw638124
  ENDIF.                                                    "hw638124
  if ( g_clear_on_account <> 'C' or u_avkoa <> 'S' ).       "hw750835
    l_avkon = febep-avkon.                                  "hw750835
  else.                                                     "hw750835
* Die Buchungsregel wurde nicht geändert und Sachkonto: Auf jeden
* Fall Sachkonto aus der Kontenfindung übernehmen, analog zu
* fb05_ftclear_sako
    l_avkon = u_saknr.                                      "hw750835
  endif.                                                    "hw750835
  LOOP AT xfebcl WHERE koart = l_avkoa                      "hw638124
    AND agkon = l_avkon.
    IF xfebcl-agbuk IS INITIAL.
      wa_ftclear-agbuk = febko-bukrs.
    ELSE.
      wa_ftclear-agbuk = xfebcl-agbuk.
    ENDIF.
    EXIT.
  ENDLOOP.
  wa_ftclear-xnops  = 'X'.
  wa_ftclear-agkoa  = l_avkoa.                              "hw638124
  wa_ftclear-agkon  = l_avkon.                              "hw750835
  wa_ftclear-selfd = 'BELNR'.
  wa_ftclear-selvon = u_akbln.

  APPEND wa_ftclear TO ftclear.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*  perform druck_buzei_ftclear using wa_ftclear-agkon.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
  PERFORM druck_buzei_ftclear USING wa_ftclear-agkon
                              CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
ENDFORM.                        "add_on_acc_doc_to_ftclear  "note 452579

*&---------------------------------------------------------------------*
*&      Form  get_worklist_and_noclear                         "fk020801
*&---------------------------------------------------------------------*

FORM get_worklist_and_noclear
     USING     u_febko TYPE febko
     CHANGING  c_worklist TYPE tfavw-ident
               c_worklist_items LIKE worklist_items
               c_noclear TYPE c.

  DATA: l_t028b TYPE t028b,
        l_febvw TYPE febvw.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * INTO l_febvw FROM febvw
*            WHERE anwnd = u_febko-anwnd
*              AND absnd = u_febko-absnd
*              AND azidt = u_febko-azidt.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  INTO l_febvw FROM febvw
            WHERE anwnd = u_febko-anwnd
              AND absnd = u_febko-absnd
              AND azidt = u_febko-azidt ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * INTO l_t028b FROM t028b
*         WHERE  bankl = l_febvw-bankl
*           AND  ktonr = u_febko-ktonr.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  INTO l_t028b FROM t028b
         WHERE  bankl = l_febvw-bankl
           AND  ktonr = u_febko-ktonr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc <> 0.
*  -- 2. try: KTONR = '+' ?
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * INTO l_t028b FROM t028b
*                  WHERE  bankl = l_febvw-bankl
*                    AND  ktonr = '+'.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  INTO l_t028b FROM t028b
                  WHERE  bankl = l_febvw-bankl
                    AND  ktonr = '+' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc <> 0.
*  -- 3. try with alternat. bank-account number if avail.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM t012k WHERE bukrs = u_febko-bukrs
*                                   AND hbkid = u_febko-hbkid
*                                   AND hktid = u_febko-hktid.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM t012k WHERE bukrs = u_febko-bukrs
                                   AND hbkid = u_febko-hbkid
                                   AND hktid = u_febko-hktid ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc = 0 AND NOT t012k-bnkn2 IS INITIAL.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * INTO l_t028b FROM t028b
*                      WHERE bankl = l_febvw-bankl
*                        AND ktonr = t012k-bnkn2.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  INTO l_t028b FROM t028b
                      WHERE bankl = l_febvw-bankl
                        AND ktonr = t012k-bnkn2 ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      ENDIF.
    ENDIF.
  ENDIF.

  IF NOT l_t028b IS INITIAL.
    c_noclear  = l_t028b-noclear.
    c_worklist = l_t028b-worklist.
  ENDIF.

  IF NOT c_worklist IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * INTO TABLE c_worklist_items FROM tfavw
*             WHERE objct = 'SAKNR'
*             AND ident = c_worklist.
*
* NEW CODE
    SELECT *
 INTO TABLE c_worklist_items FROM tfavw
             WHERE objct = 'SAKNR'
             AND ident = c_worklist ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  ENDIF.

ENDFORM.                                       "get_worklist_and_noclear


*&---------------------------------------------------------------------*
*&      Form  worklist_to_ftclear                              "fk020801
*&---------------------------------------------------------------------*

FORM worklist_to_ftclear.

  IF ( sy-tcode = 'FEBA' OR sy-tcode = 'FEBAN' )  "subsequent processing
       AND febko-anwnd = '0001'               "electronic bank statement
       AND NOT worklist IS INITIAL
       AND NOT worklist_items IS INITIAL
       AND '45' CA ikofi-attr2.       "clear G/L account in debit/credit
    LOOP AT ftclear.
      CHECK ftclear-agkoa = 'S'.
      READ TABLE worklist_items
           WITH KEY value = ftclear-agkon
           TRANSPORTING NO FIELDS.
      CHECK sy-subrc = 0.      "only if the account is in the worklist
      ftclear-agkon = worklist.           "worklist instead of account
      MODIFY ftclear.
    ENDLOOP.
  ENDIF.

ENDFORM.                                           " worklist_to_ftclear

*&---------------------------------------------------------------------*
*&      Form  check_noclear                                    "fk020801
*&---------------------------------------------------------------------*

FORM check_noclear .

  DATA: wrbtr_only TYPE boolean.

  wrbtr_only = 1.                              "true: only WRBTR-entries
  IF     febko-anwnd = '0001'                 "electronic bank statement
     AND noclear = 'X'.
    LOOP AT ftclear.
      IF ftclear-selfd <> 'WRBTR'.
        wrbtr_only = 0.                                           "false
        EXIT.
      ENDIF.
    ENDLOOP.
    IF wrbtr_only = 1.
      LOOP AT ftclear.
        ftclear-selfd = 'BELNR'.
        ftclear-selvon = '*'.
        CLEAR ftclear-selbis.
        MODIFY ftclear.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                                                  "check_noclear

*****************BEGIN PROCESS RETURNS FK051201*************************

*&---------------------------------------------------------------------*
*&      Form process_returns
*&---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form process_returns tables t_febcl structure xfebcl
*                      using u_febko type febko
*                            u_area type c
*                            u_mode type c
*                   changing c_febep type febep
*                            c_exit type c.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM process_returns TABLES t_febcl STRUCTURE xfebcl
                      USING u_febko TYPE febko
                            u_area TYPE c
                            u_mode TYPE c
                   CHANGING c_febep TYPE febep
                            c_exit TYPE c
                            xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  DATA: l_gjahr TYPE bkpf-gjahr,
        l_augbl TYPE bkpf-belnr,
        l_bvorg TYPE bkpf-bvorg,
        lt_docs LIKE STANDARD TABLE OF docs_structure,
        l_doc LIKE LINE OF lt_docs,
        lt_cleared_items LIKE STANDARD TABLE OF postab,
        l_returns_vgint TYPE t028y-returns_vgint,
        l_charges_vgint TYPE t028y-charges_vgint,
        l_reset_clear TYPE t028y-reset_clear,
        l_clear_resetted TYPE c,
        l_febep_doc TYPE borident,
        lt_msg LIKE STANDARD TABLE OF bdcmsgcoll,
        l_rrint TYPE t028x-rrint,               "internal return reason
        l_bukrs TYPE febko-bukrs,
        l_xreset_clear TYPE c,
        l_doc_change TYPE c,
        l_all_ok TYPE c,
        l_bseg_doc TYPE borident,
        l_msg LIKE LINE OF lt_msg,
        l_xdoc_found TYPE c,
        lt_neighbors TYPE STANDARD TABLE OF neighbor,
        l_neighbor LIKE LINE OF lt_neighbors.

  CONCATENATE u_febko-kukey c_febep-esnum INTO l_febep_doc-objkey.
  l_febep_doc-objtype = 'BUS4498'.
  l_rrint = c_febep-kkref+27(3).
  l_bukrs = u_febko-bukrs.

  CHECK NOT l_rrint IS INITIAL.

  CALL FUNCTION 'FIEB_GET_RETURN_ACTIVITIES'
    EXPORTING
      i_rrint         = l_rrint
    IMPORTING
      e_reset_clear   = l_reset_clear
      e_returns_vgint = l_returns_vgint
    EXCEPTIONS
      OTHERS          = 1.

  CHECK sy-subrc = 0.

  CHECK l_reset_clear = 'X' AND u_area = '2'.

  CHECK c_febep-vgint = l_returns_vgint.  "reset clear only with the
  "posting rule in t028y!

  PERFORM initialize_returns_stati USING l_reset_clear
                                CHANGING c_febep.

  CLEAR l_augbl.
  IF  c_febep-kkref+30(1) = 'N'.               "reset clear not yet done
    PERFORM find_documents    TABLES t_febcl
                                     lt_msg
                                     lt_cleared_items
                               USING l_febep_doc
                                     u_area
                            CHANGING l_bukrs
                                     l_gjahr
                                     l_augbl
                                     l_bvorg
                                     l_xdoc_found.
    IF l_xdoc_found = 'X'.
      c_febep-kkref+30(1) = 'F'.   "document for reset clearing is found
    ENDIF.
  ENDIF.
  IF  c_febep-kkref+30(1) = 'F'.  "document for reset clearing was found
    IF l_augbl IS INITIAL.
      CALL FUNCTION 'SREL_GET_NEXT_NEIGHBORS'
        EXPORTING
          object       = l_febep_doc
          relationtype = 'EB05'
          max_hops     = '01'                                  "n1133686
        TABLES
          neighbors    = lt_neighbors
        EXCEPTIONS
          OTHERS       = 1.

      LOOP AT lt_neighbors INTO l_neighbor.
        l_bukrs = l_neighbor(4).
        l_augbl = l_neighbor+4(10).
        l_gjahr = l_neighbor+14(4).
        EXIT.
      ENDLOOP.
    ENDIF.

    PERFORM check_reset_clear USING l_bukrs l_gjahr l_augbl
                           CHANGING l_xreset_clear.

    PERFORM post_reset_clear TABLES lt_msg
                            USING l_bukrs l_gjahr l_augbl
                                  l_febep_doc u_mode u_area
                                  l_xreset_clear
                         CHANGING l_clear_resetted.

    IF l_clear_resetted = 'X'.
      c_febep-kkref+30(1) = 'X'.                     "rest clear done
    ENDIF.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    perform print_reset_clear using l_bukrs l_gjahr l_augbl.
*    perform print_messages tables lt_msg.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    PERFORM print_reset_clear USING l_bukrs l_gjahr l_augbl
                              CHANGING xt_fb01.
    PERFORM print_messages TABLES lt_msg
                           CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
    CLEAR lt_msg[].
  ELSEIF c_febep-kkref+30(1) = 'N' AND NOT u_mode = 'N'.  "begin n898966

    l_xreset_clear = 'E'.     "E = Error <= No cleared document found

    PERFORM post_reset_clear TABLES lt_msg
                             USING l_bukrs l_gjahr l_augbl
                                   l_febep_doc u_mode u_area
                                   l_xreset_clear
                             CHANGING l_clear_resetted.

    IF l_clear_resetted = 'X'.

      c_febep-kkref+30(1) = 'X'.                     "reset clear done

      LOOP at vb_error.

        if vb_error-zeile cs '873'.
          delete vb_error.
        endif.

      ENDLOOP.

    ENDIF.                                                  "end n898966

  ENDIF.

  IF  c_febep-kkref+30(1) = 'X'                        "reset clear done
      AND c_febep-kkref+31(1) = 'N'.                "change docs not yet

    PERFORM get_docs TABLES lt_msg
                            lt_docs
                      USING l_rrint
                            l_febep_doc.

************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    perform change_documents tables lt_msg
*                                    lt_docs
*                              using l_febep_doc.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    PERFORM change_documents TABLES lt_msg
                                    lt_docs
                              USING l_febep_doc
                              CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
    l_all_ok = 'X'.
    LOOP AT lt_docs INTO l_doc.
      l_bseg_doc-objkey+0(4)  = l_doc-bukrs.              "note 836048
      l_bseg_doc-objkey+4(10) = l_doc-belnr.              "note 836048
      l_bseg_doc-objkey+14(4) = l_doc-gjahr.              "note 836048
      l_bseg_doc-objkey+18(3) = l_doc-buzei.              "note 836048
      l_bseg_doc-objtype = 'BSEG'.

      IF l_doc-status CA 'BC-'.
* change relation type between doc and FEBEP from
* EB06 ('To be changed') to EB07 ('Was changed') or EB08 ('Batch Input')
        CALL FUNCTION 'BINARY_RELATION_DELETE'
          EXPORTING
            obj_rolea    = l_febep_doc
            obj_roleb    = l_bseg_doc
            relationtype = 'EB06'
          EXCEPTIONS
            OTHERS       = 1.
        IF sy-subrc <> 0.
          l_msg-msgid = sy-msgid.
          l_msg-msgnr = sy-msgno.
          l_msg-msgv1 = sy-msgv1.
          l_msg-msgv2 = sy-msgv2.
          l_msg-msgv3 = sy-msgv3.
          l_msg-msgv4 = sy-msgv4.
          APPEND l_msg TO lt_msg.
          EXIT.
        ENDIF.

        IF l_doc-status = 'C'.
          CALL FUNCTION 'BINARY_RELATION_CREATE'
            EXPORTING
              obj_rolea    = l_febep_doc
              obj_roleb    = l_bseg_doc
              relationtype = 'EB07'
            EXCEPTIONS
              OTHERS       = 1.
          IF sy-subrc <> 0.
            l_msg-msgid = sy-msgid.
            l_msg-msgnr = sy-msgno.
            l_msg-msgv1 = sy-msgv1.
            l_msg-msgv2 = sy-msgv2.
            l_msg-msgv3 = sy-msgv3.
            l_msg-msgv4 = sy-msgv4.
            APPEND l_msg TO lt_msg.
          ENDIF.
        ELSEIF l_doc-status = 'B'.
          CALL FUNCTION 'BINARY_RELATION_CREATE'
            EXPORTING
              obj_rolea    = l_febep_doc
              obj_roleb    = l_bseg_doc
              relationtype = 'EB08'
            EXCEPTIONS
              OTHERS       = 1.
          IF sy-subrc <> 0.
            l_msg-msgid = sy-msgid.
            l_msg-msgnr = sy-msgno.
            l_msg-msgv1 = sy-msgv1.
            l_msg-msgv2 = sy-msgv2.
            l_msg-msgv3 = sy-msgv3.
            l_msg-msgv4 = sy-msgv4.
            APPEND l_msg TO lt_msg.
          ENDIF.
        ELSEIF l_doc-status = '-'.
          CALL FUNCTION 'BINARY_RELATION_CREATE'
            EXPORTING
              obj_rolea    = l_febep_doc
              obj_roleb    = l_bseg_doc
              relationtype = 'EB10'
            EXCEPTIONS
              OTHERS       = 1.
          IF sy-subrc <> 0.
            l_msg-msgid = sy-msgid.
            l_msg-msgnr = sy-msgno.
            l_msg-msgv1 = sy-msgv1.
            l_msg-msgv2 = sy-msgv2.
            l_msg-msgv3 = sy-msgv3.
            l_msg-msgv4 = sy-msgv4.
            APPEND l_msg TO lt_msg.
          ENDIF.
        ENDIF.
      ELSE.
        CLEAR l_all_ok.
      ENDIF.
    ENDLOOP.

    IF l_all_ok = 'X'.
      c_febep-kkref+31(1) = 'X'.
    ENDIF.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    perform print_messages tables lt_msg.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    PERFORM print_messages TABLES lt_msg
                           CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  ENDIF.

  UPDATE febep SET kkref = c_febep-kkref WHERE kukey = c_febep-kukey
                                           AND esnum = c_febep-esnum.

  IF febep-kkref+30(2) CA 'NF'.
    c_exit = true.
  ENDIF.
ENDFORM.                                                "process_returns

*&---------------------------------------------------------------------*
*&      Form  find_documents
*&---------------------------------------------------------------------*

FORM find_documents TABLES t_febcl STRUCTURE xfebcl
                              ct_msg  STRUCTURE bdcmsgcoll
                              t_cleared_items STRUCTURE postab
                        USING u_febep_doc TYPE borident
                              u_area TYPE c
                     CHANGING c_bukrs TYPE bkpf-bukrs
                              c_gjahr TYPE bkpf-gjahr
                              c_augbl TYPE bkpf-belnr
                              c_bvorg TYPE bkpf-bvorg
                              c_xdoc_found TYPE c.

  DATA: lt_bkpf TYPE STANDARD TABLE OF bkpf,
        l_bkpf TYPE bkpf,
        l_bukrs TYPE bkpf-bukrs,
        l_bseg_doc TYPE borident,
        l_bkpf_doc TYPE borident,
        lt_cleared_items LIKE STANDARD TABLE OF postab,
        l_cleared_item LIKE LINE OF t_cleared_items,
        l_msg LIKE LINE OF ct_msg,
        l_ok TYPE c,
        l_lines TYPE i,
        l_cleared_lines TYPE i,
        l_xfound TYPE c.

  LOOP AT t_febcl WHERE selfd = 'BELNR'.
    SELECT * FROM bkpf INTO l_bkpf
      WHERE bukrs = c_bukrs
      AND   belnr = xfebcl-selvon
      ORDER BY gjahr.                             "take the newest one
    ENDSELECT.
    IF sy-subrc = 0.
      CALL FUNCTION 'GET_CLEARED_ITEMS'
        EXPORTING
          i_belnr = l_bkpf-belnr
          i_bukrs = l_bkpf-bukrs
          i_gjahr = l_bkpf-gjahr
          i_bvorg = l_bkpf-bvorg
        TABLES
          t_items = lt_cleared_items
        EXCEPTIONS
          OTHERS  = 1.
      IF sy-subrc = 0.
        IF l_xfound = 'X'.       "more than 1 clearing docs was found:
          CLEAR l_xfound.        "therefore don't reset clearing
          EXIT.
        ENDIF.
        l_xfound = 'X'.
        c_bukrs = l_bkpf-bukrs.
        c_gjahr = l_bkpf-gjahr.
        c_augbl = l_bkpf-belnr.
        c_bvorg = l_bkpf-bvorg.
        t_cleared_items[] = lt_cleared_items[].
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF l_xfound = 'X'.
    DELETE t_cleared_items WHERE belnr = c_augbl
                             AND bukrs = c_bukrs
                             AND gjahr = c_gjahr.

*   relate the clearing document to the statement
    l_bkpf_doc-objkey+0(4)  = c_bukrs.                  "note 836048
    l_bkpf_doc-objkey+4(10) = c_augbl.                  "note 836048
    l_bkpf_doc-objkey+14(4) = c_gjahr.                  "note 836048
    l_bkpf_doc-objtype = 'BKPF'.
    CALL FUNCTION 'BINARY_RELATION_CREATE'
      EXPORTING
        obj_rolea    = u_febep_doc
        obj_roleb    = l_bkpf_doc
        relationtype = 'EB05'
      EXCEPTIONS
        OTHERS       = 1.

    IF sy-subrc = 0.
      c_xdoc_found = 'X'.                         "Document is found
      LOOP AT t_cleared_items INTO l_cleared_item.
        CLEAR: l_bseg_doc.
        l_bseg_doc-objtype = 'BSEG'.
        l_bseg_doc-objkey+0(4)  = l_cleared_item-bukrs.     "note 836048
        l_bseg_doc-objkey+4(10) = l_cleared_item-belnr.     "note 836048
        l_bseg_doc-objkey+14(4) = l_cleared_item-gjahr.     "note 836048
        l_bseg_doc-objkey+18(3) = l_cleared_item-buzei.     "note 836048
*   relate the docs to the statement
        CALL FUNCTION 'BINARY_RELATION_CREATE'
          EXPORTING
            obj_rolea    = u_febep_doc
            obj_roleb    = l_bseg_doc
            relationtype = 'EB06'
          EXCEPTIONS
            OTHERS       = 1.
        IF sy-subrc <> 0.
          l_msg-msgid = sy-msgid.
          l_msg-msgnr = sy-msgno.
          l_msg-msgv1 = sy-msgv1.
          l_msg-msgv2 = sy-msgv2.
          l_msg-msgv3 = sy-msgv3.
          l_msg-msgv4 = sy-msgv4.
          APPEND l_msg TO ct_msg.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ELSE.
    CLEAR l_msg.
    l_msg-msgid = 'FB'.
    l_msg-msgnr = '873'.
    PERFORM append_vb_error USING l_msg.
  ENDIF.

ENDFORM.                                                 "find_documents

*&---------------------------------------------------------------------*
*&      Form  post_reset_clear
*&
*& c_clear_resetted = 'X', if it was resetted
*& c_clear_resetted = ' ', if it is not resetted
*&---------------------------------------------------------------------*

FORM post_reset_clear TABLES ct_msg STRUCTURE bdcmsgcoll
                      USING  u_bukrs TYPE bkpf-bukrs
                             u_gjahr TYPE bkpf-gjahr
                             u_augbl TYPE bkpf-belnr
                             u_febep_doc TYPE borident
                             u_mode TYPE c
                             u_area TYPE c
                             u_xreset_clear TYPE c
                   CHANGING  c_clear_resetted TYPE c.

  DATA: l_subrc TYPE sy-subrc,
        lt_neighbors TYPE STANDARD TABLE OF neighbor,
        lt_neighbors_lines TYPE i,
        l_msg LIKE LINE OF ct_msg.

  IF u_xreset_clear = 'Y'.
    IF open = false.
      PERFORM posting_interface_start.
    ENDIF.
    IF testl NE 'X'.
      IF function = 'B'.                    "create batch-input session
        CALL FUNCTION 'POSTING_INTERFACE_RESET_CLEAR'
          EXPORTING
            i_tcode = 'FBRA'
            i_augbl = u_augbl
            i_bukrs = u_bukrs
            i_gjahr = u_gjahr
          IMPORTING
            e_subrc = l_subrc
            e_msgid = msgid
            e_msgty = msgty
            e_msgno = msgno
            e_msgv1 = msgv1
            e_msgv2 = msgv2
            e_msgv3 = msgv3
            e_msgv4 = msgv4
          EXCEPTIONS
            OTHERS  = 1.
        IF sy-subrc <> 0 OR l_subrc <> 0.
          l_msg-msgid = msgid.
          l_msg-msgnr = msgno.
          l_msg-msgv1 = msgv1.
          l_msg-msgv2 = msgv2.
          l_msg-msgv3 = msgv3.
          l_msg-msgv4 = msgv4.
          APPEND l_msg TO ct_msg.
        ELSE.
          c_clear_resetted = 'X'.
        ENDIF.
      ELSE.                                            "call transaction
        CALL FUNCTION 'CALL_FBRA'
          EXPORTING
            i_bukrs = u_bukrs
            i_augbl = u_augbl
            i_gjahr = u_gjahr
            i_mode  = u_mode
          EXCEPTIONS
            OTHERS  = 1.
        IF sy-subrc = 0.
          c_clear_resetted = 'X'.
        ELSE.
          l_msg-msgid = sy-msgid.
          l_msg-msgnr = sy-msgno.
          l_msg-msgv1 = u_augbl.
          l_msg-msgv2 = u_bukrs.
          l_msg-msgv3 = u_gjahr.
          APPEND l_msg TO ct_msg.
        ENDIF.
      ENDIF.   "(function)
    ENDIF.    "(testl)
  ELSEIF u_xreset_clear = 'N'.
    CLEAR l_msg.
    l_msg-msgid = 'FB'.
    l_msg-msgnr = '734'.
    l_msg-msgv1 = u_augbl.
    l_msg-msgv2 = u_bukrs.
    l_msg-msgv3 = u_gjahr.
    PERFORM append_vb_error USING l_msg.
  ELSEIF u_xreset_clear = 'E'.
    IF NOT u_mode = 'N'.                                    "n898966
      CALL FUNCTION 'CALL_FBRA'                             "n898966
        EXPORTING
          i_bukrs = u_bukrs
          i_augbl = u_augbl
          i_gjahr = u_gjahr
          i_mode  = u_mode
        EXCEPTIONS
          OTHERS  = 1.
      IF sy-subrc = 0.
        c_clear_resetted = 'X'.
      ELSE.
        l_msg-msgid = sy-msgid.
        l_msg-msgnr = sy-msgno.
        l_msg-msgv1 = u_augbl.
        l_msg-msgv2 = u_bukrs.
        l_msg-msgv3 = u_gjahr.
        APPEND l_msg TO ct_msg.
      ENDIF.
    ELSE.
      CLEAR l_msg.
    l_msg-msgid = sy-msgid.
    l_msg-msgnr = sy-msgno.
    l_msg-msgv1 = sy-msgv1.
    l_msg-msgv2 = sy-msgv2.
    l_msg-msgv3 = sy-msgv3.
    l_msg-msgv4 = sy-msgv4.
    PERFORM append_vb_error USING l_msg.
    ENDIF.
  ENDIF.                                            "(l_xreset_clearing)

ENDFORM.                                               "post_reset_clear

*&---------------------------------------------------------------------*
*&      Form  check_reset_clear
*&---------------------------------------------------------------------*
*  returns c_xreset_clear with the values:
*
* 'Y' = reset clearing is possible without reversing document
* 'N' = reversing document is obligatory
* 'E' = reset clearing is not possible because of an other reason
*----------------------------------------------------------------------*

FORM check_reset_clear USING u_bukrs TYPE bkpf-bukrs
                             u_gjahr TYPE bkpf-gjahr
                             u_augbl TYPE bkpf-belnr
                    CHANGING c_xreset_clear TYPE c.

  DATA: l_xstor TYPE c.

  CALL FUNCTION 'CALL_FBRA'
    EXPORTING
      i_bukrs      = u_bukrs
      i_augbl      = u_augbl
      i_gjahr      = u_gjahr
      i_xsimu      = 'X'
    IMPORTING
      e_xstor      = l_xstor
    EXCEPTIONS
      not_possible = 1.
  IF sy-subrc = 0.
    IF l_xstor IS INITIAL.
      c_xreset_clear = 'Y'.
    ELSE.
      c_xreset_clear = 'N'. "no
    ENDIF.
  ELSE.
    c_xreset_clear = 'E'. "error
  ENDIF.
ENDFORM.                                              "check_reset_clear

*----------------------------------------------------------------------*
*&      Form  print_reset_clear
*&---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form print_reset_clear  using    u_bukrs type bkpf-bukrs
*                                 u_gjahr type bkpf-gjahr
*                                 u_augbl type bkpf-belnr.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM print_reset_clear  USING    u_bukrs TYPE bkpf-bukrs
                                 u_gjahr TYPE bkpf-gjahr
                                 u_augbl TYPE bkpf-belnr
                        CHANGING xt_fb01 LIKE gt_fb01_1.
  DATA: ls_fb01 TYPE fagl_acc_s_rfebbu00_alv.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  DATA l_doc TYPE string.

  IF p_bupro = 'X'.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    reserve 6 lines.
*    write: /01 sy-vline, 02 sy-uline(130), 132 sy-vline.
*    char80 = text-035.
*    concatenate u_augbl u_bukrs u_gjahr into l_doc separated by space.
*    replace '&' with l_doc into char80.
*    write: /01     sy-vline,
*            02(05) febep-esnum,
*            08(04) febep-vgint,
*            14(20) febep-vgext,
*            35(04) 'FBRA',
*            41(80) char80,
*            132    sy-vline.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    char80 = text-035.
    CONCATENATE u_augbl u_bukrs u_gjahr INTO l_doc SEPARATED BY space.
    REPLACE '&' WITH l_doc INTO char80.
    CLEAR ls_fb01.
    ls_fb01-esnum       = febep-esnum.
    ls_fb01-vgint      = febep-vgint.
    ls_fb01-vgext      = febep-vgext.
    ls_fb01-tcode      = 'FBRA'.
    ls_fb01-bername    = bername.
    ls_fb01-msg        = char80.

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
    ls_fb01-bankl      = gs_header-bankl.
    ls_fb01-ktonr   = gs_header-ktonr.
    ls_fb01-aznum   = gs_header-aznum.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*
    ls_fb01-kukey     = febko-kukey.                "n853370
    ls_fb01-mappe     = mappe.

    APPEND ls_fb01 TO xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  ENDIF.
ENDFORM.                                              "print_reset_clear

*&---------------------------------------------------------------------*
*&      Form  change_documents
*& c_doc_status = 'C', if call transaction mode and the doc was changed
*& c_doc_status = 'B', if batch input session was succesfully created
*&---------------------------------------------------------------------*

FORM change_document TABLES ct_msg STRUCTURE bdcmsgcoll
                     USING u_zahls TYPE t028z-zahls
                           u_mansp TYPE t028z-mansp
                           u_zlsch TYPE t028z-zlsch
                           u_zlsch_delete TYPE t028z-zlsch_delete
                           u_bukrs TYPE bkpf-bukrs
                           u_gjahr TYPE bkpf-gjahr
                           u_belnr TYPE bkpf-belnr
                           u_buzei TYPE bseg-buzei
                           u_ret_change_doc_exit TYPE
                                        REF TO if_ex_fieb_ret_change_doc
                  CHANGING c_doc_status TYPE char1.

  DATA: lt_all_msg TYPE STANDARD TABLE OF bdcmsgcoll,
        l_all_msg LIKE LINE OF lt_all_msg,
        l_koart TYPE bseg-koart,
        l_zlspr TYPE bseg-zlspr,
        l_msg LIKE LINE OF ct_msg,
        l_subrc TYPE sy-subrc,
        l_msgid TYPE sy-msgid,
        l_msgty TYPE sy-msgty,
        l_msgno TYPE sy-msgno,
        l_msgv1 TYPE sy-msgv1,
        l_msgv2 TYPE sy-msgv2,
        l_msgv3 TYPE sy-msgv3,
        l_msgv4 TYPE sy-msgv4,
        lt_this_febre TYPE STANDARD TABLE OF febre.

  l_zlspr = u_zahls.
  REFRESH bdcdata. CLEAR bdcdata.
  CHECK testl NE 'X'.
  IF NOT ( u_zahls IS INITIAL AND u_mansp IS INITIAL
     AND u_zlsch IS INITIAL AND u_zlsch_delete IS INITIAL ).

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM  bseg
*         WHERE  bukrs  = u_bukrs
*         AND    belnr  = u_belnr
*         AND    gjahr  = u_gjahr
*         AND    buzei  = u_buzei.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM  bseg
         WHERE  bukrs  = u_bukrs
         AND    belnr  = u_belnr
         AND    gjahr  = u_gjahr
         AND    buzei  = u_buzei ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    l_koart = bseg-koart.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM t001 WHERE bukrs = u_bukrs.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM t001 WHERE bukrs = u_bukrs ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

*   fill selection screen of FB09
    PERFORM bdc_start_dynpro USING 'SAPMF05L' '0102'.
    PERFORM bdc_add_field USING 'RF05L-BELNR' u_belnr.
    PERFORM bdc_add_field USING 'RF05L-BUKRS' u_bukrs.
    PERFORM bdc_add_field USING 'RF05L-GJAHR' u_gjahr.
    PERFORM bdc_add_field USING 'RF05L-BUZEI' u_buzei.

    PERFORM bdc_add_field USING 'BDC_OKCODE' '   '.

    PERFORM dynpro_determine USING l_koart.
    PERFORM bdc_start_dynpro USING 'SAPMF05L' t019-dynnr.

    IF NOT l_zlspr IS INITIAL.
      PERFORM bdc_add_field USING 'BSEG-ZLSPR' l_zlspr.
    ENDIF.

    IF bseg-umsks = space.                         "n1020581
      IF NOT u_mansp IS INITIAL.
      PERFORM bdc_add_field USING 'BSEG-MANSP' u_mansp.
    ENDIF.

    PERFORM bdc_add_field USING 'BDC_OKCODE' '/08'. "jump to 'more data'

*     determine dynpro number of popup screen
    IF l_koart = 'K'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM t019w WHERE mpool = 'SAPMF05L'
*                                   AND buvar = t001-buvar
*                                   AND winfk = 'ZKOK'.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM t019w WHERE mpool = 'SAPMF05L'
                                   AND buvar = t001-buvar
                                   AND winfk = 'ZKOK' ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc <> 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM t019w WHERE mpool = 'SAPMF05L'
*                                     AND buvar = space
*                                     AND winfk = 'ZKOK'.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM t019w WHERE mpool = 'SAPMF05L'
                                     AND buvar = space
                                     AND winfk = 'ZKOK' ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      ENDIF.
    ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM t019w WHERE mpool = 'SAPMF05L'
*                                   AND buvar = t001-buvar
*                                   AND winfk = 'ZKOD'.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM t019w WHERE mpool = 'SAPMF05L'
                                   AND buvar = t001-buvar
                                   AND winfk = 'ZKOD' ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc <> 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM t019w WHERE mpool = 'SAPMF05L'
*                                     AND buvar = space
*                                     AND winfk = 'ZKOD'.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM t019w WHERE mpool = 'SAPMF05L'
                                     AND buvar = space
                                     AND winfk = 'ZKOD' ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      ENDIF.
    ENDIF.

    PERFORM bdc_start_dynpro USING 'SAPMF05L' t019w-winnr.
      IF NOT u_zlsch_delete IS INITIAL.
        PERFORM bdc_add_field USING 'BSEG-ZLSCH' ' '.
      ELSEIF NOT u_zlsch IS INITIAL.
        PERFORM bdc_add_field USING 'BSEG-ZLSCH' u_zlsch.
      ENDIF.
    ELSE.
*     special G/L                                  n1020581
      IF NOT u_zlsch_delete IS INITIAL.
        PERFORM bdc_add_field USING 'BSEG-ZLSCH' ' '.
      ELSEIF NOT u_zlsch IS INITIAL.
        PERFORM bdc_add_field USING 'BSEG-ZLSCH' u_zlsch.
      ENDIF.

      PERFORM bdc_add_field USING 'BDC_OKCODE' '/08'. "jump to 'more data'

*     determine dynpro number of popup screen
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM t019w WHERE mpool = 'SAPMF05L'
*                                   AND buvar = t001-buvar
*                                   AND winfk = 'ZKOX'.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM t019w WHERE mpool = 'SAPMF05L'
                                   AND buvar = t001-buvar
                                   AND winfk = 'ZKOX' ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc <> 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM t019w WHERE mpool = 'SAPMF05L'
*                                     AND buvar = space
*                                     AND winfk = 'ZKOX'.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM t019w WHERE mpool = 'SAPMF05L'
                                     AND buvar = space
                                     AND winfk = 'ZKOX' ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      ENDIF.

      PERFORM bdc_start_dynpro USING 'SAPMF05L' t019w-winnr.
      IF NOT u_mansp IS INITIAL.
        PERFORM bdc_add_field USING 'BSEG-MANSP' u_mansp.
      ENDIF.
    ENDIF.                                         "n1020581
    PERFORM bdc_start_dynpro USING 'SAPMF05L' t019-dynnr.
    PERFORM bdc_add_field USING 'BDC_OKCODE' '/11'.

  ENDIF.

* now the customer can change BDCDATA in the BAdI to change other fields
* in the document.
  CLEAR: l_msg, l_subrc.
  REFRESH lt_this_febre.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM febre INTO TABLE lt_this_febre
*                      WHERE kukey = febko-kukey
*                      AND   esnum = febep-esnum.
*
* NEW CODE
  SELECT *
 FROM febre INTO TABLE lt_this_febre
                      WHERE kukey = febko-kukey
                      AND   esnum = febep-esnum ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  CALL METHOD u_ret_change_doc_exit->change_bdcdata
    EXPORTING
      i_febko   = febko
      i_febep   = febep
      t_febre   = lt_this_febre[]
      i_bukrs   = u_bukrs
      i_gjahr   = u_gjahr
      i_belnr   = u_belnr
      i_buzei   = u_buzei
    IMPORTING
      e_subrc   = l_subrc
      e_msgid   = l_msgid
      e_msgno   = l_msgno
      e_msgv1   = l_msgv1
      e_msgv2   = l_msgv2
      e_msgv3   = l_msgv3
      e_msgv4   = l_msgv4
    CHANGING
      t_bdcdata = bdcdata[].

  IF l_subrc <> 0 OR bdcdata IS INITIAL.
    l_msg-msgid = l_msgid.
    l_msg-msgnr = l_msgno.
    l_msg-msgv1 = l_msgv1.
    l_msg-msgv2 = l_msgv2.
    l_msg-msgv3 = l_msgv3.
    l_msg-msgv4 = l_msgv4.
    IF NOT l_msg IS INITIAL.
      APPEND l_msg TO ct_msg.
    ENDIF.
    c_doc_status = '-'.
    EXIT.
  ELSE.
    CLEAR: l_msg, l_subrc.
    tcode = 'FB09'.
    IF function EQ 'C'.
      CALL TRANSACTION tcode USING  bdcdata
                           MODE   mode
                           UPDATE 'S'.

      IF sy-subrc = 0 AND sy-msgid = 'F5' AND ( sy-msgno = '300' OR
                                                sy-msgno = '303' ).
        c_doc_status = 'C'.        "doc was changed via call transaction
      ELSE.
        l_msg-msgid = sy-msgid.
        l_msg-msgnr = sy-msgno.
        l_msg-msgv1 = sy-msgv1.
        l_msg-msgv2 = sy-msgv2.
        l_msg-msgv3 = sy-msgv3.
        l_msg-msgv4 = sy-msgv4.
        APPEND l_msg TO ct_msg.
      ENDIF.
    ELSE.                                           "batch-input session
      CALL FUNCTION 'BDC_INSERT'
        EXPORTING
          tcode     = tcode
        TABLES
          dynprotab = bdcdata
        EXCEPTIONS
          OTHERS    = 4.
      IF sy-subrc NE 0.
        l_msg-msgid = sy-msgid.
        l_msg-msgnr = sy-msgno.
        l_msg-msgv1 = sy-msgv1.
        l_msg-msgv2 = sy-msgv2.
        l_msg-msgv3 = sy-msgv3.
        l_msg-msgv4 = sy-msgv4.
        APPEND l_msg TO ct_msg.
      ELSE.
        c_doc_status = 'B'.      "BatchInputSession successfully created
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                                                "change_document

*&---------------------------------------------------------------------*
*&      Form  change_documents
*&---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form change_documents tables ct_msg structure bdcmsgcoll
*                             ct_docs structure docs_structure
*                       using u_febep_doc type borident.

************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM change_documents TABLES ct_msg STRUCTURE bdcmsgcoll
                             ct_docs STRUCTURE docs_structure
                       USING u_febep_doc TYPE borident
                       CHANGING xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  DATA: l_doc LIKE LINE OF ct_docs,
        l_msg LIKE LINE OF ct_msg,
        l_xfirst_printed TYPE c.

* badi
  CLASS cl_exithandler DEFINITION LOAD.
  DATA l_ret_change_doc_exit TYPE REF TO if_ex_fieb_ret_change_doc.
  CALL METHOD cl_exithandler=>get_instance
    CHANGING
      instance = l_ret_change_doc_exit.

  LOOP AT ct_docs INTO l_doc.
    PERFORM change_document TABLES ct_msg
                            USING l_doc-zahls
                                  l_doc-mansp
                                  l_doc-zlsch
                                  l_doc-zlsch_delete
                                  l_doc-bukrs
                                  l_doc-gjahr
                                  l_doc-belnr
                                  l_doc-buzei
                                  l_ret_change_doc_exit
                         CHANGING l_doc-status.

    IF l_doc-status CA 'BC'.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*      perform print_changed_document using l_doc-bukrs
*                                           l_doc-gjahr
*                                           l_doc-belnr
*                                           l_doc-buzei
*                                  changing l_xfirst_printed.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
      PERFORM print_changed_document USING l_doc-bukrs
                                           l_doc-gjahr
                                           l_doc-belnr
                                           l_doc-buzei
                                  CHANGING l_xfirst_printed
                                           xt_fb01.

************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
    ENDIF.
    MODIFY ct_docs FROM l_doc TRANSPORTING status.
  ENDLOOP.

ENDFORM.                                               "change_documents

*&---------------------------------------------------------------------*
*&      Form  print_changed_document
*&---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form print_changed_document using u_bukrs type bkpf-bukrs
*                                  u_gjahr type bkpf-gjahr
*                                  u_belnr type bkpf-belnr
*                                  u_buzei type bseg-buzei
*                                  c_xfirst_printed type c.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM print_changed_document USING u_bukrs TYPE bkpf-bukrs
                                  u_gjahr TYPE bkpf-gjahr
                                  u_belnr TYPE bkpf-belnr
                                  u_buzei TYPE bseg-buzei
                     CHANGING     c_xfirst_printed TYPE c
                                  xt_fb01 LIKE gt_fb01_1.
  DATA: ls_fb01 TYPE fagl_acc_s_rfebbu00_alv.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  DATA l_doc TYPE string.

  IF p_bupro = 'X'.
    CONCATENATE u_belnr u_buzei u_bukrs u_gjahr
              INTO l_doc SEPARATED BY space.
    IF c_xfirst_printed = ' '.
      c_xfirst_printed = 'X'.
    ENDIF.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*    reserve 6 lines.
*    if c_xfirst_printed = ' '.
*      write: /01 sy-vline, 02 sy-uline(130), 132 sy-vline.
*      c_xfirst_printed = 'X'.
*    endif.
*    char80 = text-050.
*    replace '&' in char80 with l_doc.
*    write: /01     sy-vline,
*            02(05) febep-esnum,
*            08(04) febep-vgint,
*            14(20) febep-vgext,
*            35(04) tcode,
*            41(80) char80,
*            132    sy-vline.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    CLEAR ls_fb01.
    ls_fb01-esnum       = febep-esnum.
    ls_fb01-vgint      = febep-vgint.
    ls_fb01-vgext      = febep-vgext.
    ls_fb01-tcode      = tcode.
    ls_fb01-bername    = bername.
    ls_fb01-msg        = char80.

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
    ls_fb01-bankl  = gs_header-bankl.
    ls_fb01-ktonr  = gs_header-ktonr.
    ls_fb01-aznum  = gs_header-aznum.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*
    ls_fb01-kukey     = febko-kukey.                "n853370
    ls_fb01-mappe     = mappe.

    APPEND ls_fb01 TO xt_fb01.
  ENDIF.
ENDFORM.                                         "print_changed_document

*&---------------------------------------------------------------------*
*&      Form  get_docs
*&---------------------------------------------------------------------*

FORM get_docs TABLES ct_msg STRUCTURE bdcmsgcoll
                     ct_docs STRUCTURE docs_structure
               USING u_rrint TYPE t028y-rrint
                     u_febep_doc TYPE borident.
  DATA: l_doc LIKE LINE OF ct_docs,
        lt_neighbors TYPE STANDARD TABLE OF neighbor,
        l_neighbor LIKE LINE OF lt_neighbors,
        l_msg LIKE LINE OF ct_msg,
        l_save_bukrs TYPE bkpf-bukrs,
        l_mansp TYPE t028z-mansp,
        l_zahls TYPE t028z-zahls,
        l_zlsch TYPE t028z-zlsch,
        l_zlsch_delete TYPE t028z-zlsch_delete.

  CALL FUNCTION 'SREL_GET_NEXT_NEIGHBORS'
    EXPORTING
      object       = u_febep_doc
      relationtype = 'EB06'
      max_hops     = '01'                                      "n1133686
    TABLES
      neighbors    = lt_neighbors
    EXCEPTIONS
      OTHERS       = 1.
  IF sy-subrc <> 0.
    l_msg-msgid = sy-msgid.
    l_msg-msgnr = sy-msgno.
    l_msg-msgv1 = sy-msgv1.
    l_msg-msgv2 = sy-msgv2.
    l_msg-msgv3 = sy-msgv3.
    l_msg-msgv4 = sy-msgv4.
    APPEND l_msg TO ct_msg.
  ELSE.
    LOOP AT lt_neighbors INTO l_neighbor.
      l_doc-bukrs = l_neighbor-objkey+0(4).
      l_doc-belnr = l_neighbor-objkey+4(10).
      l_doc-gjahr = l_neighbor-objkey+14(4).
      l_doc-buzei = l_neighbor-objkey+18(3).
      AT FIRST.
        l_save_bukrs = l_doc-bukrs.
        CALL FUNCTION 'FIEB_GET_CHANGE_DOC_ACTIVITIES'
          EXPORTING
            i_rrint        = u_rrint
            i_bukrs        = l_doc-bukrs
          IMPORTING
            e_mansp        = l_doc-mansp
            e_zahls        = l_doc-zahls
            e_zlsch        = l_doc-zlsch
            e_zlsch_delete = l_doc-zlsch_delete
          EXCEPTIONS
            OTHERS         = 1.
        IF sy-subrc <> 0.
          l_msg-msgid = sy-msgid.
          l_msg-msgnr = sy-msgno.
          l_msg-msgv1 = sy-msgv1.
          l_msg-msgv2 = sy-msgv2.
          l_msg-msgv3 = sy-msgv3.
          l_msg-msgv4 = sy-msgv4.
          APPEND l_msg TO ct_msg.
          l_doc-status = 'E'.                           "error status!
        ENDIF.
      ENDAT.
      IF l_save_bukrs <> l_doc-bukrs.
        l_save_bukrs = l_doc-bukrs.
        CALL FUNCTION 'FIEB_GET_CHANGE_DOC_ACTIVITIES'
          EXPORTING
            i_rrint        = u_rrint
            i_bukrs        = l_doc-bukrs
          IMPORTING
            e_mansp        = l_doc-mansp
            e_zahls        = l_doc-zahls
            e_zlsch        = l_doc-zlsch
            e_zlsch_delete = l_doc-zlsch_delete
          EXCEPTIONS
            OTHERS         = 1.
        IF sy-subrc <> 0.
          l_msg-msgid = sy-msgid.
          l_msg-msgnr = sy-msgno.
          l_msg-msgv1 = sy-msgv1.
          l_msg-msgv2 = sy-msgv2.
          l_msg-msgv3 = sy-msgv3.
          l_msg-msgv4 = sy-msgv4.
          APPEND l_msg TO ct_msg.
          l_doc-status = 'E'.                           "error status!
        ENDIF.
      ENDIF.
      APPEND l_doc TO ct_docs.
    ENDLOOP.
  ENDIF.
ENDFORM.                                                    "get_docs

*&---------------------------------------------------------------------*
*&      Form  print_messages
*&---------------------------------------------------------------------*
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*form print_messages  tables ut_msg structure bdcmsgcoll.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM print_messages  TABLES ut_msg STRUCTURE bdcmsgcoll
                     CHANGING xt_fb01 LIKE gt_fb01_1.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  DATA l_msg LIKE LINE OF ut_msg.

  CHECK p_bupro = 'X'.
  LOOP AT ut_msg INTO l_msg.
    msgid = l_msg-msgid.
    msgno = l_msg-msgnr.
    msgv1 = l_msg-msgv1.
    msgv2 = l_msg-msgv2.
    msgv3 = l_msg-msgv3.
    msgv4 = l_msg-msgv4.
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
*          perform druck_message.
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
    PERFORM druck_message CHANGING xt_fb01.
************************************************************************
***    End of ALV Conversion                     C5053248
************************************************************************
  ENDLOOP.
ENDFORM.                    " print_messages

*&---------------------------------------------------------------------*
*&      Form  initialize_returns_stati
*&---------------------------------------------------------------------*

FORM initialize_returns_stati
                    USING u_reset_clear TYPE t028y-reset_clear
                 CHANGING c_febep TYPE febep.
  DATA: l_doc_change TYPE c,
        l_rc_ok TYPE c, "rest clear ok is filled as follows:
*  '-', if no reset clearing necessary
*  'N', if there has to be a reset clearing but it's not done yet
*  'F', if the document for reset clearing was found, but it's not yet
*       done
*  'X', if the reset clearing was already done
        l_cd_ok TYPE c. "change documents ok in area 1, meaning:
*  '-', if no documents have to be changed in
*  'N', if some documents have to be changed
*  'X', if all documents were changed

  CHECK c_febep-kkref+30(2) IS INITIAL.

  IF u_reset_clear = 'X'.
    l_rc_ok = 'N'.
    l_cd_ok = 'N'.
  ELSE.
    l_rc_ok = '-'.
    l_cd_ok = '-'.
  ENDIF.
  c_febep-kkref+30(1) = l_rc_ok.
  c_febep-kkref+31(1) = l_cd_ok.
ENDFORM.                                       "initialize_returns_stati

*&---------------------------------------------------------------------*
*&      Form  append_vb_error
*&---------------------------------------------------------------------*

FORM append_vb_error USING u_msg TYPE bdcmsgcoll.

  DATA: l_string TYPE string,
        l_t100 TYPE t100.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t100 INTO l_t100
*          WHERE sprsl = sy-langu
*            AND arbgb = u_msg-msgid
*            AND msgnr = u_msg-msgnr.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t100 INTO l_t100
          WHERE sprsl = sy-langu
            AND arbgb = u_msg-msgid
            AND msgnr = u_msg-msgnr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  CONCATENATE text-113 text-112 INTO l_string.
  REPLACE '&' WITH u_msg-msgid INTO l_string.
  REPLACE '&' WITH u_msg-msgnr INTO l_string.
  CONCATENATE l_string l_t100-text INTO l_string SEPARATED BY space.
  REPLACE '&' WITH u_msg-msgv1 INTO l_string.
  REPLACE '&' WITH u_msg-msgv2 INTO l_string.
  REPLACE '&' WITH u_msg-msgv3 INTO l_string.
  REPLACE '&' WITH u_msg-msgv4 INTO l_string.
  CONDENSE l_string.

  CLEAR vb_error.
  vb_error-anwnd = febko-anwnd.
  vb_error-absnd = febko-absnd.
  vb_error-azidt = febko-azidt.
  vb_error-ktonr = febko-ktonr.
  vb_error-aznum = febko-aznum.
  vb_error-esnum = febep-esnum.
  vb_error-buber = bereich.
  vb_error-zeile = l_string.
  APPEND vb_error.
  statist-error = statist-error + 1.
ENDFORM.                                              " append_vb_error
*******************END PROCESS RETURNS FK05122001**********************
************************************************************************
**    Begin of comment                           C5053248
************************************************************************
**********************************************************************
* form write_item_header                                   "hw531667
**********************************************************************
*form write_item_header using febep   structure febep
*                             applk   type applk_bf.
*  reserve 3 lines.
*  uline.
*  write: /01     sy-vline,
*          02(05) febep-esnum,
*          08(04) febep-vgint,
*          14(27) febep-vgext,
*          44(06) applk,
*          83(03) febep-kwaer,
*          88(16) febep-kwbtr currency febep-kwaer.
*
*  if not febep-fwbtr is initial.
*    write: 106(01) '(',
*           107(03) febep-fwaer,
*           112(16) febep-fwbtr currency febep-fwaer,
*           130(01) ')'.
*  endif.
*endform.                               " WRITE_ITEM_HEADER
************************************************************************
***    End of comment                            C5053248
************************************************************************
************************************************************************
***    Begin of ALV Conversion                   C5053248
************************************************************************
FORM write_item_header USING febep   STRUCTURE febep
                             applk   TYPE applk_bf
                       CHANGING xt_fb01 LIKE gt_fb01_1.
  DATA: ls_fb01 TYPE fagl_acc_s_rfebbu00_alv.
  CLEAR ls_fb01.
  ls_fb01-esnum       = febep-esnum.
  ls_fb01-vgint      = febep-vgint.
  ls_fb01-vgext      = febep-vgext.
  ls_fb01-blart      = applk.
  ls_fb01-currency   = febep-kwaer.
  ls_fb01-amount     = febep-kwbtr.
  ls_fb01-bername    = bername.

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
  ls_fb01-bankl = gs_header-bankl.
  ls_fb01-ktonr = gs_header-ktonr.
  ls_fb01-aznum = gs_header-aznum.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*

  APPEND ls_fb01 TO xt_fb01.
  IF NOT febep-fwbtr IS INITIAL.
    CLEAR   ls_fb01.
    ls_fb01-bername    = bername.
    ls_fb01-currency   = febep-kwaer.
    ls_fb01-amount     = febep-kwbtr.

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
    ls_fb01-bankl      = gs_header-bankl.
    ls_fb01-ktonr   = gs_header-ktonr.
    ls_fb01-aznum   = gs_header-aznum.
    APPEND ls_fb01 TO xt_fb01.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*
    ls_fb01-kukey     = febko-kukey.                "n853370
    ls_fb01-mappe     = mappe.

  ENDIF.

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
*  APPEND ls_fb01 TO xt_fb01.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*

ENDFORM.                               " WRITE_ITEM_HEADER
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT_ALV
*&---------------------------------------------------------------------*
*       BUILD A FIELD CATALOG FOR ALV
*----------------------------------------------------------------------*
*      <--XT_FIELDCAT  FIELD CATALOG ALV
*----------------------------------------------------------------------*
FORM build_fieldcat_alv USING iv_counter TYPE i
                        CHANGING xt_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: ls_fcat TYPE slis_fieldcat_alv.
  DATA: lt_fcat TYPE slis_t_fieldcat_alv.

  CASE iv_counter.
    WHEN 1.
      CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name       = gc_str
        CHANGING
          ct_fieldcat            = lt_fcat
        EXCEPTIONS
          inconsistent_interface = 1
          program_error          = 2
          OTHERS                 = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      ls_fcat-tabname = gc_1l.
      MODIFY lt_fcat FROM ls_fcat TRANSPORTING tabname
        WHERE tabname NE ls_fcat-tabname.
      APPEND LINES OF lt_fcat TO xt_fieldcat.

      LOOP AT xt_fieldcat INTO ls_fcat.
        CASE ls_fcat-fieldname.
*          WHEN 'ESNUM'.
*            ls_fcat-seltext_l = text-301.
*            ls_fcat-seltext_m = text-301.
*            ls_fcat-seltext_s = text-301.
*            ls_fcat-ddictxt   = gc_s.
*          WHEN 'VGINT'.
*            ls_fcat-seltext_l = text-302.
*            ls_fcat-seltext_m = text-302.
*            ls_fcat-seltext_s = text-302.
*            ls_fcat-ddictxt   = gc_s.
*          WHEN 'VGEXT'.
*            ls_fcat-seltext_l = text-303.
*            ls_fcat-seltext_m = text-303.
*            ls_fcat-seltext_s = text-303.
*            ls_fcat-ddictxt   = gc_s.
*          WHEN 'TCODE'.
*            ls_fcat-seltext_l = text-304.
*            ls_fcat-seltext_m = text-304.
*            ls_fcat-seltext_s = text-304.
*            ls_fcat-ddictxt   = gc_s.
*          WHEN 'BUZEI'.
*            ls_fcat-seltext_l = text-305.
*            ls_fcat-seltext_m = text-305.
*            ls_fcat-seltext_s = text-305.
*            ls_fcat-ddictxt   = gc_s.
*          WHEN 'blart'.
*            ls_fcat-seltext_l = text-306.
*            ls_fcat-seltext_m = text-306.
*            ls_fcat-seltext_s = text-306.
*            ls_fcat-ddictxt   = gc_s.
*          WHEN 'BSCHL'.
*            ls_fcat-seltext_l = text-307.
*            ls_fcat-seltext_m = text-307.
*            ls_fcat-seltext_s = text-307.
*            ls_fcat-ddictxt   = gc_s.
          WHEN 'SAKNR'.
            ls_fcat-seltext_l = text-308.
            ls_fcat-seltext_m = text-308.
            ls_fcat-seltext_s = text-308.
            ls_fcat-ddictxt   = gc_m.
          WHEN 'TXT20'.
            ls_fcat-seltext_l = text-309.
            ls_fcat-seltext_m = text-309.
            ls_fcat-seltext_s = text-309.
            ls_fcat-ddictxt   = gc_m.
*          WHEN 'CURRENCY'.
*            ls_fcat-seltext_l = text-310.
*            ls_fcat-seltext_m = text-310.
*            ls_fcat-seltext_s = text-310.
*            ls_fcat-ddictxt   = gc_s.
          WHEN 'AMOUNT'.
            ls_fcat-no_zero = 'X'.
            ls_fcat-cfieldname = 'CURRENCY'.
*            ls_fcat-seltext_m = text-311.
*            ls_fcat-seltext_s = text-311.
*            ls_fcat-ddictxt   = gc_s.
*          WHEN 'SELFD'.
*            ls_fcat-seltext_l = text-312.
*            ls_fcat-seltext_m = text-312.
*            ls_fcat-seltext_s = text-312.
*            ls_fcat-ddictxt   = gc_s.
          WHEN 'SELVON'.
            ls_fcat-seltext_l = text-313.
            ls_fcat-seltext_m = text-313.
            ls_fcat-seltext_s = text-313.
            ls_fcat-ddictxt   = gc_m.
          WHEN 'BERNAME'.
            ls_fcat-no_out = gc_chk.
          WHEN 'MSG'.
            ls_fcat-seltext_l = text-329.
            ls_fcat-seltext_m = text-329.
            ls_fcat-seltext_s = text-329.
            ls_fcat-ddictxt   = gc_m.
          WHEN  'BANKL'.
            ls_fcat-tech      = gc_chk.
          WHEN  'KTONR'.
            ls_fcat-tech      = gc_chk.
          WHEN  'AZNUM'.
            ls_fcat-tech      = gc_chk.
          WHEN 'WAERS'.
            ls_fcat-no_out    = 'X'.
        ENDCASE.
        MODIFY xt_fieldcat FROM ls_fcat.
      ENDLOOP.

      CLEAR lt_fcat.
      CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name       = gc_str2
        CHANGING
          ct_fieldcat            = lt_fcat
        EXCEPTIONS
          inconsistent_interface = 1
          program_error          = 2
          OTHERS                 = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      ls_fcat-tabname = gc_1h.
      MODIFY lt_fcat FROM ls_fcat TRANSPORTING tabname
        WHERE tabname NE ls_fcat-tabname.
      APPEND LINES OF lt_fcat TO xt_fieldcat.

      LOOP AT xt_fieldcat INTO ls_fcat.
        CASE ls_fcat-fieldname.
          WHEN 'BERNAME'.
            ls_fcat-seltext_l = text-314.
            ls_fcat-seltext_m = text-314.
            ls_fcat-seltext_s = text-314.
            ls_fcat-ddictxt   = gc_s.
*          WHEN 'BANKL'.
*            ls_fcat-seltext_l = text-315.
*            ls_fcat-seltext_m = text-315.
*            ls_fcat-seltext_s = text-315.
*            ls_fcat-ddictxt   = gc_s.
*          WHEN 'KTONR'.
*            ls_fcat-seltext_l = text-308.
*            ls_fcat-seltext_m = text-308.
*            ls_fcat-seltext_s = text-308.
*            ls_fcat-ddictxt   = gc_s.
*          WHEN 'AZNUM'.
*            ls_fcat-seltext_l = text-316.
*            ls_fcat-seltext_m = text-316.
*            ls_fcat-seltext_s = text-316.
*            ls_fcat-ddictxt   = gc_s.
*          WHEN 'KUKEY'.
*            ls_fcat-seltext_l = text-317.
*            ls_fcat-seltext_m = text-317.
*            ls_fcat-seltext_s = text-317.
*            ls_fcat-ddictxt   = gc_s.

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
          WHEN 'MAPPE'.
            ls_fcat-tech      = gc_chk.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*

        ENDCASE.
        MODIFY xt_fieldcat FROM ls_fcat.
      ENDLOOP.

    WHEN 2.
      CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name       = gc_strs
        CHANGING
          ct_fieldcat            = xt_fieldcat
        EXCEPTIONS
          inconsistent_interface = 1
          program_error          = 2
          OTHERS                 = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

*      APPEND LINES OF lt_fcat TO xt_fieldcat.

      LOOP AT xt_fieldcat INTO ls_fcat.
        CASE ls_fcat-fieldname.
          WHEN 'BERNAME'.
            ls_fcat-seltext_l = text-314.
            ls_fcat-seltext_m = text-314.
            ls_fcat-seltext_s = text-314.
            ls_fcat-ddictxt   = gc_s.
           WHEN 'BANKL'.
             ls_fcat-seltext_l = text-315.
             ls_fcat-seltext_m = text-315.
             ls_fcat-seltext_s = text-315.
             ls_fcat-ddictxt   = gc_s.
           WHEN 'KTONR'.
             ls_fcat-seltext_l = text-318.
             ls_fcat-seltext_m = text-318.
             ls_fcat-seltext_s = text-318.
             ls_fcat-ddictxt   = gc_s.
          WHEN 'GROUPID'.
            ls_fcat-seltext_l = text-319.
            ls_fcat-seltext_m = text-319.
            ls_fcat-seltext_s = text-319.
            ls_fcat-ddictxt   = gc_s.
          WHEN 'GRPNR'.
            ls_fcat-seltext_l = text-320.
            ls_fcat-seltext_m = text-320.
            ls_fcat-seltext_s = text-320.
            ls_fcat-ddictxt   = gc_s.
          WHEN 'FB01'.
            ls_fcat-seltext_l = text-321.
            ls_fcat-seltext_m = text-321.
            ls_fcat-seltext_s = text-321.
            ls_fcat-ddictxt   = gc_s.
            ls_fcat-do_sum = gc_chk.
          WHEN 'FB05'.
            ls_fcat-seltext_l = text-322.
            ls_fcat-seltext_m = text-322.
            ls_fcat-seltext_s = text-322.
            ls_fcat-ddictxt   = gc_s.
            ls_fcat-do_sum = gc_chk.
          WHEN 'AKONT'.
            ls_fcat-seltext_l = text-323.
            ls_fcat-seltext_m = text-323.
            ls_fcat-seltext_s = text-323.
            ls_fcat-ddictxt   = gc_s.
            ls_fcat-do_sum = gc_chk.
          WHEN 'NOTPO'.
            ls_fcat-seltext_l = text-324.
            ls_fcat-seltext_m = text-324.
            ls_fcat-seltext_s = text-324.
            ls_fcat-ddictxt   = gc_s.
            ls_fcat-do_sum = gc_chk.
          WHEN 'ERROR'.
            ls_fcat-seltext_l = text-325.
            ls_fcat-seltext_m = text-325.
            ls_fcat-seltext_s = text-325.
            ls_fcat-ddictxt   = gc_s.
            ls_fcat-do_sum = gc_chk.
          WHEN 'SUMME'.
            ls_fcat-seltext_l = text-326.
            ls_fcat-seltext_m = text-326.
            ls_fcat-seltext_s = text-326.
            ls_fcat-ddictxt   = gc_s.
            ls_fcat-do_sum = gc_chk.
          WHEN 'SUMSO'.
*>>*<<* Start of changes on 02 June 2004 : C5056171 *>>*<<*
*            ls_fcat-seltext_l = text-328.
*            ls_fcat-seltext_m = text-328.
*            ls_fcat-seltext_s = text-328.
            ls_fcat-seltext_l = text-327.
            ls_fcat-seltext_m = text-327.
            ls_fcat-seltext_s = text-327.
            ls_fcat-ddictxt   = gc_s.
            ls_fcat-do_sum    = gc_chk.
          WHEN 'SUMHA'.
*            ls_fcat-seltext_l = text-327.
*            ls_fcat-seltext_m = text-327.
*            ls_fcat-seltext_s = text-327.
            ls_fcat-seltext_l = text-328.
            ls_fcat-seltext_m = text-328.
            ls_fcat-seltext_s = text-328.
            ls_fcat-ddictxt   = gc_s.
            ls_fcat-do_sum    = gc_chk.
          WHEN  'KUKEY'.
            ls_fcat-tech      = gc_chk.
          WHEN  'AZNUM'.
            ls_fcat-tech      = gc_chk.
          WHEN 'WAERS'.
            ls_fcat-no_out    = 'X'.
        ENDCASE.
        MODIFY xt_fieldcat FROM ls_fcat.
      ENDLOOP.

  ENDCASE.
ENDFORM.                    " BUILD_FIELDCAT_ALV
*&---------------------------------------------------------------------*
*&      Form  SET_LAYOUT_ALV
*&---------------------------------------------------------------------*
*       BUILD A LAYOUT FOR ALV
*----------------------------------------------------------------------*
*      -->IV_COUNTER COUNTER FIELD
*      <--XS_LAYO    LAYOUT TABLE
*----------------------------------------------------------------------*
FORM set_layout_alv USING iv_counter TYPE i
                    CHANGING xs_layo  TYPE slis_layout_alv.
*  CASE iv_counter.
*    WHEN 1.
*      xs_layo-list_append = gc_y.
*    WHEN OTHERS.
*      xs_layo-list_append = gc_chk.
*  ENDCASE.

  clear xs_layo-list_append.                "n982069
  xs_layo-no_hotspot        = gc_chk.
  xs_layo-colwidth_optimize = gc_chk.
*  xs_layo-min_linesize      = '255'.       "n1039354

ENDFORM.                    " SET_LAYOUT_ALV
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_FB01_ALV1
*&---------------------------------------------------------------------*
*       DISP[ALY THE FIRST LIST
*----------------------------------------------------------------------*
*     --> IT_FB01   ALV TABLE
*----------------------------------------------------------------------*
FORM display_fb01_list1 USING it_fb01 LIKE gt_fb01_1.
  DATA: lt_evts TYPE slis_t_event.        "events table
  DATA: ls_key  TYPE slis_keyinfo_alv.
  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
        ls_layo TYPE slis_layout_alv,
        lt_sort     TYPE slis_t_sortinfo_alv,
        lt_extab    TYPE slis_t_extab.                  "n982069

  DATA: lv_counter TYPE i VALUE 1.
***Build the field catalog
  PERFORM build_fieldcat_alv USING lv_counter
                             CHANGING lt_fieldcat. "Build Field Catalog
***Build the set layout
  PERFORM set_layout_alv USING lv_counter
                         CHANGING ls_layo.     "to set layout

***Build the events
  PERFORM set_events_alv USING lv_counter
                         CHANGING lt_evts.  "to set events

*-----> Initialise Sorting Parameters.
  PERFORM t_sort_build   CHANGING lt_sort.

*-----> Set excluding tab for ALV ok-codes
  PERFORM extab_build_alv USING 'PLOG'               "n982069
                          CHANGING lt_extab.

*----->
  PERFORM set_keyinfo_1 CHANGING ls_key.

  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      i_callback_program = gv_repid
      is_layout          = ls_layo
      it_fieldcat        = lt_fieldcat
      it_excluding       = lt_extab               "n982069
      it_events          = lt_evts
      i_tabname_header   = gc_1h
      i_tabname_item     = gc_1l
      it_sort            = lt_sort
      is_keyinfo         = ls_key
      i_save             = 'A'
    TABLES
      t_outtab_header    = gt_header
      t_outtab_item      = it_fb01
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*
ENDFORM.                    " DISPLAY_FB01_ALV1
*&---------------------------------------------------------------------*
*&      Form  SET_EVENTS_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_EVTS  text
*----------------------------------------------------------------------*
FORM set_events_alv  USING iv_counter TYPE i
                     CHANGING xt_evts TYPE slis_t_event.
  DATA: ls_events TYPE slis_alv_event.
*** To get the top of list based on the ptype
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type     = 0
    IMPORTING
      et_events       = xt_evts
    EXCEPTIONS
      list_type_wrong = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CASE iv_counter.
    WHEN 1.
      READ TABLE xt_evts INTO ls_events
                  WITH KEY name = slis_ev_top_of_page.
      IF sy-subrc = 0.
        ls_events-form = gc_tol_form1.
        MODIFY xt_evts FROM ls_events TRANSPORTING form
        WHERE name = slis_ev_top_of_page.
      ENDIF.

*      READ TABLE xt_evts INTO ls_events
*                 WITH KEY name = slis_ev_end_of_list.
*      IF sy-subrc = 0.
*        ls_events-form = gc_end_list1.
*        MODIFY xt_evts FROM ls_events TRANSPORTING form
*        WHERE name = slis_ev_end_of_list.
*      ENDIF.

    WHEN 2.
      READ TABLE xt_evts INTO ls_events
                  WITH KEY name = slis_ev_top_of_page.
      IF sy-subrc = 0.
        ls_events-form = gc_tol_form2.
        MODIFY xt_evts FROM ls_events TRANSPORTING form
        WHERE name = slis_ev_top_of_page.
      ENDIF.
  ENDCASE.
ENDFORM.                    " SET_EVENTS_ALV
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_LIST_ONE
*&---------------------------------------------------------------------*
* This subroutine is dynamically called and handles event TOP-OF-LIST
*----------------------------------------------------------------------*
FORM top_of_page_one .                                      "#EC CALLED

  DATA: ls_header TYPE fagl_acc_s_rfebbu00_alv_head.

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
  DATA: lv_linsz LIKE sy-linsz.         "Line Size , temporary variable
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*

  CLEAR ls_header.
  PERFORM header_hiersequ(saplkkbl) USING ls_header.

  IF febko-kukey ne ls_header-kukey.                         "n853370
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM febko WHERE kukey = ls_header-kukey.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM febko WHERE kukey = ls_header-kukey ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.

  MOVE space TO        bhdgd-line1.
  MOVE space TO        bhdgd-line2.
  MOVE febko-bukrs TO  bhdgd-bukrs.
  MOVE sy-uname TO     bhdgd-uname.
  MOVE sy-repid TO     bhdgd-repid.
  CASE anwnd.
    WHEN '0001'.
      MOVE text-007 TO bhdgd-line1.
    WHEN '0002'.
      MOVE text-008 TO bhdgd-line1.
    WHEN '0003'.
      MOVE text-009 TO bhdgd-line1.
    WHEN OTHERS.
      MOVE sy-title TO bhdgd-line1.
  ENDCASE.
  IF function = 'C'.
    MOVE text-038      TO bhdgd-line2.
  ELSE.
    MOVE text-039 TO char132.
    REPLACE '&' WITH ls_header-mappe INTO char132.
    MOVE char132+0(50) TO bhdgd-line2.
  ENDIF.
  bhdgd-inifl = '0'.

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
  CALL FUNCTION 'REUSE_ALV_LIST_LAYOUT_INFO_GET'
    IMPORTING
      e_width = lv_linsz.

  MOVE lv_linsz TO bhdgd-lines.
*  bhdgd-LINES = sy-linsz.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*

  CALL FUNCTION 'FAGL_BATCH_HEADING_PERFORM'
    EXPORTING
      is_bhdgd = bhdgd.

  CLEAR bhdgd.

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
  IF testl = 'X'.
    WRITE:/(lv_linsz) text-102.
    WRITE:/(lv_linsz) text-103.
    WRITE:/(lv_linsz) text-102.
  ENDIF.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*
ENDFORM.                    " top_of_list_ONE
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_LIST_TWO
*&---------------------------------------------------------------------*
* This subroutine is dynamically called and handles event TOP-OF-LIST
*----------------------------------------------------------------------*
FORM top_of_page_two.                                       "#EC CALLED

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
  DATA: lv_linsz LIKE sy-linsz.         "Line Size , temporary variable
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*

  MOVE space TO        bhdgd-line1.
  MOVE space TO        bhdgd-line2.
  MOVE febko-bukrs TO  bhdgd-bukrs.
  MOVE sy-uname TO     bhdgd-uname.
  MOVE sy-repid TO     bhdgd-repid.
  CASE anwnd.
    WHEN '0001'.
      MOVE text-007 TO bhdgd-line1.
    WHEN '0002'.
      MOVE text-008 TO bhdgd-line1.
    WHEN '0003'.
      MOVE text-009 TO bhdgd-line1.
    WHEN OTHERS.
      MOVE sy-title TO bhdgd-line1.
  ENDCASE.
  MOVE text-041 TO bhdgd-line2.
  bhdgd-inifl = '0'.

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
  CALL FUNCTION 'REUSE_ALV_LIST_LAYOUT_INFO_GET'
    IMPORTING
      e_width = lv_linsz.

  MOVE lv_linsz TO bhdgd-lines.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*

  CALL FUNCTION 'FAGL_BATCH_HEADING_PERFORM'
    EXPORTING
      is_bhdgd = bhdgd.

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
  IF testl = 'X'.
    WRITE:/(lv_linsz) text-102.
    WRITE:/(lv_linsz) text-103.
    WRITE:/(lv_linsz) text-102.
  ENDIF.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*

ENDFORM.                    " top_of_list_TWO
*&---------------------------------------------------------------------*
*&      Form  END_OF_LIST
*&---------------------------------------------------------------------*
FORM end_of_alv_list.                                       "#EC CALLED
  PERFORM display_fb01_list2 USING gt_statis.
ENDFORM.                    "END_OF_ALV_LIST
*&---------------------------------------------------------------------*
*&      Form  header_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_ACCT  text
*----------------------------------------------------------------------*
FORM header_data  CHANGING xt_header LIKE gt_header.

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
*  DATA: ls_header TYPE fagl_acc_s_rfebbu00_alv_head.
  CLEAR  gs_header.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*


  IF function = 'C'.
    CLEAR mappe .
  ENDIF .

  IF p_bupro = 'X'.
    IF printflag = 'P'.
      IF bereich = '1'.
        gs_header-bername = text-011.
      ELSEIF bereich = '2'.
        gs_header-bername = text-012.
      ENDIF.
      LOOP AT xfebvw WHERE anwnd = febko-anwnd
                       AND absnd = febko-absnd
                       AND azidt = febko-azidt.
        EXIT.
      ENDLOOP.
      gs_header-bankl = xfebvw-bankl.
      gs_header-banka = xfebvw-banka.
      gs_header-ktonr = febko-ktonr.
      gs_header-aznum = febko-aznum.
      gs_header-kukey = febko-kukey.
      gs_header-mappe = mappe.

*     no double entries, note 853370
      READ TABLE xt_header FROM gs_header TRANSPORTING NO FIELDS .
      if sy-subrc ne 0.
        APPEND gs_header TO xt_header.
      endif.

    ELSEIF printflag = 'E'.

      IF bereich = '1'.
        gs_header-bername = text-011.
      ELSEIF bereich = '2'.
        gs_header-bername = text-012.
      ENDIF.
      LOOP AT xfebvw WHERE anwnd = vb_error-anwnd
                       AND absnd = vb_error-absnd
                       AND azidt = vb_error-azidt.
        EXIT.
      ENDLOOP.
      gs_header-bankl = xfebvw-bankl.
      gs_header-banka = xfebvw-banka.
      gs_header-ktonr = vb_error-ktonr.
      gs_header-aznum = vb_error-aznum.
      gs_header-kukey = febko-kukey.                    "n1152883
      gs_header-mappe = mappe.

*     no double entries, note 853370
      READ TABLE xt_header FROM gs_header TRANSPORTING NO FIELDS .
      if sy-subrc ne 0.
        APPEND gs_header TO xt_header.
      endif.
    ENDIF.

  ENDIF.

ENDFORM.                    " header_data
*&---------------------------------------------------------------------*
*&      Form  set_keyinfo_1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LS_KEY  text
*----------------------------------------------------------------------*
FORM set_keyinfo_1  CHANGING xs_key TYPE slis_keyinfo_alv.
  CLEAR xs_key.
  xs_key-header01 = 'BERNAME'.
  xs_key-item01   = 'BERNAME'.
  xs_key-header02 = 'BANKL'.
  xs_key-item02   = 'BANKL'.
  xs_key-header03 = 'KTONR'.
  xs_key-item03   = 'KTONR'.
  xs_key-header04 = 'AZNUM'.
  xs_key-item04   = 'AZNUM'.
  xs_key-header05 = 'MAPPE'.                    "n853370
  xs_key-item05   = 'MAPPE'.
ENDFORM.                    " set_keyinfo_1
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_FB01_LIST2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_FB01_2  text
*----------------------------------------------------------------------*
FORM display_fb01_list2  USING  it_statis LIKE gt_statis.
  DATA: lt_evts TYPE slis_t_event.        "events table
  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
        ls_layo TYPE slis_layout_alv,
        lt_sort TYPE slis_t_sortinfo_alv,
        ls_sort TYPE slis_sortinfo_alv,
        lt_extab    TYPE slis_t_extab.                  "n982069

  DATA: lv_counter TYPE i VALUE 2.

  CLEAR ls_sort.
  ls_sort-spos      = 1.
  ls_sort-fieldname = 'BERNAME'.
  ls_sort-up        = gc_chk.
  ls_sort-subtot    = gc_chk.
  APPEND ls_sort TO lt_sort.

*>>*<<* Start of changes on 02 June 2004 : C5056171 *>>*<<*
  ls_sort-spos      = 2.
  ls_sort-fieldname = 'KUKEY'.  "'KTONR'.
  ls_sort-up        = gc_chk.
  ls_sort-subtot    = gc_chk.
  APPEND ls_sort TO lt_sort.
*>>*<<* End of changes on 02 June 2004 : C5056171 *>>*<<*


  PERFORM build_fieldcat_alv USING lv_counter
                             CHANGING lt_fieldcat. "Build Field Catalog

  PERFORM set_layout_alv USING lv_counter
                         CHANGING ls_layo.     "to set layout
***Build the events
  PERFORM set_events_alv USING lv_counter
                         CHANGING lt_evts.  "to set events

*-----> Set excluding tab for ALV ok-codes
  PERFORM extab_build_alv USING 'STAT'
                          CHANGING lt_extab.               "n982069

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program = gv_repid
      is_layout          = ls_layo
      it_fieldcat        = lt_fieldcat
      it_sort            = lt_sort
      it_events          = lt_evts
      it_excluding       = lt_extab                         "n982069
    TABLES
      t_outtab           = it_statis
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " DISPLAY_FB01_LIST2
*&---------------------------------------------------------------------*
*&      Form  display_list
*&---------------------------------------------------------------------*
*       text  For Display of ALV list
*----------------------------------------------------------------------*
FORM display_list .
  DATA: lt_evts TYPE slis_t_event.        "events table
  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
        l_variant   LIKE disvariant.

  l_variant-report     = gv_repid.

** For Initialise Fieldcatlog for header & item tables.
  PERFORM fieldcat_build CHANGING lt_fieldcat.
** For Event handling parameters
  PERFORM lt_events_build CHANGING lt_evts.

*GET ALV LAYOUT.
  PERFORM LAYOUT_SIMPLE_BUILD CHANGING GS_LAYOUT.


  PERFORM sort_info_alv CHANGING gt_sort.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program = gv_repid
      it_fieldcat        = lt_fieldcat
      is_variant         = l_variant
      i_save             = 'A'
      it_events          = lt_evts
      it_sort            = gt_sort
    TABLES
      t_outtab           = gt_outtab3
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " display_list
*&---------------------------------------------------------------------*
*&      Form  fieldcat_build
*&---------------------------------------------------------------------*
*       text  Fieldcatelog table
*----------------------------------------------------------------------*
*      <--xt_fieldcat  text Fieldcatelog table
*----------------------------------------------------------------------*
FORM fieldcat_build  CHANGING xt_fieldcat  TYPE slis_t_fieldcat_alv.

  DATA: ls_fieldcat TYPE slis_fieldcat_alv,
        lv_text(20) TYPE c.
  lv_text = text-l25.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'              "#EC *
      EXPORTING
      i_program_name         = gv_repid
      i_structure_name       = 'FIN_RFEBBU0001_ALV'
    CHANGING
      ct_fieldcat            = xt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

** Hide fields from the item table that are not required to be output
  LOOP AT xt_fieldcat INTO ls_fieldcat.
    CASE ls_fieldcat-fieldname.
      WHEN 'ESNUM'.
        ls_fieldcat-col_pos = 8.
        ls_fieldcat-key = ' '.
        ls_fieldcat-seltext_l = lv_text+0(3).
        ls_fieldcat-seltext_m = lv_text+0(3).
        ls_fieldcat-seltext_s = lv_text+0(3).
        ls_fieldcat-reptext_ddic = lv_text+0(3).
      WHEN 'BATCH'.
        ls_fieldcat-col_pos = 9.
        ls_fieldcat-seltext_l = lv_text+4(5).
        ls_fieldcat-seltext_m = lv_text+4(5).
        ls_fieldcat-seltext_s = lv_text+4(5).
        ls_fieldcat-reptext_ddic = lv_text+4(5).
      WHEN 'CHECT'.
        ls_fieldcat-col_pos = 1.
        ls_fieldcat-key = ' '.
        ls_fieldcat-seltext_l = text-l16.
        ls_fieldcat-seltext_m = text-l16.
        ls_fieldcat-seltext_s = text-l16.
        ls_fieldcat-reptext_ddic = text-l16.
        ls_fieldcat-outputlen = 13.
      WHEN 'KNRZA'.
        ls_fieldcat-col_pos = 2.
        ls_fieldcat-seltext_l = text-l17.
        ls_fieldcat-seltext_m = text-l17.
        ls_fieldcat-seltext_s = text-l17.
        ls_fieldcat-reptext_ddic = text-l17.
      WHEN 'KWBTR'.
        ls_fieldcat-col_pos = 3.
        ls_fieldcat-seltext_l = text-l19.
        ls_fieldcat-seltext_m = text-l19.
        ls_fieldcat-seltext_s = text-l19.
        ls_fieldcat-reptext_ddic = text-l19.
        ls_fieldcat-no_zero = 'X'.
      WHEN 'BELNR'.
        ls_fieldcat-col_pos = 4.
        ls_fieldcat-seltext_l = text-l18.
        ls_fieldcat-seltext_m = text-l18.
        ls_fieldcat-seltext_s = text-l18.
        ls_fieldcat-reptext_ddic = text-l18.
      WHEN 'NBBLN'.
        ls_fieldcat-col_pos = 5.
        ls_fieldcat-seltext_l = text-l20.
        ls_fieldcat-seltext_m = text-l20.
        ls_fieldcat-seltext_s = text-l20.
        ls_fieldcat-reptext_ddic = text-l20.
* start changes after review C5056169 01.06.2004

      WHEN 'SGTXT'.
        ls_fieldcat-col_pos = 7.
        ls_fieldcat-seltext_l = text-l37.
        ls_fieldcat-seltext_m = text-l37.
        ls_fieldcat-seltext_s = text-l37.
        ls_fieldcat-reptext_ddic = text-l37.
* start changes after review C5056169 15.07.2004
        ls_fieldcat-outputlen = 15.

*        WHEN 'AVKON'.
*          ls_fieldcat-col_pos = 10.
*          ls_fieldcat-seltext_l = text-l33.
*          ls_fieldcat-seltext_m = text-l33.
*          ls_fieldcat-seltext_s = text-l33.
*          ls_fieldcat-reptext_ddic = text-l33.
*        WHEN 'AVSID'.
*          ls_fieldcat-col_pos = 11.
*          ls_fieldcat-seltext_l = text-l41.
*          ls_fieldcat-seltext_m = text-l41.
*          ls_fieldcat-seltext_s = text-l41.
*          ls_fieldcat-reptext_ddic = text-l41.
      WHEN 'ADVICE'.
        ls_fieldcat-col_pos = 10.
        ls_fieldcat-seltext_l = text-l33.
        ls_fieldcat-seltext_m = text-l33.
        ls_fieldcat-seltext_s = text-l33.
        ls_fieldcat-reptext_ddic = text-l33.
      WHEN 'AKBLN'.
        ls_fieldcat-col_pos = 6.
        ls_fieldcat-seltext_l = text-l21.
        ls_fieldcat-seltext_m = text-l21.
        ls_fieldcat-seltext_s = text-l21.
        ls_fieldcat-reptext_ddic = text-l21.
      when 'MESSAGES'.
        ls_fieldcat-col_pos = 11.
        ls_fieldcat-seltext_l = text-329.
        ls_fieldcat-seltext_m = text-329.
        ls_fieldcat-seltext_s = text-329.
        ls_fieldcat-reptext_ddic = text-329.
      WHEN 'KWAER'.
        ls_fieldcat-no_out    = 'X'.
      WHEN OTHERS.
        ls_fieldcat-tech = 'X'.
    ENDCASE.
    MODIFY xt_fieldcat FROM ls_fieldcat.
  ENDLOOP.

ENDFORM.                    " fieldcat_build
*&---------------------------------------------------------------------*
*&      Form  lt_events_build
*&---------------------------------------------------------------------*
*       text  Event handling
*----------------------------------------------------------------------*
*      <--x_events  text Event Table
*----------------------------------------------------------------------*
FORM lt_events_build  CHANGING x_events TYPE slis_t_event.  "#EC *

  DATA:   ls_events TYPE slis_alv_event.
  REFRESH x_events.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type     = 0
    IMPORTING
      et_events       = x_events
    EXCEPTIONS
      list_type_wrong = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  READ TABLE x_events INTO ls_events WITH
       KEY name = slis_ev_top_of_page.
  IF sy-subrc = 0.
    ls_events-form = 'TOP_OF_PAGE'.
    MODIFY x_events FROM ls_events TRANSPORTING form
           WHERE name = slis_ev_top_of_page.
  ENDIF.

  READ TABLE x_events INTO ls_events WITH
       KEY name = slis_ev_end_of_list.
  IF sy-subrc = 0.
    ls_events-form = 'END_OF_LIST'.
    MODIFY x_events FROM ls_events TRANSPORTING form
           WHERE name = slis_ev_end_of_list.
  ENDIF.


  READ TABLE x_events INTO ls_events WITH
         KEY name = slis_ev_after_line_output.
  IF sy-subrc = 0.
    ls_events-form = 'AFTER_LINE_OUTPUT'.
    MODIFY x_events FROM ls_events TRANSPORTING form
           WHERE name = slis_ev_after_line_output.
  ENDIF.

  READ TABLE x_events INTO ls_events WITH
       KEY name = slis_ev_pf_status_set .
  IF sy-subrc = 0.
    ls_events-form = 'PF_STATUS_SET'.
    MODIFY x_events FROM ls_events TRANSPORTING form
           WHERE name = slis_ev_pf_status_set.
  ENDIF.
ENDFORM.                    " lt_events_build

*&---------------------------------------------------------------------*
*&      Form  LAYOUT_SIMPLE_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GS_LAYOUT  text
*----------------------------------------------------------------------*
form LAYOUT_SIMPLE_BUILD  changing Xs_layout TYPe  SLIS_LAYOUT_ALV.

  XS_LAYOUT-list_appenD = 'X'.
*XS_LAYOUT-colwidth_optimize = 'X'.
endform.                    " LAYOUT_SIMPLE_BUILD


*&--------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&--------------------------------------------------------------------*
*       Routine Which triggers TOP_OF_PAGE EVENT.
*---------------------------------------------------------------------*
FORM top_of_page.                                           "#EC CALLED

  TABLES: usr01.
  DATA:  l_datfm TYPE datfm.
  DATA: lr_grid TYPE REF TO cl_salv_form_layout_grid.
  CREATE OBJECT lr_grid.

  DATA: lv_prev_period(135),lv_prev_period1(135),
        lv_rep_period(135),lv_text(16) TYPE c,lv_date(10) TYPE c.

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
  DATA: lv_linsz LIKE sy-linsz.         "Line Size , temporary variable
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*

*start changes after review C5056169 22 Jun 2004.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT  * FROM febko WHERE kukey = gt_outtab3-kukey.
*
* NEW CODE
  SELECT *
 FROM febko WHERE kukey = gt_outtab3-kukey ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  ENDSELECT.
*end changes after review C5053099 22 Jun 2004.

  lv_text = text-l11.
  CONCATENATE lv_text febko-absnd+0(10) INTO lv_prev_period
  SEPARATED BY space .
  lr_grid->create_text(
    row     = 1
    column  = 1
    text    = lv_prev_period
    tooltip = lv_prev_period ).


  lv_text = text-l12.
  CONCATENATE lv_text febko-absnd+11(10) INTO lv_prev_period
  SEPARATED BY space .
  lr_grid->create_text(
    row     = 1
    column  = 2
    text    = lv_prev_period
    tooltip = lv_prev_period ).


  lv_text = text-l09.
  CONCATENATE lv_text febko-azidt+0(07) INTO lv_prev_period
  SEPARATED BY space .
  lr_grid->create_text(
  row     = 1
  column  = 3
  text    = lv_prev_period
  tooltip = lv_prev_period ).


  lv_text = text-l13.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE datfm FROM usr01 INTO l_datfm
*                            WHERE bname = sy-uname.
*
* NEW CODE
          SELECT datfm
          UP TO 1 ROWS  FROM usr01 INTO l_datfm
                            WHERE bname = sy-uname ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        CASE l_datfm.
          WHEN '1'.
            CONCATENATE febko-azdat+6(2) febko-azdat+4(2) febko-azdat(4)
              INTO lv_prev_period SEPARATED BY '.'.
          WHEN '2'.
            CONCATENATE  febko-azdat+4(2) febko-azdat+6(2) febko-azdat(4)
              INTO lv_prev_period SEPARATED BY '/'.
          WHEN '3'.
            CONCATENATE  febko-azdat+4(2) febko-azdat+6(2) febko-azdat(4)
              INTO lv_prev_period SEPARATED BY '.'.
          WHEN '4'.
            CONCATENATE  febko-azdat(4) febko-azdat+4(2) febko-azdat+6(2)
              INTO lv_prev_period SEPARATED BY '.'.
          WHEN '5'.
            CONCATENATE  febko-azdat(4) febko-azdat+4(2) febko-azdat+6(2)
              INTO lv_prev_period SEPARATED BY '/'.
          WHEN '6'.
            CONCATENATE  febko-azdat(4) febko-azdat+4(2) febko-azdat+6(2)
              INTO lv_prev_period SEPARATED BY '-'.
          WHEN OTHERS.
        ENDCASE.
  CONCATENATE lv_text lv_prev_period INTO lv_rep_period
  SEPARATED BY space .
  lr_grid->create_text(
    row     = 1
    column  = 4
    text    = lv_rep_period
    tooltip = lv_rep_period ).


  lv_text = text-l15.
  CONCATENATE lv_text febko-kukey INTO lv_prev_period
  SEPARATED BY space .
  lr_grid->create_text(
    row     = 1
    column  = 5
    text    = lv_prev_period
    tooltip = lv_prev_period ).


  CALL METHOD cl_salv_form_content=>set
    EXPORTING
      value = lr_grid.

*>>*<<* Start of changes on 23 June 2004 : C5056171 *>>*<<*
*    Get the width of ALV list and set the same for Batch Heading
  CALL FUNCTION 'REUSE_ALV_LIST_LAYOUT_INFO_GET'
    IMPORTING
      e_width = lv_linsz
     EXCEPTIONS
      no_infos = 4.

  MOVE lv_linsz TO bhdgd-lines.
*  bhdgd-LINES = sy-linsz.
*>>*<<* End of changes on 23 June 2004 : C5056171 *>>*<<*

  bhdgd-bukrs = febko-bukrs.
  bhdgd-uname = sy-uname.
  bhdgd-repid = sy-repid.
  char16      = text-l09.
  bhdgd-line1 = char16(8).
  bhdgd-line2 = text-l02.
  bhdgd-inifl = '0'.

  CALL FUNCTION 'FAGL_BATCH_HEADING_PERFORM'
    EXPORTING
      is_bhdgd = bhdgd.

ENDFORM.                    "TOP_OF_PAGE

*start changes after review C5053099 24 Jun 2004.
*&--------------------------------------------------------------------*
*&      Form  END_OF_LIST
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM end_of_list.                                           "#EC CALLED

*  DATA: totl_cnt TYPE i.
*  DATA: appl_cnt TYPE i.
*  DATA: papl_cnt TYPE i.
*  DATA: poac_cnt TYPE i.
*  DATA: unid_cnt TYPE i.
*  DATA: totl_sum  LIKE febep-kwbtr.
*  DATA: appl_sum  LIKE febep-kwbtr.
*  DATA: papl_sum  LIKE febep-kwbtr.
*  DATA: poac_sum  LIKE febep-kwbtr.
*  DATA: unid_sum  LIKE febep-kwbtr.
*  DATA: totl_txt(5) TYPE c.
*  DATA: appl_txt(5) TYPE c.
*  DATA: papl_txt(5) TYPE c.
*  DATA: poac_txt(5) TYPE c.
*  DATA: unid_txt(5) TYPE c.
*  DATA: outesnum TYPE i.               "40a numeric
*
*  LOOP AT s_kukey.
*
*    SELECT * FROM febko WHERE kukey = s_kukey-low.
*    ENDSELECT.
*    SELECT * FROM febep INTO TABLE xfebep
*           WHERE kukey = s_kukey-low.
*    IF sy-subrc = 0.
*      CLEAR:  totl_cnt,  totl_sum,  totl_txt,
*              appl_cnt,  appl_sum,  appl_txt,
*              papl_cnt,  papl_sum,  papl_txt,
*              poac_cnt,  poac_sum,  poac_txt,
*              unid_cnt,  unid_sum,  unid_txt.
*      LOOP AT xfebep.
*        IF NOT xfebep-nbbln IS INITIAL.
*          IF xfebep-estat = '3'.
**--------- Partially Applied ----------------------------    -----
*            papl_sum = papl_sum + xfebep-kwbtr. "CHECK - mpEURO
*            papl_cnt = papl_cnt + 1.
*          ELSE.
**--------- Applied --------------------------------------    -----
*            appl_sum = appl_sum + xfebep-kwbtr. "CHECK - mpEURO
*            appl_cnt = appl_cnt + 1.
*          ENDIF.
*        ELSEIF NOT xfebep-akbln IS INITIAL.
**--------- On Account -----------------------------------    -----
*          poac_sum = poac_sum + xfebep-kwbtr. "CHECK - mpEURO
*          poac_cnt = poac_cnt + 1.
*        ELSE.
**--------- Unprocessed ----------------------------------    -----
*          unid_sum = unid_sum + xfebep-kwbtr. "CHECK - mpEURO
*          unid_cnt = unid_cnt + 1.
*        ENDIF.
*
*        write:  130     sy-vline.
*
*        PERFORM write_lbmsg_lines.
*      ENDLOOP.
*
*      totl_cnt  =  appl_cnt + poac_cnt + unid_cnt + papl_cnt.
*      totl_sum  =  appl_sum + poac_sum + unid_sum + papl_sum.
*      totl_txt  =  totl_cnt.
*      appl_txt  =  appl_cnt.
*      papl_txt  =  papl_cnt.
*      poac_txt  =  poac_cnt.
*      unid_txt  =  unid_cnt.
*
*      write:  /1 sy-vline,
*              11 text-l01.
*
*      write:  65 text-l03,
*              73(07) text-l10,
*             130 sy-vline.
*      write:  /1 sy-vline,
*               2 text-l04.
*      write:  11  febko-azdat dd/mm/yyyy,
*              35(15) text-l30,
*              50 appl_sum currency xfebep-kwaer,      "CHECK - mpEURO
*              73 appl_txt,
*             130 sy-vline.
*      write:  /1 sy-vline,
*               2 'Lockbox:'(l09).
*      write:  11  febko-azidt+0(7),
*              35(15) text-l36,
**             35(15) TEXT-L34,
**             50 POAC_SUM CURRENCY XFEBEP-KWAER,
**             73 POAC_TXT,
*              50 papl_sum currency xfebep-kwaer, "CHECK - mpEURO
*              73 papl_txt,
*             130 sy-vline.
*
*      write:  /1 sy-vline,
*              35(15) text-l34,
*              50 poac_sum currency xfebep-kwaer, "CHECK - mpEURO
*              73 poac_txt,
*             130 sy-vline.
*      unid_cnt =  unid_cnt.
*      write:  /1 sy-vline,
*              35(15) text-l32,
*              50 unid_sum currency xfebep-kwaer, "CHECK - mpEURO
*              73 unid_txt,
*             130 sy-vline.
*      write: /1 sy-vline,
*              35(15) text-l35,
*              50 totl_sum currency xfebep-kwaer, "CHECK - mpEURO
*              73 totl_txt,
*             130 sy-vline.
*    ENDIF.
*
*    uline.
*  ENDLOOP.
* start changes after review C5056169 01.06.2004
  perform display_hierlist_alv.
* end changes after review C5056169 01.06.2004

ENDFORM.                    "END_OF_LIST
*end changes after review C5053099 24 Jun 2004.


** Start OF Changes on 21-apr-2004
*&---------------------------------------------------------------------*
*&      Form  T_SORT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--XT_SORT  text
*----------------------------------------------------------------------*
FORM t_sort_build  CHANGING xt_sort TYPE slis_t_sortinfo_alv.

  DATA: ls_sort TYPE slis_sortinfo_alv.

* Area
  CLEAR ls_sort.
  ls_sort-fieldname = 'BERNAME'.
  ls_sort-spos      = 2.
  ls_sort-up        = 'X'.
  ls_sort-group     =  '*'.
  APPEND ls_sort TO xt_sort.

* Account No
  ls_sort-fieldname = 'KTONR'.
  ls_sort-spos      = 3.
  ls_sort-up        = 'X'.
  ls_sort-group     =  '*'.
  APPEND ls_sort TO xt_sort.

* Statement No
  ls_sort-fieldname = 'AZNUM'.
  ls_sort-spos      = 4.
  ls_sort-up        = 'X'.
  ls_sort-group     =  '*'.
  APPEND ls_sort TO xt_sort.

* BDC session
  ls_sort-fieldname = 'MAPPE'.               "853370
  ls_sort-spos      = 7.
  ls_sort-up        = 'X'.
  ls_sort-group     =  '*'.
  APPEND ls_sort TO xt_sort.

ENDFORM.                    " T_SORT_BUILD

** End OF Changes on 21-apr-2004

**&--------------------------------------------------------------------*
**&      Form  PF_STATUS_SET
**&--------------------------------------------------------------------*
**       text  User interaction code for setting PF-STATUS
**---------------------------------------------------------------------*
FORM pf_status_set USING rt_extab TYPE slis_t_extab.        "#EC CALLED

  SET TITLEBAR 'SY-TITLE'.                                  "#EC *

ENDFORM.                    "HANDLE_EVENT_USER_COMMAND



*start changes after review C5053099 24 Jun 2004.
*&---------------------------------------------------------------------*
*&      Form  sort_info_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_SORT  text
*----------------------------------------------------------------------*
FORM sort_info_alv  CHANGING xt_sort TYPE slis_t_sortinfo_alv.
  DATA: ls_sort TYPE slis_sortinfo_alv.

  ls_sort-fieldname = 'KUKEY'.
  ls_sort-spos      = 1.
  ls_sort-up        = 'X'.
  ls_sort-group     = '*'.
  APPEND ls_sort TO xt_sort.

ENDFORM.                    " sort_info_alv
*&---------------------------------------------------------------------*
*&      Form  after_line_output
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM after_line_output USING   is_lineinfo TYPE slis_lineinfo.
                                                            "#EC CALLED
  DATA: lv_index LIKE sy-index, lv_index1 LIKE sy-index,
          ls_outtab1 TYPE foap_s_rfeblbd00_list,
          l_width TYPE  i.


  DATA: totl_cnt TYPE i.
  DATA: appl_cnt TYPE i.
  DATA: papl_cnt TYPE i.
  DATA: poac_cnt TYPE i.
  DATA: unid_cnt TYPE i.
  DATA: totl_sum  LIKE febep-kwbtr.
  DATA: appl_sum  LIKE febep-kwbtr.
  DATA: papl_sum  LIKE febep-kwbtr.
  DATA: poac_sum  LIKE febep-kwbtr.
  DATA: unid_sum  LIKE febep-kwbtr.
  DATA: totl_txt(5) TYPE c.
  DATA: appl_txt(5) TYPE c.
  DATA: papl_txt(5) TYPE c.
  DATA: poac_txt(5) TYPE c.
  DATA: unid_txt(5) TYPE c.
  DATA: outesnum TYPE i.               "40a numeric
  DATA: is_lineinfo_next TYPE slis_lineinfo.

  CALL FUNCTION 'REUSE_ALV_LIST_LAYOUT_INFO_GET'
    IMPORTING
      e_width       = l_width
    EXCEPTIONS
      no_infos      = 1
      program_error = 2
      OTHERS        = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* start changes after review C5056169 01.06.2004

* read table gt_outtab3  INTO gs_outtab INDEX is_lineinfo-tabindex.
* READ TABLE lbmsg WITH KEY kukey =  gs_outtab-kukey
*                           esnum =  gs_outtab-esnum
*                           BINARY SEARCH.
*  idx_lbmsg = is_lineinfo-tabindex.  "sy-tabix.
*  DO.
*    READ TABLE lbmsg INDEX idx_lbmsg.
*
*     if  lbmsg-kukey =  gs_outtab-kukey
*     and lbmsg-esnum =  gs_outtab-esnum
*     and sy-subrc = 0.
*      FORMAT COLOR COL_NEGATIVE.
*      uline.
*      WRITE: /1      sy-vline,
*             18(110) lbmsg-text,
*            130      sy-vline.
*      FORMAT RESET.
*      uline.
*      idx_lbmsg = idx_lbmsg + 1.
*    ELSE.
*      EXIT.
*    ENDIF.
*  ENDDO.

  format color col_normal intensified on.
* end changes after review C5056169 01.06.2004

  CLEAR : gs_outtab, gs_outtab_next.
  READ TABLE gt_outtab3  INTO gs_outtab INDEX is_lineinfo-tabindex.
  is_lineinfo_next-tabindex = is_lineinfo-tabindex + 1.
  READ TABLE gt_outtab3  INTO gs_outtab_next
                         INDEX is_lineinfo_next-tabindex.
  if gs_outtab-kukey <> gs_outtab_next-kukey.

    LOOP AT s_kukey WHERE low = gs_outtab-kukey.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT * FROM febko WHERE kukey = s_kukey-low.
**
* NEW CODE
      SELECT *
 FROM febko WHERE kukey = s_kukey-low ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      ENDSELECT.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT * FROM febep INTO TABLE xfebep
*             WHERE kukey = s_kukey-low.
*
* NEW CODE
      SELECT *
 FROM febep INTO TABLE xfebep
             WHERE kukey = s_kukey-low ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      IF sy-subrc = 0.
        CLEAR:  totl_cnt,  totl_sum,  totl_txt,
                appl_cnt,  appl_sum,  appl_txt,
                papl_cnt,  papl_sum,  papl_txt,
                poac_cnt,  poac_sum,  poac_txt,
                unid_cnt,  unid_sum,  unid_txt.
        LOOP AT xfebep.
          IF NOT xfebep-nbbln IS INITIAL.
            IF xfebep-estat = '3'.
*--------- Partially Applied ----------------------------    -----
              papl_sum = papl_sum + xfebep-kwbtr. "CHECK - mpEURO
              papl_cnt = papl_cnt + 1.
            ELSE.
*--------- Applied --------------------------------------    -----
              appl_sum = appl_sum + xfebep-kwbtr. "CHECK - mpEURO
              appl_cnt = appl_cnt + 1.
            ENDIF.
          ELSEIF NOT xfebep-akbln IS INITIAL.
*--------- On Account -----------------------------------    -----
            poac_sum = poac_sum + xfebep-kwbtr. "CHECK - mpEURO
            poac_cnt = poac_cnt + 1.
          ELSE.
*--------- Unprocessed ----------------------------------    -----
            unid_sum = unid_sum + xfebep-kwbtr. "CHECK - mpEURO
            unid_cnt = unid_cnt + 1.
          ENDIF.

* start changes after review C5056169 01.06.2004

*          WRITE:  130     sy-vline.

*          PERFORM write_lbmsg_lines.
* end changes after review C5056169 01.06.2004

        ENDLOOP.

        totl_cnt  =  appl_cnt + poac_cnt + unid_cnt + papl_cnt.
        totl_sum  =  appl_sum + poac_sum + unid_sum + papl_sum.
        totl_txt  =  totl_cnt.
        appl_txt  =  appl_cnt.
        papl_txt  =  papl_cnt.
        poac_txt  =  poac_cnt.
        unid_txt  =  unid_cnt.

* start changes after review C5056169 01.06.2004

*        WRITE:  /1 sy-vline,
*                11 text-l01.
*
*        WRITE:  65 text-l03,
*                73(07) text-l10,
*               130 sy-vline.
*        WRITE:  /1 sy-vline,
*                 2 text-l04.
*        WRITE:  11  febko-azdat DD/MM/YYYY,
*                35(15) text-l30,
*                50 appl_sum CURRENCY xfebep-kwaer,      "CHECK - mpEURO
*                73 appl_txt,
*               130 sy-vline.
*        WRITE:  /1 sy-vline,
*                 2 'Lockbox:'(l09).
*        WRITE:  11  febko-azidt+0(7),
*                35(15) text-l36,
**             35(15) TEXT-L34,
**             50 POAC_SUM CURRENCY XFEBEP-KWAER,
**             73 POAC_TXT,
*                50 papl_sum CURRENCY xfebep-kwaer, "CHECK - mpEURO
*                73 papl_txt,
*               130 sy-vline.
*
*        WRITE:  /1 sy-vline,
*                35(15) text-l34,
*                50 poac_sum CURRENCY xfebep-kwaer, "CHECK - mpEURO
*                73 poac_txt,
*               130 sy-vline.
* end changes after review C5056169 01.06.2004

        unid_cnt =  unid_cnt.
* start changes after review C5056169 01.06.2004
*        WRITE:  /1 sy-vline,
*                35(15) text-l32,
*                50 unid_sum CURRENCY xfebep-kwaer, "CHECK - mpEURO
*                73 unid_txt,
*               130 sy-vline.
*        WRITE: /1 sy-vline,
*                35(15) text-l35,
*                50 totl_sum CURRENCY xfebep-kwaer, "CHECK - mpEURO
*                73 totl_txt,
*               130 sy-vline.
* end changes after review C5056169 01.06.2004


      ENDIF.
* start changes after review C5056169 01.06.2004

      MOVE : febko-azdat  to gs_header1-azdat,
             febko-azidt+0(7) to gs_header1-azidt,
             febko-kukey  to gs_header1-kukey.
      append gs_header1 to gt_header1.


      move:  febko-azidt+0(7) to gs_item1-azidt,
             text-l30   to gs_item1-check_status,
             appl_sum   to gs_item1-amounts,
             appl_txt   to gs_item1-checks_cnt,
             febko-kukey  TO gs_item1-kukey,
             febko-waers  TO gs_item1-kwaer.
      Append gs_item1 to gt_item1.

      move:  febko-azidt+0(7) to gs_item1-azidt,
            text-l36   to gs_item1-check_status,
            papl_sum   to gs_item1-amounts,
            papl_txt   to gs_item1-checks_cnt,
            febko-kukey  TO gs_item1-kukey,
            febko-waers  TO gs_item1-kwaer.
      Append gs_item1 to gt_item1.

      move:  febko-azidt+0(7) to gs_item1-azidt,
            text-l34   to gs_item1-check_status,
            poac_sum   to gs_item1-amounts,
            poac_txt   to gs_item1-checks_cnt,
            febko-kukey  TO gs_item1-kukey,
            febko-waers  TO gs_item1-kwaer.
      Append gs_item1 to gt_item1.

      move:  febko-azidt+0(7) to gs_item1-azidt,
             text-l32   to gs_item1-check_status,
             unid_sum   to gs_item1-amounts,
             unid_txt   to gs_item1-checks_cnt,
             febko-kukey  TO gs_item1-kukey,
             febko-waers  TO gs_item1-kwaer.
      Append gs_item1 to gt_item1.


    ENDLOOP.
  ENDIF.
*end changes after review C5056169 01.06.2004

ENDFORM.                    " after_line_output

* start changes after review C5056169 02.06.2004
*&---------------------------------------------------------------------*
*&      Form  display_hierlist_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form display_hierlist_alv .

  DATA : LS_KEYINFO  TYPE SLIS_KEYINFO_ALV.
  DATA :  LT_FIELDCAT_HEAD TYPE SLIS_T_FIELDCAT_ALV,
         LT_FIELDCAT_DET TYPE SLIS_T_FIELDCAT_ALV.


*BUILD FIELDCATALOG - Header table.
  PERFORM FIELDCAT_HEAD_BUILD  USING 'FEBEP'
                               CHANGING LT_FIELDCAT_HEAD.
*BUILD FIELDCATALOG - Detail table.
  PERFORM FIELDCAT_DET_BUILD USING 'FIN_RFEBBU0002_ALV'
                                CHANGING LT_FIELDCAT_DET.
* Append field catalogs to a table to be passed to ALV function.
  APPEND  LINES  OF  LT_FIELDCAT_DET  TO  LT_FIELDCAT_HEAD.

*GET ALV LAYOUT.
  PERFORM LAYOUT_HIER_BUILD CHANGING GS_LAYOUT.

*BUILD ALV EVENTS TABLE
  PERFORM EVENTTAB_ALV_BUILD    CHANGING GT_EVENTTAB_ALV.

*BUILD KEY INFO.
  PERFORM KEYINFO_BUILD CHANGING  LS_KEYINFO.

*BUILD SORT INFO.
  REFRESH GT_SORT.
  PERFORM SORT_INFO_HIER CHANGING GT_SORT.

*DISPLAY HIERARCHICAL LIST.
  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = GV_REPID
      IS_LAYOUT          = GS_LAYOUT
      IT_FIELDCAT        = LT_FIELDCAT_HEAD
      IT_EVENTS          = GT_EVENTTAB_ALV
      I_TABNAME_HEADER   = 'GT_HEADER1'
      I_TABNAME_ITEM     = 'GT_ITEM1'
      IS_KEYINFO         = LS_KEYINFO
      IT_SORT            = gt_sort
    TABLES
      T_OUTTAB_HEADER    = GT_HEADer1
      T_OUTTAB_ITEM      = GT_item1
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
          WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


endform.                    " display_hierlist_alv
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_HEAD_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GC_HEAD  text
*      <--P_LT_FIELDCAT_HEAD  text
*----------------------------------------------------------------------*
form FIELDCAT_HEAD_BUILD  USING    IV_STRUCTURE TYPE DD02L-TABNAME"#EC *
                         CHANGING XT_FIELDCAT  TYPE SLIS_T_FIELDCAT_ALV.

  DATA : LS_FIELDCAT TYPE SLIS_FIELDCAT_ALV.

* Function to get field catalog information.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = GV_REPID
      I_STRUCTURE_NAME       = 'FEBKO'
      I_INTERNAL_TABNAME     = 'GT_HEADER1'
    CHANGING
      CT_FIELDCAT            = XT_FIELDCAT
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  CLEAR LS_FIELDCAT.

*Customise field catalog.
  LOOP AT XT_FIELDCAT INTO LS_FIELDCAT.

    CASE LS_FIELDCAT-FIELDNAME.
      WHEN 'AZDAT'.
      when  'AZIDT'.
        LS_FIELDCAT-SELTEXT_L = text-l39.
        LS_FIELDCAT-SELTEXT_M = text-l39.
        LS_FIELDCAT-SELTEXT_S = text-l39.
        LS_FIELDCAT-reptext_ddic = text-l39.
      WHEN OTHERS.
        LS_FIELDCAT-TECH = 'X'.
    ENDCASE.
    MODIFY XT_FIELDCAT FROM LS_FIELDCAT TRANSPORTING TECH
                                                     seltext_L
                                                     seltext_m
                                                     seltext_s
                                                     reptext_ddic.
  endloop.

endform.                    " FIELDCAT_HEAD_BUILD
*&---------------------------------------------------------------------*
*&      Form  fieldcat_det_build
*&---------------------------------------------------------------------*
*       Build Function Catalog
*----------------------------------------------------------------------*
*      -->IV_STRUCTURE  text
*      <--XT_FIELDCAT  table to hold field catalog info. for items
*----------------------------------------------------------------------*
FORM FIELDCAT_DET_BUILD  USING    IV_STRUCTURE TYPE DD02L-TABNAME"#EC *
                         CHANGING XT_FIELDCAT  TYPE SLIS_T_FIELDCAT_ALV.

  DATA : LS_FIELDCAT TYPE SLIS_FIELDCAT_ALV.

* Function to get field catalog info. for items.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = GV_REPID
      I_STRUCTURE_NAME       = 'FIN_RFEBBU0002_ALV'
      I_INTERNAL_TABNAME     = 'GT_ITEM1'
    CHANGING
      CT_FIELDCAT            = XT_FIELDCAT
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*Customise Field catalog
  LOOP AT XT_FIELDCAT INTO LS_FIELDCAT.
    CASE LS_FIELDCAT-FIELDNAME.
      WHEN 'AZIDT' or 'KUKEY'.
        LS_FIELDCAT-TECH = 'X'.
      when 'AMOUNTS'.
        ls_fieldcat-do_sum = 'X'.
      WHEN 'KWAER'.
        ls_fieldcat-no_out = 'X'.
    ENDCASE.
    MODIFY xt_fieldcat FROM ls_fieldcat TRANSPORTING tech do_sum no_out.
  ENDLOOP.


ENDFORM.                    " fieldcat_det_build
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_BUILD
*&---------------------------------------------------------------------*
*       Build Layout for popup ALV list
*----------------------------------------------------------------------*
*      <--XS_LAYOUT structure to hold layout info.
*----------------------------------------------------------------------*
FORM LAYOUT_HIER_BUILD  CHANGING XS_LAYOUT TYPe  SLIS_LAYOUT_ALV.

  XS_LAYOUT-list_append = 'X'.


ENDFORM.                    " LAYOUT_Assign_BUILD
*&---------------------------------------------------------------------*
*&      Form  keyinfo_build
*&---------------------------------------------------------------------*
*     Build Key information for header and detail tables
*----------------------------------------------------------------------*
*      <--XS_KEYINFO  structure to hold keyinfo for header and Detail
*                     tables.
*----------------------------------------------------------------------*
FORM KEYINFO_BUILD  CHANGING XS_KEYINFO  TYPE  SLIS_KEYINFO_ALV.

  XS_KEYINFO-HEADER01 = 'AZIDT'.
  XS_KEYINFO-ITEM01   = 'AZIDT'.
  XS_KEYINFO-HEADER02 = 'KUKEY'.                 "974044
  XS_KEYINFO-ITEM02   = 'KUKEY'.                 "974044

ENDFORM.                    " keyinfo_build

*&---------------------------------------------------------------------*
*&      Form  EVENTTAB_ALV_BUILD
*&---------------------------------------------------------------------*
*       Build Event table for ALV.
*----------------------------------------------------------------------*
*      <--XT_EVENTTAB_ALV  Table to hold events
*----------------------------------------------------------------------*
FORM EVENTTAB_ALV_BUILD  CHANGING XT_EVENTTAB_ALV TYPE SLIS_T_EVENT.

  DATA: LS_EVENT TYPE SLIS_ALV_EVENT.

* Function to trap ALV events.
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      I_LIST_TYPE = 0
    IMPORTING
      ET_EVENTS   = XT_EVENTTAB_ALV.

*TOP_OF_PAGE event.
  READ TABLE XT_EVENTTAB_ALV WITH KEY NAME = SLIS_EV_TOP_OF_PAGE INTO
LS_EVENT.

  IF SY-SUBRC = 0.
    MOVE GC_TOP_OF_PAGE_HIER TO LS_EVENT-FORM.
    MODIFY XT_EVENTTAB_ALV  FROM LS_EVENT TRANSPORTING FORM
      WHERE NAME = SLIS_EV_TOP_OF_PAGE.
  ENDIF.


ENDFORM.                    " EVENTTAB_ALV_BUILD
*&---------------------------------------------------------------------*
*&      Form  sort_info_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_SORT  text
*----------------------------------------------------------------------*
FORM sort_info_HIER  CHANGING xt_sort TYPE slis_t_sortinfo_alv.
  DATA: ls_sort TYPE slis_sortinfo_alv.

  ls_sort-fieldname = 'AZIDT'.
  ls_sort-spos      = 2.
  ls_sort-up        = 'X'.
  LS_SORT-SUBTOT    = 'X'.
  APPEND ls_sort TO xt_sort.

ENDFORM.                    " sort_info_alv
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE_hier
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form TOP_OF_PAGE_hier .                                     "#EC CALLED
  DATA: lp_grid1  TYPE REF TO cl_salv_form_layout_grid.
  DATA: lv_linsz LIKE sy-linsz.         "Line Size , temporary variable

  CALL FUNCTION 'REUSE_ALV_LIST_LAYOUT_INFO_GET'
    IMPORTING
      e_width = lv_linsz.

  MOVE lv_linsz TO bhdgd-lines.


  bhdgd-bukrs = febko-bukrs.
  bhdgd-uname = sy-uname.
  bhdgd-repid = sy-repid.
  char16      = text-l09.
  bhdgd-line1 = char16(8).
  bhdgd-line2 = text-l02.
  bhdgd-inifl = '0'.

  CALL FUNCTION 'FAGL_BATCH_HEADING_PERFORM'
    EXPORTING
      is_bhdgd = bhdgd.

  CREATE OBJECT lp_grid1.
  lp_grid1->create_text(
  row    = 1
  column = 1
  text = text-L38 ).

  cl_salv_form_content=>set( lp_grid1 ).
endform.                    " TOP_OF_PAGE_hier
* end changes after review C5056169 02.06.2004
*&---------------------------------------------------------------------*
*&      Form  dynpro_determine_br
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FEBEP_AVKOA  text
*      -->P_STRUC_FEBEP_ZUONR_UMSKZ  text
*----------------------------------------------------------------------*
form dynpro_determine_br  using    p_avkoa
                                   p_umskz.

  t019-dyncl = 'A'.
  t019-koart = p_avkoa.
  t019-umskz = p_umskz.
  t019-buvar = t001-buvar.

  READ TABLE t019.
  IF sy-subrc NE 0.
    t019-buvar = space.
    READ TABLE t019.
    IF sy-subrc NE 0.
        t019-umskz = space.
        READ TABLE t019.
        IF sy-subrc NE 0.
          MESSAGE ID 'F5' TYPE 'I' NUMBER '100' WITH 'T019' t019(4).
        ENDIF.
    ENDIF.
  ENDIF.
endform.                    " dynpro_determine_br
form extab_build_alv using value(list_name) type c           "n982069
                     changing lt_extab type slis_t_extab.

  data: ls_extab type slis_extab.

*general functions to be excluded
  ls_extab-fcode = '&ETA'.
  append ls_extab to lt_extab.
  ls_extab-fcode = '&EB9'.
  append ls_extab to lt_extab.
  ls_extab-fcode = '&ALL'.
  append ls_extab to lt_extab.
  ls_extab-fcode = '&SAL'.
  append ls_extab to lt_extab.
  ls_extab-fcode = '&ODN'.
  append ls_extab to lt_extab.
  ls_extab-fcode = '&OUP'.
  append ls_extab to lt_extab.
  ls_extab-fcode = '&XPA'.
  append ls_extab to lt_extab.
  ls_extab-fcode = '&ABC'.
  append ls_extab to lt_extab.
  ls_extab-fcode = '&ILT'.
  append ls_extab to lt_extab.
  ls_extab-fcode = '&ILD'.
  append ls_extab to lt_extab.
  ls_extab-fcode = '&UMC'.
  append ls_extab to lt_extab.
  ls_extab-fcode = '&SUM'.
  append ls_extab to lt_extab.
  ls_extab-fcode = '&OMP'.
  append ls_extab to lt_extab.
  ls_extab-fcode = '&XXL'.
  append ls_extab to lt_extab.
  ls_extab-fcode = '%SL'.
  append ls_extab to lt_extab.
  ls_extab-fcode = '&AQW'.
  append ls_extab to lt_extab.
  ls_extab-fcode = '&XML'.
  append ls_extab to lt_extab.
  ls_extab-fcode = '&AVR'.
  append ls_extab to lt_extab.
  ls_extab-fcode = '%SL'.
  append ls_extab to lt_extab.
  ls_extab-fcode = '&MIN'.
  append ls_extab to lt_extab.
  ls_extab-fcode = '&MAX'.
  append ls_extab to lt_extab.
  ls_extab-fcode = '%ML'.
  append ls_extab to lt_extab.
  ls_extab-fcode = '&KOM'.
  append ls_extab to lt_extab.
  ls_extab-fcode = '&AUF'.
  append ls_extab to lt_extab.

  case list_name.
  when 'STAT'.
    ls_extab-fcode = '&OL0'.
    append ls_extab to lt_extab.
    ls_extab-fcode = '&OLX'.
    append ls_extab to lt_extab.
  when 'PLOG'.
  endcase.

endform.
*&---------------------------------------------------------------------*
*&      Form  loop_xmessages
*&---------------------------------------------------------------------*
FORM loop_xmessages tables xmessages structure balmt
                           changing xt_fb01 like gt_fb01_1.

      LOOP AT xmessages.
        IF xmessages-msgid IS INITIAL OR
           xmessages-msgno IS INITIAL.
*----- Print Message if Call Trans and Posting Log (never for Lockbox)--
          msgid = 'FB'.
          msgno = '420'.
          msgv1 = xmessages-msgtxt.
          CLEAR: msgv2, msgv3, msgv4.
          IF  function = 'C'
          AND p_bupro  = 'X'.
            PERFORM druck_message CHANGING xt_fb01.
          ENDIF.
*----- Save Message for Lockbox Posting Log ---------------------------
          IF anwnd = '0003'                                 "
          AND bereich NE '2'.                               "30D
            PERFORM save_message_for_lbox_log USING bereich."
          ENDIF.                                            "
        ELSE.
*----- Print Message if Call Trans and Posting Log (never for Lockbox)--
          msgid = xmessages-msgid.
          msgno = xmessages-msgno.
          msgv1 = xmessages-msgv1.
          msgv2 = xmessages-msgv2.
          msgv3 = xmessages-msgv3.
          msgv4 = xmessages-msgv4.
          IF  function = 'C'
          AND p_bupro  = 'X'.
            msgtxt = xmessages-msgtxt.                      "hw818056
            PERFORM druck_message CHANGING xt_fb01.
          ENDIF.
*----- Save Message for Lockbox Posting Log ---------------------------
          IF anwnd = '0003'
          AND bereich NE '2'.
            PERFORM save_message_for_lbox_log USING bereich.
          ENDIF.
        ENDIF.
      ENDLOOP.

ENDFORM.                    " loop_xmessages
