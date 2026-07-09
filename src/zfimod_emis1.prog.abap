*$*$********************************************************************
*$*$                                                                   *
*$*$ PROGRAMAM  : ZZFIMOD_EMIS1                                         *
*$*$ DESCRIPCION: Programa que modifica Campo BSEG-ZZMOT_EMIS          *
*$*$              En los pagos masivos con Via de Pago V o T, el campo *
*$*$              T_BSEG-ZZMOT_EMIS no se llena en el Documento¨de     *
*$*$              pago, para lo cual este programa busca la Factura y  *
*$*$              saca el contenido de este campo y lo traslada al pago*
*$*$                                                                   *
*$*$ AUTOR      : VisioOne.                                            *
*$*$                                                                   *
*$*$ DATA    : 03/07/2014.                                             *
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
REPORT  ZFIMOD_EMIS
        MESSAGE-ID FS
        NO STANDARD PAGE HEADING
        LINE-SIZE 132.
*
*----------------------------------------------------------------------*
* Data Declarations                                                    *
*----------------------------------------------------------------------*
INCLUDE FF05LCDV.                "function module BELEG_WRITE_DOCUMENT
INCLUDE FF05LCDF.                "form CD_CALL_BELEG
*
TABLES:
*
  T001,                          "Company Codes
  BSEG,                          "Accounting document segment
  RFSDO,                         "Data elements for selection
  BSEC, BSED, BSET.
*
TYPES:
  BEGIN OF PROTOCOL_LINE,        "Protocol line
    BUKRS LIKE BSEG-BUKRS,
    BELNR LIKE BSEG-BELNR,
    GJAHR LIKE BSEG-GJAHR,
    BUZEI LIKE BSEG-BUZEI,
  END OF PROTOCOL_LINE.
*
*
DATA:
  Z_BKPF        LIKE BKPF   OCCURS 0 WITH HEADER LINE,
  T_BKPF        LIKE BKPF   OCCURS 1 WITH HEADER LINE,
  T_BSEG        LIKE BSEG   OCCURS 0 WITH HEADER LINE,
  T_BKDF        LIKE BKDF   OCCURS 0 WITH HEADER LINE,
  T_BSEC        LIKE BSEC   OCCURS 0 WITH HEADER LINE,
  T_BSED        LIKE BSED   OCCURS 0 WITH HEADER LINE,
  T_BSET        LIKE BSET   OCCURS 0 WITH HEADER LINE,
  T_UPDATE      TYPE PROTOCOL_LINE OCCURS 0 WITH HEADER LINE,
  T_QUEUE       TYPE PROTOCOL_LINE OCCURS 0 WITH HEADER LINE,
  T_ERROR       TYPE PROTOCOL_LINE OCCURS 0 WITH HEADER LINE,
  t_multi       TYPE protocol_line OCCURS 0 WITH HEADER LINE,
  W_XBSEG       LIKE FBSEG,
  W_YBSEG       LIKE FBSEG,
  I_NOPROT      TYPE C VALUE 'X',
  I_PTYPE       TYPE C,
  I_PAGEEND     TYPE C VALUE 'X', "
  I_INTENSIFIED TYPE C,           "
  IS_ZBUKR(10)  TYPE C,
  IS_VBLNR(10)  TYPE C,
  IS_GJAHR(10)  TYPE C,
  IS_BUZEI(10)  TYPE C.

* Data Z
  data:    begin of s_postab occurs 50,
               xauth(1)      type c,            " Berechtigung?
               xhell(1)      type c.            " Hell anzeigen?
          include structure rfpos.              " Listanzeigen-Struktur
  include rfeposc9.                             " Kunden-Sonderfelder
  data:      xbkpf(1)      type c,                 " BKPF nachgelesen?
             xbseg(1)      type c,                 " BSEG nachgelesen?
             xbsec(1)      type c,                 " BSEC nachgelesen?
             xbsed(1)      type c,                 " BSED nachgelesen?
             xpayr(1)      type c,                 " PAYR nachgelesen?
             xbsegc(1)     type c,                 " BSEGC nachgelesen?
             xbsbv(1)      type c,                 " BSBV nachgelesen?
             xmod(1)       type c,                 " POSTAB modifiziert?
           end of s_postab.
  data: wa_bsak type bsak,
        wa_rut type STCD1.
*end data z
*----------------------------------------------------------------------*
* Selections                                                           *
*----------------------------------------------------------------------*
  SELECT-OPTIONS:
    S_BUKR FOR BKPF-BUKRS,
    S_BELN FOR BKPF-BELNR,
    S_BLAR FOR BKPF-BLART,
    S_CPUD FOR BKPF-CPUDT.

INITIALIZATION.
*
  PERFORM GET_LABEL USING 'BKPF' 'S': 'BUKRS' IS_ZBUKR,
                                      'BELNR' IS_VBLNR,
                                      'GJAHR' IS_GJAHR.
  PERFORM GET_LABEL USING 'BSEG' 'M': 'BUZEI' IS_BUZEI.
