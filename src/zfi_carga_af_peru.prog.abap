*----------------------------------------------------------------------*
*                                                                      *
*  Título       : Activo Fijo - carga inicial                          *
*                                                                      *
*  Denominación : carga inicial de activo fijo                         *
*                                                                      *
*  Autor        : VisionOne Consulting S.A.                            *
*                                                                      *
*                                                                      *
*======================================================================*
REPORT ZFI_CARGA_AF
       NO STANDARD PAGE HEADING
       LINE-SIZE 500
       LINE-COUNT 53
       MESSAGE-ID ZI .
************************************************************************
CONSTANTS :  BEGIN OF C,
               TCODE(04)           TYPE C    VALUE 'AS91'    ,
               RCTYP_C(01)         TYPE C    VALUE 'A'       ,
               RCTYP_P(01)         TYPE C    VALUE 'B'       ,
               GROUP      LIKE APQI-GROUPID  VALUE 'AS91_01' ,
               TCODE1(04)           TYPE C    VALUE 'AS01'    ,
               RCTYP_C1(01)         TYPE C    VALUE 'A'       ,
               RCTYP_P1(01)         TYPE C    VALUE 'B'       ,
               GROUP1      LIKE APQI-GROUPID  VALUE 'AS01_01' ,
             END OF C.

CONSTANTS :  BEGIN OF CS,
               TCODES(04)           TYPE C    VALUE 'AS94'    ,
               RCTYP_CS(01)         TYPE C    VALUE 'A'       ,
               RCTYP_PS(01)         TYPE C    VALUE 'B'       ,
               GROUP      LIKE APQI-GROUPID  VALUE 'AS94_01' ,
               TCODE1S(04)           TYPE C    VALUE 'AS04'    ,
               RCTYP_C1S(01)         TYPE C    VALUE 'A'       ,
               RCTYP_P1S(01)         TYPE C    VALUE 'B'       ,
               GROUP1      LIKE APQI-GROUPID  VALUE 'AS04_01' ,
             END OF CS.

CONSTANTS :  BEGIN OF CN,
               TCODEN(04)           TYPE C    VALUE 'AS01'    ,
               RCTYP_CN(01)         TYPE C    VALUE 'A'       ,
               RCTYP_PN(01)         TYPE C    VALUE 'B'       ,
               GROUP      LIKE APQI-GROUPID  VALUE 'AS01_01' ,
               TCODE1N(04)           TYPE C    VALUE 'AS01'    ,
               RCTYP_C1N(01)         TYPE C    VALUE 'A'       ,
               RCTYP_P1N(01)         TYPE C    VALUE 'B'       ,
               GROUP1      LIKE APQI-GROUPID  VALUE 'AS01_01' ,
             END OF CN.

************************************************************************
TABLES : BGR00,
         BALTD,
         BALTB.


************************************************************************
* D A T A   -   D E C L A R A T I O N

DATA : BEGIN OF I_IN OCCURS 0,
*---BALTD
         ANLKL(08),      "Clase Act.Fijo      Col A
         BUKRS(04),      "Sociedad            Col B
         TXT50(50),      "Denominación        Col C
         TXA50(50),      "Denominacion 2      Col D
         ANLHTXT(50),    "Denominacion 3      Col E
         SERNR(18),      "Serie               Col F
         INVNR(25),      "Numero Inventario   Col G
         MENGE(17),      "Cantidad            Col H
         MEINS(03),      "Unidad de Medida    Col I
         XHIST(1),       "Gestion historica   Col J
         INKEN(1),       "Indicador Invent.   Col K
         AKTIV(08),      "Fecha Adquisición   Col L
         KOSTL(10),      "Centro de Costo     Col M
         KOSTLV(10),     "Ce.Co. responsa.    Col N
         STORT(10),      "Emplazamiento       Col O
         KFZKZ(15),      "Matricula           Col P
         EQANZ(10),      "Cantidad Equipos    COL Q
         XNEU_AM(1),     "Activo comprado New COL R
         LAND1(2),       "Pais                COL S
         URJHR(4),       "Ejercicio Ori.      COL T
         URWRT(16),      "Valor Iriginal      COL U

