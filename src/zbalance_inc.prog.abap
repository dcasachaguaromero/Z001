*----------------------------------------------------------------------*
***INCLUDE ZBALANCE_INC .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_FILE USING SPATH_FILE.
*data SPATH_FILE type rlgrap-filename.

  PATH_FILE = SPATH_FILE.
  CONCATENATE PATH_FILE '\BALANCE' '_' SY-DATUM '_' SY-UZEIT '.txt' INTO PATH_FILE.
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
  DATA : LS_OUTPUT LIKE LINE OF GT_OUTPUT.
  DATA: V_LONG TYPE I.
  DATA: V_LEN TYPE I.

  V_HORIZ_TAB = CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB.
  V_NEWLINE   = CL_ABAP_CHAR_UTILITIES=>NEWLINE.


  G_LINEAS = 1.
  G_PRIMERO = 0.
  CLEAR GT_DATA.

  LOOP AT GT_OUTPUT INTO LS_OUTPUT.


    IF G_LINEAS LE g_line.
      IF G_PRIMERO = 0.
        PERFORM CABECERA.
        PERFORM NEW_PAGE.
        CLEAR G_TOTLAUFD.
        G_PRIMERO = 1.
        TXT1 = LS_OUTPUT-SAKNR. " cuenta
        TXT2 = LS_OUTPUT-TXT50. " descripcion
        WRITE : LS_OUTPUT-SUMME_SOLL TO TXT3 CURRENCY LS_OUTPUT-HWAER. " DEBE
        WRITE : LS_OUTPUT-SUMME_HABEN TO TXT4 CURRENCY LS_OUTPUT-HWAER. " HABER
        WRITE : LS_OUTPUT-SALDO_ENDE_SOLL TO TXT5 CURRENCY LS_OUTPUT-HWAER. " Saldo deudor
        WRITE : LS_OUTPUT-SALDO_ENDE_HABEN TO TXT6 CURRENCY LS_OUTPUT-HWAER. " Saldo Acreedor
        WRITE : LS_OUTPUT-BESTANDKONTO TO TXT7 CURRENCY LS_OUTPUT-HWAER. " activo
        WRITE : LS_OUTPUT-BESTANDKONTO_PASSIV TO TXT8 CURRENCY LS_OUTPUT-HWAER. " pasivo
        WRITE : LS_OUTPUT-ERFOLG_AUFWAND TO TXT9 CURRENCY LS_OUTPUT-HWAER. " perdida
        WRITE : LS_OUTPUT-ERFOLG_ERTRAG TO TXT10 CURRENCY LS_OUTPUT-HWAER. " ganancia

        G_TOTLAUFD = 1.
      ELSE.
        TXT1 = LS_OUTPUT-SAKNR. " cuenta
        TXT2 = LS_OUTPUT-TXT50. " descripcion
        WRITE : LS_OUTPUT-SUMME_SOLL TO TXT3 CURRENCY LS_OUTPUT-HWAER. " DEBE
        WRITE : LS_OUTPUT-SUMME_HABEN TO TXT4 CURRENCY LS_OUTPUT-HWAER. " HABER
        WRITE : LS_OUTPUT-SALDO_ENDE_SOLL TO TXT5 CURRENCY LS_OUTPUT-HWAER. " Saldo deudor
        WRITE : LS_OUTPUT-SALDO_ENDE_HABEN TO TXT6 CURRENCY LS_OUTPUT-HWAER. " Saldo Acreedor
        WRITE : LS_OUTPUT-BESTANDKONTO TO TXT7 CURRENCY LS_OUTPUT-HWAER. " activo
        WRITE : LS_OUTPUT-BESTANDKONTO_PASSIV TO TXT8 CURRENCY LS_OUTPUT-HWAER. " pasivo
        WRITE : LS_OUTPUT-ERFOLG_AUFWAND TO TXT9 CURRENCY LS_OUTPUT-HWAER. " perdida
        WRITE : LS_OUTPUT-ERFOLG_ERTRAG TO TXT10 CURRENCY LS_OUTPUT-HWAER. " ganancia
        G_TOTLAUFD =  G_TOTLAUFD + 1.
      ENDIF.

      IF  TXT5 IS INITIAL.
        CONCATENATE '-' TXT5 INTO TXT5.
      ENDIF.

      IF  TXT7 IS INITIAL.
        CONCATENATE '-' TXT7 INTO TXT7.
      ENDIF.

    ELSE.  " titulo
