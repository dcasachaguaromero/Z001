*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZF_CREATE_DOC_FROM_INDEX_2_TX
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZF_CREATE_DOC_FROM_INDEX_2_TX LINE-SIZE 255 MESSAGE-ID fb   .
* RFC: in the remote system you have to create a function (SE37)
* flagged RFC capable in its attributes. Interface:
*"----------------------------------------------------------------------
* FUNCTION: Z_GET_REMOTE_DOCUMENT3
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(CLIENT) LIKE  T001-MANDT
*"     VALUE(DOCNO) LIKE  BKPF-BELNR
*"     VALUE(COCODE) LIKE  BKPF-BUKRS
*"     VALUE(F_YEAR) LIKE  BKPF-GJAHR
*"  TABLES
*"      IRFBLG STRUCTURE  RFBLG OPTIONAL
*"      IBKPF STRUCTURE   BKPF OPTIONAL
*"  EXCEPTIONS
*"      NOTHING_AINT_THERE
*"----------------------------------------------------------------------


TABLES: bkpf, bseg, bsis, bsas, bsid, bsad, bsik, bsak, t030,
        t001, skb1, ska1, knb1, lfb1, rfblg, tbsl, dd03l, t003,
        t001a, t005, t000, t880, sscrfields, vbhdr, vbmod, rfdt.


SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME TITLE text_001.

SELECT-OPTIONS: pbukrs FOR bkpf-bukrs MEMORY ID buk.
SELECT-OPTIONS: pbelnr FOR bkpf-belnr MEMORY ID bln.
SELECT-OPTIONS: pgjahr FOR bkpf-gjahr MEMORY ID gjr.
SELECT-OPTIONS: pmonat FOR bkpf-monat.
SELECT-OPTIONS: pcpudt FOR bkpf-cpudt.
SELECT-OPTIONS: pbudat FOR bkpf-budat.
SELECT-OPTIONS: ptcode FOR bkpf-tcode.
SELECT-OPTIONS: pblart FOR bkpf-blart.


SELECTION-SCREEN END OF BLOCK 001.

SELECTION-SCREEN BEGIN OF BLOCK 009 WITH FRAME TITLE text_030.
PARAMETERS: rbkpf RADIOBUTTON GROUP 001.
PARAMETERS: rbseg RADIOBUTTON GROUP 001 DEFAULT 'X'.
PARAMETERS: cbset AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK 009.

SELECTION-SCREEN BEGIN OF BLOCK 010 WITH FRAME TITLE text_031.
PARAMETERS: xnormal RADIOBUTTON GROUP 002 DEFAULT 'X'.
PARAMETERS: xrfc RADIOBUTTON GROUP 002.
PARAMETERS: xvbtab  RADIOBUTTON GROUP 002.
SELECTION-SCREEN END OF BLOCK 010.






SELECTION-SCREEN BEGIN OF BLOCK 004 WITH FRAME TITLE text_007.
PARAMETERS: tbukrs LIKE bkpf-bukrs,
        tbelnr LIKE bkpf-belnr,
        tgjahr LIKE bkpf-gjahr.
SELECTION-SCREEN END OF BLOCK 004.

SELECTION-SCREEN BEGIN OF BLOCK 005 WITH FRAME TITLE text_008.
PARAMETERS: ybvorg LIKE bkpf-bvorg,
            yxblnr LIKE bkpf-xblnr,
            yawkey LIKE bkpf-awkey.
SELECTION-SCREEN END OF BLOCK 005.
SELECTION-SCREEN BEGIN OF BLOCK 002 WITH FRAME TITLE text_002.
PARAMETERS: xbsis AS CHECKBOX DEFAULT 'X'.
PARAMETERS: xbsas  AS CHECKBOX DEFAULT 'X'.
SELECT-OPTIONS phkont FOR bseg-hkont MEMORY ID sak.
PARAMETERS: xbsid AS CHECKBOX DEFAULT 'X'.
PARAMETERS: xbsad  AS CHECKBOX DEFAULT 'X'.
SELECT-OPTIONS pkunnr FOR bseg-kunnr MEMORY ID kun.
PARAMETERS: xbsik AS CHECKBOX DEFAULT 'X'.
PARAMETERS: xbsak  AS CHECKBOX DEFAULT 'X'.
SELECT-OPTIONS plifnr FOR bseg-lifnr MEMORY ID lif.
SELECTION-SCREEN END OF BLOCK 002.

SELECTION-SCREEN BEGIN OF BLOCK 003 WITH FRAME TITLE text_003.
PARAMETERS xrepair AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK 003.

SELECTION-SCREEN BEGIN OF BLOCK 006 WITH FRAME TITLE text_009.
PARAMETERS src_sys LIKE rfcdes-rfcdest MODIF ID inc.
PARAMETERS src_cli LIKE t001-mandt MODIF ID inc.
SELECTION-SCREEN END  OF BLOCK 006.


SELECTION-SCREEN BEGIN OF BLOCK 007 WITH FRAME TITLE text_010.
PARAMETERS: pvbkey LIKE vbhdr-vbkey.
SELECTION-SCREEN END  OF BLOCK 007.


* ---------------------------------------------------------------
*                          Types:
* ---------------------------------------------------------------

* for versions >= 4.5: use this line.
DATA: huge_amount LIKE rgvalue-wertv10.
* else use the following definition:
* data: huge_amount like glt0-hsl01.
* end of version dependent section


TYPES: BEGIN OF tbkpf,
       bukrs LIKE bkpf-bukrs,
       belnr LIKE bkpf-belnr,
       gjahr LIKE bkpf-gjahr,
       errcd TYPE i,
       repcd TYPE i,
       END OF tbkpf.
TYPES: BEGIN OF texception,
       bukrs LIKE bkpf-bukrs,
       belnr LIKE bkpf-belnr,
       gjahr LIKE bkpf-gjahr,
       buzei LIKE bseg-buzei,
       level TYPE c,
       key TYPE i,
*       mess(25) type c,
       END OF texception,
       BEGIN OF t_cmp,
                 accnt LIKE bseg-hkont,
                 type  LIKE bseg-koart, " Special G/L indicator
                 gsber LIKE bseg-gsber,
                 pswsl LIKE bseg-pswsl,
                 monat LIKE bkpf-monat,
                 drcrk LIKE glt0-drcrk, "S=Debit,H=Credit,U=Umsatz(NB).
                 tw_cal LIKE huge_amount,
                 tw_ist LIKE huge_amount,
                 hw1_cal LIKE huge_amount,
                 hw1_ist LIKE huge_amount,
                 hw2_cal LIKE huge_amount,
                 hw2_ist LIKE huge_amount,
                 hw3_cal LIKE huge_amount,
                 hw3_ist LIKE huge_amount,
        END OF t_cmp.

* ***************************************
* do not use:
* just for structure... for table params:
* ***************************************
DATA: nbkpf TYPE tbkpf OCCURS 0 WITH HEADER LINE.

* ---------------------------------------------------------------
*                          constants
* ---------------------------------------------------------------
CONSTANTS:
        c_progress_small TYPE i VALUE 100,
        c_progress_large TYPE i VALUE 1000.




* ---------------------------------------------------------------
*                         global data
* ---------------------------------------------------------------
DATA: exceptions TYPE texception OCCURS 10 WITH HEADER LINE,
      template_bkpf LIKE bkpf,
      template_bseg LIKE bseg OCCURS 0 WITH HEADER LINE,
      has_template TYPE c,
      excute_hdr TYPE i,
      excute_rep TYPE i,
      hbseg LIKE bseg,
      hbkpf LIKE bkpf,
      ebseg LIKE bseg,
      global_bkpf LIKE bkpf OCCURS 0 WITH HEADER LINE,
      global_bseg LIKE bseg OCCURS 0 WITH HEADER LINE,
      global_rfblg LIKE rfblg OCCURS 0 WITH HEADER LINE,
      global_nbkpf TYPE tbkpf OCCURS 0 WITH HEADER LINE,
      global_t001 LIKE t001 OCCURS 0 WITH HEADER LINE,
      global_error_count TYPE i,
      itbsl LIKE tbsl OCCURS 0 WITH HEADER LINE.
*      x_remote type c.


DATA: glvals TYPE t_cmp OCCURS 1000 WITH HEADER LINE,
      glvald TYPE t_cmp OCCURS 1000 WITH HEADER LINE,
      glvalk TYPE t_cmp OCCURS 1000 WITH HEADER LINE,
      glvald_shb TYPE t_cmp OCCURS 1000 WITH HEADER LINE,
      glvalk_shb TYPE t_cmp OCCURS 1000 WITH HEADER LINE.


FIELD-SYMBOLS <input> TYPE ANY.
DATA: ydd03l_bseg LIKE dd03l OCCURS 290 WITH HEADER LINE.
DATA: ydd03l_bkpf LIKE dd03l OCCURS 290 WITH HEADER LINE.
DATA: ydd03l_bsis LIKE dd03l OCCURS 290 WITH HEADER LINE.
DATA: ydd03l_bsid LIKE dd03l OCCURS 290 WITH HEADER LINE.
DATA: ydd03l_bsik LIKE dd03l OCCURS 290 WITH HEADER LINE.
DATA: exclude_edit_bseg LIKE dd03l-fieldname OCCURS 0 WITH HEADER LINE.
DATA: exclude_edit_bkpf LIKE dd03l-fieldname OCCURS 0 WITH HEADER LINE.
DATA: text(20).
DATA: h_index LIKE sy-index.







* ---------------------------------------------------------------
*                          Events
* ---------------------------------------------------------------
INITIALIZATION.
  text_001 = 'Document selection'.
  text_002 = 'Index Selection'.
  text_003 = 'Search/Repair options'.
  text_007 = 'Template document'.
  text_008 = 'Replace BKPF-fields with'.
  text_009 = 'RFC-Parameters'.
  text_010 = 'Update Record'.
  text_030 = 'Repair object'.
  text_031 = 'Repair Method'.
* ---------------------------------------------------------------
*                    AT SELECTION-SCREEN
* ---------------------------------------------------------------
AT SELECTION-SCREEN.

  PERFORM test_screen.

* ---------------------------------------------------------------
*                    Start of selection
* ---------------------------------------------------------------

START-OF-SELECTION.
  PERFORM main.


* ---------------------------------------------------------------
*                    AT LINE-SELECTION
* ---------------------------------------------------------------
AT LINE-SELECTION.
*  clear h_clear.
*  clear h_beln2.
  CLEAR excute_hdr.
  CLEAR excute_rep.

  CASE sy-lsind.
    WHEN 1.
*   *********************************
*   Process clicks on the main screen
*   *********************************
      CLEAR hbseg.
      CLEAR hbkpf.
      CLEAR h_index.
      READ LINE sy-lilli INDEX sy-listi.
      PERFORM line_selection_1.
    WHEN 2.
*   *********************************
*   Process clicks on the next screen
*   *********************************
      CLEAR hbseg.
      CLEAR hbkpf.
      CLEAR h_index.
      READ LINE sy-lilli INDEX sy-listi.
      PERFORM line_selection_2.
    WHEN 3.
      READ LINE sy-lilli INDEX sy-listi.
      PERFORM line_selection_3.
  ENDCASE.

* ---------------------------------------------------------------
*                          Formroutines:
* ---------------------------------------------------------------

FORM main.

  PERFORM fill_global_data.

*  *****************************
*  The one and only main program
*  *****************************
*  *************************
*  template select and write
*  *************************
  PERFORM select_template.
  PERFORM write_template.
*  **************************
*  Init global data
*  *************************
  CLEAR global_bkpf.
  REFRESH global_bkpf.
  CLEAR global_bseg.
  REFRESH global_bseg.
  CLEAR global_rfblg.
  REFRESH global_rfblg.
  CLEAR global_nbkpf.
  REFRESH global_nbkpf.
  CLEAR global_t001.
  REFRESH global_t001.

  CLEAR: glvals, glvald, glvald_shb, glvalk, glvalk_shb.
  REFRESH: glvals, glvald, glvald_shb, glvalk, glvalk_shb.


  CLEAR global_error_count.
*  ****************************
*  Select the ccs in selection
*  *****************************
  PERFORM initialize_progress.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM t001 INTO TABLE global_t001 WHERE bukrs IN pbukrs.
*
* NEW CODE
  SELECT *
 FROM t001 INTO TABLE global_t001 WHERE bukrs IN pbukrs ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  LOOP AT global_t001.
    PERFORM main_bukrs USING global_t001.
  ENDLOOP.

  PERFORM write_miss_item TABLES global_nbkpf.

  PERFORM write_exceptions.
*  Display execute button
  PERFORM write_execute_button_1.

*  additional action when running in batch
  CHECK sy-batch = 'X'.
  PERFORM collect_data.
  PERFORM do_repair.



ENDFORM.


*---------------------------------------------------------------------*
*       FORM main_bukrs                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PT001                                                         *
*---------------------------------------------------------------------*
FORM main_bukrs USING pt001 LIKE t001.
  DATA: iibkpf LIKE nbkpf OCCURS 1000 WITH HEADER LINE.
*  *****************************************
*  work on one companycode:
*  ****************************************
  PERFORM get_miss_item TABLES iibkpf
                         USING pt001.
  APPEND LINES OF iibkpf TO global_nbkpf.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM collect_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM collect_data.

  CLEAR global_bkpf.
  REFRESH global_bkpf.
  CLEAR global_bseg.
  REFRESH global_bseg.
  CLEAR global_rfblg.
  REFRESH global_rfblg.


  DATA: new_bkpf LIKE bkpf OCCURS 10 WITH HEADER LINE,
        new_bseg LIKE bseg OCCURS 10 WITH HEADER LINE.



  LOOP AT global_t001.
    IF rbkpf = 'X'.
      PERFORM create_new_headers TABLES global_nbkpf
                                        new_bkpf
                                  USING global_t001.

      PERFORM write_new_headers TABLES new_bkpf
                                       global_nbkpf
                                 USING global_t001.

*      ************************************************
*      finally copy all recreated bkkpfs to global_bkpf
*      ************************************************
      APPEND LINES OF new_bkpf TO global_bkpf.

    ELSE.

      PERFORM create_new_positions TABLES global_nbkpf
                                          new_bseg
                                    USING global_t001.

      PERFORM write_new_positions TABLES global_nbkpf
                                         new_bseg
                                   USING global_t001.



      APPEND LINES OF new_bseg TO global_bseg.


    ENDIF.

  ENDLOOP.

  PERFORM write_exceptions.
  PERFORM write_execute_button.


ENDFORM.

*---------------------------------------------------------------------*
*       FORM get_miss_item                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IIBKPF                                                        *
*  -->  PT001                                                         *
*---------------------------------------------------------------------*
FORM get_miss_item TABLES iibkpf STRUCTURE nbkpf
                         USING pt001 LIKE t001.
  IF rbkpf = 'X'.
*   *************************************************
*   this form finds missing bkpf entries very fast
*   and the missing ones in the iibkpf table
*   *************************************************

    SELECT bkpf~bukrs rfblg~bukrs rfblg~gjahr rfblg~belnr rfblg~pagelg
    INTO (bkpf-bukrs,
         rfblg-bukrs,
         rfblg-gjahr,
         rfblg-belnr,
         rfblg-pagelg)
                  FROM rfblg " client specified
                  LEFT OUTER JOIN bkpf ON
                                 rfblg~bukrs EQ bkpf~bukrs AND
                                 rfblg~belnr EQ bkpf~belnr AND
                                 rfblg~gjahr EQ bkpf~gjahr
                               WHERE
                                     rfblg~bukrs EQ pt001-bukrs
                                 AND rfblg~belnr IN pbelnr
                                 AND rfblg~gjahr IN pgjahr
                                 AND rfblg~pageno EQ 0.

      IF bkpf-bukrs IS INITIAL.
*       *********************************************
*       no bkpf present: bkpf-bukrs will be initial.
*       *********************************************
        CLEAR iibkpf.
        iibkpf-bukrs = rfblg-bukrs.
        iibkpf-belnr = rfblg-belnr.
        iibkpf-gjahr = rfblg-gjahr.
        iibkpf-errcd = 1.
        APPEND iibkpf.
        ADD 1 TO global_error_count.
      ENDIF.
      PERFORM execute_progress USING global_error_count 'RFBLG'.
    ENDSELECT.
  ELSE.
    DATA ibseg LIKE bseg OCCURS 10 WITH HEADER LINE.
    DATA ubal TYPE c.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM bkpf WHERE bukrs = pt001-bukrs
*                         AND belnr IN pbelnr
*                         AND gjahr IN pgjahr
*                         AND monat IN pmonat
*                         AND cpudt IN pcpudt
*                         AND budat IN pbudat
*                         AND tcode IN ptcode
*                         AND blart IN pblart
*                         AND bstat EQ space.
*
* NEW CODE
    SELECT *
 FROM bkpf WHERE bukrs = pt001-bukrs
                         AND belnr IN pbelnr
                         AND gjahr IN pgjahr
                         AND monat IN pmonat
                         AND cpudt IN pcpudt
                         AND budat IN pbudat
                         AND tcode IN ptcode
                         AND blart IN pblart
                         AND bstat EQ space ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