**
*  valores del Area Financiera 01.
**
         AFABE01(02),    "Area de Valorización 01   Col V
         AFASL01(04),    "Clave Amort          01   Col W
         NDJAR01(05),    "Vida Util Años       01   Col X
         ndper01(03),    "Vida Util Meses      01   Col Y
         AFABG01(08),    "Fecha Inicio Dep     01   Col Z
         NDABJ01(05),    "Vida Util Trans/Años 01   Col AA
         NDABP01(03),    "Vida Util TRans/Meses01   Col AB
         KANSW01(16),    "Valor Adqui.         01   Col AC
         KNAFA01(16),    "Amort. Acumulada     01   Col AD
**
*  Valores del Area Tributaria 05
**
**
         AFABE02(02),    "Area de Valorización 05   Col AE
         AFASL02(04),    "Clave Amort          05   Col AF
         NDJAR02(05),    "Vida Util Años       05   Col AG
         ndper02(03),    "Vida Util Meses      05   Col AH
         AFABG02(08),    "Fecha Inicio Dep     05   Col AI
         NDABJ02(05),    "Vida Util Trans/Años 05   Col AJ
         NDABP02(03),    "Vida Util TRans/Meses05   Col AK
         KANSW02(16),    "Valor Adqui.         05   Col AL
         KNAFA02(16),    "Amort. Acumulada     05   Col AM
*
*---BALTB
*         mandt  (constante)
*         bukrs  (constante)
*         anlkl  (ya existe arriba)
*         tcode  (constante)
*         rctyp  (constante)
*01
         BWASL-1(03),
         BZDAT-1(09),
         ANBTR01-1(15),
         ANBTR02-1(15),
         ANBTR03-1(15),
         ANBTR04-1(15),
         ANBTR05-1(15),
*02
         BWASL-2(03),
         BZDAT-2(09),
         ANBTR01-2(15),
         ANBTR02-2(15),
         ANBTR03-2(15),
         ANBTR04-2(15),
         ANBTR05-2(15),
       END OF I_IN.

DATA : BEGIN OF I_OUT OCCURS 0,
*---BALTD
*         mandt(03),  (constante)
         ANLKL(08),      "Clase Act.Fijo      Col A
         BUKRS(04),      "Sociedad            Col B
         BWCNT(04),
         TXT50(50),      "Denominación        Col C
         TXA50(50),      "Denominacion 2      Col D
         ANLHTXT(50),    "Denominacion 3      Col E
         SERNR(18),      "Serie               Col F
         INVNR(25),      "Numero Inventario   Col G
         MENGE(17),      "Cantidad            Col H
         ANLN1(16),
         ANLN2(04),
         MEINS(03),      "Unidad de Medida    Col I
         XHIST(1),       "Gestion historica   Col J
         INKEN(1),       "Indicador Invent.   Col K
         AKTIV(08),      "Fecha Adquisición   Col L
         KOSTL(10),      "Centro de Costo     Col M
         KOSTLV(10),     "Ce.Co. responsa.    Col N
         STORT(10),      "Emplazamiento       Col O
         KFZKZ(15),      "Matricula           Col P
         EQANZ(10),      "Cantidad Equipos    COL Q
         XNEU_AM(1),     "Activo comprado New COL R
         LAND1(2),       "Pais                COL S
         URJHR(4),       "Ejercicio Ori.      COL T
         URWRT(16),      "Valor Iriginal      COL U
*
         AFABE01(02),
         AFASL01(04),
         NDJAR01(03),
         NDPER01(03),
         AFABG01(08),
         NDABJ01(05),
         NDABP01(03),
         KANSW01(16),
         KAUFW01(16),
         KNAFA01(16),
         KAUFN01(16),
         AUFWB01(16),
         NAFAG01(16),
         AUFNG01(16),
*
         AFABE02(02),
         AFASL02(04),
         NDJAR02(03),
         NDPER02(03),
         AFABG02(08),
         NDABJ02(05),
         NDABP02(03),
         KANSW02(16),
         KAUFW02(16),
         KNAFA02(16),
         KAUFN02(16),
         AUFWB02(16),
         NAFAG02(16),
         AUFNG02(16),
*---BALTB
*         mandt  (constante)
*         bukrs  (constante)
*         anlkl  (ya existe arriba)
*         tcode  (constante)
*         rctyp  (constante)
         BWASL-1(03),
         BZDAT-1(09),
         ANBTR01-1(15),
         ANBTR02-1(15),
         ANBTR03-1(15),
         ANBTR04-1(15),
         ANBTR05-1(15),
