*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*

************************************************************************
* Programa : ZFITRASPASODOC
* Módulo   : FI - Finanzas
* Documento:
* Usuario responsable:
* Consultor funcional:
* Consultor ABAP     : HCASTILLO
* Descripción: Programa de Carga documentos SAP en ORACLE tabla DOCUMENTO_SAP.
* Transacción:
* Juego de datos:
************************************************************************

REPORT  ZFITRASPASODOC.
INCLUDE ole2incl.
*=======================================================================
* Tablas
*=======================================================================

"Definimos las tablas que vamos a leer
TABLES: BKPF,BSEG,M_KREDK, BSET, T003.


*=======================================================================
* Estructuras
*=======================================================================

"Creamos una tabla interna con los campos necesarios
"El OCCURS 0 indica que es una tabla dinámica
DATA: BEGIN OF T_DATOS OCCURS 0,
      BUKRS LIKE BKPF-BUKRS,
      BELNR LIKE BKPF-BELNR,
      GJAHR LIKE BKPF-GJAHR,
      BLART LIKE BKPF-BLART,
      WAERS LIKE BKPF-WAERS,
      BKTXT LIKE BKPF-BKTXT,
      MONAT LIKE BKPF-MONAT,
      BLDAT LIKE BKPF-BLDAT,
      XBLNR LIKE BKPF-XBLNR,
      XREVERSAL LIKE BKPF-XREVERSAL,
      MANDT LIKE BKPF-MANDT,
      DMBTR LIKE BSEG-DMBTR,
      LIFNR LIKE BSEG-LIFNR,
      MWSTS LIKE BSEG-MWSTS,
      MWSKZ LIKE BSEG-MWSKZ,
      MWSNR LIKE BSEG-MWSTS,
      MWSPR LIKE BSEG-MWSTS,
      ANLN1 LIKE BSEG-ANLN1,
      HWBAS LIKE BSEG-HWBAS,
      HWEXE LIKE BSEG-HWBAS,
      SORTL LIKE M_KREDK-SORTL,
      MCOD1 LIKE M_KREDK-MCOD1,
      HKOPR LIKE BSET-HKONT,
      HKONR LIKE BSET-HKONT,
      HKOIV LIKE BSET-HKONT,
      END OF T_DATOS.

DATA: BEGIN OF I1 OCCURS 0,
    LINEA(1000),
END OF I1.

DATA: BEGIN OF I2 OCCURS 0,
    LINEA(1000),
END OF I2.

DATA: BEGIN OF SPL OCCURS 0,
        VAL(1023),
      END OF SPL,
      sindx TYPE I.
*=======================================================================
* Variables
*=======================================================================

"Una variable a modo de contador
DATA: CONTADOR TYPE I.

DATA: con TYPE ole2_object,
      rec TYPE ole2_object,
      SQL(1023),
      V_AFECTO(20),
      V_EXENTO(20),
      V_IVA(20),
      V_IVA_NR(20),
      V_IVA_PR(20),
      v_TOTAL(20),
      V_EMPRESA like BKPF-BUKRS,
      amount_display like wmto_s-amount,
      amount_sap like wmto_s-amount.
*=======================================================================
* Selection screen
*=======================================================================

"Estos son los parámetros de selección de programa

SELECTION-SCREEN BEGIN OF BLOCK DATA WITH FRAME TITLE TEXT-T01.
"Podemos elegir un rango de valores
SELECT-OPTIONS:
      S_BUKRS FOR BKPF-BUKRS  NO-EXTENSION
                              NO INTERVALS.  .
"Podemos elegir solamente un valor
"OBLIGATORY indica que es obligatorio para ejecutar el programa
PARAMETERS:
      P_GJAHR LIKE BKPF-GJAHR OBLIGATORY,
      P_MONAT LIKE BKPF-MONAT OBLIGATORY,
    Guardar LIKE RLGRAP-FILENAME DEFAULT 'C:\'  MEMORY ID Guardar.
SELECTION-SCREEN END OF BLOCK DATA.

*=======================================================================
* Start-of-selection
*=======================================================================

"Comienza la ejecución del programa

START-OF-SELECTION.
"Llamamos a las funciones que hemos creado

CASE GUARDAR.
  WHEN ''.
    MESSAGE i004(zfi) WITH 'Escribe una Ruta'(i02).
  WHEN 'C:\'.
    MESSAGE i004(zfi) WITH 'Escribe un Nombre al Archivo " .TXT "'(i02).
  WHEN OTHERS.
    PERFORM OBTENER_DATOS.
    PERFORM IMPRIMIR_DATOS.
    PERFORM DESCARGA.

    MESSAGE i004(zfi) WITH 'Los Datos Fueron Descargados'(i02).
ENDCASE.


*=======================================================================
* Subrutinas
*=======================================================================