SELECT * FROM bseg INTO TABLE ibseg
WHERE bukrs = bkpf-bukrs
AND belnr = bkpf-belnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*AND gjahr = bkpf-gjahr.
AND GJAHR = BKPF-GJAHR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
      IF sy-subrc NE 0.
*          *********************************************
*          no bseg present:
*          *********************************************
        CLEAR iibkpf.
        iibkpf-bukrs = bkpf-bukrs.
        iibkpf-belnr = bkpf-belnr.
        iibkpf-gjahr = bkpf-gjahr.
        iibkpf-errcd = 2.
        APPEND iibkpf.
        ADD 1 TO global_error_count.
      ELSE.

        PERFORM zero_balance_check TABLES ibseg CHANGING ubal.
        IF ubal = 'X'.
          CLEAR iibkpf.
          iibkpf-bukrs = bkpf-bukrs.
          iibkpf-belnr = bkpf-belnr.
          iibkpf-gjahr = bkpf-gjahr.
          iibkpf-errcd = 3.
          APPEND iibkpf.
          ADD 1 TO global_error_count.
        ENDIF.
      ENDIF.
      PERFORM execute_progress USING global_error_count 'BKPF'.
    ENDSELECT.

  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM zero_balance_check_correct                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IBSEG                                                         *
*  -->  UBAL                                                          *
*---------------------------------------------------------------------*
FORM zero_balance_check_correct TABLES ibseg STRUCTURE bseg
                      CHANGING ubal TYPE c.
  CLEAR ubal.
  DATA: wrbtr LIKE glt0-hsl01.

  LOOP AT ibseg.
    IF ibseg-shkzg = 'S'.
      ADD ibseg-wrbtr TO wrbtr.
    ELSE.
      SUBTRACT ibseg-wrbtr FROM wrbtr.
    ENDIF.
  ENDLOOP.

  IF wrbtr NE 0.
    IF wrbtr < 0.
*      -> haben ist zu groß -> auf soll addieren
      READ TABLE ibseg WITH KEY shkzg = 'S'.
      IF sy-subrc = 0.
*         subtract a neg val means add
        ibseg-wrbtr = ibseg-wrbtr - wrbtr.
        MODIFY ibseg INDEX sy-tabix.
      ENDIF.
    ELSE.
*      -> soll ist zu groß -> auf haben addieren
      READ TABLE ibseg WITH KEY shkzg = 'H'.
      IF sy-subrc = 0.
*         subtract a neg val means add
        ibseg-wrbtr = ibseg-wrbtr + wrbtr.
        MODIFY ibseg INDEX sy-tabix.
      ENDIF.
    ENDIF.
    ubal = 'X'.
  ENDIF.


ENDFORM.

*---------------------------------------------------------------------*
*       FORM zero_balance_check                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IBSEG                                                         *
*  -->  UBAL                                                          *
*---------------------------------------------------------------------*
FORM zero_balance_check TABLES ibseg STRUCTURE bseg
                      CHANGING ubal TYPE c.
  CLEAR ubal.
  DATA: wrbtr LIKE glt0-hsl01,
        dmbtr LIKE glt0-hsl01,
        dmbe2 LIKE glt0-hsl01,
        dmbe3 LIKE glt0-hsl01.

  LOOP AT ibseg.
    IF ibseg-shkzg = 'S'.
      ADD ibseg-wrbtr TO wrbtr.
      ADD ibseg-dmbtr TO dmbtr.
      ADD ibseg-dmbe2 TO dmbe2.
      ADD ibseg-dmbe3 TO dmbe3.
    ELSE.
      SUBTRACT ibseg-wrbtr FROM wrbtr.
      SUBTRACT ibseg-dmbtr FROM dmbtr.
      SUBTRACT ibseg-dmbe2 FROM dmbe2.
      SUBTRACT ibseg-dmbe3 FROM dmbe3.
    ENDIF.
  ENDLOOP.

  IF wrbtr NE 0 OR dmbtr NE 0 OR dmbe2 NE 0 OR dmbe3 NE 0.
    ubal = 'X'.
  ENDIF.


ENDFORM.

*---------------------------------------------------------------------*
*       FORM write_new_positions                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IIBKPF                                                        *
*  -->  NEW_BSEG                                                      *
*  -->  PT001                                                         *
*---------------------------------------------------------------------*
FORM write_new_positions TABLES iibkpf STRUCTURE nbkpf
                               new_bseg STRUCTURE bseg
                         USING pt001 LIKE t001.
  DATA bseg_item_count TYPE i.
  DATA xbset LIKE bset OCCURS 0 WITH HEADER LINE.

  LOOP AT iibkpf WHERE bukrs = pt001-bukrs.
    NEW-LINE.
    ULINE (112).
    FORMAT COLOR COL_HEADING.
    WRITE:/ sy-vline,
            iibkpf-bukrs,
            iibkpf-belnr,
            iibkpf-gjahr.
    CASE iibkpf-repcd.
      WHEN 0.
        WRITE: 'Document can be recreated'.
      WHEN 2.
        WRITE: 'Document cannot be recreated: No Positions found'
             COLOR COL_NEGATIVE.
      WHEN 3.
        WRITE: 'Document cannot be recreated: would be unbalanced'
            COLOR COL_NEGATIVE.
      WHEN 4.
        WRITE: 'Document cannot be recreated: RFC failed'
            COLOR COL_NEGATIVE.
      WHEN 5.
        WRITE: 'Document cannot be recreated: No Data in Source'
            COLOR COL_NEGATIVE.
      WHEN 11.
        WRITE: 'Document cannot be recreated: Initial Account Num'
            COLOR COL_NEGATIVE.
      WHEN 12.
        WRITE: 'Document cannot be recreated: Missing Positions'
            COLOR COL_NEGATIVE.
      WHEN -1.
        WRITE: 'Document successfully recreated'
            COLOR COL_POSITIVE.
      WHEN -2.
        WRITE: 'Doc not successfully recreated: modify bseg failed'
             COLOR COL_NEGATIVE.

    ENDCASE.

    WRITE: 112 sy-vline.
    PERFORM write_bseg_header.
    NEW-LINE.
    ULINE (112).

    bseg_item_count = 0.

    IF xrfc = 'X'.
      LOOP AT global_rfblg WHERE bukrs = iibkpf-bukrs
                             AND belnr = iibkpf-belnr
                             AND gjahr = iibkpf-gjahr.
        FORMAT COLOR COL_NORMAL.
        WRITE:/ sy-vline,
                global_rfblg-pageno,
                '**** RFBLG has binary type ****',
                112 sy-vline.
        FORMAT COLOR OFF.
        ADD 1 TO bseg_item_count.

      ENDLOOP.
    ELSE.
      LOOP AT new_bseg WHERE bukrs = iibkpf-bukrs
                         AND belnr = iibkpf-belnr
                         AND gjahr = iibkpf-gjahr.
        FORMAT COLOR COL_NORMAL.
        PERFORM write_bseg USING new_bseg.


        FORMAT COLOR OFF.
        IF iibkpf-repcd = 0.
          hbseg = new_bseg.
          HIDE hbseg.
          WRITE '@0Z@' AS ICON COLOR OFF.
        ENDIF.


        ADD 1 TO bseg_item_count.

      ENDLOOP.

      IF iibkpf-repcd = -1.
      IF cbset = 'X'.
        PERFORM create_ibset TABLES xbset
                              USING iibkpf.
        PERFORM write_bset TABLES xbset
                            USING iibkpf.
      ENDIF.
      ENDIF.
      IF iibkpf-repcd = 0.
        NEW-LINE.
        ULINE (112).

        FORMAT INTENSIFIED OFF.
        FORMAT COLOR COL_NORMAL.
        WRITE:/ sy-vline,
              'Trying to repair BSET also',
              112 sy-vline.
        FORMAT COLOR OFF.
        FORMAT INTENSIFIED ON.

      ENDIF.



    ENDIF.

    IF bseg_item_count = 0.
      WRITE:/ sy-vline,
              '***** No Data ****',
              112 sy-vline.


    ENDIF.


    NEW-LINE.
    ULINE (112).

  ENDLOOP.
  FORMAT COLOR OFF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM create_new_headers_rfvb                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IIBKPF                                                        *
*  -->  NEW_BKPF                                                      *
*  -->  PT001                                                         *
*---------------------------------------------------------------------*
FORM create_new_headers_rfvb  TABLES iibkpf STRUCTURE nbkpf
                                      new_bkpf STRUCTURE bkpf
                                USING pt001 LIKE t001.
  LOOP AT global_t001.
    PERFORM bkpf_create_rfvb TABLES iibkpf new_bkpf
                              USING global_t001.
  ENDLOOP.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM create_new_headers_rfc                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IIBKPF                                                        *
*  -->  NEW_BKPF                                                      *
*  -->  PT001                                                         *
*---------------------------------------------------------------------*
FORM create_new_headers_rfc  TABLES iibkpf STRUCTURE nbkpf
                                      new_bkpf STRUCTURE bkpf
                                USING pt001 LIKE t001.
  DATA ybkpf LIKE bkpf OCCURS 0 WITH HEADER LINE.
  DATA msg_text(80) TYPE c.

  LOOP AT iibkpf.
    CALL FUNCTION 'Z_GET_REMOTE_DOCUMENT3'  DESTINATION src_sys
         EXPORTING
              client             = src_cli
              docno              = iibkpf-belnr
              cocode             = iibkpf-bukrs
              f_year             = iibkpf-gjahr
         TABLES
              ibkpf              = ybkpf
      EXCEPTIONS
             nothing_aint_there = 1
             communication_failure = 3 MESSAGE msg_text
             system_failure        = 4 MESSAGE msg_text
             OTHERS             = 2.
*   check exceptions
    IF sy-subrc EQ '1'.
      exceptions-bukrs = iibkpf-bukrs.
      exceptions-belnr = iibkpf-belnr.
      exceptions-gjahr = iibkpf-gjahr.
      exceptions-buzei = '0'.
      exceptions-key = '8'.
      iibkpf-repcd = 5.
      MODIFY iibkpf.
      exceptions-level = 'E'.
      APPEND exceptions.
    ENDIF.
    IF sy-subrc EQ '2' OR sy-subrc EQ '3' OR sy-subrc EQ '4'.
      exceptions-bukrs = iibkpf-bukrs.
      exceptions-belnr = iibkpf-belnr.
      exceptions-gjahr = iibkpf-gjahr.
      exceptions-buzei = '0'.
      exceptions-key = '10'.
      iibkpf-repcd = 4.
      MODIFY iibkpf.
      exceptions-level = 'E'.
      APPEND exceptions.
    ENDIF.

    IF sy-subrc = 0.
      APPEND LINES OF ybkpf TO new_bkpf.
    ENDIF.

  ENDLOOP.



ENDFORM.



*---------------------------------------------------------------------*
*       FORM create_new_positions_rfc                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IIBKPF                                                        *
*  -->  NEW_BSEG                                                      *
*  -->  PT001                                                         *
*---------------------------------------------------------------------*
FORM create_new_positions_rfc  TABLES iibkpf STRUCTURE nbkpf
                                      new_bseg STRUCTURE bseg
                                USING pt001 LIKE t001.

  DATA yrfblg LIKE rfblg OCCURS 0 WITH HEADER LINE.
  DATA msg_text(80) TYPE c.
*   this rfc-enabled function module has to be created in
*   the source system !
  LOOP AT iibkpf.
    CALL FUNCTION 'Z_GET_REMOTE_DOCUMENT3'  DESTINATION src_sys
         EXPORTING
              client             = src_cli
              docno              = iibkpf-belnr
              cocode             = iibkpf-bukrs
              f_year             = iibkpf-gjahr
         TABLES
              irfblg             = yrfblg
      EXCEPTIONS
             nothing_aint_there = 1
             communication_failure = 3 MESSAGE msg_text
             system_failure        = 4 MESSAGE msg_text
             OTHERS             = 2.
*   check exceptions
    IF sy-subrc EQ '1'.
      exceptions-bukrs = iibkpf-bukrs.
      exceptions-belnr = iibkpf-belnr.
      exceptions-gjahr = iibkpf-gjahr.
      exceptions-buzei = '0'.
      exceptions-key = '8'.
      iibkpf-repcd = 5.
      MODIFY iibkpf.
      exceptions-level = 'E'.
      APPEND exceptions.
    ENDIF.
    IF sy-subrc EQ '2' OR sy-subrc EQ '3' OR sy-subrc EQ '4'.
      exceptions-bukrs = iibkpf-bukrs.
      exceptions-belnr = iibkpf-belnr.
      exceptions-gjahr = iibkpf-gjahr.
      exceptions-buzei = '0'.
      exceptions-key = '10'.
      iibkpf-repcd = 4.
      MODIFY iibkpf.
      exceptions-level = 'E'.
      APPEND exceptions.
    ENDIF.

    IF sy-subrc = 0.
      APPEND LINES OF yrfblg TO global_rfblg.
    ENDIF.

  ENDLOOP.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM create_new_positions_rf070                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IIBKPF                                                        *
*  -->  NEW_BSEG                                                      *
*  -->  PT001                                                         *
*---------------------------------------------------------------------*
FORM create_new_positions_rf070  TABLES iibkpf STRUCTURE nbkpf
                                      new_bseg STRUCTURE bseg
                                USING pt001 LIKE t001.

  LOOP AT global_t001.
    PERFORM bukrs_import USING global_t001.
    PERFORM bseg_create_rf070 TABLES iibkpf new_bseg
                              USING global_t001.
  ENDLOOP.



ENDFORM.

*---------------------------------------------------------------------*
*       FORM create_new_positions_rfvb                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IIBKPF                                                        *
*  -->  NEW_BSEG                                                      *
*  -->  PT001                                                         *
*---------------------------------------------------------------------*
FORM create_new_positions_rfvb  TABLES iibkpf STRUCTURE nbkpf
                                      new_bseg STRUCTURE bseg
                                USING pt001 LIKE t001.

  LOOP AT global_t001.
    PERFORM bseg_create_rfvb TABLES iibkpf new_bseg
                              USING global_t001.
  ENDLOOP.



ENDFORM.


*---------------------------------------------------------------------*
*       FORM bseg_create_rf070                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IIBKPF                                                        *
*  -->  NEW_BSEG                                                      *
*  -->  PT001                                                         *
*---------------------------------------------------------------------*
FORM bseg_create_rf070 TABLES iibkpf STRUCTURE nbkpf
                              new_bseg STRUCTURE bseg
                       USING pt001 LIKE t001.
  DATA: tabix_new_bseg LIKE sy-tabix,
        wbseg LIKE bseg,
        must_create_sec TYPE c,
        buzei LIKE bseg-buzei,
        wbkpf LIKE bkpf,
        err_flag TYPE c.


  LOOP AT iibkpf WHERE bukrs = global_t001-bukrs.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM bkpf INTO wbkpf WHERE bukrs = iibkpf-bukrs
*                                           AND belnr = iibkpf-belnr
*                                           AND gjahr = iibkpf-gjahr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM bkpf INTO wbkpf WHERE bukrs = iibkpf-bukrs
                                           AND belnr = iibkpf-belnr
                                           AND gjahr = iibkpf-gjahr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    CHECK sy-subrc = 0.

    buzei = '001'.
    LOOP AT glvals.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM skb1 WHERE bukrs = pt001-bukrs
*                                  AND saknr = glvals-accnt.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM skb1 WHERE bukrs = pt001-bukrs
                                  AND saknr = glvals-accnt ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      CHECK sy-subrc = 0. "entry in skb1 should exist.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM ska1 WHERE ktopl = pt001-ktopl
*                                  AND saknr = glvals-accnt.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM ska1 WHERE ktopl = pt001-ktopl
                                  AND saknr = glvals-accnt ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      CHECK sy-subrc = 0. "entry in ska1 should exist.

      CLEAR: new_bseg, wbseg.
      wbseg-buzei = buzei.
      ADD 1 TO buzei.
      PERFORM project_glval_to_bseg USING glvals iibkpf
                                 CHANGING wbseg must_create_sec.



      PERFORM tabix_new_bseg TABLES new_bseg
                              USING wbseg
                           CHANGING tabix_new_bseg.
      PERFORM template_select CHANGING wbseg.

      PERFORM project_glval_to_bseg USING glvals iibkpf
                                 CHANGING wbseg must_create_sec.


      IF NOT skb1-mitkz IS INITIAL.
        wbseg-hzuon = wbseg-zuonr.
        CLEAR wbseg-zuonr.
        wbseg-koart = skb1-mitkz.
        IF wbseg-shkzg = 'S'.
          IF wbseg-koart = 'D'.
            wbseg-bschl = '01'.
          ELSE.
            wbseg-bschl = '21'.
          ENDIF.
        ELSE.
          IF wbseg-koart = 'D'.
            wbseg-bschl = '11'.
          ELSE.
            wbseg-bschl = '31'.
          ENDIF.
        ENDIF.
      ELSE.
        wbseg-koart = 'S'.
        IF wbseg-shkzg = 'S'.
          wbseg-bschl = '40'.
        ELSE.
          wbseg-bschl = '50'.
        ENDIF.
      ENDIF.

      wbseg-sgtxt = 'Rep by SAP'.

      IF skb1-xsalh NE 'X'.
        wbseg-wrbtr = wbseg-pswbt.
      ELSE.
        IF wbkpf-waers = global_t001-waers.
          wbseg-wrbtr = wbseg-dmbtr.

        ELSE.
          PERFORM create_wrbtr USING wbkpf-waers
                                     global_t001-waers
                                     wbkpf-budat
                                     wbseg-dmbtr
                            CHANGING wbseg-wrbtr
                                     err_flag.
        ENDIF.
      ENDIF.

      IF tabix_new_bseg GT 0.
        MODIFY new_bseg FROM wbseg INDEX tabix_new_bseg.
      ELSE.
        APPEND wbseg TO new_bseg.
      ENDIF.



    ENDLOOP.


    EXIT. " just one doc for a company code.
  ENDLOOP.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM bseg_create_rfvb                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IIBKPF                                                        *
