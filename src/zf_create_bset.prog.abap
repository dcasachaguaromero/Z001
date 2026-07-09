*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* Report  ZF_CREATE_BSET
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*mm&
*tete
*&---------------------------------------------------------------------*
************************************************************************
* Version for 4.6C and 4.7
*-----------------------------------------------------------------------
* Read explanations and restrictions in note 649388
* If report is updated then update also attachment of that note !!
*-----------------------------------------------------------------------
*
* last change: June 22, 2005 Copy tax amounts from bseg into bset
* last change: July 30, 2004 SKE, SKT line items
* last change: March 31, 2004 Selection for tax code
* last change: Dec 03, 2003 Note 664567 implemented
* last change: Nov 18, 2003 Tolerance
* last change: Aug 21, 2003 Note 651751 deactivated
* last change: Aug 18, 2003
*              Notes implemented: 651751, 553812, 558288, 571928
* last change: Aug 8,2003
* last change: July 14,2003 downpayments
* last change: July 7, 2003
* last change: March 27, 2003
* last change: October 7, 2002
* last change: October 2, 2002
* last change: September 24, 2002
*
* Only documents transferred to accounting are selected
* i.e.: No documents originally posted in accounting are selected
* i.e.: awtyp = BKPF is not selected unless parameter no_fb01 is initial
*
* Table BSET contains the tax information of an accounting document.
* Report deletes all existing entries in table BSET
* and replaces them in total by newly calculated ones.
* Presupposition:
* this takes place in fact only if
* the the existing BSET is different from the the newly calculated BSET
*
* The line items of the document itsself (table BSEG) are not modified.
*
* Run report first in test mode by setting the parameter TESTRUN
* on the selection screen
* and
* analyse the listed documents carefully
* whether their stored (OLD) tax data in BSET is really wrong and
* whether the recalculated (NEW) tax data for BSET is really correct
*
* In the test mode there are of course no data base changes.
***********************************************************************
* Internal technical information:
* Function module FI_TAX_CALCULATION cannot be used directly because
* - Bypass-functionality might be active which must be deactivated for
*   selected documents in order to recalculate the BSET-entries
* - in normal call stacks BSET is not empty when FI_TAX_CALCULATION
*   is called,then BSET is only modified or some entries are appended.
* - But now, BSET must be built up from the scratch and this does not
*   work properly in FI_TAX_CALCULATION_WITHOUT_BYPASS
* - Therefore only the relevant parts from
*   FI_TAX_CALCULATION_WITHOUT_BYPASS
*   are copied directly in this report
************************************************************************
* Select-Options and Parameters
* p_belnr    FI document number
* p_bukrs    company code
* p_gjahr    business year
* p_budat    posting date
* p_blart    document type
* p_awtyp    reference procudure i.e. VBRK for SD billing documents
* p_tcode    transaction code
* p_awkey    bkpf-awkey
*
* no_fb01    ON = fb01,fb60 etc documents are not selected
* testrun    ON = no databbase changes
*-----------------------------------------------------------------------

REPORT  zf_create_bset  MESSAGE-ID ff LINE-SIZE 255.        "Aug 8,2003

TABLES: bkpf, bseg, bset.
TABLES: ttypv.                                              "N571928

DATA: xbkpf LIKE bkpf OCCURS 10 WITH HEADER LINE,
      ybkpf LIKE bkpf OCCURS 10 WITH HEADER LINE,
      xbseg LIKE bseg OCCURS 10 WITH HEADER LINE,
      xbset LIKE bset OCCURS 10 WITH HEADER LINE,
      ybset LIKE bset OCCURS 10 WITH HEADER LINE.

* output structure
DATA: BEGIN OF xoutput OCCURS 0,
          bukrs LIKE bkpf-bukrs,
          belnr LIKE bkpf-belnr,
          gjahr LIKE bkpf-gjahr,
          count_ist TYPE i,
          count_soll TYPE i,
          deleted TYPE i,
          inserted TYPE i,
          text(20) TYPE c,
          updated TYPE c,
      END OF xoutput.

* Bset for output
DATA: BEGIN OF bset_output OCCURS 0,
         status(3) TYPE c,      " 'OLD' or 'NEW',
         bukrs LIKE bset-bukrs,
         belnr LIKE bset-belnr,
         gjahr LIKE bset-gjahr,
         buzei LIKE bset-buzei,
         mwskz LIKE bset-mwskz,
         shkzg LIKE bset-shkzg,
         fwbas LIKE bset-fwbas,
         fwste LIKE bset-fwste,
         hwbas LIKE bset-hwbas,                             "Aug 8,2003
         hwste LIKE bset-hwste,                             "Aug 8,2003
         lwbas LIKE bset-hwbas,                             "Aug 8,2003
         lwste LIKE bset-hwste,                             "Aug 8,2003
      END OF bset_output.

* counter
DATA:  exist_bset_count TYPE i,
       calc_bset_count TYPE i,
       docs_checked TYPE i,
       docs_corrupt TYPE i,
       xcorrupt TYPE c,
       icommit TYPE i.
*
* begin of Nov, 18,2003
*DATA:  tolerance TYPE fwste VALUE '0.01'.
DATA:  l_fwste TYPE fwste,
       l_hwste TYPE hwste,
       l_h2ste TYPE h2ste,
       l_h3ste TYPE h3ste.
* end of Nov, 18,2003
DATA: not_sel.                                           "March 31,2004

SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME.
SELECT-OPTIONS: p_belnr FOR bkpf-belnr,
                p_bukrs FOR bkpf-bukrs MEMORY ID buk,
                p_gjahr FOR bkpf-gjahr MEMORY ID gjr,
                p_budat FOR bkpf-budat,
                p_blart FOR bkpf-blart,
                p_awtyp FOR bkpf-awtyp,   "July 7, 2003
                p_tcode FOR bkpf-tcode,   "July 7, 2003
                p_awkey FOR bkpf-awkey,   "July 7, 2003
                p_mwskz FOR bseg-mwskz.   "March 31,2004
SELECTION-SCREEN END OF BLOCK 001.
PARAMETERS : no_fb01 AS CHECKBOX DEFAULT 'X'.               "Aug 8,2003
PARAMETERS : copybseg AS CHECKBOX.                        "June 22, 2005
PARAMETERS : testrun AS CHECKBOX DEFAULT 'X'.
PARAMETERS : toleranc TYPE fwste DEFAULT 0.

