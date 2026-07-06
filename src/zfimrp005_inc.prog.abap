*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <23-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZFIMRP005_INC .
*----------------------------------------------------------------------*
FORM REPORTE.
*LEAVE TO LIST-PROCESSING. "AND RETURN TO SCREEN 0.
* LEAVE TO LIST-PROCESSING. NEW-PAGE NO-HEADING NO-TITLE.
  REFRESH: GT_FIELDCAT.
  CLEAR: GT_EVENTS, GT_LIST_TOP_OF_PAGE, LS_TOOLBAR.
  PERFORM BUILD.
*  PERFORM BUILD2.
  PERFORM EVENTTAB_BUILD CHANGING GT_EVENTS.
  PERFORM LAYOUT_INIT USING GS_LAYOUT.
  PERFORM COMMENT_BUILD  CHANGING GT_LIST_TOP_OF_PAGE.
  PERFORM CALL_ALV.
ENDFORM.                    " REPORTE_


*&---------------------------------------------------------------------*
*&      Form  BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUILD.
* DATA FIELD CATALOG
* Explain Field Description to ALV
  DATA: FIELDCAT_IN TYPE SLIS_FIELDCAT_ALV.

  CLEAR FIELDCAT_IN.
  FIELDCAT_LN-FIELDNAME = 'CHEK1'.
*  FIELDCAT_LN-KEY       = 'X'.   "SUBTOTAL KEY
  FIELDCAT_LN-CHECKBOX    = 'X'.
  FIELDCAT_LN-EDIT    = 'X'.
  FIELDCAT_LN-SELTEXT_L = 'Selección'.
  FIELDCAT_LN-HOTSPOT = ' '.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.

  CLEAR FIELDCAT_IN.
  FIELDCAT_LN-FIELDNAME = 'BUKRS'.
  FIELDCAT_LN-KEY       = ' '.   "SUBTOTAL KEY
  FIELDCAT_LN-CHECKBOX   = ' '.
  FIELDCAT_LN-EDIT    = ' '.
  FIELDCAT_LN-SELTEXT_L = 'Sociedad FI'.
  FIELDCAT_LN-HOTSPOT = ' '.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.

  CLEAR FIELDCAT_IN.
  FIELDCAT_LN-FIELDNAME = 'VBLNR'.
  FIELDCAT_LN-KEY       = ' '.   "SUBTOTAL KEY
  FIELDCAT_LN-CHECKBOX   = ' '.
  FIELDCAT_LN-EDIT    = ' '.
  FIELDCAT_LN-SELTEXT_L = 'Numero de Doc Orig.'.
  FIELDCAT_LN-HOTSPOT = 'X'.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.

  CLEAR FIELDCAT_IN.
  FIELDCAT_LN-FIELDNAME = 'ZALDT'.
  FIELDCAT_LN-KEY       = ' '.   "SUBTOTAL KEY
  FIELDCAT_LN-CHECKBOX   = ' '.
  FIELDCAT_LN-EDIT    = ' '.
  FIELDCAT_LN-HOTSPOT = ' '.
  FIELDCAT_LN-SELTEXT_L = 'Fecha Doc. Orig'.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.

  CLEAR FIELDCAT_IN.
  FIELDCAT_LN-FIELDNAME = 'ZNME1'.
  FIELDCAT_LN-KEY       = ' '.   "SUBTOTAL KEY
  FIELDCAT_LN-CHECKBOX   = ' '.
  FIELDCAT_LN-EDIT    = ' '.
  FIELDCAT_LN-HOTSPOT = ' '.
  FIELDCAT_LN-SELTEXT_L = 'Acreedor'.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.

  CLEAR FIELDCAT_IN.
  FIELDCAT_LN-FIELDNAME = 'BELNR'.
  FIELDCAT_LN-KEY       = ' '.   "SUBTOTAL KEY
  FIELDCAT_LN-CHECKBOX   = ' '.
  FIELDCAT_LN-EDIT    = ' '.
  FIELDCAT_LN-SELTEXT_L = 'Numero de Doc.'.
  FIELDCAT_LN-HOTSPOT = 'x'.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.

  CLEAR FIELDCAT_IN.
  FIELDCAT_LN-FIELDNAME = 'BLDAT'.
  FIELDCAT_LN-SELTEXT_L = 'Fecha Contab.'.
  FIELDCAT_LN-HOTSPOT = ' '.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.

  CLEAR FIELDCAT_IN.
  FIELDCAT_LN-FIELDNAME = 'BUZEI'.
  FIELDCAT_LN-SELTEXT_L = 'Posición'.
  FIELDCAT_LN-HOTSPOT = ' '.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.

  CLEAR FIELDCAT_IN.
  FIELDCAT_LN-FIELDNAME = 'CHECT'.
  FIELDCAT_LN-SELTEXT_L = 'Numero de Cheque'.
  FIELDCAT_LN-HOTSPOT = ' '.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.

  CLEAR FIELDCAT_IN.
  FIELDCAT_LN-FIELDNAME = 'WRBTR'.
  FIELDCAT_LN-SELTEXT_L = 'Monto Cheque'.
  FIELDCAT_LN-HOTSPOT = ' '.
  FIELDCAT_LN-CURRENCY  = 'CLP'.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.

  CLEAR FIELDCAT_IN.
  FIELDCAT_LN-FIELDNAME = 'ZMOTE'.
  FIELDCAT_LN-SELTEXT_L = 'Motivo Emisión'.
  FIELDCAT_LN-HOTSPOT = ' '.
  FIELDCAT_LN-CURRENCY  = ' '.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.

  CLEAR FIELDCAT_IN.
  FIELDCAT_LN-FIELDNAME = 'DATEV'.
  FIELDCAT_LN-SELTEXT_L = 'Cant. Dias'.
  FIELDCAT_LN-HOTSPOT = ' '.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.

  CLEAR FIELDCAT_IN.
  FIELDCAT_LN-FIELDNAME  = 'STATUS'.
  FIELDCAT_LN-SELTEXT_L = 'STATUS'.
  FIELDCAT_LN-ICON      = 'X'.
  FIELDCAT_LN-HOTSPOT = ' '.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.

  CLEAR FIELDCAT_IN.
  FIELDCAT_LN-FIELDNAME  = 'ESTADO'.
  FIELDCAT_LN-SELTEXT_L = 'Estado'.
  FIELDCAT_LN-ICON      = 'X'.
  FIELDCAT_LN-HOTSPOT = ' '.
  APPEND FIELDCAT_LN TO GT_FIELDCAT.



* DATA SORTING AND SUBTOTAL
  DATA: GS_SORT TYPE SLIS_SORTINFO_ALV.
ENDFORM.                    "BUILD
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT
*&---------------------------------------------------------------------*

FORM LAYOUT_INIT USING RS_LAYOUT TYPE SLIS_LAYOUT_ALV.
  RS_LAYOUT-GROUP_CHANGE_EDIT = 'X'.
  RS_LAYOUT-DETAIL_POPUP      = 'X'.
  RS_LAYOUT-INFO_FIELDNAME    = 'X'.
  RS_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  RS_LAYOUT-ZEBRA             = 'X'.
ENDFORM.                    "LAYOUT_INIT

*&---------------------------------------------------------------------*
*&      Form  CALL_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CALL_ALV.
  G_REPID = SY-REPID.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = G_REPID
      I_CALLBACK_PF_STATUS_SET = ' '
      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND_DET'
      I_BACKGROUND_ID          = 'LOGOISAPBAN002'
      IS_LAYOUT                = GS_LAYOUT
      IT_FIELDCAT              = GT_FIELDCAT[]
      IT_EVENTS                = GT_EVENTS
    TABLES
      T_OUTTAB                 = T_OK
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
  IF SY-SUBRC <> 0.
  ENDIF.
ENDFORM.                    "CALL_ALV

* HEADER FORM
FORM EVENTTAB_BUILD CHANGING LT_EVENTS TYPE SLIS_T_EVENT.
  CONSTANTS:
  GC_FORMNAME_TOP_OF_PAGE TYPE SLIS_FORMNAME VALUE 'TOP_OF_PAGE'.
  DATA: LS_EVENT TYPE SLIS_ALV_EVENT.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      I_LIST_TYPE = 0
    IMPORTING
      ET_EVENTS   = LT_EVENTS.
  READ TABLE LT_EVENTS WITH KEY NAME =  SLIS_EV_TOP_OF_PAGE   INTO LS_EVENT.
  IF SY-SUBRC = 0.
    MOVE GC_FORMNAME_TOP_OF_PAGE TO LS_EVENT-FORM.
    APPEND LS_EVENT TO LT_EVENTS.
  ENDIF.
ENDFORM.                    "EVENTTAB_BUILD