*         PERFORM Subtotal.
      PERFORM CABECERA.
      PERFORM NEW_PAGE.
      G_LINEAS = 1.
      CLEAR G_TOTLAUFD.
      G_TOTLAUFD =  1.
      TXT1 = LS_OUTPUT-SAKNR. " cuenta
      TXT2 = LS_OUTPUT-TXT50. " descripcion
      WRITE : LS_OUTPUT-SUMME_SOLL TO TXT3 CURRENCY LS_OUTPUT-HWAER. " DEBE
      WRITE : LS_OUTPUT-SUMME_HABEN TO TXT4 CURRENCY LS_OUTPUT-HWAER. " HABER
      WRITE : LS_OUTPUT-SALDO_ENDE_SOLL TO TXT5 CURRENCY LS_OUTPUT-HWAER. " Saldo deudor
      WRITE : LS_OUTPUT-SALDO_ENDE_HABEN TO TXT6 CURRENCY LS_OUTPUT-HWAER. " Saldo Acreedor
      WRITE : LS_OUTPUT-BESTANDKONTO TO TXT7 CURRENCY LS_OUTPUT-HWAER. " activo
      WRITE : LS_OUTPUT-BESTANDKONTO_PASSIV TO TXT8 CURRENCY LS_OUTPUT-HWAER. " pasivo
      WRITE : LS_OUTPUT-ERFOLG_AUFWAND TO TXT9 CURRENCY LS_OUTPUT-HWAER. " perdida
      WRITE : LS_OUTPUT-ERFOLG_ERTRAG TO TXT10 CURRENCY LS_OUTPUT-HWAER. " ganancia
    ENDIF.

*    SHIFT TXT1 RIGHT DELETING TRAILING SPACE.
*    SHIFT txt2 RIGHT DELETING TRAILING SPACE.
*    SHIFT txt2 LEFT DELETING LEADING ' '.
    V_LEN = STRLEN( TXT2 ).
    DESCRIBE FIELD TXT2 LENGTH V_LONG IN CHARACTER MODE.
    V_LEN = V_LONG - V_LEN.
    DO V_LEN TIMES.
      CONCATENATE TXT2 SPACE INTO TXT2.
    ENDDO.

    SHIFT TXT3 RIGHT DELETING TRAILING SPACE.
    SHIFT TXT4 RIGHT DELETING TRAILING SPACE.
    SHIFT TXT5 RIGHT DELETING TRAILING SPACE.
    SHIFT TXT6 RIGHT DELETING TRAILING SPACE.
    SHIFT TXT7 RIGHT DELETING TRAILING SPACE.
    SHIFT TXT8 RIGHT DELETING TRAILING SPACE.
    SHIFT TXT9 RIGHT DELETING TRAILING SPACE.
    SHIFT TXT10 RIGHT DELETING TRAILING SPACE.


    CLEAR S_TEXTO.
*    CONCATENATE TXT1 V_HORIZ_TAB
*                TXT2 V_HORIZ_TAB
*                TXT3 V_HORIZ_TAB
*                TXT4 V_HORIZ_TAB
*                TXT5 V_HORIZ_TAB
*                TXT6 V_HORIZ_TAB
*                TXT7 V_HORIZ_TAB
*                TXT8  INTO S_TEXTO.
** v_NEWLINE
* se arma texto patra colocar en Tabla interna
    CLEAR S_TEXTO.
    S_TEXTO+0(20)  = TXT1.
    S_TEXTO+20(60) = TXT2.
    S_TEXTO+80(20)  = TXT3.
    S_TEXTO+100(20)  = TXT4.
    S_TEXTO+120(20)  = TXT5.
    S_TEXTO+140(20)  = TXT6.
    S_TEXTO+160(20)  = TXT7.
    S_TEXTO+180(20)  = TXT8.
    S_TEXTO+200(20)  = TXT9.
    S_TEXTO+220(20)  = TXT10.

    APPEND S_TEXTO TO GT_DATA.
    G_LINEAS = G_LINEAS + 1.

  ENDLOOP.

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
    SKIP 2 .