* select documents
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*SELECT * FROM bkpf WHERE bukrs IN p_bukrs
*                   AND   belnr IN p_belnr
*                   AND   gjahr IN p_gjahr
*                   AND   budat IN p_budat
*                   AND   blart IN p_blart
*                   AND   awtyp IN p_awtyp
*                   AND   tcode IN p_tcode  "July 7, 2003
*                   AND   awkey IN p_awkey  "July 7, 2003
**"/ only posted, no statistical doc (no down paym. req)
*                   AND   bstat = space.
*
* NEW CODE
SELECT *
 FROM bkpf WHERE bukrs IN p_bukrs
                   AND   belnr IN p_belnr
                   AND   gjahr IN p_gjahr
                   AND   budat IN p_budat
                   AND   blart IN p_blart
                   AND   awtyp IN p_awtyp
                   AND   tcode IN p_tcode  "July 7, 2003
                   AND   awkey IN p_awkey  "July 7, 2003
*"/ only posted, no statistical doc (no down paym. req)
                   AND   bstat = space ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

* no documents originally posted in FI
  IF NOT no_fb01 IS INITIAL.                                "Aug 8,2003
    CHECK bkpf-awtyp NE 'BKPF'.
  ENDIF.

  IF sy-subrc = 0.
    MOVE-CORRESPONDING bkpf TO xbkpf.
    APPEND xbkpf.
  ENDIF.
ENDSELECT.

LOOP AT xbkpf.
  CLEAR not_sel.                                          "March 31,2004
  xcorrupt = space.
  docs_checked = docs_checked + 1.

  REFRESH: ybkpf, ybset, xbseg, xbset.
  CLEAR: ybkpf, ybset, xbseg, xbset.
  CLEAR: exist_bset_count, calc_bset_count.
  CLEAR: xoutput.

* to get recalculation in 4.6B
  IF xbkpf-awtyp NE 'RFBU'.
    xbkpf-awtyp = 'WBRK'.              " no calculation of discount base
  ENDIF.
  IF xbkpf-tcode = 'MRKO'.
    xbkpf-tcode = 'FB01'.
  ENDIF.
  IF xbkpf-glvor = 'SD00'.
    xbkpf-glvor = 'RFBU'.
  ENDIF.
  xbkpf-xmwst = 'X'.                   "calculate tax

  MOVE-CORRESPONDING xbkpf TO ybkpf.
  APPEND ybkpf.

SELECT * FROM bseg WHERE bukrs = xbkpf-bukrs AND
belnr = xbkpf-belnr AND
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*gjahr = xbkpf-gjahr.
GJAHR = XBKPF-GJAHR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
    IF  NOT bseg-mwskz IS INITIAL                    "March 31,2004
    AND  bseg-mwskz NE '**'.                         "March 31,2004
      IF bseg-mwskz IN p_mwskz.                      "March 31,2004
* ok
      ELSE.                                           "March 31,2004
        not_sel = 'X'.                                "March 31,2004
        EXIT.                                         "March 31,2004
      ENDIF.                                          "March 31,2004
    ENDIF.                                            "March 31,2004
    MOVE-CORRESPONDING bseg TO xbseg.
    APPEND xbseg.
  ENDSELECT.
  IF not_sel = 'X'.                                 "March 31,2004
    docs_checked = docs_checked - 1.                "March 31,2004
    CONTINUE.                                       "March 31,2004
  ENDIF.                                            "March 31,2004


SELECT * FROM bset WHERE bukrs = xbkpf-bukrs AND
belnr = xbkpf-belnr AND
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*gjahr = xbkpf-gjahr.
GJAHR = XBKPF-GJAHR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
    exist_bset_count = exist_bset_count + 1.
    MOVE-CORRESPONDING bset TO xbset.
    APPEND xbset.
  ENDSELECT.

* begin of Aug 8,2003
* doc not yet reported
  LOOP AT xbset.
    IF NOT xbset-stmdt IS INITIAL
    OR NOT xbset-stmti IS INITIAL.
      xoutput-text = 'Doc. already reported'.
      EXIT.
    ENDIF.
  ENDLOOP.

* CHECK xoutput-text IS INITIAL.                       Aug 21, 2003
* end of Aug 8,2003


*  CALL FUNCTION 'FI_TAX_CALCULATION'
*    TABLES
*      t_bkpf = ybkpf
*      t_bseg = xbseg
*      t_bset = ybset.
  PERFORM fi_tax_calculation TABLES ybkpf
                                    xbseg
                                    ybset.

  LOOP AT ybset.
    calc_bset_count = calc_bset_count + 1.
  ENDLOOP.

* no bset calculated
  IF calc_bset_count = 0.
    xoutput-text = 'No BSET '.
  ENDIF.

* begin of change June 22, 2005
  IF not copybseg IS INITIAL.
    PERFORM copy_bseg TABLES xbseg
                             ybset.
  ENDIF.
* end of change June 22, 2005

* begin of change September 24, 2002
*  copy STCEG, EGBLD, EGLLD
  DATA: l_stceg LIKE bset-stceg,
        l_egbld LIKE bset-egbld,
        l_eglld LIKE bset-eglld.
  CLEAR: l_stceg,
         l_egbld,
         l_eglld.
  CLEAR xbset.
  CLEAR ybset.
  LOOP AT xbset.
    IF NOT xbset-stceg IS INITIAL
    AND ybset-stceg IS INITIAL.
      l_stceg = xbset-stceg.
    ENDIF.
    IF  NOT xbset-egbld IS INITIAL
    AND ybset-egbld IS INITIAL.
      l_egbld = xbset-egbld.
    ENDIF.
    IF  NOT xbset-eglld IS INITIAL
    AND ybset-eglld IS INITIAL.
      l_eglld = xbset-eglld.
    ENDIF.
  ENDLOOP.

  IF NOT l_stceg IS INITIAL.
    ybset-stceg = l_stceg.
    MODIFY ybset TRANSPORTING stceg
                 WHERE belnr = xbset-belnr.
  ENDIF.
  IF NOT l_egbld IS INITIAL.
    ybset-egbld = l_egbld.
    MODIFY ybset TRANSPORTING egbld
                 WHERE belnr = xbset-belnr.
  ENDIF.
  IF NOT l_eglld IS INITIAL.
    ybset-eglld = l_eglld.
    MODIFY ybset TRANSPORTING eglld
                 WHERE belnr = xbset-belnr.
  ENDIF.
* end of change September 24, 2002

* corrupt when calc. BSET does not equal existing BSET
*  IF calc_bset_count ne exist_bset_count.
* corrupt when calc. BSET greater than existing BSET
  IF calc_bset_count NE exist_bset_count
  OR ybset[] NE xbset[].

* begin of change October 2, 2002
* activate or deactivate if necessary
* only special differences are checked
    IF  ybset[]         NE xbset[]
    AND calc_bset_count =  exist_bset_count.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES04 ECDK917080 *
