*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZFILIB006_INC2 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_FILE USING SPATH_FILE.
*data SPATH_FILE type rlgrap-filename.
  CLEAR GT_DATA.
  REFRESH GT_DATA.
  PATH_FILE = SPATH_FILE.
  CONCATENATE PATH_FILE '\RETENCION' '_' SY-DATUM '_' SY-UZEIT '.txt' INTO PATH_FILE.
  PERFORM CREA_DIRECTORIO USING SPATH_FILE.
  PERFORM PREPARA_FILE USING PATH_FILE.
ENDFORM.                    " GET_FILE

*&---------------------------------------------------------------------*
*&      Form  Crea_directorio
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PPATH_FILE text
*----------------------------------------------------------------------*
FORM CREA_DIRECTORIO USING PPATH_FILE.
  DATA: P_DIR TYPE RLGRAP-FILENAME.
  P_DIR = PPATH_FILE.

  CALL FUNCTION 'GUI_CREATE_DIRECTORY'
    EXPORTING
      DIRNAME = P_DIR
    EXCEPTIONS
      FAILED  = 1
      OTHERS  = 2.

ENDFORM.                    "Crea_directorio
*&---------------------------------------------------------------------*
*&      Form  PREPARA_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PATH_FILE  text
*----------------------------------------------------------------------*
FORM PREPARA_FILE  USING    P_PATH_FILE.
  DATA : LS_OUTPUT LIKE OUTPUT_LIST.
  DATA : LS2_OUTPUT LIKE OUTPUT_LIST.
  DATA: V_LONG TYPE I.
  DATA: V_LEN TYPE I.
  DATA: L_CONTLINES TYPE I.
  DATA:L_WT_QSSHH TYPE WITH_ITEM-WT_QSSHH.
  DATA:L_WT_QBSHH TYPE WITH_ITEM-WT_QSSHH.
  DATA:L_DMBTR    TYPE WITH_ITEM-WT_QSSHH.
  DATA: L_TABIX   TYPE I. " TABIX DEL LOOP PRINCIPAL
  DATA: L_NEXTTABIX   TYPE I. " PARA PREGUNTAR POR ELPROXIMO REGISTRO
  DATA: T_REG TYPE I.

  V_HORIZ_TAB = CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB.
  V_NEWLINE   = CL_ABAP_CHAR_UTILITIES=>NEWLINE.

*  TXTDR = '123456789012345678901234567890'.
  G_LINEAS = 1.
  G_PRIMERO = 0.
  L_CONTLINES = 0.

  DESCRIBE TABLE output_list LINES T_REG.
  LOOP AT OUTPUT_LIST INTO LS_OUTPUT.
    L_TABIX  = SY-TABIX.
    L_NEXTTABIX = SY-TABIX + 1.
    L_CONTLINES = L_CONTLINES + 1.
    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        DATE_INTERNAL = LS_OUTPUT-BLDAT
      IMPORTING
        DATE_EXTERNAL = TXT6.


    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        DATE_INTERNAL = LS_OUTPUT-BUDAT
      IMPORTING
        DATE_EXTERNAL = TXT7.

    IF G_LINEAS LE G_LINE.
      IF G_PRIMERO = 0.
        PERFORM CABECERA.
        PERFORM NEW_PAGE.
        CLEAR G_TOTLAUFD.
        CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
          EXPORTING
            DATE_INTERNAL = LS_OUTPUT-BLDAT
          IMPORTING
            DATE_EXTERNAL = TXT6.


        CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
          EXPORTING
            DATE_INTERNAL = LS_OUTPUT-BUDAT
          IMPORTING
            DATE_EXTERNAL = TXT7.
*            SE BUSCA DIRECCION
         PERFORM Addr_lifnr USING LS_OUTPUT-LIFNR
                         CHANGING ADDRS.

        TXTDR = ADDRS.
        G_PRIMERO = 1.
        TXT1 = LS_OUTPUT-LTEXT. " DESCRIP
        TXT2 = LS_OUTPUT-BELNR. " DOCUMENTO
        TXT3 = LS_OUTPUT-STCD1. " RUT
        TXT4 = LS_OUTPUT-NAME1. " NOMBRE
        TXT5 = LS_OUTPUT-ZUONR. " BOLETA
        WRITE : LS_OUTPUT-WT_QSSHH TO TXT8 CURRENCY LS_OUTPUT-WAERS. " VALOR BOLETA
        WRITE : LS_OUTPUT-WT_QBSHH TO TXT9 CURRENCY LS_OUTPUT-WAERS. " VALOR RETENCION
        WRITE : LS_OUTPUT-DMBTR TO TXT10 CURRENCY LS_OUTPUT-WAERS. " VALOR A PAGAR
        L_WT_QSSHH = L_WT_QSSHH + LS_OUTPUT-WT_QSSHH. " VALOR BOLETA
        L_WT_QBSHH = L_WT_QBSHH + LS_OUTPUT-WT_QBSHH." VALOR RETENCION
        L_DMBTR    = L_DMBTR + LS_OUTPUT-DMBTR. " VALOR A PAGAR
        G_TOTLAUFD = 1.



      ELSE.
*         SE BUSCA DIRECCION
          PERFORM Addr_lifnr USING LS_OUTPUT-LIFNR
                          CHANGING ADDRS.

        TXTDR = ADDRS.
        TXT1 = LS_OUTPUT-LTEXT. " BLART
        TXT2 = LS_OUTPUT-BELNR. " DOCUMENTO
        TXT3 = LS_OUTPUT-STCD1. " RUT
        TXT4 = LS_OUTPUT-NAME1. " NOMBRE
        TXT5 = LS_OUTPUT-ZUONR. " BOLETA
        WRITE : LS_OUTPUT-WT_QSSHH TO TXT8 CURRENCY LS_OUTPUT-WAERS. " VALOR BOLETA
        WRITE : LS_OUTPUT-WT_QBSHH TO TXT9 CURRENCY LS_OUTPUT-WAERS. " VALOR RETENCION
        WRITE : LS_OUTPUT-DMBTR TO TXT10 CURRENCY LS_OUTPUT-WAERS. " VALOR A PAGAR
        L_WT_QSSHH = L_WT_QSSHH + LS_OUTPUT-WT_QSSHH. " VALOR BOLETA
        L_WT_QBSHH = L_WT_QBSHH + LS_OUTPUT-WT_QBSHH." VALOR RETENCION
        L_DMBTR    = L_DMBTR + LS_OUTPUT-DMBTR. " VALOR A PAGAR
        G_TOTLAUFD =  G_TOTLAUFD + 1.
      ENDIF.

      IF  TXT7 IS INITIAL.
        CONCATENATE '-' TXT5 INTO TXT5.
      ENDIF.

      IF  TXT8 IS INITIAL.
        CONCATENATE '-' TXT7 INTO TXT7.
      ENDIF.

    ELSE.  " titulo