*  -->  NEW_BSEG                                                      *
*  -->  PT001                                                         *
*---------------------------------------------------------------------*
FORM bseg_create_rfvb TABLES iibkpf STRUCTURE nbkpf
                              new_bseg STRUCTURE bseg
                       USING pt001 LIKE t001.

  DATA: dbseg LIKE bseg OCCURS 10 WITH HEADER LINE.


  LOOP AT iibkpf WHERE bukrs = global_t001-bukrs.

    LOOP AT new_bseg WHERE bukrs = iibkpf-bukrs
                       AND belnr = iibkpf-belnr
                       AND gjahr = iibkpf-gjahr.
      DELETE new_bseg.
    ENDLOOP.

    PERFORM bseg_import_vb TABLES dbseg
                            USING iibkpf-bukrs
                                  iibkpf-belnr
                                  iibkpf-gjahr.

    APPEND LINES OF dbseg TO new_bseg.


  ENDLOOP.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM bkpf_create_rfvb                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IIBKPF                                                        *
*  -->  NEW_BKPF                                                      *
*  -->  PT001                                                         *
*---------------------------------------------------------------------*
FORM bkpf_create_rfvb TABLES iibkpf STRUCTURE nbkpf
                              new_bkpf STRUCTURE bkpf
                       USING pt001 LIKE t001.

  DATA: dbkpf LIKE bkpf OCCURS 10 WITH HEADER LINE.


  LOOP AT iibkpf WHERE bukrs = global_t001-bukrs.

    LOOP AT new_bkpf WHERE bukrs = iibkpf-bukrs
                       AND belnr = iibkpf-belnr
                       AND gjahr = iibkpf-gjahr.
      DELETE new_bkpf.
    ENDLOOP.

    PERFORM bkpf_import_vb TABLES dbkpf
                            USING iibkpf-bukrs
                                  iibkpf-belnr
                                  iibkpf-gjahr.

    APPEND LINES OF dbkpf TO new_bkpf.


  ENDLOOP.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM bkpf_import_vb                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PIBKPF                                                        *
*  -->  PPBUKRS                                                       *
*  -->  PPBELNR                                                       *
*  -->  PPGJAHR                                                       *
*---------------------------------------------------------------------*
FORM bkpf_import_vb TABLES pibkpf STRUCTURE bkpf
                     USING ppbukrs LIKE bseg-bukrs
                           ppbelnr LIKE bseg-belnr
                           ppgjahr LIKE bseg-gjahr.


  CLEAR pibkpf.
  REFRESH pibkpf.
  DATA: BEGIN OF vb_key,
        key LIKE vbmod-vbkey,
        id  LIKE vbmod-vbmodcnt,
        END OF vb_key.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM vbhdr WHERE vbkey = pvbkey.
**
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM vbhdr WHERE vbkey = pvbkey ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  CHECK sy-subrc = 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM vbmod WHERE vbkey = pvbkey
*                             AND vbfunc = 'POST_DOCUMENT'.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM vbmod WHERE vbkey = pvbkey
                             AND vbfunc = 'POST_DOCUMENT' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  CHECK sy-subrc = 0.
* '29173DC881F24919B2BDB5F94E1EEBDB'.
* VB_KEY-ID = '2'.
  vb_key-key = pvbkey.
  vb_key-id = vbmod-vbmodcnt. " das ist die ID für Post_document.


  DATA: tembkpf LIKE bkpf OCCURS 10 WITH HEADER LINE.
  IMPORT t_bkpf TO tembkpf FROM LOGFILE ID vb_key.

  LOOP AT tembkpf WHERE bukrs = ppbukrs
                    AND belnr = ppbelnr
                    AND gjahr = ppgjahr.

    pibkpf = tembkpf.
    APPEND pibkpf.

  ENDLOOP.


ENDFORM.


*---------------------------------------------------------------------*
*       FORM bseg_import_vb                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PIBSEG                                                        *
*  -->  PPBUKRS                                                       *
*  -->  PPBELNR                                                       *
*  -->  PPGJAHR                                                       *
*---------------------------------------------------------------------*
FORM bseg_import_vb TABLES pibseg STRUCTURE bseg
                     USING ppbukrs LIKE bseg-bukrs
                           ppbelnr LIKE bseg-belnr
                           ppgjahr LIKE bseg-gjahr.


  CLEAR pibseg.
  REFRESH pibseg.
  DATA: BEGIN OF vb_key,
        key LIKE vbmod-vbkey,
        id  LIKE vbmod-vbmodcnt,
        END OF vb_key.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM vbhdr WHERE vbkey = pvbkey.
**
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM vbhdr WHERE vbkey = pvbkey ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  CHECK sy-subrc = 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM vbmod WHERE vbkey = pvbkey
*                             AND vbfunc = 'POST_DOCUMENT'.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM vbmod WHERE vbkey = pvbkey
                             AND vbfunc = 'POST_DOCUMENT' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  CHECK sy-subrc = 0.
* '29173DC881F24919B2BDB5F94E1EEBDB'.
* VB_KEY-ID = '2'.
  vb_key-key = pvbkey.
  vb_key-id = vbmod-vbmodcnt. " das ist die ID für Post_document.


  DATA: tembseg LIKE bseg OCCURS 10 WITH HEADER LINE.
  IMPORT t_bseg TO tembseg FROM LOGFILE ID vb_key.

  LOOP AT tembseg WHERE bukrs = ppbukrs
                    AND belnr = ppbelnr
                    AND gjahr = ppgjahr.

    pibseg = tembseg.
    APPEND pibseg.

  ENDLOOP.


ENDFORM.



*---------------------------------------------------------------------*
*       FORM create_wrbtr                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PFC_WAERS                                                     *
*  -->  PLC_WAERS                                                     *
*  -->  PDATE                                                         *
*  -->  PLC                                                           *
*  -->  PFC                                                           *
*  -->  PERR                                                          *
*---------------------------------------------------------------------*
FORM create_wrbtr USING pfc_waers LIKE bkpf-waers
                        plc_waers LIKE bkpf-waers
                        pdate LIKE bkpf-budat
                        plc LIKE bseg-dmbtr
               CHANGING pfc LIKE bseg-dmbtr
                        perr TYPE c.
  CLEAR perr.
  CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
    EXPORTING
*   CLIENT                  = SY-MANDT
      date                    = pdate
      foreign_currency        = pfc_waers
      local_amount            = plc
      local_currency          = plc_waers
*   RATE                    = 0
*   TYPE_OF_RATE            = 'M'
*   READ_TCURR              = 'X'
   IMPORTING
*   EXCHANGE_RATE           =
      foreign_amount          = pfc
*   FOREIGN_FACTOR          =
*   LOCAL_FACTOR            =
*   EXCHANGE_RATEX          =
*   DERIVED_RATE_TYPE       =
*   FIXED_RATE              =
    EXCEPTIONS
     no_rate_found           = 1
     overflow                = 2
     no_factors_found        = 3
     no_spread_found         = 4
     derived_2_times         = 5
     OTHERS                  = 6
            .
  IF sy-subrc <> 0.
    perr = 'X'.
  ENDIF.


ENDFORM.



*---------------------------------------------------------------------*
*       FORM project_glval_to_bseg                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PGLVALS                                                       *
*  -->  PHEADER                                                       *
*  -->  PBSEG                                                         *
*  -->  MUST_CREATE_SEC                                               *
*---------------------------------------------------------------------*
FORM project_glval_to_bseg USING pglvals TYPE t_cmp
                                 pheader TYPE tbkpf
                        CHANGING pbseg LIKE bseg
                                 must_create_sec TYPE c.
  DATA: dtw LIKE huge_amount.
  DATA: dhw1 LIKE huge_amount.
  DATA: dhw2 LIKE huge_amount.
  DATA: dhw3 LIKE huge_amount.

  dtw  = pglvals-tw_ist  - pglvals-tw_cal.
  dhw1 = pglvals-hw1_ist - pglvals-hw1_cal.
  dhw2 = pglvals-hw2_ist - pglvals-hw2_cal.
  dhw3 = pglvals-hw3_ist - pglvals-hw3_cal.

  MOVE: pheader-belnr TO pbseg-belnr,
        pheader-gjahr TO pbseg-gjahr,
        pheader-bukrs TO pbseg-bukrs.


  MOVE: pglvals-accnt TO pbseg-hkont,
        pglvals-accnt TO pbseg-saknr,
        pglvals-gsber TO pbseg-gsber,
        pglvals-drcrk TO pbseg-shkzg,
        pglvals-pswsl TO pbseg-pswsl.


  MOVE: dtw  TO pbseg-pswbt,
        dhw1 TO pbseg-dmbtr,
        dhw2 TO pbseg-dmbe2,
        dhw3 TO pbseg-dmbe3.
*        pbseg-wrbtr is not set here.
*        this must be done later when all
*        account settings are known.


ENDFORM.

*---------------------------------------------------------------------*
*       FORM bukrs_import                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PT001                                                         *
*---------------------------------------------------------------------*
FORM bukrs_import USING pt001 LIKE t001.
* import data of a previous run for a given cc/year

  DATA: rfdt_key_exp LIKE rfdt-srtfd.

  rfdt_key_exp    = 'INDEX_F070_'.
  rfdt_key_exp+11 = pt001-bukrs.
  rfdt_key_exp+15 = pgjahr-low.

  DATA: sdate LIKE sy-datum.
  DATA: stime LIKE sy-uzeit.
  DATA: syear LIKE bkpf-gjahr.


  IMPORT sdate TO sdate stime TO stime syear TO syear
   glvals glvald glvalk glvald_shb glvalk_shb
    FROM DATABASE rfdt(fu) ID rfdt_key_exp.

  IF sy-subrc NE 0.
    CLEAR: glvals, glvald, glvalk, glvald_shb.
    REFRESH: glvals, glvald, glvalk, glvald_shb.
  ENDIF.

  PERFORM after_import TABLES glvals.
  PERFORM after_import TABLES glvald.
  PERFORM after_import TABLES glvalk.
  PERFORM after_import TABLES glvald_shb.
  PERFORM after_import TABLES glvalk_shb.


ENDFORM.

*---------------------------------------------------------------------*
*       FORM after_import                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IBAL                                                          *
*---------------------------------------------------------------------*
FORM after_import TABLES ibal STRUCTURE glvals.
  DATA: dtw LIKE huge_amount.
  DATA: dhw1 LIKE huge_amount.
  DATA: dhw2 LIKE huge_amount.
  DATA: dhw3 LIKE huge_amount.
  LOOP AT ibal.
    CLEAR: dtw, dhw1, dhw2, dhw3.
    dtw = ibal-tw_cal - ibal-tw_ist.
    dhw1 = ibal-hw1_cal - ibal-hw1_ist.
    dhw2 = ibal-hw2_cal - ibal-hw2_ist.
    dhw3 = ibal-hw3_cal - ibal-hw3_ist.
    IF dtw = 0 AND
      dhw1 = 0 AND
      dhw2 = 0 AND
      dhw3 = 0.
      DELETE ibal.
    ELSE.
      IF dtw > 0 OR
        dhw1 > 0 OR
        dhw2 > 0 OR
        dhw3 > 0.
        DELETE ibal.
      ELSE.
*           write:/ 'kept'.
      ENDIF.
    ENDIF.
*      only value < 0 make sense


  ENDLOOP.

ENDFORM.



*---------------------------------------------------------------------*
*       FORM create_new_positions                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IIBKPF                                                        *
*  -->  NEW_BSEG                                                      *
*  -->  PT001                                                         *
*---------------------------------------------------------------------*
FORM create_new_positions TABLES iibkpf STRUCTURE nbkpf
                               new_bseg STRUCTURE bseg
                         USING pt001 LIKE t001.

  IF xrfc = 'X'.
    PERFORM create_new_positions_rfc TABLES iibkpf new_bseg
                                     USING pt001.
    EXIT.
  ENDIF.

  IF xvbtab = 'X'.
    PERFORM create_new_positions_rfvb TABLES iibkpf new_bseg
                                     USING pt001.

    EXIT.
  ENDIF.

  RANGES docs FOR bseg-belnr.
  RANGES years FOR bseg-gjahr.
  DATA: tabix_new_bseg LIKE sy-tabix,
        wbseg LIKE bseg.
  LOOP AT iibkpf WHERE bukrs = pt001-bukrs.
    CLEAR: docs, years.

    docs-sign = 'I'.
    docs-option = 'EQ'.
    docs-low = iibkpf-belnr.

    years-sign = 'I'.
    years-option = 'EQ'.
    years-low = iibkpf-gjahr.

    APPEND docs.
    APPEND years.

  ENDLOOP.





  IF xbsis = 'X'.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM bsis WHERE bukrs = pt001-bukrs
*                         AND hkont IN phkont
*                         AND belnr IN docs
*                         AND gjahr IN years.
*
* NEW CODE
    SELECT *
 FROM bsis WHERE bukrs = pt001-bukrs
                         AND hkont IN phkont
                         AND belnr IN docs
                         AND gjahr IN years ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

      READ TABLE iibkpf WITH KEY bukrs = bsis-bukrs
                                 belnr = bsis-belnr
                                 gjahr = bsis-gjahr.
      CHECK sy-subrc = 0.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM skb1 WHERE bukrs = pt001-bukrs
*                                  AND saknr = bsis-hkont.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM skb1 WHERE bukrs = pt001-bukrs
                                  AND saknr = bsis-hkont ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      CHECK sy-subrc = 0.

      CLEAR: new_bseg, wbseg.
      MOVE-CORRESPONDING bsis TO wbseg.

      PERFORM tabix_new_bseg TABLES new_bseg
                              USING wbseg
                           CHANGING tabix_new_bseg.
      PERFORM template_select CHANGING wbseg.

      MOVE-CORRESPONDING bsis TO wbseg.
      IF NOT skb1-mitkz IS INITIAL.
        wbseg-hzuon = wbseg-zuonr.
        CLEAR wbseg-zuonr.
      ENDIF.

      IF tabix_new_bseg GT 0.
        MODIFY new_bseg FROM wbseg INDEX tabix_new_bseg.
      ELSE.
        APPEND wbseg TO new_bseg.
      ENDIF.


    ENDSELECT.
  ENDIF.
  IF xbsas = 'X'.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM bsas WHERE bukrs = pt001-bukrs
*                         AND hkont IN phkont
*                         AND belnr IN docs
*                         AND gjahr IN years.
*
* NEW CODE
    SELECT *
 FROM bsas WHERE bukrs = pt001-bukrs
                         AND hkont IN phkont
                         AND belnr IN docs
                         AND gjahr IN years ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      READ TABLE iibkpf WITH KEY bukrs = bsas-bukrs
                                 belnr = bsas-belnr
                                 gjahr = bsas-gjahr.
      CHECK sy-subrc = 0.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM skb1 WHERE bukrs = pt001-bukrs
*                                  AND saknr = bsas-hkont.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM skb1 WHERE bukrs = pt001-bukrs
                                  AND saknr = bsas-hkont ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      CHECK sy-subrc = 0.

      CLEAR: new_bseg, wbseg.
      MOVE-CORRESPONDING bsas TO wbseg.

      PERFORM tabix_new_bseg TABLES new_bseg
                              USING wbseg
                           CHANGING tabix_new_bseg.
      PERFORM template_select CHANGING wbseg.

      MOVE-CORRESPONDING bsas TO wbseg.
      IF NOT skb1-mitkz IS INITIAL.
        wbseg-hzuon = wbseg-zuonr.
        CLEAR wbseg-zuonr.
      ENDIF.

      IF tabix_new_bseg GT 0.
        MODIFY new_bseg FROM wbseg INDEX tabix_new_bseg.
      ELSE.
        APPEND wbseg TO new_bseg.
      ENDIF.


    ENDSELECT.
  ENDIF.

  IF xbsid = 'X'.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM bsid WHERE bukrs = pt001-bukrs
