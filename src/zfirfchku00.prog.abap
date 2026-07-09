*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <27-12-2019> *
*& Transport Number: < ECDK916982 > *
*&---------------------------------------------------------------------*
************************************************************************
* Copy The Check Number In A Reference Document Field                  *
*----------------------------------------------------------------------*
* -> If a further field of the document is to be filled with           *
*    the check number, additional lines, which correspond              *
*    with ** (double star) characterized lines, must are inserted.     *
************************************************************************
* Title       : Create Reference for Check from Payment Document
*----------------------------------------------------------------------*
* Change history of ALV Development
* Program description: Display the list of Reference for Check from
*                      Payment Document
* Short description of the program:This program Converted into ALV List
*          Using Function Modules REUSE_ALV_BLOCK_LIST_INIT,
*          REUSE_ALV_BLOCK_LIST_APPEND,REUSE_ALV_BLOCK_LIST_DISPLAY,
*          The ALV output contains Classical append ALV list
*----------------------------------------------------------------------*

REPORT rfchku01
       MESSAGE-ID fs
       NO STANDARD PAGE HEADING
       LINE-SIZE 132.

*----------------------------------------------------------------------*
* Data Declarations                                                    *
*----------------------------------------------------------------------*
INCLUDE ff05lcdv.                "function module BELEG_WRITE_DOCUMENT
INCLUDE ff05lcdf.                "form CD_CALL_BELEG

TABLES:
* -> If further fields of a document are to be filled with
*    the check number, additional reference flags must be maintained
*    in the value table of the domain of PAYR-IREFE.
  payr,                          "Payment transfer medium file
  t001,                          "Company Codes
  bseg,                          "Accounting document segment
  rfsdo,                         "Data elements for selection
  bsec, bsed, bset.              "Dummy Tables for
"function module CHANGE_DOCUMENT

TYPES:
  BEGIN OF protocol_line,        "Protocol line
    zbukr LIKE payr-zbukr,
    vblnr LIKE payr-vblnr,
    gjahr LIKE payr-gjahr,
    hbkid LIKE payr-hbkid,
    hktid LIKE payr-hktid,
    rzawe LIKE payr-rzawe,
    chect LIKE payr-chect,
  END OF protocol_line.

RANGES:
  r_laufd FOR payr-laufd,        "Date on which the program is to be run
  r_laufi FOR payr-laufi.        "Additional identification

DATA:
  t_payr        LIKE payr   OCCURS 0 WITH HEADER LINE,
  t_bkpf        LIKE bkpf   OCCURS 1 WITH HEADER LINE,
  t_bseg        LIKE bseg   OCCURS 0 WITH HEADER LINE,
  t_bkdf        LIKE bkdf   OCCURS 0 WITH HEADER LINE,
  t_bsec        LIKE bsec   OCCURS 0 WITH HEADER LINE,
  t_bsed        LIKE bsed   OCCURS 0 WITH HEADER LINE,
  t_bset        LIKE bset   OCCURS 0 WITH HEADER LINE,
  t_laufk       LIKE ilaufk OCCURS 0 WITH HEADER LINE,
  t_update      TYPE protocol_line OCCURS 0 WITH HEADER LINE,
  t_queue       TYPE protocol_line OCCURS 0 WITH HEADER LINE,
  t_error       TYPE protocol_line OCCURS 0 WITH HEADER LINE,
  t_multi       TYPE protocol_line OCCURS 0 WITH HEADER LINE,
  w_xbseg       LIKE fbseg,
  w_ybseg       LIKE fbseg,
  i_refkz       LIKE payr-irefe,
  i_noprot      TYPE c VALUE 'X',
  i_ptype       TYPE c,
*  I_PAGEEND     TYPE C VALUE 'X', "removed Retrofit
*  I_INTENSIFIED TYPE C,           "removed Retrofit
  is_zbukr(10)  TYPE c,
  is_vblnr(10)  TYPE c,
  is_gjahr(10)  TYPE c,
  is_hbkid(10)  TYPE c,
  is_hktid(10)  TYPE c,
  is_rzawe(10)  TYPE c,
  subrc_w LIKE sy-subrc,
  im_chect(20)  TYPE c.

* Data Z
DATA:    BEGIN OF s_postab OCCURS 50,
             xauth(1)      TYPE c,                 " Berechtigung?
             xhell(1)      TYPE c.                 " Hell anzeigen?
        INCLUDE STRUCTURE rfpos.              " Listanzeigen-Struktur
INCLUDE rfeposc9.                     " Kunden-Sonderfelder
DATA:      xbkpf(1)      TYPE c,                 " BKPF nachgelesen?
           xbseg(1)      TYPE c,                 " BSEG nachgelesen?
           xbsec(1)      TYPE c,                 " BSEC nachgelesen?
           xbsed(1)      TYPE c,                 " BSED nachgelesen?
           xpayr(1)      TYPE c,                 " PAYR nachgelesen?
           xbsegc(1)     TYPE c,                 " BSEGC nachgelesen?
           xbsbv(1)      TYPE c,                 " BSBV nachgelesen?
           xmod(1)       TYPE c,                 " POSTAB modifiziert?
         END OF s_postab.
DATA: wa_bsak TYPE bsak,
      wa_rut TYPE stcd1.
