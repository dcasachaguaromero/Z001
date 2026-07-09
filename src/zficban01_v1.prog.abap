*&---------------------------------------------------------------------*
*& Report  ZFICBAN01_V1
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT  ZFICBAN01_V1.

tables: FEBKO,t012t,ZOPEBCO.
DATA:   P_TIPO TYPE P.
DATA: ds_name     LIKE filename-fileextern.
DATA: ds_name_cab     LIKE filename-fileextern.
DATA: ds_name_det     LIKE filename-fileextern.
DATA: BEGIN OF tab_wa OCCURS 100,
        wa(1700),
      END OF tab_wa.

TYPES:
        W_TR001(50)    TYPE C,
        line(1000) TYPE C.

INCLUDE ZFICBAN01_PARAM.
*INCLUDE: ZFITR001_PARAM,
INCLUDE ZFICBAN01_VAR.
*         ZFITR001_VAR,
INCLUDE ZFICBAN01_CLASS_V1.
*INCLUDE ZFICBAN01_CLASS.
*         ZFITR001_CLASS.

DATA: ITO_C       TYPE STANDARD TABLE OF LINE ,
      ITO_D       TYPE STANDARD TABLE OF LINE ,
      IT_C        TYPE STANDARD TABLE OF LINE ,
      IT_D        TYPE STANDARD TABLE OF LINE ,
      IT_DATA     TYPE STANDARD TABLE OF LINE.
data: wa_it_c(2000).
data: wa_it_d(2000).
data: wa_file TYPE string.


*****************************************************************************************
INITIALIZATION.

  CLEAR W_BNCO.
  DATA OBJ_MTCASH TYPE REF TO MULTICASH.

  CREATE OBJECT OBJ_MTCASH.
*&---------------------------------------------------------------------*
*& AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.

  CALL METHOD OBJ_MTCASH->M_FIND_FILE
    IMPORTING
      P_FILE1 = P_FILE.

*AT SELECTION-SCREEN OUTPUT.

AT SELECTION-SCREEN ON lds_name.
  IF kz_app = 'X'.
* Physikalischen Dateinamen ermitteln --
    CALL FUNCTION 'FILE_GET_NAME'
      EXPORTING
        logical_filename = lds_name
      IMPORTING
        file_name        = ds_name
      EXCEPTIONS
        file_not_found   = 01.
    IF sy-subrc NE 0.
      MESSAGE e016(mg) WITH lds_name.
    ENDIF.
  ENDIF.

*****************************************************************************************
START-OF-SELECTION.
    CALL METHOD OBJ_MTCASH->M_VALIDA_BCO
      importing
     WI_BNCO = W_BNCO.

  wa_file = p_file.
  TRANSLATE wa_file TO UPPER CASE.
  IF wa_file CS '.XLS' OR WA_FILE CS '.HTM'.
    PERFORM XLS_TO_TXT TABLES IT_DATA
      USING P_FILE.
    CALL METHOD OBJ_MTCASH->M_SET_DATA
      EXPORTING
        I_ITDATA = IT_DATA.
  ELSE.
    CALL METHOD OBJ_MTCASH->M_GET_DATA
      EXPORTING
        WI_FILE = P_FILE
        WI_TIPO = P_TIPO.
  ENDIF.



   CONCATENATE ds_name p_BUKRS '_' W_BNCO '_CAB' into ds_name_cab.
   CONCATENATE ds_name P_BUKRS '_' W_BNCO '_DET' into ds_name_det.

CASE W_BNCO.

  WHEN W_BCI.   "comentario
    CALL METHOD OBJ_MTCASH->M_PROCESA_BCI
     EXPORTING
       WI_BNCO = W_BNCO
     IMPORTING
        ITO_C   = IT_C
        ITO_D   = IT_D.