*02
         BWASL-2(03),
         BZDAT-2(09),
         ANBTR01-2(15),
         ANBTR02-2(15),
         ANBTR03-2(15),
         ANBTR04-2(15),
         ANBTR05-2(15),

       END OF I_OUT.

DATA: BEGIN OF BDCDATA OCCURS 0.
        INCLUDE STRUCTURE BDCDATA.
DATA: END OF BDCDATA.

DATA : BEGIN OF VOI,
         OUT_FILE(100)                ," output file
         T_COUNT TYPE I               ," number of total input records
       END OF VOI.

DATA :  NUMLINES TYPE I.
DATA :  NUMMOV   TYPE I.

************************************************************************
PARAMETERS:  P_FNAME LIKE RLGRAP-FILENAME  OBLIGATORY,
             P_OUTNM(50),
             P_PROD AS CHECKBOX.

************************************************************************
START-OF-SELECTION.

  PERFORM OPEN_OUTPUT_FILE.

  PERFORM UPLOAD_DATA.

  PERFORM INIT_STRUCTURE USING BGR00.

  PERFORM INIT_STRUCTURE USING BALTD.  "cabecera
  PERFORM INIT_STRUCTURE USING BALTB.  "posicion


************************************************************************
*** M A I N   -   L O G I C

* convert data
  LOOP AT I_IN.
    IF ( I_IN-BUKRS = 'PE10' OR
         I_IN-BUKRS = 'PE11' OR
         I_IN-BUKRS = 'PE47'   ).
         PERFORM CONVERT_DATA.
         APPEND I_OUT.
    ENDIF.
  ENDLOOP.

* create output file
* PERFORM create_bgr00.
* WRITE / bgr00.

*  SORT i_out.

  LOOP AT I_OUT.
    PERFORM CREATE_BALTD.
    WRITE / BALTD.
    NUMMOV = 0.
    DO I_OUT-BWCNT TIMES.
      NUMMOV = NUMMOV + 1.
      PERFORM CREATE_BALTB USING NUMMOV.
      WRITE / BALTB.
    ENDDO.
  ENDLOOP.

  CLOSE DATASET VOI-OUT_FILE.

  DESCRIBE TABLE I_IN LINES NUMLINES.
  WRITE : / 'input:', NUMLINES.
  DESCRIBE TABLE I_OUT LINES NUMLINES.
  WRITE : / 'output:', NUMLINES.

************************************************************************
END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  UPLOAD_DATA
*&---------------------------------------------------------------------*
FORM UPLOAD_DATA.

  REFRESH I_IN.
  CLEAR   I_IN.

  CALL FUNCTION 'UPLOAD'
       EXPORTING
            CODEPAGE            = ' '
            FILENAME            = P_FNAME
            FILETYPE            = 'DAT'" tab delimited
*           FILETYPE            = 'ASC'
       TABLES
            DATA_TAB            = I_IN
       EXCEPTIONS
            CONVERSION_ERROR    = 1
            INVALID_TABLE_WIDTH = 2
            INVALID_TYPE        = 3
            NO_BATCH            = 4
            UNKNOWN_ERROR       = 5
            OTHERS              = 6.
*
  IF SY-SUBRC <> 0 .
    WRITE : / 'Upload of file not possible'(008) ,
            / 'Please check'(009) ,
            / 'Return-Code = '(010) ,
              SY-SUBRC        .
    STOP .
  ENDIF.


ENDFORM.                               " UPLOAD_DATA

*&---------------------------------------------------------------------*
*&      Form  CONVERT_DATA
*&---------------------------------------------------------------------*
FORM CONVERT_DATA.

  CLEAR: I_OUT.
  MOVE-CORRESPONDING  I_IN  TO  I_OUT.

  IF I_OUT-BWASL-1 = SPACE.
     I_OUT-BWCNT = 0.
  ELSE.
   IF I_OUT-BWASL-2 = SPACE.
      I_OUT-BWCNT = '1'.
   ENDIF.
  ENDIF.