*                         AND kunnr IN pkunnr
*                         AND belnr IN docs
*                         AND gjahr IN years.
*
* NEW CODE
    SELECT *
 FROM bsid WHERE bukrs = pt001-bukrs
                         AND kunnr IN pkunnr
                         AND belnr IN docs
                         AND gjahr IN years ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

      READ TABLE iibkpf WITH KEY bukrs = bsid-bukrs
                                 belnr = bsid-belnr
                                 gjahr = bsid-gjahr.
      CHECK sy-subrc = 0.

      CLEAR: new_bseg, wbseg.
      MOVE-CORRESPONDING bsid TO wbseg.

      PERFORM tabix_new_bseg TABLES new_bseg
                              USING wbseg
                           CHANGING tabix_new_bseg.
      PERFORM template_select CHANGING wbseg.

      MOVE-CORRESPONDING bsid TO wbseg.
      IF tabix_new_bseg GT 0.
        MODIFY new_bseg FROM wbseg INDEX tabix_new_bseg.
      ELSE.
        APPEND wbseg TO new_bseg.
      ENDIF.
    ENDSELECT.
  ENDIF.
  IF xbsad = 'X'.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM bsad WHERE bukrs = pt001-bukrs
*                         AND kunnr IN pkunnr
*                         AND belnr IN docs
*                         AND gjahr IN years.
*
* NEW CODE
    SELECT *
 FROM bsad WHERE bukrs = pt001-bukrs
                         AND kunnr IN pkunnr
                         AND belnr IN docs
                         AND gjahr IN years ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

      READ TABLE iibkpf WITH KEY bukrs = bsad-bukrs
                                 belnr = bsad-belnr
                                 gjahr = bsad-gjahr.
      CHECK sy-subrc = 0.

      CLEAR: new_bseg, wbseg.
      MOVE-CORRESPONDING bsad TO wbseg.

      PERFORM tabix_new_bseg TABLES new_bseg
                              USING wbseg
                           CHANGING tabix_new_bseg.
      PERFORM template_select CHANGING wbseg.

      MOVE-CORRESPONDING bsad TO wbseg.
      IF tabix_new_bseg GT 0.
        MODIFY new_bseg FROM wbseg INDEX tabix_new_bseg.
      ELSE.
        APPEND wbseg TO new_bseg.
      ENDIF.
    ENDSELECT.
  ENDIF.

  IF xbsik = 'X'.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM bsik WHERE bukrs = pt001-bukrs
*                         AND lifnr IN plifnr
*                         AND belnr IN docs
*                         AND gjahr IN years.
*
* NEW CODE
    SELECT *
 FROM bsik WHERE bukrs = pt001-bukrs
                         AND lifnr IN plifnr
                         AND belnr IN docs
                         AND gjahr IN years ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

      READ TABLE iibkpf WITH KEY bukrs = bsik-bukrs
                                 belnr = bsik-belnr
                                 gjahr = bsik-gjahr.
      CHECK sy-subrc = 0.

      CLEAR: new_bseg, wbseg.
      MOVE-CORRESPONDING bsik TO wbseg.

      PERFORM tabix_new_bseg TABLES new_bseg
                              USING wbseg
                           CHANGING tabix_new_bseg.
      PERFORM template_select CHANGING wbseg.

      MOVE-CORRESPONDING bsik TO wbseg.
      IF tabix_new_bseg GT 0.
        MODIFY new_bseg FROM wbseg INDEX tabix_new_bseg.
      ELSE.
        APPEND wbseg TO new_bseg.
      ENDIF.
    ENDSELECT.
  ENDIF.
  IF xbsak = 'X'.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM bsak WHERE bukrs = pt001-bukrs
*                         AND lifnr IN plifnr
*                         AND belnr IN docs
*                         AND gjahr IN years.
*
* NEW CODE
    SELECT *
 FROM bsak WHERE bukrs = pt001-bukrs
                         AND lifnr IN plifnr
                         AND belnr IN docs
                         AND gjahr IN years ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

      READ TABLE iibkpf WITH KEY bukrs = bsak-bukrs
                                 belnr = bsak-belnr
                                 gjahr = bsak-gjahr.
      CHECK sy-subrc = 0.

      CLEAR: new_bseg, wbseg.
      MOVE-CORRESPONDING bsak TO wbseg.

      PERFORM tabix_new_bseg TABLES new_bseg
                              USING wbseg
                           CHANGING tabix_new_bseg.
      PERFORM template_select CHANGING wbseg.

      MOVE-CORRESPONDING bsak TO wbseg.
      IF tabix_new_bseg GT 0.
        MODIFY new_bseg FROM wbseg INDEX tabix_new_bseg.
      ELSE.
        APPEND wbseg TO new_bseg.
      ENDIF.
    ENDSELECT.
  ENDIF.

* ***************************************
* All indices are selected at this point
* and copied over the template positions
* (if there are any)
* ***************************************

* *********************************************
* Zero balance check and append existing bsegs.
* and sort by bukrs belnr gjahr buzei.
* *********************************************
  PERFORM deselect_ubal TABLES iibkpf new_bseg
                         USING pt001.

  PERFORM complete_positions TABLES iibkpf new_bseg
                              USING pt001.

  PERFORM final_checks TABLES iibkpf new_bseg
                         USING pt001.





ENDFORM.
*---------------------------------------------------------------------*
*       FORM complete_positions                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IIBKPF                                                        *
*  -->  NEW_BSEG                                                      *
*  -->  PT001                                                         *
*---------------------------------------------------------------------*
FORM complete_positions TABLES iibkpf STRUCTURE nbkpf
                               new_bseg STRUCTURE bseg
                         USING pt001 LIKE t001.
  LOOP AT iibkpf WHERE bukrs = pt001-bukrs.

    LOOP AT new_bseg WHERE bukrs = iibkpf-bukrs
                       AND belnr = iibkpf-belnr
                       AND gjahr = iibkpf-gjahr.
*            Buchungsschlüssel:->Kontoart ->umsatzwirksam ->Zahlvorgang
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM tbsl WHERE bschl = new_bseg-bschl.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM tbsl WHERE bschl = new_bseg-bschl ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc = 0.
        new_bseg-koart = tbsl-koart.
        new_bseg-xumsw = tbsl-xumsw.
        new_bseg-xzahl = tbsl-xzahl.
        MODIFY new_bseg.
      ENDIF.
*            augcp wird auf augdt gesetzt.
      new_bseg-augcp = new_bseg-augdt.

*            Werte aus Sachkonten-A-Segment
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM ska1 WHERE ktopl = pt001-ktopl
*                                  AND saknr = new_bseg-hkont.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM ska1 WHERE ktopl = pt001-ktopl
                                  AND saknr = new_bseg-hkont ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc = 0.
        new_bseg-altkt = ska1-bilkt.
        new_bseg-xbilk = ska1-xbilk.
        new_bseg-gvtyp = ska1-gvtyp.
      ENDIF.

*            Werte aus Sachkonten-B-Segment
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM skb1 WHERE bukrs = pt001-bukrs
*                                  AND saknr = new_bseg-hkont.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM skb1 WHERE bukrs = pt001-bukrs
                                  AND saknr = new_bseg-hkont ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc = 0.
        IF new_bseg-koart CA 'DK'.
          new_bseg-xopvw = 'X'.
          new_bseg-xkres = 'X'.
        ENDIF.
        IF new_bseg-koart CA 'DKA'.
          new_bseg-xhres = skb1-xkres.
        ENDIF.
        IF new_bseg-koart CA 'SM'.
          new_bseg-xkres = skb1-xkres.
          new_bseg-xopvw = skb1-xopvw.
        ENDIF.
      ENDIF.
      IF new_bseg-shkzg = 'S'.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM t030 WHERE ktopl = pt001-ktopl
*                                  AND konts = new_bseg-hkont.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM t030 WHERE ktopl = pt001-ktopl
                                  AND konts = new_bseg-hkont ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      ELSE.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM t030 WHERE ktopl = pt001-ktopl
*                                  AND konth = new_bseg-hkont.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM t030 WHERE ktopl = pt001-ktopl
                                  AND konth = new_bseg-hkont ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      ENDIF.

      IF sy-subrc = 0.
        new_bseg-ktosl = t030-ktosl.
        new_bseg-xauto = 'X'.
        IF new_bseg-ktosl = 'SKV'.
          new_bseg-buzid = 'Z'.
        ENDIF.
        IF new_bseg-ktosl = 'WRX'.
          new_bseg-buzid = 'W'.
        ENDIF.

      ENDIF.
      DATA: wt030k LIKE t030k.
      IF new_bseg-shkzg = 'S'.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM t030k INTO wt030k
*                                WHERE ktopl = pt001-ktopl
*                                  AND mwskz = new_bseg-mwskz
*                                  AND konts = new_bseg-hkont.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM t030k INTO wt030k
                                WHERE ktopl = pt001-ktopl
                                  AND mwskz = new_bseg-mwskz
                                  AND konts = new_bseg-hkont ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      ELSE.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM t030k INTO wt030k
*                                WHERE ktopl = pt001-ktopl
*                                  AND mwskz = new_bseg-mwskz
*                                  AND konth = new_bseg-hkont.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM t030k INTO wt030k
                                WHERE ktopl = pt001-ktopl
                                  AND mwskz = new_bseg-mwskz
                                  AND konth = new_bseg-hkont ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      ENDIF.

      IF sy-subrc = 0.
        new_bseg-ktosl = wt030k-ktosl.
        new_bseg-xauto = 'X'.
        new_bseg-buzid = 'T'.
*               field TXGRP can be ignored
        CASE skb1-mwskz.
          WHEN '< '.
            new_bseg-mwart = 'V'.
          WHEN '> '.
            new_bseg-mwart = 'A'.
          WHEN OTHERS.
*                    when creating BSET wrong results possible
        ENDCASE.

      ENDIF.

      IF new_bseg-koart = 'A'.
        PERFORM read_anlagen CHANGING new_bseg.
      ENDIF.


      MODIFY new_bseg.


    ENDLOOP.

  ENDLOOP.

ENDFORM.


*---------------------------------------------------------------------*
*       FORM zero_bal_tw                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IIBKPF                                                        *
*  -->  NEW_BSEG                                                      *
*  -->  PT001                                                         *
*---------------------------------------------------------------------*
FORM zero_bal_tw TABLES iibkpf STRUCTURE nbkpf
                                 new_bseg STRUCTURE bseg
                          USING  pt001 LIKE t001.

  DATA: ubal_bseg LIKE bseg OCCURS 10 WITH HEADER LINE,
        ubal TYPE c.
  LOOP AT iibkpf WHERE bukrs = pt001-bukrs.

    CLEAR ubal_bseg.
    REFRESH ubal_bseg.

    LOOP AT new_bseg WHERE bukrs = iibkpf-bukrs
                       AND belnr = iibkpf-belnr
                       AND gjahr = iibkpf-gjahr.
      APPEND new_bseg TO ubal_bseg.

    ENDLOOP.

    PERFORM zero_balance_check_correct TABLES ubal_bseg
                     CHANGING ubal.
    IF ubal = 'X'.
      LOOP AT ubal_bseg.
        READ TABLE new_bseg WITH KEY bukrs = ubal_bseg-bukrs
                                     belnr = ubal_bseg-belnr
                                     gjahr = ubal_bseg-gjahr
                                     buzei = ubal_bseg-buzei.
        IF sy-subrc = 0.
          IF new_bseg-wrbtr NE ubal_bseg-wrbtr.
            new_bseg-wrbtr = ubal_bseg-wrbtr.
            MODIFY new_bseg INDEX sy-tabix TRANSPORTING wrbtr.
          ENDIF.

        ENDIF.

      ENDLOOP.

    ENDIF.


  ENDLOOP.



ENDFORM.



*---------------------------------------------------------------------*
*       FORM deselect_ubal                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IIBKPF                                                        *
*  -->  NEW_BSEG                                                      *
*  -->  PT001                                                         *
*---------------------------------------------------------------------*
FORM deselect_ubal TABLES iibkpf STRUCTURE nbkpf
                                 new_bseg STRUCTURE bseg
                          USING  pt001 LIKE t001.

  DATA: ubal_bseg LIKE bseg OCCURS 10 WITH HEADER LINE,
        ubal TYPE c.
  LOOP AT iibkpf WHERE bukrs = pt001-bukrs.

    CLEAR ubal_bseg.
    REFRESH ubal_bseg.



    LOOP AT new_bseg WHERE bukrs = iibkpf-bukrs
                       AND belnr = iibkpf-belnr
                       AND gjahr = iibkpf-gjahr.
      APPEND new_bseg TO ubal_bseg.

    ENDLOOP.

SELECT * FROM bseg WHERE bukrs = iibkpf-bukrs
AND belnr = iibkpf-belnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*AND gjahr = iibkpf-gjahr.
AND GJAHR = IIBKPF-GJAHR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *

      READ TABLE ubal_bseg WITH KEY bukrs = bseg-bukrs
                               belnr = bseg-belnr
                               gjahr = bseg-gjahr
                               buzei = bseg-buzei.
      IF sy-subrc NE 0.
        APPEND bseg TO ubal_bseg.
        APPEND bseg TO new_bseg.
      ELSE.
        READ TABLE new_bseg WITH KEY bukrs = bseg-bukrs
                               belnr = bseg-belnr
                               gjahr = bseg-gjahr
                               buzei = bseg-buzei.
        IF sy-subrc = 0.
          MODIFY new_bseg FROM bseg INDEX sy-tabix.
        ENDIF.

      ENDIF.


    ENDSELECT.

    PERFORM zero_balance_check TABLES ubal_bseg
                     CHANGING ubal.
    DESCRIBE TABLE ubal_bseg LINES sy-tfill.

    IF ubal = 'X' OR sy-tfill < 1.
      exceptions-bukrs = iibkpf-bukrs.
      exceptions-belnr = iibkpf-belnr.
      exceptions-gjahr = iibkpf-gjahr.
      exceptions-buzei = '0'.
      IF ubal = 'X'.
        exceptions-key = '4'.
        iibkpf-repcd = 3.
      ELSE.
        exceptions-key = '5'.
        iibkpf-repcd = 2.
      ENDIF.
      exceptions-level = 'E'.
      APPEND exceptions.

      MODIFY iibkpf.



*        delete new_bseg where bukrs = iibkpf-bukrs
*                          and belnr = iibkpf-belnr
*                          and gjahr = iibkpf-gjahr.
*        delete iibkpf.
    ENDIF.



  ENDLOOP.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM final_checks                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IIBKPF                                                        *
*  -->  NEW_BSEG                                                      *
*  -->  PT001                                                         *
*---------------------------------------------------------------------*
FORM final_checks TABLES iibkpf STRUCTURE nbkpf
                                 new_bseg STRUCTURE bseg
                          USING  pt001 LIKE t001.

  DATA: ubal_bseg LIKE bseg OCCURS 10 WITH HEADER LINE,
        ubal TYPE c.
  LOOP AT iibkpf WHERE bukrs = pt001-bukrs.

    CLEAR ubal_bseg.
    REFRESH ubal_bseg.



    LOOP AT new_bseg WHERE bukrs = iibkpf-bukrs
                       AND belnr = iibkpf-belnr
                       AND gjahr = iibkpf-gjahr.
      APPEND new_bseg TO ubal_bseg.

    ENDLOOP.

SELECT * FROM bseg WHERE bukrs = iibkpf-bukrs
AND belnr = iibkpf-belnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*AND gjahr = iibkpf-gjahr.
AND GJAHR = IIBKPF-GJAHR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *

      READ TABLE ubal_bseg WITH KEY bukrs = bseg-bukrs
                               belnr = bseg-belnr
                               gjahr = bseg-gjahr
                               buzei = bseg-buzei.
      IF sy-subrc NE 0.
        APPEND bseg TO ubal_bseg.
        APPEND bseg TO new_bseg.
      ELSE.
        READ TABLE new_bseg WITH KEY bukrs = bseg-bukrs
                               belnr = bseg-belnr
                               gjahr = bseg-gjahr
                               buzei = bseg-buzei.
        IF sy-subrc = 0.
          MODIFY new_bseg FROM bseg INDEX sy-tabix.
        ENDIF.

      ENDIF.


    ENDSELECT.



    SORT ubal_bseg BY buzei.

    LOOP AT ubal_bseg.
      IF ubal_bseg-buzei NE sy-tabix.
        exceptions-bukrs = iibkpf-bukrs.
        exceptions-belnr = iibkpf-belnr.
        exceptions-gjahr = iibkpf-gjahr.
        exceptions-buzei = ubal_bseg-buzei.
        exceptions-key = '12'.
        iibkpf-repcd = 12.
        exceptions-level = 'E'.
        APPEND exceptions.
        MODIFY iibkpf.
      ENDIF.
    ENDLOOP.

    LOOP AT ubal_bseg.
      IF ( ubal_bseg-koart = 'K' AND
         ( ubal_bseg-lifnr IS INITIAL OR ubal_bseg-hkont IS INITIAL ) )
         OR
         ( ubal_bseg-koart = 'D' AND
         ( ubal_bseg-kunnr IS INITIAL OR ubal_bseg-hkont IS INITIAL ) )
         OR
         ( ( ubal_bseg-koart = 'S' OR ubal_bseg-koart = 'M' ) AND
         ubal_bseg-hkont IS INITIAL ).

        exceptions-bukrs = iibkpf-bukrs.
        exceptions-belnr = iibkpf-belnr.
        exceptions-gjahr = iibkpf-gjahr.
        exceptions-buzei = ubal_bseg-buzei.
        exceptions-key = '11'.
        iibkpf-repcd = 11.
        exceptions-level = 'E'.
        APPEND exceptions.
        MODIFY iibkpf.
      ENDIF.
    ENDLOOP.

  ENDLOOP.



  SORT iibkpf BY bukrs belnr gjahr.
  SORT new_bseg BY bukrs belnr gjahr buzei.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM template_select                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PNEW_BSEG                                                     *