*&---------------------------------------------------------------------*
*&      Form  COMMENT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->GT_TOP_OF_PAGE  text
*----------------------------------------------------------------------*
FORM COMMENT_BUILD CHANGING GT_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER.
  DATA: GS_LINE TYPE SLIS_LISTHEADER.
  CLEAR GS_LINE.
  GS_LINE-TYP  = 'H'.
  CASE SAVE_CODE.
    WHEN 'PRO_01'.
      IF XELE EQ 'X'.
        GS_LINE-INFO = 'Caducar Electrónico Masivo'.
      ENDIF.
    WHEN 'PRO_04'.
      IF XFIS EQ 'X'.
        GS_LINE-INFO = 'Prescribir'.
      ENDIF.
  ENDCASE.
  APPEND GS_LINE TO GT_TOP_OF_PAGE.

  CLEAR GS_LINE.
  GS_LINE-TYP  = 'S'.
  GS_LINE-KEY  = 'Sociedad'.
  GS_LINE-INFO = BUKRS.
  APPEND GS_LINE TO GT_TOP_OF_PAGE.

  GS_LINE-KEY  = 'Banco'.
  GS_LINE-INFO = HBKID.
  APPEND GS_LINE TO GT_TOP_OF_PAGE.

  GS_LINE-KEY  = 'ID Cuenta'.
  GS_LINE-INFO = HKTID.
  APPEND GS_LINE TO GT_TOP_OF_PAGE.

  GS_LINE-TYP  = 'S'.
  GS_LINE-KEY  = 'Fecha de Ejecución'.
  WRITE: BKPF-BUDAT TO GS_LINE-INFO.
  APPEND GS_LINE TO GT_TOP_OF_PAGE.

  GS_LINE-KEY  = 'Usuario'.
  GS_LINE-INFO = SY-UNAME.
  APPEND GS_LINE TO GT_TOP_OF_PAGE.


ENDFORM.                    "COMMENT_BUILD

*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM TOP_OF_PAGE.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = GT_LIST_TOP_OF_PAGE.
  WRITE: SY-DATUM, 'Page No', SY-PAGNO LEFT-JUSTIFIED.
ENDFORM.                    "TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  END_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM END_OF_PAGE.
  WRITE AT (SY-LINSZ) SY-PAGNO CENTERED.
ENDFORM.                    "END_OF_PAGE



*&---------------------------------------------------------------------*
*&      Form  CADUCA_ELEC_MASIV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PSEL  text
*      -->P_STRUCTURE  text
*      -->P_PSEL  text
*      -->P_T_OK  text
*      -->P_STRUCTURE  text
*      -->P_T_OK  text
*      -->P_BUKRS  text
*      -->P_HBKID  text
*      -->P_HKTID  text
*      -->P_BKPF_BUDAT  text
*----------------------------------------------------------------------*
FORM  CADUCA_ELEC_MASIV   TABLES  PSEL STRUCTURE PSEL
                                  T_OK STRUCTURE T_OK
                            USING BUKRS HBKID HKTID BKPF-BUDAT.



  DATA: T_PAYR LIKE T012K  OCCURS 0 WITH HEADER LINE.
  DATA: T_BSIS LIKE BSIS OCCURS 0 WITH HEADER LINE.
  DATA: T_BSAS LIKE BSAS  OCCURS 0 WITH HEADER LINE.
  DATA: G_HKOD LIKE BSEG-HKONT. "GUARDA CUENTA DE DESTINO"
  DATA: G_SGTXT  LIKE BSEG-SGTXT. "ALMACENAMOS EL TEXTO PARA LA POSICION.
  DATA: G_CHECAUX LIKE T_OK-CHECT.

  REFRESH T_CTA.

  RANGES: P_BUKRS FOR PAYR-ZBUKR.


  SELECT * INTO CORRESPONDING FIELDS OF TABLE T_PAYR
      FROM T012K
     WHERE BUKRS EQ BUKRS
       AND HBKID EQ HBKID
       AND HKTID EQ HKTID.

  DATA: VNUN TYPE N,
        VNUN2(9) TYPE C.

  LOOP AT T_PAYR.
    REFRESH T_CTA.
    VNUN = 1.
    DO 2 TIMES.
      ADD 1 TO VNUN.
      VNUN2 = VNUN.
      CONCATENATE T_PAYR-HKONT+0(9) VNUN2 INTO T_CTA-LOW.
      T_CTA-SIGN = 'I'.
      T_CTA-OPTION = 'EQ'.
      APPEND T_CTA.
      IF   VNUN EQ 2.
        VNUN = 8.
      ENDIF.
    ENDDO.
  ENDLOOP.

*Begin of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 23/12/2019 EY_DES02 ECDK917080 *
SORT T_CTA .
*End of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 23/12/2019 EY_DES02 ECDK917080 *
  DELETE ADJACENT DUPLICATES FROM T_CTA.

*    ASIGNA VALOR A G_HKOD ******************************
  CONCATENATE T_PAYR-HKONT+0(9) '7' INTO G_HKOD.
*********************************************************

  SELECT  * APPENDING  CORRESPONDING FIELDS OF TABLE  T_BSIS
    FROM BSIS
   WHERE BUKRS = BUKRS
     AND HKONT IN T_CTA.

  CONCATENATE 'Caducar Electronico Masivo'  ' - '  SY-DATUM INTO G_SGTXT.
  G_LITTLE = 'Proceso de Caducado Electrónico (Masivo)'.

  LOOP AT  T_BSIS.


* Si   Existe registro, por lo tanto cheque sin compensar, verificar si han pasado los 60 días para caducar
    DATA: DATEDIFF  TYPE  P,
    TIMEDIFF  TYPE  P,
    EARLIEST  TYPE  C.
    DATA: P_KOUHR1 TYPE KOUHR,
          P_KOUHR2 TYPE KOUHR.
    P_KOUHR1 = SY-UZEIT.
    P_KOUHR2 =  P_KOUHR1.
*    IF T_BSIS-HKONT+9(1) = 2.
      CALL FUNCTION 'SD_DATETIME_DIFFERENCE'
        EXPORTING
*          DATE1            = T_BSIS-BLDAT
          DATE1            = T_BSIS-VALUT
          TIME1            = P_KOUHR1
          DATE2            = BKPF-BUDAT
          TIME2            = P_KOUHR2
        IMPORTING
          DATEDIFF         = DATEDIFF
          TIMEDIFF         = TIMEDIFF
          EARLIEST         = EARLIEST
        EXCEPTIONS
          INVALID_DATETIME = 1
          OTHERS           = 2.
*    ELSE.
*       CALL FUNCTION 'SD_DATETIME_DIFFERENCE'
*        EXPORTING
*          DATE1            = T_BSIS-BLDAT
**          DATE1            = T_BSIS-VALUT
*          TIME1            = P_KOUHR1
*          DATE2            = BKPF-BUDAT
*          TIME2            = P_KOUHR2
*        IMPORTING
*          DATEDIFF         = DATEDIFF
*          TIMEDIFF         = TIMEDIFF
*          EARLIEST         = EARLIEST
*        EXCEPTIONS
*          INVALID_DATETIME = 1
*          OTHERS           = 2.
*    ENDIF.
    IF SY-SUBRC EQ 0.
      DATA: P_VOIDR TYPE PAYR-VOIDR.
      CLEAR: G_CHECAUX,P_VOIDR.

      IF EARLIEST EQ 2.
        DATEDIFF = DATEDIFF * -1.
        DES_CTA = G_DESF.
      ENDIF.

      IF T_BSIS-HKONT+9(1) EQ 2.
        SELECT *
        FROM PAYR
        INTO CORRESPONDING FIELDS OF TABLE IT_PAYR
        WHERE ICHEC EQ ''
          AND ZBUKR EQ BUKRS
          AND HBKID EQ HBKID
          AND HKTID EQ HKTID
          AND VBLNR EQ T_BSIS-BELNR.
      ELSE.
        SELECT *
          FROM PAYR
       INTO CORRESPONDING FIELDS OF TABLE IT_PAYR
       WHERE ICHEC EQ ''
         AND ZBUKR EQ BUKRS
         AND HBKID EQ HBKID
         AND HKTID EQ HKTID
         AND CHECT EQ T_BSIS-ZUONR.
      ENDIF.

      IF SY-SUBRC EQ 0.
        READ TABLE IT_PAYR INDEX 1.
      ENDIF.

******** Validacion de cuenta **************************
      PERFORM VALID_CTA  USING T_BSIS-HKONT+9(1)  SAVE_CODE
                      CHANGING G_VALID_CTA.
********************************************************
      PERFORM DESC_CTA USING T_BSIS-HKONT+9(1) CHANGING DES_CTA.
      IF IT_PAYR-VOIDR GT 0. " causa de anulacion
        DES_CTA = 'CHEQUE ANULADO'.
        G_VALID_CTA = 1.
      ENDIF.
**************************************************************************
      PERFORM  ZMOT_EMIS USING BUKRS  T_BSIS-BELNR T_BSIS-GJAHR
                      CHANGING P_ZMOT_EMIS.