*end data z
************************************************************************
***    Begin of ALV Conversion                   Retrofit
************************************************************************
***Data Declaration
TYPE-POOLS: slis. "ALV def. type-pool
DATA: gt_update TYPE STANDARD TABLE OF foap_s_rfchku00_list.
"Update table
DATA: gt_queue TYPE STANDARD TABLE OF foap_s_rfchku00_list.
" Queue table
DATA: gt_error TYPE STANDARD TABLE OF foap_s_rfchku00_list.
"Error table
DATA: gt_multi TYPE STANDARD TABLE OF foap_s_rfchku00_list.
"Multiple check table
DATA: gv_repid TYPE sy-repid.               "Report field
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv.  " ALV Field Catalog Table
DATA: gs_layo TYPE slis_layout_alv.     "layout table
DATA:gc_tol_form1 TYPE slis_formname VALUE 'TOP_OF_LIST_ONE'.
"top of page 1
DATA:gc_tol_form2 TYPE slis_formname VALUE 'TOP_OF_LIST_TWO'.
"top of page 2
DATA:gc_tol_form3 TYPE slis_formname VALUE 'TOP_OF_LIST_THREE'.
"top of page 3
DATA:gc_tol_form4 TYPE slis_formname VALUE 'TOP_OF_LIST_FOUR'.
"top of page 4
DATA: gv_count TYPE i. "Counter field
CONSTANTS: gc_str   TYPE dd02l-tabname VALUE
                        'FOAP_S_RFCHKU00_LIST',"Structure
           gc_color TYPE char05 VALUE 'COLOR', "TO MAINTAIN COLOR VALUE
           gc_chk   TYPE char01 VALUE 'X', "Check field
           gc_ptu   TYPE char01 VALUE 'U', "update type field
           gc_ptq   TYPE char01 VALUE 'Q', "Queue type field
           gc_ptm   TYPE char01 VALUE 'M', "multiple type field
           gc_pte   TYPE char01 VALUE 'E', "Error type field
           gc_ltya  TYPE char01 VALUE 'A', "Layout type field
           gc_s     TYPE char01 VALUE 'S', "short text field
           gc_outtab TYPE slis_tabname VALUE 'OUTTAB', "Table name
           gc_gjahr TYPE slis_fieldname VALUE 'GJAHR', "field name
           gc_hbkid TYPE slis_fieldname VALUE 'HBKID', "field name
           gc_rzawe TYPE slis_fieldname VALUE 'RZAWE'. "field name
************************************************************************
***    End of ALV Conversion                     Retrofit
************************************************************************


*----------------------------------------------------------------------*
* Selections                                                           *
*----------------------------------------------------------------------*
SELECT-OPTIONS:
  s_zbuk FOR payr-zbukr,       "Paying company code
  s_bank FOR payr-hbkid,       "Short key for a house bank
  s_acco FOR payr-hktid.       "ID for account details

SELECTION-SCREEN:
SKIP 1,
BEGIN OF BLOCK bl0 WITH FRAME TITLE text-001.
PARAMETERS: p_refe LIKE payr-irefe.
* TEXT-001: 'General selections'
SELECT-OPTIONS:
  s_chec FOR payr-chect,       "Check number
  s_vbln FOR payr-vblnr,       "Document number
  s_zald FOR rfsdo-chkladat,   "Check date
  s_cpud FOR rfsdo-chkledat,   "Print date
  s_user FOR rfsdo-chkluser,   "Print user
  s_zweg FOR payr-rzawe.       "Payment method
SELECTION-SCREEN:
BEGIN OF LINE,
  COMMENT 01(31) text-002 FOR FIELD zw_laufd.
*   TEXT-002: 'Checks from a pay run'
PARAMETERS:
  zw_laufd LIKE payr-laufd.  "Date on which the program is to be run
SELECTION-SCREEN POSITION 46.
PARAMETERS:
  zw_laufi LIKE payr-laufi,  "Additional identification
  zw_xvorl LIKE reguh-xvorl NO-DISPLAY.
SELECTION-SCREEN:
END OF LINE,
END OF BLOCK bl0.

SELECTION-SCREEN:
BEGIN OF BLOCK bl1 WITH FRAME TITLE text-003,
* TEXT-003: 'Selection of a target field for the check number'
  BEGIN OF LINE,
    POSITION 1.
*   Fill the reference document number with the check number
PARAMETERS: p_xblnr RADIOBUTTON GROUP func DEFAULT 'X'.
SELECTION-SCREEN: COMMENT 3(40) il_xblnr FOR FIELD p_xblnr,
END OF LINE,
BEGIN OF LINE,
POSITION 1.
*   Fill the allocation number with the check number
PARAMETERS: p_zuonr RADIOBUTTON GROUP func.
SELECTION-SCREEN: COMMENT 3(40) il_zuonr FOR FIELD p_zuonr,
END OF LINE,
BEGIN OF LINE,
POSITION 1.
*   Fill the reference key for line item with the check number
PARAMETERS: p_xref3 RADIOBUTTON GROUP func.
SELECTION-SCREEN: COMMENT 3(40) il_xref3 FOR FIELD p_xref3,
END OF LINE,
**BEGIN OF LINE, POSITION 1.
**  PARAMETERS: Further_Parameter RADIOBUTTON GROUP FUNC.
**  SELECTION-SCREEN: COMMENT 3(50) Label_Variable.
**END OF LINE,
END OF BLOCK bl1.