SORT XBSET .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES04 ECDK917080 *
      LOOP AT ybset.
        READ TABLE xbset INDEX sy-tabix.
        IF xbset-fwbas NE ybset-fwbas
*        OR xbset-fwste NE ybset-fwste                     "Nov 18,2003
        OR xbset-hwbas NE ybset-hwbas
*        OR xbset-hwste NE ybset-hwste                     "Nov 18,2003
        OR xbset-h2bas NE ybset-h2bas
        OR xbset-h3bas NE ybset-h3bas
*        OR xbset-h2ste NE ybset-h2ste                     "Nov 18,2003
*        OR xbset-h3ste NE ybset-h3ste                     "Nov 18,2003
        OR xbset-ktosl NE ybset-ktosl
        OR xbset-kbetr NE ybset-kbetr                      "Oct. 7, 2002
*       OR xbset-knumh NE ybset-knumh
*       OR xbset-kschl NE ybset-kschl
        OR xbset-lstml NE ybset-lstml                       "Aug 8,2003
        OR xbset-lwste NE ybset-lwste                       "Aug 8,2003
        OR xbset-lwbas NE ybset-lwbas                       "Aug 8,2003
        OR xbset-shkzg NE ybset-shkzg.
          xcorrupt = 'X'.
        ENDIF.
* begin of Nov, 18,2003
        IF xcorrupt = 'X'.
          EXIT.
        ENDIF.
        l_fwste = abs( xbset-fwste - ybset-fwste ).
        l_hwste = abs( xbset-hwste - ybset-hwste ).
        l_h2ste = abs( xbset-h2ste - ybset-h2ste ).
        l_h3ste = abs( xbset-h3ste - ybset-h3ste ).

        IF l_fwste GT toleranc
        OR l_hwste GT toleranc
        OR l_h2ste GT toleranc
        OR l_h3ste GT toleranc.
          xcorrupt = 'X'.
        ENDIF.
        IF xcorrupt = 'X'.
          EXIT.
        ENDIF.
* end of Nov, 18,2003
      ENDLOOP.
      CHECK  xcorrupt = 'X'.
    ENDIF.
* end of change October 2, 2002

    xcorrupt = 'X'.

    MOVE-CORRESPONDING ybkpf TO xoutput.
    xoutput-count_ist = exist_bset_count.
    xoutput-count_soll = calc_bset_count.

* store some old bset data for output list
    LOOP AT xbset.
      bset_output-status = 'OLD'.
      MOVE-CORRESPONDING xbset TO bset_output.
      APPEND bset_output.
    ENDLOOP.

* store some new bset data for output list
    LOOP AT ybset.
      bset_output-status = 'NEW'.
      MOVE-CORRESPONDING ybset TO bset_output.
      APPEND bset_output.
    ENDLOOP.

    IF testrun IS INITIAL.
* delete old BSET
      DELETE bset FROM TABLE xbset.
      xoutput-deleted = sy-dbcnt.
* insert new BSET
      INSERT bset FROM TABLE ybset.
      xoutput-inserted = sy-dbcnt.
      xoutput-updated = 'X'.
      icommit = icommit + 1.
    ENDIF.

    APPEND xoutput.
  ENDIF.
  IF xcorrupt = 'X'.
    docs_corrupt = docs_corrupt + 1.
  ENDIF.
  IF icommit GT 500.
    COMMIT WORK.
    CLEAR icommit.
  ENDIF.

ENDLOOP.                               "xbkpf
COMMIT WORK.

PERFORM output_documents.

**********************************************************************
* form output_documents
**********************************************************************
FORM output_documents.

  SORT xoutput         BY bukrs belnr gjahr.
  SORT bset_output     BY bukrs belnr gjahr status buzei.

  FORMAT COLOR COL_HEADING.
  WRITE: / 'BUKRS  BELNR        GJAHR  existBSET   calcBSET  '.
  WRITE:   'deletedBSET  insertedBSET  updated  comment              '.
  ULINE.
  FORMAT COLOR OFF.

  LOOP AT xoutput.
    WRITE: /(6) xoutput-bukrs,
           (12) xoutput-belnr,
            (6) xoutput-gjahr,
           (10) xoutput-count_ist,
           (10) xoutput-count_soll,
           (13) xoutput-deleted,
           (13) xoutput-inserted,
            (8) xoutput-updated,
           (20) xoutput-text.
  ENDLOOP.

  NEW-LINE. ULINE.
  FORMAT COLOR COL_TOTAL.
  WRITE: / 'Documents checked:', docs_checked.
  WRITE: / 'Documents corrupt:', docs_corrupt.
  FORMAT COLOR OFF.


  NEW-PAGE.
  FORMAT COLOR COL_POSITIVE.
  WRITE: 'Corrected documents: compare old and new BSET'.
  FORMAT COLOR COL_HEADING.
  WRITE: / 'STA CompC  Doc.No       Year   LIN TC D'.
  WRITE: '       FC-BASE          FC-TAX ',
         '       LC-BASE          LC-TAX ',
         '       PC-BASE          PC-TAX '.


  FORMAT COLOR COL_NORMAL.
  LOOP AT bset_output.
    ON CHANGE OF bset_output-belnr.
      ULINE.
    ENDON.

    WRITE: /(3)   bset_output-status,
            (6)   bset_output-bukrs,
            (12)  bset_output-belnr,
            (6)   bset_output-gjahr,
            (3)   bset_output-buzei,

            (2)   bset_output-mwskz,
            (1)   bset_output-shkzg,
            (15)  bset_output-fwbas,
            (15)  bset_output-fwste,
            (15)  bset_output-hwbas,                        "Aug 8,2003
            (15)  bset_output-hwste,                        "Aug 8,2003
            (15)  bset_output-lwbas,                        "Aug 8,2003
            (15)  bset_output-lwste.                        "Aug 8,2003

  ENDLOOP.



ENDFORM.                               "output_documents
*&---------------------------------------------------------------------*
*&      Form  fi_tax_calculation
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_YKPF  text
*      -->P_XBSEG  text
*      -->P_YBSET  text
*----------------------------------------------------------------------*
FORM fi_tax_calculation TABLES   t_bkpf STRUCTURE bkpf
                                 t_bseg STRUCTURE bseg
                                 t_bset STRUCTURE bset.

  DATA: i_rwbset_head LIKE rwbset_head,
        t_rwbset LIKE rwbset OCCURS 0 WITH HEADER LINE.
  DATA: i_xale LIKE bkpf-xmwst.

  CLEAR:  i_rwbset_head,
          t_rwbset,
          i_xale.
  REFRESH t_rwbset.