**************************************************************************
* Si diferencia de fechas es menos a 60 doias no se podra caducar.
      IF DATEDIFF >= 60.
        CLEAR:   T_OK.
        IF T_BSIS-HKONT+9(1) EQ 2.
          MOVE: IT_PAYR-VBLNR TO T_OK-BELNR.
        ELSE.
          MOVE: T_BSIS-BELNR TO T_OK-BELNR.
        ENDIF.

        IF G_VALID_CTA EQ 1.
          MOVE '@0A@'    TO T_OK-STATUS. " ICONO MAL
        ELSE.
          MOVE '@08@'    TO T_OK-STATUS. " ICONO BIEN
        ENDIF.

        MOVE: T_BSIS-BUKRS TO T_OK-BUKRS,
        T_BSIS-BUZEI  TO T_OK-BUZEI,
        T_BSIS-GJAHR  TO T_OK-GJAHR,
        T_BSIS-HKONT  TO T_OK-HKONT,
        T_BSIS-WRBTR  TO T_OK-WRBTR,
        G_HKOD        TO T_OK-HKONTD,
         'X'          TO T_OK-CHEK1,
        G_SGTXT       TO T_OK-SGTXT,
        DATEDIFF      TO T_OK-DATEV,
        IT_PAYR-CHECT TO T_OK-CHECT,
        DES_CTA       TO T_OK-ESTADO,
        IT_PAYR-VBLNR TO T_OK-VBLNR,
        G_LITTLE      TO T_OK-LITTLE,
        T_BSIS-BLDAT  TO T_OK-BLDAT,
        IT_PAYR-ZALDT TO T_OK-ZALDT,
        IT_PAYR-ZNME1 TO T_OK-ZNME1,
        P_ZMOT_EMIS   TO T_OK-ZMOTE.

        MOVE : HBKID  TO T_OK-HBKID,
               HKTID  TO T_OK-HKTID,
               S_PBUDAT-LOW  TO T_OK-PBUDAT.

      ELSE.
        CLEAR:   T_OK.
        MOVE: T_BSIS-BELNR TO T_OK-BELNR,
        '@0A@'    TO T_OK-STATUS,
        T_BSIS-BUKRS TO T_OK-BUKRS,
        T_BSIS-BUZEI TO T_OK-BUZEI,
        T_BSIS-GJAHR TO T_OK-GJAHR,
        T_BSIS-HKONT TO T_OK-HKONT,
        T_BSIS-WRBTR TO T_OK-WRBTR,
         'X'         TO T_OK-CHEK1,
        G_HKOD       TO T_OK-HKONTD,
        G_SGTXT      TO T_OK-SGTXT,
        DATEDIFF     TO T_OK-DATEV,
        G_CHECAUX    TO T_OK-CHECT,
        DES_CTA      TO T_OK-ESTADO,
        IT_PAYR-VBLNR TO T_OK-VBLNR,
        IT_PAYR-ZALDT TO T_OK-ZALDT,
        IT_PAYR-ZNME1 TO T_OK-ZNME1,
        P_ZMOT_EMIS   TO T_OK-ZMOTE.

        MOVE : HBKID  TO T_OK-HBKID,
               HKTID  TO T_OK-HKTID,
        S_PBUDAT-LOW  TO T_OK-PBUDAT,
        T_BSIS-BLDAT  TO T_OK-BLDAT.
      ENDIF.
      APPEND T_OK.
    ENDIF.
  ENDLOOP.

ENDFORM.  " CADUCA_ELEC_MASIV

*&---------------------------------------------------------------------*
*&      Form  EJEC_MAS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM EJEC_MAS .
  DATA G_RESP.
  IF T_OK IS NOT INITIAL.
    G_RESP = '1'.
    IF G_RESP EQ '1'. " SI"
      PERFORM GENE_JUEGO_DATOS.
    ELSEIF G_RESP EQ '2'. " NO
      CLEAR T_OK.
      REFRESH T_OK.
    ELSEIF G_RESP EQ 'A'. "CANCELAR".
      CLEAR T_OK.
      REFRESH T_OK.
    ENDIF.

  ENDIF.
ENDFORM.                    " EJEC_MAS
*&---------------------------------------------------------------------*
*&      Form  DESC_CTA
*&---------------------------------------------------------------------*
*       text obtiene descripcion de cuenta
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DESC_CTA USING CTA TYPE C
              CHANGING DES_CTA.

  CASE CTA.
    WHEN 0.
      DES_CTA =  'SALDO'.
    WHEN 1.
      DES_CTA =  'DEPOSITO'.
    WHEN 2.
      DES_CTA =  'CHEQUE GIRADO'.
    WHEN 3.
      DES_CTA =  'CARGOS'.
    WHEN 4.
      DES_CTA =  'ABONOS'.
    WHEN 5.
      DES_CTA =  'TRANSFERENCIAS'.
    WHEN 6.
      DES_CTA =  'CADUCADO FÍSICO'.
    WHEN 7.
      DES_CTA =  'CADUCADO ELECTRÓNICO'.
    WHEN 8.
      DES_CTA =  'CADUCADO FISCAL'.
    WHEN 9.
      DES_CTA =  'REVALIDADO'.
    WHEN OTHERS.
      DES_CTA =  '--'.
  ENDCASE.


ENDFORM.                    " DESC_CTA
*&---------------------------------------------------------------------*
*&      Form  PARAMETROS_JDATOS
*&---------------------------------------------------------------------*
FORM PARAMETROS_JDATOS.
*- Nombre Juego Datos
  I_TABLSUBM-SELNAME = 'MAPPE'.
  I_TABLSUBM-KIND    = 'P'.
  I_TABLSUBM-SIGN    = 'I'.
  I_TABLSUBM-OPTION  = 'EQ'.
  I_TABLSUBM-LOW     = GROUP.
  APPEND I_TABLSUBM.
*- Fecha Desde
  I_TABLSUBM-SELNAME = 'VON'.
  I_TABLSUBM-KIND    = 'P'.
  I_TABLSUBM-SIGN    = 'I'.
  I_TABLSUBM-OPTION  = 'EQ'.
  I_TABLSUBM-LOW     = SY-DATUM.
  APPEND I_TABLSUBM.

*- Checkbox A Procesar
  I_TABLSUBM-SELNAME = 'Z_VERARB'.
  I_TABLSUBM-KIND    = 'P'.
  I_TABLSUBM-SIGN    = 'I'.
  I_TABLSUBM-OPTION  = 'EQ'.
  I_TABLSUBM-LOW     = 'X'.
  APPEND I_TABLSUBM.

  I_TABLSUBM-SELNAME = 'FEHLER'.
  I_TABLSUBM-KIND    = 'P'.
  I_TABLSUBM-SIGN    = 'I'.
  I_TABLSUBM-OPTION  = 'EQ'.
  I_TABLSUBM-LOW     = SPACE.
  APPEND I_TABLSUBM.

*- Máquina Destino
  I_TABLSUBM-SELNAME = 'BATCHSYS'.
  I_TABLSUBM-KIND    = 'P'.
  I_TABLSUBM-SIGN    = 'I'.
  I_TABLSUBM-OPTION  = 'EQ'.
  I_TABLSUBM-LOW     = SY-HOST.
  APPEND I_TABLSUBM.
ENDFORM.                    " PARAMETROS_JDATOS

*&---------------------------------------------------------------------*
*&      Form  VALID_CTA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->G_CTA        text
*      -->G_PROCESO    text
*      -->G_VALID_CTA  text
*----------------------------------------------------------------------*
FORM VALID_CTA  USING    G_CTA G_PROCESO
                CHANGING G_VALID_CTA.
  G_VALID_CTA = 0.
  CASE G_PROCESO.
    WHEN 'PRO_01'. " caducado electronico.
      IF G_CTA EQ 0.
        G_VALID_CTA = 1.
      ENDIF.

      IF G_CTA EQ 1.
        G_VALID_CTA = 1.
      ENDIF.

      IF G_CTA EQ 3.
        G_VALID_CTA = 1.
      ENDIF.

      IF G_CTA EQ 4.
        G_VALID_CTA = 1.
      ENDIF.

      IF G_CTA EQ 5.
        G_VALID_CTA = 1.
      ENDIF.

      IF G_CTA EQ 6.
        G_VALID_CTA = 1.
      ENDIF.

      IF G_CTA EQ 7.
        G_VALID_CTA = 1.
      ENDIF.

      IF G_CTA EQ 8.
        G_VALID_CTA = 1.
      ENDIF.
    WHEN 'PRO_02'. " caducado fisico
      IF G_CTA EQ 0.
        G_VALID_CTA = 1.
      ENDIF.

      IF G_CTA EQ 1.
        G_VALID_CTA = 1.
      ENDIF.

      IF G_CTA EQ 3.
        G_VALID_CTA = 1.
      ENDIF.

      IF G_CTA EQ 4.
        G_VALID_CTA = 1.
      ENDIF.

      IF G_CTA EQ 5.
        G_VALID_CTA = 1.
      ENDIF.

      IF G_CTA EQ 6.
        G_VALID_CTA = 1.
      ENDIF.

      IF G_CTA EQ 8.
        G_VALID_CTA = 1.
      ENDIF.

    WHEN OTHERS.
      G_VALID_CTA = 0.
  ENDCASE.

ENDFORM.                    " VALID_CTA
*&---------------------------------------------------------------------*
*&      Form  GENE_JUEGO_DATOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GENE_JUEGO_DATOS .
  TABLES: BBKPF,      "Cab.documento para documento contable (estruct. bat
          BBSEG,      "Segmento de documento contable (estruct. batch inpu
          BGR00,      "Estructura batch input para datos de juego de datos
          BSELK,
          BSELP.


  DATA: NOMBRE_LOGICO LIKE V_FILENACI-FILEINTERN VALUE
                         'Z_INTERFAZ_FI',
                         JUEGO_DATOS(75),
                         ARCH_ENTRADA(75),
                         NOM_JD1(12),
                         FECHA_JD LIKE SY-DATUM,
                         REG(44),
                         NUEVO_DOCTO(1).

  G_EXIS =  'N'.

  LOOP AT T_OK.
    IF T_OK-STATUS EQ '@08@' AND T_OK-CHEK1 EQ 'X'.
      G_EXIS = 'S'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF G_EXIS EQ 'S'.
    CONCATENATE 'CAD' '_' SY-UZEIT INTO JUEGO_DATOS.
    GROUP = JUEGO_DATOS.

    DATA : PATH_FILE     LIKE RLGRAP-FILENAME.
    IF SAVE_CODE ='PR0_01'.
      CONCATENATE PATH_FILE '/interfaces/cheques/caducados/' INTO PATH_FILE.
    ENDIF.

    IF SAVE_CODE ='PR0_04'.
      CONCATENATE PATH_FILE '/interfaces/cheques/prescritos/' INTO PATH_FILE.
    ENDIF.


    CONCATENATE PATH_FILE S_BUKRS-LOW '_' SY-DATUM '_' SY-UZEIT '.txt' INTO PATH_FILE.
    CONDENSE PATH_FILE NO-GAPS.

    OPEN DATASET JUEGO_DATOS FOR OUTPUT IN TEXT MODE
                               ENCODING DEFAULT.
