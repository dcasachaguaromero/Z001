*$*$********************************************************************
*$*$                                                                   *
*$*$ PROGRAMAM  : ZZFIMOD_EMIS3                                        *
*$*$ DESCRIPCION: Programa que modifica Campo BSEG-ZZMOT_EMIS          *
*$*$              En los pagos masivos con Via de Pago V o T, el campo *
*$*$              T_BSEG-ZZMOT_EMIS no se llena en el Documento¨de     *
*$*$              pago, para lo cual este programa busca la Factura y  *
*$*$              saca el contenido de este campo y lo traslada al pago*
*$*$              COPIA DEL PROGRAMA ZFIMOD_EMIS1                      *
*$*$                                                                   *
*$*$ AUTOR      : Waldo Alarcón - VisioOne.                            *
*$*$                                                                   *
*$*$ DATA    : 29/06/2020.                                             *
*$*$                                                                   *
*$*$********************************************************************
*$*$                   HISTORIAL DE MODIFICACIONES                     *
*$*$-------------------------------------------------------------------*
*$*$ DATA     | AUTOR          | DESCRIPCION                           *
*$*$-------------------------------------------------------------------*
*$*$          |                |                                       *
*$*$          |                |                                       *
*$*$-------------------------------------------------------------------*
*$*$********************************************************************
REPORT  zfimod_emis3 MESSAGE-ID fs
                     NO STANDARD PAGE HEADING LINE-SIZE 132.
*
*----------------------------------------------------------------------*
* Data Declarations                                                    *
*----------------------------------------------------------------------*
INCLUDE ff05lcdv.                "function module BELEG_WRITE_DOCUMENT
INCLUDE ff05lcdf.                "form CD_CALL_BELEG
*
TABLES:
*
  t001,                          "Company Codes
  bseg,                          "Accounting document segment
  rfsdo,                         "Data elements for selection
  bsec, bsed, bset.
*
TYPES:
  BEGIN OF protocol_line,        "Protocol line
    bukrs      LIKE bseg-bukrs,
    belnr      LIKE bseg-belnr,
    gjahr      LIKE bseg-gjahr,
    buzei      LIKE bseg-buzei,
    zzmot_emis TYPE bseg-zzmot_emis,
  END OF protocol_line.
*
*
DATA:
  z_bkpf        LIKE bkpf   OCCURS 0 WITH HEADER LINE,
  t_bkpf        LIKE bkpf   OCCURS 1 WITH HEADER LINE,
  t_bseg        LIKE bseg   OCCURS 0 WITH HEADER LINE,
  t_bkdf        LIKE bkdf   OCCURS 0 WITH HEADER LINE,
  t_bsec        LIKE bsec   OCCURS 0 WITH HEADER LINE,
  t_bsed        LIKE bsed   OCCURS 0 WITH HEADER LINE,
  t_bset        LIKE bset   OCCURS 0 WITH HEADER LINE,
  t_update      TYPE protocol_line OCCURS 0 WITH HEADER LINE,
  t_queue       TYPE protocol_line OCCURS 0 WITH HEADER LINE,
  t_error       TYPE protocol_line OCCURS 0 WITH HEADER LINE,
  t_multi       TYPE protocol_line OCCURS 0 WITH HEADER LINE,
  w_xbseg       LIKE fbseg,
  w_ybseg       LIKE fbseg,
  i_noprot      TYPE c VALUE 'X',
  i_ptype       TYPE c,
  i_pageend     TYPE c VALUE 'X', "
  i_intensified TYPE c,           "
  is_zbukr(10)  TYPE c,
  is_vblnr(10)  TYPE c,
  is_gjahr(10)  TYPE c,
  is_buzei(10)  TYPE c,
  lv_tabix      TYPE sytabix.