*         PERFORM Subtotal.
      PERFORM CABECERA.
      PERFORM NEW_PAGE.
      G_LINEAS = 1.
      CLEAR G_TOTLAUFD.
      G_TOTLAUFD =  1.

     CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        DATE_INTERNAL = LS_OUTPUT-BLDAT
      IMPORTING
        DATE_EXTERNAL = TXT6.


    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        DATE_INTERNAL = LS_OUTPUT-BUDAT
      IMPORTING
        DATE_EXTERNAL = TXT7.
*     SE BUSCA DIRECCION
      PERFORM Addr_lifnr USING LS_OUTPUT-LIFNR
                      CHANGING ADDRS.
      TXT1 = LS_OUTPUT-LTEXT. " BLART
      TXT2 = LS_OUTPUT-BELNR. " DOCUMENTO
      TXT3 = LS_OUTPUT-STCD1. " RUT
      TXT4 = LS_OUTPUT-NAME1. " NOMBRE
      TXT5 = LS_OUTPUT-ZUONR. " BOLETA
      WRITE : LS_OUTPUT-WT_QSSHH TO TXT8 CURRENCY LS_OUTPUT-WAERS. " VALOR BOLETA
      WRITE : LS_OUTPUT-WT_QBSHH TO TXT9 CURRENCY LS_OUTPUT-WAERS. " VALOR RETENCION
      WRITE : LS_OUTPUT-DMBTR TO TXT10 CURRENCY LS_OUTPUT-WAERS. " VALOR A PAGAR
       L_WT_QSSHH = L_WT_QSSHH + LS_OUTPUT-WT_QSSHH. " VALOR BOLETA
       L_WT_QBSHH = L_WT_QBSHH + LS_OUTPUT-WT_QBSHH." VALOR RETENCION
       L_DMBTR    = L_DMBTR + LS_OUTPUT-DMBTR. " VALOR A PAGAR
    ENDIF.

    SHIFT TXT8 RIGHT DELETING TRAILING SPACE.
    SHIFT TXT9 RIGHT DELETING TRAILING SPACE.
    SHIFT TXT10 RIGHT DELETING TRAILING SPACE.


    CLEAR S_TEXTO.
* se arma texto patra colocar en Tabla interna
    CLEAR S_TEXTO.
      S_TEXTO+0(5)  = L_CONTLINES.
      S_TEXTO+5(15)  = TXT2.
      S_TEXTO+20(15) = TXT3.
      S_TEXTO+35(30)  = TXT4.
      S_TEXTO+65(40)  = TXTDR.
      S_TEXTO+105(15)  = TXT5.
      S_TEXTO+120(15)  = TXT6.
      S_TEXTO+135(15)  = TXT7.
      S_TEXTO+155(15)  = TXT8.
      S_TEXTO+170(15)  = TXT9.
      S_TEXTO+185(15)  = TXT10.


    APPEND S_TEXTO TO GT_DATA.
    G_LINEAS = G_LINEAS + 1.

*        subtotales.
    READ TABLE OUTPUT_LIST INDEX L_NEXTTABIX INTO LS2_OUTPUT.
    IF LS2_OUTPUT-LTEXT NE LS_OUTPUT-LTEXT OR T_REG EQ L_TABIX . " SI HAY DIFERENCIA SE AGREGA EL SUBTOTAL
        PERFORM SUBTOTALES USING LS_OUTPUT-LTEXT
                                 L_WT_QSSHH
                                 L_WT_QBSHH
                                 L_DMBTR
                                 LS_OUTPUT-WAERS.
    ENDIF.

  ENDLOOP.
*  PERFORM  TOTAL_RETENCION.
  PERFORM  RESUMEN_FILE.
  PERFORM  GUI_DOWNLOAD_F USING P_PATH_FILE.

ENDFORM.                    " PREPARA_FILE
*&---------------------------------------------------------------------*
*&      Form  GUI_DOWNLOAD_F
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PATH_FILE  text
*----------------------------------------------------------------------*
FORM GUI_DOWNLOAD_F USING PATH_FILE.
  DATA: XTEXTM(100) TYPE C.

  DATA : NOMBRE_A  TYPE STRING.
  NOMBRE_A = PATH_FILE.

  CALL FUNCTION 'GUI_DOWNLOAD'
  EXPORTING
    FILENAME                = NOMBRE_A
    FILETYPE                = 'ASC'
    APPEND                  = ' '
    CONFIRM_OVERWRITE       = ' '
  TABLES
*      data_tab                = reg_stder
    DATA_TAB                = GT_DATA
  EXCEPTIONS
    FILE_WRITE_ERROR        = 1
    NO_BATCH                = 2
    GUI_REFUSE_FILETRANSFER = 3
    INVALID_TYPE            = 4
    NO_AUTHORITY            = 5
    UNKNOWN_ERROR           = 6
    HEADER_NOT_ALLOWED      = 7
    SEPARATOR_NOT_ALLOWED   = 8
    FILESIZE_NOT_ALLOWED    = 9
    HEADER_TOO_LONG         = 10
    DP_ERROR_CREATE         = 11
    DP_ERROR_SEND           = 12
    DP_ERROR_WRITE          = 13
    UNKNOWN_DP_ERROR        = 14
    ACCESS_DENIED           = 15
    DP_OUT_OF_MEMORY        = 16
    DISK_FULL               = 17
    DP_TIMEOUT              = 18
    FILE_NOT_FOUND          = 19
    DATAPROVIDER_EXCEPTION  = 20
    CONTROL_FLUSH_ERROR     = 21
    OTHERS                  = 22.



  IF SY-SUBRC <> 0.
    WRITE :/ 'error!!!!'  ,
           /  SY-MSGV1 ,
           /  SY-MSGV2 ,
           /  SY-MSGV3 ,
           /  SY-MSGV4 .
  ELSE.