*                               WITH SMART.
*        Inicializa las estructuras del batch-input con '/' (nodata)
    PERFORM INICIALIZA_JD USING BBSEG.
    PERFORM INICIALIZA_JD USING BBKPF.
    PERFORM INICIALIZA_JD USING BSELK.
    PERFORM INICIALIZA_JD USING BSELP.

*   Se genera la estructura de datos
    PERFORM CREAR_JUEGO_DATOS USING JUEGO_DATOS.
    CLOSE DATASET JUEGO_DATOS.

*      Se llama al programa estandar que genera el batch input.
    SUBMIT RFBIBL00 WITH DS_NAME  = JUEGO_DATOS
                    WITH CALLMODE = 'B'
                    WITH XINF = 'X'
                AND RETURN.


* lanza el juego de datos.
    DATA:   QID       LIKE APQI-QID,
            QID01     LIKE APQI-QID.
    DATA: CONT TYPE I.

    SELECT SINGLE * FROM APQI
        WHERE  GROUPID EQ GROUP
           AND  QSTATE  EQ ' '
           AND  USERID  EQ SY-UNAME
           AND  CREDATE EQ SY-DATUM.
    MOVE APQI-QID TO QID.

    IF SY-SUBRC EQ 0.
      PERFORM PARAMETROS_JDATOS.
* lanza el juego de datos.
      SUBMIT RSBDCSUB  WITH SELECTION-TABLE I_TABLSUBM AND RETURN.
      DO.
        IF CONT < 9999999.
*        COMMIT WORK.
* DO de Espera Mientras el juego de datos se ejecute totalmente
          SELECT SINGLE * FROM APQI
              WHERE QID     EQ QID
              AND   USERID  EQ SY-UNAME
              AND   GROUPID EQ GROUP.
          IF SY-SUBRC EQ 0.
            IF  APQI-QSTATE  EQ 'F' OR APQI-QSTATE  EQ 'E' .
              PERFORM FILE_RES USING PATH_FILE.
*         Se graba Historia
              PERFORM  ZRESERVA.
              EXIT.
            ENDIF.
            CONT = 0.
          ELSE.
            WAIT UP TO 3 SECONDS.
          ENDIF.
        ENDIF.
        ADD 1 TO CONT.
      ENDDO.
    ELSE.
      WRITE: / 'EL JUEGO DE DATOS NO EXISTE'.
    ENDIF.

    WRITE: / 'Archivo Generado :  ',
              PATH_FILE.
  ELSE.
    WRITE: / 'No hay datos para Procesar '.
  ENDIF.

ENDFORM.                    " GENE_JUEGO_DATOS
*&---------------------------------------------------------------------*
*&      Form  INICIALIZA_JD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->TABLA      text
*----------------------------------------------------------------------*
FORM   INICIALIZA_JD USING TABLA.
  DATA: L_ACUMU TYPE I.
  DO.
    ADD 1 TO L_ACUMU.
    ASSIGN COMPONENT L_ACUMU OF STRUCTURE TABLA TO <F>.
    IF SY-SUBRC NE 0. EXIT. ENDIF.
    MOVE '/' TO <F>.
  ENDDO.

ENDFORM.                    "INICIALIZA_JD

*&---------------------------------------------------------------------*
*&      Form  CREAR_JUEGO_DATOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CREAR_JUEGO_DATOS USING JUEGO_DATOS.
* Cabecera de la transacción con el juego de datos
  PERFORM CREA_CABECERA_JD USING JUEGO_DATOS.

  LOOP AT T_OK.
    IF T_OK-STATUS EQ '@08@' AND T_OK-CHEK1 EQ 'X'.
      G_EXIS = 'S'.
      PERFORM CREA_CABECERA_BBKPF USING JUEGO_DATOS.
      PERFORM CREA_CABECERA_BBSEG USING JUEGO_DATOS.
      PERFORM CREA_CABECERA_BSELK USING JUEGO_DATOS.
      PERFORM CREA_CABECERA_BSELP USING JUEGO_DATOS.
    ENDIF.
*    ELSE.
*      PERFORM CREA_CABECERA_BBSEG USING JUEGO_DATOS.
*    ENDIF.
  ENDLOOP.
ENDFORM.                    "CREAR_JUEGO_DATOS


*&---------------------------------------------------------------------*
*&      Form  CREA_CABECERA_JD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FICHERO    text
*----------------------------------------------------------------------*
FORM CREA_CABECERA_JD USING FICHERO.

  MOVE: '0'            TO BGR00-STYPE,
        FICHERO        TO BGR00-GROUP,
        SY-MANDT       TO BGR00-MANDT,
        SY-UNAME       TO BGR00-USNAM,
        'X'            TO BGR00-XKEEP,
        '/'            TO BGR00-NODATA.
  TRANSFER BGR00 TO FICHERO.

ENDFORM.                               "F_BATCH_DOCU

*&---------------------------------------------------------------------*
*&      Form  CREA_CABECERA_BBKPF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FICHERO    text
*----------------------------------------------------------------------*
FORM CREA_CABECERA_BBKPF USING FICHERO.

  MOVE: '1'                   TO BBKPF-STYPE,
*        'BBKPF'               TO BBKPF-TBNAM,
        'FB05'                TO BBKPF-TCODE,    "Cod. transaccion
        'ZA'                  TO BBKPF-BLART,    "Clase documento
        T_OK-BUKRS            TO BBKPF-BUKRS,    "Sociedad
         BKPF-BUDAT+4(2)      TO BBKPF-MONAT,    "Mes contable
        'CLP'                 TO BBKPF-WAERS,    "Moneda
  'Cambio Estado cheque'      TO BBKPF-BKTXT.    "Texto Cab.Docto


*  IF T_OK-BLDAT IS NOT INITIAL.
*    CONCATENATE T_OK-BLDAT+6(2)
*                T_OK-BLDAT+4(2)
*                T_OK-BLDAT+0(4) INTO BBKPF-BLDAT.
*  ELSE.
*    CONCATENATE BKPF-BUDAT+6(2)
*                BKPF-BUDAT+4(2)
*                BKPF-BUDAT+0(4) INTO BBKPF-BLDAT.
*  ENDIF.
*

  DATA : P_BUDAT TYPE BLDAT.
  SELECT SINGLE  BUDAT INTO P_BUDAT
    FROM  BKPF
   WHERE  BUKRS EQ T_OK-BUKRS
     AND  BELNR EQ T_OK-VBLNR
     AND  GJAHR EQ T_OK-GJAHR.

  IF SY-SUBRC EQ 0.
    CONCATENATE P_BUDAT+6(2)
                P_BUDAT+4(2)
                P_BUDAT+0(4) INTO BBKPF-BLDAT.
  ELSE.
    CONCATENATE BKPF-BUDAT+6(2)
                BKPF-BUDAT+4(2)
                BKPF-BUDAT+0(4) INTO BBKPF-BLDAT.
  ENDIF.

  CONCATENATE BKPF-BUDAT+6(2)
              BKPF-BUDAT+4(2)
              BKPF-BUDAT+0(4) INTO BBKPF-BUDAT.




*  BBKPF-BLDAT = SY-DATUM.
*  BBKPF-BUDAT = BKPF-BUDAT.
  BBKPF-AUGLV = 'UMBUCHNG'.
  BBKPF-DOCID   = '*'.

*  IF ARCH_PLANO-KURSF NE SPACE.
  MOVE '1'    TO BBKPF-KURSF.
*  ENDIF.
*  IF ARCH_PLANO-BELNR NE SPACE.
**    MOVE ARCH_PLANO-BELNR    TO BBKPF-BELNR.
*  ENDIF.
*  IF ARCH_PLANO-WWERT NE SPACE.
**    MOVE ARCH_PLANO-WWERT    TO BBKPF-WWERT.
*  ENDIF.
*  IF ARCH_PLANO-XBLNR NE SPACE.
**    MOVE ARCH_PLANO-XBLNR    TO BBKPF-XBLNR.
*  ENDIF.


  TRANSFER BBKPF TO FICHERO.
  PERFORM INICIALIZA_JD USING BBKPF.
ENDFORM.                               "F_CREA_CABECERA_BBKPF
*&---------------------------------------------------------------------*
*&      Form  CREA_CABECERA_BBSEG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FICHERO    text
*----------------------------------------------------------------------*
FORM CREA_CABECERA_BBSEG USING FICHERO.
  DATA :  G_WRBTR(10),
          G_WRBTRI TYPE P DECIMALS 0.
  G_WRBTR = T_OK-WRBTR.
  REPLACE '.'  WITH ' ' INTO G_WRBTR.
  CONDENSE G_WRBTR NO-GAPS.
  G_WRBTRI =  G_WRBTR.

  MOVE: '2'                   TO BBSEG-STYPE,
        'BBSEG'               TO BBSEG-TBNAM,
        '50'                  TO BBSEG-NEWBS,    "Clave contabil.
        T_OK-HKONTD           TO BBSEG-NEWKO,    "Cuenta
        G_WRBTRI              TO BBSEG-WRBTR,    "Importe mon doc
        T_OK-SGTXT            TO BBSEG-SGTXT.


  IF T_OK-CHECT IS NOT INITIAL.
    MOVE T_OK-CHECT            TO BBSEG-ZUONR.    "ASIGNACION
  ENDIF.

  MOVE T_OK-ZMOTE              TO BBSEG-ZZMOT_EMIS. " MOTIVO DE EMISION