*&---------------------------------------------------------------------*
*&      Form  OBTENER_DATOS
*&---------------------------------------------------------------------*
* Obtenemos los datos de las tablas BKPF y BSEG.
*----------------------------------------------------------------------*

FORM OBTENER_DATOS.

"Seleccionamos los valores de la tabla BKPF que cumplan con los
"requisitos y los guardamos en nuestra tabla interna.
"El APPEND sirve para almacenar los valores en la ultima fila
"de la tabla interna




SELECT BUKRS BELNR GJAHR BLART WAERS BKTXT MONAT BLDAT XBLNR XREVERSAL MANDT
INTO T_DATOS
FROM BKPF
WHERE BUKRS IN S_BUKRS
  AND GJAHR EQ P_GJAHR
  AND MONAT EQ P_MONAT
  AND ( BLART EQ 'F1' OR BLART EQ 'F2' OR
        BLART EQ 'F3' OR BLART EQ 'F4' OR
        BLART EQ 'F5' OR BLART EQ 'F6' OR
        BLART EQ 'D1' OR BLART EQ 'D2' OR
        BLART EQ 'D3' OR BLART EQ 'D4' OR
        BLART EQ 'N1' OR BLART EQ 'N2' OR
        BLART EQ 'N3' OR BLART EQ 'N4' OR
        BLART EQ 'I1' OR BLART EQ 'I2' OR
        BLART EQ 'F0'
       ).
APPEND T_DATOS.
ENDSELECT.

"Hacemos un LOOP para recorrer todos los registros de nuestra
"tabla interna

LOOP AT T_DATOS.
"El SY-TABIX es una variable del sistema que nos indica el número
"de vueltas que ha dado un LOOP.
CONTADOR = SY-TABIX.
"Seleccionamos un dato y lo almacenamos en uno de los campos
"de nuestra tabla interna. El SINGLE indica que solo queremos un
"valor

* IMPORTE TOTAL
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
SELECT SINGLE DMBTR
INTO T_DATOS-DMBTR
FROM BSEG
WHERE BUKRS EQ T_DATOS-BUKRS
  AND BELNR EQ T_DATOS-BELNR
  AND GJAHR EQ T_DATOS-GJAHR
  AND KOART EQ 'K'.

* ACREEEDOR
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
SELECT SINGLE LIFNR
INTO T_DATOS-LIFNR
FROM BSEG
WHERE BUKRS EQ T_DATOS-BUKRS
  AND BELNR EQ T_DATOS-BELNR
  AND GJAHR EQ T_DATOS-GJAHR
  AND KOART EQ 'K'.

* IMPUESTO
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
SELECT SINGLE HWSTE
INTO T_DATOS-MWSTS
FROM BSET
WHERE BUKRS EQ T_DATOS-BUKRS
  AND BELNR EQ T_DATOS-BELNR
  AND GJAHR EQ T_DATOS-GJAHR
  AND MWSKZ EQ 'C1' .
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
SELECT SINGLE HKONT
INTO T_DATOS-HKOIV
FROM BSET
WHERE BUKRS EQ T_DATOS-BUKRS
  AND BELNR EQ T_DATOS-BELNR
  AND GJAHR EQ T_DATOS-GJAHR
  AND MWSKZ EQ 'C1' .
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
SELECT SINGLE HWSTE
INTO T_DATOS-MWSNR
FROM BSET
WHERE BUKRS EQ T_DATOS-BUKRS
  AND BELNR EQ T_DATOS-BELNR
  AND GJAHR EQ T_DATOS-GJAHR
  AND (  MWSKZ EQ 'C4' OR MWSKZ EQ 'C6' ) .
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
SELECT SINGLE   HKONT
INTO   T_DATOS-HKONR
FROM BSET
WHERE BUKRS EQ T_DATOS-BUKRS
  AND BELNR EQ T_DATOS-BELNR
  AND GJAHR EQ T_DATOS-GJAHR
  AND (  MWSKZ EQ 'C4' OR MWSKZ EQ 'C6' ) .
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
SELECT SINGLE HWSTE
INTO T_DATOS-MWSPR
FROM BSET
WHERE BUKRS EQ T_DATOS-BUKRS
  AND BELNR EQ T_DATOS-BELNR
  AND GJAHR EQ T_DATOS-GJAHR
  AND (  MWSKZ EQ 'C5' OR MWSKZ EQ 'C9' ) .
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
SELECT SINGLE   HKONT
INTO   T_DATOS-HKOPR
FROM BSET
WHERE BUKRS EQ T_DATOS-BUKRS
  AND BELNR EQ T_DATOS-BELNR
  AND GJAHR EQ T_DATOS-GJAHR
  AND (  MWSKZ EQ 'C5' OR MWSKZ EQ 'C9' ) .
