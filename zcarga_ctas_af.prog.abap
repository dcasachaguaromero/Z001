*&---------------------------------------------------------------------*
*& Report  ZCARGA_CTAS_AF
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZCARGA_CTAS_AF.

TABLES : T095, T095B , databrowse.

DATA    BEGIN OF XTABLA1 OCCURS 0.
        INCLUDE STRUCTURE T095.
DATA:   END OF XTABLA1.

DATA    BEGIN OF XTABLA2 OCCURS 0.
        INCLUDE STRUCTURE T095B.
DATA:   END OF XTABLA2.


DATA: W_INDEX LIKE SY-INDEX.

SELECTION-SCREEN BEGIN OF BLOCK bl0 WITH FRAME TITLE text-000.
  parameters :  P_FILE LIKE RLGRAP-FILENAME default 'C:/Banmedica/'.
SELECTION-SCREEN END OF BLOCK bl0.

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
  parameters:  W_T095  type c radiobutton group 12 default 'X' ,
               W_T095B type c RADIOBUTTON group 12 .
SELECTION-SCREEN END OF BLOCK bl1.
*
SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-002.
  PARAMETERS : P_OPTION AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK bl2.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      DEF_FILENAME     = ''
      DEF_PATH         = 'C:\Banmedica\'
      MASK             = ',*.*,*.*.'
      MODE             = 'O'
      TITLE            = 'Abrir Archivo desde PC'
    IMPORTING
      FILENAME         = P_FILE
    EXCEPTIONS
      INV_WINSYS       = 1
      NO_BATCH         = 2
      SELECTION_CANCEL = 3
      SELECTION_ERROR  = 4
      OTHERS           = 5.

start-of-selection.

  IF NOT W_T095 IS INITIAL.

    perform leer_planilla tables XTABLA1 using p_file 'DAT'.

    LOOP AT XTABLA1.
      W_INDEX = SY-TABIX.
      MOVE-CORRESPONDING XTABLA1 TO T095.
      MOVE SYST-MANDT TO T095-MANDT.
      CHECK P_OPTION IS INITIAL.
      MODIFY T095.
      IF SY-SUBRC NE 0.
        WRITE:/ 'ERROR GRABANDO REGISTRO' , W_INDEX , 'ERROR' , SY-SUBRC.
      ENDIF.
      COMMIT WORK.
    ENDLOOP.

  ELSE.

    perform leer_planilla tables XTABLA2 using p_file 'DAT'.

    LOOP AT XTABLA2.
      W_INDEX = SY-TABIX.
      MOVE-CORRESPONDING XTABLA2 TO T095B.
      MOVE SYST-MANDT TO T095B-MANDT.
      CHECK P_OPTION IS INITIAL.
      MODIFY T095B.
      IF SY-SUBRC NE 0.
        WRITE:/ 'ERROR GRABANDO REGISTRO' , W_INDEX , 'ERROR' , SY-SUBRC.
      ENDIF.
      COMMIT WORK.
    ENDLOOP.


  ENDIF.

  IF P_OPTION IS INITIAL.
    WRITE :/ 'MODO REAL'.
    WRITE :/ 'PROCESO ACTUALIZACIÓN TERMINADO'.
  ELSE.
    WRITE :/ 'PROCESO TEST TERMINADO'.
  ENDIF.


*&---------------------------------------------------------------------*
*&      Form  leer_planilla
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM LEER_PLANILLA TABLES NOM_TAB
                   USING  NOM_ARCH NOM_TIP.
* VARIABLES leer planilla
  DATA : FR LIKE RLGRAP-FILENAME,
         TIPO  LIKE RLGRAP-FILETYPE.
* Asignacion de variables
  FR   = NOM_ARCH.
  TIPO = NOM_TIP(3).

  CALL FUNCTION 'WS_UPLOAD'
    EXPORTING
      FILENAME = FR
      FILETYPE = TIPO
    TABLES
      DATA_TAB = NOM_TAB
    EXCEPTIONS
      OTHERS   = 9.
*
  IF SY-SUBRC NE 0.
    WRITE:/ 'SE HA PRESENTADO ERROR AL LEER ARCHIVO', p_file.
    STOP.
  ENDIF.
*
ENDFORM.                    " leer_planilla