*    SKIP 2 .
**    FORMAT COLOR 3 ON.
    CONCATENATE 'Se genero archivo :' PATH_FILE INTO XTEXTM.
    MESSAGE  XTEXTM TYPE 'S'.
**     WRITE : / 'Se genero archivo :', PATH_FILE.
**    FORMAT COLOR 3 OFF.
  ENDIF.
ENDFORM. "  GUI_DOWNLOAD_F
*&---------------------------------------------------------------------*
*&      Form  NEW_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM NEW_PAGE.
  DATA :  P_LINEA(200) TYPE C.
  DO 200 TIMES.
    CONCATENATE P_LINEA '-' INTO P_LINEA.
  ENDDO.

  S_TEXTO = '     '.
  CONCATENATE S_TEXTO V_NEWLINE  INTO S_TEXTO.
  SHIFT S_TEXTO RIGHT DELETING TRAILING SPACE.
  APPEND S_TEXTO TO GT_DATA.
  APPEND S_TEXTO TO GT_DATA.
  APPEND S_TEXTO TO GT_DATA.
  APPEND S_TEXTO TO GT_DATA.

  TXT1 = 'Tipo Doc'.
  TXT2 = 'Documento'.
  TXT3 = 'R.U.T.'.
  TXT4 = 'Nombre'.
  TXT5 = 'Boleta'.
  TXT6 = 'Fecha Boleta'.
  TXT7 = 'Fecha Doc'.
  TXT8 = 'Val. Boleta'.
  TXT9 = 'Val. Retenc.'.
  TXT10 = 'Val. Pagar'.
  TXTDR = 'Dirección'.

*  SHIFT TXT1 RIGHT DELETING TRAILING SPACE.
*  SHIFT TXT2 RIGHT DELETING TRAILING SPACE.
*  SHIFT TXT3 RIGHT DELETING TRAILING SPACE.
*  SHIFT TXT4 RIGHT DELETING TRAILING SPACE.
*  SHIFT TXT5 RIGHT DELETING TRAILING SPACE.
*  SHIFT TXT6 RIGHT DELETING TRAILING SPACE.
*  SHIFT TXT7 RIGHT DELETING TRAILING SPACE.
  SHIFT TXT8 RIGHT DELETING TRAILING SPACE.
  SHIFT TXT9 RIGHT DELETING TRAILING SPACE.
  SHIFT TXT10 RIGHT DELETING TRAILING SPACE.

*  CONCATENATE TXT1 V_HORIZ_TAB
*         TXT2 V_HORIZ_TAB
*         TXT3 V_HORIZ_TAB
*         TXT4 V_HORIZ_TAB
*         TXT5 V_HORIZ_TAB
*         TXT6 V_HORIZ_TAB
*         TXT7 V_HORIZ_TAB
*         TXT8 V_NEWLINE  INTO S_TEXTO.

  APPEND P_LINEA TO GT_DATA.

  CLEAR S_TEXTO.

*      S_TEXTO+0(5)  = L_CONTLINES.
      S_TEXTO+5(15)  = TXT2.
      S_TEXTO+20(15) = TXT3.
      S_TEXTO+35(30)  = TXT4.
      S_TEXTO+65(40)  = TXTDR.
      S_TEXTO+105(15)  = TXT5.
      S_TEXTO+120(15)  = TXT6.
      S_TEXTO+135(15)  = TXT7.
      S_TEXTO+155(15)  = TXT8.
      S_TEXTO+170(15)  = TXT9.
      S_TEXTO+185(15)  = TXT10.


  APPEND S_TEXTO TO GT_DATA.

  APPEND P_LINEA TO GT_DATA.

ENDFORM. " NEW_PAGE
*&---------------------------------------------------------------------*
*&      Form  CABECERA
*&---------------------------------------------------------------------*
*       SE CREA CABEZERA
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CABECERA .
  DATA :  P_LINEA(240) TYPE C.
  DATA :  P_BUTXT LIKE T001-BUTXT.
***** se extrae la descripcion de la sociedad

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE BUTXT
*    INTO P_BUTXT
*    FROM T001
*    WHERE BUKRS EQ S_COMPY.
*
* NEW CODE
  SELECT BUTXT
  UP TO 1 ROWS 
    INTO P_BUTXT
    FROM T001
    WHERE BUKRS EQ S_COMPY ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  S_TEXTO = '     '.
  CONCATENATE S_TEXTO V_NEWLINE  INTO S_TEXTO.
  SHIFT S_TEXTO RIGHT DELETING TRAILING SPACE.
  APPEND S_TEXTO TO GT_DATA.
  APPEND S_TEXTO TO GT_DATA.
  APPEND S_TEXTO TO GT_DATA.
  APPEND S_TEXTO TO GT_DATA.
  APPEND S_TEXTO TO GT_DATA.
  APPEND S_TEXTO TO GT_DATA.

  TXT1 = 'Sociedad : '.
  TXT2 = P_BUTXT.
  S_TEXTO+0(20)  = TXT1.
  S_TEXTO+20(30) = TXT2.
  APPEND S_TEXTO TO GT_DATA.

  S_TEXTO = '     '.
  TXT3 = 'LIBRO RETENCION     (Mensual)'.
  S_TEXTO+75(40)  = TXT3.
  TXT4 = 'Fecha Emision :'.

  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
   EXPORTING
     DATE_INTERNAL                  = SY-DATUM
   IMPORTING
     DATE_EXTERNAL                  = TXT5