* Begin of change G.Rupp
*   CALL FUNCTION 'FI_TAX_CALCULAT_WITHOUT_BYPASS'
*         EXPORTING
*              i_xale        = i_xale
*              i_rwbset_head = i_rwbset_head
*         TABLES
*              t_bkpf        = t_bkpf
*              t_bseg        = t_bseg
*              t_bset        = t_bset
*              t_rwbset      = t_rwbset.
  PERFORM fi_tax_calculat_without_bypass TABLES t_bkpf
                                                t_bseg
                                                t_bset
                                                t_rwbset
                                         USING  i_xale
                                                i_rwbset_head.
  .

* end of change G.Rupp
*
* Fortschreibung für das externe System
  IF NOT t_bset[]   IS INITIAL                              "N553812
  OR NOT t_rwbset[] IS INITIAL.                             "N553812
    READ TABLE t_bkpf INDEX 1.
    IF NOT t_bkpf-bukrs IS INITIAL.
      DATA: external_system_aktive TYPE c.
      DATA: tax_linewise           TYPE c.                  "N558288
      CLEAR tax_linewise.                                   "N558288
      CLEAR external_system_aktive.                         "N558288
      CALL FUNCTION 'CHECK_JURISDICTION_ACTIVE'
           EXPORTING
                i_bukrs    = t_bkpf-bukrs
           IMPORTING
                e_external = external_system_aktive
                e_xtxit    = tax_linewise.                  "N558288

      IF NOT external_system_aktive IS INITIAL.
        CALL FUNCTION 'EXTERNAL_TAX_DOC_ADD_GLTAXDATA'
             EXPORTING
                  i_rwbset_head = i_rwbset_head
             TABLES
                  t_bset        = t_bset
                  t_rwbset      = t_rwbset.
*  Compress
        CLEAR t_bset-taxps.
        MODIFY t_bset TRANSPORTING taxps WHERE taxps NE space.
* begin of note 571928
* tax group txgrp of no use if already compression in RW-interface
* if compression of BSEG in RW-interface then compress also BSET
        IF ttypv-awtyp NE t_bkpf-awtyp
        OR ttypv-awtyp IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*          SELECT * FROM ttypv WHERE awtyp EQ t_bkpf-awtyp.
*
* NEW CODE
          SELECT *
 FROM ttypv WHERE awtyp EQ t_bkpf-awtyp ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
          ENDSELECT.
        ENDIF.
        IF ttypv-awtyp = t_bkpf-awtyp
        AND NOT ttypv-awtyp IS INITIAL.
          CLEAR t_bset-txgrp.
          MODIFY t_bset TRANSPORTING txgrp        "N558288  N664567
                        WHERE txgrp NE space.     "N558288  N664567
        ENDIF.
* end of note 571928
        CALL FUNCTION 'FI_TAX_SV_COMPRESS'
             TABLES
                  i_bset = t_bset.
      ENDIF.                           "if external_system_aktive
    ENDIF.
  ENDIF.                                                    "N553812


ENDFORM.                               " fi_tax_calculation
*&---------------------------------------------------------------------*
*&      Form  fi_tax_calculat_without_bypass
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_XALE  text
*      -->P_I_RWBSET_HEAD  text
*      -->P_T_BKPF  text
*      -->P_T_BSEG  text
*      -->P_T_BSET  text
*      -->P_T_RWBSET  text
*----------------------------------------------------------------------*
FORM fi_tax_calculat_without_bypass TABLES   t_bkpf STRUCTURE bkpf
                                             t_bseg STRUCTURE bseg
                                             t_bset STRUCTURE bset
                                         t_rwbset STRUCTURE rwbset
                                          USING    i_xale
                                                   i_rwbset_head.
* begin of change G.Rupp
* This was originally the function module
* fi_tax_calculat_without_bypass
* end of change G.Rupp

  DATA: tabix     LIKE sy-tabix,
        bukrs     LIKE t001-bukrs,
        xfound(1) TYPE c.
  DATA: flg_br_active(1) TYPE c.

* Begin of insertion G.Rupp.
*-------------------------------------------------------------------
  TABLES: ttxd, t001.
* -------- from TAX2 TOP ------------------------------------------
  DATA: xtaxes   LIKE rtax1u21 OCCURS  5 WITH HEADER LINE,
*     ztaxes   like bset     occurs  5 with header line,
*     xbset    like bset     occurs  5 with header line,
      zbset    LIKE bset     OCCURS  5 WITH HEADER LINE,
*     xbkpf    like bkpf     occurs  1 with header line,
      xbseg    LIKE bseg     OCCURS 10 WITH HEADER LINE,
      ybseg LIKE bseg OCCURS 10 WITH HEADER LINE,   "G.Rupp July 14,2003
      xdbseg   LIKE dbseg    OCCURS 10 WITH HEADER LINE.

  DATA: xusvr LIKE bkpf-xusvr,
        kalsm LIKE t005-kalsm.

*-------------------------------------------------------------------
* end of insertion G.Rupp

  REFRESH xtaxes. "/ might not work here, should be in TAX2
  REFRESH xbseg.
  REFRESH xdbseg.
  CALL FUNCTION 'REFRESH_TAX_TABLES'.                       "HW44833
*--------------------------------------------------------------------
* begin of insertion March 27, 2003
* Steuerschema muß intern gelesen sein
*
  CLEAR ttxd.
  READ TABLE t_bkpf INDEX 1.           "nur ein Eintrag erlaubt ????
  READ TABLE t_bseg INDEX 1.
  IF t_bseg-stbuk IS INITIAL.
    bukrs = t_bkpf-bukrs.
  ELSE.
    bukrs = t_bseg-stbuk.
  ENDIF.

  CALL FUNCTION 'FIND_TAX_SPREADSHEET'
       EXPORTING
            buchungskreis = bukrs
       IMPORTING
            schema        = kalsm.
*
* Flag für Aufruf aus RW-IN setzen
*
  CALL FUNCTION 'SET_RWIN_FLAG'.

*
* Vorarbeit
*
  xusvr = space.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM ttxd WHERE kalsm = kalsm.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM ttxd WHERE kalsm = kalsm ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc = 0.
    xusvr = 'X'.
  ELSE.
    xusvr = space.
  ENDIF.
* end of change March 27, 2003
*-----------------------------------------------------------------------
* KHE: nur noch ein Belegkopf übergeben
  LOOP AT t_bkpf.
    LOOP AT t_bseg WHERE bukrs = t_bkpf-bukrs
                   AND belnr   = t_bkpf-belnr
                   AND gjahr   = t_bkpf-gjahr.