*---------------------------------------------------------------------*
FORM template_select CHANGING pnew_bseg LIKE bseg.

  IF has_template = 'X'.
*          **********************************************************
*          select template using buzei:
*          other kinds of template selection can be implemented here
*          **********************************************************
    READ TABLE template_bseg WITH KEY buzei = pnew_bseg-buzei.
    IF sy-subrc = 0.
      pnew_bseg = template_bseg.
    ELSE.
*          *********************************************************
*          do some other selection here:
*           read table template_bseg with key abc = pnew_bseg-xyz.
*           if sy-subrc = 0.
*              pnew_bseg = template_bseg.
*           else.
*           .....
*           endif.
*          *********************************************************
    ENDIF.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM tabix_new_bseg                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_NEW_BSEG                                                    *
*  -->  PPBSEG                                                        *
*  -->  TABIX_NEW_BSEG                                                *
*---------------------------------------------------------------------*
FORM tabix_new_bseg TABLES p_new_bseg STRUCTURE bseg
                     USING ppbseg LIKE bseg
                  CHANGING tabix_new_bseg LIKE sy-tabix.

  READ TABLE p_new_bseg WITH KEY bukrs = ppbseg-bukrs
                                 belnr = ppbseg-belnr
                                 gjahr = ppbseg-gjahr
                                 buzei = ppbseg-buzei.
  IF sy-subrc = 0.
    tabix_new_bseg = sy-tabix.
  ELSE.
    tabix_new_bseg = 0.
  ENDIF.


ENDFORM.

*---------------------------------------------------------------------*
*       FORM create_new_headers                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IIBKPF                                                        *
*  -->  NEW_BKPF                                                      *
*  -->  PT001                                                         *
*---------------------------------------------------------------------*
FORM create_new_headers TABLES iibkpf STRUCTURE nbkpf
                               new_bkpf STRUCTURE bkpf
                         USING pt001 LIKE t001.


  IF xrfc = 'X'.
    PERFORM create_new_headers_rfc TABLES iibkpf new_bkpf
                                     USING pt001.
    EXIT.
  ENDIF.

  IF xvbtab = 'X'.
    PERFORM create_new_headers_rfvb TABLES iibkpf new_bkpf
                                     USING pt001.

    EXIT.
  ENDIF.

  DATA ibseg LIKE bseg OCCURS 10 WITH HEADER LINE.
  DATA found_it TYPE c.
  LOOP AT iibkpf WHERE bukrs = pt001-bukrs.
*    ***************************************
*    select all bseg entries with line
*    item display set for one missing
*    bkpf entry and select a corresponding
*    index if possible
*    ***************************************



    PERFORM get_bseg_for_index TABLES ibseg
                                USING iibkpf
                             CHANGING found_it.
    IF found_it IS INITIAL.
      exceptions-bukrs = iibkpf-bukrs.
      exceptions-belnr = iibkpf-belnr.
      exceptions-gjahr = iibkpf-gjahr.
      exceptions-buzei = '0'.
      exceptions-key = '2'.
      exceptions-level = 'E'.
      APPEND exceptions.
*        delete iibkpf.
      iibkpf-repcd = 4.
      MODIFY iibkpf.
      CONTINUE.
    ENDIF.

    PERFORM get_index_from_bseg TABLES ibseg
                                       new_bkpf
                                 USING iibkpf
                                       pt001
                              CHANGING found_it.
    IF found_it IS INITIAL.
      IF has_template IS INITIAL.
*          *********************************************
*          no index exists and no template was used: ->
*          can't create header
*          *********************************************
        exceptions-bukrs = iibkpf-bukrs.
        exceptions-belnr = iibkpf-belnr.
        exceptions-gjahr = iibkpf-gjahr.
        exceptions-buzei = '0'.
        exceptions-key = '1'.
        exceptions-level = 'E'.
        APPEND exceptions.
        iibkpf-repcd = 5.
        MODIFY iibkpf.
*           delete iibkpf.
      ELSE.
*          *********************************************
*          no index exists and but template was used: ->
*          create header with warning
*          *********************************************
        exceptions-bukrs = iibkpf-bukrs.
        exceptions-belnr = iibkpf-belnr.
        exceptions-gjahr = iibkpf-gjahr.
        exceptions-buzei = '0'.
        exceptions-key = '3'.
        exceptions-level = 'W'.
        APPEND exceptions.
        PERFORM substitute_fields_bkpf USING pt001
                                    CHANGING new_bkpf.
        new_bkpf-bukrs = iibkpf-bukrs.
        new_bkpf-belnr = iibkpf-belnr.
        new_bkpf-gjahr = iibkpf-gjahr.
        APPEND new_bkpf.
      ENDIF.

    ENDIF.



  ENDLOOP.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM get_index_from_bseg                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IBSEG                                                         *
*  -->  NEW_BKPF                                                      *
*  -->  IIBKPF                                                        *
*  -->  PT001                                                         *
*  -->  FOUND_IT                                                      *
*---------------------------------------------------------------------*
FORM get_index_from_bseg TABLES ibseg STRUCTURE bseg
                                new_bkpf STRUCTURE bkpf
                          USING iibkpf TYPE tbkpf
                                pt001 LIKE t001
                       CHANGING found_it TYPE c.
  CLEAR found_it.
  LOOP AT ibseg.
    PERFORM select_single_index TABLES new_bkpf
                                 USING ibseg
                                       pt001
                                 CHANGING found_it.
    IF found_it = 'X'.
      EXIT.
    ENDIF.

  ENDLOOP.


ENDFORM.

*---------------------------------------------------------------------*
*       FORM complete_bkpf                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PT001                                                         *
*  -->  PBKPF                                                         *
*---------------------------------------------------------------------*
FORM complete_bkpf USING pt001 LIKE t001
                CHANGING pbkpf LIKE bkpf.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t003 WHERE blart = pbkpf-blart.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t003 WHERE blart = pbkpf-blart ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc = 0.
    pbkpf-xnetb = t003-xnetb.
  ENDIF.

  pbkpf-hwaer = pt001-waers.


  IF pbkpf-usnam IS INITIAL.
    pbkpf-usnam = sy-uname.

  ENDIF.


  PERFORM get_hw2_3 USING pt001
            CHANGING pbkpf-hwae2
                     pbkpf-hwae3.

  PERFORM get_kurs123 USING pt001
                   CHANGING pbkpf.


  IF has_template IS INITIAL.
    pbkpf-cpudt = pbkpf-budat.
    pbkpf-cputm = sy-uzeit.
  ENDIF.


ENDFORM.

*---------------------------------------------------------------------*
*       FORM substitute_fields_bkpf                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PT001                                                         *
*  -->  PBKPF                                                         *
*---------------------------------------------------------------------*
FORM substitute_fields_bkpf USING pt001 LIKE t001
                         CHANGING pbkpf LIKE bkpf.
  CLEAR pbkpf.
  IF has_template = 'X'.
    pbkpf = template_bkpf.
  ENDIF.
  pbkpf-bktxt = 'Recreated by SAP'.
  pbkpf-awkey = yawkey.
  pbkpf-bvorg = ybvorg.
  pbkpf-xblnr = yxblnr.


ENDFORM.

*---------------------------------------------------------------------*
*       FORM select_single_index                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  NEW_BKPF                                                      *
*  -->  PIBSEG                                                        *
*  -->  PT001                                                         *
*  -->  FOUND                                                         *
*---------------------------------------------------------------------*
FORM select_single_index TABLES new_bkpf STRUCTURE bkpf
                                   USING pibseg LIKE bseg
                                         pt001 LIKE t001
                                   CHANGING found TYPE c.
  CLEAR found.

  IF pibseg-koart CA 'DKA'.

    IF pibseg-koart = 'D'.
      IF pibseg-augbl IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM bsid
*             WHERE  bukrs  = pibseg-bukrs
*             AND    kunnr  = pibseg-kunnr
*             AND    umsks  = pibseg-umsks
*             AND    umskz  = pibseg-umskz
*             AND    augdt  = pibseg-augdt
*             AND    augbl  = pibseg-augbl
*             AND    zuonr  = pibseg-zuonr
*             AND    gjahr  = pibseg-gjahr
*             AND    belnr  = pibseg-belnr
*             AND    buzei  = pibseg-buzei.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM bsid
             WHERE  bukrs  = pibseg-bukrs
             AND    kunnr  = pibseg-kunnr
             AND    umsks  = pibseg-umsks
             AND    umskz  = pibseg-umskz
             AND    augdt  = pibseg-augdt
             AND    augbl  = pibseg-augbl
             AND    zuonr  = pibseg-zuonr
             AND    gjahr  = pibseg-gjahr
             AND    belnr  = pibseg-belnr
             AND    buzei  = pibseg-buzei ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc = 0.
          PERFORM substitute_fields_bkpf USING pt001
                                      CHANGING new_bkpf.
          MOVE-CORRESPONDING bsid TO new_bkpf.

          PERFORM complete_bkpf USING pt001
                             CHANGING new_bkpf.
          APPEND new_bkpf.
          found = 'X'.
          EXIT.
        ENDIF.
      ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM bsad
*             WHERE  bukrs  = pibseg-bukrs
*             AND    kunnr  = pibseg-kunnr
*             AND    umsks  = pibseg-umsks
*             AND    umskz  = pibseg-umskz
*             AND    augdt  = pibseg-augdt
*             AND    augbl  = pibseg-augbl
*             AND    zuonr  = pibseg-zuonr
*             AND    gjahr  = pibseg-gjahr
*             AND    belnr  = pibseg-belnr
*             AND    buzei  = pibseg-buzei.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM bsad
             WHERE  bukrs  = pibseg-bukrs
             AND    kunnr  = pibseg-kunnr
             AND    umsks  = pibseg-umsks
             AND    umskz  = pibseg-umskz
             AND    augdt  = pibseg-augdt
             AND    augbl  = pibseg-augbl
             AND    zuonr  = pibseg-zuonr
             AND    gjahr  = pibseg-gjahr
             AND    belnr  = pibseg-belnr
             AND    buzei  = pibseg-buzei ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc = 0.
          PERFORM substitute_fields_bkpf USING pt001
                                      CHANGING new_bkpf.
          MOVE-CORRESPONDING bsad TO new_bkpf.
          PERFORM complete_bkpf USING pt001
                             CHANGING new_bkpf.
          APPEND new_bkpf.
          found = 'X'.
          EXIT.
        ENDIF.

      ENDIF.
    ENDIF.

    IF pibseg-koart = 'K'.
      IF pibseg-augbl IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM bsik
*             WHERE  bukrs  = pibseg-bukrs
*             AND    lifnr  = pibseg-lifnr
*             AND    umsks  = pibseg-umsks
*             AND    umskz  = pibseg-umskz
*             AND    augdt  = pibseg-augdt
*             AND    augbl  = pibseg-augbl
*             AND    zuonr  = pibseg-zuonr
*             AND    gjahr  = pibseg-gjahr
*             AND    belnr  = pibseg-belnr
*             AND    buzei  = pibseg-buzei.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM bsik
             WHERE  bukrs  = pibseg-bukrs
             AND    lifnr  = pibseg-lifnr
             AND    umsks  = pibseg-umsks
             AND    umskz  = pibseg-umskz
             AND    augdt  = pibseg-augdt
             AND    augbl  = pibseg-augbl
             AND    zuonr  = pibseg-zuonr
             AND    gjahr  = pibseg-gjahr
             AND    belnr  = pibseg-belnr
             AND    buzei  = pibseg-buzei ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc = 0.
          PERFORM substitute_fields_bkpf USING pt001
                                      CHANGING new_bkpf.
          MOVE-CORRESPONDING bsik TO new_bkpf.
          PERFORM complete_bkpf USING pt001
                             CHANGING new_bkpf.
          APPEND new_bkpf.
          found = 'X'.
          EXIT.
        ENDIF.
      ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM bsak
*             WHERE  bukrs  = pibseg-bukrs
*             AND    lifnr  = pibseg-lifnr
*             AND    umsks  = pibseg-umsks
*             AND    umskz  = pibseg-umskz
*             AND    augdt  = pibseg-augdt
*             AND    augbl  = pibseg-augbl
*             AND    zuonr  = pibseg-zuonr
*             AND    gjahr  = pibseg-gjahr
*             AND    belnr  = pibseg-belnr
*             AND    buzei  = pibseg-buzei.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM bsak
             WHERE  bukrs  = pibseg-bukrs
             AND    lifnr  = pibseg-lifnr
             AND    umsks  = pibseg-umsks
             AND    umskz  = pibseg-umskz
             AND    augdt  = pibseg-augdt
             AND    augbl  = pibseg-augbl
             AND    zuonr  = pibseg-zuonr
             AND    gjahr  = pibseg-gjahr
             AND    belnr  = pibseg-belnr
             AND    buzei  = pibseg-buzei ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc = 0.
          PERFORM substitute_fields_bkpf USING pt001
                                      CHANGING new_bkpf.
          MOVE-CORRESPONDING bsak TO new_bkpf.
          PERFORM complete_bkpf USING pt001
                             CHANGING new_bkpf.
          APPEND new_bkpf.
          found = 'X'.
          EXIT.
        ENDIF.

      ENDIF.
    ENDIF.

    IF pibseg-xhres = 'X'.
      IF pibseg-augbl IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM bsis
*        WHERE  bukrs  = pibseg-bukrs
*        AND    hkont  = pibseg-hkont
*        AND    augdt  = pibseg-augdt
*        AND    augbl  = pibseg-augbl
*        AND    zuonr  = pibseg-hzuon
*        AND    gjahr  = pibseg-gjahr
*        AND    belnr  = pibseg-belnr
*        AND    buzei  = pibseg-buzei.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM bsis
        WHERE  bukrs  = pibseg-bukrs
        AND    hkont  = pibseg-hkont
        AND    augdt  = pibseg-augdt
        AND    augbl  = pibseg-augbl
        AND    zuonr  = pibseg-hzuon
        AND    gjahr  = pibseg-gjahr
        AND    belnr  = pibseg-belnr
        AND    buzei  = pibseg-buzei ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc = 0.
          PERFORM substitute_fields_bkpf USING pt001
                                      CHANGING new_bkpf.
          MOVE-CORRESPONDING bsis TO new_bkpf.
          PERFORM complete_bkpf USING pt001
                             CHANGING new_bkpf.
          APPEND new_bkpf.
          found = 'X'.
          EXIT.
        ENDIF.
      ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM bsas
*          WHERE  bukrs  = pibseg-bukrs
*          AND    hkont  = pibseg-hkont
*          AND    augdt  = pibseg-augdt
*          AND    augbl  = pibseg-augbl
*          AND    zuonr  = pibseg-hzuon
*          AND    gjahr  = pibseg-gjahr
*          AND    belnr  = pibseg-belnr
*          AND    buzei  = pibseg-buzei.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM bsas
          WHERE  bukrs  = pibseg-bukrs
          AND    hkont  = pibseg-hkont
          AND    augdt  = pibseg-augdt
          AND    augbl  = pibseg-augbl
          AND    zuonr  = pibseg-hzuon
          AND    gjahr  = pibseg-gjahr
          AND    belnr  = pibseg-belnr
          AND    buzei  = pibseg-buzei ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc = 0.
          PERFORM substitute_fields_bkpf USING pt001
                                      CHANGING new_bkpf.
          MOVE-CORRESPONDING bsas TO new_bkpf.
          PERFORM complete_bkpf USING pt001
                             CHANGING new_bkpf.
          APPEND new_bkpf.
          found = 'X'.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.


  ELSEIF pibseg-koart CA 'SM'.

    IF pibseg-xkres = 'X'.
      IF pibseg-augbl IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM bsis
*        WHERE  bukrs  = pibseg-bukrs
*        AND    hkont  = pibseg-hkont
*        AND    augdt  = pibseg-augdt
*        AND    augbl  = pibseg-augbl
*        AND    zuonr  = pibseg-zuonr
*        AND    gjahr  = pibseg-gjahr
*        AND    belnr  = pibseg-belnr
*        AND    buzei  = pibseg-buzei.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM bsis
        WHERE  bukrs  = pibseg-bukrs
        AND    hkont  = pibseg-hkont
        AND    augdt  = pibseg-augdt
        AND    augbl  = pibseg-augbl
        AND    zuonr  = pibseg-zuonr
        AND    gjahr  = pibseg-gjahr
        AND    belnr  = pibseg-belnr
        AND    buzei  = pibseg-buzei ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc = 0.
          CLEAR new_bkpf.
          PERFORM substitute_fields_bkpf USING pt001
                                      CHANGING new_bkpf.
          MOVE-CORRESPONDING bsis TO new_bkpf.
          PERFORM complete_bkpf USING pt001
                             CHANGING new_bkpf.
          APPEND new_bkpf.
          found = 'X'.
          EXIT.
        ENDIF.
      ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM bsas