* Data Z
DATA:    BEGIN OF s_postab OCCURS 50,
           xauth(1)  TYPE c,            " Berechtigung?
           xhell(1)  TYPE c.            " Hell anzeigen?
           INCLUDE STRUCTURE rfpos.              " Listanzeigen-Struktur
           INCLUDE rfeposc9.                             " Kunden-Sonderfelder
           DATA:      xbkpf(1)  TYPE c,                 " BKPF nachgelesen?
           xbseg(1)  TYPE c,                 " BSEG nachgelesen?
           xbsec(1)  TYPE c,                 " BSEC nachgelesen?
           xbsed(1)  TYPE c,                 " BSED nachgelesen?
           xpayr(1)  TYPE c,                 " PAYR nachgelesen?
           xbsegc(1) TYPE c,                 " BSEGC nachgelesen?
           xbsbv(1)  TYPE c,                 " BSBV nachgelesen?
           xmod(1)   TYPE c,                 " POSTAB modifiziert?
         END OF s_postab.
DATA: wa_bsak TYPE bsak,
      wa_rut  TYPE stcd1,
      ti_bsak TYPE TABLE OF bsak.
*end data z
*----------------------------------------------------------------------*
* Selections                                                           *
*----------------------------------------------------------------------*
SELECT-OPTIONS:
  s_bukr FOR bkpf-bukrs,
  s_beln FOR bkpf-belnr,
  s_blar FOR bkpf-blart  DEFAULT 'ZP' MODIF ID pro,
  s_cpud FOR bkpf-cpudt.

INITIALIZATION.
*
  PERFORM get_label USING 'BKPF' 'S': 'BUKRS' is_zbukr,
                                      'BELNR' is_vblnr,
                                      'GJAHR' is_gjahr.
  PERFORM get_label USING 'BSEG' 'M': 'BUZEI' is_buzei.
*
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    CHECK screen-group1 EQ 'PRO'.
    screen-input = 0.
    MODIFY SCREEN.
  ENDLOOP.
*----------------------------------------------------------------------*
* Check Of The Selections                                              *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON s_bukr.
  SELECT * FROM t001 WHERE bukrs IN s_bukr.
    AUTHORITY-CHECK OBJECT 'F_PAYR_BUK' ID 'BUKRS' FIELD t001-bukrs
                                        ID 'ACTVT' FIELD '02'.
*   Authority check
    IF sy-subrc <> 0.
      SET CURSOR FIELD 'S_BUKR'.
      MESSAGE e515 WITH s_bukr.
    ENDIF.
  ENDSELECT.
* Company code check
  IF sy-subrc <> 0.
    MESSAGE e899 WITH 'Sociedad: ' s_bukr ' NO Existe' ' '.
  ENDIF.
*
*----------------------------------------------------------------------*
* List Title                                                           *
*----------------------------------------------------------------------*
TOP-OF-PAGE.
  FORMAT COLOR COL_BACKGROUND INTENSIFIED ON.
  WRITE TEXT-004.
  WRITE 70 sy-pagno.
  FORMAT COLOR COL_HEADING INTENSIFIED ON.
  WRITE: / sy-uline(70),
         /01 sy-vline NO-GAP, is_zbukr,   "Company code
          10 sy-vline NO-GAP, is_gjahr,   "Fiscal Year
          20 sy-vline NO-GAP, is_vblnr,   "Document number
          34 sy-vline NO-GAP, is_buzei,   "Position
          48 sy-vline NO-GAP, 'Motivo Emisión',
          70 sy-vline NO-GAP,
         /   sy-uline(70).
*
END-OF-PAGE.
  IF i_pageend = 'X'.
    WRITE: / sy-uline(70).
  ENDIF.
*
*----------------------------------------------------------------------*
* Main Program                                                        *
*----------------------------------------------------------------------*
START-OF-SELECTION.
************************************************************************
*
* Reading of the document in the selected field of document
  SELECT * FROM bkpf INTO TABLE z_bkpf
         WHERE bukrs IN s_bukr
           AND belnr IN s_beln
           AND blart IN s_blar
           AND cpudt IN s_cpud
           AND stblg = space.
*
  LOOP AT z_bkpf.
*   Reading of the document items
    SELECT * FROM bseg INTO TABLE t_bseg
             WHERE bukrs      EQ z_bkpf-bukrs
               AND belnr      EQ z_bkpf-belnr
               AND gjahr      EQ z_bkpf-gjahr
               ORDER BY PRIMARY KEY.
*
    CHECK sy-subrc = 0.
*
    CLEAR  : xbseg, ybseg, *bkpf, bkpf.
    REFRESH: xbseg, ybseg.
    t_bkpf = z_bkpf.
    *bkpf  = t_bkpf.