*   EXCEPTIONS
*     DATE_INTERNAL_IS_INVALID       = 1
*     OTHERS                         = 2
            .
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*   TXT5 = sy-datum.

  S_TEXTO+160(15)  = TXT4.
  S_TEXTO+175(15)  = TXT5.
  APPEND S_TEXTO TO GT_DATA.


  S_TEXTO = '     '.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM T015M WHERE SPRAS = SY-LANGU
*                      AND MONUM = S_MONTH.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM T015M WHERE SPRAS = SY-LANGU
                      AND MONUM = S_MONTH ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*  TXT6 = IDATE_DESC.
  S_TEXTO+75(25)  = IDATE_DESC.
  APPEND S_TEXTO TO GT_DATA.

ENDFORM.                    " CABECERA
*&---------------------------------------------------------------------*
*&      Form  TOTAL_RETENCION
*&---------------------------------------------------------------------*
*       SE INSERTA TOTAL DE LA RETENCION EN ARCHIVO
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TOTAL_RETENCION .
  DATA : LS_OUTPUT LIKE OUTPUT_LIST.
  DATA : L_DMBTR       LIKE BSIK-DMBTR.          " invoice amount
  DATA : L_WT_QSSHH    LIKE WITH_ITEM-WT_QSSHH.  " wt base amount
  DATA : L_WT_QBSHH    LIKE WITH_ITEM-WT_QBSHH.  " wt amount


  LOOP AT OUTPUT_LIST INTO LS_OUTPUT.

    L_WT_QSSHH = L_WT_QSSHH + LS_OUTPUT-WT_QSSHH.
    L_WT_QBSHH = L_WT_QBSHH + LS_OUTPUT-WT_QBSHH.
    L_DMBTR = L_DMBTR + LS_OUTPUT-DMBTR.

  ENDLOOP.

  WRITE : L_WT_QSSHH TO TXT8 CURRENCY 'CLP'. " VALOR BOLETA
  WRITE : L_WT_QBSHH TO TXT9 CURRENCY 'CLP'. " VALOR RETENCION
  WRITE : L_DMBTR TO TXT10 CURRENCY 'CLP'. " VALOR A PAGAR


  SHIFT TXT8 RIGHT DELETING TRAILING SPACE.
  SHIFT TXT9 RIGHT DELETING TRAILING SPACE.
  SHIFT TXT10 RIGHT DELETING TRAILING SPACE.

  CLEAR S_TEXTO.
  S_TEXTO+150(20)  = 'TOTAL'.
  S_TEXTO+170(20)  = TXT8.
  S_TEXTO+190(20)  = TXT9.
  S_TEXTO+210(20)  = TXT10.

  APPEND S_TEXTO TO GT_DATA.

ENDFORM.                    " TOTAL_RETENCION

*&---------------------------------------------------------------------*
*&      Form  resumen_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM RESUMEN_FILE.

  DATA: V_INDEX LIKE SY-TABIX.
  CLEAR S_TEXTO.

  APPEND S_TEXTO TO GT_DATA.
  APPEND S_TEXTO TO GT_DATA.
  APPEND S_TEXTO TO GT_DATA.
  APPEND S_TEXTO TO GT_DATA.
  APPEND S_TEXTO TO GT_DATA.

*  imprime cabecera ***********************************************
  S_TEXTO+70(30)  = TEXT-811.
  APPEND S_TEXTO TO GT_DATA.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM T015M WHERE SPRAS = SY-LANGU
*                        AND MONUM = S_MONTH.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM T015M WHERE SPRAS = SY-LANGU
                        AND MONUM = S_MONTH ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  S_TEXTO+70(30) = IDATE_DESC.
  APPEND S_TEXTO TO GT_DATA.



  S_TEXTO+70(30) = 'Moneda: CLP'.
  APPEND S_TEXTO TO GT_DATA.
  CLEAR S_TEXTO.

  APPEND S_TEXTO TO GT_DATA.
  APPEND S_TEXTO TO GT_DATA.
********************************************************************

  SORT TOTAL_TABLE .

* titulos
  CLEAR S_TEXTO.
  S_TEXTO+0(230)  = '---------------------------------------------------------------------------------------------------------------------------------------------------------------------'.
  APPEND S_TEXTO TO GT_DATA.

  CLEAR S_TEXTO.
  S_TEXTO+0(33) = TEXT-332.
*  S_TEXTO+33(30) = TEXT-331.
  S_TEXTO+58(30) = TEXT-330.
  S_TEXTO+84(30) = TEXT-406.
  S_TEXTO+114(30) = TEXT-407.
  S_TEXTO+150(30) = TEXT-408.
  APPEND S_TEXTO TO GT_DATA.
  CLEAR S_TEXTO.
  S_TEXTO+0(230)  = '---------------------------------------------------------------------------------------------------------------------------------------------------------------------'.
  APPEND S_TEXTO TO GT_DATA.
*
***************************************************************************

  LOOP AT TOTAL_TABLE.
    V_TABIX = SY-TABIX.
    IF TOTAL_TABLE-CONT_NULL > 0.
      TOTAL_TABLE-COUNT = TOTAL_TABLE-COUNT - TOTAL_TABLE-CONT_NULL.
      MODIFY TOTAL_TABLE INDEX V_TABIX.
    ENDIF.
  ENDLOOP.

  LOOP AT TOTAL_TABLE.

    IF SY-TABIX = 1.
*      ULINE AT /1(148).
    ENDIF.
***DOC NULOS.
*    IF total_table-blart = 'B1'.
*      total_table-cont = c1.
*    ELSEIF total_table-blart = 'B2'.
*      total_table-cont = c2.
*    ENDIF.
***
*    WRITE:/1 '|',  total_table-type_desc,'|',
    CLEAR S_TEXTO.


*    write:/1 '|',   total_table-blart, '                        ', '|',
    WRITE: TOTAL_TABLE-CONT_NULL  NO-SIGN TO TXT2." '          ' , '|',
    WRITE: TOTAL_TABLE-COUNT NO-SIGN TO TXT3.
    WRITE: TOTAL_TABLE-WT_QSSHH NO-SIGN CURRENCY T001-WAERS TO TXT8.
    WRITE: TOTAL_TABLE-WT_QBSHH NO-SIGN CURRENCY T001-WAERS TO TXT5.
    WRITE: TOTAL_TABLE-DMBTR NO-SIGN CURRENCY T001-WAERS TO TXT6.

    S_TEXTO+0(30) = TOTAL_TABLE-TYPE_DESC.