*
*----------------------------------------------------------------------*
* Check Of The Selections                                              *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON S_BUKR.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM T001 WHERE BUKRS IN S_BUKR.
*
* NEW CODE
  SELECT *
 FROM T001 WHERE BUKRS IN S_BUKR ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    AUTHORITY-CHECK OBJECT 'F_PAYR_BUK' ID 'BUKRS' FIELD T001-BUKRS
                                        ID 'ACTVT' FIELD '02'.
*   Authority check
    IF SY-SUBRC <> 0.
      SET CURSOR FIELD 'S_BUKR'.
      MESSAGE E515 WITH S_BUKR.
     ENDIF.
  ENDSELECT.
* Company code check
  IF SY-SUBRC <> 0.
     MESSAGE E899 with 'Sociedad: ' S_BUKR ' NO Existe' ' '.
  ENDIF.
*
*----------------------------------------------------------------------*
* List Title                                                           *
*----------------------------------------------------------------------*
TOP-OF-PAGE.
  FORMAT COLOR COL_BACKGROUND INTENSIFIED ON.
  write text-004.
  WRITE 50 SY-PAGNO.
  FORMAT COLOR COL_HEADING INTENSIFIED ON.
  WRITE: / SY-ULINE(50),
         /01 SY-VLINE NO-GAP, IS_ZBUKR,   "Company code
          12 SY-VLINE NO-GAP, IS_GJAHR,   "Fiscal Year
          23 SY-VLINE NO-GAP, IS_VBLNR,   "Document number
          34 SY-VLINE NO-GAP, IS_BUZEI,   "Position
          50 sy-VLINE NO-GAP,
         /   SY-ULINE(50).
*
END-OF-PAGE.
  IF I_PAGEEND = 'X'.
    WRITE: / SY-ULINE(50).
  ENDIF.
*
*----------------------------------------------------------------------*
* Main Program                                                        *
*----------------------------------------------------------------------*
START-OF-SELECTION.
************************************************************************
*
* Reading of the document in the selected field of document
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM BKPF INTO TABLE Z_BKPF
*         WHERE BUKRS IN S_BUKR
*           AND BELNR IN S_BELN
*           AND BLART IN S_BLAR
*           AND CPUDT IN S_CPUD
*           AND STBLG = space.
*
* NEW CODE
  SELECT *
 FROM BKPF INTO TABLE Z_BKPF
         WHERE BUKRS IN S_BUKR
           AND BELNR IN S_BELN
           AND BLART IN S_BLAR
           AND CPUDT IN S_CPUD
           AND STBLG = space ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
*
  LOOP AT Z_BKPF.
    CLEAR:   T_BSEG.
    CLEAR:   xbseg, ybseg, *bkpf, bkpf.
    REFRESH: xbseg, ybseg.
    T_BKPF = Z_BKPF.
*
    CHECK SY-SUBRC = 0.
    *BKPF = T_BKPF.
*   Reading of the document items
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM BSEG INTO TABLE T_BSEG
*             WHERE BUKRS = Z_BKPF-BUKRS
*               AND BELNR = Z_BKPF-BELNR
*               AND GJAHR = Z_BKPF-GJAHR.
*
* NEW CODE
    SELECT *
 FROM BSEG INTO TABLE T_BSEG
             WHERE BUKRS = Z_BKPF-BUKRS
               AND BELNR = Z_BKPF-BELNR
               AND GJAHR = Z_BKPF-GJAHR ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
*
    CHECK SY-SUBRC = 0.
    LOOP AT T_BSEG.
        CHECK t_bseg-ZZMOT_EMIS = ' '.
        CLEAR wa_bsak.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        select single * from bsak into wa_bsak
*          where     bukrs = t_bseg-bukrs
*                and augbl = t_bseg-belnr
*                and gjahr = t_bseg-gjahr
*                and belnr ne t_bseg-belnr
*                and xzahl ne 'X'.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  from bsak into wa_bsak
          where     bukrs = t_bseg-bukrs
                and augbl = t_bseg-belnr
                and gjahr = t_bseg-gjahr
                and belnr ne t_bseg-belnr
                and xzahl ne 'X' ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        CHECK sy-subrc eq 0.
*
        MOVE-CORRESPONDING T_BSEG TO W_YBSEG.
        APPEND W_YBSEG TO YBSEG.
        T_BSEG-ZZMOT_EMIS = wa_bsak-ZZMOT_EMIS.
*
        MODIFY T_BSEG.
        MOVE-CORRESPONDING T_BSEG TO W_XBSEG.
        APPEND W_XBSEG TO XBSEG.
        MOVE-CORRESPONDING T_BSEG TO T_UPDATE.
        APPEND T_UPDATE.
    ENDLOOP.
    UPD_BSEG = 'U'.
    BKPF = T_BKPF.
    APPEND T_BKPF.
    UPD_BKPF = 'U'.