*
  PERFORM CONVERT_FECHA CHANGING I_IN-AKTIV
                                 I_OUT-AKTIV.
  PERFORM CONVERT_FECHA CHANGING I_IN-AFABG01
                                 I_OUT-AFABG01.
  PERFORM CONVERT_FECHA CHANGING I_IN-AFABG02
                                 I_OUT-AFABG02.
*
*
* Area 01 Contable
  IF NOT ( I_IN-NDJAR01 IS INITIAL ).
     I_OUT-NDJAR01 = I_IN-NDJAR01.
  ELSE.
     MOVE '/' TO I_OUT-NDJAR01.
  ENDIF.

  IF NOT ( I_IN-NDPER01 IS INITIAL ).
     I_OUT-NDPER01 = I_IN-NDPER01.
  ELSE.
     MOVE '/' TO I_OUT-NDPER01.
  ENDIF.

  IF NOT ( I_IN-NDABJ01 IS INITIAL ).
     I_OUT-NDABJ01 = I_IN-NDABJ01.
  ELSE.
     MOVE '/' TO I_OUT-NDABJ01.
  ENDIF.

  IF NOT ( I_IN-NDABP01 IS INITIAL ).
     I_OUT-NDABP01 = I_IN-NDABP01.
  ELSE.
     MOVE '/' TO I_OUT-NDABP01.
  ENDIF.

* Area 02 CM de Area Financiera
  IF NOT ( I_IN-NDJAR02 IS INITIAL ).
     I_OUT-NDJAR02 = I_IN-NDJAR02.
  ELSE.
     MOVE '/' TO I_OUT-NDJAR02.
  ENDIF.

  IF NOT ( I_IN-NDPER02 IS INITIAL ).
     I_OUT-NDPER02 = I_IN-NDPER02.
  ELSE.
     MOVE '/' TO I_OUT-NDPER02.
  ENDIF.

  IF NOT ( I_IN-NDABJ02 IS INITIAL ).
     I_OUT-NDABJ02 = I_IN-NDABJ02.
  ELSE.
     MOVE '/' TO I_OUT-NDABJ02.
  ENDIF.

  IF NOT ( I_IN-NDABP02 IS INITIAL ).
     I_OUT-NDABP02 = I_IN-NDABP02.
  ELSE.
     MOVE '/' TO I_OUT-NDABP02.
  ENDIF.

*
  MOVE '/' TO I_OUT-KFZKZ.
*
  IF I_OUT-STORT = SPACE.
    MOVE '/' TO I_OUT-STORT.
  ENDIF.
*
  IF I_OUT-NAFAG01 = '0' OR I_OUT-NAFAG01 = SPACE.
    MOVE '/' TO I_OUT-NAFAG01.
  ENDIF.

  IF I_OUT-NAFAG02 = '0' OR I_OUT-NAFAG02 = SPACE.
    MOVE '/' TO I_OUT-NAFAG02.
  ENDIF.

*
  IF I_OUT-AUFWB01 = '0' OR I_OUT-AUFWB01 = SPACE.
    MOVE '/' TO I_OUT-AUFWB01.
  ENDIF.

  IF I_OUT-AUFWB02 = '0' OR I_OUT-AUFWB02 = SPACE.
    MOVE '/' TO I_OUT-AUFWB02.
  ENDIF.

*
  IF I_OUT-AUFNG01 = '0' OR I_OUT-AUFNG01 = SPACE.
    MOVE '/' TO I_OUT-AUFNG01.
  ENDIF.

  IF I_OUT-AUFNG02 = '0' OR I_OUT-AUFNG02 = SPACE.
    MOVE '/' TO I_OUT-AUFNG02.
  ENDIF.

*
  IF I_OUT-KAUFW01 = '0' OR I_OUT-KAUFW01 = SPACE.
    MOVE '/' TO I_OUT-KAUFW01.
  ENDIF.

  IF I_OUT-KAUFW02 = '0' OR I_OUT-KAUFW02 = SPACE.
    MOVE '/' TO I_OUT-KAUFW02.
  ENDIF.

*
  IF I_OUT-KNAFA01 = '0' OR I_OUT-KNAFA01 = SPACE.
    MOVE '/' TO I_OUT-KNAFA01.
  ENDIF.

  IF I_OUT-KNAFA02 = '0' OR I_OUT-KNAFA02 = SPACE.
    MOVE '/' TO I_OUT-KNAFA02.
  ENDIF.

