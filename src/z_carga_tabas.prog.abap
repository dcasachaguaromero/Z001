*&---------------------------------------------------------------------*
*& Report  Z_CARGA_TABAS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  Z_CARGA_TABAS.

TABLES: TABAS , T093.

DATA: XT093 LIKE TABLE OF T093 WITH HEADER LINE.

RANGES: r_afaber     FOR t093-AFABER.


PARAMETERS : P_BUKRS LIKE T001-BUKRS OBLIGATORY DEFAULT 'CL01',   "Sociedad
             P_GJAHR LIKE TABAS-GJAHR OBLIGATORY DEFAULT '2011'. "Ejercicio

SELECT-OPTIONS: S_AFABER FOR TABAS-AFABER OBLIGATORY
                 DEFAULT '06'. "Ar. Valorac.

PARAMETERS : P_CPUDT LIKE TABAS-CPUDT OBLIGATORY DEFAULT '20110101', "Día registro del documento contable
             P_CPUTM LIKE TABAS-CPUTM OBLIGATORY DEFAULT '240000' ,
             P_BLNRF LIKE TABAS-BLNRF OBLIGATORY,   "Nº de documento 'desde'
             P_BLNRT LIKE TABAS-BLNRT OBLIGATORY.  "A número de documen


PARAMETERS: P_TEST AS CHECKBOX DEFAULT 'X'.


LOOP AT S_AFABER.
  MOVE P_BUKRS   TO TABAS-BUKRS.  "Sociedad
  MOVE P_GJAHR   TO TABAS-GJAHR.  "Ejercicio
  MOVE S_AFABER-LOW  TO TABAS-AFABER. "Área de valoración real o derivada
  MOVE P_CPUDT   TO TABAS-CPUDT.  "Día del registro del documento contable
  MOVE P_CPUTM   TO TABAS-CPUTM.  "Hora de entrada
  MOVE P_BLNRF   TO TABAS-BLNRF.  "Nº de documento 'desde'
  MOVE P_BLNRT   TO TABAS-BLNRT.  "A número de documen

  CHECK P_TEST IS INITIAL.
  INSERT TABAS.
  IF SY-SUBRC NE 0.
    WRITE:/ ' ERROR AL GRABAR ' , TABAS.
  ELSE.
    WRITE:/ ' EXITO AL GRABAR' , TABAS.
  ENDIF.

ENDLOOP.





*SELECT * FROM T093 INTO TABLE XT093
*              WHERE AFAPL   = 'PCS' "Plan de valoración
*              AND   BUHBKT  = '2'.  "Contab. Periodica
*
*
*IF XT093[] IS INITIAL.
*  WRITE:/ 'NO HAY AREAS CONTAB. PERIODICAS' .
*ELSE.
*  REFRESH r_afaber.
*  LOOP AT XT093.
*    MOVE P_BUKRS       TO TABAS-BUKRS.  "Sociedad
*    MOVE P_GJAHR       TO TABAS-GJAHR.  "Ejercicio
*    MOVE XT093-AFABER  TO TABAS-AFABER. "Área de valoración real o derivada
*    MOVE P_CPUDT       TO TABAS-CPUDT.  "Día del registro del documento contable
*    MOVE P_CPUTM       TO TABAS-CPUTM.  "Hora de entrada
*    MOVE '9999999999'  TO TABAS-BLNRF.  "Nº de documento 'desde'
*    MOVE '9999999999'  TO TABAS-BLNRT.  "A número de documen
*
*    CHECK P_TEST IS INITIAL.
*    INSERT TABAS.
*    IF SY-SUBRC NE 0.
*      WRITE:/ ' ERROR AL GRABAR ' , TABAS.
*    ELSE.
*      WRITE:/ ' EXITO AL GRABAR' , TABAS.
*    ENDIF.
*  ENDLOOP.
*ENDIF.







.