* Buchungskreisverrechnungszeilen einschließen da jetzt mit MWSKZ
*                  AND KTOSL   NE 'BUV'.
*
* For SD and MAR (mass accounts receivable)
* include tax items, otherwise exclude tax items.
*
      IF  t_bkpf-awtyp NE 'VBRK'
      AND t_bkpf-awtyp NE 'WBRK'
      AND t_bkpf-glvor NE 'SD00'
      AND t_bkpf-awtyp(2) NE 'RE'
      AND t_bkpf-awtyp NE 'TRAVL'      "new for 4.0c
      AND t_bkpf-awtyp NE 'FKKSU'
      OR ttxd-xtxit = 'X'.             "March 27, 2003
        CHECK t_bseg-buzid NE 'T'.
      ENDIF.
      IF t_bkpf-awtyp EQ 'FKKSU'.
        CHECK t_bseg-buzid EQ 'T'.
      ENDIF.
*
      MOVE-CORRESPONDING t_bseg TO xdbseg.
*
      IF t_bseg-koart EQ 'D'
      OR t_bseg-koart EQ 'K'.
*
* Calculate base amount only for a/r and a/p items
* but never calculate it for invoices from SD or MAR
*
        IF  t_bkpf-awtyp NE 'VBRK'
        AND t_bkpf-awtyp NE 'WBRK'
        AND t_bkpf-glvor NE 'SD00'
        AND t_bkpf-awtyp(2) NE 'RE'
        AND t_bkpf-awtyp NE 'TRAVL'    "new for 4.0c
        AND t_bkpf-awtyp NE 'FKKSU'.
          xdbseg-xskfb = 'X'.
        ENDIF.
* if cash discount base is set, don't calculate it later "/N523276
        IF NOT t_bseg-skfbt IS INITIAL.                     "/N523276
          CLEAR xdbseg-xskfb.                               "/N523276
        ENDIF.                                              "/N523276
      ELSE.
        xdbseg-xskfb = space.
      ENDIF.
      APPEND xdbseg.
      APPEND t_bseg TO xbseg.
    ENDLOOP.

* Copy relevant information from BSET to XTAXES.
* for the first company code
*    LOOP AT t_bset WHERE bukrs = t_bkpf-bukrs
*                   AND belnr   = t_bkpf-belnr
*                   AND gjahr   = t_bkpf-gjahr.
*      MOVE-CORRESPONDING t_bset TO xtaxes.
*      xtaxes-basmt = t_bset-fwbas.
*      APPEND xtaxes.
*    ENDLOOP.
  ENDLOOP.

**----------------------------------------------------------------------
* begin of change March 27, 2003

** Steuerschema muß intern gelesen sein
**
*  READ TABLE t_bkpf INDEX 1.           "nur ein Eintrag erlaubt ????
*  READ TABLE t_bseg INDEX 1.
*  IF t_bseg-stbuk IS INITIAL.
*    bukrs = t_bkpf-bukrs.
*  ELSE.
*    bukrs = t_bseg-stbuk.
*  ENDIF.
*
*  CALL FUNCTION 'FIND_TAX_SPREADSHEET'
*       EXPORTING
*            buchungskreis = bukrs
*       IMPORTING
*            schema        = kalsm.
**
** Flag für Aufruf aus RW-IN setzen
**
*  CALL FUNCTION 'SET_RWIN_FLAG'.
*
**
** Vorarbeit
**
*  xusvr = space.
*  SELECT SINGLE * FROM ttxd WHERE kalsm = kalsm.
*  IF sy-subrc = 0.
*    xusvr = 'X'.
*  ELSE.
*    xusvr = space.
*  ENDIF.
* end of change March 27, 2003
*-----------------------------------------------------------------------
* Note 651751 is not allowed in case of recalculation here Aug 21, 2003
* xstvr = X necessary to set xsnet = X (to find right tax base)
* IF t_bkpf-xmwst IS INITIAL.                      "N651751 deactivated
  CALL FUNCTION 'SET_TAX_AMOUNT'
       EXPORTING
            i_xusvr = xusvr
            i_reset = 'X'
       TABLES
            t_taxes = xtaxes.
* ENDIF.                                           "N651751 deactivated
*-----------------------------------------------------------------------
* begin of insertion G.Rupp
  LOOP AT xbseg WHERE ktosl = 'MVA'
                OR    ktosl = 'VVA'.
    DELETE xbseg.
    DELETE xdbseg INDEX sy-tabix.
  ENDLOOP.
* end of insertionm G.Rupp
*----------------------------------------------------------------------
* begin of G.Rupp July 14,2003
* in downpayments etc delete tax line items
  ybseg[] = xbseg[].
  LOOP AT ybseg WHERE umsks NE space
                AND mwskz NE space.
    LOOP AT xbseg WHERE mwskz = ybseg-mwskz
                  AND   buzid = 'T'
                  AND   mwart NE space.
      DELETE xbseg.
    ENDLOOP.

  ENDLOOP.
* end of G.Rupp July 14,2003
*----------------------------------------------------------------------
* Cross checks between FI document (BKPF & BSEG) and tax data (BSET)
* is performed here
*
  CALL FUNCTION 'CALCULATE_TAX_DOCUMENT'
       EXPORTING
            i_bukrs = bukrs
            i_noerr = 'X'
       TABLES
            t_bkpf  = t_bkpf
            t_bseg  = xbseg
            t_dbseg = xdbseg
* begin of change March 27, 2003
       EXCEPTIONS
            error_message = 8.
  IF sy-subrc = 8.
    IF sy-msgty = 'E'
    OR sy-msgty = 'A'.
      MESSAGE ID      sy-msgid
              TYPE    sy-msgty
              NUMBER  sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
* end of change March 27, 2003

*
* Steuernachweiszeilen
* jetzt aber immer ohne Steuerzeilen
*
  DATA ydbseg LIKE xdbseg OCCURS 10 WITH HEADER LINE.
  ydbseg[] = xdbseg[].
  LOOP AT xbseg WHERE buzid = 'T'.
    DELETE xbseg.
    DELETE xdbseg INDEX sy-tabix.
  ENDLOOP.
*-----------------------------------------------------------------------
* begin of insertion G.Rupp
  LOOP AT xbseg WHERE ktosl = 'SKV'
                OR    ktosl = 'SKE'               "July 30,2004
                OR    ktosl = 'SKT'               "July 30,2004
                OR    ktosl = 'VSK'               "July 30,2004
                OR    mwart NE space. "/ manual tax account lines
    DELETE xbseg.
    DELETE xdbseg INDEX sy-tabix.
  ENDLOOP.