*          WHERE  bukrs  = pibseg-bukrs
*          AND    hkont  = pibseg-hkont
*          AND    augdt  = pibseg-augdt
*          AND    augbl  = pibseg-augbl
*          AND    zuonr  = pibseg-zuonr
*          AND    gjahr  = pibseg-gjahr
*          AND    belnr  = pibseg-belnr
*          AND    buzei  = pibseg-buzei.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM bsas
          WHERE  bukrs  = pibseg-bukrs
          AND    hkont  = pibseg-hkont
          AND    augdt  = pibseg-augdt
          AND    augbl  = pibseg-augbl
          AND    zuonr  = pibseg-zuonr
          AND    gjahr  = pibseg-gjahr
          AND    belnr  = pibseg-belnr
          AND    buzei  = pibseg-buzei ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc = 0.
          CLEAR new_bkpf.
          PERFORM substitute_fields_bkpf USING pt001
                                      CHANGING new_bkpf.
          MOVE-CORRESPONDING bsas TO new_bkpf.
          PERFORM complete_bkpf USING pt001
                             CHANGING new_bkpf.
          APPEND new_bkpf.
          found = 'X'.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF.





ENDFORM.



*---------------------------------------------------------------------*
*       FORM get_bseg_for_index                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IBSEG                                                         *
*  -->  PPBKPF                                                        *
*  -->  FOUND_IT                                                      *
*---------------------------------------------------------------------*
FORM get_bseg_for_index TABLES ibseg STRUCTURE bseg
                                 USING ppbkpf TYPE tbkpf
                              CHANGING found_it TYPE c.
* **********************************************
* select all bseg entries with line item display
* and put them in ibseg
* **********************************************
  CLEAR found_it.
SELECT * FROM bseg INTO TABLE ibseg WHERE bukrs = ppbkpf-bukrs
AND belnr = ppbkpf-belnr
AND gjahr = ppbkpf-gjahr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*AND ( xkres = 'X' OR xhres = 'X' ).
AND ( XKRES = 'X' OR XHRES = 'X' ) ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
  DESCRIBE TABLE ibseg LINES sy-tfill.
  CHECK sy-tfill GT 0.

  found_it = 'X'.




ENDFORM.


*---------------------------------------------------------------------*
*       FORM write_miss_item                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  IIBKPF                                                        *
*---------------------------------------------------------------------*
FORM write_miss_item TABLES iibkpf STRUCTURE nbkpf.
  NEW-LINE.
  ULINE (112).
  FORMAT COLOR COL_HEADING.
  WRITE:/ sy-vline,
             'BUKR',
             '  FI-BELNR',
             'YEAR',
             'Type of Err',
             112 sy-vline.

  NEW-LINE.
  ULINE (112).
  FORMAT COLOR COL_NORMAL.
  LOOP AT iibkpf.
    WRITE:/ sy-vline,
            iibkpf-bukrs,
            iibkpf-belnr,
            iibkpf-gjahr.
    CASE iibkpf-errcd.
      WHEN '1'.
        WRITE 'BKPF_MISSING'.
      WHEN '2'.
        WRITE 'BSEG_MISSING'.
      WHEN '3'.
        WRITE 'BSEG_UNBALANCED'.

    ENDCASE.
    WRITE: 112 sy-vline.


  ENDLOOP.
  DESCRIBE TABLE iibkpf LINES sy-tfill.
  IF sy-tfill = 0.
    WRITE:/ sy-vline,
            '***** No errors found *****',
            112 sy-vline.
  ENDIF.
  NEW-LINE.
  ULINE (112).

ENDFORM.

*---------------------------------------------------------------------*
*       FORM write_exceptions                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM write_exceptions.
  DESCRIBE TABLE exceptions LINES sy-tfill.
  DATA messagestring(25) TYPE c.
  NEW-LINE.
  ULINE (112).
  FORMAT COLOR COL_HEADING.
  WRITE:/ sy-vline,
          (108) 'Exception List',
          sy-vline.
  NEW-LINE.
  ULINE (112).
  FORMAT COLOR COL_NORMAL.
  IF sy-tfill = 0.
    WRITE:/ sy-vline,
            (108) '**** No Exceptions and Warnings ****',
            sy-vline.

  ENDIF.


  LOOP AT exceptions.
    PERFORM messageid_to_string USING exceptions-key
                   CHANGING messagestring.
    WRITE:/ sy-vline,
     exceptions-level,
     exceptions-bukrs,
     exceptions-belnr,
     exceptions-gjahr.
    IF exceptions-buzei GT 0.
      WRITE exceptions-buzei.
    ENDIF.
    WRITE: messagestring,
    112 sy-vline.
  ENDLOOP.
  NEW-LINE.
  ULINE (112).
  FORMAT COLOR COL_TOTAL.
  WRITE:/ sy-vline,
          'Number of Exceptions',
          sy-tfill,
          112 sy-vline.
  NEW-LINE.
  ULINE (112).
  FORMAT COLOR OFF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM messageid_to_string                                      *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PID                                                           *
*  -->  MESS                                                          *
*---------------------------------------------------------------------*
FORM messageid_to_string USING pid TYPE i
                      CHANGING mess TYPE c.
* *****************************************
* Translate the message key (number) to
* a readable string
* *****************************************

  CASE pid.
    WHEN '1'.
      mess = 'NO_INDEX_FOUND'.
    WHEN '2'.
      mess = 'NO_BSEG_FOUND'.
    WHEN '3'.
      mess = 'HEADER_CREATED W/O INDEX'.
    WHEN '4'.
      mess = 'DOCUMENT_UNBALANCED'.
    WHEN '5'.
      mess = 'NO_POSITIONS_FOUND'.
    WHEN '6'.
      mess = 'MODIFY_BKPF_FAILED'.
    WHEN '7'.
      mess = 'MODIFY_BSEG_FAILED'.
    WHEN '8'.
      mess = 'NOT_FOUND_IN_REMOTE_SYSTEM'.
    WHEN '9'.
      mess = 'MODIFY_RFBLG_FAILED'.
    WHEN '10'.
      mess = 'RFC_FAILED'.
    WHEN '11'.
      mess = 'Initial Account Number'.
    WHEN '12'.
      mess = 'Missing Positions'.






  ENDCASE.


ENDFORM.



*---------------------------------------------------------------------*
*       FORM test_screen                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM test_screen.
  PERFORM select_template.
  PERFORM test_rfc_fields.
  PERFORM test_vb_fields.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM test_vb_fields                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM test_vb_fields.
  IF xvbtab = 'X' AND pvbkey IS INITIAL.
    MESSAGE e000 WITH
    'VBKEY needed'.
    EXIT.
  ENDIF.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM test_rfc_fields                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM test_rfc_fields.
  IF xrfc = 'X'.
    IF src_sys IS INITIAL OR src_cli IS INITIAL.
      MESSAGE e000 WITH
      'Remote System and Client needed'.
      EXIT.
    ENDIF.

  ENDIF.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM select_template                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM select_template.
  DATA: tembkpf LIKE bkpf.
  CLEAR has_template.
  IF NOT tbelnr IS INITIAL.
    tembkpf-belnr = tbelnr.
    tembkpf-bukrs = tbukrs.
    tembkpf-gjahr = tgjahr.
    IF tembkpf-bukrs IS INITIAL OR tembkpf-gjahr IS INITIAL.
      MESSAGE e000 WITH
      'Cpcd and/or fiscal year for template document'
                                 tembkpf-belnr 'needed'.
    ENDIF.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM bkpf INTO template_bkpf
*                                   WHERE bukrs = tembkpf-bukrs
*                                     AND belnr = tembkpf-belnr
*                                     AND gjahr = tembkpf-gjahr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM bkpf INTO template_bkpf
                                   WHERE bukrs = tembkpf-bukrs
                                     AND belnr = tembkpf-belnr
                                     AND gjahr = tembkpf-gjahr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc NE 0.
      MESSAGE e000 WITH 'No Template BKPF found for'
      tembkpf-bukrs tembkpf-belnr tembkpf-gjahr.
    ELSE.
      has_template = 'X'.
    ENDIF.
    IF rbseg = 'X'.
SELECT * FROM bseg INTO TABLE template_bseg
WHERE bukrs = tembkpf-bukrs
AND belnr = tembkpf-belnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*AND gjahr = tembkpf-gjahr.
AND GJAHR = TEMBKPF-GJAHR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
      IF sy-subrc NE 0.
        MESSAGE e000 WITH 'No Template BSEG found for'
        tembkpf-bukrs tembkpf-belnr tembkpf-gjahr.
      ELSE.
        has_template = 'X'.
      ENDIF.
    ENDIF.

  ENDIF.

ENDFORM.

DEFINE write_bkpf_field.
  format color col_normal.
  write:/ sy-vline,
          '&2', (102) &1-&2,
          sy-vline.
  format color off.
END-OF-DEFINITION.

*---------------------------------------------------------------------*
*       FORM insert_missing_headers                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM insert_missing_headers.
*   ***********************************
*   Insert to BKPF
*   ***********************************


  DATA badsysubrc TYPE c.
  LOOP AT global_nbkpf WHERE repcd = 0.
    CLEAR badsysubrc.
    LOOP AT global_bkpf WHERE bukrs = global_nbkpf-bukrs
                          AND belnr = global_nbkpf-belnr
                          AND gjahr = global_nbkpf-gjahr.

      MODIFY bkpf FROM global_bkpf.
      IF sy-subrc NE 0.
        badsysubrc = 'X'.
        exceptions-bukrs = global_bkpf-bukrs.
        exceptions-belnr = global_bkpf-belnr.
        exceptions-gjahr = global_bkpf-gjahr.
        exceptions-buzei = '0'.
        exceptions-key = '6'.
        exceptions-level = 'E'.
        APPEND exceptions.
      ENDIF.
    ENDLOOP.
    IF badsysubrc = 'X'.
      global_nbkpf-repcd = -2.
    ELSE.
      global_nbkpf-repcd = -1.
    ENDIF.
    MODIFY global_nbkpf.

  ENDLOOP.
*   ***********************************
*   Write the output
*   ***********************************
*    perform write_inserted_bkpfs.

  LOOP AT global_t001.
    PERFORM write_new_headers TABLES global_bkpf
                                     global_nbkpf
                               USING global_t001.
  ENDLOOP.

*   **********************************
*   After the insert data in
*   global_bkpf are not needed anymore
*   **********************************
  CLEAR global_bkpf.
  REFRESH global_bkpf.

  CLEAR hbseg.
  CLEAR hbkpf.
  CLEAR h_index.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM insert_missing_bsegs                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM insert_missing_bsegs.
*   ***********************************
*   Insert to BSEG
*   ***********************************
  DATA badsysubrc TYPE c.
  LOOP AT global_nbkpf WHERE repcd = 0.

    CLEAR badsysubrc.
    IF xrfc IS INITIAL.
      LOOP AT global_bseg WHERE bukrs = global_nbkpf-bukrs
                            AND belnr = global_nbkpf-belnr
                            AND gjahr = global_nbkpf-gjahr.

        MODIFY bseg FROM global_bseg.
        IF sy-subrc NE 0.
          badsysubrc = 'X'.
          exceptions-bukrs = global_bseg-bukrs.
          exceptions-belnr = global_bseg-belnr.
          exceptions-gjahr = global_bseg-gjahr.
          exceptions-buzei = global_bseg-buzei.
          exceptions-key = '7'.
          exceptions-level = 'E'.
          APPEND exceptions.
        ENDIF.

      ENDLOOP.
*        ************************************
*        ** Create Bset:
*        ************************************
      IF cbset = 'X'.
      PERFORM create_bset USING global_nbkpf.
      ENDIF.

    ELSE.
      LOOP AT global_rfblg WHERE bukrs = global_nbkpf-bukrs
                             AND belnr = global_nbkpf-belnr
                             AND gjahr = global_nbkpf-gjahr.
        MODIFY rfblg FROM global_rfblg.
        IF sy-subrc NE 0.
          badsysubrc = 'X'.
          exceptions-bukrs = global_rfblg-bukrs.
          exceptions-belnr = global_rfblg-belnr.
          exceptions-gjahr = global_rfblg-gjahr.
          exceptions-buzei = global_rfblg-pageno.
          exceptions-key = '9'.
          exceptions-level = 'E'.
          APPEND exceptions.
        ENDIF.


      ENDLOOP.

    ENDIF.
    IF badsysubrc = 'X'.
      global_nbkpf-repcd = -2.
    ELSE.
      global_nbkpf-repcd = -1.
    ENDIF.
    MODIFY global_nbkpf.
  ENDLOOP.

*   ***********************************
*   Write the output
*   ***********************************
*    perform write_inserted_bsegs.
  LOOP AT global_t001.
    PERFORM write_new_positions TABLES global_nbkpf
                                       global_bseg
                                 USING global_t001.
  ENDLOOP.

*   **********************************
*   After the insert data in
*   global_bkpf are not needed anymore
*   **********************************
  CLEAR global_bseg.
  REFRESH global_bseg.

  CLEAR global_nbkpf.
  REFRESH global_nbkpf.

  CLEAR hbseg.
  CLEAR hbkpf.
  CLEAR h_index.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM create_bset                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PNBKPF                                                        *
*---------------------------------------------------------------------*
FORM create_bset USING pnbkpf LIKE nbkpf.
*  ******************************
*  Create bseg for one Document:
*  ******************************
  DATA xbset LIKE bset OCCURS 0 WITH HEADER LINE.
  PERFORM create_ibset TABLES xbset
                        USING pnbkpf.


  DESCRIBE TABLE xbset LINES sy-tfill.
  IF sy-tfill GT 0.
    DELETE FROM bset WHERE bukrs = pnbkpf-bukrs
                       AND belnr = pnbkpf-belnr
                       AND gjahr = pnbkpf-gjahr.
    INSERT bset FROM TABLE xbset.
  ENDIF.






ENDFORM.

*---------------------------------------------------------------------*
*       FORM write_bset                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PIBSET                                                        *
*  -->  PNBKPF                                                        *
*---------------------------------------------------------------------*
FORM write_bset TABLES pibset STRUCTURE bset
                   USING pnbkpf LIKE nbkpf.

  FORMAT COLOR COL_NORMAL.
  FORMAT INTENSIFIED OFF.
  DESCRIBE TABLE pibset LINES sy-tfill.
  NEW-LINE.
  ULINE (112).
  IF sy-tfill GT 0.
    LOOP AT pibset.
      WRITE:/ sy-vline,
              'BSET',
              pibset-buzei,
              pibset-mwskz,
              pibset-ktosl,
              pibset-hkont,
              pibset-shkzg,
              pibset-hwbas,
              pibset-hwste,
              112 sy-vline.

    ENDLOOP.
  ELSE.
    WRITE:/ sy-vline,
            'BSET',
            'Nothing to be created',
            112 sy-vline.
  ENDIF.
  FORMAT COLOR COL_NORMAL.
  FORMAT INTENSIFIED ON.



ENDFORM.


*---------------------------------------------------------------------*
*       FORM create_ibset                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PIBSET                                                        *
*  -->  PNBKPF                                                        *
*---------------------------------------------------------------------*
FORM create_ibset TABLES pibset STRUCTURE bset
                   USING pnbkpf LIKE nbkpf.

  REFRESH pibset.
  CLEAR pibset.
*  ******************************
*  Create bseg for one Document:
*  ******************************
  DATA xbkpf LIKE bkpf OCCURS 0 WITH HEADER LINE.
  DATA xbseg LIKE bseg OCCURS 0 WITH HEADER LINE.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM bkpf INTO xbkpf WHERE bukrs = pnbkpf-bukrs
*                                         AND belnr = pnbkpf-belnr
*                                         AND gjahr = pnbkpf-gjahr.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM bkpf INTO xbkpf WHERE bukrs = pnbkpf-bukrs
                                         AND belnr = pnbkpf-belnr
                                         AND gjahr = pnbkpf-gjahr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  CHECK sy-subrc = 0.


* to get recalculation in 4.6B
  IF xbkpf-awtyp NE 'RFBU'.
    xbkpf-awtyp = 'WBRK'.            " no calculation of discount base
  ENDIF.
  IF xbkpf-tcode = 'MRKO'.
    xbkpf-tcode = 'FB01'.
  ENDIF.
  IF xbkpf-glvor = 'SD00'.
    xbkpf-glvor = 'RFBU'.
  ENDIF.
  xbkpf-xmwst = 'X'.                 "calculate tax
  xbkpf-xsnet = 'X'.                 "calculate tax using net amounts

  APPEND xbkpf.




  LOOP AT global_bseg WHERE bukrs = pnbkpf-bukrs
                        AND belnr = pnbkpf-belnr
                        AND gjahr = pnbkpf-gjahr.
    APPEND global_bseg TO xbseg .

  ENDLOOP.


  CALL FUNCTION 'FI_TAX_CALCULATION'
*    EXPORTING
*      I_XALE              =
*      I_RWBSET_HEAD       =
    TABLES
      t_bkpf              = xbkpf
      t_bseg              = xbseg
      t_bset              = pibset
*      T_RWBSET            =
            .
ENDFORM.