*    S_TEXTO+30(30) = TXT2.
    S_TEXTO+60(30) = TXT3.
    S_TEXTO+90(30) = TXT8.
    S_TEXTO+120(30) = TXT5.
    S_TEXTO+150(30) = TXT6.

    APPEND S_TEXTO TO GT_DATA.

    AT LAST.
      SUM.
       CLEAR S_TEXTO.
       S_TEXTO+0(230)  = '---------------------------------------------------------------------------------------------------------------------------------------------------------------------'.
       APPEND S_TEXTO TO GT_DATA.
*      clear:  total_table-type_desc.
      CLEAR S_TEXTO.
      S_TEXTO+0(30) = TEXT-809.

*      ULINE AT /1(148).
*      WRITE: /1 '|',  iexport, '|',
      WRITE:TOTAL_TABLE-CONT_NULL NO-SIGN TO TXT2.
      WRITE:TOTAL_TABLE-COUNT NO-SIGN  TO TXT3.
      WRITE:TOTAL_TABLE-WT_QSSHH NO-SIGN CURRENCY T001-WAERS TO TXT8.
      WRITE:TOTAL_TABLE-WT_QBSHH NO-SIGN CURRENCY T001-WAERS TO TXT5.
      WRITE:TOTAL_TABLE-DMBTR    NO-SIGN CURRENCY T001-WAERS TO TXT6.
*      S_TEXTO+30(30) = TXT2.
      S_TEXTO+60(30) = TXT3.
      S_TEXTO+90(30) = TXT8.
      S_TEXTO+120(30) = TXT5.
      S_TEXTO+150(30) = TXT6.
      APPEND S_TEXTO TO GT_DATA.
    ENDAT.



  ENDLOOP.

ENDFORM. " resumen file.

*&---------------------------------------------------------------------*
*&      Form  PRINT_FINAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PRINT_FINAL2.
  DATA: WA TYPE OUT,
       COUNT TYPE I,
       CONT  TYPE I ,
*       C_WT_QSSHH(11),
*       C_WT_QBSHH(11),
*       C_DMBTR(11),
       TYPE_DESC(27) TYPE   C,
       TYPE_IMPUESTO(27) TYPE C,
       TABIX LIKE SY-TABIX.

*  SORT output_list BY witht wt_withcd lifnr poper budat belnr.
  SORT OUTPUT_LIST BY WITHT BLART XBLNR.

  DESCRIBE TABLE OUTPUT_LIST LINES FOUND.
  DATA: P_BLART TYPE  BSIK-BLART.
  IF FOUND = 0.
*    WRITE: /70 text-420.
    EXIT.
  ENDIF.
*  SORT output_list   BY blart.

  CONT = 0.
  LOOP AT OUTPUT_LIST.

*hide: output_list-belnr.
    MOVE OUTPUT_LIST TO WA.
    ADD 1 TO COUNT.

    MULTIPLY WA-WT_QSSHH BY -1.
    MULTIPLY WA-WT_QBSHH BY -1.
    MULTIPLY WA-DMBTR BY -1.



*    CLEAR: TYPE_DESC,TYPE_IMPUESTO.
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES01 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE  LTEXT FROM T003T INTO TYPE_DESC
*     WHERE SPRAS = 'S'
*     AND   BLART = WA-BLART.
*
* NEW CODE
    SELECT LTEXT
    UP TO 1 ROWS  FROM T003T INTO TYPE_DESC
     WHERE SPRAS = 'S'
     AND   BLART = WA-BLART ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE TEXT40 FROM T059U INTO TYPE_IMPUESTO
*    WHERE SPRAS = 'S'
*    AND  LAND1  = 'CL'
*    AND WITHT   = WA-WITHT.
*
* NEW CODE
    SELECT TEXT40
    UP TO 1 ROWS  FROM T059U INTO TYPE_IMPUESTO
    WHERE SPRAS = 'S'
    AND  LAND1  = 'CL'
    AND WITHT   = WA-WITHT ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

*    IF output_list-AUGBL IS NOT INITIAL.
*      cont = cont + 1.
*    ENDIF.

    ON CHANGE OF OUTPUT_LIST-BLART.
*      SKIP.
*      WRITE: /1 type_desc.
*      ULINE.

    ENDON.

    TABIX = SY-TABIX.

    HIDE: OUTPUT_LIST-BELNR.
    CLEAR OUTPUT_LIST-BELNR.

    AT END OF BLART.


      SUM.
*      ULINE.

      MULTIPLY OUTPUT_LIST-WT_QSSHH BY -1.
      MULTIPLY OUTPUT_LIST-WT_QBSHH BY -1.
      MULTIPLY OUTPUT_LIST-DMBTR BY -1.
      MOVE: OUTPUT_LIST-COUNT TO TOTAL_TABLE-COUNT,
            OUTPUT_LIST-CONT_NULL TO TOTAL_TABLE-CONT_NULL,
            TYPE_IMPUESTO TO TOTAL_TABLE-TYPE_IMPUESTO,
            TYPE_DESC TO TOTAL_TABLE-TYPE_DESC,
            OUTPUT_LIST-WT_QSSHH TO TOTAL_TABLE-WT_QSSHH,
            OUTPUT_LIST-DMBTR TO TOTAL_TABLE-DMBTR,
            OUTPUT_LIST-WT_QBSHH  TO TOTAL_TABLE-WT_QBSHH,
            OUTPUT_LIST-XBLNR  TO TOTAL_TABLE-XBLNR,
            OUTPUT_LIST-BELNR TO TOTAL_TABLE-BELNR,
            OUTPUT_LIST-BLART TO TOTAL_TABLE-BLART,
            WA-QSATZ TO TOTAL_TABLE-QSATZ.
*            cont TO total_table-cont
      .

      COLLECT TOTAL_TABLE.
      CLEAR CONT.