*INDICADOR DE IMPUESTO
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
SELECT SINGLE MWSKZ
INTO T_DATOS-MWSKZ
FROM BSET
WHERE BUKRS EQ T_DATOS-BUKRS
  AND BELNR EQ T_DATOS-BELNR
  AND GJAHR EQ T_DATOS-GJAHR.

*---------------


* valor afecto
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
SELECT SINGLE HWBAS
INTO   T_DATOS-HWBAS
FROM   BSET
WHERE  BUKRS EQ T_DATOS-BUKRS
  AND  BELNR EQ T_DATOS-BELNR
  AND  GJAHR EQ T_DATOS-GJAHR
  AND  HWSTE NE 0.

* valor exento
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
SELECT SINGLE  HWBAS
INTO   T_DATOS-HWEXE
FROM   BSET
WHERE  BUKRS EQ T_DATOS-BUKRS
  AND  BELNR EQ T_DATOS-BELNR
  AND  GJAHR EQ T_DATOS-GJAHR
  AND  HWSTE EQ 0.

* TIENE ACTIVO FIJO
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
 SELECT SINGLE ANLN1
  INTO   T_DATOS-ANLN1
FROM BSEG
WHERE BUKRS EQ T_DATOS-BUKRS
  AND BELNR EQ T_DATOS-BELNR
  AND GJAHR EQ T_DATOS-GJAHR
  AND KOART EQ 'A'.



* RUT ACREEDOR

  SELECT SINGLE SORTL
  INTO   T_DATOS-SORTL
  FROM   M_KREDK
WHERE BUKRS EQ T_DATOS-BUKRS
  AND LIFNR EQ T_DATOS-LIFNR.

* NOMBRE ACREEDOR

SELECT SINGLE MCOD1
  INTO   T_DATOS-MCOD1
  FROM   M_KREDK
WHERE BUKRS EQ T_DATOS-BUKRS
  AND LIFNR EQ T_DATOS-LIFNR.




*---------



"El MODIFY modifica la tabla interna, para agregar el valor
"que hemos obtenido en el query anterior, utilizando como
"indice, el número de vuelta del LOOP

MODIFY T_DATOS INDEX CONTADOR.

ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  IMPRIMIR_DATOS
*&---------------------------------------------------------------------*
* Imprimimos en pantalla los datos generados
*----------------------------------------------------------------------*

FORM IMPRIMIR_DATOS.
    perform openconnection.

"Imprimimos una pequeña cabecera con los titulos

*WRITE:/1 'Sociedad',15 'Doc. Contable',30 'Año',37 'Moneda',
*55 'Monto', 70 'Clas.Doc.',80 'GLOSA', 100 'PERIODO',110 'id PROV',120 'IVA',140 'MONTOIVA',
*150 'FECHA DOC',165 'ACTIVOF',170 'RUT',175 'REFERNCIA'.

"Recorremos nuestra tabla interna e imprimimos en pantalla
"registro por registro...


V_EMPRESA  =  S_BUKRS-low.

LOOP AT T_DATOS.

*WRITE:/1 T_DATOS-BUKRS,15 T_DATOS-BELNR,30 T_DATOS-GJAHR,
*38 T_DATOS-WAERS,45 T_DATOS-DMBTR,70 T_DATOS-BLART,
*80 T_DATOS-BKTXT, 100 T_DATOS-MONAT,110 T_DATOS-LIFNR,
*120  T_DATOS-MWSTS,140  T_DATOS-MWSKZ, 150 T_DATOS-BLDAT,165 T_DATOS-ANLN1,
*170 T_DATOS-SORTL,175 T_DATOS-XBLNR.


amount_sap =  T_DATOS-MWSTS.

CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
    EXPORTING
      CURRENCY              = T_DATOS-WAERS
      AMOUNT_INTERNAL       = amount_sap
      IMPORTING
     AMOUNT_DISPLAY        = amount_display.
 IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
V_IVA = amount_display.


*------------------------------
* INICIO TOTAL
*------------------------------
amount_sap = T_DATOS-DMBTR.

CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
    EXPORTING
      CURRENCY              = T_DATOS-WAERS
      AMOUNT_INTERNAL       = amount_sap
   IMPORTING
     AMOUNT_DISPLAY        = amount_display
*   EXCEPTIONS
*     INTERNAL_ERROR        = 1
*     OTHERS                = 2
            .
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

V_TOTAL = amount_display.
*------------------------------
* FIN TOTAL
*------------------------------

amount_sap = T_DATOS-MWSNR.

CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
    EXPORTING
      CURRENCY              = T_DATOS-WAERS
      AMOUNT_INTERNAL       = amount_sap
   IMPORTING
     AMOUNT_DISPLAY        = amount_display