*---------------------------------------------------------------------*
*       FORM write_inserted_bsegs                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM write_inserted_bsegs.
  LOOP AT global_bseg.
    ON CHANGE OF global_bseg-belnr.
      NEW-LINE.
      ULINE (112).
      FORMAT COLOR COL_HEADING.
      WRITE:/ sy-vline,
              global_bseg-bukrs,
              global_bseg-belnr,
              global_bseg-gjahr,
              112 sy-vline.
    ENDON.
    FORMAT COLOR COL_NORMAL.
    WRITE:/ sy-vline,
            global_bseg-buzei,
            global_bseg-augdt,
            global_bseg-augbl,
            global_bseg-gsber,
            global_bseg-shkzg,
            global_bseg-bschl,
            global_bseg-wrbtr,
            global_bseg-dmbtr,
            global_bseg-hkont,
            global_bseg-kunnr,
            global_bseg-lifnr,
            112 sy-vline.



  ENDLOOP.
  NEW-LINE.
  ULINE (112).
  FORMAT COLOR OFF.


ENDFORM.

*---------------------------------------------------------------------*
*       FORM write_inserted_bkpfs                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM write_inserted_bkpfs.

  DATA idx TYPE i.
  LOOP AT global_bkpf.
    IF idx = 0.
      NEW-LINE.
      ULINE (112).
    ENDIF.
    FORMAT COLOR COL_POSITIVE.
    WRITE: / sy-vline,
             (87) 'Created BKPF in update mode',
             global_bkpf-bukrs,
             global_bkpf-belnr,
             global_bkpf-gjahr,
             sy-vline.
    NEW-LINE.
    ULINE (112).

    PERFORM write_doc_header USING global_bkpf.

    NEW-LINE.
    ULINE (112).

    ADD 1 TO idx.


  ENDLOOP.

  FORMAT COLOR COL_TOTAL.
  WRITE: / sy-vline,
           (23) 'SY-SUBRC',
           sy-subrc,
           112 sy-vline.
  WRITE: / sy-vline,
           (23) 'Number entries inserted',
           sy-dbcnt,
           112 sy-vline.
  NEW-LINE.
  ULINE (112).

ENDFORM.


*---------------------------------------------------------------------*
*       FORM write_doc_header                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PBKPF                                                         *
*---------------------------------------------------------------------*
FORM write_doc_header USING pbkpf LIKE bkpf.
*       write_bkpf_field pbkpf bukrs.
*       write_bkpf_field pbkpf belnr.
*       write_bkpf_field pbkpf gjahr.
  write_bkpf_field pbkpf blart.
  write_bkpf_field pbkpf budat.
  write_bkpf_field pbkpf monat.
  write_bkpf_field pbkpf tcode.
  write_bkpf_field pbkpf bvorg.
  write_bkpf_field pbkpf xblnr.
  write_bkpf_field pbkpf waers.
  write_bkpf_field pbkpf bstat.
  write_bkpf_field pbkpf glvor.
  write_bkpf_field pbkpf awtyp.
  write_bkpf_field pbkpf awkey.
  write_bkpf_field pbkpf awsys.
  write_bkpf_field pbkpf bktxt.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM write_new_headers                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PBKPF                                                         *
*  -->  IIBKPF                                                        *
*  -->  PT001                                                         *
*---------------------------------------------------------------------*
FORM write_new_headers TABLES pbkpf STRUCTURE bkpf
                              iibkpf STRUCTURE nbkpf
                        USING pt001 LIKE t001.

  LOOP AT pbkpf WHERE bukrs = pt001-bukrs.
    READ TABLE iibkpf WITH KEY  bukrs = pbkpf-bukrs
                                belnr = pbkpf-belnr
                                gjahr = pbkpf-gjahr.
    IF sy-subrc = 0.
      NEW-LINE.
      ULINE (112).
      FORMAT COLOR COL_HEADING.
      WRITE: / sy-vline,
               'Simulated BKPF',
               pbkpf-bukrs,
               pbkpf-belnr,
               pbkpf-gjahr.
      CASE iibkpf-repcd.
        WHEN 0.
          WRITE: 'Header can be reconstructed'.
        WHEN 4.
          WRITE: 'Header cannot be recreated: No BSEG found'
                  COLOR COL_NEGATIVE.
        WHEN 5.
          WRITE: 'Header cannot be recreated: No INDEX found'
                  COLOR COL_NEGATIVE.
        WHEN -1.
          WRITE: 'Document header successfully recreated'
                  COLOR COL_POSITIVE.
        WHEN -2.
         WRITE: 'Header not successfully recreated: modify BKPF failed'
                   COLOR COL_NEGATIVE.


      ENDCASE.
      WRITE   112 sy-vline.
      NEW-LINE.
      ULINE (112).

      PERFORM write_doc_header USING pbkpf.

      IF iibkpf-repcd = 0.
        hbkpf = pbkpf.
        HIDE hbkpf.
        WRITE '@0Z@' AS ICON COLOR OFF.
      ENDIF.


      NEW-LINE.
      ULINE (112).


    ENDIF.
  ENDLOOP.

ENDFORM.


*---------------------------------------------------------------------*
*       FORM write_template                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM write_template.
  IF has_template = 'X'.
    NEW-LINE.
    ULINE (112).
    FORMAT COLOR COL_HEADING.
    WRITE: / sy-vline,
             (87) 'Template Header used:',
             template_bkpf-bukrs,
             template_bkpf-belnr,
             template_bkpf-gjahr,
             sy-vline.
    NEW-LINE.
    ULINE (112).

    PERFORM write_doc_header USING template_bkpf.

    NEW-LINE.
    ULINE (112).
  ENDIF.

  IF rbseg = 'X'.
    IF has_template = 'X'.
      FORMAT COLOR COL_HEADING.
      WRITE: / sy-vline,
              (108) 'Template BSEG used:',
              sy-vline.
      PERFORM write_bseg_header.
      NEW-LINE.
      ULINE (112).

      FORMAT COLOR COL_NORMAL.

      LOOP AT template_bseg.
        PERFORM write_bseg USING template_bseg.
      ENDLOOP.
      DESCRIBE TABLE template_bseg LINES sy-tfill.
      IF sy-tfill LT 1.
        WRITE:/ sy-vline,
                '***** no data *****',
                112 sy-vline.
      ENDIF.
      NEW-LINE.
      ULINE (112).

    ENDIF.
  ENDIF.

ENDFORM.


*---------------------------------------------------------------------*
*       FORM write_bseg                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PBSEG                                                         *
*---------------------------------------------------------------------*
FORM write_bseg USING pbseg LIKE bseg.

  WRITE: / sy-vline,
      pbseg-buzei,
      (5) pbseg-buzid,
      (5) pbseg-ktosl,
      pbseg-augdt,
      pbseg-augbl,
      pbseg-bschl,
      pbseg-koart,
      pbseg-umskz,
      pbseg-umsks,
      pbseg-shkzg,
      pbseg-gsber,
      pbseg-dmbtr,
      pbseg-wrbtr.
  CASE pbseg-koart.
    WHEN 'S' OR 'M' OR 'A'.
      WRITE pbseg-hkont.
    WHEN 'D'.
      WRITE pbseg-kunnr.
    WHEN 'K'.
      WRITE pbseg-lifnr.
  ENDCASE.
  WRITE: 112 sy-vline.


ENDFORM.


*---------------------------------------------------------------------*
*       FORM write_bseg_header                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM write_bseg_header.
  WRITE: / sy-vline,
          'POS',
          'BUZID',
          'KTOSL',
          'Clear_Date',
          'Clear_Docn',
          'PK',
          'K',
          'S',
          'Z',
          'H',
          'GSBE',
          '       Amount LC',
          '       Amount FC',
          'Account No'.
  WRITE: 112 sy-vline.


ENDFORM.


*---------------------------------------------------------------------*
*       FORM write_execute_button                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM write_execute_button.
* ***************************************
* A click on the execute Button generates
* an 'AT-LINE-SELECTION' EVENT
* ***************************************

  CLEAR excute_hdr.
  IF rbkpf = 'X'.
    DESCRIBE TABLE global_bkpf LINES sy-tfill.
  ELSE.
    IF xrfc IS INITIAL.
      DESCRIBE TABLE global_bseg LINES sy-tfill.
    ELSE.
      DESCRIBE TABLE global_rfblg LINES sy-tfill.
    ENDIF.

  ENDIF.
  IF sy-tfill > 0.
    excute_hdr = 1.
    NEW-LINE.
    ULINE (112).
    WRITE:/ sy-vline,
            '@15@' AS ICON HOTSPOT.
    HIDE excute_hdr.
    IF rbkpf = 'X'.
      WRITE 'Create the missing headers now ?'.
    ELSE.
      IF xrfc IS INITIAL.
        WRITE 'Create the missing positions now ?'.
      ELSE.
        WRITE 'Get the missing positions by RFC now ?'.
      ENDIF.

    ENDIF.
    WRITE   112 sy-vline.

    NEW-LINE.
    ULINE (112).
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM write_execute_button_1                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM write_execute_button_1.
* ***************************************
* A click on the execute Button generates
* an 'AT-LINE-SELECTION' EVENT
* ***************************************

  CLEAR excute_rep.
  DESCRIBE TABLE global_nbkpf LINES sy-tfill.
  IF sy-tfill > 0.
    excute_rep = 1.
    NEW-LINE.
    ULINE (112).
    WRITE:/ sy-vline,
            '@15@' AS ICON HOTSPOT.
    WRITE 'Try to repair'.
    WRITE   112 sy-vline.
    HIDE excute_rep.
    NEW-LINE.
    ULINE (112).
  ENDIF.
ENDFORM.



*---------------------------------------------------------------------*
*       FORM line_selection_1                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM line_selection_1.

  IF NOT excute_rep IS INITIAL AND sy-cucol > 2 AND sy-cucol < 6.
    PERFORM collect_data.
    EXIT.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM do_repair                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM do_repair.
  IF xrepair IS INITIAL.
    MESSAGE i000 WITH 'Repair Mode not set'.
    EXIT.
  ENDIF.
  IF rbkpf = 'X'.
*   ***********************************
*   Do the BKPF inserts here
*   ***********************************
    PERFORM insert_missing_headers.
    PERFORM write_exceptions.
    EXIT.
  ELSE.
*   ***********************************
*   Do the BSEG inserts here
*   ***********************************
    PERFORM insert_missing_bsegs.
    PERFORM write_exceptions.
    EXIT.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM line_selection_2                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM line_selection_2.

  IF NOT excute_hdr IS INITIAL AND sy-cucol > 2 AND sy-cucol < 6.
    PERFORM do_repair.
  ENDIF.

  IF rbseg = 'X'.
    IF NOT hbseg IS INITIAL AND sy-cucol > 114 AND sy-cucol < 116.
      READ TABLE global_bseg WITH KEY bukrs = hbseg-bukrs
                                      belnr = hbseg-belnr
                                      gjahr = hbseg-gjahr
                                      buzei = hbseg-buzei.
      IF sy-subrc = 0.
        PERFORM edit_list_bseg USING hbseg.
      ENDIF.
    ENDIF.
    EXIT.
  ENDIF.

  IF rbkpf = 'X'.
    IF NOT hbkpf IS INITIAL AND sy-cucol > 114 AND sy-cucol < 116.
      READ TABLE global_bkpf WITH KEY bukrs = hbkpf-bukrs
                                      belnr = hbkpf-belnr
                                      gjahr = hbkpf-gjahr.
      IF sy-subrc = 0.
        PERFORM list_bkpf USING template_bkpf hbkpf.
      ENDIF.
    ENDIF.
    EXIT.
  ENDIF.


ENDFORM.

*---------------------------------------------------------------------*
*       FORM line_selection_3                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM line_selection_3.
  FIELD-SYMBOLS:  <input2> TYPE ANY,
                  <input3> TYPE ANY.


  CLEAR h_index.
  READ CURRENT LINE FIELD VALUE text.
  IF h_index > 0 AND sy-cucol > 54 AND sy-cucol < 75.
    IF sy-subrc = 0.

      IF rbseg = 'X'.
        ASSIGN COMPONENT h_index OF STRUCTURE hbseg TO <input2>.
        IF text = <input2>.
          EXIT.
        ENDIF.
        MOVE text TO  <input2>.


        LOOP AT global_bseg WHERE bukrs = hbseg-bukrs
                               AND belnr = hbseg-belnr
                               AND gjahr = hbseg-gjahr
                               AND buzei = hbseg-buzei.
          global_bseg = hbseg.
          MODIFY global_bseg.
        ENDLOOP.

      ENDIF.

      IF rbkpf = 'X'.

        ASSIGN COMPONENT h_index OF STRUCTURE hbkpf TO <input2>.
        IF text = <input2>.
          EXIT.
        ENDIF.
        MOVE text TO  <input2>.


        LOOP AT global_bkpf WHERE bukrs = hbkpf-bukrs
                               AND belnr = hbkpf-belnr
                               AND gjahr = hbkpf-gjahr.
          global_bkpf = hbkpf.
          MODIFY global_bkpf.
        ENDLOOP.


      ENDIF.

    ENDIF.

  ELSE.
    MESSAGE i000 WITH 'Select a valid field'.
  ENDIF. " <-- H_index > 0.
*  else.  " <--- of if x_testl

*  endif. " <--- of if x_testl

ENDFORM.


* -------------------------------------------------------------------- *
*                  Fortschrittsbalken initialisieren                   *
* -------------------------------------------------------------------- *
FORM initialize_progress.
  DATA: no_use TYPE i,
        no_name.

  PERFORM do_progress USING 'X'
                      CHANGING no_use no_name.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM execute_progress                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  P_ERROR_COUNT                                                 *
*  -->  NAME                                                          *
*---------------------------------------------------------------------*
FORM execute_progress USING p_error_count TYPE i name.
  PERFORM do_progress USING ' '
                      CHANGING p_error_count name.
ENDFORM.

* -------------------------------------------------------------------- *
*              Abfrage des aktuellen Fehlercounts                      *
* -------------------------------------------------------------------- *
FORM query_progress CHANGING p_count TYPE i.
  DATA: no_name.
  PERFORM do_progress USING 'A'
                      CHANGING p_count no_name.
ENDFORM.

* -------------------------------------------------------------------- *
*            Formroutine zum Hochzählen und ausgeben                   *
* -------------------------------------------------------------------- *
FORM do_progress USING init_flag
                 CHANGING p_error_count TYPE i name.

  STATICS hit100 TYPE i.
  STATICS hit1000 TYPE i.
  STATICS hitall TYPE i.
  DATA hitstring_count(7) TYPE c.
  DATA string_error(6) TYPE c.
  DATA status_sting(40) TYPE c.
  DATA per_cent TYPE i.
  IF init_flag = 'A'.
    p_error_count = hitall.
    EXIT.
  ENDIF.
  IF init_flag = 'X'.
    hit100 = 0.
    hit1000 = 0.
    hitall = 0.
    EXIT.
  ENDIF.

  ADD 1 TO hit100.
  ADD 1 TO hit1000.
  ADD 1 TO hitall.
  IF hit100 = c_progress_small.
    hitstring_count = hitall.
    per_cent = hit1000 / 10.
    string_error = p_error_count.
    DATA name2(30).
    CONCATENATE name ' Entries,' string_error INTO name2.
    CONCATENATE hitstring_count
                name2
               'Errors'
                INTO status_sting
                           SEPARATED BY space.
    PERFORM progress USING status_sting per_cent.
    CLEAR hit100.
  ENDIF.
  IF hit1000 = c_progress_large.
    CLEAR hit1000.
  ENDIF.

ENDFORM.

* -------------------------------------------------------------------- *
*                     Fortschrittsanzeige
* -------------------------------------------------------------------- *
FORM progress USING text outperc.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
       EXPORTING
            text       = text
            percentage = outperc.
ENDFORM.

* -------------------------------------------------------------------- *
*                    Editor
* -------------------------------------------------------------------- *

FORM edit_list_bseg USING h_bseg LIKE bseg.
  DATA: buffer LIKE bseg.
  DATA: b_bseg LIKE bseg.
  b_bseg = h_bseg.
  LOOP AT template_bseg WHERE buzei = h_bseg-buzei.
    buffer = template_bseg.
    EXIT.
  ENDLOOP.

  PERFORM list_bseg USING buffer b_bseg.

ENDFORM.


* -------------------------------------------------------------------- *
*                           Bseg auflisten
* -------------------------------------------------------------------- *
FORM list_bseg USING bkpf_1 LIKE bseg bkpf_2 LIKE bseg.
  ebseg = bkpf_2.
  DATA: int TYPE i,
        inp TYPE i.
  FIELD-SYMBOLS: <output_1>, <output_2>.

  FORMAT COLOR COL_NEGATIVE.
  NEW-LINE.
  ULINE (74).
  WRITE:/ sy-vline,
          'Do not forget to double click on the field you have changed',
          74 sy-vline.
  WRITE:/ sy-vline,
          'The double click commits changes to the internal tables!',
          74 sy-vline.
  FORMAT COLOR OFF.



  NEW-LINE.
  ULINE (74).
  WRITE:/ sy-vline NO-GAP,
         (3) '#' LEFT-JUSTIFIED COLOR COL_HEADING NO-GAP,
         sy-vline NO-GAP,
         (5) 'FIELD' COLOR COL_HEADING NO-GAP,
         sy-vline COLOR OFF NO-GAP,
         (20) ' Template BSEG' COLOR COL_HEADING NO-GAP,
         sy-vline NO-GAP,
         (20) ' Restored BSEG' COLOR COL_HEADING NO-GAP,
         sy-vline NO-GAP.