*
      NEW-PAGE.

    ENDAT.
  ENDLOOP.

  SORT OUTPUT_LIST_NULL BY BLART .

  LOOP AT OUTPUT_LIST_NULL WHERE BLART = 'B1'.
    C1 = 1 + C1.
  ENDLOOP.

  LOOP AT OUTPUT_LIST_NULL WHERE BLART = 'B2'.
    C2 = 1 + C2.
  ENDLOOP.

  LOOP AT OUTPUT_LIST_NULL WHERE BLART = 'B3'.
    C3 = 1 + C3.
  ENDLOOP.

  LOOP AT OUTPUT_LIST_NULL WHERE BLART = 'B4'.
    C4 = 1 + C4.
  ENDLOOP.


ENDFORM.                    " PRINT_FINAL2
*&---------------------------------------------------------------------*
*&      Form  HTML_TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM HTML_TOP_OF_PAGE USING DOCUMENT
                            TYPE REF TO CL_DD_DOCUMENT.     "#EC CALLED

  DATA: L_TITLE        TYPE SDYDO_TEXT_ELEMENT,
        L_TEXT         TYPE SDYDO_TEXT_ELEMENT,
        L_MONTH     TYPE FCLTX.

  DATA : L_FONTSIZ     TYPE SDYDO_ATTRIBUTE.

  DATA: TI_ZFIGIRO LIKE ZFIGIRO OCCURS 0 WITH HEADER LINE.

  IF GS_T001-ADRNR NE SPACE.
* Company name and address details for header.
    PERFORM GET_COMP_ADDRESS.
  ENDIF.
* SE EXTRAE GIRO
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM ZFIGIRO
*    INTO TABLE TI_ZFIGIRO
*    WHERE BUKRS = S_COMPY.
*
* NEW CODE
  SELECT *
 FROM ZFIGIRO
    INTO TABLE TI_ZFIGIRO
    WHERE BUKRS = S_COMPY ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

*************************************************
  L_TEXT = GS_T001-BUTXT.
  CALL METHOD DOCUMENT->ADD_TEXT
    EXPORTING
      TEXT         = L_TEXT
      SAP_EMPHASIS = 'Strong'. "'Strong'.
*********************************************************
******** Giro **************************+
  L_FONTSIZ = '1'.
  LOOP AT TI_ZFIGIRO.
    IF TI_ZFIGIRO-GIRO_1 IS NOT INITIAL.
      CALL METHOD DOCUMENT->NEW_LINE.
      CONCATENATE 'Giro : ' TI_ZFIGIRO-GIRO_1 INTO L_TEXT.
*    l_text = TI_ZFIGIRO-GIRO_1.
      CALL METHOD DOCUMENT->ADD_TEXT
      EXPORTING
        TEXT         = L_TEXT
*      sap_emphasis = 'HEADING' "'Strong'.
        SAP_FONTSIZE = L_FONTSIZ.
      CALL METHOD DOCUMENT->NEW_LINE.
    ENDIF.

    IF TI_ZFIGIRO-GIRO_2 IS NOT INITIAL.
      L_TEXT = TI_ZFIGIRO-GIRO_2.
      CALL METHOD DOCUMENT->ADD_TEXT
      EXPORTING
        TEXT         = L_TEXT
*        sap_emphasis = 'HEADING'. "'Strong'.
        SAP_FONTSIZE = L_FONTSIZ.
      CALL METHOD DOCUMENT->NEW_LINE.
    ENDIF.

    IF TI_ZFIGIRO-GIRO_3 IS NOT INITIAL.
      L_TEXT = TI_ZFIGIRO-GIRO_3.
      CALL METHOD DOCUMENT->ADD_TEXT
        EXPORTING
          TEXT         = L_TEXT
          SAP_EMPHASIS = 'HEADING'. "'Strong'.
      CALL METHOD DOCUMENT->NEW_LINE.
    ENDIF.

    IF TI_ZFIGIRO-GIRO_4 IS NOT INITIAL.
      L_TEXT = TI_ZFIGIRO-GIRO_4.
      CALL METHOD DOCUMENT->ADD_TEXT
        EXPORTING
          TEXT         = L_TEXT
          SAP_EMPHASIS = 'HEADING'. "'Strong'.
      CALL METHOD DOCUMENT->NEW_LINE.
    ENDIF.

    IF TI_ZFIGIRO-GIRO_5 IS NOT INITIAL.
      L_TEXT = TI_ZFIGIRO-GIRO_5.
      CALL METHOD DOCUMENT->ADD_TEXT
        EXPORTING
          TEXT         = L_TEXT
          SAP_EMPHASIS = 'HEADING'. "'Strong'.
      CALL METHOD DOCUMENT->NEW_LINE.
    ENDIF.

    IF TI_ZFIGIRO-GIRO_6 IS NOT INITIAL.
      L_TEXT = TI_ZFIGIRO-GIRO_6.
      CALL METHOD DOCUMENT->ADD_TEXT
        EXPORTING
          TEXT         = L_TEXT
          SAP_EMPHASIS = 'HEADING'. "'Strong'.
      CALL METHOD DOCUMENT->NEW_LINE.
    ENDIF.

    IF TI_ZFIGIRO-GIRO_7 IS NOT INITIAL.
      L_TEXT = TI_ZFIGIRO-GIRO_7.
      CALL METHOD DOCUMENT->ADD_TEXT
        EXPORTING
          TEXT         = L_TEXT
          SAP_EMPHASIS = 'HEADING'. "'Strong'.
      CALL METHOD DOCUMENT->NEW_LINE.
    ENDIF.

    IF TI_ZFIGIRO-GIRO_8 IS NOT INITIAL.
      L_TEXT = TI_ZFIGIRO-GIRO_8.
      CALL METHOD DOCUMENT->ADD_TEXT
        EXPORTING
          TEXT         = L_TEXT
          SAP_EMPHASIS = 'HEADING'. "'Strong'.
      CALL METHOD DOCUMENT->NEW_LINE.
    ENDIF.
  ENDLOOP.

  CLEAR: GS_T001Z.
