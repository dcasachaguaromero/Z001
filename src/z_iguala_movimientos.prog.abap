*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES03 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  Z_IGUALA_MOVIMIENTOS
*&
*&---------------------------------------------------------------------*
*&Iguala Movimientos Ar Modelo  = Ar Destino
*&
*&---------------------------------------------------------------------*

REPORT  Z_IGUALA_MOVIMIENTOS
                        MESSAGE-ID ZFI
                        line-size  132
                        line-count 65.

FIELD-SYMBOLS <F1>.

tables : anla, anlz, anlb ,anlc ,ANEK , anep ,ANEA ,ANLP ,CSKS.

tables : baltd , baltb.

DATA XANLA LIKE TABLE OF ANLA WITH HEADER LINE.
DATA XANEK LIKE TABLE OF ANEK WITH HEADER LINE.
DATA XANEP LIKE TABLE OF ANEP WITH HEADER LINE.
DATA XANEA LIKE TABLE OF ANEA WITH HEADER LINE.



SELECTION-SCREEN BEGIN OF BLOCK bl0 WITH FRAME TITLE text-000.
parameters : p_bukrs like anla-bukrs obligatory .
SELECTION-SCREEN END OF BLOCK bl0.
*
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
PARAMETERS: P_GJAHR LIKE ANLC-GJAHR OBLIGATORY DEFAULT '2011',
            P_AFA_IN LIKE ANLC-AFABE OBLIGATORY DEFAULT '10',
            P_AFA_OU LIKE ANLC-AFABE OBLIGATORY DEFAULT '20'.

SELECT-OPTIONS : S_BWASL FOR ANEP-BWASL,
                 S_BUDAT FOR ANEK-BUDAT OBLIGATORY,
                 S_CPUDT FOR ANEK-CPUDT.


SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-002.
SELECT-OPTIONS: S_ANLN1 FOR ANLA-ANLN1,
                S_ANLKL FOR ANLA-ANLKL.
SELECTION-SCREEN END OF BLOCK bl2.

SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE text-003.
PARAMETERS: P_OPTIO AS CHECKBOX DEFAULT 'X',
            P_baja  as CHECKBOX DEFAULT space.

SELECTION-SCREEN END OF BLOCK bl3.

start-of-selection.
*

* Rescata Activos que cumplen la condición
  if not P_baja is initial.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*     select * from anla into table xanla
*                        where bukrs = p_bukrs     and
*                              aktiv <> '00000000' and
**                             deakt =  '00000000' and
*                              anln1 in s_anln1    and
*                              anlkl in s_anlkl.
*
* NEW CODE
     SELECT *
 from anla into table xanla
                        where bukrs = p_bukrs     and
                              aktiv <> '00000000' and
*                             deakt =  '00000000' and
                              anln1 in s_anln1    and
                              anlkl in s_anlkl ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  else.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*     select * from anla into table xanla
*                        where bukrs = p_bukrs     and
*                              aktiv <> '00000000' and
*                              deakt =  '00000000' and
*                              anln1 in s_anln1    and
*                              anlkl in s_anlkl.
*
* NEW CODE
     SELECT *
 from anla into table xanla
                        where bukrs = p_bukrs     and
                              aktiv <> '00000000' and
                              deakt =  '00000000' and
                              anln1 in s_anln1    and
                              anlkl in s_anlkl ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  ENDIF.

  IF XANLA[] IS INITIAL.
    WRITE:/ 'NO SE SELECCIONARON ACTIVOS'.
  ELSE.
    LOOP AT XANLA.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      select * from v_anepk