*    FORMAT COLOR 3 ON.
    CONCATENATE 'Se genero archivo :' PATH_FILE INTO XTEXTM.
    MESSAGE  XTEXTM TYPE 'S'.
*     WRITE : / 'Se genero archivo :', PATH_FILE.
*    FORMAT COLOR 3 OFF.
  ENDIF.
ENDFORM. "  GUI_DOWNLOAD_F
*&---------------------------------------------------------------------*
*&      Form  NEW_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM NEW_PAGE.
  DATA :  P_LINEA(240) TYPE C.
  DO 240 TIMES.
    CONCATENATE P_LINEA '-' INTO P_LINEA.
  ENDDO.

  S_TEXTO = '     '.
  CONCATENATE S_TEXTO V_NEWLINE  INTO S_TEXTO.
  SHIFT S_TEXTO RIGHT DELETING TRAILING SPACE.
  APPEND S_TEXTO TO GT_DATA.
  APPEND S_TEXTO TO GT_DATA.
  APPEND S_TEXTO TO GT_DATA.
  APPEND S_TEXTO TO GT_DATA.
  TXT1 = 'Cuenta'.
  TXT2 = 'Descripcion'.
  TXT3 = 'Débitos'.
  TXT4 = 'Creditos'.
  TXT5 = 'Saldo Deudor'.
  TXT6 = 'Saldo Acreedor'.
  TXT7 = 'Activos'.
  TXT8 = 'Pasivos'.
  TXT9 = 'Perdida'.
  TXT10 = 'Ganancia'.

*  SHIFT TXT1 RIGHT DELETING TRAILING SPACE.
*  SHIFT TXT2 RIGHT DELETING TRAILING SPACE.
  SHIFT TXT3 RIGHT DELETING TRAILING SPACE.
  SHIFT TXT4 RIGHT DELETING TRAILING SPACE.
  SHIFT TXT5 RIGHT DELETING TRAILING SPACE.
  SHIFT TXT6 RIGHT DELETING TRAILING SPACE.
  SHIFT TXT7 RIGHT DELETING TRAILING SPACE.
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
  S_TEXTO+0(20)  = TXT1.
  S_TEXTO+20(60) = TXT2.
  S_TEXTO+80(20)  = TXT3.
  S_TEXTO+100(20)  = TXT4.
  S_TEXTO+120(20)  = TXT5.
  S_TEXTO+140(20)  = TXT6.
  S_TEXTO+160(20)  = TXT7.
  S_TEXTO+180(20)  = TXT8.
  S_TEXTO+200(20)  = TXT9.
  S_TEXTO+220(20)  = TXT10.
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

  SELECT SINGLE BUTXT
    INTO P_BUTXT
    FROM T001
    WHERE BUKRS EQ SD_BUKRS-LOW.
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
  TXT3 = 'Balance General     (Mensual)'.
  S_TEXTO+120(20)  = TXT3.
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

  S_TEXTO+200(20)  = TXT4.
  S_TEXTO+220(20)  = TXT5.
  APPEND S_TEXTO TO GT_DATA.


  S_TEXTO = '     '.
  TXT6 = GV_LOWDATE.
  TXT7 = 'A'.
  TXT8 = GV_HIGHDATE.
  S_TEXTO+110(20)  = TXT6.
  S_TEXTO+130(5)  = TXT7.
  S_TEXTO+135(20)  = TXT8.
  APPEND S_TEXTO TO GT_DATA.