*----------------------------------------------------------------------*
*  Initialization                                                      *
*----------------------------------------------------------------------*
INITIALIZATION.
  REFRESH t_laufk.
  t_laufk-laufk = 'W'.
  t_laufk-sign  = 'E'.
  APPEND t_laufk.
  PERFORM get_label USING 'PAYR' 'S': 'ZBUKR' is_zbukr,
                                      'VBLNR' is_vblnr,
                                      'GJAHR' is_gjahr,
                                      'HBKID' is_hbkid,
                                      'HKTID' is_hktid,
                                      'RZAWE' is_rzawe.
  PERFORM get_label USING 'PAYR' 'M': 'CHECT' im_chect.
  PERFORM get_label USING 'BKPF' 'L': 'XBLNR' il_xblnr.
  PERFORM get_label USING 'BSEG' 'L': 'ZUONR' il_zuonr,
                                      'XREF3' il_xref3.
************************************************************************
***    Begin of ALV Conversion                   Retrofit
************************************************************************
  gv_repid = sy-repid.
************************************************************************
***    End of ALV Conversion                     Retrofit
************************************************************************
*----------------------------------------------------------------------*
* Check Of The Selections                                              *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON s_zbuk.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM t001 WHERE bukrs IN s_zbuk.
*
* NEW CODE
  SELECT *
 FROM t001 WHERE bukrs IN s_zbuk ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    AUTHORITY-CHECK OBJECT 'F_PAYR_BUK' ID 'BUKRS' FIELD t001-bukrs
                                        ID 'ACTVT' FIELD '02'.
*   Authority check
    IF sy-subrc <> 0.
      SET CURSOR FIELD 'S_ZBUK'.
      MESSAGE e515 WITH s_zbuk.
    ENDIF.
  ENDSELECT.
* Company code check
  IF sy-subrc <> 0.
    MESSAGE e511 WITH s_zbuk.
  ENDIF.

*---------------------------------------------------------------------*
* F1-Help For Radiobuttons                                            *
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON HELP-REQUEST FOR p_xblnr.
  CALL FUNCTION 'HELP_OBJECT_SHOW_FOR_FIELD'
    EXPORTING
      called_for_tab   = 'BKPF'
      called_for_field = 'XBLNR'.

AT SELECTION-SCREEN ON HELP-REQUEST FOR p_zuonr.
  CALL FUNCTION 'HELP_OBJECT_SHOW_FOR_FIELD'
    EXPORTING
      called_for_tab   = 'BSEG'
      called_for_field = 'ZUONR'.

AT SELECTION-SCREEN ON HELP-REQUEST FOR p_xref3.
  CALL FUNCTION 'HELP_OBJECT_SHOW_FOR_FIELD'
    EXPORTING
      called_for_tab   = 'BSEG'
      called_for_field = 'XREF3'.


*---------------------------------------------------------------------*
* F4 For Payment Method                                               *
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR zw_laufd.
  CALL FUNCTION 'F4_ZAHLLAUF'
    EXPORTING
      f1typ = 'D'
      f1nme = 'ZW_LAUFD'
      f2nme = 'ZW_LAUFI'
    IMPORTING
      laufd = zw_laufd
      laufi = zw_laufi
    TABLES
      laufk = t_laufk.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR zw_laufi.
  CALL FUNCTION 'F4_ZAHLLAUF'
    EXPORTING
      f1typ = 'I'
      f1nme = 'ZW_LAUFI'
      f2nme = 'ZW_LAUFD'
    IMPORTING
      laufd = zw_laufd
      laufi = zw_laufi
    TABLES
      laufk = t_laufk.

*----------------------------------------------------------------------*
* List Title                                                           *
*----------------------------------------------------------------------*
*>>>>>commented Retrofit
*TOP-OF-PAGE.
*  FORMAT COLOR COL_BACKGROUND INTENSIFIED ON.
*  CASE I_PTYPE.
*    WHEN 'U'.
*      IF     P_XBLNR = 'X'.
*        WRITE TEXT-004.
**       TEXT-004: 'Reference document numbers with check numbers'
*      ELSEIF P_ZUONR = 'X'.
*        WRITE TEXT-005.
**       TEXT-005: 'Allocation numbers with check numbers'
*      ELSEIF P_XREF3 = 'X'.
*        WRITE TEXT-006.
**       TEXT-006: 'Reference keys for line items with check numbers'
***    ELSEIF Further_Parameter = 'X'.
***      WRITE Text_element_with_list_header_text.
*      ENDIF.
*    WHEN 'Q'.
*      WRITE TEXT-007.
**     TEXT-007: 'By other users closed documents'
*    WHEN 'E'.
*      WRITE TEXT-008.
**     TEXT-008: 'Error with the document update'
*    WHEN 'M'.
*      WRITE text-009.
**     TEXT-009: 'Maintain the check reference manually'
*  ENDCASE.
*  WRITE 84 SY-PAGNO.
*  FORMAT COLOR COL_HEADING INTENSIFIED ON.
*  WRITE: / SY-ULINE(88),
*         /01 SY-VLINE NO-GAP, IS_ZBUKR,   "Company code
*          12 SY-VLINE NO-GAP, IS_VBLNR,   "Document number
*          23 SY-VLINE NO-GAP, IS_GJAHR,   "Fiscal Year
*          34 SY-VLINE NO-GAP, IS_HBKID,   "Bank key
*          45 SY-VLINE NO-GAP, IS_HKTID,   "Bank account key
*          56 SY-VLINE NO-GAP, IS_RZAWE,   "payment method
*          67 SY-VLINE NO-GAP, IM_CHECT,   "Check number
*          88 SY-VLINE NO-GAP,
*         /   SY-ULINE(88).
*
*END-OF-PAGE.
*  IF I_PAGEEND = 'X'.
*    WRITE: / SY-ULINE(88).
*  ENDIF.
*<<<<<<commented Retrofit
*----------------------------------------------------------------------*
* Main Program                                                        *
*----------------------------------------------------------------------*
START-OF-SELECTION.
************************************************************************
***    Begin of ALV Conversion                   Retrofit
************************************************************************
  PERFORM create_block_list_alv USING gv_repid.
