*&---------------------------------------------------------------------*
*& Report  ZFIPG007                                           *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT  ZFIPG007                        .

TABLES: TABAS , T093.

DATA: XT093 LIKE TABLE OF T093 WITH HEADER LINE.

RANGES: r_afaber     FOR t093-AFABER.


PARAMETERS : P_BUKRS LIKE T001-BUKRS OBLIGATORY DEFAULT 'CL035',
             P_GJAHR LIKE TABAS-GJAHR OBLIGATORY DEFAULT '2009',
             P_CPUDT LIKE TABAS-CPUDT OBLIGATORY,
             P_CPUTM LIKE TABAS-CPUTM OBLIGATORY DEFAULT '240000'.

PARAMETERS: P_TEST AS CHECKBOX DEFAULT 'X'.


* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*SELECT * FROM T093 INTO TABLE XT093
*              WHERE AFAPL   = 'BM01' "Plan de valoración
*              AND   BUHBKT  = '6'.  
*
* NEW CODE
SELECT *
 FROM T093 INTO TABLE XT093
              WHERE AFAPL   = 'BM01' "Plan de valoración
              AND   BUHBKT  = '6' ORDER BY PRIMARY KEY.  

* END. 07-07-2026 - ATC - ATC-03"Contab. Periodica


IF XT093[] IS INITIAL.
  WRITE:/ 'NO HAY AREAS CONTAB. PERIODICAS' .
ELSE.
  REFRESH r_afaber.
  LOOP AT XT093.
    MOVE P_BUKRS       TO TABAS-BUKRS.  "Sociedad
    MOVE P_GJAHR       TO TABAS-GJAHR.  "Ejercicio
    MOVE XT093-AFABER  TO TABAS-AFABER.
    "Área de valoración real o derivada
    MOVE P_CPUDT       TO TABAS-CPUDT.
    "Día del registro del documento contable
    MOVE P_CPUTM       TO TABAS-CPUTM.  "Hora de entrada
    MOVE '9999999999'  TO TABAS-BLNRF.  "Nº de documento 'desde'
    MOVE '9999999999'  TO TABAS-BLNRT.  "A número de documen

    CHECK P_TEST IS INITIAL.
    INSERT TABAS.
    IF SY-SUBRC NE 0.
      WRITE:/ ' ERROR AL GRABAR ' , TABAS.
    ELSE.
      WRITE:/ ' EXITO AL GRABAR' , TABAS.
    ENDIF.
  ENDLOOP.
ENDIF.