*
  IF I_OUT-KANSW01 = '0' OR I_OUT-KANSW01 = SPACE.
    MOVE '/' TO I_OUT-KANSW01.
  ENDIF.

  IF I_OUT-KANSW02 = SPACE.
    MOVE '/' TO I_OUT-KANSW02.
  ENDIF.
*
  IF I_OUT-SERNR = SPACE.
    MOVE '/' TO I_OUT-SERNR.
  ENDIF.

  IF I_OUT-BWASL-1 = SPACE.
    MOVE '/' TO I_OUT-BWASL-1.
  ENDIF.
  IF I_OUT-BWASL-2 = SPACE.
    MOVE '/' TO I_OUT-BWASL-2.
  ENDIF.

  IF I_OUT-BZDAT-1 = SPACE.
    MOVE '/' TO I_OUT-BZDAT-1.
  ENDIF.
  IF I_OUT-BZDAT-2 = SPACE.
    MOVE '/' TO I_OUT-BZDAT-2.
  ENDIF.
*
*01
*
  IF I_OUT-ANBTR01-1 = '0' OR I_OUT-ANBTR01-1 = SPACE.
     MOVE '/' TO I_OUT-ANBTR01-1.
  ENDIF.
  IF I_OUT-ANBTR02-1 = '0' OR I_OUT-ANBTR02-1 = SPACE.
     MOVE '/' TO I_OUT-ANBTR02-1.
  ENDIF.
*
*02
*
  IF I_OUT-ANBTR01-2 = '0' OR I_OUT-ANBTR01-2 = SPACE.
     MOVE '/' TO I_OUT-ANBTR01-2.
  ENDIF.
  IF I_OUT-ANBTR02-2 = '0' OR I_OUT-ANBTR02-2 = SPACE.
     MOVE '/' TO I_OUT-ANBTR02-2.
  ENDIF.
*
*
  IF I_OUT-KAUFN01 = '0' OR I_OUT-KAUFN01 = SPACE.
     MOVE '/' TO I_OUT-KAUFN01.
  ENDIF.
  IF I_OUT-KAUFN02 = '0' OR I_OUT-KAUFN02 = SPACE.
     MOVE '/' TO I_OUT-KAUFN02.
  ENDIF.
*
ENDFORM.                               " CONVERT_DATA



*&---------------------------------------------------------------------*
*&      Form  CREATE_BGR00
*&---------------------------------------------------------------------*
FORM CREATE_BGR00.

* fill table
  MOVE '0'                   TO BGR00-STYPE.
  MOVE C-GROUP               TO BGR00-GROUP.
  MOVE SY-MANDT              TO BGR00-MANDT.
  MOVE SY-UNAME              TO BGR00-USNAM.

* transfer
  TRANSFER BGR00             TO VOI-OUT_FILE.


ENDFORM.                               " CREATE_BGR00

*&---------------------------------------------------------------------*
*&      Form  INIT_STRUCTURE
*&---------------------------------------------------------------------*
FORM INIT_STRUCTURE USING   TAB.

  FIELD-SYMBOLS <FS> .

  DO.
    ASSIGN COMPONENT SY-INDEX OF STRUCTURE TAB TO <FS> .
    IF SY-SUBRC <> 0.
      EXIT.
    ENDIF.
    <FS> = '/' .
  ENDDO .


ENDFORM.                               " INIT_STRUCTURE

*&---------------------------------------------------------------------*
*&      Form  OPEN_OUTPUT_FILE
*&---------------------------------------------------------------------*
FORM OPEN_OUTPUT_FILE.

  VOI-OUT_FILE = P_OUTNM.
  WRITE: / 'output file name is     :'(023) , VOI-OUT_FILE.

  DELETE DATASET      VOI-OUT_FILE .
  OPEN   DATASET      VOI-OUT_FILE   FOR OUTPUT   IN TEXT MODE ENCODING
                                                          DEFAULT.


ENDFORM.                               " OPEN_OUTPUT_FILE
*&---------------------------------------------------------------------*
*&      Form  CREATE_BALTD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_BALTD.