*  if x_testl is initial.
  WRITE: (20) 'Edit Restored BSEG'  COLOR COL_HEADING NO-GAP,
         sy-vline NO-GAP.
*  endif.

*  if xrepair ne 'X'.
*    new-line.
*    uline (53).
*  else.
  NEW-LINE.
  ULINE (74).
*  endif.

  FORMAT COLOR OFF.

* loop over all entries
  DO.
    ASSIGN COMPONENT sy-index OF STRUCTURE bkpf_1 TO <output_1>.
    ASSIGN COMPONENT sy-index OF STRUCTURE bkpf_2 TO <output_2>.
    ASSIGN COMPONENT sy-index OF STRUCTURE ebseg TO <input>.
    IF sy-subrc NE 0.
      EXIT.
    ENDIF.
    READ TABLE ydd03l_bseg WITH KEY position = sy-index.
    IF ydd03l_bseg-keyflag = 'X'.
      int = 1.
      inp = 0.
    ELSE.
      int = 0.
      inp = 1.
      READ TABLE ydd03l_bsis WITH
                        KEY fieldname = ydd03l_bseg-fieldname.
      IF sy-subrc = 0.
        inp = 0.
      ELSE.
        READ TABLE ydd03l_bsid WITH
                          KEY fieldname = ydd03l_bseg-fieldname.
        IF sy-subrc = 0.
          inp = 0.
        ELSE.
          READ TABLE ydd03l_bsik WITH
                            KEY fieldname = ydd03l_bseg-fieldname.
          IF sy-subrc = 0.
            inp = 0.
          ELSE.
            LOOP AT exclude_edit_bseg.
              IF exclude_edit_bseg = ydd03l_bseg-fieldname.
                inp = 0.
                EXIT.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    <input> =  <output_2>.
    text = <input>.
    h_index = sy-index.

    WRITE:/ sy-vline NO-GAP,
     (3) sy-index LEFT-JUSTIFIED
                      COLOR COL_KEY NO-GAP INTENSIFIED = int,
         sy-vline NO-GAP,
     (5) ydd03l_bseg-fieldname COLOR COL_KEY NO-GAP INTENSIFIED = int,
         sy-vline COLOR OFF NO-GAP,
  AT (20) <output_1>  COLOR COL_NORMAL NO-GAP INTENSIFIED = int,
      32  sy-vline  NO-GAP,
  AT (20) <output_2>  COLOR COL_NORMAL NO-GAP INTENSIFIED = int,
      53 sy-vline NO-GAP.
* if xrepair = 'X'.
    PERFORM format_input USING text ydd03l_bseg inp.
    HIDE h_index.
* endif.
    FORMAT COLOR OFF.
  ENDDO.
* end of do loop over all entries.

  NEW-LINE.
* if xrepair ne 'X'.
*    uline (53).
*  else.
*    new-line.
  ULINE (74).
*  endif.



ENDFORM.

*---------------------------------------------------------------------*
*       FORM list_bkpf                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  BKPF_1                                                        *
*  -->  BKPF_2                                                        *
*---------------------------------------------------------------------*
FORM list_bkpf USING bkpf_1 LIKE bkpf bkpf_2 LIKE bkpf.
  DATA: int TYPE i, inp TYPE i.
  FIELD-SYMBOLS: <output_1>, <output_2>.

  FORMAT COLOR COL_NEGATIVE.
  NEW-LINE.
  ULINE (74).
  WRITE:/ sy-vline,
          'Do not forget to double click on the field you have changed',
          74 sy-vline.
  WRITE:/ sy-vline,
          'The double click commits changes to the internal tables!',
          74 sy-vline.
  FORMAT COLOR OFF.

  NEW-LINE.
  ULINE (74).
  WRITE:/ sy-vline NO-GAP,
         (3) '#' LEFT-JUSTIFIED COLOR COL_HEADING NO-GAP,
         sy-vline NO-GAP,
         (5) 'FIELD' COLOR COL_HEADING NO-GAP,
         sy-vline COLOR OFF NO-GAP,
         (20) ' Template Header' COLOR COL_HEADING NO-GAP,
         sy-vline NO-GAP,
         (20) ' Restored Header' COLOR COL_HEADING NO-GAP,
         sy-vline NO-GAP.
  WRITE: (20) 'Edit Restored Header'  COLOR COL_HEADING NO-GAP,
         sy-vline NO-GAP.

  NEW-LINE.
  ULINE (74).
  FORMAT COLOR OFF.

* loop over all entries
  DO.
    ASSIGN COMPONENT sy-index OF STRUCTURE bkpf_1 TO <output_1>.
    ASSIGN COMPONENT sy-index OF STRUCTURE bkpf_2 TO <output_2>.
    ASSIGN COMPONENT sy-index OF STRUCTURE bkpf TO <input>.
    IF sy-subrc NE 0.
      EXIT.
    ENDIF.
    READ TABLE ydd03l_bkpf WITH KEY position = sy-index.

    IF ydd03l_bkpf-keyflag = 'X'.
      int = 1.
      inp = 0.
    ELSE.
      int = 0.
      inp = 1.
      READ TABLE ydd03l_bsis WITH KEY fieldname = ydd03l_bkpf-fieldname.
      IF sy-subrc = 0.
        inp = 0.
      ELSE.
        READ TABLE ydd03l_bsid WITH
                          KEY fieldname = ydd03l_bkpf-fieldname.
        IF sy-subrc = 0.
          inp = 0.
        ELSE.
          READ TABLE ydd03l_bsik WITH
                            KEY fieldname = ydd03l_bkpf-fieldname.
          IF sy-subrc = 0.
            inp = 0.
          ELSE.
            LOOP AT exclude_edit_bkpf.
              IF exclude_edit_bkpf = ydd03l_bkpf-fieldname.
                inp = 0.
                EXIT.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    <input> =  <output_2>.
    text = <input>.
    h_index = sy-index.
    WRITE:/ sy-vline NO-GAP,
     (3) sy-index LEFT-JUSTIFIED
                      COLOR COL_KEY NO-GAP INTENSIFIED = int,
         sy-vline NO-GAP,
     (5) ydd03l_bkpf-fieldname COLOR COL_KEY NO-GAP INTENSIFIED = int,
         sy-vline COLOR OFF NO-GAP,
     (20) <output_1>  COLOR COL_NORMAL NO-GAP INTENSIFIED = int,
         sy-vline  NO-GAP,
     (20) <output_2>  COLOR COL_NORMAL NO-GAP INTENSIFIED = int,
         sy-vline NO-GAP.
    WRITE: (20) text INPUT = inp
                           COLOR COL_NORMAL INTENSIFIED ON NO-GAP,
           '|' NO-GAP.
    HIDE h_index.

    FORMAT COLOR OFF.
  ENDDO.
* end of do loop over all entries.

  NEW-LINE.
  ULINE (74).


ENDFORM.



*---------------------------------------------------------------------*
*       FORM format_input                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  TEXT                                                          *
*  -->  YDD03L                                                        *
*  -->  INP                                                           *
*---------------------------------------------------------------------*
FORM format_input USING text TYPE any
                        ydd03l LIKE dd03l
                        inp TYPE i.

  IF ydd03l-inttype = 'D'.
    WRITE: AT (20) text INPUT = inp LEFT-JUSTIFIED
               COLOR COL_NORMAL INTENSIFIED ON NO-GAP,
            74  '|' NO-GAP.
  ENDIF.
  IF ydd03l-inttype <> 'D'.
    WRITE: AT (20) text INPUT = inp LEFT-JUSTIFIED
               COLOR COL_NORMAL INTENSIFIED ON NO-GAP,
           74       '|' NO-GAP.
  ENDIF.

ENDFORM.


*---------------------------------------------------------------------*
*       FORM get_hw2_3                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PT001                                                         *
*  -->  HW2                                                           *
*  -->  HW3                                                           *
*---------------------------------------------------------------------*
FORM get_hw2_3 USING pt001 LIKE t001
             CHANGING hw2 LIKE bkpf-waers
                      hw3 LIKE bkpf-waers.
  CLEAR: hw2, hw3.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t001a WHERE bukrs = pt001-bukrs.
**
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t001a WHERE bukrs = pt001-bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc = 0.
    PERFORM waehrung USING pt001
                           t001a-curtp
                  CHANGING hw2.
    PERFORM waehrung USING pt001
                           t001a-curtp2
                  CHANGING hw3.



  ENDIF.


ENDFORM.



*---------------------------------------------------------------------*
*       FORM waehrung                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PT001                                                         *
*  -->  CURTP                                                         *
*  -->  WAERS                                                         *
*---------------------------------------------------------------------*
FORM waehrung USING pt001 LIKE t001
                    curtp LIKE t001a-curtp
     CHANGING waers LIKE t001-waers.

  CLEAR waers.
  CHECK NOT curtp IS INITIAL.


  CASE curtp.
    WHEN '11' OR '12'.                 " Hauswährung
      waers = pt001-waers.
    WHEN '30' OR '31' OR '32'.         " Konzernwährung
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM t000
*             WHERE mandt = sy-mandt.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM t000
             WHERE mandt = sy-mandt ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc = 0.
        waers = t000-mwaer.
      ENDIF.
    WHEN '40'.                         " Hartwährung
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM t005
*             WHERE land1 = pt001-land1.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM t005
             WHERE land1 = pt001-land1 ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc = 0.
        waers = t005-curha.
      ENDIF.
    WHEN '50'.                         " Indexwährung
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM t005
*             WHERE land1 = pt001-land1.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM t005
             WHERE land1 = pt001-land1 ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc = 0.
        waers = t005-curin.
      ENDIF.
    WHEN '60'.                         " Gesellschaftswährung
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM t880
*             WHERE rcomp = pt001-rcomp.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM t880
             WHERE rcomp = pt001-rcomp ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc = 0.
        waers = t880-curr.
      ENDIF.
  ENDCASE.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM get_kurs123                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PT001                                                         *
*  -->  PBKPF                                                         *
*---------------------------------------------------------------------*
FORM get_kurs123 USING pt001 LIKE t001
            CHANGING pbkpf LIKE bkpf.

  PERFORM get_kurs USING pbkpf-waers
                         pbkpf-hwaer
                         pbkpf-budat
                         'M'
                CHANGING pbkpf-kursf.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t001a WHERE bukrs = pt001-bukrs.
**
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t001a WHERE bukrs = pt001-bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  CHECK sy-subrc = 0.

  IF t001a-cursr = '1'.
    PERFORM get_kurs USING pbkpf-waers
                           pbkpf-hwae2
                           pbkpf-budat
                           t001a-kurst
                  CHANGING pbkpf-kurs2.


  ENDIF.
  IF t001a-cursr = '2'.
    PERFORM get_kurs USING pbkpf-hwaer
                           pbkpf-hwae2
                           pbkpf-budat
                           t001a-kurst
                  CHANGING pbkpf-kurs2.


  ENDIF.

  IF t001a-cursr2 = '1'.
    PERFORM get_kurs USING pbkpf-waers
                           pbkpf-hwae3
                           pbkpf-budat
                           t001a-kurst2
                  CHANGING pbkpf-kurs3.


  ENDIF.
  IF t001a-cursr2 = '2'.
    PERFORM get_kurs USING pbkpf-hwaer
                           pbkpf-hwae3
                           pbkpf-budat
                           t001a-kurst2
                  CHANGING pbkpf-kurs3.


  ENDIF.




ENDFORM.





*---------------------------------------------------------------------*
*       FORM get_kurs                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  PFROM                                                         *
*  -->  PTO                                                           *
*  -->  PDATE                                                         *
*  -->  PRATE                                                         *
*  -->  KURS                                                          *
*---------------------------------------------------------------------*
FORM get_kurs USING pfrom LIKE t001-waers
                        pto LIKE t001-waers
                     pdate LIKE bkpf-budat
                     prate LIKE t001a-kurst
             CHANGING kurs LIKE bkpf-kursf.

  CHECK pfrom NE pto.
  CHECK NOT pfrom IS INITIAL.
  CHECK NOT pto IS INITIAL.

  CLEAR kurs.


  CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
    EXPORTING
*     CLIENT                  = SY-MANDT
      date                    = pdate
      foreign_amount          = '10000'
      foreign_currency        = pfrom
      local_currency          = pto
*     RATE                    = 0
      type_of_rate            = prate
*     READ_TCURR              = 'X'
   IMPORTING
      exchange_rate           = kurs
*     FOREIGN_FACTOR          =
*     LOCAL_AMOUNT            =
*     LOCAL_FACTOR            =
*     EXCHANGE_RATEX          =
*     FIXED_RATE              =
*     DERIVED_RATE_TYPE       =
   EXCEPTIONS
      no_rate_found           = 1
      overflow                = 2
      no_factors_found        = 3
      no_spread_found         = 4
      derived_2_times         = 5
      OTHERS                  = 6
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    CLEAR kurs.
  ENDIF.



ENDFORM.










*---------------------------------------------------------------------*
*       FORM fill_global_data                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM fill_global_data.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM dd03l INTO TABLE ydd03l_bseg WHERE tabname = 'BSEG'.
*
* NEW CODE
  SELECT *
 FROM dd03l INTO TABLE ydd03l_bseg WHERE tabname = 'BSEG' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  SORT ydd03l_bseg BY position.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM dd03l INTO TABLE ydd03l_bkpf WHERE tabname = 'BKPF'.
*
* NEW CODE
  SELECT *
 FROM dd03l INTO TABLE ydd03l_bkpf WHERE tabname = 'BKPF' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  SORT ydd03l_bkpf BY position.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM dd03l INTO TABLE ydd03l_bsis WHERE tabname = 'BSIS'.
*
* NEW CODE
  SELECT *
 FROM dd03l INTO TABLE ydd03l_bsis WHERE tabname = 'BSIS' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  SORT ydd03l_bsis BY position.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM dd03l INTO TABLE ydd03l_bsid WHERE tabname = 'BSID'.
*
* NEW CODE
  SELECT *
 FROM dd03l INTO TABLE ydd03l_bsid WHERE tabname = 'BSID' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  SORT ydd03l_bsid BY position.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM dd03l INTO TABLE ydd03l_bsik WHERE tabname = 'BSIK'.
*
* NEW CODE
  SELECT *
 FROM dd03l INTO TABLE ydd03l_bsik WHERE tabname = 'BSIK' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  SORT ydd03l_bsik BY position.

  exclude_edit_bseg = 'KOART'.
  APPEND exclude_edit_bseg.
  exclude_edit_bseg = 'XUMSW'.
  APPEND exclude_edit_bseg.
  exclude_edit_bseg = 'XZAHL'.
  APPEND exclude_edit_bseg.
  exclude_edit_bseg = 'AUGCP'.
  APPEND exclude_edit_bseg.
  exclude_edit_bseg = 'HZUON'.
  APPEND exclude_edit_bseg.
  exclude_edit_bseg = 'GVTYP'.
  APPEND exclude_edit_bseg.
  exclude_edit_bseg = 'XBILK'.
  APPEND exclude_edit_bseg.
  exclude_edit_bseg = 'XHRES'.
  APPEND exclude_edit_bseg.
  exclude_edit_bseg = 'XKRES'.
  APPEND exclude_edit_bseg.
  exclude_edit_bseg = 'XOPVW'.
  APPEND exclude_edit_bseg.



  exclude_edit_bkpf = 'XNETB'.
  APPEND exclude_edit_bkpf.
  exclude_edit_bkpf = 'HWAER'.
  APPEND exclude_edit_bkpf.
  exclude_edit_bkpf = 'USNAM'.
  APPEND exclude_edit_bkpf.
  exclude_edit_bkpf = 'HWAE2'.
  APPEND exclude_edit_bkpf.
  exclude_edit_bkpf = 'HWAE3'.
  APPEND exclude_edit_bkpf.
  exclude_edit_bkpf = 'KURS2'.
  APPEND exclude_edit_bkpf.
  exclude_edit_bkpf = 'KURS3'.
  APPEND exclude_edit_bkpf.


*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*SELECT * FROM tbsl INTO TABLE itbsl.
SELECT * FROM TBSL INTO TABLE ITBSL ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
  SORT itbsl BY bschl.

ENDFORM.


* Das Feld LNRAN wird nicht übernommen, da am untersuchten Beispiel
* das Feld im FI nicht korrekt gefüllt war.
* Das Feld MEINS aus der ANEK wird nicht übernommen, um den IO
* einzusparen
FORM read_anlagen CHANGING new_bseg LIKE bseg.
  TABLES: anep.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM anep
*  WHERE bukrs = new_bseg-bukrs
*    AND gjahr = new_bseg-gjahr
*    AND belnr = new_bseg-belnr
*    AND buzei = new_bseg-buzei.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM anep
  WHERE bukrs = new_bseg-bukrs
    AND gjahr = new_bseg-gjahr
    AND belnr = new_bseg-belnr
    AND buzei = new_bseg-buzei ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc = 0.
    new_bseg-anln1 = anep-anln1.
    new_bseg-anln2 = anep-anln2.
    new_bseg-anbwa = anep-bwasl.
    new_bseg-bzdat = anep-bzdat.
  ENDIF.
ENDFORM.
*** end of program