************************************************************************
***    End of ALV Conversion                     Retrofit
************************************************************************
* Conversion of the payment method Parameters into Select-Options
  IF NOT zw_laufd IS INITIAL.
    CLEAR r_laufd.
    r_laufd-low    = zw_laufd.
    r_laufd-option = 'EQ'.
    r_laufd-sign   = 'I'.
    APPEND r_laufd.
  ENDIF.
  IF NOT zw_laufi IS INITIAL.
    CLEAR r_laufi.
    r_laufi-low    = zw_laufi.
    r_laufi-option = 'EQ'.
    r_laufi-sign   = 'I'.
    APPEND r_laufi.
  ENDIF.

* Reading of the payment transfer mediums, whose numbers are to filled
* in the selected field of document
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM payr INTO TABLE t_payr
*         WHERE
*           irefe =  p_refe
*           AND voidr =  0
*           AND laufd IN r_laufd
*           AND laufi IN r_laufi
*           AND zbukr IN s_zbuk
*           AND hbkid IN s_bank
*           AND hktid IN s_acco
*           AND rzawe IN s_zweg
*           AND chect IN s_chec
*           AND zaldt IN s_zald
*           AND pridt IN s_cpud
*           AND prius IN s_user
*           AND vblnr IN s_vbln
*           AND vblnr <> space.
*
* NEW CODE
  SELECT *
 FROM payr INTO TABLE t_payr
         WHERE
           irefe =  p_refe
           AND voidr =  0
           AND laufd IN r_laufd
           AND laufi IN r_laufi
           AND zbukr IN s_zbuk
           AND hbkid IN s_bank
           AND hktid IN s_acco
           AND rzawe IN s_zweg
           AND chect IN s_chec
           AND zaldt IN s_zald
           AND pridt IN s_cpud
           AND prius IN s_user
           AND vblnr IN s_vbln
           AND vblnr <> space ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
* Aqui hacer select para traer los comprobantes que no tengan asignado los cheques


  LOOP AT t_payr.
    CLEAR: t_bkpf, t_bseg.
    CLEAR: xbseg, ybseg, *bkpf, bkpf.
    REFRESH: xbseg, ybseg.
    REFRESH  t_bkpf.
*   if a payment document is referenced more than once,
*   it is not possible to determine the check number
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM payr UP TO 2 ROWS
*       WHERE zbukr = t_payr-zbukr
*         AND vblnr = t_payr-vblnr
*         AND gjahr = t_payr-gjahr
*        AND voidr = 0.
*
* NEW CODE
    SELECT *
 FROM payr UP TO 2 ROWS
       WHERE zbukr = t_payr-zbukr
         AND vblnr = t_payr-vblnr
         AND gjahr = t_payr-gjahr
        AND voidr = 0 ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    ENDSELECT.
    IF sy-dbcnt > 1.
      MOVE-CORRESPONDING t_payr TO t_multi.
      APPEND t_multi.
      CONTINUE.
    ENDIF.
*   Reading of the document header
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM bkpf INTO t_bkpf
*           WHERE bukrs = t_payr-zbukr
*             AND belnr = t_payr-vblnr
*             AND gjahr = t_payr-gjahr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM bkpf INTO t_bkpf
           WHERE bukrs = t_payr-zbukr
             AND belnr = t_payr-vblnr
             AND gjahr = t_payr-gjahr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    CHECK sy-subrc = 0.
     *bkpf = t_bkpf.
*   Fill a field of the BKPF table with the check number
    IF p_xblnr = 'X'.
*     Fill the reference document number with the check number
*      T_BKPF-XBLNR = T_PAYR-CHECT.

      CLEAR wa_rut.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE stcd1 INTO wa_rut
*        FROM lfa1
*        WHERE lifnr = t_payr-lifnr.
*
* NEW CODE
      SELECT stcd1
      UP TO 1 ROWS  INTO wa_rut
        FROM lfa1
        WHERE lifnr = t_payr-lifnr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      CHECK sy-subrc EQ 0.

      CONDENSE wa_rut.
      t_bkpf-xblnr = wa_rut.

      i_refkz = '2'.
**  ELSEIF Further_Parameter_Of_A_BKPF_Field = 'X'.
**    t_bkpf-Document_Field_Name = t_payr-chect.
**    i_refkz = Defined_Reference_Item.
    ELSE.
*   Fill a field of the BSEG table with the check number
*     Reading of the document items
      SELECT * FROM bseg INTO TABLE t_bseg
             WHERE bukrs = t_payr-zbukr
               AND belnr = t_payr-vblnr

*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK916982*
*               AND gjahr = t_payr-gjahr.
               AND gjahr = t_payr-gjahr ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK916982*
*               AND HKONT = T_PAYR-UBHKT.
      CHECK sy-subrc = 0.
      LOOP AT t_bseg.
        CHECK t_bseg-zzmot_emis = ' ' OR t_bseg-xref1 = ' ' OR t_bseg-zuonr = ' '.
        CLEAR wa_bsak.
        IF sy-tabix = 1.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE * FROM bsak INTO wa_bsak