* R.U.T Tax Number.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE PAVAL FROM T001Z INTO GS_T001Z-PAVAL
*                     WHERE BUKRS = S_COMPY
*                     AND PARTY = 'TAXNR'.
*
* NEW CODE
  SELECT PAVAL
  UP TO 1 ROWS  FROM T001Z INTO GS_T001Z-PAVAL
                     WHERE BUKRS = S_COMPY
                     AND PARTY = 'TAXNR' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  CHECK SY-SUBRC = 0.
*  rut
  CONCATENATE 'Rut : ' GS_T001Z-PAVAL INTO L_TEXT.
*  l_text = GS_T001Z-PAVAL.
  CALL METHOD DOCUMENT->ADD_TEXT
    EXPORTING
      TEXT         = L_TEXT
      SAP_EMPHASIS = 'HEADING'. "'Strong'.
  CALL METHOD DOCUMENT->NEW_LINE.

* direccion
  CONCATENATE 'Dirección :' GS_ADDR_COMP-STREET INTO L_TEXT.
*  l_text = GS_ADDR_COMP-STREET.
  CALL METHOD DOCUMENT->ADD_TEXT
    EXPORTING
      TEXT         = L_TEXT
      SAP_EMPHASIS = 'HEADING'. "'Strong'.
  CALL METHOD DOCUMENT->NEW_LINE.
***********************************************

*  CALL METHOD document->new_line.
  L_TEXT = G_BUTXT.
  CALL METHOD DOCUMENT->ADD_TEXT
    EXPORTING
      TEXT         = L_TEXT
      SAP_EMPHASIS = 'Strong'.
  CALL METHOD DOCUMENT->NEW_LINE.
  L_TITLE = 'Libro de Retenciones'.
  CALL METHOD DOCUMENT->ADD_GAP
    EXPORTING
      WIDTH = 170.
  CALL METHOD DOCUMENT->ADD_TEXT
    EXPORTING
      TEXT          = L_TITLE
      SAP_STYLE     = 'HEADING'
      SAP_FONTSTYLE = 'C'
      SAP_EMPHASIS  = 'C'.

*  fECHA
  CLEAR : GV_LOWDATE, GV_HIGHDATE, GV_DATE.

  DATA P_MONTH     TYPE FCLTX.
  PERFORM GET_MONTH USING   S_MONTH
                 CHANGING P_MONTH.

  CONCATENATE P_MONTH '. ' ' ' S_YEAR INTO GV_DATE.

*  CONCATENATE P_DATE+6(2) '.' P_DATE+4(2) '.' P_DATE+0(4) INTO
*  GV_HIGHDATE.
*  CONCATENATE 'Desde :'GV_LOWDATE ' A ' GV_HIGHDATE INTO GV_DATE
*              SEPARATED BY SPACE.




  L_TITLE = GV_DATE.
  CALL METHOD DOCUMENT->NEW_LINE.
  CALL METHOD DOCUMENT->ADD_TEXT
    EXPORTING
      TEXT         = L_TEXT
      SAP_EMPHASIS = 'HEADING'.
*  CALL METHOD document->new_line.
*  l_title = GV_DATE.
  CALL METHOD DOCUMENT->ADD_GAP
    EXPORTING
      WIDTH = 195.
  CALL METHOD DOCUMENT->ADD_TEXT
    EXPORTING
      TEXT      = L_TITLE
      SAP_STYLE = 'Strong'.

ENDFORM.                    "html_top_of_page
*&---------------------------------------------------------------------*
*&      Form  GET_COMP_ADDRESS
*&---------------------------------------------------------------------*
* Subroutine to get Company Address
*----------------------------------------------------------------------*
FORM GET_COMP_ADDRESS.

  CLEAR: GS_ADDR_SEL, GS_ADDR_COMP.

*Address number
  GS_ADDR_SEL-ADDRNUMBER = GS_T001-ADRNR.

*Call Function Module to get Company code address.
  CALL FUNCTION 'ADDR_GET'
    EXPORTING
      ADDRESS_SELECTION = GS_ADDR_SEL
    IMPORTING
      ADDRESS_VALUE     = GS_ADDR_COMP
    EXCEPTIONS
      PARAMETER_ERROR   = 1
      ADDRESS_NOT_EXIST = 2
      VERSION_NOT_EXIST = 3
      INTERNAL_ERROR    = 4
      OTHERS            = 5.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " GET_COMP_ADDRESS

*&---------------------------------------------------------------------*
*&      Form  GET_COMPANY_DATA
*&---------------------------------------------------------------------*
* Subroutine to get company code data.
*----------------------------------------------------------------------*
FORM GET_COMPANY_DATA .

*Select data from T001 table.
  CLEAR: GS_T001.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE BUKRS BUTXT WAERS ADRNR FROM T001
*                INTO (GS_T001-BUKRS, GS_T001-BUTXT, GS_T001-WAERS,
*                      GS_T001-ADRNR)
*                WHERE BUKRS = S_COMPY.
*
* NEW CODE
  SELECT BUKRS BUTXT WAERS ADRNR
  UP TO 1 ROWS  FROM T001
                INTO (GS_T001-BUKRS, GS_T001-BUTXT, GS_T001-WAERS,
                      GS_T001-ADRNR)
                WHERE BUKRS = S_COMPY ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  CHECK SY-SUBRC = 0.

ENDFORM.                               " GET_COMPANY_DATA
*&---------------------------------------------------------------------*
*&      Form  get_month
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MONAT    text
*      -->P_MONTH    text
*----------------------------------------------------------------------*
FORM GET_MONTH USING P_MONAT TYPE MONAT
               CHANGING P_MONTH     TYPE FCLTX.

  DATA: LT_MONTH_NAMES TYPE TABLE OF T247,
        LS_MONTH_NAMES TYPE  T247,
        L_SUBRC        TYPE SY-SUBRC.
  CALL FUNCTION 'MONTH_NAMES_GET'
    EXPORTING
      LANGUAGE              = SY-LANGU
    IMPORTING
      RETURN_CODE           = L_SUBRC
    TABLES
      MONTH_NAMES           = LT_MONTH_NAMES
    EXCEPTIONS
      MONTH_NAMES_NOT_FOUND = 1
      OTHERS                = 2.
  IF L_SUBRC EQ 0.
    READ TABLE LT_MONTH_NAMES
     INTO LS_MONTH_NAMES
     WITH KEY MNR = P_MONAT.
    IF SY-SUBRC EQ 0.
      MOVE LS_MONTH_NAMES-LTX TO P_MONTH .
    ENDIF.
  ENDIF.

