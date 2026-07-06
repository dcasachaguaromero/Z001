*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZREPLICA_BAJAS_TOTALES
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZREPLICA_BAJAS_TOTALES
        no standard page heading line-size 255.

include bdcrecx1.


tables : anla, anlz, anlb ,anlc ,ANEK, anep ,ANEA ,ANLP ,CSKS.

DATA XANLA LIKE TABLE OF ANLA WITH HEADER LINE.
DATA WANEP LIKE TABLE OF ANEP WITH HEADER LINE.
DATA WANEA LIKE TABLE OF ANEA WITH HEADER LINE.
DATA XANEK LIKE TABLE OF ANEK WITH HEADER LINE.
DATA XANEP LIKE TABLE OF ANEP WITH HEADER LINE.
DATA XANEA LIKE TABLE OF ANEA WITH HEADER LINE.

DATA : FECHA(10) TYPE C,
       VALOR(16) TYPE C,
       INGRS(16) TYPE C,
       FACTOR(03) TYPE C,
       MES TYPE PERID,
       TXT_CAB(05) TYPE C,
       CANTID(13)  TYPE C,
       C_MOV(03) TYPE C,
       SV(01) TYPE C.


SELECTION-SCREEN BEGIN OF BLOCK bl0 WITH FRAME TITLE text-000.
parameters : p_bukrs like anla-bukrs obligatory .
SELECTION-SCREEN END OF BLOCK bl0.
*
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
PARAMETERS: P_GJAHR LIKE ANLC-GJAHR OBLIGATORY DEFAULT '2010',
*            P_AFABEN LIKE ANLC-AFABE OBLIGATORY default '50',  "Nueva Area
            P_AFABEM LIKE ANLC-AFABE OBLIGATORY default '10'.  "Area Modelo

SELECT-OPTIONS: S_BUDAT FOR ANEK-BUDAT OBLIGATORY,
                S_BWASL FOR ANEP-BWASL OBLIGATORY.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-002.
SELECT-OPTIONS: S_ANLN1 FOR ANLA-ANLN1,
                S_ANLN2 FOR ANLA-ANLN2.
*                S_ANLKL FOR ANLA-ANLKL.
SELECTION-SCREEN END OF BLOCK bl2.

SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE text-003.
PARAMETERS: P_REPBJ AS CHECKBOX DEFAULT ''.
SELECTION-SCREEN END OF BLOCK bl3.


start-of-selection.

* Rescata Movimientos que cumplen la condición
* Desde Area modelo

  select * from v_anepk
   APPENDING CORRESPONDING FIELDS OF table XANEK
                   WHERE BUKRS = P_BUKRS
                   AND   ANLN1 IN S_ANLN1
                   AND   ANLN2 IN S_ANLN2
                   AND   GJAHR = P_GJAHR
                   AND   BUDAT IN S_BUDAT
                   AND   BWASL IN S_BWASL
                   AND   AFABE = P_AFABEM.

*Begin of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 19/12/2019 EY_DES04 ECDK917080 *
SORT XANEK .
*End of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 19/12/2019 EY_DES04 ECDK917080 *
  DELETE ADJACENT DUPLICATES FROM XANEK.

  IF NOT XANEK[] IS INITIAL.

    LOOP AT XANEK.
      select * from ANEP appending table WANEP
               WHERE BUKRS = XANEK-BUKRS
               AND   ANLN1 = XANEK-ANLN1
               AND   ANLN2 = XANEK-ANLN2
               AND   GJAHR = XANEK-GJAHR
               AND   LNRAN = XANEK-LNRAN
               AND   AFABE = P_AFABEM.
    ENDLOOP.

    IF WANEP[] IS INITIAL.
      WRITE:/ 'NO SE SELECCIONARON MOVIMIENTOS BAJAS'.
    ELSE.
      LOOP AT WANEP.
        SELECT SINGLE * FROM ANLA WHERE bukrs = p_bukrs       and
                                        anln1 = WANEP-ANLN1 and
                                        anln2 = WANEP-ANLN2.
* Solo Activos Vigentes entran en proceso.
        IF ANLA-DEAKT IS INITIAL.
          MOVE-CORRESPONDING WANEP TO XANEP.
          APPEND XANEP.
        ENDIF.
      ENDLOOP.
*
      IF XANEP[] IS INITIAL.
        WRITE:/ 'NO SE SELECCIONARON MOVIMIENTOS A TRATAR'.
      ELSE.

        LOOP AT XANEP WHERE NOT XANTW IS INITIAL
                      AND   LNSAN IS INITIAL.

* LEE ANEA DEL AREA MODELO

* SI NUEVA AREA ES 50, LEE ANEA DE AREA MODELO
* y TAMBIEN AREA CM = 02.
*          IF P_AFABEN = '50'.

          select * from ANEA appending table XANEA
             WHERE BUKRS = XANEP-BUKRS
             AND   ANLN1 = XANEP-ANLN1
             AND   ANLN2 = XANEP-ANLN2
             AND   GJAHR = XANEP-GJAHR
             AND   LNRAN = XANEP-LNRAN
             AND   AFABE = XANEP-AFABE.
          COMMIT WORK .