* fill table

  MOVE-CORRESPONDING I_OUT TO BALTD.
  MOVE  SY-MANDT   TO  BALTD-MANDT.

  IF I_OUT-BWASL-1 = '100' AND I_OUT-KANSW01 = '/' AND
     I_OUT-ANBTR01-1 = '/'.
     MOVE  '/'        TO  I_OUT-BWASL-1.
     MOVE  0          TO  I_OUT-BWCNT.
     IF I_OUT-ANLN2 EQ '/'.
        MOVE  C-TCODE    TO  BALTD-TCODE.
        MOVE  C-RCTYP_C  TO  BALTD-RCTYP.
     ELSE.
        MOVE '/'          TO  BALTD-ANLN2.
        MOVE  CS-TCODES   TO  BALTD-TCODE.
        MOVE  CS-RCTYP_CS TO  BALTD-RCTYP.
     ENDIF.
  ELSE.
     IF I_OUT-ANLN2 EQ ' '.
        MOVE '/'          TO  BALTD-ANLN1.
        MOVE '/'          TO  BALTD-ANLN2.
        MOVE  C-TCODE    TO  BALTD-TCODE.
        MOVE  C-RCTYP_C  TO  BALTD-RCTYP.
     ELSE.
        MOVE '/'          TO  BALTD-ANLN2.
        MOVE  CS-TCODES   TO  BALTD-TCODE.
        MOVE  CS-RCTYP_CS TO  BALTD-RCTYP.
     ENDIF.
  ENDIF.

  IF I_OUT-BWCNT = 0.
    MOVE '/' TO BALTD-BWCNT.
  ENDIF.

* transfer
  TRANSFER BALTD           TO VOI-OUT_FILE.

ENDFORM.                               " CREATE_BALTD

*&---------------------------------------------------------------------*
*&      Form  CREATE_BALTB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_BALTB USING CONT.

* fill table

  MOVE-CORRESPONDING I_OUT TO BALTB.
  CASE CONT.
  WHEN '1'.
     MOVE I_OUT-BWASL-1 TO BALTB-BWASL.
     MOVE I_OUT-BZDAT-1 TO BALTB-BZDAT.
     MOVE I_OUT-ANBTR01-1 TO BALTB-ANBTR01.
     MOVE I_OUT-ANBTR02-1 TO BALTB-ANBTR02.
     MOVE I_OUT-ANBTR03-1 TO BALTB-ANBTR03.
     MOVE I_OUT-ANBTR04-1 TO BALTB-ANBTR04.
     MOVE I_OUT-ANBTR05-1 TO BALTB-ANBTR05.
  WHEN '2'.
     MOVE I_OUT-BWASL-2 TO BALTB-BWASL.
     MOVE I_OUT-BZDAT-2 TO BALTB-BZDAT.
     MOVE I_OUT-ANBTR01-2 TO BALTB-ANBTR01.
     MOVE I_OUT-ANBTR02-2 TO BALTB-ANBTR02.
     MOVE I_OUT-ANBTR03-2 TO BALTB-ANBTR03.
     MOVE I_OUT-ANBTR04-2 TO BALTB-ANBTR04.
     MOVE I_OUT-ANBTR05-2 TO BALTB-ANBTR05.
  ENDCASE.

  MOVE  SY-MANDT  TO  BALTB-MANDT.
  MOVE  C-TCODE   TO  BALTB-TCODE.
  MOVE  C-RCTYP_P TO  BALTB-RCTYP.
*   MOVE  '/'       TO  baltb-bukrs.
*  MOVE  '/'       TO  baltb-anlkl.

* transfer
  TRANSFER BALTB          TO VOI-OUT_FILE.

ENDFORM.                               " CREATE_BALTB
*&---------------------------------------------------------------------*
*&      Form  CONVERT_FECHA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_IN_AKTIV  text                                           *
*----------------------------------------------------------------------*
FORM CONVERT_FECHA CHANGING P_FECHA
                            NEW_FECHA.

  DATA: T_MES(02), T_MES1(03), T_SPACE.

  CLEAR: T_MES, T_MES1, T_SPACE, NEW_FECHA.


  IF P_FECHA <> SPACE.
    NEW_FECHA(04)   = P_FECHA+4(04).                        "año
    NEW_FECHA+4(02) = P_FECHA+2(02).                        "mes
    NEW_FECHA+6(02) = P_FECHA(02).                          "dia
  ENDIF.

ENDFORM.                               " CONVERT_FECHA