*IF SAVE_CODE ='PR0_04'.
*  BBSEG-PRCTR = 9999999999.
*ENDIF.



*     Si los campos vienen vacíos, se deja el signo '/' (nodata)

*  IF ARCH_PLANO-DMBTR NE SPACE.
*    MOVE ARCH_PLANO-DMBTR    TO BBSEG-DMBTR.
*  ENDIF.
*
*  IF ARCH_PLANO-NEWUM NE SPACE.
*    MOVE ARCH_PLANO-NEWUM    TO BBSEG-NEWUM.
*  ENDIF.
*  IF ARCH_PLANO-NEWBW NE SPACE.
*    MOVE ARCH_PLANO-NEWBW    TO BBSEG-NEWBW.
*  ENDIF.
*  IF ARCH_PLANO-ZFBDT NE SPACE.
*    CONCATENATE ARCH_PLANO-ZFBDT+0(2)
*                ARCH_PLANO-ZFBDT+3(2)
*                ARCH_PLANO-ZFBDT+6(4) INTO BBSEG-ZFBDT.
*  ENDIF.
*  IF ARCH_PLANO-ZTERM NE SPACE.
*    MOVE ARCH_PLANO-ZTERM    TO BBSEG-ZTERM.
*  ENDIF.
*  IF ARCH_PLANO-VALUT NE SPACE.
*    CONCATENATE ARCH_PLANO-VALUT+0(2)
*                ARCH_PLANO-VALUT+3(2)
*                ARCH_PLANO-VALUT+6(4) INTO BBSEG-VALUT.

  IF SAVE_CODE NE 'PR0_04'.
    CONCATENATE BKPF-BUDAT+6(2)
          BKPF-BUDAT+4(2)
          BKPF-BUDAT+0(4) INTO BBSEG-VALUT.
  ENDIF.
*  BBSEG-VALUT = BKPF-BUDAT.
*  ENDIF.
*  IF ARCH_PLANO-ZLSPR NE SPACE.
*    MOVE ARCH_PLANO-ZLSPR    TO BBSEG-ZLSPR.
*  ENDIF.
*  IF ARCH_PLANO-ZLSCH NE SPACE.
*    MOVE ARCH_PLANO-ZLSCH    TO BBSEG-ZLSCH.
*  ENDIF.
*  IF ARCH_PLANO-BANKL NE SPACE.
*    MOVE ARCH_PLANO-BANKL    TO BBSEG-BANKL.
*  ENDIF.
*  IF ARCH_PLANO-BANKS NE SPACE.
*    MOVE ARCH_PLANO-BANKS    TO BBSEG-BANKS.
*  ENDIF.
*  IF ARCH_PLANO-BANKN NE SPACE.
*    MOVE ARCH_PLANO-BANKN    TO BBSEG-BANKN.
*  ENDIF.
*  IF ARCH_PLANO-HBKID NE SPACE.
*    MOVE ARCH_PLANO-HBKID    TO BBSEG-HBKID.
*  ENDIF.
*  IF ARCH_PLANO-REGUL NE SPACE.
*    MOVE ARCH_PLANO-REGUL    TO BBSEG-REGUL.
*  ENDIF.
*  IF ARCH_PLANO-NAME1 NE SPACE.
*    MOVE ARCH_PLANO-NAME1    TO BBSEG-NAME1.
*  ENDIF.
*  IF ARCH_PLANO-NAME3 NE SPACE.
*    MOVE ARCH_PLANO-NAME3    TO BBSEG-NAME3.
*  ENDIF.
*  IF ARCH_PLANO-ORT01 NE SPACE.
*    MOVE ARCH_PLANO-ORT01    TO BBSEG-ORT01.
*  ENDIF.
*  IF ARCH_PLANO-ZUONR NE SPACE.
*    MOVE ARCH_PLANO-ZUONR    TO BBSEG-ZUONR.
*  ENDIF.
*  IF ARCH_PLANO-SGTXT NE SPACE.
*    MOVE ARCH_PLANO-SGTXT    TO BBSEG-SGTXT.
*  ENDIF.
*  IF ARCH_PLANO-KOSTL NE SPACE.
*    MOVE ARCH_PLANO-KOSTL    TO BBSEG-KOSTL.
*  ENDIF.
*  IF ARCH_PLANO-SKFBT NE SPACE.
*    MOVE ARCH_PLANO-SKFBT    TO BBSEG-SKFBT.
*  ENDIF.
*  IF ARCH_PLANO-AUFNR NE SPACE.
*    MOVE ARCH_PLANO-AUFNR    TO BBSEG-AUFNR.
*  ENDIF.
*
*  IF ARCH_PLANO-MENGE NE SPACE.
*    MOVE ARCH_PLANO-MENGE    TO BBSEG-MENGE.
*  ENDIF.
*
*  IF ARCH_PLANO-MEINS NE SPACE.
*    MOVE ARCH_PLANO-MEINS    TO BBSEG-MEINS.
*  ENDIF.

  TRANSFER BBSEG TO FICHERO.
  PERFORM INICIALIZA_JD USING BBSEG.

ENDFORM.                    "CREA_CABECERA_BBSEG
*&---------------------------------------------------------------------*
*&      Form  CREA_CABECERA_BSELK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JUEGO_DATOS  text
*----------------------------------------------------------------------*
FORM CREA_CABECERA_BSELK  USING    JUEGO_DATOS.
  MOVE: '2'                   TO BSELK-STYPE,
        'BSELK'               TO BSELK-TBNAM.


  BSELK-AGKON  = T_OK-HKONT.
  BSELK-AGBUK  = T_OK-BUKRS.
  BSELK-AGKOA  = 'S'.
  BSELK-XNOPS  = 'X'.
  TRANSFER BSELK TO JUEGO_DATOS.
  PERFORM INICIALIZA_JD USING BSELK.

ENDFORM.                    " CREA_CABECERA_BSELK
*&---------------------------------------------------------------------*
*&      Form  CREA_CABECERA_BSELP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_JUEGO_DATOS  text
*----------------------------------------------------------------------*
FORM CREA_CABECERA_BSELP  USING    JUEGO_DATOS.
  MOVE: '2'                   TO BSELP-STYPE,
      'BSELP'               TO BSELP-TBNAM.
  BSELP-FELDN_1 = 'BELNR'.
  CONCATENATE T_OK-BELNR T_OK-GJAHR T_OK-BUZEI INTO BSELP-SLVON_1.
  TRANSFER BSELP TO JUEGO_DATOS.
  PERFORM INICIALIZA_JD USING BSELP.
ENDFORM.                    " CREA_CABECERA_BSELP

*&---------------------------------------------------------------------*
*&      Form  FILE_RES
*&---------------------------------------------------------------------*
*       text CREACION DE ARCHIVO PLANO PARA EL RESUMEN DE CADUCIDAD.
*
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILE_RES USING PATH_FILE.

  DATA:  V_HORIZ_TAB(1) TYPE C.
*  Variables para archivo *****
  DATA: P_FECEJEC(40) TYPE C.
  DATA: P_USUARIO(40) TYPE C.
  DATA: P_LINEA(500) TYPE C.
  DATA: P_ID TYPE I.
  DATA: P_FEC(10) TYPE C.
  DATA: TXT1(10),TXT2(10),TXT3(10) ,TXT4(10) ,TXT5(20) ,TXT6(20) ,TXT7(20) ,TXT8(10).
  DATA: TXTVAL(15),TXTFECD(20),TXTACR(30) ,TXTEMI(20), TXTBUDAT(20).
  DATA: P_DOC TYPE BSIS-BELNR.
*  DATA: gt_data TYPE STANDARD TABLE OF ty_tab. "Datos a transferir
  IF T_OK IS NOT INITIAL.
    OPEN DATASET PATH_FILE FOR OUTPUT IN TEXT MODE ENCODING UTF-8.



*      TAB
    V_HORIZ_TAB = CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB.

    CONCATENATE S_PBUDAT-LOW+6(2) '.'
              S_PBUDAT-LOW+4(2) '.'
              S_PBUDAT-LOW+0(4) INTO P_FEC.

*     se realiza el cuadro de resumen.
    CONCATENATE 'Fecha de Ejecución ' ' : '  P_FEC INTO P_FECEJEC.
    CONCATENATE 'Usuario ' ' : ' SY-UNAME INTO P_USUARIO.

    TRANSFER 'Cambio Estado de Cheques' TO PATH_FILE .
    TRANSFER G_LITTLE TO PATH_FILE .
    TRANSFER P_FECEJEC TO PATH_FILE.
    TRANSFER P_USUARIO TO PATH_FILE.
    TRANSFER ' ' TO PATH_FILE.
*     TITULOS
    PERFORM TITULOS USING PATH_FILE.

  ENDIF.
* detalle
  P_ID = 0.
  LOOP AT T_OK.
    CLEAR : TXT1,TXT2,TXT3,TXT4,TXT5,TXT6,TXT7,TXT8.
    CLEAR : TXTVAL,TXTFECD,TXTACR,TXTEMI.
    IF T_OK-STATUS EQ '@08@' AND T_OK-CHEK1 EQ 'X'.
      P_ID = P_ID + 1.
      CLEAR P_DOC.
*      SELECT SINGLE BELNR INTO P_DOC
*       FROM BSIS
*      WHERE BUKRS EQ T_OK-BUKRS
*        AND HKONT EQ T_OK-HKONTD
*        AND ZUONR EQ T_OK-CHECT
*        AND GJAHR EQ T_OK-GJAHR.

      SELECT SINGLE AUGBL INTO P_DOC
        FROM BSAS
        WHERE BUKRS EQ T_OK-BUKRS
          AND HKONT EQ T_OK-HKONT