*
    LOOP AT t_bseg WHERE lifnr NE space.
*
      SELECT * FROM bsak INTO TABLE ti_bsak UP TO 1 ROWS
        WHERE     bukrs EQ t_bseg-bukrs
              AND lifnr EQ t_bseg-lifnr
              AND augdt EQ z_bkpf-budat
              AND augbl EQ t_bseg-belnr
              AND belnr NE t_bseg-belnr
              AND xzahl NE 'X'
              AND zzmot_emis NE space
              ORDER BY gjahr DESCENDING belnr DESCENDING.
      CHECK sy-subrc EQ 0.
      READ TABLE ti_bsak INTO wa_bsak INDEX 1.
*
      LOOP AT t_bseg.
        MOVE sy-tabix TO lv_tabix.
*
        MOVE-CORRESPONDING t_bseg TO w_ybseg.
        APPEND w_ybseg TO ybseg.
*
        t_bseg-zzmot_emis = wa_bsak-zzmot_emis.
        MODIFY t_bseg INDEX lv_tabix.
**
        MOVE-CORRESPONDING t_bseg TO w_xbseg.
        APPEND w_xbseg TO xbseg.
*
        MOVE-CORRESPONDING t_bseg TO t_update.
        APPEND t_update.
      ENDLOOP.
    ENDLOOP.
*
    upd_bseg = 'U'.
    bkpf     = t_bkpf.
    APPEND t_bkpf.
*
    upd_bkpf = 'U'.
*
*      Document update
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
*      Create a change document for the document modifications
      objectid = bkpf(21).
      tcode    = 'FB02'.
      utime    = sy-uzeit.
      udate    = sy-datum.
      username = sy-uname.
      SET UPDATE TASK LOCAL.
      PERFORM cd_call_beleg.
      COMMIT WORK.
    ENDIF.
  ENDLOOP.
* Protocol output of updated documents
  LOOP AT t_update.
    AT FIRST.
      CLEAR i_noprot.
      i_ptype   = 'U'.
      NEW-PAGE.
    ENDAT.
    PERFORM protocol_output USING t_update.
    AT LAST.
      WRITE: / sy-uline(70).
      CLEAR i_pageend.
    ENDAT.
  ENDLOOP.
* Protocol output of closed documents
  LOOP AT t_queue.
    AT FIRST.
      i_pageend = 'X'.
      i_ptype   = 'Q'.
      NEW-PAGE.
    ENDAT.
    PERFORM protocol_output USING t_queue.
    AT LAST.
      WRITE: / sy-uline(70).
      CLEAR i_pageend.
    ENDAT.
  ENDLOOP.
* Protocol output of update errors
  LOOP AT t_error.
    AT FIRST.
      i_pageend = 'X'.
      i_ptype   = 'E'.
      NEW-PAGE.
    ENDAT.
    PERFORM protocol_output USING t_error.
    AT LAST.
      WRITE: / sy-uline(70).
      CLEAR i_pageend.
    ENDAT.
  ENDLOOP.
*
  IF i_noprot = 'X'.
    MESSAGE i899 WITH 'Sociedad: ' s_bukr ' Sin Resgistros' ' Seleccionados'.
  ENDIF.
*
**************************************************
* 'form cd_call_beleg'
  INCLUDE ff05lcdc.
*
*----------------------------------------------------------------------*
* Write A Protocol Item                                                *
*----------------------------------------------------------------------*
*
FORM protocol_output USING pline TYPE protocol_line.
  IF i_intensified = space.
    FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
    i_intensified = 'X'.
  ELSE.
    FORMAT COLOR COL_NORMAL INTENSIFIED ON.
    i_intensified = ' '.
  ENDIF.
  WRITE: /01 sy-vline NO-GAP,
             pline-bukrs      NO-GAP, 10 sy-vline NO-GAP,
             pline-gjahr      NO-GAP, 20 sy-vline NO-GAP,
             pline-belnr      NO-GAP, 34 sy-vline NO-GAP,
             pline-buzei      NO-GAP, 48 sy-vline NO-GAP,
             pline-zzmot_emis NO-GAP, 70 sy-vline NO-GAP.
*
ENDFORM.
*
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
ENDFORM.
