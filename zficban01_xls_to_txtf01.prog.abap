*----------------------------------------------------------------------*
***INCLUDE ZFICBAN01_XLS_TO_TXTF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  XLS_TO_TXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_DATA  text
*      -->P_P_FILE  text
*----------------------------------------------------------------------*
DATA: filename LIKE rlgrap-filename,
            begcol TYPE i,
            begrow TYPE i,
            endcol TYPE i,
            endrow TYPE i.
* Tick don't append header

DATA: BEGIN OF intern OCCURS 0.
        INCLUDE STRUCTURE  alsmex_tabline.
DATA: END OF intern.

DATA: BEGIN OF intern1 OCCURS 0.
        INCLUDE STRUCTURE  alsmex_tabline.
DATA: END OF intern1.

DATA: BEGIN OF t_col OCCURS 0,
       col LIKE alsmex_tabline-col,
       size TYPE i.
DATA: END OF t_col.

DATA: zwlen TYPE i,
      zwlines TYPE i.

DATA: BEGIN OF fieldnames OCCURS 3,
        title(60),
        table(6),
        field(10),
        kz(1),
      END OF fieldnames.
* No of columns
DATA: BEGIN OF data_tab OCCURS 0,
       value_0001(50),
       value_0002(50),
       value_0003(50),
       value_0004(50),
       value_0005(50),
       value_0006(50),
       value_0007(50),
       value_0008(50),
       value_0009(50),
       value_0010(50),
       value_0011(50),
       value_0012(50),
       value_0013(50),
       value_0014(50),
       value_0015(50),
       value_0016(50),
       value_0017(50),
       value_0018(50),
       value_0019(50),
       value_0020(50),
       value_0021(50),
       value_0022(50),
       value_0023(50),
       value_0024(50),
       value_0025(50),
       value_0026(50),
       value_0027(50),
       value_0028(50),
       value_0029(50),
       value_0030(50),
       value_0031(50),
       value_0032(50),
       value_0033(50),
       value_0034(50),
       value_0035(50),
       value_0036(50),
       value_0037(50),
       value_0038(50),
       value_0039(50),
       value_0040(50),
       value_0041(50),
       value_0042(50),
       value_0043(50),
       value_0044(50),
       value_0045(50),
       value_0046(50),
       value_0047(50),
       value_0048(50),
       value_0049(50),
       value_0050(50),
       value_0051(50),
       value_0052(50),
       value_0053(50),
       value_0054(50),
       value_0055(50),
       value_0056(50),
       value_0057(50),
       value_0058(50),
       value_0059(50),
       value_0060(50),
       value_0061(50),
       value_0062(50),
       value_0063(50),
       value_0064(50),
       value_0065(50),
       value_0066(50),
       value_0067(50),
       value_0068(50),
       value_0069(50),
       value_0070(50),
       value_0071(50),
       value_0072(50),
       value_0073(50),
       value_0074(50),
       value_0075(50),
       value_0076(50),
       value_0077(50),
       value_0078(50),
       value_0079(50),
       value_0080(50),
       value_0081(50),
       value_0082(50),
       value_0083(50),
       value_0084(50),
       value_0085(50),
       value_0086(50),
       value_0087(50),
       value_0088(50),
       value_0089(50),
       value_0090(50),
       value_0091(50),
       value_0092(50),
       value_0093(50),
       value_0094(50),
       value_0095(50),
       value_0096(50),
       value_0097(50),
       value_0098(50),
       value_0099(50),
       value_0100(50).
DATA: END OF data_tab.
DATA: tind(4) TYPE n.
DATA: zwfeld(19).
FIELD-SYMBOLS: <fs1>.

TYPES:
        line2(1000) TYPE C.

data: wa_data TYPE line2.

FORM XLS_TO_TXT  TABLES   P_IT_DATA
                 USING    P_P_FILE.

    begcol = 1.
    begrow = 1.
    endcol = 100.
    endrow = 32000.
    filename = P_P_FILE.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
       EXPORTING
            filename                = filename
            i_begin_col             = begcol
            i_begin_row             = begrow
            i_end_col               = endcol
            i_end_row               = endrow
       TABLES
            intern                  = intern
       EXCEPTIONS
            inconsistent_parameters = 1
            upload_ole              = 2
            OTHERS                  = 3.

  IF sy-subrc <> 0.
    WRITE:/ 'Upload Error ', SY-SUBRC.
  ENDIF.

  LOOP AT intern.
    intern1 = intern.
    CLEAR intern1-row.
    APPEND intern1.
  ENDLOOP.

  SORT intern1 BY col.
  LOOP AT intern1.
    AT NEW col.
      t_col-col = intern1-col.
      APPEND t_col.
    ENDAT.
    zwlen = strlen( intern1-value ).
    READ TABLE t_col WITH KEY col = intern1-col.
    IF sy-subrc EQ 0.
      IF zwlen > t_col-size.
        t_col-size = zwlen.
*                          Internal Table, Current Row Index
        MODIFY t_col INDEX sy-tabix.
      ENDIF.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE t_col LINES zwlines.
*  zwlines = 15.
  SORT intern BY row col.
  DO zwlines TIMES.
    WRITE sy-index TO fieldnames-title.
    APPEND fieldnames.
  ENDDO.

  SORT intern BY row col.
  LOOP AT intern.
*    Comentario
*    IF kzheader = 'X'
*    AND intern-row = 1.
*      CONTINUE.
*    ENDIF.
    tind = intern-col.
    CONCATENATE 'DATA_TAB-VALUE_' tind INTO zwfeld.
    ASSIGN (zwfeld) TO <fs1>.
    <fs1> = intern-value.
    AT END OF row.
      APPEND data_tab.
      CLEAR data_tab.
    ENDAT.
  ENDLOOP.

  LOOP AT data_tab.
    CONCATENATE
            data_tab-value_0001
            data_tab-value_0002
            data_tab-value_0003
            data_tab-value_0004
            data_tab-value_0005
            data_tab-value_0006
            data_tab-value_0007
            data_tab-value_0008
            data_tab-value_0009
            data_tab-value_0010
            data_tab-value_0011
            data_tab-value_0012
            data_tab-value_0013
            data_tab-value_0014
            data_tab-value_0015
    INTO wa_data SEPARATED BY ';'.
*    Aqui hacer el translate
    APPEND wa_data to P_IT_DATA.
  ENDLOOP.
ENDFORM.                    " XLS_TO_TXT