*    AND ZUONR EQ T_OK-CHECT
          AND GJAHR EQ T_OK-GJAHR
          AND BELNR EQ T_OK-BELNR.


      IF SY-SUBRC EQ 0.
        TXT6 = P_DOC.
        MOVE P_DOC TO T_OK-BELNRACT.
      ELSE.
        TXT6 = '999'.
      ENDIF.

      TXT1 = P_ID.
      TXT2 = T_OK-BUKRS.
      TXT3 = S_HBKID-LOW.
      TXT4 = S_HKTID-LOW.
      TXT5 = T_OK-VBLNR.
      TXT7 = T_OK-CHECT.
      WRITE: T_OK-WRBTR TO TXTVAL CURRENCY 'CLP'.
*      TXTVAL = T_OK-WRBTR.
      TXTFECD = T_OK-ZALDT.
      TXTACR  = T_OK-ZNME1.
      TXTEMI  = T_OK-ZMOTE.
      TXTBUDAT = S_PBUDAT-LOW.

      IF  TXT5 IS INITIAL.
        CONCATENATE '-' TXT5 INTO TXT5.
      ENDIF.

      IF  TXT7 IS INITIAL.
        CONCATENATE '-' TXT7 INTO TXT7.
      ENDIF.

      IF TXTFECD IS INITIAL.
        CONCATENATE '-' TXTFECD INTO TXTFECD.
      ENDIF.

      IF TXTACR IS INITIAL.
        CONCATENATE '-' TXTACR INTO TXTACR.
      ENDIF.

      IF TXTEMI IS INITIAL.
        CONCATENATE '-' TXTEMI INTO TXTEMI.
      ENDIF.


      SHIFT TXT1 RIGHT DELETING TRAILING SPACE.
      SHIFT TXT2 RIGHT DELETING TRAILING SPACE.
      SHIFT TXT3 RIGHT DELETING TRAILING SPACE.
      SHIFT TXT4 RIGHT DELETING TRAILING SPACE.
      SHIFT TXT5 RIGHT DELETING TRAILING SPACE.
      SHIFT TXT6 RIGHT DELETING TRAILING SPACE.
      SHIFT TXT7 RIGHT DELETING TRAILING SPACE.
      SHIFT TXTVAL RIGHT DELETING TRAILING SPACE.
      SHIFT TXTFECD RIGHT DELETING TRAILING SPACE.
      SHIFT TXTACR  RIGHT DELETING TRAILING SPACE.
      SHIFT TXTEMI  RIGHT DELETING TRAILING SPACE.
      SHIFT TXTBUDAT RIGHT DELETING TRAILING SPACE.

      CONCATENATE TXT1 V_HORIZ_TAB
               TXT2 V_HORIZ_TAB
               TXT3 V_HORIZ_TAB
               TXT4 V_HORIZ_TAB
               TXT5 V_HORIZ_TAB
               TXTFECD V_HORIZ_TAB
               TXT6 V_HORIZ_TAB
               TXTBUDAT V_HORIZ_TAB
               TXT7 V_HORIZ_TAB    "CHEQUE
               TXTVAL V_HORIZ_TAB
               TXTACR V_HORIZ_TAB
               TXTEMI V_HORIZ_TAB  INTO P_LINEA.

      TRANSFER P_LINEA TO PATH_FILE LENGTH 2500.
    ENDIF.
  ENDLOOP.

  CLOSE DATASET PATH_FILE.



ENDFORM.                    " FILE_RES
*&---------------------------------------------------------------------*
*&      Form  TITULOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TITULOS USING PATH_FILE.
  DATA: TXT1(10),TXT2(10),TXT3(10) ,TXT4(10) ,TXT5(20) ,TXT6(20) ,TXT7(20) ,TXT8(10).
  DATA: TXTVAL(15),TXTFECD(20),TXTACR(30) ,TXTEMI(20), TXTBUDAT(20).
  DATA: P_LINEA(500) TYPE C.
  DATA:  V_HORIZ_TAB(1) TYPE C.

*      TAB
  V_HORIZ_TAB = CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB.

  CLEAR : TXT1,TXT2,TXT3,TXT4,TXT5,TXT6,TXT7,TXT8.
  CLEAR : TXTVAL,TXTFECD,TXTACR,TXTEMI.

  TXT1 = 'ID'.
  TXT2 = 'SOCIEDAD'.
  TXT3 = 'BANCO'.
  TXT4 = 'CUENTA'.
  TXT5 = 'DOC. ORIGINAL'.
  TXT6 = 'NUM. DOCUMENTO'.
  TXT7 = 'CHEQUE'.
  TXTVAL = 'MONTO'.
  TXTFECD = 'FECHA DOC'.
  TXTACR  = 'ACREEDOR'.
  TXTEMI  = 'TIPO EMISION'.
  TXTBUDAT = 'FECHA DOCUMENTO'.

  IF  TXT5 IS INITIAL.
    CONCATENATE '-' TXT5 INTO TXT5.
  ENDIF.

  IF  TXT7 IS INITIAL.
    CONCATENATE '-' TXT7 INTO TXT7.
  ENDIF.

  SHIFT TXT1 RIGHT DELETING TRAILING SPACE.
  SHIFT TXT2 RIGHT DELETING TRAILING SPACE.
  SHIFT TXT3 RIGHT DELETING TRAILING SPACE.
  SHIFT TXT4 RIGHT DELETING TRAILING SPACE.
  SHIFT TXT5 RIGHT DELETING TRAILING SPACE.
  SHIFT TXT6 RIGHT DELETING TRAILING SPACE.
  SHIFT TXTFECD RIGHT DELETING TRAILING SPACE.
  SHIFT TXT7 RIGHT DELETING TRAILING SPACE.
  SHIFT TXTVAL RIGHT DELETING TRAILING SPACE.
  SHIFT TXTBUDAT RIGHT DELETING TRAILING SPACE.
  SHIFT TXTACR  RIGHT DELETING TRAILING SPACE.
  SHIFT TXTEMI  RIGHT DELETING TRAILING SPACE.

  CONCATENATE TXT1 V_HORIZ_TAB
                TXT2 V_HORIZ_TAB
                TXT3 V_HORIZ_TAB
                TXT4 V_HORIZ_TAB
                TXT5 V_HORIZ_TAB
                TXTFECD V_HORIZ_TAB
                TXT6 V_HORIZ_TAB
                TXTBUDAT V_HORIZ_TAB
                TXT7 V_HORIZ_TAB    "CHEQUE
                TXTVAL V_HORIZ_TAB
                TXTACR V_HORIZ_TAB
                TXTEMI V_HORIZ_TAB  INTO P_LINEA.

  TRANSFER P_LINEA TO PATH_FILE LENGTH 2500.

  TRANSFER '__________________________________________________________________________________________________________________________________________________________________________________________________________________________' TO PATH_FILE.

ENDFORM.                    " TITULOS
*&---------------------------------------------------------------------*
*&      Form  PRESCRIBIR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PSEL  text
*      -->P_T_OK  text
*      -->P_S_BUKRS_LOW  text
*      -->P_S_HBKID_LOW  text
*      -->P_S_HKTID_LOW  text
*      -->P_S_PBUDAT_LOW  text
*----------------------------------------------------------------------*
FORM PRESCRIBIR  TABLES   P_PSEL STRUCTURE PSEL
                            "Insertar nombre correcto para <...>
                          P_T_OK STRUCTURE T_OK
                 USING    BUKRS
                          HBKID
                          HKTID
                          PBUDAT.

  DATA: T_PAYR LIKE T012K  OCCURS 0 WITH HEADER LINE.
  DATA: T_BSIS LIKE BSIS OCCURS 0 WITH HEADER LINE.
  DATA: T_BSAS LIKE BSAS  OCCURS 0 WITH HEADER LINE.
  DATA: G_HKOD LIKE BSEG-HKONT. "GUARDA CUENTA DE DESTINO"
  DATA: G_SGTXT  LIKE BSEG-SGTXT. "ALMACENAMOS EL TEXTO PARA LA POSICION.
  DATA: G_CHECAUX LIKE T_OK-CHECT.
  DATA: P_DIAS TYPE ZMOT_PRESCRIP-DIAS.

  REFRESH T_CTA.

  RANGES: P_BUKRS FOR PAYR-ZBUKR.


  SELECT * INTO CORRESPONDING FIELDS OF TABLE T_PAYR
      FROM T012K
       WHERE BUKRS EQ BUKRS
         AND HBKID EQ HBKID
         AND HKTID EQ HKTID.

  DATA: VNUN TYPE N,
        VNUN2(9) TYPE C.

  LOOP AT T_PAYR.
    REFRESH T_CTA.
    VNUN = 5.
    DO 2 TIMES.
      ADD 1 TO VNUN.
      VNUN2 = VNUN.
      CONCATENATE T_PAYR-HKONT+0(9) VNUN2 INTO T_CTA-LOW.
      T_CTA-SIGN = 'I'.
      T_CTA-OPTION = 'EQ'.
      APPEND T_CTA.
    ENDDO.
  ENDLOOP.

*ReSQ: No Need Of Change Internal Table T_CTA Already Sorted
  DELETE ADJACENT DUPLICATES FROM T_CTA.

*    ASIGNA VALOR A G_HKOD ******************************
*   CONCATENATE T_PAYR-HKONT+0(9) '7' INTO G_HKOD.
*   SE DEBE TRAER CUENTA DE TABLA ZCTA_PRESCRIP.

  SELECT SINGLE CUENTA_P
    FROM ZCTA_PRESCRIP
    INTO G_HKOD
   WHERE T_CUENTA EQ 4.