* Banco Santander
  WHEN  W_STNDR.
    CALL METHOD OBJ_MTCASH->M_PROCESA_STNDR
     EXPORTING
       WI_BNCO = W_BNCO
     IMPORTING
        ITO_C   = IT_C
        ITO_D   = IT_D.

    WHEN W_CHILE.
      CALL METHOD OBJ_MTCASH->M_PROCESA_CHILE
        EXPORTING
          WI_BNCO = W_BNCO
        IMPORTING
          ITO_C = IT_C
          ITO_D = IT_D
          .
    WHEN W_BBVA.
      IF wa_file CS '.XLS'.
        CALL METHOD OBJ_MTCASH->M_PROCESA_BBVA_XLS
        EXPORTING
            WI_BNCO = W_BNCO
          IMPORTING
            ITO_C = IT_C
            ITO_D = IT_D
            .
      ELSE.
        CALL METHOD OBJ_MTCASH->M_PROCESA_BBVA
        EXPORTING
            WI_BNCO = W_BNCO
          IMPORTING
            ITO_C = IT_C
            ITO_D = IT_D
            .
      ENDIF.

    WHEN W_CORP.
      IF wa_file CS '.XLS'.
        CALL METHOD OBJ_MTCASH->M_GET_DATA
        EXPORTING
          WI_FILE = P_FILE
          WI_TIPO = P_TIPO.
        CALL METHOD OBJ_MTCASH->M_PROCESA_CORP_XLS
        EXPORTING
            WI_BNCO = W_BNCO
          IMPORTING
            ITO_C = IT_C
            ITO_D = IT_D
            .
      ELSE.
        CALL METHOD OBJ_MTCASH->M_PROCESA_CORP_XLS
        EXPORTING
            WI_BNCO = W_BNCO
          IMPORTING
            ITO_C = IT_C
            ITO_D = IT_D
            .
      ENDIF.

    WHEN W_SECU.
      IF wa_file CS '.XLS'.
        CALL METHOD OBJ_MTCASH->M_PROCESA_ALL_XLS
          EXPORTING
            WI_BNCO = W_BNCO
            IMPORTING
              ITO_C = IT_C
              ITO_D = IT_D
              .
      ELSE.
        CALL METHOD OBJ_MTCASH->M_PROCESA_SECURITY
          EXPORTING
            WI_BNCO = W_BNCO
            IMPORTING
              ITO_C = IT_C
              ITO_D = IT_D
              .
      ENDIF.

    WHEN W_SCTIA.
      CALL METHOD OBJ_MTCASH->M_PROCESA_SCOTIA
      EXPORTING
        WI_BNCO = W_BNCO
        IMPORTING
          ITO_C = IT_C
          ITO_D = IT_D
          .
    WHEN W_ESTADO.
      CALL METHOD OBJ_MTCASH->M_PROCESA_ESTADO
      EXPORTING
        WI_BNCO = W_BNCO
        IMPORTING
          ITO_C = IT_C
          ITO_D = IT_D
          .
    WHEN W_BICE.
      if wa_file cs '.XLS'.
        CALL METHOD OBJ_MTCASH->M_PROCESA_BICE
        EXPORTING
          WI_BNCO = W_BNCO
          IMPORTING
            ITO_C = IT_C
            ITO_D = IT_D
            .
      ELSEIF wa_file cs '.HTM'.
        CALL METHOD OBJ_MTCASH->M_PROCESA_BICE_HTM
        EXPORTING
          WI_BNCO = W_BNCO
          IMPORTING
            ITO_C = IT_C
            ITO_D = IT_D
            .
      ENDIF.

    when others.
      IF wa_file CS '.XLS'.
        CALL METHOD OBJ_MTCASH->M_PROCESA_ALL_XLS
          EXPORTING
            WI_BNCO = W_BNCO
            IMPORTING
              ITO_C = IT_C
              ITO_D = IT_D
              .
      ENDIF.

    MESSAGE  s398(00) with text-001 w_bnco text-002.
    stop.

ENDCASE.
  PERFORM VALIDATION.


  CALL METHOD OBJ_MTCASH->M_DWN_FILE
    EXPORTING
      ITI_C  = IT_C
      ITI_D  = IT_D..

perform write_to_file.
if einlesen = 'X'.
  if batch eq 'X' . " si el porces es en fondo necesita tomar los ficheros del servidor
        move ds_name_cab to AUSZFILE.
        move ds_name_det to UMSFILE.
  else.
        move p_file2 to  AUSZFILE.
        move p_file3 to  UMSFILE.
        move 'X' to      PCUPLOAD.
  endif.
SUBMIT RFEBKA00
        WITH AUSZFILE = AUSZFILE
        WITH BATCH  = batch
        WITH EINLESEN = einlesen
        WITH FORMAT = 'M'
*       WITH INTRADAY = intraday
        WITH MREGEL  = mregel
        WITH NULLUMSA = NULLUMSA
*        WITH PA_BDANZ = PA_BDANZ
*        WITH PA_BDART =  PA_BDART
*        WITH PA_DSART = PA_DSART
        WITH PA_LSEPA = PA_LSEPA
        WITH PA_MODE =  PA_MODE
        WITH PA_TEST =  PA_TEST
*        WITH PA_VERD =  PA_VERD
        WITH PA_XBDC =  PA_XBDC
        WITH PA_XBKBU = PA_XBKBU
        WITH PA_XCALL = PA_XCALL
*        WITH PA_XDISP = PA_XDISP
        WITH PCUPLOAD = PCUPLOAD
*        WITH P_BAIPRE = P_BAIPRE
        WITH P_BUPRO =  P_BUPRO
        WITH P_KOAUSZ = P_KOAUSZ
*       WITH P_PRIORD = P_PRIORD
        WITH P_STATIK = P_STATIK
*        WITH P_STOP =   P_STOP
*        WITH S_FILTER ...
*        WITH T_FILTER ...
        WITH UMSFILE = UMSFILE
        WITH VALUT_ON  = valut_on.
*        WITH WF_OKEY = WF_OKEY
*        WITH WF_WITEM = WF_WITEM
*        WITH WF_WLIST = WF_WLIST.
endif.
*---------------------------------------------------------------------*
*        FORM write_to_file
*---------------------------------------------------------------------*
*        Write order data to file                                    *
*---------------------------------------------------------------------*
FORM write_to_file.

  IF kz_app = 'X'.
    OPEN DATASET ds_name_cab FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc NE 0.
      MESSAGE e002(mg) WITH ds_name_cab.
    ENDIF.
    LOOP AT IT_C into wa_it_c.
      TRANSFER wa_it_c TO ds_name_cab.
      IF sy-subrc NE 0.
        MESSAGE e001(mg) WITH ds_name_cab.
      ENDIF.
    ENDLOOP.
    CLOSE DATASET ds_name_cab.
       OPEN DATASET ds_name_det FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc NE 0.
      MESSAGE e002(mg) WITH ds_name_det.
    ENDIF.
    LOOP AT IT_D into wa_it_d.
      TRANSFER wa_it_d TO ds_name_det.
      IF sy-subrc NE 0.
        MESSAGE e001(mg) WITH ds_name_det.
      ENDIF.
    ENDLOOP.
    CLOSE DATASET ds_name_det.
  endif.

ENDFORM.                    "WRITE_TO_FILE

INCLUDE ZFICBAN01_XLS_TO_TXTF01.
*&---------------------------------------------------------------------*
*&      Form  VALIDATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VALIDATION .
  LOOP AT it_c into wa_it_c.

  ENDLOOP.
ENDFORM.                    " VALIDACION DE SALDO INICIAL.