*            select * from ANEA appending table XANEA
*               WHERE BUKRS = XANEP-BUKRS
*               AND   ANLN1 = XANEP-ANLN1
*               AND   ANLN2 = XANEP-ANLN2
*               AND   GJAHR = XANEP-GJAHR
*               AND   LNRAN = XANEP-LNRAN
*               AND   AFABE = '02'.
*            COMMIT WORK.
*          ENDIF.
*
        ENDLOOP.

        IF NOT P_REPBJ IS INITIAL.
          perform open_group.
          PERFORM REPLICA_BAJA.

        ENDIF.

      ENDIF.
    ENDIF.

    IF NOT P_REPBJ IS INITIAL.
      perform close_group.
    ENDIF.

    IF NOT P_REPBJ IS INITIAL.
      WRITE:/ 'EJECUCIÓN CON REPLICA DE MOVIMIENTOS'.
    ELSE.
      WRITE:/ 'EJECUCIÓN SIN REPLICA DE MOVIMIENTOS'.
    ENDIF.
*
    WRITE:/ 'PROCESO FINALIZADO'.
    WRITE:/ ' EJECUTE AFAR  '.
  ELSE.
    WRITE:/ 'NO SE SELECCIONARON REGISTROS'.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  REPLICA_BAJA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REPLICA_BAJA .
*
  LOOP AT XANEP.
*
    WRITE XANEP-BZDAT TO FECHA.
    MOVE FECHA+3(2) TO MES.
    MOVE XANEP-LNRAN TO TXT_CAB.
    MOVE XANEP-BWASL TO C_MOV.

    perform bdc_dynpro      using 'SAPMA01B' '0100'.
    perform bdc_field       using 'BDC_CURSOR'
                                  'ANBZ-BWASL'.
    perform bdc_field       using 'BDC_OKCODE'
                                  '/00'.
    perform bdc_field       using 'ANBZ-BUKRS'
                                   P_BUKRS.
    perform bdc_field       using 'ANBZ-ANLN1'
                                  XANEP-ANLN1.
    perform bdc_field       using 'ANBZ-ANLN2'
                                  XANEP-ANLN2.
    perform bdc_field       using 'ANEK-BLDAT'
                                   FECHA.
    perform bdc_field       using 'ANEK-BUDAT'
                                   FECHA.
    perform bdc_field       using 'ANBZ-PERID'
                                   MES.

    case c_mov.
      when '200'.
        perform bdc_field       using 'ANBZ-BWASL'
                                      'Y20'.
      when '210'.
        perform bdc_field       using 'ANBZ-BWASL'
                                      'Y21'.
      when '250'.
        perform bdc_field       using 'ANBZ-BWASL'
                                      'Y25'.
      when '260'.
        perform bdc_field       using 'ANBZ-BWASL'
                                      'Y60'.
    endcase.

*    VALOR = XANEP-ANBTR *  100.
*
    READ TABLE XANEA WITH KEY bukrs = XANEP-bukrs
                              anln1 = XANEP-anln1
                              anln2 = XANEP-anln2
                              gjahr = XANEP-gjahr
                              lnran = XANEP-lnran
                              afabe = XANEP-AFABE.
*
    IF XANEA-ERLBT < 0.
      INGRS = XANEA-ERLBT * -100.
    ELSE.
      INGRS = XANEA-ERLBT *  100.
    ENDIF.

*    IF VALOR < 0.
*      VALOR = VALOR * -1.
*    ENDIF.
*
*    REPLACE '.' WITH ',' INTO VALOR.
    REPLACE '.' WITH ',' INTO INGRS.

    perform bdc_dynpro      using 'SAPMA01B' '0120'.
    perform bdc_field       using 'BDC_CURSOR'
                                  'ANEK-XBLNR'.
    perform bdc_field       using 'BDC_OKCODE'
                                  '=UPDA'.
    perform bdc_field       using 'ANBZ-BZDAT'
                                   FECHA.
* BAJA TOTAL
    perform bdc_field       using 'ANBZ-XVABG'
                                  'X'.
*
    IF INGRS NE 0.

      perform bdc_field       using 'ANBZ-ERBDM'
                                       INGRS.
    ENDIF.
*
*    perform bdc_field       using 'ANBZ-DMBTR'
*                                   VALOR.

    perform bdc_field       using 'ANEK-SGTXT'
                                   TXT_CAB.
    perform bdc_field       using 'RA01B-ZUORD'
                                  'XANEP-LNRAN.'.
    perform bdc_field       using 'ANEK-XBLNR'
                                  'XANEP-LNRAN.'.

    perform bdc_transaction using 'ABAO'.



* Esto si se usa con Unidades, pero en ese caso deben ser todas las areas
* CARGAMOS CANTIDAD
* BUSCO EN ANEK CORRESPONDIENTE.

*  SELECT SINGLE * FROM ANEK
*     WHERE BUKRS = XANEP-BUKRS
*     AND   ANLN1 = XANEP-ANLN1
*     AND   ANLN2 = XANEP-ANLN2
*     AND   GJAHR = XANEP-GJAHR
*     AND   LNRAN = XANEP-LNRAN.
*
*  CANTID = ANEK-MENGE * 1.
*
*  perform bdc_field  using 'RAIFP2-MENGE'
*                            CANTID.

  ENDLOOP.

ENDFORM.                    " REPLICA_BAJA