*********************************************************************


  SELECT  * APPENDING  CORRESPONDING FIELDS OF TABLE  T_BSIS
    FROM BSIS
     WHERE BUKRS = BUKRS
       AND HKONT IN T_CTA.

  CONCATENATE 'Prescribir'  ' - '  SY-DATUM INTO G_SGTXT.
  G_LITTLE = 'Prescribir'.

  LOOP AT  T_BSIS.
*    *********************************************************

* Si   Existe registro, por lo tanto cheque sin compensar, verificar si han pasado los 60 días para caducar
    DATA: DATEDIFF  TYPE  P,
    TIMEDIFF  TYPE  P,
    EARLIEST  TYPE  C.
    DATA: P_KOUHR1 TYPE KOUHR,
          P_KOUHR2 TYPE KOUHR.
    P_KOUHR1 = SY-UZEIT.
    P_KOUHR2 =  P_KOUHR1.
    CALL FUNCTION 'SD_DATETIME_DIFFERENCE'
      EXPORTING
       DATE1            = T_BSIS-BLDAT
*        DATE1            = T_BSIS-VALUT
        TIME1            = P_KOUHR1
        DATE2            = BKPF-BUDAT
        TIME2            = P_KOUHR2
      IMPORTING
        DATEDIFF         = DATEDIFF
        TIMEDIFF         = TIMEDIFF
        EARLIEST         = EARLIEST
      EXCEPTIONS
        INVALID_DATETIME = 1
        OTHERS           = 2.
    IF SY-SUBRC EQ 0.
      DATA: P_VOIDR TYPE PAYR-VOIDR.
      CLEAR: G_CHECAUX,P_VOIDR.
      DATA: P_VBLNR TYPE PAYR-VBLNR.
      CLEAR P_VBLNR.

*      SELECT SINGLE VBLNR VOIDR
*      FROM PAYR
*      INTO (P_VBLNR , P_VOIDR)
*      WHERE ICHEC EQ ''
*        AND ZBUKR EQ BUKRS
*        AND HBKID EQ HBKID
*        AND HKTID EQ HKTID
*        AND CHECT EQ T_BSIS-ZUONR.

      SELECT *
        FROM PAYR
        INTO CORRESPONDING FIELDS OF TABLE IT_PAYR
        WHERE ICHEC EQ ''
          AND ZBUKR EQ BUKRS
          AND HBKID EQ HBKID
          AND HKTID EQ HKTID
          AND CHECT EQ T_BSIS-ZUONR.

      IF SY-SUBRC EQ 0.
        READ TABLE IT_PAYR INDEX 1.
      ENDIF.

***************************************************************************
      DATA:  MOT_EMIS TYPE BSEG-ZZMOT_EMIS.
      PERFORM  ZMOT_EMIS USING BUKRS  T_BSIS-BELNR T_BSIS-GJAHR
                      CHANGING P_ZMOT_EMIS.
**************************************************************************

*     SE SACARA LA CANTIDAD DE DIAS A CONSULTAR POR MOTIVO DE PRESCRIPCION
*     EN TABLA  : ZMOT_PRESCRIP.
      IF T_BSIS-HKONT+9(1) EQ 6 OR T_BSIS-HKONT+9(1) EQ 7.
        CLEAR P_DIAS.
        SELECT SINGLE DIAS
          FROM ZMOT_PRESCRIP
          INTO P_DIAS
         WHERE ZZMOT_EMIS EQ P_ZMOT_EMIS.

        IF SY-SUBRC NE 0.
          P_DIAS = 9999.
        ENDIF.

      ENDIF.

      IF SY-SUBRC EQ 0.
      ENDIF.

      G_CHECAUX =  T_BSIS-ZUONR.
      IF EARLIEST EQ 2.
        DATEDIFF = DATEDIFF * -1.
        DES_CTA = G_DESF.
      ENDIF.
******** Validacion de cuenta **************************
      PERFORM VALID_CTA  USING T_BSIS-HKONT+9(1)  SAVE_CODE
                      CHANGING G_VALID_CTA.

      PERFORM DESC_CTA USING T_BSIS-HKONT+9(1) CHANGING DES_CTA.
      IF IT_PAYR-VOIDR GT 0. " causa de anulacion
        DES_CTA = 'CHEQUE ANULADO'.
        G_VALID_CTA = 1.
      ENDIF.

* Si diferencia de fechas es menos a 60 doias no se podra caducar.
      IF DATEDIFF >= P_DIAS.
        CLEAR:   T_OK.
        MOVE: T_BSIS-BELNR TO T_OK-BELNR.
        IF G_VALID_CTA EQ 1.
          MOVE '@0A@'    TO T_OK-STATUS. " ICONO MAL
        ELSE.
          MOVE '@08@'    TO T_OK-STATUS. " ICONO BIEN
        ENDIF.

        MOVE: T_BSIS-BUKRS TO T_OK-BUKRS,
        T_BSIS-BUZEI  TO T_OK-BUZEI,
        T_BSIS-GJAHR  TO T_OK-GJAHR,
        T_BSIS-HKONT  TO T_OK-HKONT,
        T_BSIS-WRBTR  TO T_OK-WRBTR,
        G_HKOD        TO T_OK-HKONTD,
         'X'          TO T_OK-CHEK1,
        G_SGTXT       TO T_OK-SGTXT,
        DATEDIFF      TO T_OK-DATEV,
        G_CHECAUX     TO T_OK-CHECT,
        DES_CTA       TO T_OK-ESTADO,
        IT_PAYR-VBLNR TO T_OK-VBLNR,
        G_LITTLE      TO T_OK-LITTLE,
        T_BSIS-BLDAT  TO T_OK-BLDAT,
        IT_PAYR-ZALDT TO T_OK-ZALDT,
        IT_PAYR-ZNME1 TO T_OK-ZNME1,
        P_ZMOT_EMIS   TO T_OK-ZMOTE.

        MOVE : HBKID  TO T_OK-HBKID,
               HKTID  TO T_OK-HKTID,
               S_PBUDAT-LOW  TO T_OK-PBUDAT.

      ELSE.
        CLEAR:   T_OK.
        MOVE: T_BSIS-BELNR TO T_OK-BELNR,
        '@0A@'    TO T_OK-STATUS,
        T_BSIS-BUKRS TO T_OK-BUKRS,
        T_BSIS-BUZEI TO T_OK-BUZEI,
        T_BSIS-GJAHR TO T_OK-GJAHR,
        T_BSIS-HKONT TO T_OK-HKONT,
        T_BSIS-WRBTR TO T_OK-WRBTR,
         'X'         TO T_OK-CHEK1,
        G_HKOD       TO T_OK-HKONTD,
        G_SGTXT      TO T_OK-SGTXT,
        DATEDIFF     TO T_OK-DATEV,
        G_CHECAUX    TO T_OK-CHECT,
        DES_CTA      TO T_OK-ESTADO,
        IT_PAYR-VBLNR  TO T_OK-VBLNR,
        IT_PAYR-ZALDT  TO T_OK-ZALDT,
        IT_PAYR-ZNME1  TO T_OK-ZNME1,
        P_ZMOT_EMIS    TO T_OK-ZMOTE..

        MOVE : HBKID  TO T_OK-HBKID,
               HKTID  TO T_OK-HKTID,
        S_PBUDAT-LOW  TO T_OK-PBUDAT,
        T_BSIS-BLDAT  TO T_OK-BLDAT.
      ENDIF.
      APPEND T_OK.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " PRESCRIBIR
*&---------------------------------------------------------------------*
*&      Form  ZZMOT_EMIS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BSIS_GJAHR  text
*      -->P_P_VBLNR  text
*      -->P_BUKRS  text
*      <--P_MOTPRE  text
*----------------------------------------------------------------------*
FORM ZZMOT_EMISI  USING    GJAHR
                          P_VBLNR
                          BUKRS
                 CHANGING MOT_EMIS.


  DATA:    BEGIN OF S_POSTAB OCCURS 50,
               XAUTH(1)      TYPE C,                 " Berechtigung?
               XHELL(1)      TYPE C.                 " Hell anzeigen?
          INCLUDE STRUCTURE RFPOS.              " Listanzeigen-Struktur
  INCLUDE RFEPOSC9.                     " Kunden-Sonderfelder
  DATA:      XBKPF(1)      TYPE C,                 " BKPF nachgelesen?
             XBSEG(1)      TYPE C,                 " BSEG nachgelesen?
             XBSEC(1)      TYPE C,                 " BSEC nachgelesen?
             XBSED(1)      TYPE C,                 " BSED nachgelesen?
             XPAYR(1)      TYPE C,                 " PAYR nachgelesen?
             XBSEGC(1)     TYPE C,                 " BSEGC nachgelesen?
             XBSBV(1)      TYPE C,                 " BSBV nachgelesen?
             XMOD(1)       TYPE C,                 " POSTAB modifiziert?
           END OF S_POSTAB.



  DATA:
  I_GJAHR LIKE PAYR-GJAHR,
  I_VBLNR LIKE PAYR-VBLNR,
  I_XBUKR LIKE PAYR-XBUKR,
  I_ZBUKR LIKE PAYR-ZBUKR.

  I_XBUKR = 'X'.
  I_ZBUKR = BUKRS.

  CALL FUNCTION 'GET_INVOICE_DOCUMENT_NUMBERS'
    EXPORTING
      I_GJAHR   = GJAHR
      I_VBLNR   = P_VBLNR
      I_XBUKR   = I_XBUKR
      I_ZBUKR   = I_ZBUKR
    TABLES
      T_INVOICE = S_POSTAB
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.
  IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  CLEAR:MOT_EMIS.
  DATA: P_BELNR LIKE BKPF-BELNR.
  DATA: P_BUZEI LIKE BSEG-BUZEI.
  DATA: P_GJAHR LIKE BSEG-GJAHR.
  LOOP AT S_POSTAB WHERE BLART EQ 'SA' AND XHELL EQ 'X'.
    MOVE S_POSTAB-AUGBL TO P_BELNR.
    MOVE S_POSTAB-BUZEI TO P_BUZEI.
    MOVE S_POSTAB-GJAHR TO P_GJAHR.
  ENDLOOP.

  SELECT SINGLE ZZMOT_EMIS INTO MOT_EMIS
    FROM BSEG
   WHERE BUKRS EQ BUKRS
     AND BELNR EQ P_BELNR
     AND GJAHR EQ GJAHR
     AND BUZEI EQ 1
     AND KOART EQ 'S'.