ENDFORM.                    "get_month
*&---------------------------------------------------------------------*
*&      Form  SUBTOTALES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_OUTPUT_LTEXT  text
*      -->P_L_WT_QSSHH  text
*      -->P_L_WT_QBSHH  text
*      -->P_L_WT_QBSHH  text
*----------------------------------------------------------------------*
FORM SUBTOTALES  USING    BLAR_ORIG
                          L_WT_QSSHH
                          L_WT_QBSHH
                          L_DMBTR
                          L_WAERS.


CLEAR TXT1. "
CLEAR TXT2.
CLEAR TXT3.

CLEAR TXT4. " BLART
CLEAR TXT5.
CLEAR TXT6.
CLEAR TXT7.
CLEAR TXTDR.

TXT6 = 'TOTAL'. "
*TXT7 = BLAR_ORIG.
WRITE : L_WT_QSSHH TO TXT8 CURRENCY L_WAERS. " VALOR BOLETA
WRITE : L_WT_QBSHH TO TXT9 CURRENCY L_WAERS. " VALOR RETENCION
WRITE : L_DMBTR TO TXT10 CURRENCY L_WAERS. " VALOR A PAGAR

SHIFT TXT8 RIGHT DELETING TRAILING SPACE.
SHIFT TXT9 RIGHT DELETING TRAILING SPACE.
SHIFT TXT10 RIGHT DELETING TRAILING SPACE.

CLEAR S_TEXTO.
S_TEXTO+130(65)  = '____________________________________________________________________________________________________'.
APPEND S_TEXTO TO GT_DATA.

CLEAR S_TEXTO.
* se arma texto patra colocar en Tabla interna
    CLEAR S_TEXTO.
*    S_TEXTO+0(5)  = L_CONTLINES.
*    S_TEXTO+5(30)  = TXT1.
*    S_TEXTO+30(20) = TXT2.
*    S_TEXTO+50(20)  = TXT3.
*    S_TEXTO+70(40)  = TXT4.
*    S_TEXTO+110(20)  = TXT5.
*    S_TEXTO+130(20)  = TXT6.
*    S_TEXTO+150(20)  = TXT7.
*    S_TEXTO+170(20)  = TXT8.
*    S_TEXTO+190(20)  = TXT9.
*    S_TEXTO+210(20)  = TXT10.
      S_TEXTO+5(15)  = TXT2.
      S_TEXTO+20(15) = TXT3.
      S_TEXTO+35(30)  = TXT4.
      S_TEXTO+65(40)  = TXTDR.
      S_TEXTO+105(15)  = TXT5.
      S_TEXTO+120(15)  = TXT6.
      S_TEXTO+135(20)  = BLAR_ORIG.
      S_TEXTO+155(15)  = TXT8.
      S_TEXTO+170(15)  = TXT9.
      S_TEXTO+185(15)  = TXT10.

    APPEND S_TEXTO TO GT_DATA.

CLEAR L_WT_QSSHH. " VALOR BOLETA
CLEAR L_WT_QBSHH." VALOR RETENCION
CLEAR L_DMBTR. " VALOR A PAGAR

CLEAR S_TEXTO.
APPEND S_TEXTO TO GT_DATA.
APPEND S_TEXTO TO GT_DATA.
APPEND S_TEXTO TO GT_DATA.
CLEAR TXT1. "
CLEAR TXT2.
CLEAR TXT3.
CLEAR TXT4. " BLART
CLEAR TXT5.
CLEAR TXT6.
CLEAR TXT7.
CLEAR TXT8.
CLEAR TXT9.
CLEAR TXT10.

ENDFORM.                    " SUBTOTALES
*&---------------------------------------------------------------------*
*&      Form  ADDR_LIFNR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_OUTPUT_LIFNR  text
*      <--P_ADDRS  text
*----------------------------------------------------------------------*
FORM ADDR_LIFNR  USING    P_LIFNR
                 CHANGING P_ADDRS.

DATA L_ADRNR TYPE LFA1-ADRNR.
DATA L_STREET TYPE ADRC-STREET.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE ADRNR INTO L_ADRNR
*   FROM LFA1
*  WHERE LIFNR  EQ P_LIFNR.
*
* NEW CODE
SELECT ADRNR
UP TO 1 ROWS  INTO L_ADRNR
   FROM LFA1
  WHERE LIFNR  EQ P_LIFNR ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01


  IF SY-SUBRC EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE STREET INTO L_STREET
*      FROM ADRC
*     WHERE ADDRNUMBER EQ L_ADRNR.
*
* NEW CODE
    SELECT STREET
    UP TO 1 ROWS  INTO L_STREET
      FROM ADRC
     WHERE ADDRNUMBER EQ L_ADRNR ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      IF SY-SUBRC EQ 0.
         if L_STREET is not initial.
          P_ADDRS = L_STREET.
         else.
          P_ADDRS = 'S/D'.
         endif.
      ELSE.
         P_ADDRS = 'S/D'.
      ENDIF.
  ENDIF.


ENDFORM.                    " ADDR_LIFNR
*&---------------------------------------------------------------------*
*&      Form  CALL_FB03
*&---------------------------------------------------------------------*
*       HACE REFERENCIA A FB03
*----------------------------------------------------------------------*
*      -->P_I_SELFIELD_VALUE  text
*      -->P_BUKRS  text
*      -->P_GJAHR  text
*----------------------------------------------------------------------*
FORM CALL_FB03  USING    P_DOC
                            P_BUKRS
                            P_GJAHR.


  SET PARAMETER ID :'BLN' FIELD  P_DOC,
                    'BUK' FIELD  P_BUKRS,
                    'GJR' FIELD  P_GJAHR.


  CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.


ENDFORM.                    " CALL_FAGLB03