* end of insertion G.Rupp
* --------------------------------------------------------------
* Flag zum Ausschalten von Meldung Steuerbetrag > 0 bei Steuerbasis = 0
* in CREATE_BSET_ITEM (TAX1) bestimmen
  DATA: flg_tax1_check_off TYPE c.
  PERFORM determine_flg_tax1_check USING t_bkpf-curt2
                                         t_bkpf-curt3
                                         flg_tax1_check_off.

  CALL FUNCTION 'CREATE_BSET_ITEM'
       EXPORTING
            transfer_prices_active = flg_tax1_check_off
       TABLES
            t_bkpf                 = t_bkpf
            t_bseg                 = xbseg
            t_bset                 = zbset
* begin of change March 27, 2003
       EXCEPTIONS
            error_message = 8.
  IF sy-subrc = 8.
    IF sy-msgty = 'E'
    OR sy-msgty = 'A'.
      MESSAGE ID      sy-msgid
              TYPE    sy-msgty
              NUMBER  sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
* end of change March 27, 2003


*
* Abmischen der BSET-Daten und BSEG-Daten
*
* Anzahlungen mit Steuerkennzeichen 0% für Immobilien/Darlehen
  IF t_bkpf-awtyp(2) EQ 'RE'.
    CLEAR zbset-buzei.
    MODIFY zbset TRANSPORTING buzei WHERE buzei NE space.
    CALL FUNCTION 'FI_TAX_SV_COMPRESS'
         TABLES
              i_bset = zbset.

    CALL FUNCTION 'FI_TAX_SV_COMPRESS'
         TABLES
              i_bset = t_bset.
  ENDIF.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* begin of deactivation G.Rupp
* Deactivated in this REPORT
* because t_bset is initially empty in the context of this report
*  LOOP AT zbset.
*    xfound = space.
*    LOOP AT t_bset WHERE mwskz EQ zbset-mwskz
*                   AND   shkzg EQ zbset-shkzg
*                   AND   txjcd EQ zbset-txjcd
*                   AND   ktosl EQ zbset-ktosl.
*      IF t_bkpf-awtyp NE 'FKKSU'.
*        CHECK t_bset-hkont = zbset-hkont.
*      ENDIF.
*      xfound = 'X'.
*      IF ttxd-xextn NE space.
*        CHECK t_bset-kschl = zbset-kschl.
*      ENDIF.
*      IF t_bset-txgrp IS INITIAL OR
*         t_bset-txgrp <> zbset-txgrp.
*        t_bset-txgrp = zbset-txgrp.
*      ENDIF.
** In case of problems in the determination of the jurisdiction codes we
** we trust the results determined by other applications
*      IF t_bset-txjdp IS INITIAL.
*        t_bset-txjdp = zbset-txjdp.
*      ENDIF.
*      IF t_bset-txjlv IS INITIAL.
*        t_bset-txjlv = zbset-txjlv.
*      ENDIF.
*      IF t_bset-hwbas IS INITIAL.
*        t_bset-hwbas = zbset-hwbas.
*      ENDIF.
*      IF t_bset-fwbas IS INITIAL.
*        t_bset-fwbas = zbset-fwbas.
*      ENDIF.
*      IF t_bset-h2bas IS INITIAL.
*        t_bset-h2bas = zbset-h2bas.
*      ENDIF.
*      IF t_bset-h3bas IS INITIAL.
*        t_bset-h3bas = zbset-h3bas.
*      ENDIF.
*      IF t_bset-knumh IS INITIAL.
*        t_bset-knumh = zbset-knumh.
*      ENDIF.
*      IF t_bset-kschl IS INITIAL.
*        t_bset-kschl = zbset-kschl.
*      ENDIF.
*      IF t_bkpf-glvor EQ 'SD00'
*      AND t_bkpf-tcode NE 'IDOC'.
** leave KBETR unchanged in case of invoices from SD
*      ELSE.
*        t_bset-kbetr = zbset-kbetr.
*      ENDIF.
*      IF t_bset-stbkz IS INITIAL.
*        t_bset-stbkz = zbset-stbkz.
*      ENDIF.
*      MODIFY t_bset.
*    ENDLOOP.
*
*    IF xfound = space.
** falsches Steuercustomizing im SD mit falschem Ktosl/Hkont
*      IF t_bkpf-glvor = 'SD00'.
**
** Pruefung ob Brasilianische Steuerrechnung aktiv ist
**
*        CHECK flg_br_active EQ space.
*        CALL FUNCTION 'J_1BSA_COMPONENT_ACTIVE'
*             EXPORTING
*                  bukrs                = t_bkpf-bukrs
*                  component            = 'BR'
*             EXCEPTIONS
*                  component_not_active = 02
*                  OTHERS               = 1.
*        IF sy-subrc = 0.
*          flg_br_active = 'X'.
** Fehlermeldung nur falls BR Steuerrechnung NICHT aktiv ist
*          CONTINUE.
*        ENDIF.
*        READ TABLE t_bset WITH KEY mwskz = zbset-mwskz.
** Falls in Tabelle kein Eintrag vorhanden z.B. ALE/IDOC oder bei 0%
** keine Fehlermeldung ausgeben
*        IF sy-subrc IS INITIAL
** TXJCD or --> and ersetzen
*        AND zbset-fwste NE space.
*          MESSAGE e761 WITH  zbset-mwskz zbset-ktosl.
*        ENDIF.
*      ENDIF.
**
** Steuernachweiszeile ist noch nicht vorhanden, deshalb nachtragen
**
*
*      MOVE-CORRESPONDING zbset TO t_bset.
**
** Beschaffen der richtigen (vorläufigen) Belegnummer für die ergänzten
** ZBSET Zeilen
*
*      LOOP AT t_bseg WHERE mwskz EQ t_bset-mwskz.
*        EXIT.
*      ENDLOOP.
*      IF t_bseg-stbuk IS INITIAL.
*        t_bset-bukrs = t_bseg-bukrs.
*        t_bset-gjahr = t_bseg-gjahr.
*        t_bset-belnr = t_bseg-belnr.
*      ELSE.
*        READ TABLE t_bseg WITH KEY bukrs = t_bseg-stbuk.
*        t_bset-bukrs = t_bseg-bukrs.
*        t_bset-gjahr = t_bseg-gjahr.
*        t_bset-belnr = t_bseg-belnr.
*      ENDIF.
*      APPEND t_bset.
*    ENDIF.
*  ENDLOOP.
*
* Die Belegdaten wurden in den Steuerroutinen modifiziert
*
*  CLEAR tabix.
** Bei buchungskreisübergreifenden Buchungen wird  nur der Beleg im
** auslösenden Buchungskreis übergeben
*  LOOP AT t_bkpf.
*    LOOP AT t_bseg WHERE bukrs = t_bkpf-bukrs
*                   AND belnr   = t_bkpf-belnr
*                   AND gjahr   = t_bkpf-gjahr.
*      tabix = tabix + 1.
**
*      IF t_bseg-skfbt IS INITIAL.
**       READ TABLE xdbseg INDEX tabix.          " note 305624
*        READ TABLE ydbseg INDEX tabix.
*
*        IF sy-subrc IS INITIAL.
**          IF NOT ydbseg-skfbt IS INITIAL.     " note 321612
**            MESSAGE e799 with 'SKFBT'.
**          ENDIF.
**         t_bseg-skfbt = xdbseg-skfbt.
*          t_bseg-skfbt = ydbseg-skfbt.
*        ENDIF.
*      ENDIF.
**
*      IF t_bseg-hwbas IS INITIAL
*      OR t_bseg-fwbas IS INITIAL
*      OR t_bseg-txgrp IS INITIAL.
** Die Beträge werden aus den verdichteten ZBSET-Zeilen ergänzt
*        LOOP AT zbset WHERE hkont EQ t_bseg-hkont
*                      AND   mwskz EQ t_bseg-mwskz
*                      AND   shkzg EQ t_bseg-shkzg.
*          IF t_bseg-hwbas IS INITIAL.
*            t_bseg-hwbas = zbset-hwbas.
*          ENDIF.
*          IF t_bseg-fwbas IS INITIAL.
*            t_bseg-fwbas = zbset-fwbas.
*          ENDIF.
*          IF t_bseg-txgrp IS INITIAL.
*            t_bseg-txgrp = zbset-txgrp.
*          ENDIF.
*        ENDLOOP.
*        IF NOT sy-subrc IS INITIAL.
** ADD TXGRP in GL accounts
*          LOOP AT zbset WHERE mwskz EQ t_bseg-mwskz.
*            IF t_bseg-txgrp IS INITIAL.
*              t_bseg-txgrp = zbset-txgrp.
*            ENDIF.
*            EXIT.
*          ENDLOOP.
*        ENDIF.
*      ENDIF.
*      MODIFY t_bseg.
*    ENDLOOP.
*  ENDLOOP.