*             WHERE lifnr = t_payr-lifnr
*              AND bukrs = t_bseg-bukrs
*              AND augbl = t_bseg-belnr
*              AND augdt = t_bseg-augdt
*              AND belnr NE t_bseg-belnr
*              AND xzahl NE 'X'.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS  FROM bsak INTO wa_bsak
             WHERE lifnr = t_payr-lifnr
              AND bukrs = t_bseg-bukrs
              AND augbl = t_bseg-belnr
              AND augdt = t_bseg-augdt
              AND belnr NE t_bseg-belnr
              AND xzahl NE 'X' ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

          subrc_w = sy-subrc.

        ENDIF.


        CHECK subrc_w EQ 0.

        CLEAR wa_rut.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE stcd1 INTO wa_rut
*          FROM lfa1
*          WHERE lifnr = t_payr-lifnr.
*
* NEW CODE
        SELECT stcd1
        UP TO 1 ROWS  INTO wa_rut
          FROM lfa1
          WHERE lifnr = t_payr-lifnr ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        CHECK sy-subrc EQ 0.

        CONDENSE wa_rut.

        MOVE-CORRESPONDING t_bseg TO w_ybseg.
        APPEND w_ybseg TO ybseg.
        IF     p_zuonr = 'X'.
*         Fill the allocation number with the check number
*          T_BSEG-ZUONR = T_PAYR-CHECT.

*          Aqui hacer asignacion de los campos Z y el nombre acreedor para actualizar las tablas.
          t_bseg-zzmot_emis = wa_bsak-zzmot_emis.
          CONCATENATE t_payr-znme1 t_payr-znme2 INTO t_bseg-sgtxt.
          t_bseg-xref1 = wa_rut+0(12).
          t_bseg-xref3 = wa_bsak-zuonr+0(18).
          i_refkz = '2'.

          IF t_bseg-hkont = t_payr-ubhkt.
            t_bseg-zuonr = t_payr-chect.
          ENDIF.

        ELSEIF p_xref3 = 'X'.
*         Fill the reference key for line item with the check number
          t_bseg-xref3 = t_payr-chect.
          i_refkz = '3'.
**      ELSEIF Further_Parameter_Of_A_BSEG_Field = 'X'.
**        t_bseg-Document_Field_Name = t_payr-chect.
**        i_refkz = Defined_Reference_Item.
        ENDIF.
        MODIFY t_bseg.
        MOVE-CORRESPONDING t_bseg TO w_xbseg.
        APPEND w_xbseg TO xbseg.
      ENDLOOP.
      upd_bseg = 'U'.
    ENDIF.
    bkpf = t_bkpf.
    APPEND t_bkpf.
    upd_bkpf = 'U'.
*   Enqueue document for update
    CALL FUNCTION 'ENQUEUE_EFBKPF'
      EXPORTING
        mode_bkpf      = 'E'
        mandt          = sy-mandt
        bukrs          = t_bkpf-bukrs
        belnr          = t_bkpf-belnr
        gjahr          = t_bkpf-gjahr
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc = 0.
*      Enqueque payment transfer medium for update
      CALL FUNCTION 'ENQUEUE_EFPAYR'
        EXPORTING
          mode_payr      = 'E'
          mandt          = sy-mandt
          zbukr          = t_payr-zbukr
          hbkid          = t_payr-hbkid
          hktid          = t_payr-hktid
          rzawe          = t_payr-rzawe
          chect          = t_payr-chect
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.
      IF sy-subrc = 0.
*        Document update
        CALL FUNCTION 'CHANGE_DOCUMENT'
          TABLES
            t_bkdf = t_bkdf
            t_bkpf = t_bkpf
            t_bsec = t_bsec
            t_bsed = t_bsed
            t_bseg = t_bseg
            t_bset = t_bset
          EXCEPTIONS
            OTHERS = 4.
        IF sy-subrc = 0.
*          Update of payment transfer medium
          UPDATE payr SET irefe = i_refkz
                 WHERE zbukr = t_payr-zbukr
                   AND hbkid = t_payr-hbkid
                   AND hktid = t_payr-hktid
                   AND rzawe = t_payr-rzawe
                   AND chect = t_payr-chect.
          IF sy-subrc = 0.
*            Fill the update protocol item table
            MOVE-CORRESPONDING t_payr TO t_update.
            APPEND t_update.
*            Create a change document for the document modifications
            objectid = bkpf(21).
            tcode    = 'FCHU'.
            utime    = sy-uzeit.
            udate    = sy-datum.
            username = sy-uname.
            SET UPDATE TASK LOCAL.
            PERFORM cd_call_beleg.
            COMMIT WORK.
          ELSE.
            ROLLBACK WORK.
            MOVE-CORRESPONDING t_payr TO t_error.
            APPEND t_error.
          ENDIF.
        ELSE.
          ROLLBACK WORK.
          MOVE-CORRESPONDING t_payr TO t_error.
          APPEND t_error.
        ENDIF.
*        Dequeque payment transfer medium after update
        CALL FUNCTION 'DEQUEUE_EFPAYR'
          EXPORTING
            mode_payr = 'E'
            mandt     = sy-mandt
            zbukr     = t_payr-zbukr
            hbkid     = t_payr-hbkid
            hktid     = t_payr-hktid
            rzawe     = t_payr-rzawe
            chect     = t_payr-chect.
      ELSE.
        MOVE-CORRESPONDING t_payr TO t_queue.
        APPEND t_queue.
      ENDIF.