*   EXCEPTIONS
*     INTERNAL_ERROR        = 1
*     OTHERS                = 2
            .
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

V_IVA_NR = amount_display.

* IVA PRPORCIONAL

amount_sap = T_DATOS-MWSPR.

CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
    EXPORTING
      CURRENCY              = T_DATOS-WAERS
      AMOUNT_INTERNAL       = amount_sap
   IMPORTING
     AMOUNT_DISPLAY        = amount_display
*   EXCEPTIONS
*     INTERNAL_ERROR        = 1
*     OTHERS                = 2
            .
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

V_IVA_PR = amount_display.

amount_sap = T_DATOS-HWBAS.

CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
    EXPORTING
      CURRENCY              = T_DATOS-WAERS
      AMOUNT_INTERNAL       = amount_sap
   IMPORTING
     AMOUNT_DISPLAY        = amount_display
*   EXCEPTIONS
*     INTERNAL_ERROR        = 1
*     OTHERS                = 2
            .
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
V_afecto = amount_display.


amount_sap = T_DATOS-HWEXE.

CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
    EXPORTING
      CURRENCY              = T_DATOS-WAERS
   AMOUNT_INTERNAL       = amount_sap
   IMPORTING
     AMOUNT_DISPLAY        = amount_display
*   EXCEPTIONS
*     INTERNAL_ERROR        = 1
*     OTHERS                = 2
            .
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
V_exento = amount_display.


if V_afecto = 0.
    V_exento  = V_TOTAL.
ENDIF.

EXEC SQL.
      EXECUTE PROCEDURE SAP_CARGAS_DE_DATOS_PKG.SAP_CARGA_DOCUMENTOS_VENTA_V2(
                      IN :T_DATOS-BUKRS  ,
                      IN :T_DATOS-BELNR  ,
                      IN :T_DATOS-SORTL  ,
                      IN :T_DATOS-BLDAT  ,
                      IN :T_DATOS-BKTXT ,
                      IN :V_afecto ,
                      IN :V_exento ,
                      IN :V_IVA ,
                      IN :V_TOTAL      ,
                      IN :T_DATOS-XBLNR ,
                      IN :T_DATOS-BLART ,
                      IN :T_DATOS-BLART ,
                      IN :T_DATOS-ANLN1 ,
                      IN :T_DATOS-MWSKZ ,
                      IN :V_IVA_NR     ,
                      IN :T_DATOS-MONAT ,
                      IN :T_DATOS-GJAHR ,
                      IN :T_DATOS-XREVERSAL ,
                      IN :T_DATOS-MCOD1 ,
                      IN :V_IVA_PR     ,
                      IN :T_DATOS-HKOPR ,
                      IN :T_DATOS-HKONR ,
                      IN :T_DATOS-HKOIV )
ENDEXEC.


* write: / SQL.
 CONTADOR = 0.




ENDLOOP.

EXEC SQL.
        EXECUTE PROCEDURE SAP_CARGAS_DE_DATOS_PKG.generar_archivo_plano(
                        IN :V_EMPRESA  ,
                        IN :P_GJAHR  ,
                        IN :P_MONAT
                        )
ENDEXEC.





   EXEC SQL.
      OPEN c1 FOR
       select linea from SAP_LIBRO_ELECTRONICO
        where  sociedad          = :V_EMPRESA
                 and ano         =   :P_GJAHR
                 and periodo     = :P_MONAT
                 order by secuencia asc

   ENDEXEC.

 CONTADOR = 0.

    DO.
      EXEC SQL.
        FETCH NEXT c1 INTO  :I2-LINEA

      ENDEXEC.
      IF sy-subrc <> 0.
        EXIT.
      ELSE.
        APPEND I2 TO I1.
      ENDIF.
    ENDDO.
    EXEC SQL.
      CLOSE c1
    ENDEXEC.

perform closeconnection.

ENDFORM.

form DESCARGA.







CALL FUNCTION 'WS_DOWNLOAD'
      EXPORTING
        filename                      = Guardar
        filetype                      = 'DAT'
     TABLES
        data_tab                      = I1
   EXCEPTIONS
     INTERNAL_ERROR        = 1
     OTHERS                = 2.


CASE sy-subrc.
  WHEN 1.
    WRITE 'Validar Ruta y nombre de archivo'.
  WHEN 2.
    WRITE 'Validar Ruta y nombre de archivo'.
ENDCASE.

endform.
*----------------------------------------------------------------------*
* RUTINAS DE CONEXION  *
*----------------------------------------------------------------------*
form openconnection.
    exec sql.
          connect to 'SAPCSC' as 'CON'
       endexec.
      exec sql.
          set connection 'CON'
      endexec.
endform.
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
form closeconnection.
    exec sql.
      SET CONNECTION DEFAULT
    endexec.
endform.
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
