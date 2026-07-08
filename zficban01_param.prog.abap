*&---------------------------------------------------------------------*
*&  Include           ZFITR001_PARAM
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-B01.
parameters    :
              p_BUKRS like FEBKO-BUKRS obligatory.   "sociedad
*             p_HBKID like FEBKO-HBKID.   "Banco propio

select-options:
                 s_HBKID for FEBKO-HBKID obligatory,   "Banco propio
                 S_HKTID FOR FEBKO-HKTID.    "cuenta corriente bancaria
*                s_ktonr FOR febko-ktonr,
*                S_WAERS FOR FEBKO-WAERS.


PARAMETERS:  P_FILE TYPE FILENAME
                        DEFAULT 'C:\'
                        OBLIGATORY MEMORY ID A,   "Archivo de Carga
            P_TYPE LIKE RLGRAP-FILETYPE DEFAULT 'ASC' OBLIGATORY,
            p_file2 TYPE filename DEFAULT 'C:\auszug.txt' obligatory,  "auszug.
            p_file3 TYPE filename DEFAULT 'C:\umsatz.txt' obligatory.  "umsatz. "Tipo de Archivo

*PARAMETERS: P_LIST(20) AS LISTBOX VISIBLE LENGTH 10.
PARAMETERS kz_app as checkbox default 'X'.    "RADIOBUTTON GROUP 0001 DEFAULT 'X'.

PARAMETERS: LDS_NAME     LIKE FILENAME-FILEINTERN
                         DEFAULT 'ZCB_FICHEROS'.


  SELECTION-SCREEN END OF BLOCK B1.

  SELECTION-SCREEN  BEGIN OF BLOCK 1 WITH FRAME TITLE text-165.
PARAMETERS:     einlesen     LIKE rfpdo1-febeinles default 'X',
                format       LIKE rfpdo1-febformat DEFAULT 'M' NO-DISPLAY, " AS
*                LISTBOX VISIBLE LENGTH 30 USER-COMMAND bai no-DISPLAY,
                AUSZFILE     LIKE  RFPDO1-FEBAUSZF NO-DISPLAY,
                umsfile      LIKE rfpdo1-febumsf no-DISPLAY,
                PCUPLOAD     LIKE RFPDO1-FEBPCUPLD DEFAULT 'X',
                NULLUMSA     LIKE RFPDO1-NULLUMSATZ.          "n1085596
SELECTION-SCREEN  END OF BLOCK 1.


*------- Buchungsparameter ---------------------------------------------
SELECTION-SCREEN  BEGIN OF BLOCK 2 WITH FRAME TITLE text-160.
*SELECTION-SCREEN  BEGIN OF LINE.
PARAMETERS: pa_xcall TYPE febpdo-xcall    RADIOBUTTON GROUP 1 DEFAULT 'X'.
*SELECTION-SCREEN
*  COMMENT 03(29) FOR FIELD pa_xcall.
PARAMETERS: pa_xbkbu TYPE febpdo-xbkbu.
*SELECTION-SCREEN
*  COMMENT 35(16) text-171 FOR FIELD pa_xbkbu.
PARAMETERS: pa_mode  TYPE rfpdo-allgazmd NO-DISPLAY.
*SELECTION-SCREEN: END OF LINE.

SELECTION-SCREEN  BEGIN OF LINE.
PARAMETERS: pa_xbdc  LIKE febpdo-xbinpt   RADIOBUTTON GROUP 1 .
SELECTION-SCREEN
  COMMENT 03(29) text-163 FOR FIELD pa_xbdc.
SELECTION-SCREEN
  COMMENT 35(20) text-164 FOR FIELD mregel.
PARAMETERS: mregel   LIKE rfpdo1-febmregel DEFAULT '1'.
SELECTION-SCREEN: END OF LINE.

SELECTION-SCREEN: BEGIN OF LINE.
PARAMETERS: pa_test LIKE rfpdo1-febtestl RADIOBUTTON GROUP 1 .
SELECTION-SCREEN
  COMMENT 03(29) text-168 FOR FIELD pa_test.
SELECTION-SCREEN: END OF LINE.

PARAMETERS: valut_on     LIKE rfpdo2-febvalut DEFAULT 'X'.
SELECTION-SCREEN  END OF BLOCK 2.

*------- Finanzdisposition ---------------------------------------------
*SELECTION-SCREEN  BEGIN OF BLOCK 5 WITH FRAME TITLE text-172.
*SELECTION-SCREEN: BEGIN OF LINE.
*PARAMETERS: pa_xdisp LIKE febpdo-xdisp.
*SELECTION-SCREEN
*  COMMENT 03(29) text-170 FOR FIELD pa_xdisp.
*PARAMETERS: pa_verd  LIKE rfffpdo1-ffdisxverd.
*SELECTION-SCREEN
*  COMMENT 34(15) text-174 FOR FIELD pa_verd.
*SELECTION-SCREEN
*  COMMENT 55(15) text-173 FOR FIELD pa_dsart.
*PARAMETERS: pa_dsart LIKE fdes-dsart.
*SELECTION-SCREEN: END OF LINE.
*PARAMETERS: intraday     LIKE rfpdo1_en-akintraday AS CHECKBOX.
*
*
*SELECTION-SCREEN  END OF BLOCK 5.

*C5060356
*------- BAI Preprocessor --------------------------------------
*SELECTION-SCREEN  BEGIN OF BLOCK 6 WITH FRAME TITLE text-007 .
*PARAMETERS:     p_baipre   TYPE bai_prep AS CHECKBOX MODIF ID mo1,
*                p_priord   LIKE prior_day AS CHECKBOX MODIF ID mo1,
*                p_stop     LIKE stop_flag AS CHECKBOX MODIF ID mo1.
*SELECTION-SCREEN  END OF BLOCK 6.


*------- Interpretationsparameter --------------------------------------
*SELECTION-SCREEN  BEGIN OF BLOCK 3 WITH FRAME TITLE text-166.
*DATA: num10(10) TYPE n.
*DATA: chr16(16) TYPE c.
*SELECT-OPTIONS: s_filter FOR  febpdo-febfilter1.
*SELECT-OPTIONS: t_filter FOR  febpdo-febfilter2.
*SELECTION-SCREEN: BEGIN OF LINE.
*SELECTION-SCREEN
*   COMMENT 01(31) text-176 FOR FIELD pa_bdart.
*PARAMETERS: pa_bdart     LIKE febpdo-bdart.
*SELECTION-SCREEN
*   COMMENT 36(21) text-177 FOR FIELD pa_bdanz.
*PARAMETERS: pa_bdanz     LIKE febpdo-bdanz.
*SELECTION-SCREEN: END OF LINE.
*SELECTION-SCREEN  END OF BLOCK 3.

*------- Ausgabeparameter ----------------------------------------------
SELECTION-SCREEN  BEGIN OF BLOCK 4 WITH FRAME TITLE text-167.
PARAMETERS: batch        LIKE rfpdo2-febbatch,
            p_koausz     LIKE rfpdo1-febpausz default 'X',   " Kontoauszug drucken
            p_bupro      LIKE rfpdo2-febbupro default 'X',
            p_statik     LIKE rfpdo2-febstat,
            pa_lsepa     LIKE febpdo-lsepa.
SELECTION-SCREEN  END OF BLOCK 4.