*     Dequeue document after update
      CALL FUNCTION 'DEQUEUE_EFBKPF'
        EXPORTING
          mode_bkpf = 'E'
          mandt     = sy-mandt
          bukrs     = t_bkpf-bukrs
          belnr     = t_bkpf-belnr
          gjahr     = t_bkpf-gjahr.
    ELSE.
      MOVE-CORRESPONDING t_payr TO t_queue.
      APPEND t_queue.
    ENDIF.
  ENDLOOP.
*>>>>>>>>>>>>>commented Retrofit
** Protocol output of updated documents
*  LOOP AT T_UPDATE.
*    AT FIRST.
*      CLEAR I_NOPROT.
*      I_PTYPE   = 'U'.
*      NEW-PAGE.
*    ENDAT.
*    PERFORM PROTOCOL_OUTPUT USING T_UPDATE.
*    AT LAST.
*      WRITE: / SY-ULINE(88).
*      CLEAR I_PAGEEND.
*    ENDAT.
*  ENDLOOP.
** Protocol output of closed documents
*  LOOP AT T_QUEUE.
*    AT FIRST.
*      I_PAGEEND = 'X'.
*      I_PTYPE   = 'Q'.
*      NEW-PAGE.
*    ENDAT.
*    PERFORM PROTOCOL_OUTPUT USING T_QUEUE.
*    AT LAST.
*      WRITE: / sy-uline(88).
*      CLEAR i_pageend.
*    ENDAT.
*  ENDLOOP.
** Protocol output of multiple checks for
** one payment document.
*  LOOP AT t_multi.
*    AT FIRST.
*      i_pageend = 'X'.
*      i_ptype   = 'M'.
*      NEW-PAGE.
*    ENDAT.
*    PERFORM protocol_output USING t_multi.
*    AT LAST.
*      WRITE: / SY-ULINE(88).
*      CLEAR I_PAGEEND.
*    ENDAT.
*  ENDLOOP.
** Protocol output of update errors
*  LOOP AT T_ERROR.
*    AT FIRST.
*      I_PAGEEND = 'X'.
*      I_PTYPE   = 'E'.
*      NEW-PAGE.
*    ENDAT.
*    PERFORM PROTOCOL_OUTPUT USING T_ERROR.
*    AT LAST.
*      WRITE: / SY-ULINE(88).
*      CLEAR I_PAGEEND.
*    ENDAT.
*  ENDLOOP.
** Check whether a document field was filled with a check number
*  IF I_NOPROT = 'X'.
*    MESSAGE I321.
*  ENDIF.
*<<<<<<<<<<<<<commented Retrofit
************************************************************************
***    Begin of ALV Conversion                   Retrofit
************************************************************************
  PERFORM output_documents_alv.
***Display all available lists
  IF gv_count GT 0.
    PERFORM display_block_list_alv.
  ENDIF.
************************************************************************
***    End of ALV Conversion                     Retrofit
************************************************************************

* 'form cd_call_beleg'
  INCLUDE ff05lcdc.

*----------------------------------------------------------------------*
* Write A Protocol Item                                                *
*----------------------------------------------------------------------*
*>>>>>>>>>>>>>commented Retrofit
*FORM PROTOCOL_OUTPUT USING PLINE TYPE PROTOCOL_LINE.
*  IF I_INTENSIFIED = SPACE.
*    FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
*    I_INTENSIFIED = 'X'.
*  ELSE.
*    FORMAT COLOR COL_NORMAL INTENSIFIED ON.
*    I_INTENSIFIED = ' '.
*  ENDIF.
*  WRITE: /01 SY-VLINE NO-GAP,
*             PLINE-ZBUKR NO-GAP, 12 SY-VLINE NO-GAP,
*             PLINE-VBLNR NO-GAP, 23 SY-VLINE NO-GAP,
*             PLINE-GJAHR NO-GAP, 34 SY-VLINE NO-GAP,
*             PLINE-HBKID NO-GAP, 45 SY-VLINE NO-GAP,
*             PLINE-HKTID NO-GAP, 56 SY-VLINE NO-GAP,
*             PLINE-RZAWE NO-GAP, 67 SY-VLINE NO-GAP,
*             PLINE-CHECT NO-GAP, 88 SY-VLINE NO-GAP.
*ENDFORM.
*<<<<<<<<<<<commented Retrofit

*----------------------------------------------------------------------*
* Get The Data Dictionary Label Of A Table Field                       *
*----------------------------------------------------------------------*
FORM get_label USING    table_name TYPE ddobjname
                        label_type TYPE clike
                        field_name TYPE dfies-fieldname
               CHANGING label      TYPE clike.
  DATA: lt_dfies LIKE dfies OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = table_name
      fieldname      = field_name
      langu          = sy-langu
    TABLES
      dfies_tab      = lt_dfies
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.
  IF sy-subrc = 0.
    READ TABLE lt_dfies INDEX 1.
    CASE label_type.
      WHEN 'S'. label = lt_dfies-scrtext_s.
      WHEN 'M'. label = lt_dfies-scrtext_m.
      WHEN 'L'. label = lt_dfies-scrtext_l.
    ENDCASE.
  ENDIF.
ENDFORM.                    "GET_LABEL
************************************************************************
***    Begin of ALV Conversion                   Retrofit
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  CREATE_BLOCK_LIST_ALV
*&---------------------------------------------------------------------*
*       Create block list for ALV
*----------------------------------------------------------------------*
*      -->IV_REPID  Report name field
*----------------------------------------------------------------------*
FORM create_block_list_alv USING iv_repid TYPE sy-repid.
***Create block list
  CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_INIT'
    EXPORTING
      i_callback_program = iv_repid.