*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* end of deactivation G.Rupp

* begin of insertion G.Rupp
  t_bset[] = zbset[].

** Beschaffen der richtigen (vorläufigen) Belegnummer für die ergänzten
** ZBSET Zeilen
*
  LOOP AT t_bset.
    LOOP AT t_bseg WHERE mwskz EQ t_bset-mwskz.
      EXIT.
    ENDLOOP.
    IF t_bseg-stbuk IS INITIAL.
      t_bset-bukrs = t_bseg-bukrs.
      t_bset-gjahr = t_bseg-gjahr.
      t_bset-belnr = t_bseg-belnr.
    ELSE.
      READ TABLE t_bseg WITH KEY bukrs = t_bseg-stbuk.
      t_bset-bukrs = t_bseg-bukrs.
      t_bset-gjahr = t_bseg-gjahr.
      t_bset-belnr = t_bseg-belnr.
    ENDIF.
    MODIFY t_bset.
  ENDLOOP.
* end of insertion G.Rupp
************************************************************************

  IF  t_bkpf-awtyp  = 'VBRK'
  OR  t_bkpf-awtyp  = 'WBRK'
  OR  t_bkpf-glvor = 'SD00'
  OR  t_bkpf-awtyp(2) = 'RE'
  OR  t_bkpf-awtyp = 'TRAVL'           "New for 4.0c
  OR  t_bkpf-awtyp = 'FKKSU'.
    xdbseg[] = ydbseg[].
  ENDIF.

*
* Steuerpositionen komprimieren
*
* if ttxd-xextn is initial.                                 "ALRK080848
* DATA external_tax_system_used TYPE c.                     "ALRK080848
* CALL FUNCTION 'DETERMINE_EXTERN_SYSTEM_USED'              "ALRK080848
*       EXPORTING
*            schema                   = kalsm
*       IMPORTING
*            external_tax_system_used = external_tax_system_used.
*      EXCEPTIONS
*           not_found                = 1
*           OTHERS                   = 2.

* IF  external_tax_system_used = 'X'.                       "ALRK080848
*   CALL FUNCTION 'FI_TAX_COMPRESS_TXJCD'                   "ALRK080848
*           EXPORTING external_system_used = external_tax_system_used
*           TABLES
*                t_bset = t_bset.
*
*
* ELSE.                                                     "ALRK080848
  CALL FUNCTION 'FI_TAX_SV_COMPRESS'
       TABLES
            i_bset = t_bset.
* ENDIF.
* Fuer Werke im Ausland die Steuer in Meldewaehrung
* fortschreiben
*  LOOP AT zbset.
*    LOOP AT t_bset WHERE hkont EQ zbset-hkont
*                   AND   mwskz EQ zbset-mwskz
*                   AND   shkzg EQ zbset-shkzg
*                   AND   txjcd EQ zbset-txjcd
*                   AND   ktosl EQ zbset-ktosl.
*      IF t_bset-lstml IS INITIAL.
*        t_bset-lstml = zbset-lstml.
*      ENDIF.
*      IF t_bset-lwste IS INITIAL.
*        t_bset-lwste = zbset-lwste.
*      ENDIF.
*      IF t_bset-lwbas IS INITIAL.
*        t_bset-lwbas = zbset-lwbas.
*      ENDIF.
*      MODIFY t_bset.
*    ENDLOOP.
*  ENDLOOP.

  DATA: wa_t005 LIKE t005, wa_t007a LIKE t007a.
  DATA: xwia LIKE t000f-xwiaa,
        x001 LIKE t001,
        x005 LIKE t005,
        locl_land  LIKE t007a-lstml,
        locl_waers LIKE t005-waers,
        locl_kurst LIKE t005-kurst,
        date LIKE bkpf-budat.

  READ TABLE t_bkpf INDEX 1.
  CALL FUNCTION 'CHECK_PLANTS_ABROAD_ACTIVE'
       EXPORTING
            i_bukrs       = t_bkpf-bukrs
       IMPORTING
            e_fi_isactive = xwia.
  IF NOT xwia IS INITIAL.
    CALL FUNCTION 'FI_COMPANY_CODE_DATA'
         EXPORTING
              i_bukrs = t_bkpf-bukrs
         IMPORTING
              e_t001  = x001.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM t005 INTO wa_t005 WHERE land1 = x001-land1.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM t005 INTO wa_t005 WHERE land1 = x001-land1 ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    kalsm = wa_t005-kalsm.
    LOOP AT t_bset.
      tabix = sy-tabix.
      CLEAR: wa_t007a.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM t007a INTO wa_t007a WHERE kalsm = kalsm AND
