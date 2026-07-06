*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES03 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  Z_ELIMINA_DOC_COMPLETO_AF
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  Z_ANULA_DOC_COMPLETO_AF.

TABLES: ANLA, ANEK , ANEP, ANEA, ANLH, V_ANEPK, T093.


DATA XANEK LIKE TABLE OF ANEK WITH HEADER LINE.
DATA WANEK LIKE TABLE OF ANEK WITH HEADER LINE.

DATA XANEP LIKE TABLE OF ANEP WITH HEADER LINE.
DATA XANEA LIKE TABLE OF ANEA WITH HEADER LINE.

DATA : VEZ(05) TYPE C,
       W_GJAHR LIKE ANLC-GJAHR.


SELECTION-SCREEN BEGIN OF BLOCK bl0 WITH FRAME TITLE text-000.
parameters : p_bukrs like anla-bukrs obligatory .
SELECTION-SCREEN END OF BLOCK bl0.
*
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: S_GJAHR FOR ANEK-GJAHR OBLIGATORY DEFAULT '2011',
                S_BUDAT FOR ANEk-BUDAT OBLIGATORY,
                S_BWASL FOR ANEP-BWASL OBLIGATORY,
                S_TCODE FOR ANEK-TCODE,
                S_BELNR FOR ANEP-BELNR,
                S_CPUDT FOR ANEK-CPUDT,
                S_USNAM FOR ANEK-USNAM.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-002.
SELECT-OPTIONS: S_ANLN1 FOR ANLA-ANLN1.
*                  S_ANLKL FOR ANLA-ANLKL.
SELECT-OPTIONS: S_AFABE FOR T093-AFABER OBLIGATORY .

SELECTION-SCREEN END OF BLOCK bl2.

SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE text-003.
PARAMETERS: P_OPTIO AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK bl3.

DATA: MAX_LNRAN LIKE ANEK-LNRAN.


start-of-selection.

  select * from v_anepk
  APPENDING CORRESPONDING FIELDS OF table XANEK
                  WHERE BUKRS = P_BUKRS
                  AND   ANLN1 IN S_ANLN1
                  AND   GJAHR IN S_GJAHR
                  AND   BUDAT IN S_BUDAT
                  AND   BWASL IN S_BWASL
                  AND   TCODE IN S_TCODE
                  AND   BELNR IN S_BELNR
                  AND   CPUDT IN S_CPUDT
                  AND   USNAM IN S_USNAM.

*Begin of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 19/12/2019 EY_DES03 ECDK917080 *
SORT XANEK .
*End of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 19/12/2019 EY_DES03 ECDK917080 *
  DELETE ADJACENT DUPLICATES FROM XANEK.

  IF NOT XANEK[] IS INITIAL.

    LOOP AT XANEK.
      select * from ANEP appending table XANEP
               WHERE BUKRS = XANEK-BUKRS
               AND   ANLN1 = XANEK-ANLN1
               AND   ANLN2 = XANEK-ANLN2
               AND   GJAHR = XANEK-GJAHR
               AND   BELNR = XANEK-BELNR
               AND   LNRAN = XANEK-LNRAN
               AND   AFABE IN S_AFABE.

      select * from ANEA appending table XANEA
           WHERE BUKRS = XANEK-BUKRS
           AND   ANLN1 = XANEK-ANLN1
           AND   ANLN2 = XANEK-ANLN2
           AND   GJAHR = XANEK-GJAHR
           AND   LNRAN = XANEK-LNRAN
           AND   AFABE IN S_AFABE.
    ENDLOOP.

* BORRADO DOCUMENTOS.
    PERFORM BORRADO.
    FREE : XANEP , XANEA.
* DETERMINA ULTIMO CORRELATIVO
    PERFORM DET_CORR.
  ELSE.
    WRITE:/ 'NO SE SELECCIONARON MOVIMIENTOS'.
  ENDIF.
*
  WRITE:/.
  WRITE:/ 'FIN PROCESO'.
  IF P_OPTIO IS INITIAL.
    WRITE:/ 'REGISTRO BORRADOS'.
    WRITE:/ 'CORRELATIVO MODIFICADO'.
  ELSE.
    WRITE:/ 'REGISTROS NO BORRADOS'.
    WRITE:/ 'CORRELATIVO NO MODIFICADO'.
  ENDIF.
*
*&---------------------------------------------------------------------*
*&      Form  BORRADO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BORRADO .
*
  LOOP AT XANEK.

* VERIFICA QUE LA CABECERA SOLO TENGA MOV POR LAS AREAS INDICADAS
* PARA BORRARLA, SINO LA DEJA.

    SELECT SINGLE * FROM ANEP WHERE BUKRS = XANEK-BUKRS
                               AND   ANLN1 = XANEK-ANLN1
                               AND   ANLN2 = XANEK-ANLN2
                               AND   GJAHR = XANEK-GJAHR
                               AND   LNRAN = XANEK-LNRAN
                               AND   BELNR = XANEK-BELNR
                               AND   AFABE NOT IN S_AFABE.
*
    IF SY-SUBRC NE 0.
      VEZ = VEZ + 1.
      MOVE-CORRESPONDING XANEK TO ANEK.
      CHECK P_OPTIO IS INITIAL.
      DELETE ANEK.
      IF VEZ > 1000.
        COMMIT WORK.
        CLEAR VEZ.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CLEAR VEZ.

  LOOP AT XANEP.
    VEZ =  VEZ + 1.
    MOVE-CORRESPONDING XANEP TO ANEP.
    CHECK P_OPTIO IS INITIAL.
    DELETE ANEP.
    IF VEZ > 1000.
      COMMIT WORK.
      CLEAR VEZ.
    ENDIF.
  ENDLOOP.

  CLEAR VEZ.

  LOOP AT XANEA.
    VEZ = VEZ + 1.
    MOVE-CORRESPONDING XANEA TO ANEA.
    CHECK P_OPTIO IS INITIAL.
    DELETE ANEA.
    IF VEZ > 1000.
      COMMIT WORK.
      CLEAR VEZ.
    ENDIF.
  ENDLOOP.
*
ENDFORM.                    " BORRADO
*&---------------------------------------------------------------------*
*&      Form  DET_CORR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DET_CORR .
*
* DETERMINA ULTIMO CORRELATIVO

*Begin of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 19/12/2019 EY_DES03 ECDK917080 *
SORT XANEK by ANLN1 ANLN2.
*End of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 19/12/2019 EY_DES03 ECDK917080 *
  DELETE ADJACENT DUPLICATES FROM XANEK
                  COMPARING ANLN1 ANLN2 .

  LOOP AT XANEK.

    MOVE-CORRESPONDING XANEK TO WANEK.

    AT NEW ANLN1.

      SELECT MAX( LNRAN ) INTO MAX_LNRAN FROM ANEK
      WHERE BUKRS = WANEK-BUKRS
      AND   ANLN1 = WANEK-ANLN1.
*      AND   GJAHR IN S_GJAHR.


      SELECT SINGLE * FROM ANLH WHERE BUKRS = WANEK-BUKRS
                                AND   ANLN1 = WANEK-ANLN1.

      ANLH-LANEP = MAX_LNRAN.
      WRITE:/ ANLH-ANLN1 , 'ULTIMO CORR' , MAX_LNRAN.
      CHECK P_OPTIO IS INITIAL.
      MODIFY ANLH.

    ENDAT.

  ENDLOOP.
*
ENDFORM.                    " DET_CORR