*   Enqueue document for update
*   CALL FUNCTION 'ENQUEUE_EFBKPF'
*        EXPORTING  MODE_BKPF      = 'E'
*                   MANDT          = SY-MANDT
*                   BUKRS          = T_BKPF-BUKRS
*                   BELNR          = T_BKPF-BELNR
*                   GJAHR          = T_BKPF-GJAHR
*        EXCEPTIONS FOREIGN_LOCK   = 1
*                   SYSTEM_FAILURE = 2
*                   OTHERS         = 3.
*
    IF SY-SUBRC = 0.
*      Document update
       CALL FUNCTION 'CHANGE_DOCUMENT'
            TABLES     T_BKDF = T_BKDF
                       T_BKPF = T_BKPF
                       T_BSEC = T_BSEC
                       T_BSED = T_BSED
                       T_BSEG = T_BSEG
                       T_BSET = T_BSET
            EXCEPTIONS OTHERS = 4.
*
       IF SY-SUBRC = 0.
*      Create a change document for the document modifications
          OBJECTID = BKPF(21).
          TCODE    = 'FB02'.
          UTIME    = SY-UZEIT.
          UDATE    = SY-DATUM.
          USERNAME = SY-UNAME.
          SET UPDATE TASK LOCAL.
          PERFORM CD_CALL_BELEG.
          COMMIT WORK.
       endif.
*
    ENDIF.
  ENDLOOP.
* Protocol output of updated documents
  LOOP AT T_UPDATE.
    AT FIRST.
      CLEAR I_NOPROT.
      I_PTYPE   = 'U'.
      NEW-PAGE.
    ENDAT.
    PERFORM PROTOCOL_OUTPUT USING T_UPDATE.
    AT LAST.
      WRITE: / SY-ULINE(50).
      CLEAR I_PAGEEND.
    ENDAT.
  ENDLOOP.
* Protocol output of closed documents
  LOOP AT T_QUEUE.
    AT FIRST.
      I_PAGEEND = 'X'.
      I_PTYPE   = 'Q'.
      NEW-PAGE.
    ENDAT.
    PERFORM PROTOCOL_OUTPUT USING T_QUEUE.
    AT LAST.
      WRITE: / sy-uline(50).
      CLEAR i_pageend.
    ENDAT.
  ENDLOOP.
* Protocol output of update errors
  LOOP AT T_ERROR.
    AT FIRST.
      I_PAGEEND = 'X'.
      I_PTYPE   = 'E'.
      NEW-PAGE.
    ENDAT.
    PERFORM PROTOCOL_OUTPUT USING T_ERROR.
    AT LAST.
      WRITE: / SY-ULINE(50).
      CLEAR I_PAGEEND.
    ENDAT.
  ENDLOOP.
*
  IF I_NOPROT = 'X'.
    MESSAGE I899 with 'Sociedad: ' S_BUKR ' Sin Resgistros' ' Seleccionados'.
  ENDIF.
*
**************************************************
* 'form cd_call_beleg'
INCLUDE FF05LCDC.
*
*----------------------------------------------------------------------*
* Write A Protocol Item                                                *
*----------------------------------------------------------------------*
*
FORM PROTOCOL_OUTPUT USING PLINE TYPE PROTOCOL_LINE.
  IF I_INTENSIFIED = SPACE.
    FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
    I_INTENSIFIED = 'X'.
  ELSE.
    FORMAT COLOR COL_NORMAL INTENSIFIED ON.
    I_INTENSIFIED = ' '.
  ENDIF.
  WRITE: /01 SY-VLINE NO-GAP,
             PLINE-BUKRS NO-GAP, 12 SY-VLINE NO-GAP,
             PLINE-GJAHR NO-GAP, 23 SY-VLINE NO-GAP,
             PLINE-BELNR NO-GAP, 34 SY-VLINE NO-GAP,
             PLINE-BUZEI NO-GAP, 50 SY-VLINE NO-GAP.
*
ENDFORM.
*
*----------------------------------------------------------------------*
* Get The Data Dictionary Label Of A Table Field                       *
*----------------------------------------------------------------------*
FORM GET_LABEL USING    TABLE_NAME TYPE DDOBJNAME
                        LABEL_TYPE TYPE CLIKE
                        FIELD_NAME TYPE DFIES-FIELDNAME
               CHANGING LABEL      TYPE CLIKE.
  DATA: lt_dfies like dfies occurs 0 with header line.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
       EXPORTING  TABNAME        = TABLE_NAME
                  FIELDNAME      = FIELD_NAME
                  LANGU          = SY-LANGU
       tables     DFIES_tab      = lt_dfies
       EXCEPTIONS NOT_FOUND      = 1
                  INTERNAL_ERROR = 2
                  OTHERS         = 3.
  IF SY-SUBRC = 0.
    read table lt_dfies index 1.
    CASE LABEL_TYPE.
      WHEN 'S'. LABEL = lt_dfies-SCRTEXT_S.
      WHEN 'M'. LABEL = lt_dfies-SCRTEXT_M.
      WHEN 'L'. LABEL = lt_dfies-SCRTEXT_L.
    ENDCASE.
  ENDIF.
ENDFORM.
