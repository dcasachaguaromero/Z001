*&---------------------------------------------------------------------*
*& Report  ZFITR0001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZFITR0001.

tables: FEBKO,t012t.
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

INCLUDE: ZFITR001_PARAM,
         ZFITR001_VAR,
         ZFITR001_CLASS.

DATA: ITO_C       TYPE STANDARD TABLE OF LINE ,
      ITO_D       TYPE STANDARD TABLE OF LINE ,
      IT_C        TYPE STANDARD TABLE OF LINE ,
      IT_D        TYPE STANDARD TABLE OF LINE .
data: wa_it_c(2000).
data: wa_it_d(2000).


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



  CALL METHOD OBJ_MTCASH->M_GET_DATA
    EXPORTING
      WI_FILE = P_FILE
      WI_TIPO = P_TIPO.

CASE W_BNCO.

  WHEN W_BCI.

* Banco Santander
  WHEN  W_STNDR.
*componemos el nombre del archivo con SOciedad  Banco propio y cuenta corriente


* SELECT  single      * FROM  T012T
*        WHERE  SPRAS  = sy-langu
*        AND    BUKRS  = p_bukrs
*        AND    HBKID  = s_hbkid-low.

   concatenate ds_name W_BNCO  '_CAB' into ds_name_cab.
   concatenate ds_name W_BNCO  '_DET' into ds_name_det.


    CALL METHOD OBJ_MTCASH->M_PROCESA_STNDR
     EXPORTING
       WI_BNCO = W_BNCO
     IMPORTING
        ITO_C   = IT_C
        ITO_D   = IT_D.



  when others.

    message  s398(00) with text-001 w_bnco text-002.
    stop.

ENDCASE.
  CALL METHOD OBJ_MTCASH->M_DWN_FILE
    EXPORTING
      ITI_C  = IT_C
      ITI_D  = IT_D..

perform write_to_file.

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