*                                                  mwskz = t_bset-mwskz.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM t007a INTO wa_t007a WHERE kalsm = kalsm AND
                                                  mwskz = t_bset-mwskz ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF wa_t007a-lstml IS INITIAL.
        wa_t007a-lstml = x001-land1.
      ENDIF.
      CALL FUNCTION 'FI_COUNTRY_DATA'
           EXPORTING
                i_land1 = wa_t007a-lstml
           IMPORTING
                e_t005  = x005.
      locl_land   = x005-land1.
      locl_waers  = x005-waers.
      locl_kurst  = x005-kurst.

      IF t_bset-lstml IS INITIAL.
        t_bset-lstml = wa_t007a-lstml.
      ENDIF.
      IF locl_waers = t_bkpf-waers.
        t_bset-lwste = t_bset-fwste.
        t_bset-lwbas = t_bset-fwbas.
      ELSEIF locl_waers = t_bkpf-hwaer AND locl_kurst = 'M'.
        t_bset-lwste = t_bset-hwste.
        t_bset-lwbas = t_bset-hwbas.
      ELSEIF locl_waers = t_bkpf-hwae2 AND t_bkpf-kuty2 = 'M'
                                       AND locl_kurst = 'M'.
        t_bset-lwste = t_bset-h2ste.
        t_bset-lwbas = t_bset-h2bas.
      ELSEIF locl_waers = t_bkpf-hwae3 AND t_bkpf-kuty3 = 'M'
                                       AND locl_kurst = 'M'.
        t_bset-lwste = t_bset-h3ste.
        t_bset-lwbas = t_bset-h3bas.
      ELSE.
        IF t_bkpf-glvor = 'SD00'.
          date = t_bkpf-wwert.         "use same date as SD
        ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE * FROM t001 WHERE bukrs = t_bset-bukrs.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS  FROM t001 WHERE bukrs = t_bset-bukrs ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          IF t001-txkrs = '3'.
            date = t_bkpf-bldat.
          ELSE.
            date = t_bkpf-budat.
          ENDIF.
        ENDIF.
        IF t_bset-lwbas IS INITIAL.
          CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
               EXPORTING
                    local_currency   = locl_waers
                    foreign_currency = t_bkpf-waers
                    foreign_amount   = t_bset-fwbas
                    date             = date
                    type_of_rate     = locl_kurst
               IMPORTING
                    local_amount     = t_bset-lwbas.
        ENDIF.
        IF ( t_bset-lwste IS INITIAL )
        AND NOT ( t_bset-fwste IS INITIAL ) .
          CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
               EXPORTING
                    local_currency   = locl_waers
                    foreign_currency = t_bkpf-waers
                    foreign_amount   = t_bset-fwste
                    date             = date
                    type_of_rate     = locl_kurst
               IMPORTING
                    local_amount     = t_bset-lwste.
        ENDIF.
      ENDIF.
      MODIFY t_bset INDEX tabix.
    ENDLOOP.
  ENDIF.


ENDFORM.                               " fi_tax_calculat_without_bypass
* Kontext: SD-Faktura mit par. Bewertungen
*          hier gibt es Bewertungsbuchungen
*          ( Zeilen mit HW1 = 0, HW2 <> 0 und/oder HW3 <> 0 ),
*          die in CREATE_BSET_ITEM zum Abbruch FF759 führen
*----------------------------------------------------------------------*
FORM determine_flg_tax1_check USING  value(curt2)  LIKE bkpf-curt2
                                     value(curt3)  LIKE bkpf-curt3
                                         flg_tax1_check_off TYPE c.


* Wenn HW2 oder HW3 nicht-legale Bewertung ist
  DATA: flg_nonlegal_valutyp TYPE c.
  DATA: valutyp LIKE acccr-valutyp.
* Wenn HW2 geführt wird
  IF NOT curt2 IS INITIAL.
    CALL FUNCTION 'K_CURRTYP_AND_VAL_GET'
         EXPORTING
              i_cvtyp       = curt2                      "#EC DOM_EQUAL
         IMPORTING
              e_valutyp     = valutyp
         EXCEPTIONS
              illegal_cvtyp = 1
              OTHERS        = 2.
    IF sy-subrc <> 0.
      valutyp = '0'.
    ENDIF.
    IF NOT valutyp IS INITIAL.
      flg_nonlegal_valutyp = 'X'.
    ENDIF.
  ENDIF.
* Wenn HW3 geführt wird
  IF NOT curt3 IS INITIAL.
    CALL FUNCTION 'K_CURRTYP_AND_VAL_GET'
         EXPORTING
              i_cvtyp       = curt3                      "#EC DOM_EQUAL
         IMPORTING
              e_valutyp     = valutyp
         EXCEPTIONS
              illegal_cvtyp = 1
              OTHERS        = 2.
    IF sy-subrc <> 0.
      valutyp = '0'.
    ENDIF.
    IF NOT valutyp IS INITIAL.
      flg_nonlegal_valutyp = 'X'.
    ENDIF.
  ENDIF.

* Dann schalte die Prüfung in CREATE_BSET_ITEM aus
  IF flg_nonlegal_valutyp = 'X'.
    flg_tax1_check_off = 'X'.
  ELSE.
    flg_tax1_check_off = ' '.
  ENDIF.

ENDFORM.                               " DETERMINE_FLG_TAX1_CHECK
*&---------------------------------------------------------------------*
*&      Form  copy_bseg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_XBSEG  text
*      -->P_YBSET  text
*----------------------------------------------------------------------*
FORM copy_bseg TABLES   t_bseg STRUCTURE bseg
                        t_bset STRUCTURE bset.

* copy tax data from bseg into bset
  DATA: l_count TYPE i.

  LOOP AT t_bset WHERE fwste NE 0                " line are not in BSEG
                       AND NOT hkont IS initial. "no NVV
    CLEAR l_count.
    LOOP AT t_bseg WHERE mwart NE space     "only tax lines
                   AND   xauto NE space     "only automatic lines
                   AND   mwskz = t_bset-mwskz
                   AND   txjcd = t_bset-txjcd
                   AND   ktosl = t_bset-ktosl
                   AND   hkont = t_bset-hkont
                   AND   shkzg = t_bset-shkzg.

      IF NOT t_bset-txgrp IS INITIAL.
        CHECK t_bseg-txgrp = t_bset-txgrp.
      ENDIF.

      ADD 1 TO l_count.

    ENDLOOP.
    IF l_count = 1.
      t_bset-fwbas = t_bseg-fwbas.
      t_bset-hwbas = t_bseg-hwbas.
      t_bset-fwste = t_bseg-wrbtr.
      t_bset-hwste = t_bseg-dmbtr.
      MODIFY t_bset.
    ELSE.
      EXIT.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " c