ENDFORM.                    " ZZMOT_EMIS
*&---------------------------------------------------------------------*
*&      Form  ZMOT_EMIS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_OK_BUKRS  text
*      -->P_T_BSIS_BELNR  text
*      -->P_T_BSIS_GJAHR  text
*      <--P_P_ZMOT_EMIS  text
*      <--P_MOVE  text
*      <--P_T_BSIS_BELNR  text
*      <--P_TO  text
*      <--P_T_OK_BELNR  text
*----------------------------------------------------------------------*
FORM ZMOT_EMIS  USING    P_BUKRS
                         Z_BELNR
                         P_GJAHR
                CHANGING P_EMIS.


  DATA:    BEGIN OF S_POSTAB OCCURS 50,
            XAUTH(1)      TYPE C,                 " Berechtigung?
            XHELL(1)      TYPE C.                 " Hell anzeigen?
          INCLUDE STRUCTURE RFPOS.              " Listanzeigen-Struktur
  INCLUDE RFEPOSC9.                     " Kunden-Sonderfelder
  DATA:      XBKPF(1)      TYPE C,                 " BKPF nachgelesen?
             XBSEG(1)      TYPE C,                 " BSEG nachgelesen?
             XBSEC(1)      TYPE C,                 " BSEC nachgelesen?
             XBSED(1)      TYPE C,                 " BSED nachgelesen?
             XPAYR(1)      TYPE C,                 " PAYR nachgelesen?
             XBSEGC(1)     TYPE C,                 " BSEGC nachgelesen?
             XBSBV(1)      TYPE C,                 " BSBV nachgelesen?
             XMOD(1)       TYPE C,                 " POSTAB modifiziert?
           END OF S_POSTAB.


  DATA:
  I_GJAHR LIKE PAYR-GJAHR,
  I_VBLNR LIKE PAYR-VBLNR,
  I_XBUKR LIKE PAYR-XBUKR,
  I_ZBUKR LIKE PAYR-ZBUKR.

  I_XBUKR = 'X'.
  I_ZBUKR = P_BUKRS.

  CLEAR P_EMIS.

*ResQ Comment:Correction not required as Select Single is used 23/12/2019 EY_DES02 ECDK917080 *
  SELECT SINGLE ZZMOT_EMIS INTO P_EMIS
    FROM BSEG
   WHERE BUKRS EQ P_BUKRS
     AND BELNR EQ Z_BELNR
     AND ( BUZEI EQ 1 OR
              BUZEI EQ 2 )
     AND GJAHR EQ P_GJAHR
     AND ZZMOT_EMIS NE ' '.

  IF SY-SUBRC NE 0.

    CALL FUNCTION 'GET_INVOICE_DOCUMENT_NUMBERS'
      EXPORTING
        I_GJAHR   = P_GJAHR
        I_VBLNR   = Z_BELNR
        I_XBUKR   = I_XBUKR
        I_ZBUKR   = I_ZBUKR
      TABLES
        T_INVOICE = S_POSTAB
      EXCEPTIONS
        NOT_FOUND = 1
        OTHERS    = 2.
    IF SY-SUBRC <> 0.
*       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    DATA: R_BELNR LIKE BKPF-BELNR.
    DATA: P_BUZEI LIKE BSEG-BUZEI.

    LOOP AT S_POSTAB.
      MOVE S_POSTAB-BELNR TO R_BELNR.
      MOVE S_POSTAB-BUZEI TO P_BUZEI.
    ENDLOOP.

*ResQ Comment:Correction not required as Select Single is used 23/12/2019 EY_DES02 ECDK917080 *
    SELECT SINGLE ZZMOT_EMIS INTO P_EMIS
   FROM BSEG
  WHERE BUKRS EQ P_BUKRS
    AND BELNR EQ R_BELNR
    AND ( BUZEI EQ 1 OR
             BUZEI EQ 2 )
    AND GJAHR EQ P_GJAHR
    AND ZZMOT_EMIS NE ' '.


    IF SY-SUBRC NE 0.
      P_EMIS = '--'.
    ENDIF.
  ENDIF.


ENDFORM.                    " ZMOT_EMIS

FORM ZRESERVA.
*  DATA: P_CODIDU  LIKE ZREVERSACHEQUE-IDUSUARIO.

  DATA : P_HORAP TYPE SY-UZEIT.
  DATA : IT_BSEG LIKE BSEG OCCURS 0 WITH HEADER LINE.
  DATA : IT_BSAS LIKE BSAS OCCURS 0 WITH HEADER LINE.
*  CONCATENATE SY-UNAME '_' BUKRS '_' HBKID '_'  SY-DATUM  '_' SY-UZEIT INTO P_CODIDU.

*  IF P_I_TABLSUBM IS  INITIAL.
*    EXIT.
*  ENDIF.

  MOVE SY-UZEIT TO P_HORAP.

  CLEAR IT_REVERSA.
  REFRESH IT_REVERSA.

  LOOP AT T_OK.
    IF T_OK-STATUS EQ '@08@' AND T_OK-CHEK1 EQ 'X'.
*     SE RESCATA ULTIMO DOCUMENTO REALIZADO
*      SELECT * INTO TABLE IT_BSEG
*        FROM BSEG
*       WHERE BUKRS EQ T_OK-BUKRS
*         AND BELNR EQ T_OK-BELNR
*         AND GJAHR EQ T_OK-GJAHR
*         AND BUZEI EQ T_OK-BUZEI.
*
*        IF SY-SUBRC EQ 0.
*            LOOP AT IT_BSEG.
*              MOVE  IT_BSEG-AUGBL TO  IT_REVERSA-BELNRACT.
*            ENDLOOP.
*        ENDIF.

       SELECT * INTO TABLE IT_BSAS
        FROM BSAS
        WHERE BUKRS EQ T_OK-BUKRS
          AND HKONT EQ T_OK-HKONT
*    AND ZUONR EQ T_OK-CHECT
          AND GJAHR EQ T_OK-GJAHR
          AND BELNR EQ T_OK-BELNR.

        IF SY-SUBRC EQ 0.
            LOOP AT IT_BSAS.
              MOVE  IT_BSAS-AUGBL TO  IT_REVERSA-BELNRACT.
            ENDLOOP.
        ENDIF.


      MOVE :
        SY-UNAME    TO IT_REVERSA-CODUSUARIO,
        T_OK-BUKRS  TO IT_REVERSA-BUKRS,
        T_OK-HBKID  TO IT_REVERSA-HBKID,
        T_OK-HKTID  TO IT_REVERSA-HKTID,
        BKPF-BUDAT  TO IT_REVERSA-BUDAT,
        'N'         TO IT_REVERSA-ESTREVER,
        SY-DATUM    TO IT_REVERSA-FECPROCESO,
        P_HORAP     TO IT_REVERSA-HORAPROCESO,
        T_OK-BELNR  TO IT_REVERSA-BELNR,
        T_OK-BUZEI  TO IT_REVERSA-BUZEI,
        T_OK-GJAHR  TO IT_REVERSA-GJAHR,
        T_OK-HKONT  TO IT_REVERSA-HKONT,
        T_OK-WRBTR  TO IT_REVERSA-WRBTR,
        T_OK-WAERS  TO IT_REVERSA-WAERS,
        T_OK-CHECT  TO IT_REVERSA-CHECT,
        T_OK-HKONTD TO IT_REVERSA-HKONTD,
        T_OK-ESTADO TO IT_REVERSA-ESTADO,
        T_OK-VBLNR  TO IT_REVERSA-VBLNR,
        T_OK-BLDAT  TO IT_REVERSA-BLDAT,
        T_OK-LIFNR  TO IT_REVERSA-LIFNR,
        T_OK-ZALDT  TO IT_REVERSA-ZALDT,
        T_OK-ZMOTE  TO IT_REVERSA-ZMOTE.

      APPEND IT_REVERSA.
    ENDIF.

  ENDLOOP.

  IF IT_REVERSA[] IS NOT INITIAL.
*   SE BUSCAN LOS CHEQUES PARA PINTAR LOS CHEQUES PROCESADOS ENTERIORMENTE
*    PERFORM MARCA_CHEQUES_ANT.
*   SE INSERTA EN ZREVERSACHEQUE *****************************************
    LOOP AT IT_REVERSA.
      INSERT INTO ZREVERSACHEQUE
       VALUES IT_REVERSA.
*      IF SY-SUBRC eq 0.
**        MESSAGE 'Problemas al Guardar registros en Tabla : ZREVERSACHEQUE' TYPE 'W'.
*
*      ENDIF.
      COMMIT WORK AND WAIT.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " ZRESERVACHEQUE