*
ENDFORM.                    " CREATE_BLOCK_LIST_ALV
*&---------------------------------------------------------------------*
*&      Form  OUTPUT_DOCUMENTS_ALV
*&---------------------------------------------------------------------*
*    Build and display the ALV data
*----------------------------------------------------------------------*
FORM output_documents_alv .
*
  DATA: wa_payr TYPE protocol_line.
***Build field catalog and layout for ALV
  PERFORM build_fieldcat_alv CHANGING gt_fieldcat. "Build Field Catalog
  PERFORM set_layout_alv     CHANGING gs_layo.     "to set layout
* Protocol output of updated documents
  IF NOT t_update IS INITIAL.
    LOOP AT t_update INTO wa_payr.
      AT FIRST.
        CLEAR i_noprot.
        i_ptype   = gc_ptu.
      ENDAT.
      PERFORM protocol_output_alv USING wa_payr
                                  CHANGING gt_update.
      CLEAR wa_payr.
    ENDLOOP.
    gv_count = gv_count + 1.
    PERFORM display_alv TABLES gt_update.
  ENDIF.
* Protocol output of closed documents
  IF NOT t_queue IS INITIAL.
    LOOP AT t_queue INTO wa_payr.
      AT FIRST.
        i_ptype   = gc_ptq.
      ENDAT.
      PERFORM protocol_output_alv USING wa_payr
                                  CHANGING gt_queue.
      CLEAR wa_payr.
    ENDLOOP.
    gv_count = gv_count + 1.
    PERFORM display_alv TABLES gt_queue.
  ENDIF.
* Protocol output of multiple checks for
* one payment document.
  IF NOT t_multi IS INITIAL.
    LOOP AT t_multi INTO wa_payr.
      AT FIRST.
        i_ptype   = gc_ptm.
      ENDAT.
      PERFORM protocol_output_alv USING wa_payr
                                  CHANGING gt_multi.
      CLEAR wa_payr.
    ENDLOOP.
    gv_count = gv_count + 1.
    PERFORM display_alv TABLES gt_multi.
  ENDIF.
* Protocol output of update errors
  IF NOT t_error IS INITIAL.
    LOOP AT t_error INTO wa_payr.
      AT FIRST.
        i_ptype   = gc_pte.
      ENDAT.
      PERFORM protocol_output_alv USING wa_payr
                                  CHANGING gt_error.
      CLEAR wa_payr.
    ENDLOOP.
    gv_count = gv_count + 1.
    PERFORM display_alv TABLES gt_error.
  ENDIF.
* Check whether a document field was filled with a check number
  IF i_noprot = gc_chk.
    MESSAGE i321.
  ENDIF.
*
ENDFORM.                    " OUTPUT_DOCUMENTS_ALV
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT_ALV
*&---------------------------------------------------------------------*
*       Build field catalog
*----------------------------------------------------------------------*
*      <--XT_FIELDCAT  Storet the field catolog details
*----------------------------------------------------------------------*
FORM build_fieldcat_alv  CHANGING xt_fieldcat TYPE slis_t_fieldcat_alv.
*
  DATA: ls_fcat TYPE slis_fieldcat_alv.

  CLEAR: xt_fieldcat.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = gc_str
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

  LOOP AT xt_fieldcat INTO ls_fcat.
    CASE ls_fcat-fieldname.
      WHEN gc_gjahr OR gc_hbkid OR gc_rzawe.
        ls_fcat-ddictxt = gc_s.
    ENDCASE.
    ls_fcat-tabname = gc_outtab.
    MODIFY xt_fieldcat FROM ls_fcat.
    CLEAR ls_fcat.
  ENDLOOP.
*
ENDFORM.                    " BUILD_FIELDCAT_ALV
*&---------------------------------------------------------------------*
*&      Form  SET_LAYOUT_ALV
*&---------------------------------------------------------------------*
*       Build a layout
*----------------------------------------------------------------------*
*      <--XS_LAYO  Store the layout details
*----------------------------------------------------------------------*
FORM set_layout_alv  CHANGING xs_layo TYPE slis_layout_alv.
*
  xs_layo-no_hotspot        = gc_chk.
  xs_layo-colwidth_optimize = space.
  xs_layo-info_fieldname    = gc_color.
*
ENDFORM.                    " SET_LAYOUT_ALV
*&---------------------------------------------------------------------*
*&      Form  PROTOCOL_OUTPUT_ALV
*&---------------------------------------------------------------------*
*       Moving the data to ALV table
*----------------------------------------------------------------------*
*      -->IW_PLINE  work area
*      <--XT_OUTTAB store the ALV data
*----------------------------------------------------------------------*
FORM protocol_output_alv  USING iw_pline TYPE protocol_line
                          CHANGING xt_outtab LIKE gt_update.
*
  DATA: ls_outtab TYPE foap_s_rfchku00_list.
  CLEAR ls_outtab.
  MOVE iw_pline TO ls_outtab.
  APPEND ls_outtab TO xt_outtab.
*
ENDFORM.                    " PROTOCOL_OUTPUT_ALV
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       Display the ALV block list
*----------------------------------------------------------------------*
*      -->IT_OUTTAB  Passing table name
*----------------------------------------------------------------------*
FORM display_alv TABLES it_outtab LIKE gt_update.
*
  DATA: lt_evts TYPE slis_t_event.        "events table