ENDFORM.                    " CABECERA
*&---------------------------------------------------------------------*
*&      Form  FI_IMPORT_BALANCE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FI_IMPORT_BALANCE USING SBALAN.

  CALL FUNCTION 'FI_IMPORT_BALANCE_SHEET_POS'
    EXPORTING
      VERSION           = SBALAN " T011-VERSN " B100
    TABLES
      X011P             = X011P
      X011V             = X011V
      I011Z             = X011Z
    EXCEPTIONS
      NEW_BALANCE_SHEET = 04.


ENDFORM.                    " FI_IMPORT_BALANCE
*&---------------------------------------------------------------------*
*&      Form  ONLY_ESTRUCT
*&---------------------------------------------------------------------*
*       SE BUSCARAN LAS ESTRUCTURAS DE BALANCES
* LAS CUENTAS QUE NO PERTENEZCAN A LA ESTRUCTURA SERAN ELIMINADAS DE
* LA TABLA INTERNA.
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ONLY_ESTRUCT .
  DATA : LS_OUTPUT LIKE LINE OF GT_OUTPUT OCCURS 0 WITH HEADER LINE.
  DATA : LS_OUTPUT2 LIKE LINE OF GT_OUTPUT OCCURS 0 WITH HEADER LINE.
  DATA : L_COMP TYPE NUMC10.
  DATA : L_CUENTA TYPE KTOPL.
  DATA : L_ID TYPE I.
  DATA : IDENT TYPE I.

  DATA : BEGIN OF LSZ OCCURS 0,
      KTOPL    TYPE KTOPL, "Plan de cuentas
      NBILKT  TYPE NUMC10, "Límite superior del intervalo de cuentas
      NVONKT  TYPE NUMC10, "Límite inferior del intervalo de cuentas
     END OF LSZ.


  IF GT_OUTPUT[] IS INITIAL OR X011Z[] IS INITIAL.
    EXIT.
  ENDIF.


  LOOP AT X011Z.
    MOVE X011Z-KTOPL TO LSZ-KTOPL.
    MOVE X011Z-BILKT TO LSZ-NBILKT.
    MOVE X011Z-VONKT TO LSZ-NVONKT.
    APPEND LSZ.
  ENDLOOP.


* SE VERIFICA QUE EXISTA LA CUENTA EN TABLA ZEST_BALANC
  LOOP AT GT_OUTPUT INTO LS_OUTPUT.
    IDENT = 1. " SE SETEA PARA QUE SE BORRE LA CUENTA A BUSCAR
    L_COMP = LS_OUTPUT-SAKNR.
    LOOP AT LSZ.
      IF ( LSZ-NBILKT >= L_COMP ) AND ( LSZ-NVONKT <= L_COMP ).
        IDENT = 0. " SI ENCONTRO LA CUENTA NO SE BORRA
        EXIT.
      ENDIF.

    ENDLOOP.
    IF IDENT = 1.
      MOVE LS_OUTPUT-SAKNR TO LS_OUTPUT2-SAKNR.
      APPEND LS_OUTPUT2. " las cuentas que se encuentran en esta tabla se deben sacar de GT_OUTPUT
    ENDIF.

  ENDLOOP.

  LOOP AT GT_OUTPUT INTO LS_OUTPUT.
    L_ID = SY-TABIX.

    READ TABLE LS_OUTPUT2 WITH KEY SAKNR = LS_OUTPUT-SAKNR.

    IF SY-SUBRC EQ 0.
      DELETE GT_OUTPUT WHERE SAKNR = LS_OUTPUT-SAKNR.
    ENDIF.

 ENDLOOP.




  ENDFORM.                    " ONLY_ESTRUCT
*&---------------------------------------------------------------------*
*&      Form  value_request_path_down
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PATH     text
*----------------------------------------------------------------------*
FORM value_request_path_down  CHANGING p_path.

  DATA: l_path TYPE string.

  MOVE p_path TO l_path.

  CALL METHOD cl_gui_frontend_services=>directory_browse
    CHANGING
      selected_folder      = l_path
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

  MOVE l_path TO p_path.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  user_command_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
      WHEN'OK'.
      SET SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " user_command_0100  INPUT