*       APPENDING CORRESPONDING FIELDS OF table XANEK
*                  WHERE BUKRS = XANLA-BUKRS
*                  AND   ANLN1 = XANLA-ANLN1
*                  AND   ANLN2 = XANLA-ANLN2
*                  AND   GJAHR = P_GJAHR
*                  AND   BUDAT IN S_BUDAT
*                  AND   CPUDT IN S_CPUDT
*                  AND   BWASL IN S_BWASL
*                  AND   AFABE = P_AFA_IN.
*
* NEW CODE
      SELECT *
 from v_anepk
       APPENDING CORRESPONDING FIELDS OF table XANEK
                  WHERE BUKRS = XANLA-BUKRS
                  AND   ANLN1 = XANLA-ANLN1
                  AND   ANLN2 = XANLA-ANLN2
                  AND   GJAHR = P_GJAHR
                  AND   BUDAT IN S_BUDAT
                  AND   CPUDT IN S_CPUDT
                  AND   BWASL IN S_BWASL
                  AND   AFABE = P_AFA_IN ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    ENDLOOP.

*Begin of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 19/12/2019 EY_DES03 ECDK917080 *
SORT XANEK .
*End of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 19/12/2019 EY_DES03 ECDK917080 *
    DELETE ADJACENT DUPLICATES FROM XANEK.

    LOOP AT XANEK.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      select * from ANEP appending table XANEP
*               WHERE BUKRS = XANEK-BUKRS
*               AND   ANLN1 = XANEK-ANLN1
*               AND   ANLN2 = XANEK-ANLN2
*               AND   GJAHR = XANEK-GJAHR
*               AND   LNRAN = XANEK-LNRAN
*               AND   AFABE = P_AFA_IN.
*
* NEW CODE
      SELECT *
 from ANEP appending table XANEP
               WHERE BUKRS = XANEK-BUKRS
               AND   ANLN1 = XANEK-ANLN1
               AND   ANLN2 = XANEK-ANLN2
               AND   GJAHR = XANEK-GJAHR
               AND   LNRAN = XANEK-LNRAN
               AND   AFABE = P_AFA_IN ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    ENDLOOP.
*
    IF XANEP[] IS INITIAL.
      WRITE:/ 'NO SE SELECCIONARON MOVIMIENTOS'.
    ELSE.
      LOOP AT XANEP WHERE NOT XANTW IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*        select * from ANEA appending table XANEA
*           WHERE BUKRS = XANEP-BUKRS
*           AND   ANLN1 = XANEP-ANLN1
*           AND   ANLN2 = XANEP-ANLN2
*           AND   GJAHR = XANEP-GJAHR
*           AND   LNRAN = XANEP-LNRAN
*           AND   AFABE = XANEP-AFABE.
*
* NEW CODE
        SELECT *
 from ANEA appending table XANEA
           WHERE BUKRS = XANEP-BUKRS
           AND   ANLN1 = XANEP-ANLN1
           AND   ANLN2 = XANEP-ANLN2
           AND   GJAHR = XANEP-GJAHR
           AND   LNRAN = XANEP-LNRAN
           AND   AFABE = XANEP-AFABE ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      ENDLOOP.
      PERFORM AJUSTA_MOVIMIENTOS.
    ENDIF.
  ENDIF.

  WRITE:/ 'PROCESO FINALIZADO'.
  WRITE:/ ' EJECUTE AFAR  '.

*&---------------------------------------------------------------------*
*&      Form  AJUSTA_MOVIMIENTOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM AJUSTA_MOVIMIENTOS .

  LOOP AT XANEP.
    MOVE-CORRESPONDING XANEP TO ANEP.
    MOVE P_AFA_OU TO ANEP-AFABE.
    CHECK P_OPTIO IS INITIAL.
    MODIFY ANEP.
  ENDLOOP.
  COMMIT WORK.
*
  LOOP AT XANEA.
    MOVE-CORRESPONDING XANEA TO ANEA.
    MOVE P_AFA_OU TO ANEA-AFABE.
    CHECK P_OPTIO IS INITIAL.
    MODIFY ANEA.
  ENDLOOP.
  COMMIT WORK.

ENDFORM.                    " LIMPIA_CM