***Build the events
  PERFORM set_events_alv CHANGING lt_evts.  "to set events
***Display the ALV Block list
  CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_APPEND'
    EXPORTING
      is_layout                  = gs_layo
      it_fieldcat                = gt_fieldcat
      i_tabname                  = gc_outtab
      it_events                  = lt_evts
    TABLES
      t_outtab                   = it_outtab
    EXCEPTIONS
      program_error              = 1
      maximum_of_appends_reached = 2
      OTHERS                     = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*
ENDFORM.                    " DISPLAY_ALV
*&---------------------------------------------------------------------*
*&      Form  SET_EVENTS_ALV
*&---------------------------------------------------------------------*
*       Build the events
*----------------------------------------------------------------------*
*      <--XT_EVTS  To store the events details
*----------------------------------------------------------------------*
FORM set_events_alv  CHANGING xt_evts TYPE slis_t_event.
*
  DATA: ls_events TYPE slis_alv_event.
*** To get the top of list based on the ptype
  CASE i_ptype.
    WHEN gc_ptu.
      ls_events-name = slis_ev_top_of_list.
      ls_events-form = gc_tol_form1.
      APPEND ls_events TO xt_evts.
    WHEN gc_ptq.
      ls_events-name = slis_ev_top_of_list.
      ls_events-form = gc_tol_form2.
      APPEND ls_events TO xt_evts.
    WHEN gc_pte.
      ls_events-name = slis_ev_top_of_list.
      ls_events-form = gc_tol_form3.
      APPEND ls_events TO xt_evts.
    WHEN gc_ptm.
      ls_events-name = slis_ev_top_of_list.
      ls_events-form = gc_tol_form4.
      APPEND ls_events TO xt_evts.
  ENDCASE.
*
ENDFORM.                    " SET_EVENTS_ALV
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_LIST_ONE
*&---------------------------------------------------------------------*
* This subroutine is dynamically called and handles event TOP-OF-LIST
*----------------------------------------------------------------------*
FORM top_of_list_one .                                      "#EC CALLED

  DATA: lt_line TYPE slis_t_listheader,  "list header
        ls_line TYPE slis_listheader.

  IF p_xblnr = gc_chk.
    ls_line-info = text-004.
  ELSEIF p_zuonr = gc_chk.
    ls_line-info = text-005.
  ELSEIF p_xref3 = gc_chk.
    ls_line-info = text-006.
  ENDIF.
  ls_line-typ = gc_ltya.
  APPEND ls_line TO lt_line.
  CLEAR ls_line.
***To display the list header details for ALV list
  PERFORM display_list_header_alv USING lt_line.
ENDFORM.                    " top_of_list_ONE
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_LIST_TWO
*&---------------------------------------------------------------------*
* This subroutine is dynamically called and handles event TOP-OF-LIST
*----------------------------------------------------------------------*
FORM top_of_list_two.                                       "#EC CALLED

  DATA: lt_line TYPE slis_t_listheader,  "list header
        ls_line TYPE slis_listheader.

  ls_line-typ = gc_ltya.
  ls_line-info = text-007.
  APPEND ls_line TO lt_line.
  CLEAR ls_line.
***To display the list header details for ALV list
  PERFORM display_list_header_alv USING lt_line.

ENDFORM.                    " top_of_list_TWO
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_LIST_THREE
*&---------------------------------------------------------------------*
* This subroutine is dynamically called and handles event TOP-OF-LIST
*----------------------------------------------------------------------*
FORM top_of_list_three.                                     "#EC CALLED

  DATA: lt_line TYPE slis_t_listheader,  "list header
        ls_line TYPE slis_listheader.

  ls_line-typ = gc_ltya.
  ls_line-info = text-008.
  APPEND ls_line TO lt_line.
  CLEAR ls_line.
***To display the list header details for ALV list
  PERFORM display_list_header_alv USING lt_line.
ENDFORM.                    " top_of_list_THREE
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_LIST_FOUR
*&---------------------------------------------------------------------*
* This subroutine is dynamically called and handles event TOP-OF-LIST
*----------------------------------------------------------------------*
FORM top_of_list_four.                                      "#EC CALLED

  DATA: lt_line TYPE slis_t_listheader,  "list header
        ls_line TYPE slis_listheader.

  ls_line-typ = gc_ltya.
  ls_line-info = text-009.
  APPEND ls_line TO lt_line.
  CLEAR ls_line.
***To display the list header details for ALV list
  PERFORM display_list_header_alv USING lt_line.
ENDFORM.                    " top_of_list_FOUR
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_LIST_HEADER_ALV
*&---------------------------------------------------------------------*
* This subroutine prints the header details of list.
*----------------------------------------------------------------------*
*  -->  IT_LINE, is of Type slis_t_listheader, to store header details
*----------------------------------------------------------------------*
FORM display_list_header_alv USING
                        it_line TYPE slis_t_listheader.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = it_line.
  WRITE AT 65 sy-pagno.
ENDFORM.                    " DISPLAY_LIST_HEADER_ALV
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_BLOCK_LIST_ALV
*&---------------------------------------------------------------------*
*       Display the ALV block list
*----------------------------------------------------------------------*
FORM display_block_list_alv .

  CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_DISPLAY'
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " DISPLAY_BLOCK_LIST_ALV
************************************************************************
***    End of ALV Conversion                     Retrofit
************************************************************************
